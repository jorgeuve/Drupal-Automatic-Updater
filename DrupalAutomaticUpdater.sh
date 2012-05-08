#!/bin/bash
#Shell que vamos a usar. Podemos averiguar el path de nuestro servidor con el comando --> which bash

# directorio donde se encuentra instalado drush, modificalo para acomodarlo al lugar en el que lo hayas instalado
drush=/home/miusuario/drush/drush
echo "Usando drush en la ruta $drush"

# Asignando a una variable la salida del drush sin provocar actualización para saber si hay algo que actualizar
updatedr=`echo "Primer drupal blabla.es" && cd ~/directorio_raiz/deldrupalblabla && $drush up -n && echo " Segundo drupal a actualizar petepete.es" && cd ~/public_html/petepete  && $drush up -n -l petepete.es &&  echo "tercer drupal miweb.es" && cd ~/public_html/miweb  && $drush up -n | mail -s "Actualizacion de core y modulos drupal realizada" micorreo@midominio.es`

#Sólo para saber si todo va bien mostramos que nos ha devuelto este comando, para saber que hay dentro de la variable.
echo 'la variable updatedr es igual a -->' $updatedr

# La palabra NOTE en mayúsculas sólo aparece cuando hay algo que actualizar en drush
# Actualmente lo he cambiado por la detección de la palabra SECURITY
updatoso=`echo $updatedr | grep SECURITY`

#Sólo por seguir el funcionamiento del script mostramos  el valor almacenado. Si no hay nada que actualizar updatoso no tendrá valor
#Ésta es la frase que aparece cuando hay algo que actualizar.
#NOTE: A security update for the Drupal core is available.
#Actualmente lo he cambiado por la detección de la palabra SECURITY

echo 'updatoso igual a -->'  $updatoso

#Si updatoso no tiene valor no actualizamos nada y salimos
#Si updatoso tiene algún valor realizamos actualización automática con drush -y
if [ "$updatoso" = "" ]; then
    echo "hemos llegado al then"
    echo "No hay nada que actualizar y salimos"
	else
    echo "hemos llegado al else"
	echo "existen actualizaciones"
	echo "Primer drupal blabla.es" && cd ~/directorio_raiz/deldrupalblabla && $drush up -y && echo " Segundo drupal a actualizar petepete.es" && cd ~/public_html/petepete  && $drush up -y -l petepete.es &&  echo "tercer drupal miweb.es" && cd ~/public_html/miweb  && $drush up -y | mail -s "Actualización de core y módulos drupal realizada" micorreo@midominio.es

fi
