#!/bin/bash

# This script guides you through the installation of Django 1.11, Nginx 1.14, Gunicorn 19.7 and MySQL Server 5.7.
# It also assists you in creating new projects or new applications in an existing project.

# Directory where run.sh is and where will be created all projects
BUILD_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

function welcome() {
    printf '\n%s\n%s' 'This script guides you through the installation of Django 1.11, Nginx 1.14, Gunicorn 19.7 and MySQL Server 5.7.' \
                      'It also assists you in creating new projects or new applications in an existing project.'
}

function what_to_do() {

    function install_django() {

        function install_MySQL() {
            printf '\n\e[1;33m%-6s\e[m\n' 'Installing MySQL Server 5.7...'
            sudo apt install mysql-server-5.7 python-mysqldb -y
	    echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
            echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
            sudo mysql -e "FLUSH PRIVILEGES;"
	}	

	# installation...
	printf '\n\e[1;33m%-6s\e[m\n' 'You chose to install Django.'
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing prerequisites...'
	sudo apt update
        sudo apt install language-pack-pt -y
        sudo apt upgrade -y
        sudo apt install git vim htop ethtool python-pip python3-pip snapd snapd-xdg-open -y
	sudo snap install pycharm-community --classic
        printf '\n\e[1;33m%-6s\e[m\n' 'Installing Django 1.11...'
	sudo -H pip install Django==1.11
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing Nginx 1.4 e o Gunicorn 19.7...'
	sudo apt install nginx gunicorn -y
        install_MySQL

        printf '\n\e[1;32m%-6s\n\n%s\n%s\n%s\n%s\n%s\n\n%s\n\n\e[m' \
	       'The following programs have been installed:' '    - Django 1.11' '    - Nginx 1.14' '    - Gunicorn 19.7' \
	       '    - SQLite3' '    - MySQL Server 5.7' 'MySQL root password = "root" (sudo mysql -u root -p)'
    }

    function cleaning() {
        printf '\n\n%s' 'Do you want to erase all previous configuration and projects? ([y],n): '
	read var_cleaning
        if [ "$var_cleaning" != "" ] && [ "$var_cleaning" != "Y" ] && [ "$var_cleaning" != "y" ] \
        && [ "$var_cleaning" != "N" ] && [ "$var_cleaning" != "n" ]; then
            printf '\e[1;31m%-6s\e[m' 'error: Press only Y|y or N|n'
            cleaning;
        fi
        if [ "$var_cleaning" = "" ] || [ "$var_cleaning" = "Y" ] || [ "$var_cleaning" = "y" ] ; then
            printf '\e[1;33m%-6s\e[m\n' 'Cleaning MySQL Database...'
	    sudo rm -R /var/lib/mysql/* 2> /dev/null
	    sudo mysqld --initialize --explicit_defaults_for_timestamp	
	    printf '\e[1;33m%-6s\e[m\n' 'Cleaning Nginx Configuration...'
	    sudo find /etc/nginx/sites-available/ -type f ! -name 'default' -delete
	    sudo find /etc/nginx/sites-enabled/ -type f ! -name 'default' -delete
	    sudo systemctl restart nginx
	    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous projects...'
	    sudo rm -rf $BUILD_DIR/projects/*
	    printf '\e[1;33m%-6s\e[m\n' 'Erasing Gunicor startup configuration...'
	    sudo systemctl stop gunicorn 2> /dev/null
	    sudo systemctl disable gunicorn 2> /dev/null
	    sudo rm /etc/systemd/system/gunicorn.service 2> /dev/null
	    sudo systemctl daemon-reload
	else
	    echo "apagou apenas o sites-enabled"
	fi
    }

    function create_project() {

        function project_name() {
	    printf '\n%s' 'Write new Django project name: '
            read var_project_name
            if [ "$var_project_name" = "" ] ; then
                printf '\e[1;31m%-6s\e[m' 'error: Write new Django project name'
                project_name
            fi
	}

        function choose_db() {
            printf '\n%s\n%s\n%s\n\n%s' \
                   'Choose the database type you want to use:' \
                   '    - [1] MySQL Server' '    - [2] SQLite3' 'Note: choose the corresponding number: '
            read var_db
            if [ "$var_db" != "1" ] && [ "$var_db" != "2" ]; then
                printf '\e[1;31m%-6s\e[m' 'error: Choose only options 1 or 2 !!!'
                choose_db
            fi
        }

	function configure_MySQL() {
            printf '\n\e[1;33m%-6s\e[m\n' 'Configuring MySQL Database...'
            sudo mysql -e "CREATE DATABASE $var_project_name /*\!40100 DEFAULT CHARACTER SET utf8 */;"
            sudo mysql -e "CREATE USER $var_project_name@localhost IDENTIFIED BY '$var_project_name';"
            sudo mysql -e "GRANT ALL PRIVILEGES ON $var_project_name.* TO '$var_project_name'@'localhost';"
            sudo mysql -e "FLUSH PRIVILEGES;"
	}

	# configuration...
        printf '\n\e[1;33m%-6s\e[m' 'You chose to create a new Django projects.'
	cleaning
        project_name 
	choose_db
        cd $var_project_path

        printf '\n\e[1;33m%-6s\e[m\n' 'Creating Project...'
        django-admin startproject $var_project_name	
        
	printf '\n\e[1;33m%-6s\e[m\n' 'Configuring Django settings.py...'
        sed -i -- 's/UTC/America\/Sao_Paulo/g' \
	    $BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py
	
	ip_addresses=`hostname --all-ip-addresses || hostname -I`
	ip_addresses_edited=`echo $ip_addresses | sed "s/ /', '/g"`
	sed -i -- "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = [ '$ip_addresses_edited' ]/g" \
             $BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py	

	printf "STATIC_ROOT = os.path.join(BASE_DIR, 'static/')\n" >> \
            $BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py        
        
	if [ "$var_db" = "1" ] ; then
	    sed -i -- 's/django.db.backends.sqlite3/django.db.backends.mysql/g' \
	        $BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py
            sed -i -- "s/os.path.join(BASE_DIR, 'db.sqlite3'),/'$var_project_name',\n        'USER': '$var_project_name', \
                \n        'PASSWORD': '$var_project_name',\n        'HOST': 'localhost', \
		\n        'PORT': '3306',/g" \
		$BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py
            configure_MySQL	    
	fi
       
        printf '\n\e[1;33m%-6s\e[m\n' 'Populating Database...'
	$BUILD_DIR/projects/$var_project_name/manage.py makemigrations
	$BUILD_DIR/projects/$var_project_name/manage.py migrate
	printf "from django.contrib.auth.models import User; \
                User.objects.create_superuser('admin', 'admin@$var_project_name.com', 'admin')" | \
                $BUILD_DIR/projects/$var_project_name/manage.py shell

	printf '\n\e[1;33m%-6s\e[m\n' 'Creating static web files...'	
	$BUILD_DIR/projects/$var_project_name/manage.py collectstatic

	printf '\n\e[1;33m%-6s\e[m\n' 'Configuring Gunicorn...'
	who_service=`whoami`
	printf '%s\n%s\n%s\n\n%s\n%s%s\n%s\n%s%s\n%s%s%s%s%s\n\n%s\n%s\n' \
	       '[Unit]' 'Description=gunicorn daemon' 'After=network.target' '[Service]' \
	       'User=' $who_service 'Group=www-data' 'WorkingDirectory=' $BUILD_DIR/projects/$var_project_name \
	       'ExecStart=/usr/bin/gunicorn --access-logfile - --workers 3 --bind unix:' \
	       $BUILD_DIR/projects/$var_project_name/$var_project_name '.sock ' $var_project_name \
	       '.wsgi:application' '[Install]' 'WantedBy=multi-user.target' | sudo tee /etc/systemd/system/gunicorn.service

        printf '\n\e[1;33m%-6s\e[m\n' 'Configuring Nginx...'
        printf '%s\n%s\n%s%s%s\n\n%s\n%s\n%s%s%s\n%s\n\n%s\n%s\n%s%s%s\n%s\n%s\n' \
               'server {' '    listen 80;' '    server_name ' "$ip_addresses" ';' \
               '    location = /favicon.ico { access_log off; log_not_found off; }' \
               '    location /static/ {' '        root ' $BUILD_DIR/projects/$var_project_name ';' \
               '    }' '    location / {' '        include proxy_params;' \
               '        proxy_pass http://unix:' $BUILD_DIR/projects/$var_project_name/$var_project_name '.sock;' \
               '    }' '}' | sudo tee /etc/nginx/sites-available/$var_project_name	
	sudo ln -s /etc/nginx/sites-available/$var_project_name /etc/nginx/sites-enabled
	sudo nginx -t

        printf '\n\e[1;33m%-6s\e[m\n' 'Restarting all services...'
	sudo systemctl daemon-reload
	sudo systemctl restart gunicorn
	sudo systemctl enable gunicorn
	sudo systemctl restart nginx

	printf '\n\e[1;32m%-6s\n%s%s\n%s%s\n\e[m' \
               'The following project was created:' '    - Project name: ' $var_project_name \
	       '    - Project path: ' $BUILD_DIR/projects/$var_project_name
        if [ "$var_db" = "1" ] ; then
            printf '\e[1;32m%-6s\n%s%s\n%s%s%s%s\n\e[m' '    - Database: MySQL Server 5.7' '    - Database name: ' $var_project_name \
	           '    - Database (user - passwd): ' $var_project_name ' - ' $var_project_name	    
        else
	    printf '\e[1;32m%-6s\n%s%s%s\n\e[m' '    - Database: SQLite3' '    - Database path: ' \
		   $BUILD_DIR/projects/$var_project_name '/db.sqlite3'
        fi		
	printf '\e[1;32m%-6s\n%s%s%s\n\e[m' '    - Project admin credentials (user - passwd): admin - admin ' \
	       '    - URL: http://<ip_address> e http://<ip_address>/admin'
        printf '\n\e[1;32m%-6s%s%s\n\n\e[m' 'Look in the ' $BUILD_DIR/projects/$var_project_name/$var_project_name/settings.py \
	       ' file to see all project configurations'
    }

    function create_application() {
        printf 'create_application'
    }

    # install_django: install Django 1.11, Nginx 1.4 and ask if you want to use SQLite3 ou MySQL.
    #     If you choose MySQL, MySQL 5.7 will be installed.
    # create_project: prompts for the name of the project and the path where it will be created.
    # create_application: prompts for the name of the application, the name of the project it belongs to,
    #     and what path it will be created.
    printf '\n\n%s\n%s\n%s\n%s\n\n%s' \
	   'Choose what do you want to do:' '    - [1] Install Django' '    - [2] Create new Django Project' \
	   '    - [3] Create new Application in an existing Django Project' 'Note: choose the corresponding number: '
    read var_what_to_do

    if [ "$var_what_to_do" = "1" ] ; then
        install_django
    elif [ "$var_what_to_do" = "2" ] ; then
        create_project
    elif [ "$var_what_to_do" = "3" ] ; then
        create_application
    else
        printf '\e[1;31m%-6s\e[m' 'error: Choose only options 1, 2 or 3 !!!'
        what_to_do	
    fi
}

# main

welcome;
what_to_do;


#Create new application? (Qual o nome da aplicação? Em qual projeto? Qual caminho?
# - informar onde estão os arquivos
# - informar como acessar URL


# COLOCANDO EM PRODUCAO
#settings.py
#	ALLOWED_HOSTS = ['127.0.0.1'] #somente o proprio servidor Nginx precisa acessar o Python
#	DEBUG = False

