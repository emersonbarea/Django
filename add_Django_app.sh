#!/bin/bash

# definindo o nome da aplicacao
printf '\n%s' 'Qual o nome da APLICAÇÃO que deseja criar? '
read var_app_name

# informe o nome do projeto
printf '\n%s' 'Informe o nome do PROJETO: '
read var_project_name

# informando o caminho do projeto
printf '\n%s%s%s' 'Informe o caminho do PROJETO "' $var_project_name '": '
read var_project_path

# criando a aplicacao
printf '\n%s' 'Criando a aplicação...'
cd $var_project_path/$var_project_name
python3 manage.py startapp $var_app_name

# configurando a views.py exemplo na aplicação
printf '\n%s' 'Configurando a views.py exemplo na aplicação...'
printf '%s\n' 'from django.http import HttpResponse

def index(request):
    return HttpResponse("View teste da aplicação")' >> $var_project_path/$var_project_name/$var_app_name/views.py

# mapeando a views.py exemplo da aplicação na urls.py da aplicação
printf '\n%s' 'Mapeando a views.py exemplo da aplicação na URL da aplicação...'

printf '%s\n' $'from django.conf.urls import url

from . import views

urlpatterns = [
    url(r\'^$\', views.index, name=\'index\'),
]' >> $var_project_path/$var_project_name/$var_app_name/urls.py

# mapeando a URL da aplicação na URL do projeto
printf '\n%s\n' 'Mapeando a urls.py da aplicação na urls.py do projeto...'
sed -i '$ d' $var_project_path/$var_project_name/$var_project_name/urls.py
printf '%s%s%s%s%s\n' $'    url(r\'^' $var_app_name $'/\', include(\'' $var_app_name.urls $'\')),
]' >> $var_project_path/$var_project_name/$var_project_name/urls.py
