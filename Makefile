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
