#!/bin/bash
#
########################################################
#                   DRUPAL UPDATER v0.1                #
######################### por Edu ######################
#      Automatizador de actualizaciones de Drupal      #
########################################################

##############################
# VARIABLES DE CONFIGURACION #
#----------------------------#
# Editar para configuración  #
##############################
# URLs y directorios de los sitios Drupal a examinar
URLDRU[0]='http://www.miweb.com/contenidos'
DIRDRU[0]='/var/www/contenidos'
URLDRU[1]='http://www.drupalweb.com:888'
DIRDRU[1]='/var/www/drupalweb'
URLDRU[2]='http://www.otrositio.es'
DIRDRU[2]='/home/otrositio/public_html'
# Modo de funcionamiento (si se teclea el comando sin parámetros)
#   P = Informar por Pantalla, pero no actualizar. Equivale a parámetro "pantalla"
#   E = Si hay actualizaciones informar por Email, pero no actualizar. Equivale a parámetro "email"
#   A = Intentar Actualizar y si se hace informar de ello por email. Equivale a parámetro "actualizar"
MODFUN='E'
# Dirección email a la que mandar información de actualizaciones
EMAIL='miemail@micorreo.com'
# Ruta al binario de drush (en blanco lo busca en el PATH)
DRUSHCMD=''
# Directorio temporal
DIRTMP='/tmp'

##############################
# AJUSTE DE CONFIGURACIONES  #
#----------------------------#
#       No modificar         #
##############################
# Si no se ha definido ruta a DRUSH, la tomamos del PATH
if [ -z "$DRUSHCMD" ] ; then DRUSHCMD=`which drush` ; fi
if [ -z "$DRUSHCMD" ] ; then
  echo "Error: drush no encontrado en el PATH. Debes definir la variable DRUSHCMD del script"
  exit 1
fi
# Si el usuario teclea como parámetro "pantalla", "email" o "actualizar", pasamos el programa
# al modo correspondiente independientemente de lo que se determine en el modo de funcionamiento.
if [ "$1" = "pantalla" ] ; then MODFUN='P' ; fi
if [ "$1" = "email" ] ; then MODFUN='E' ; fi
if [ "$1" = "actualizar" ] ; then MODFUN='A' ; fi
# Nombre de este script para aparecer en los logs
APLI=actdru
# Establecemos el nombre del fichero temporal
FICTMP=${DIRTMP}/actdrup.tmp
# Indicamos que  inicialmente, no hay nada que actualizar (lo cambiaremos cuando encontremos algo)
HAYACTUALIZ=N

