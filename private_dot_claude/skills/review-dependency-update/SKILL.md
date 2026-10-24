---
name: review-dependency-update
description: Renovate や Dependabot が出したライブラリ更新 PR をレビューし、approve して本番に出してよいかを判断する。更新されるバージョンの release note / changelog を読んでプロダクトへの影響を調べ、CI を確認し、コンフリクトがあれば解消して push する。影響や CI 失敗があればプロダクト側の修正方法を調べて提案する。「この renovate の PR レビューして」「dependabot の PR 見て」「ライブラリアップデートの PR 確認して」のような依頼や、作成者が renovate / dependabot の PR のレビュー依頼で発動する。人が書いたコード変更の PR には使わず code-review に任せる。
---

# review-dependency-update

ゴールは「approve & merge して本番に出してよいか」をユーザーに伝えること。diff の見た目が正しいかではなく、**新しいバージョンのライブラリがこのプロダクトで何を変えるか**を見る。approve と merge はユーザーがやるので、このスキルでは実行しない。

## 全体フロー

1. PR の把握
2. 実際に変わるバージョンの特定
3. release note / changelog を読む
4. プロダクトへの影響を調べる
5. セキュリティの確認
6. コンフリクトの解消
7. CI の確認
8. 修正方法の提案（問題があった場合）
9. 判定と報告

---

## 1. PR の把握

```bash
gh pr view <PR> --json author,headRefName,baseRefName,mergeable,mergeStateStatus,body,files
gh pr diff <PR>
```

- 作成者が bot でない場合も使えるが、手で書いたコード変更が混ざっていたらその部分は code-review に回すと伝える。
- Renovate の PR 本文には release note が抜粋されていることが多い。ただし途中で切れていることがあるので、それだけで済ませない。

## 2. 実際に変わるバージョンの特定

manifest（`package.json`、`Gemfile`、`Dockerfile`、workflow など）の差分だけでなく、**lockfile で解決されるバージョンが base と head でどう変わるか**を確かめる。

- **lockfile のバージョンが base のまま変わらない**ケースがある（manifest の下限だけを上げる PR）。この場合、入るコードは今の base と同じなので、本番の挙動は変わらない。それでも release note は読む。そのバージョンは確認されないまま base に入った可能性があるので、報告では「すでに base に入っている」と書き分ける。
- **間接依存の変化**: lockfile で巻き込まれて変わるパッケージ、新しく増えるパッケージや消えるパッケージ、deprecated の印が付いたパッケージを拾う。
- **重複**: React のように2つ入ると実行時に壊れるライブラリは、古いバージョンが lockfile に残っていないかを grep で確かめる。
- **セットで出るパッケージ**（monorepo のパッケージ群、`react` / `react-dom`、`@types/*`）が全部そろっているか。
- **依存の種類**: 本番で動くもの（`dependencies`、Gemfile のデフォルトグループ、ベースイメージ）か、開発時だけのもの（`devDependencies`、test グループ、lint ツール）か。後者なら本番への影響は小さい。

このあと読む範囲は「**旧バージョンの次から新バージョンまで**の全リリース」になる。途中のバージョンを飛ばさない。

## 3. release note / changelog を読む

次の順で探し、見つかったところで止める。

1. GitHub Releases: `gh release list -R <owner>/<repo>` で範囲内のタグを洗い出し、`gh release view <tag> -R <owner>/<repo>` で読む。monorepo では `@scope/pkg@1.2.3` のようなタグ名になっていることがある。
2. リポジトリの `CHANGELOG.md`（monorepo ではパッケージごとのディレクトリにあることが多い）
3. 上の2つが無ければ、タグ間の差分（`gh api repos/<owner>/<repo>/compare/<old>...<new>`）や `npm diff --diff=<pkg>@<old> --diff=<pkg>@<new>` を読む。

リポジトリの URL がわからなければ、`npm view <pkg> repository.url` や rubygems の `source_code_uri` で調べる。

