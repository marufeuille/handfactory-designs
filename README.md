# handfactory-designs

3Dプリント用デザインの置き場。ビューア（Space）はこのリポジトリの `designs.json` を読み、登録されたデザインを切り替えて表示する。

## デザインの追加方法

1. `designs/<id>/` フォルダを作り、STL（バイナリ形式）と、あれば .scad ソースを置く
2. `designs.json` の `designs` にエントリを追加する
   - `parts`: 表示切り替えのパーツ一覧（file はフォルダ内の STL 名）
   - `dims`: パーツごとの寸法注記（任意）。`lines` は [始点, 終点, 画面オフセット, ラベル]、`leaders` は [起点, dx, dy, ラベル]、座標はモデル座標（mm）
3. コミットして push すればビューアに反映される

## ビューア

`viewer/index.html` が単体ビューアの実装（外部ライブラリなし、平行投影、パーツ切替・寸法注記対応）。リポジトリルートを静的サーバーで配信すれば（GitHub Pages 等）、`../designs.json` と各 STL を相対パスで読み込んで表示する。Muse の Space 版ビューアも同じ designs.json を正として動作する。
