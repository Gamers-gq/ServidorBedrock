#!/bin/bash
# Autor: Marcus Mayorga
# Repositorio de GitHub: https://github.com/Gamers-gq/ServidorBedrock
# Instrucciones:https://gamers.gq/

# Instaldor de servidor de dedicado de Minecraft Bedrock
# Para instalar escriba: curl https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/InstaladorMC.sh | bash


echo "Script de instalación de Servidor Minecraft Bedrock por MarcusGamer"
echo "Habilita los puertos 19132 en tu firewall"

# Leer la entrada del usuario con un mensaje
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- aceptar (s/n)?"
    read answer < /dev/tty
    if [[ "$answer" == "${answer#[Ss]}" ]]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

# Eliminar scripts existentes
Update_Scripts() {
  rm -f iniciar.sh detener.sh reiniciar.sh permisos.sh updateservidor.sh

  # Descargar scripts del repositorio
  echo "Descargando iniciar.sh desde el repositorio..."
  curl -H "Accept-Encoding: identity" -L -o iniciar.sh https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/iniciar.sh
  chmod +x iniciar.sh
  sed -i "s:dirname:$DirName:g" iniciar.sh
  sed -i "s:servername:$ServerName:g" iniciar.sh
  sed -i "s:userxname:$UserName:g" iniciar.sh
  sed -i "s<pathvariable<$PATH<g" iniciar.sh

  echo "Descargando detener.sh desde el repositorio..."
  curl -H "Accept-Encoding: identity" -L -o detener.sh https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/detener.sh
  chmod +x detener.sh
  sed -i "s:dirname:$DirName:g" detener.sh
  sed -i "s:servername:$ServerName:g" detener.sh
  sed -i "s:userxname:$UserName:g" detener.sh
  sed -i "s<pathvariable<$PATH<g" detener.sh

  echo "Descargando reiniciar.sh desde el repositorio..."
  curl -H "Accept-Encoding: identity" -L -o reiniciar.sh https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/reiniciar.sh
  chmod +x reiniciar.sh
  sed -i "s:dirname:$DirName:g" reiniciar.sh
  sed -i "s:servername:$ServerName:g" reiniciar.sh
  sed -i "s:userxname:$UserName:g" reiniciar.sh
  sed -i "s<pathvariable<$PATH<g" reiniciar.sh

  echo "Descargando permisos.sh desde el repositorio..."
  curl -H "Accept-Encoding: identity" -L -o permisos.sh https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/permisos.sh
  chmod +x permisos.sh
  sed -i "s:dirname:$DirName:g" permisos.sh
  sed -i "s:servername:$ServerName:g" permisos.sh
  sed -i "s:userxname:$UserName:g" permisos.sh
  sed -i "s<pathvariable<$PATH<g" permisos.sh

  echo "Descargando updateservidor.sh desde el repositorio..."
  curl -H "Accept-Encoding: identity" -L -o updateservidor.sh https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/updateservidor.sh
  chmod +x updateservidor.sh
  sed -i "s:dirname:$DirName:g" updateservidor.sh
  sed -i "s:servername:$ServerName:g" updateservidor.sh
  sed -i "s:userxname:$UserName:g" updateservidor.sh
  sed -i "s<pathvariable<$PATH<g" updateservidor.sh

}


# Actualizar el servicio del servidor de Minecraft
Update_Service() {
  echo "Configurando el servicio $ServerName de Minecraft..."
  sudo curl -H "Accept-Encoding: identity" -L -o /etc/systemd/system/$ServerName.service https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/minecraft.service
  sudo chmod +x /etc/systemd/system/$ServerName.service
  sudo sed -i "s:userxname:$UserName:g" /etc/systemd/system/$ServerName.service
  sudo sed -i "s:dirname:$DirName:g" /etc/systemd/system/$ServerName.service
  sudo sed -i "s:servername:$ServerName:g" /etc/systemd/system/$ServerName.service
  sed -i "/server-port=/c\server-port=$PortIPV4" server.properties
  sed -i "/server-portv6=/c\server-portv6=$PortIPV6" server.properties
  sudo systemctl daemon-reload
  
  echo -n "Inicie el servidor de Minecraft al inicio automáticamente (Ss/n)?"
  read answer < /dev/tty
  if [[ "$answer" != "${answer#[Ss]}" ]]; then
    sudo systemctl enable $ServerName.service


# Configuración de zona horaria America/Guayaquil
echo " Cambiando la zona horaria a Guayaquil..."
timedatectl set-timezone
sudo timedatectl set-timezone America/Guayaquil


# Configuración de reinicio automático a las 6 am
    TimeZone=$(cat /etc/timezone)
    CurrentTime=$(date)
    echo "Su zona horaria actualmente está establecida en $TimeZone. Hora actual del sistema: $CurrentTime"
    echo "Puede cambiar el tiempo de reinicio seleccionado más tarde escribiendo crontab -e"
    echo -n "¿Reiniciar automáticamente y respaldar el servidor a las 6 am todos los días (s/n)?"
    read answer < /dev/tty
    if [[ "$answer" != "${answer#[Ss]}" ]]; then
      croncmd="$DirName/MinecraftBedrock/$ServerName/reiniciar.sh 2>&1"
      cronjob="0 6 * * * $croncmd"
      ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
      echo "Reinicio diario programado. Para cambiar la hora escriba crontab -e"
    fi
  fi
}

