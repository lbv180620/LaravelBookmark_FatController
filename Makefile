ps:
	docker-compose ps


launch:
	cp src/.env.sample src/.env
	@make up
	@laravel-set


up:
	docker-compose up -d

down:
	docker compose down --remove-orphans


laravel-set:
	docker-compose exec app composer install
	@make keygen
	@make mig
	@make seed

keygen:
	docker-compose exec app php artisan key:generate

mig:
	docker-compose exec app php artisan migrate

seed:
	docker-compose exec app php artisan db:seed

rollback:
	docker-compose exec app php artisan migrate:rollback


# ==== コンテナ操作コマンド群 ====

# app
app:
	docker-compose exec app bash
app-usr:
	docker-compose exec -u $(USER) app bash
stop-app:
	docker-compose stop app



# **** Request & Validation関連 ****

# Laravel 6.x HTTPリクエスト
# https://readouble.com/laravel/6.x/ja/requests.html

# Laravel 6.x バリデーション
# https://readouble.com/laravel/6.x/ja/validation.html
# → フォームリクエストバリデーション
# → 使用可能なバリデーションルール

# Laravel 8.x バリデーション
# https://readouble.com/laravel/8.x/ja/validation.html
# → @errorディレクティブ

# バリデーションまとめ記事
# https://blog.capilano-fw.com/?p=341
# https://qiita.com/kd9951/items/abd063828e33a61c8c58#accepted
# https://reffect.co.jp/laravel/laravel_validation_understanding

# バリデーションエラー表示 - Laravel公式
# https://qiita.com/kcsan/items/c1c84637944ef6ac3d0b

# バリデーションエラー表示 記事
# https://qiita.com/kcsan/items/c1c84637944ef6ac3d0b
# https://qiita.com/gone0021/items/68f0563ac2852ad96b14
# https://zenn.dev/ichii/articles/f4e4f834d26761
# https://zakkuri.life/laravel-display-validation-errors/
# https://blog.capilano-fw.com/?p=8195

# リクエストファイルの作成
# make mkreq-<モデル名>
mkreq-%:
	docker-compose exec app php artisan make:request $(@:mkreq-%=%)Request
mkreq:
	docker-compose exec app php artisan make:request $(model)Request

#^ authorizeメソッドの戻り値をtureにすること忘れずに。

# バリデーションの日本語化
# config/app.php の 'locale' => 'ja', で切り替え
install-ja-lang:
	docker-compose exec app php -r "copy('https://readouble.com/laravel/$(laravel_version).x/ja/install-ja-lang-files.php', 'install-ja-lang.php');"
	docker-compose exec app php -f install-ja-lang.php
	docker-compose exec app php -r "unlink('install-ja-lang.php');"


# ~~~~ 手動方法① ~~~~

# Laravel 8.x auth.php言語ファイル - ReaDouble
# https://readouble.com/laravel/8.x/ja/auth-php.html

# Laravel 8.x validation.php言語ファイル - ReaDouble
# https://readouble.com/laravel/8.x/ja/validation-php.html

# Laravel 8.x pagination.php言語ファイル - ReaDouble
# https://readouble.com/laravel/8.x/ja/pagination-php.html

# Laravel 8.x passwords.php言語ファイル - ReaDouble
# https://readouble.com/laravel/8.x/ja/passwords-php.html

# ⑴ 以下のファイルを作成して、貼り付け。

# resources/lang/ja
# - auth.php
# - pagination.php
# - password.php
# - validation.php


# ⑵ 'attributes' => [], の設定


# ~~~~ 手動方法② ~~~~

# 以下好きな方を選択

# Laravel-Lang/lang
# https://github.com/Laravel-Lang/lang

# laravel-resources-lang-ja
# https://github.com/minoryorg/laravel-resources-lang-ja

# ⑴ zipファイルをダウンロード。

# code → Download ZIP

# ⑵ zipファイルを展開

# ⑶ locales/ja フォルダをコピー

# ⑷ resources/lang/ 以下にペースト