拾うもの:
- Breaking / Important と書かれた項目
- 挙動の変化（既定値の変更、送るデータの変化、集計方法の変更）
- deprecated になった API やオプション
- 動作環境の条件（Node / Ruby のバージョン、peer dependency）
- セキュリティ修正

あわせて **新バージョンより新しいリリースが出ていないか**も見る。対象のバージョンにある不具合が次のバージョンで直っているなら、そちらを待つ選択肢を報告に書く。

semver の番号だけで影響の大きさを決めない。0.x のパッケージや、patch で挙動を変えるパッケージがある。

## 4. プロダクトへの影響を調べる

拾った項目ごとに、このリポジトリで使っているかを調べる。

- そのパッケージの import / require、設定ファイル（例: `next.config.*`、`instrumentation*.ts`、initializer）を grep し、release note に出てくる API 名やオプション名が使われているかを見る。
- 動作環境の条件は、`Dockerfile`、`.node-version`、`.ruby-version`、`mise.toml`、`package.json` の `engines` と照らし合わせる。
- CI で見つからない変化に注意する。設定値の効く範囲が変わる、外部サービス（Sentry、New Relic など）での数字の見え方が変わる、といったものはテストが通ったままになる。

各項目を次の3つに分ける。
- **対応が必要**: このままだと壊れる、または意図しない挙動になる。
- **挙動が変わる**: 対応はいらないが、デプロイ後に確かめた方がいい。
- **関係ない**: この repo では使っていない。報告ではまとめて1行にする。

## 5. セキュリティの確認

- **脆弱性の修正**: この更新が脆弱性の修正なら、優先して出すべきと報告する。GitHub Advisory は `gh api graphql` の `securityVulnerabilities(ecosystem: NPM, package: "<pkg>")` などで引ける。逆に、新しいバージョンに既知の脆弱性がないかも同じ方法で見る。
- **サプライチェーン攻撃の兆候**: 次のどれかがあれば報告に書く。
  - 公開されたばかりのバージョン（`npm view <pkg> time`）
  - メンテナの交代
  - インストール時に動くスクリプトの追加（lockfile の `requiresBuild` / `hasInstallScript` が新しく付いた、など）
  - 名前のよく似た別パッケージへの置き換え

## 6. コンフリクトの解消

`mergeable` が `CONFLICTING` なら、確認せずに解消してよい（ユーザーの指示）。`UNKNOWN` のときは GitHub の計算待ちなので、少し時間を置いて取り直す。

### まず bot に作り直させる

人がコミットを足すと bot がその PR を自動で更新しなくなるので、先に bot 自身に作り直させる。

- **Renovate**: PR 本文の `- [ ] <!-- rebase-check -->` を `- [x] <!-- rebase-check -->` に書き換える（`gh pr view <PR> --json body -q .body` で取得し、置換して `gh pr edit <PR> --body-file <file>`）。本文のほかの部分は変えない。
- **Dependabot**: `@dependabot rebase` とだけ書いたコメントを `gh pr comment` で投稿する。

そのあと 10 分ほど、head のコミット（`gh pr view <PR> --json headRefOid`）が変わって `MERGEABLE` になるかを見る。待つときは Monitor などで条件が満たされるまで待ち、短い間隔で何度も問い合わせない。

Renovate はチェックボックスに反応しないことがある。反応しなければ、原因は Mend の job log（PR 本文末尾のリンク）でわかるかもしれないと報告に添えて、手で解消する。

### 手で解消する

作業はユーザーが今いるブランチを汚さないよう、scratchpad に worktree を切って行う。

```bash
git fetch origin <base> <head>
git worktree add -B <head> <scratchpad>/wt-<PR> origin/<head>
cd <scratchpad>/wt-<PR>
git merge origin/<base> --no-edit
```