Fix_Permissions() {
  echo "Configuración de permisos de archivo del servidor..."
  sudo ./permisos.sh -a > /dev/null
}


# Instalar las dependencias necesarias para ejecutar el servidor de Minecraft en segundo plano
Check_Dependencies() {
  if command -v apt-get &> /dev/null; then
    echo "Actualizando apt..."
    sudo apt-get update

    echo "Comprobación e instalación de dependencias..."
    if ! command -v curl &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install curl -yqq; fi
    if ! command -v unzip &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install unzip -yqq; fi
    if ! command -v screen &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install screen -yqq; fi
    if ! command -v route &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install net-tools -yqq; fi
    if ! command -v gawk &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install gawk -yqq; fi
    if ! command -v openssl &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install openssl -yqq; fi
    if ! command -v xargs &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install xargs -yqq; fi
    if ! command -v pigz &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install pigz -yqq; fi

    CurlVer=$(apt-cache show libcurl4 | grep Version | awk 'NR==1{ print $2 }')
    if [[ "$CurlVer" ]]; then
      sudo DEBIAN_FRONTEND=noninteractive apt-get install libcurl4 -yqq
    else
# Instalar libcurl3 para compatibilidad con versiones anteriores en caso de que libcurl4 no esté disponible
      CurlVer=$(apt-cache show libcurl3 | grep Version | awk 'NR==1{ print $2 }')
      if [[ "$CurlVer" ]]; then sudo DEBIAN_FRONTEND=noninteractive apt-get install libcurl3 -yqq; fi
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install libc6 -yqq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install libcrypt1 -yqq

# Instale libssl 1.1 si está disponible
    SSLVer=$(apt-cache show libssl1.1 | grep Version | awk 'NR==1{ print $2 }')
    if [[ "$SSLVer" ]]; then
      sudo DEBIAN_FRONTEND=noninteractive apt-get install libssl1.1 -yqq
    else
      CPUArch=$(uname -m)
      if [[ "$CPUArch" == *"x86_64"* ]]; then
        echo "No hay libssl1.1 disponible en los repositorios: intento de instalación manual"
        
        sudo curl -o libssl.deb -k -L http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1l-1ubuntu1.3_amd64.deb
        sudo dpkg -i libssl.deb
        sudo rm libssl.deb
        SSLVer=$(apt-cache show libssl1.1 | grep Version | awk 'NR==1{ print $2 }')
        if [[ "$SSLVer" ]]; then
          echo "¡Instalación manual de libssl1.1 exitosa!"
        else
          echo "La instalación manual de libssl1.1 falló."
        fi
      fi
    fi


# Vuelva a verificar curl ya que los problemas de dependencia de libcurl a veces pueden eliminarlo
    if ! command -v curl &> /dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install curl -yqq; fi
    echo "Instalación de dependencia completada"
  else
    echo "Advertencia: no se encontró apto. Es posible que deba instalar curl, screen, unzip, libcurl4, openssl, libc6 y libcrypt1 con su administrador de paquetes para que el servidor se inicie correctamente."
  fi
}


# Recuperar la última versión del servidor de Minecraft Bedrock
Update_Server() {
  echo "Buscando la última versión del servidor Minecraft Bedrock..."
  curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.33 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.33" -o downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
  DownloadURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)
  DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')
  echo "$DownloadURL"
  echo "$DownloadFile"


# Descargue la última versión del servidor dedicado de Minecraft Bedrock
  echo "Descargando la última versión del servidor Minecraft Bedrock..."
  UserName=$(whoami)
  curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.33 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.33" -o "downloads/$DownloadFile" "$DownloadURL"
  unzip -o "downloads/$DownloadFile"
}