##############################
#         PROGRAMA           #
#----------------------------#
#       No modificar         #
##############################
# Realizamos un bucle para todas las entradas del array DIRPRU
for ((S = 0 ; S < ${#DIRDRU[@]} ; S++)); do
  # Consultamos en DRUSH la lista de core y módulos pendientes de actualizar (array SALIDADRUSH)
  SALIDADRUSH=( `$DRUSHCMD up -p -r ${DIRDRU[$S]} -l ${URLDRU[$S]} -n | grep -v ^$ 2> /dev/null` )
  # Contamos el número de palabras resultantes
  NUMPALAB=${#SALIDADRUSH[@]}
  # Dado que cada actualizacion presenta 4 datos, calculamos su número dividiendo
  NUMACTUALIZ=`expr $NUMPALAB / 4`
  if [ $NUMACTUALIZ -eq 0 ]
    # Si no hay actualizaciones sacamos un mensaje por pantalla
    then
      FECHA=`date +"%x %X"`
      echo ${FECHA} ${APLI}: ${URLDRU[$S]} no necesita actualizaciones
    else
      HAYACTUALIZ=S
      # Compruebo si hay que actualizar el core de drupal buscando la cadena al principio de la lista de
      # actualizaciones y modifico consecuentemente las variables que indican el numero de módulos
      if [ "${SALIDADRUSH[0]}" == "drupal" ]
        then
          NUMACTDRUPAL=1
          NUMACTMODUL=`expr $NUMACTUALIZ - 1`
        else
          NUMACTDRUPAL=0
          NUMACTMODUL=$NUMACTUALIZ
      fi
      # Si además de haber actualizaciones el programa está en modo mostrar info por pantalla/email...
      #
      if [ ! "$MODFUN" = "A" ]
        then
          FECHA=`date +"%x %X"`
          # Escribo el mensaje resumen de lo que se necesita actualizar
          if [ $NUMACTDRUPAL -eq 1 ]
	    then
	      echo ${FECHA} ${APLI}: ${URLDRU[$S]} necesita actualizar su núcleo y $NUMACTMODUL módulo/s
	    else
	      echo ${FECHA} ${APLI}: ${URLDRU[$S]} necesita actualizar $NUMACTMODUL módulo/s
	  fi
          # Con este bucle voy listando nombres y versiones de todo lo que se necesita actualizar
	  for ((J = 0 ; J < ${NUMACTUALIZ} ; J++)); do
	    INDICEMODULO=`expr $J \* 4`
	    INDICEVVIEJA=`expr $INDICEMODULO + 1`
	    INDICEVNUEVA=`expr $INDICEMODULO + 2`
            echo ${FECHA} ${APLI}:\ \ \ ${SALIDADRUSH[$INDICEMODULO]} está en la versión ${SALIDADRUSH[$INDICEVVIEJA]} y ya existe la ${SALIDADRUSH[$INDICEVNUEVA]}
	  done
      fi
      # Si además de haber actualizaciones el programa está en modo mandar emails...
      #
      if [ "$MODFUN" = "E" ]
        then
          FECHA=`date +"%x %X"`
          # Escribo cabecera e introducción del email si no existe
	  if [ ! -f $FICTMP ] ; then
            echo En su ejecución de ${FECHA}, el script ${APLI} ha detectado estas actualizaciones de sitios Drupal pendientes de realizar: > $FICTMP
            echo >> $FICTMP
          fi
          # Escribo el mensaje resumen de lo que se necesita actualizar
          if [ $NUMACTDRUPAL -eq 1 ]
	    then
	      echo SITIO: ${URLDRU[$S]} Necesita actualizar su núcleo y $NUMACTMODUL módulo/s >> $FICTMP
	    else
	      echo SITIO: ${URLDRU[$S]} Necesita actualizar $NUMACTMODUL módulo/s >> $FICTMP
	  fi
          # Con este bucle voy listando nombres y versiones de todo lo que se necesita actualizar
	  for ((J = 0 ; J < ${NUMACTUALIZ} ; J++)); do
	    INDICEMODULO=`expr $J \* 4`
	    INDICEVVIEJA=`expr $INDICEMODULO + 1`
	    INDICEVNUEVA=`expr $INDICEMODULO + 2`
            echo \ \ - ${SALIDADRUSH[$INDICEMODULO]} está en la versión ${SALIDADRUSH[$INDICEVVIEJA]} y ya existe la ${SALIDADRUSH[$INDICEVNUEVA]} >> $FICTMP
	  done
      fi
      # Si además de haber actualizaciones el programa está en modo mandar actualizar...
      #
      if [ "$MODFUN" = "A" ]
        then
          FECHA=`date +"%x %X"`
          # Escribo cabecera e introducción del email si no existe
	  if [ ! -f $FICTMP ] ; then
            echo Estos son los resultados de la actualización automática de sitios Drupal llevada a cabo por el script ${APLI} en su ejecución de fecha ${FECHA}: > $FICTMP
            echo >> $FICTMP
          fi
          # Escribo el mensaje resumen de lo que se necesita actualizar
          if [ $NUMACTDRUPAL -eq 1 ]
	    then
	      echo ${FECHA} ${APLI}: ${URLDRU[$S]} actualiza su núcleo y $NUMACTMODUL módulo/s
	      echo SITIO: ${URLDRU[$S]} actualiza su núcleo y $NUMACTMODUL módulo/s >> $FICTMP
	    else
	      echo ${FECHA} ${APLI}: ${URLDRU[$S]} actualiza $NUMACTMODUL módulo/s
	      echo SITIO: ${URLDRU[$S]} actualiza $NUMACTMODUL módulo/s >> $FICTMP
	  fi
          # Con este bucle voy listando nombres y versiones de todo lo que se necesita actualizar
	  for ((J = 0 ; J < ${NUMACTUALIZ} ; J++)); do
	    INDICEMODULO=`expr $J \* 4`
	    INDICEVVIEJA=`expr $INDICEMODULO + 1`
	    INDICEVNUEVA=`expr $INDICEMODULO + 2`
            echo \ \ - ${SALIDADRUSH[$INDICEMODULO]} está en la versión ${SALIDADRUSH[$INDICEVVIEJA]} y se actualiza a ${SALIDADRUSH[$INDICEVNUEVA]} >> $FICTMP
	  done
          echo ----------------------------------------------------------------------------------------- >> $FICTMP
	  $DRUSHCMD up -r ${DIRDRU[$S]} -l ${URLDRU[$S]} -y >>$FICTMP 2>>$FICTMP
          echo >>$FICTMP
      fi
  fi
done

# Enviamos un email notificando siempre que haya algo que actualizar
# (no vamos a dar la turra sin mas el pobre administrador)
if [ $HAYACTUALIZ = S ]
  then
    if [ "$MODFUN" = "E" ]
      then
        # Notifico en pantalla que envío la información de actualizaciones detectada por email
    if [ -n "$EMAIL" ]
          then
            echo ${FECHA} ${APLI}: Enviando mensaje a $EMAIL sobre las actualizaciones detectadas
          else
            echo ${FECHA} ${APLI}: Email no especificado, no se pudo enviar información por correo electrónico
            rm $FICTMP
            exit
        fi
        # Despedida de email
        echo >> $FICTMP
        echo Si desea que el script actualice todo este software sólo tiene que acceder a su servidor y teclear el comando \"${APLI}.sh actualizar\" y todo lo notificado se actualizará de forma automática. >> $FICTMP
        # Envío de email y borrado de fichero temporal
        mail -s "${APLI}: Sitios Drupal con actualizaciones pendientes" $EMAIL < $FICTMP
        rm $FICTMP
    fi

    if [ "$MODFUN" = "A" ]
      then
        if [ -n "$EMAIL" ] ; then
          # Notifico en pantalla que envío la información de actualizaciones detectada por email
          echo ${FECHA} ${APLI}: Enviando mensaje a $EMAIL sobre las actualizaciones realizadas
          # Envío de email y borrado de fichero temporal
          mail -s "${APLI}: Sitios Drupal actualizados" $EMAIL < $FICTMP
         rm $FICTMP
        fi
    fi
  else
    FECHA=`date +"%x %X"`
    echo ${FECHA} ${APLI}: No hay nada que actualizar, asi que ni me molesto en enviar email
  fi

