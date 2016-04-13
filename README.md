# 環境構築手順

```
$ cp .env_sample .env
$ cp node_sample.json node.json
```
.envを編集
SYNC_FROM_FOLDERを必要に応じてプログラムのあるディレクトリに指定

node.jsonを編集
githubのアクセストークンを入れる

```
$ gem install itamae
$ vagrant plugin install dotenv
$ vagrant up
$ itamae ssh --vagrant recipe.rb -l debug -j node.json
```
