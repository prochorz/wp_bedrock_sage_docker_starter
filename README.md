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
docker exec op_wp_1 sh -c 'wp media regenerate --yes --only-missing --allow-root'
php C:\wp-cli.phar media regenerate --yes --only-missing --allow-root
```

if you need backup DB
```
docker-compose up -d db;
docker exec op_db_1 sh -c 'exec /usr/bin/mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > /backup_sql/"$MYSQL_DATABASE".sql';
git add mysql/mysql_dump/bedrock_datami.sql; break;;
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

*** Loop refresh browser sync
Okay super hard to find, but apparently the BrowserSync loop on localhost:3000 was caused by the WPML plugin’s option: Browser language redirect which was set to:

Redirect visitors based on browser language only if translations exist

I disabled it and now BrowserSync works as expected!