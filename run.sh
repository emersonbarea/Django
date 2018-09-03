#!/bin/bash

# This script guides you through the installation of Django 1.11, Nginx 1.14 and MySQL Server 5.7.
# It also assists you in creating new projects or new applications in an existing project.

function welcome() {
    printf '\n%s\n%s' 'This script guides you through the installation of Django 1.11, Nginx 1.14 and MySQL Server 5.7.' \
                      'It also assists you in creating new projects or new applications in an existing project.'
}

function what_to_do() {

    function install_django() {

        function choose_db() {
            printf '\n\n%s\n%s\n%s\n\n%s' \
	           'Choose what database do you want to use in Django projects:' \
                   '    - [1] MySQL Server' '    - [2] SQLite3' 'Note: choose the corresponding number: '
            read var_db
            if [ "$var_db" != "1" ] && [ "$var_db" != "2" ]; then
                printf '\e[1;31m%-6s\e[m' 'error: Choose only options 1 or 2 !!!'
                choose_db
            fi
        }

        function install_MySQL() {
            printf '\n\e[1;33m%-6s\e[m\n' 'Installing MySQL Server 5.7...'
            sudo apt install mysql-server-5.7 -y
            echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
            echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
            DEBIAN_FRONTEND=noninteractive sudo apt install mysql-server-5.7 -y
            print '\n\e[1;33m%-6s\e[m\n' 'Creating MySQL database "django" and user "django"'
            sudo mysql -e "CREATE DATABASE django /*\!40100 DEFAULT CHARACTER SET utf8 */;"
            sudo mysql -e "CREATE USER django@localhost IDENTIFIED BY 'django';"
            sudo mysql -e "GRANT ALL PRIVILEGES ON django.* TO 'django'@'localhost';"
            sudo mysql -e "FLUSH PRIVILEGES;"
	}	

	# installation...
	printf '\n\e[1;33m%-6s\e[m' 'You chose to install Django.'
        choose_db
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing prerequisites...'
	sudo apt update
        sudo apt install language-pack-pt -y
        sudo apt upgrade -y
        sudo apt install git vim htop ethtool python-pip python3-pip snapd snapd-xdg-open -y
	sudo snap install pycharm-community --classic
        printf '\n\e[1;33m%-6s\e[m\n' 'Installing Django 1.11...'
	sudo -H pip install Django==1.11
	printf '\n\e[1;33m%-6s\e[m\n' 'Installing Nginx 1.4...'
	sudo apt install nginx -y
      	if [ "$var_db" = "1" ] ; then
            install_MySQL
	fi

        printf '\n\e[1;33m%-6s\n%s\n%s\e[m' 'Following programs have been installed:' '    - Django 1.11' '    - Nginx 1.14'
        if [ "$var_db" = "1" ] ; then
            printf '\n\e[1;33m%-6s\n\n%s\n\n%s\n%s\n%s\n%s\n%s\e[m\n\n' '    - MySQL Server 5.7' \
		   'MySQL root password = "root"' \
		   'MySQL Django credentials: ' 'username = django' 'password = django' 'database = django' 'hostname = localhost'
	else
            printf '\n\e[1;33m%-6s\e[m\n\n' '    - SQLite3'
        fi
    }

    function create_project() {
        print 'create_project'
    }

    function create_application() {
        print 'create_application'
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

