# voicevox_engine 0.22.2 へのバージョンアップに伴う koe 起動不具合の修正レポート

## 1. 問題の概要

`voicevox_engine` の Docker イメージを `voicevox/voicevox_engine:cpu-ubuntu20.04-0.14.6` から `voicevox/voicevox_engine:cpu-ubuntu20.04-0.22.2` へバージョンアップした際に、`koe` アプリケーションが正常に起動しなくなりました。
`docker-compose` のログには以下の警告およびエラーが出力されていました。

*   `voicevox_engine` 側: `プリセットファイルのマイグレーションに失敗しました`
*   `koe` アプリケーション側: `Failed to handle message Caused by: No presets available`

## 2. 調査内容

問題解決のため、以下の調査を行いました。

1.  **プリセットファイルの比較:**
    *   オリジナルのプリセットファイル (`deployment/config/voicevox_presets.yaml.org`) と、実際に使用されているファイル (`deployment/config/voicevox_presets.yaml`) を比較しました。
    *   その結果、使用中のファイルで `id: 21` が「九州そら セクシー」と「ぞん子」で重複していることが判明しました。
2.  **`voicevox_engine` のコード分析 (`preset_manager.py`):**
    *   プリセット管理を行う `voicevox_engine/voicevox_engine/preset/preset_manager.py` を確認しました。
    *   プリセット読み込み時に ID の一意性を検証するロジックが存在することを確認しました。ID 重複がエラーの原因の一つである可能性が高いと判断しました。
3.  **プリセット API の確認:**
    *   ID 重複を修正 (`id: 21` -> `id: 23`) した後も `koe` 側で `No presets available` エラーが発生しました。
    *   `voicevox-1` コンテナ内で `/presets` API (`http://localhost:50021/presets`) に `curl` でリクエストを送信したところ、レスポンスが `[]` (空の配列) であることが判明しました。これは `voicevox_engine` がプリセットを読み込めていないことを示します。
4.  **`voicevox_engine` のコード分析 (`run.py`):**
    *   エントリーポイントである `voicevox_engine/run.py` を確認しました。
    *   プリセットファイルのパス決定ロジックが、コマンドライン引数 (`--preset_file`)、環境変数 (`VV_PRESET_FILE`)、デフォルトパスの順で優先されることを確認しました。
    *   `docker-compose.yml` でマウントしているパス (`/opt/voicevox_engine/presets.yaml`) はデフォルトでは参照されず、`PresetManager` の初期化処理における旧パスからのファイル移動（マイグレーション）が、読み取り専用ボリュームマウントのために失敗し、結果として空のプリセットファイルが生成されていることが根本原因であると特定しました。

## 3. 実施した修正

上記調査に基づき、以下の2点の修正を実施しました。

1.  **プリセット ID の修正:**
    *   `deployment/config/voicevox_presets.yaml` 内で重複していた「ぞん子」のプリセット ID を `21` から `23` に変更しました。
2.  **プリセットファイルパスの明示的な指定:**
    *   `deployment/docker-compose.yml` の `voicevox` サービス定義に `environment` セクションを追加し、環境変数 `VV_PRESET_FILE` を設定して、マウントしたプリセットファイルのパス (`/opt/voicevox_engine/presets.yaml`) を明示的に指定しました。

```diff
--- a/deployment/docker-compose.yml
+++ b/deployment/docker-compose.yml
@@ -27,6 +27,8 @@
     image: voicevox/voicevox_engine:cpu-ubuntu20.04-0.22.2 # バージョンを 0.22.2 に更新
     restart: unless-stopped
     expose:
+      - 50021
+    environment: # 環境変数を追加
+      - VV_PRESET_FILE=/opt/voicevox_engine/presets.yaml # プリセットファイルのパスを指定
     volumes:
       - "./config/voicevox_presets.yaml:/opt/voicevox_engine/presets.yaml:ro"
     healthcheck:

```

## 4. 結果

上記修正を適用し `docker-compose` を再起動した結果、`voicevox_engine` はプリセットファイルを正しく読み込み、`koe` アプリケーションも正常に起動するようになりました。