- rebase して force push はしない。ruleset で force push が禁止されていることがあるうえ、bot が後から触ったときに履歴が壊れやすいので、merge でそろえる。
- **lockfile のコンフリクト**: 手で混ぜずに base 側を採用し、パッケージマネージャで作り直す。
  - pnpm: `git checkout --theirs pnpm-lock.yaml && pnpm install --lockfile-only`
  - npm: `npm install --package-lock-only`
  - Bundler: `bundle lock`
- **manifest のコンフリクト**: head のバージョンの更新と、base で入った他の変更を両方残す。
- 解消したら `git diff origin/<base>` を見て、**この PR が意図した更新以外の差分が出ていない**ことを確かめてからコミットする。
- push したら `gh pr view <PR> --json mergeable` で `MERGEABLE` になったことを確かめ、worktree とローカルブランチを片付ける。

手で解消したときは、人がコミットを足したので bot がこの PR を自動で rebase / 更新しなくなることを報告で伝える。Renovate も Dependabot も同じ。

push すると CI が走り直すので、7 は push の後に行う。

## 7. CI の確認

```bash
gh pr checks <PR>
gh api repos/<owner>/<repo>/rules/branches/<base>   # ruleset の必須チェックと承認ルール
gh api repos/<owner>/<repo>/branches/<base>/protection  # 古い branch protection（404 なら未設定）
```

- **終わっていないチェックがあれば終わるまで待つ**。`gh pr checks <PR> --watch` をバックグラウンドで動かし、終わったら続ける。
- **skip を合格と数えない**。表示が pass でも中身が「Skipped build」などのチェックは、そのテストが動いていないということなので、報告に書く。
- **必須チェック**が全部通っているかを、ruleset / branch protection と突き合わせる。
- **落ちていたら**ログを読む。GitHub Actions は `gh run view <run-id> --log-failed`、CircleCI などはチェックの URL から辿る。そのうえで、この更新が原因かを見分ける。
  - base の最新コミットでも同じチェックが落ちているなら、この PR とは関係ない。
  - 同じジョブを再実行して通るなら flaky。
  - どちらでもなければ、この更新が原因として 8 に進む。

## 8. 修正方法の提案（問題があった場合）

4 で「対応が必要」が出たとき、または 7 で更新が原因の失敗があったときに行う。

- migration guide、release note の該当箇所、upstream の issue を読み、プロダクト側の具体的な修正（変更するファイルと差分の案）を作る。
- **提案までにとどめ、勝手に修正をコミットしない**。どの PR に載せるか（この PR に積むか、別 PR で先に直すか）も選択肢として示す。
- 修正にリスクや未確認の点があれば、そのまま書く。

## 9. 判定と報告

次が全部そろったときだけ「approve してよい」と伝える。

- 「対応が必要」な影響が残っていない
- 必須チェックが全部通っている（skip を除く）
- コンフリクトが無い
- セキュリティ上の懸念が無い

approve してよい場合でも、マージのルールに引っかからないかを添える。例えば `require_last_push_approval` が有効な repo で、コンフリクト解消をユーザーのアカウントで push した場合は、ユーザー自身の approve ではマージできない。

報告の形:

```
<結論: approve してよい / まだ approve しない方がいい（理由を1行で）>

**変わるもの**: <パッケージ> <旧> → <新>（lockfile 上の実際の変化。base に入済みならそう書く）

**影響**
- 対応が必要: <項目と、8 の提案>
- 挙動が変わる: <項目>
- 関係ない: <まとめて1行>

**CI**: <結果。skip や flaky があれば書く>

**デプロイ後に見ること**: <あれば>
```

確かめていないこと（ローカルでビルドしていない、release note が見つからず差分だけで判断した、など）は、確かめたことと分けて書く。

### やらないこと

- approve、merge、PR へのレビューコメントの投稿（ユーザーから頼まれたら行う。6 の bot への rebase 依頼は除く）
- 修正のコミット（コンフリクト解消のマージコミットは除く）
- bot の設定（`renovate.json` など）の変更
