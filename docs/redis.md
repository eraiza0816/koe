# Redis データ確認マニュアル

Redis データベースの内容を確認する手順を説明します。主に Docker Compose 環境での操作を想定しています。

## 1. Redis サービス名の確認

まず、`deployment/docker-compose.yml` ファイルを開き、Redis を実行しているサービスのコンテナ名またはサービス名を確認します。通常は `redis` という名前が使われています。

```yaml
services:
  # ... other services
  redis: # <-- この名前を確認
    image: redis:7.2.5
    # ...
```

## 2. redis-cli への接続

ターミナルを開き、以下のコマンドを実行して `redis-cli` を起動し、Redis サーバーに接続します。`<redis_service_name>` は手順1で確認した名前に置き換えてください。

```bash
docker compose -f deployment/docker-compose.yml exec <redis_service_name> redis-cli
```

例 (`redis` サービスの場合):
```bash
docker compose -f deployment/docker-compose.yml exec redis redis-cli
```

成功すると、プロンプトが `127.0.0.1:6379>` のように変わります。

## 3. 認証 (パスワードが設定されている場合)

接続後、コマンドを実行しようとして `(error) NOAUTH Authentication required.` というエラーが表示された場合は、Redis にパスワードが設定されています。

パスワードは通常 `deployment/config/redis.conf` ファイル内の `requirepass` ディレクティブで設定されています。

```
# deployment/config/redis.conf の例
requirepass YOUR_STRONG_PASSWORD
```

`redis-cli` 内で以下のコマンドを実行して認証します。`<password>` は設定されているパスワードに置き換えてください。

```redis
AUTH <password>
```

例:
```redis
AUTH YOUR_STRONG_PASSWORD
```

認証に成功すると `OK` と表示されます。

## 4. データ操作コマンド

認証後、以下のコマンドでデータを確認できます。

*   **すべてのキーを表示:**
    ```redis
    KEYS *
    ```
    *注意: キーが多い場合、本番環境での `KEYS *` はパフォーマンスに影響を与える可能性があります。*

*   **キーの型を確認:**
    ```redis
    TYPE <key_name>
    ```
    例: `TYPE guild:{GUILD_ID}:user:{USER_ID}:voice`

*   **特定のキーの値を取得:**
    *   文字列 (String):
        ```redis
        GET <key_name>
        ```
    *   ハッシュ (Hash):
        ```redis
        HGETALL <key_name>
        ```
    *   リスト (List):
        ```redis
        LRANGE <key_name> 0 -1
        ```
    *   セット (Set):
        ```redis
        SMEMBERS <key_name>
        ```
    *   ソート済みセット (Sorted Set):
        ```redis
        ZRANGE <key_name> 0 -1 WITHSCORES
        ```

*   **複数のキーの値をまとめて取得 (String のみ):**
    ```redis
    MGET <key_name1> <key_name2> ...
    ```
    例 (`koe` のユーザー設定取得):
    ```redis
    MGET guild:xxx:user:yyy:voice guild:xxx:user:zzz:voice ...
    ```

*   **キーを削除:**
    ```redis
    DEL <key_name>
    ```
    例: `DEL guild:GUILD_ID:user:{USER_ID}:voice`

## 5. redis-cli の終了

操作が終わったら `exit` と入力して `redis-cli` を終了します。

```redis
exit
