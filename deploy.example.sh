#!/bin/bash
SSH_CONNECT=<SSH_URL>
GIT_CONNECT=https://<USER>:<PASSWORD>@bitbucket.org/<USER_NAME>/<PROJECT_NAME>.git
REMOTE_DIR=/home/www
SAGE_FOLDER=./bedrock/web/app/themes/sage
REMOTE_SAGE_FOLDER=/home/www/bedrock/web/app/themes/sage

COMPOSER='/usr/local/php71/bin/php /usr/local/bin/composer'
WP='/usr/local/php71/bin/php /home/www/wp-cli.phar'

eval "ssh $SSH_CONNECT 'cd $REMOTE_DIR && git pull $GIT_CONNECT'"

echo -e "\033[38;5;11m";
echo "--- pull from repo"
echo -e "\033[00m";

# Bedrock composer
read -p "<Do you wish update Bedrock composer?> : y/n " CONDITION;

if [ "$CONDITION" == "y" ]; then
  eval "ssh $SSH_CONNECT 'cd $REMOTE_DIR/bedrock/ && $COMPOSER update --no-scripts'"

  echo -e "\033[38;5;11m";
  echo "--- composer update"
  echo -e "\033[00m";
fi

# Sage composer
read -p "<Do you wish update Sage composer?> : y/n " CONDITION;

if [ "$CONDITION" == "y" ]; then
  eval "ssh $SSH_CONNECT 'cd $REMOTE_SAGE_FOLDER && $COMPOSER update'"

  echo -e "\033[38;5;11m";
  echo "--- composer update"
  echo -e "\033[00m";
fi

# Sage webpack
read -p "<Do you wish update SCSS & JS?> : y/n " CONDITION;

if [ "$CONDITION" == "y" ]; then
  eval "npm i --prefix $SAGE_FOLDER"
  eval "npm run rmdist --prefix $SAGE_FOLDER"
  eval "npm run build:production --prefix $SAGE_FOLDER"

  eval "ssh $SSH_CONNECT 'rm -rf $REMOTE_SAGE_FOLDER/dist && mkdir $REMOTE_SAGE_FOLDER/dist'"

  echo -e "\033[38;5;11m";
  echo "--- remove dist"
  echo -e "\033[00m";

  eval "rsync --archive --verbose --compress --human-readable --progress $SAGE_FOLDER/dist/ $SSH_CONNECT:$REMOTE_SAGE_FOLDER/dist/ --delete --filter 'protect log static'"

  echo -e "\033[38;5;11m";
  echo "done"
  echo -e "\033[00m";
fi

# WP Cli image
read -p "<Do you wish regenerate media?> : y/n " CONDITION;

if [ "$CONDITION" == "y" ]; then
  eval "ssh $SSH_CONNECT 'cd $REMOTE_DIR/bedrock/ && $WP media regenerate --yes --only-missing --allow-root'"

  echo -e "\033[38;5;11m";
  echo "--- images cropped"
  echo -e "\033[00m";
fi

# WP Cli Import DB
read -p "<Do you wish update DB from BackUp?> : y/n " CONDITION;

if [ "$CONDITION" == "y" ]; then
  eval "ssh $SSH_CONNECT 'cd $REMOTE_DIR/bedrock/ && $WP db import $REMOTE_DIR/mysql/mysql_dump/bedrock_sage.sql'"
  echo -e "\033[38;5;11m";
  echo "--- update DB"
  echo -e "\033[00m";
fi

## echo "alias php='/usr/local/php71/bin/php'" >> ~/.bashrc && source ~/.bashrc

## curl -sS https://getcomposer.org/installer | /usr/local/php56/bin/php -- --install-dir=/home/www
## echo "alias composer='php ~/composer.phar'" >> ~/.bashrc && source ~/.bashrc

## curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
## echo "alias wp='php ~/wp-cli.phar'" >> ~/.bashrc && source ~/.bashrc


### wp db import ../mysql/mysql_dump/bedrock_datami.sql
### wp media regenerate --yes --only-missing --allow-root