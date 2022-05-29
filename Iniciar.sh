#!/bin/bash
# Autor: MarcusGamer

# Script de inicio

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
    echo "Este script no está diseñado para ejecutarse como root.; Saliendo..."
    exit 1
fi


# Comprobar si el servidor ya está iniciado
ScreenWipe=$(screen -wipe 2>&1)
if screen -list | grep -q "\.servername"; then
    echo "¡El servidor ya está iniciado! ejecuta screen -r para abrirlo"
    exit 1
fi

# Cambiar directorio al directorio del servidor
cd dirname/MinecraftBedrock/servername

# Crear carpeta de registros/copias de seguridad/descargas si no existe
if [ ! -d "logs" ]; then
    mkdir logs
fi
if [ ! -d "downloads" ]; then
    mkdir downloads
fi
if [ ! -d "backups" ]; then
    mkdir backups
fi

# Comprobar si las interfaces de red están activas
NetworkChecks=0
if [ -e '/sbin/route' ]; then
    DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
else
    DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
fi
while [ -z "$DefaultRoute" ]; do
    echo "La interfaz de red no está activa, lo intentará de nuevo en 1 segundo"
    sleep 1
    if [ -e '/sbin/route' ]; then
        DefaultRoute=$(/sbin/route -n | awk '$4 == "UG" {print $2}')
    else
        DefaultRoute=$(route -n | awk '$4 == "UG" {print $2}')
    fi
    NetworkChecks=$((NetworkChecks + 1))
    if [ $NetworkChecks -gt 20 ]; then
        echo "Se agotó el tiempo de espera para que aparezca la interfaz de red: se inició el servidor sin conexión de red..."
        break
    fi
done

# Tomar posesión de los archivos del servidor y establecer los permisos correctos
Permissions=$(sudo bash dirname/MinecraftBedrock/servername/permisos.sh -a)

# Crear backup
if [ -d "worlds" ]; then
    echo "Respalando servidor (en la ruta MinecraftBedrock/servername/backups)"
    if [ -n "$(which pigz)" ]; then
        echo "Respalando servidor (multiple cores) a la ruta MinecraftBedrock/servername/backups"
        tar -I pigz -pvcf backups/$(date +%d.%m.%Y.%H.%M.%S).tar.gz worlds
    else
        echo "Respalando servidor (single cored) a la ruta MinecraftBedrock/servername/backups"
        tar -pzvcf backups/$(date +%d.%m.%Y.%H.%M.%S).tar.gz worlds
    fi

# Rotar copias de seguridad - mantener las 5 más recientes
Rotate=$(
    pushd dirname/MinecraftBedrock/servername/backups
    ls -1tr | head -n -5 | xargs -d '\n' rm -f --
    popd
)

echo "Iniciando el servidor de Minecraft. Para ver ejecute screen -r "
echo "Para minimizar la ventana y permitir que el servidor se ejecute en segundo plano, presione Ctrl+A y luego Ctrl+D"

BASH_CMD="LD_LIBRARY_PATH=dirname/MinecraftBedrock/servername dirname/MinecraftBedrock/servername/bedrock_server"
if command -v gawk &>/dev/null; then
    BASH_CMD+=$' | gawk \'{ print strftime(\"[%Y-%m-%d %H:%M:%S]\"), $0 }\''
else
    echo "No se encontró la aplicación gawk; las marcas de tiempo no estarán disponibles en los registros. ¡Elimine InstaladorMC.sh y ejecute el script de la nueva manera recomendada!"
fi
screen -L -Logfile logs/servername.$(date +%Y.%m.%d.%H.%M.%S).log -dmS servername /bin/bash -c "${BASH_CMD}"