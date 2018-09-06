For those who work with Django:
Anyone who works with Django knows that it is a pain to manage the creation of projects and applications for it, as well as set up a web server to host it.
Here is a script that automates Django installation and configuration environment as well is a wizard for creating new projects and applications in existing projects, making it easy and replicable.
This script also automates the following tasks:

- install Django 1.11, Nginx 1.14, Gunicorn 19.7 and MySQL Server 5.7 on a fresh Ubuntu Server 18.04
- creates new Django projects
  - allows you to choose what database to use (MySQL Server 5.7 or SQLite3) - creates and configures all DB tables and constraints
  - creates static web content base
  - creates Django admin site
  - configures Gunicorn to serve Python web content
  - configures Nginx to serve as a proxy for Python
- automates the creation of applications within an existing project
  - includes the application in the main project URL
- clear the machine
  - erase all projects
  - clean the DB
  - restore Nginx and Gunicorn to defaults

Note: this script does not do web server and BD hardening yet.

Note: it does not use virtualenv
