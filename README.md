# Perlを使ってメールを送る

## smtp.pl

SMTPサーバを使ってメールを送ります。

### 実行

	$ carton exec ./smtp.pl

## gmail.pl

GmailのDraftにメールを入れます。

### 準備

1. https://console.developers.google.com/ で プロジェクトを作成
2. Gmail APIを有効にする
3. OAuth 2.0 クライアントIDを作成する。アプリケーションの種類はその他
4. 下矢印を押してJSON形式のキーを var/client_secret.json として保存する。
5. プログラムを実行すると初回はURLが表示されるので、ブラウザで開いて承認し、コードをペースト

### 実行

	$ carton exec ./gmail.pl