# Verifique la arquitectura de la CPU para ver si necesitamos hacer algo especial para la plataforma en la que se ejecuta el servidor
Check_Architecture () {
  echo "Obteniendo la arquitectura de la CPU del sistema..."
  CPUArch=$(uname -m)
  echo "Arquitectura del sistema: $CPUArch"

  # Comprobar la arquitectura ARM
  if [[ "$CPUArch" == *"aarch"* || "$CPUArch" == *"arm"* ]]; then
    # Arquitectura ARM detectada: descargue QEMU y bibliotecas de dependencia
    echo "Plataforma ARM detectada: instalando dependencias..."

    # Compruebe si la última versión de QEMU disponible es al menos 3.0 o superior
    QEMUVer=$(apt-cache show qemu-user-static | grep Version | awk 'NR==1{ print $2 }' | cut -c3-3)
    if [[ "$QEMUVer" -lt "3" ]]; then
      echo "La versión QEMU disponible no es lo suficientemente alta para emular x86_64. Actualice su versión de QEMU."
      exit
    else
      sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install qemu-user-static binfmt-support -yqq
    fi

    if [ -n "`which qemu-x86_64-static`" ]; then
      echo "QEMU-x86_64-static instalado correctamente"
    else
      echo "QEMU-x86_64-static no se instaló correctamente; verifique el resultado anterior para ver qué salió mal."
      exit 1
    fi

# Descargar dependencias.zip del repositorio de GitHub
    curl -H "Accept-Encoding: identity" -L -o depends.zip https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/dependencias.zip
    unzip dependencias.zip
    sudo mkdir /lib64
    # Crear enlace suave ld-linux-x86-64.so.2 asignado a ld-2.31.so
    sudo rm -rf /lib64/ld-linux-x86-64.so.2
    sudo ln -s $DirName/MinecraftBedrock/$ServerName/ld-2.31.so /lib64/ld-linux-x86-64.so.2
  fi

  # Comprobar la arquitectura x86 (32 bits)
  if [[ "$CPUArch" == *"i386"* || "$CPUArch" == *"i686"* ]]; then
    # Los intentos de 32 bits no han tenido éxito: notifique al usuario que instale el sistema operativo de 64 bits
    echo "Está ejecutando un sistema operativo de 32 bits (i386 o i686) y el servidor dedicado Bedrock solo se lanzó para 64 bits (x86_64). Si tiene un procesador de 64 bits, instale un sistema operativo de 64 bits para ejecutar el servidor dedicado de Bedrock."
    exit 1
  fi
}

Update_Sudoers() {
  if [ -d /etc/sudoers.d ]; then
    sudoline="$UserName ALL=(ALL) NOPASSWD: /bin/bash $DirName/MinecraftBedrock/$ServerName/permisos.sh -a, /bin/systemctl start $ServerName, /bin/bash $DirName/MinecraftBedrock/$ServerName/start.sh"
    if [ -e /etc/sudoers.d/MinecraftBedrock ]; then
      AddLine=$(sudo grep -qxF "$sudoline" /etc/sudoers.d/MinecraftBedrock || echo "$sudoline" | sudo tee -a /etc/sudoers.d/MinecraftBedrock)
    else
      AddLine=$(echo "$sudoline" | sudo tee /etc/sudoers.d/MinecraftBedrock)
    fi
  else
    echo "/etc/sudoers.d no se encontró en su sistema. Agregue esta línea a sudoers usando sudo visudo:  $sudoline"
  fi
}
# Fin de funciones

# Comprobar para asegurarse de que no estamos ejecutando como root
if [[ $(id -u) = 0 ]]; then
   echo "Este script no está destinado a ejecutarse como root. Ejecute ./InstaladorMC.sh como usuario no root, sin sudo; el script llamará a sudo cuando sea necesario. Saliendo..."
   exit 1
fi

if [ -e "InstaladorMC.sh" ]; then
  rm -f "InstaladorMC.sh"
  echo "Copia local de InstaladorMC.sh ejecutándose. Saliendo y ejecutando la versión en línea..."
  curl https://raw.githubusercontent.com/Gamers-gq/ServidorBedrock/master/InstaladorMC.sh | bash
  exit 1
fi

Check_Dependencies

