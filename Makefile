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
