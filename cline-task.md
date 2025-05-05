# 現在の課題
voicevox_engine のバージョンアップを実施すると正常動作しなくなります。
`プリセットファイルのマイグレーションに失敗しました` というエラーが出るので，このあたりに問題がありそうです。

voicevox_engine/voicevox_engine/preset/preset_manager.py に実装があります。

voicevox_engine:cpu のバージョン 0.21.1では動作する。
voicevox/voicevox_engine:cpu-ubuntu20.04-0.21.1

0.22.2 では動作しない。
voicevox/voicevox_engine:cpu-ubuntu20.04-0.22.2

正常起動するように，原因を特定して，koe を改修してください。

オリジナルのファイル(.org という拡張子にした。)と，実際に使っている設定ファイルを用意したので，これも比較してみて。



## docker-composeのログ
``` log
~起動シーケンス（ここまでは正常なので省略）~
May 06 03:42:04 docker-compose docker[1043145]: voicevox-1  |
May 06 03:42:04 docker-compose docker[1043145]: voicevox-1  | 利用規約の詳細は以下をご確認ください。
May 06 03:42:04 docker-compose docker[1043145]: voicevox-1  | https://zonko.zone-energy.jp/guideline
May 06 03:42:04 docker-compose docker[1043145]: voicevox-1  | + exec gosu user /opt/python/bin/python3 ./run.py --voicelib_dir /opt/voicevox_core/ --runtime_dir /opt/onnxruntime/lib --host 0.0.0.0
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:C 05 May 2025 18:42:04.460 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:C 05 May 2025 18:42:04.461 * oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:C 05 May 2025 18:42:04.461 * Redis version=7.2.3, bits=64, commit=00000000, modified=0, pid=1, just started
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:C 05 May 2025 18:42:04.461 * Configuration loaded
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.462 * monotonic clock: POSIX clock_gettime
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * Running mode=standalone, port=6379.
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * Server initialized
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * Loading RDB produced by version 7.2.3
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * RDB age 2 seconds
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * RDB memory usage when created 0.83 Mb
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * Done loading RDB, keys loaded: 8, keys expired: 0.
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * DB loaded from disk: 0.000 seconds
May 06 03:42:04 docker-compose docker[1043145]: redis-1     | 1:M 05 May 2025 18:42:04.465 * Ready to accept connections tcp
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | Warning: cpu_num_threads is set to 0. Setting it to half of the logical cores.
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | /opt/voicevox_engine/voicevox_engine/preset/preset_manager.py:47: UserWarning: プリセットファイルのマイグレーションに失敗しました
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  |   warnings.warn(
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | reading /home/user/.local/share/voicevox-engine-dev/user.dict_csv-90963926-11f6-47f3-8de7-03277010b5f2.tmp ... 79
May 06 03:42:06 docker-compose docker[1043145]: [5.7K blob data]
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | INFO:     Started server process [1]
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | INFO:     Waiting for application startup.
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | INFO:     Application startup complete.
May 06 03:42:06 docker-compose docker[1043145]: voicevox-1  | INFO:     Uvicorn running on http://0.0.0.0:50021 (Press CTRL+C to quit)
May 06 03:42:07 docker-compose docker[1043145]: voicevox-1  | Info: Loading core 0.15.7.
May 06 03:42:07 docker-compose docker[1043145]: voicevox-1  | INFO:     127.0.0.1:56642 - "GET /version HTTP/1.1" 200 OK
May 06 03:42:11 docker-compose docker[1043145]: voicevox-1  | INFO:     172.19.0.4:48694 - "GET /presets HTTP/1.1" 200 OK
```