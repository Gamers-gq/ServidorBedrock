#!/bin/bash
# Script de reinicio Servidor Minecraft Bedrock por MarcusGamer

# Script de reinicio del servidor Minecraft Bedrock



# Establecer variable de ruta
USERPATH="pathvariable"
PathLength=${#USERPATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$USERPATH"
else
    echo "No se puede establecer la variable de ruta. ¡Es probable que necesite descargar una versión actualizada de InstaladorMC.sh de GitHub!"
fi


# Comprobar para asegurarse de que no estamos ejecutando como root
if [[ $(id -u) = 0 ]]; then
   echo "Este script no está destinado a ejecutarse como root.;  Saliendo..."
   exit 1
fi


# Comprobar si el servidor está iniciado
if ! screen -list | grep -q "\.servername"; then
    echo "¡El servidor no se está ejecutando actualmente!"
    exit 1
fi

echo "Enviando notificaciones de reinicio al servidor..."


# Start countdown notice on server
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 30 segundos!§r $(printf '\r')"
sleep 23s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 7 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 6 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 5 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 4 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 3 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 2 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eEl servidor se reiniciara en 1 segundos! $(printf '\r')"
sleep 1s
screen -Rd servername -X stuff "say §c► §eDeteniendo Servidor...§r $(printf '\r')"
screen -Rd servername -X stuff "stop $(printf '\r')"

echo "Deteniendo Servidor..."


# Espere hasta 30 segundos para que el servidor se cierre
StopChecks=0
while [[ $StopChecks -lt 30 ]]; do
  if ! screen -list | grep -q "\.servername"; then
    break
  fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

if screen -list | grep -q "\.servername"; then


# El servidor aún no se ha detenido después de 30 segundos, dígale a Screen que lo cierre
    echo "Minecraft server still hasn't closed after 30 seconds, closing screen manually"
    screen -S servername -X quit
    sleep 10
fi


#Inicie el servidor con ./iniciar.sh

sudo -n systemctl start servername