# ⑸ Requstファイルにattributesメソッドを定義


# **** 単体テスト関連 ****

tests:
	docker compose exec app php artisan test

test:
	docker compose exec app php artisan test --testsuite=$(name)
test-%:
	docker compose exec app php artisan test --testsuite=$(@:test-%=%)

test-f:
	docker compose exec app php artisan test --filter $(model)Test

testfu:
	docker compose exec app php artisan test tests/$(type)/$(model)Test.php

testfu-f:
	docker compose exec app php artisan test tests/$(type)/$(model)Test.php --filter=$(method)

testf:
	docker compose exec app php artisan test tests/Feature/$(model)Test.php

testu:
	docker compose exec app php artisan test tests/Unit/$(model)Test.php

testf-f:
	docker compose exec app php artisan test tests/Feature/$(model)Test.php --filter=$(method)

testu-f:
	docker compose exec app php artisan test tests/Unit/$(model)Test.php --filter=$(method)


# ----------------

#& Unitテスト

mktest-u:
	docker compose exec app php artisan make:test $(model)Test --unit
mku:
	@make mktest-u


# ----------------

#& Featureテスト

mktest-m:
	docker compose exec app php artisan make:test $(model)Test
mktest:
	@make mktest-m
mkm:
	@make mktest-m

mktest-c:
	docker compose exec app php artisan make:test $(model)ControllerTest
mkc:
	@make mkfeature

ft-%:
	docker compose exec app vendor/bin/phpunit tests/Feature/$(@:test-feature-%=%)ControllerTest

ft:
	docker compose exec app vendor/bin/phpunit tests/Feature/$(model)ControllerTest


# ==== PHPUnitコマンド群 ====

#**** ローカルでテストを実行する ****

pu-v:
	cd backend && ./vendor/bin/phpunit --version

# --color はphpunit.xmlで設定している。
phpunit:
	cd backend && ./vendor/bin/phpunit $(path)

pu:
	@make phpunit

pu-d:
	cd backend && ./vendor/bin/phpunit $(path) --debug

# --filter - PHPUnit公式
# https://phpunit.readthedocs.io/ja/latest/textui.html?highlight=--filter
pu-f:
	cd backend && ./vendor/bin/phpunit --filter $(rgx)

pu-t:
	cd backend && ./vendor/bin/phpunit --testsuite $(name)

pu-tf:
	cd backend && ./vendor/bin/phpunit --testsuite $(name) --filter $(rgx)

pu-ls:
	cd backend && ./vendor/bin/phpunit --list-suite


#**** Docker環境でテストを実行する ****

#! コンテナからテストを実行すると、コンテナに渡したDB_DATABASEの環境変数が邪魔をして、phpunit.xmlのDB_DATABASEの方を読み込んでくれない。
#! テストを実行する度にDB_DATABASEを変更するのにmake upするのはめんどくさいので、ローカルで実行した方がいい。
#! また.vscode/settings.jsonの設定も必要。

#^ 環境変数の読み込み優先順位
#^ docker-compose.yml > phpunit.xml > .env.testing

#^ 環境変数を一時的に変更する必要がある場合は、「docker run -e」を使用する。

dpu-v:
	docker-compose exec app ./vendor/bin/phpunit --version

dpu:
	docker-compose run -e DB_DATABASE=$(test) app ./vendor/bin/phpunit $(path)

dpu-d:
	docker-compose run -e DB_DATABASE=$(test) app ./vendor/bin/phpunit --debug

dpu-f:
	docker-compose run -e DB_DATABASE=$(test) app ./vendor/bin/phpunit --filter $(regex)

dpu-t:
	docker-compose run -e DB_DATABASE=$(test) app ./vendor/bin/phpunit --testsuite $(name)

dpu-tf:
	docker-compose run -e DB_DATABASE=$(test) app ./vendor/bin/phpunit --testsuite $(name) --filter $(rgx)

dpu-ls:
	docker-compose exec app ./vendor/bin/phpunit --list-suite
