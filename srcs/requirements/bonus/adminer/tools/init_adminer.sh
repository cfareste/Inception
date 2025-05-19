#! /bin/bash

copy_adminer_file()
{
    if [ -f ./adminer/index.php ]; then return 0; fi;

    cp --no-preserve=ownership /root/adminer.php ./adminer/index.php
}

copy_adminer_file
php-fpm7.4 -F