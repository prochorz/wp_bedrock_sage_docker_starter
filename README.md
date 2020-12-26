# Deploy

## Dependency
- composer
- wp-cli
- Node
- npm

how it deploy
```
cd ./bedrock
composer install
```
```
cd ./bedrock/web/app/themes/sage/
composer install
npm i
npm run build:production
```
```
cd ./bedrock/
wp media regenerate --yes --only-missing --allow-root
```

update ENV
```
cd ./bedrock/.env
cp ./.evn.example ./.env
```

## For Developer

### Run the Environment
```
docker-compose up -d
```

It's run site by url `localhost:8080`

### theme development
go to `wp/web/app/themes/sage`
```
npm i
npm run start
```

## DB
Put the *.sql to mysql/mysql_inject for inject new db
and remove the folder mysql/database
and run
```
docker-compose up -d
```

You should use the command for commit DB
```
bash ./pre-commit.hooks
```

if you need crop image run this
```
docker-compose up -d
docker exec sigagroupcomua_wp_1 sh -c 'wp media regenerate --yes --only-missing --allow-root'
php C:\wp-cli.phar media regenerate --yes --only-missing --allow-root
```

Remove all
```
docker system prune  
```

WEBP Expres ukraine.com.ua
Need this file
```
/bedrock/.htaccess
```
