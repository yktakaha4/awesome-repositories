# README

## RUN

Rails + MySQL のセットを立ち上げる。
`--build` は Docker Image をビルドするだけなので、初回だけでも OK。

Docker にソースのディレクトリをマウントしているのでローカルのファイルを修正すると Docker 上で動いている側も修正される。

```
$ docker-compose up --build
```

新しくターミナルを開く。

DB を作成する（初回のみ）。

```
$ docker-compose run --rm app rails db:create
```

DB を migrate する（初回のみ）。

```
$ docker-compose run --rm app rails db:migrate
```

Rails + MySQL のセットを終了。

```
$ docker-compose down
```

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...
