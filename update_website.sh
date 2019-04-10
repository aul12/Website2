#!/bin/bash
cd /srv/Website2/
git reset HEAD --hard
git pull origin master
jekyll b
rm -f _site/update_website.sh
cd /var/www/html
cp -r /srv/Website2/_site/* .
echo "Success"
