#!/bin/bash
# Autor: Marcus Mayorga

# Script para detener servidor 

# Set path variable
PATH="pathvariable"
PathLength=${#PATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$PATH"
else
    echo "No se puede establecer la variable de ruta. ¡Es probable que necesite descargar una versión actualizada de InstaladorMC.sh de GitHub!"
fi


# Comprobar para asegurarse de que no estamos ejecutando como root
if [[ $(id -u) = 0 ]]; then
   echo "Este script no está diseñado para ejecutarse como root.; Saliendo..."
   exit 1
fi


# Comprobar si el servidor se está ejecutando
if ! screen -list | grep -q "\.nombreservidor"; then
  echo "¡El servidor no se está ejecutando actualmente!"
  exit 1
fi


# Obtenga un tiempo de cuenta regresiva personalizado opcional (en minutos)
CountdownTime=0
while getopts ":t:" opt; do
  case $opt in
    t)
      case $OPTARG in
        ''|*[!0-9]*)
          echo "El tiempo de cuenta regresiva debe ser un número entero en minutos."
          exit 1
          ;;
        *)
          CountdownTime=$OPTARG >&2
          ;;
      esac
      ;;
    \?)
      echo "Opción inválida: -$OPTARG; el tiempo de cuenta regresiva debe ser un número entero en minutos." >&2
      ;;
  esac
done


# Detener el servidor
while [[ $CountdownTime -gt 0 ]]; do
  if [[ $CountdownTime -eq 1 ]]; then
    screen -Rd nombreservidor -X stuff "say §c► §eDeteniendo Servidor en 1 minuto...$(printf '\r')"
    echo "Deteniendo el servidor en 1 minuto..."
    sleep 30;
    screen -Rd nombreservidor -X stuff "say §c► §eDeteniendo Servidor en 30 segundos...$(printf '\r')"
    echo "Deteniendo el servidor en 30 segundos..."
    sleep 20;
    screen -Rd nombreservidor -X stuff "say §c► §eDeteniendo Servidor en 10 segundos...$(printf '\r')"
    echo "Deteniendo el servidor en 10 segundos..."
    sleep 10;
    CountdownTime=$((CountdownTime-1))
  else
    screen -Rd nombreservidor -X stuff "say §c► §eDeteniendo Servidor en $CountdownTime minutos...$(printf '\r')"
    echo "Deteniendo el servidor en $CountdownTime minutes...$(printf '\r')"
    sleep 60;
    CountdownTime=$((CountdownTime-1))
  fi
  echo "Esperando $CountdownTime mas minutos..."
done
echo "Deteniendo el servidor de Minecraft..."
screen -Rd nombreservidor -X stuff "say §c► §eDeteniendo Servidor§r (stop.sh called)...$(printf '\r')"
screen -Rd nombreservidor -X stuff "stop$(printf '\r')"


# Espere hasta 20 segundos para que el servidor se cierre
StopChecks=0
while [[ $StopChecks -lt 20 ]]; do
  if ! screen -list | grep -q "\.nombreservidor"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done


# Forzar salida si el servidor aún está abierto
if screen -list | grep -q "\.nombreservidor"; then
  echo "El servidor de Minecraft aún no se ha detenido después de 20 segundos, cerrando la pantalla manualmente"
  screen -S nombreservidor -X quit
fi

echo "El servidor de Minecraft se detuvo."