#! /bin/bash

copy_adminer_file()
{
    if [ -d ./adminer ]; then return 0; fi;

    mkdir ./adminer
    cp /root/adminer.php ./adminer/index.php
}

copy_adminer_file
php-fpm7.4 -F