# Obtener la ruta del directorio (por defecto ~)
until [ -d "$DirName" ]
do
  echo "Ingrese la ruta de instalación raíz para Minecraft BE (esta es la misma para TODOS los servidores y debe ser ~, la subcarpeta se elegirá del nombre del servidor que proporcione). Casi nadie debería cambiar esto a menos que esté instalando en un disco completamente diferente. (predeterminado ~): "
  read_with_prompt DirName "Directory Path" ~
  DirName=$(eval echo "$DirName")
  if [ ! -d "$DirName" ]; then
    echo "Directorio invalido. Utilice la ruta predeterminada de ~ o tendrá errores. Esto debería ser igual para TODOS los servidores, ya que es su directorio de instalación ROOT."
  fi
done

# Verifique si el directorio principal del servidor de Minecraft ya existe
cd $DirName
if [ ! -d "MinecraftBedrock" ]; then
  mkdir MinecraftBedrock
  cd MinecraftBedrock
else
  cd MinecraftBedrock
  if [ -f "bedrock_server" ]; then
    echo "Migrating old Bedrock server to MinecraftBedrock/old"
    cd $DirName
    mv MinecraftBedrock old
    mkdir MinecraftBedrock
    mv old MinecraftBedrock/old
    cd MinecraftBedrock
    echo "Migration complete to MinecraftBedrock/old"
  fi
fi

# Configuración del nombre del servidor
echo "Ingrese una etiqueta corta de una palabra para un servidor nuevo o existente (no use MinecraftBedrock)"
echo "Se utilizará en el nombre de la carpeta y el nombre del servicio..."

read_with_prompt ServerName "Server Label"

if [[ "$ServerName" == *"MinecraftBedrock"* ]]; then
  echo "No se permite la etiqueta de servidor de MinecraftBedrock. ¡Elija una etiqueta de servidor diferente!"
  exit 1
fi

echo "Ingrese el puerto IPV4 del servidor (por defecto 19132): "
read_with_prompt PortIPV4 "Server IPV4 Port" 19132

echo "Ingrese el puerto IPV6 del servidor (Por defecto 19133): "
read_with_prompt PortIPV6 "Server IPV6 Port" 19133

if [ -d "$ServerName" ]; then
  echo "El directorio MinecraftBedrock/$ServerName ¡ya existe! Actualización de scripts y configuración del servicio..."

# Obtener nombre de usuario
  UserName=$(whoami)
  cd $DirName
  cd MinecraftBedrock
  cd $ServerName
  echo "El directorio del servidor es: $DirName/MinecraftBedrock/$ServerName"

# Actualizar los scripts del servidor de Minecraft
  Update_Scripts

# Configuración del servicio
  Update_Service

# Configuración de Sudoers
  Update_Sudoers

# Arreglar los permisos de archivos/carpetas del servidor
  Fix_Permissions

# Configuración completada
  echo "configuracion completa. Iniciando Servidor de Minecraft $ServerName. para ver la consola use el comando screen -r o verifique la carpeta de registros si el servidor no se inicia"
  sudo systemctl daemon-reload
  sudo systemctl start $ServerName.service

  exit 0
fi

# Crear directorio del servidor
echo "Creando el directorio del servidor de Minecraft ($DirName/MinecraftBedrock/$ServerName)..."
cd $DirName
cd MinecraftBedrock
mkdir $ServerName
cd $ServerName
mkdir downloads
mkdir backups
mkdir logs

Check_Architecture

# Actualizar el binario del servidor de Minecraft
Update_Server

# Actualizar los scripts del servidor de Minecraft
Update_Scripts

# Actualizar los servicios del servidor de Minecraft
Update_Service

# Configuración de Sudoers
Update_Sudoers

# Arreglar los permisos de archivos/carpetas del servidor
Fix_Permissions

# Finalizado!
echo "La configuración está completa. Iniciando el servidor de Minecraft. Para ver la consola, use el comando screen -r o verifique la carpeta de registros si el servidor no se inicia."
sudo systemctl daemon-reload
sudo systemctl start $ServerName.service

# Espere hasta 20 segundos para que se inicie el servidor
StartChecks=0
while [[ $StartChecks -lt 20 ]]; do
  if screen -list | grep -q "\.$ServerName"; then
    break
  fi
  sleep 1;
  StartChecks=$((StartChecks+1))
done

# Forzar salida si el servidor aún está abierto
if ! screen -list | grep -q "\.$ServerName"; then
  echo "El servidor de Minecraft no pudo iniciarse después de 20 segundos."
else
  echo "El servidor de Minecraft ha comenzado. Escribe screen -r $ServerName para ver el servidor en ejecución!"
fi