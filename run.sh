#!/bin/bash

# This script guides you through the installation of Django 1.11, Nginx 1.14 and MySQL Server 5.7.
# It also assists you in creating new projects or new applications in an existing project.

function welcome() {
    printf '\n%s\n%s' 'This script guides you through the installation of Django 1.11, Nginx 1.14 and MySQL Server 5.7.' \
                      'It also assists you in creating new projects or new applications in an existing project.'
}

function what_to_do() {

    function install_django() {

        function install_MySQL() {
            printf '\n\e[1;33m%-6s\e[m\n' 'Installing MySQL Server 5.7...'
            #sudo apt install mysql-server-5.7 python-mysqldb -y
            echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
            echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
            DEBIAN_FRONTEND=noninteractive sudo apt install mysql-server-5.7 -y
            #printf '\n\e[1;33m%-6s\e[m\n' 'Creating MySQL database "django" and user "django"'
            #sudo mysql -e "CREATE DATABASE django /*\!40100 DEFAULT CHARACTER SET utf8 */;"
            #sudo mysql -e "CREATE USER django@localhost IDENTIFIED BY 'django';"
            #sudo mysql -e "GRANT ALL PRIVILEGES ON django.* TO 'django'@'localhost';"
            sudo mysql -e "FLUSH PRIVILEGES;"
	}	

	# installation...
	printf '\n\e[1;33m%-6s\e[m' 'You chose to install Django.'
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing prerequisites...'
	sudo apt update
        sudo apt install language-pack-pt -y
        sudo apt upgrade -y
        sudo apt install git vim htop ethtool python-pip python3-pip snapd snapd-xdg-open -y
	sudo snap install pycharm-community --classic
        printf '\n\e[1;33m%-6s\e[m\n' 'Installing Django 1.11...'
	sudo -H pip install Django==1.11
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing Nginx 1.4 e o Gunicorn3...'
	sudo apt install nginx gunicorn3 -y
        install_MySQL

        printf '\n\e[1;32m%-6s\n\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n\n\e[m' \
	       'The following programs have been installed:' '    - Django 1.11' '    - Nginx 1.14' '    - SQLite3' \
	       '    - MySQL Server 5.7' 'MySQL root password = "root"' 'MySQL Django credentials: ' 'username = django' \
	       'password = django' 'database = django' 'hostname = localhost'
    }

    function create_project() {

        function project_name() {
	    printf '\n\n%s' 'Write new Django project name: '
            read var_project_name
            if [ "$var_project_name" = "" ] ; then
                printf '\e[1;31m%-6s\e[m' 'error: Write new Django project name'
                project_name
            fi
	}

	function project_path() {
            printf '\n%s' 'Inform project path: '
            read var_project_path
            if [ "$var_project_path" = "" ] ; then
                printf '\e[1;31m%-6s\e[m' 'error: Write a valid path'
                project_path
            fi
	    if [ ! -d $var_project_path ]; then
	        printf '\e[1;33m%-6s\e[m' 'Warning: This path does not exist. Do you want to create it? ([y],n) '
		read var_create_path
                if [ "$var_create_path" = "" ] || [ "$var_create_path" = "Y" ] || [ "$var_create_path" = "y" ] ; then
                    mkdir -p $var_project_path
		else
		    project_path
		fi
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
        project_name 
	project_path
	choose_db
        cd $var_project_path
        django-admin startproject $var_project_name	
        
	printf '\n\e[1;33m%-6s\e[m\n' 'Configuring Django...'
        sed -i -- 's/UTC/America\/Sao_Paulo/g' \
	    $var_project_path/$var_project_name/$var_project_name/settings.py
        sed -i -- "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \['localhost'\]/g" \
            $var_project_path/$var_project_name/$var_project_name/settings.py
        sed -i -- "s/STATIC_URL = '\/static\/'/STATIC_ROOT = os.path.join(BASE_DIR, 'static\/')/g" \
            $var_project_path/$var_project_name/$var_project_name/settings.py        
        
	if [ "$var_db" = "1" ] ; then
            printf '\n\e[1;33m%-6s\e[m\n' 'Configuring MySQL...'
	    configure_MySQL
	    sed -i -- 's/django.db.backends.sqlite3/django.db.backends.mysql/g' \
	        $var_project_path/$var_project_name/$var_project_name/settings.py
            sed -i -- "s/os.path.join(BASE_DIR, 'db.sqlite3'),/'$var_project_name',\n        'USER': '$var_project_name', \
                \n        'PASSWORD': '$var_project_name',\n        'HOST': 'localhost', \
		\n        'PORT': '3306',/g" \
		$var_project_path/$var_project_name/$var_project_name/settings.py
	fi
        
	printf '\n\e[1;32m%-6s\n%s%s\n%s%s\n\e[m' \
               'The following project was created:' '    - Project name: ' $var_project_name \
	       '    - Project path: ' $var_project_path/$var_project_name
        if [ "$var_db" = "1" ] ; then
            printf '\e[1;32m%-6s\n%s%s\n%s%s%s%s\n\e[m' '    - Database: MySQL Server 5.7' '    - Database name: ' $var_project_name \
	           '    - Database (user - passwd): ' $var_project_name - $var_project_name	    
        else
	    printf '\e[1;32m%-6s\n%s%s%s\n\e[m' '    - Database: SQLite3' '    - Database path: ' \
		   $var_project_path/$var_project_name '/db.sqlite3'
        fi		
        printf '\n\e[1;32m%-6s%s%s\n\n\e[m' 'Look in the ' $var_project_path/$var_project_name/$var_project_name/settings.py \
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


#Do you want install Django? (This option will also install Nginx and MySQL Server)
# - vai usar o MySQL ou SQLite3?
# - informar que será criado um projeto chamado teste
#       - com uma aplicação chamada teste
# - informar que o cara pode acessar essa aplicação na URL XPTO
# - e onde estão os arquivos....

#Create a new project? (Qual o nome do projeto? Qual caminho?)
# - informar onde estão os arquivos 
# - informar como acessar a URL
# - informar que não aplicação criada neste projeto ainda

#Create new application? (Qual o nome da aplicação? Em qual projeto? Qual caminho?
# - informar onde estão os arquivos
# - informar como acessar URL


# COLOCANDO EM PRODUCAO
#settings.py
#	ALLOWED_HOSTS = ['127.0.0.1'] #somente o proprio servidor Nginx precisa acessar o Python
#	DEBUG = False

