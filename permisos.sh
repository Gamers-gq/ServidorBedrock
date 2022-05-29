#!/bin/bash
# Autor: Marcus Mayorga

# Toma posesión de los archivos del servidor para corregir errores de permisos comunes, como el acceso denegado
# Esto es muy común al restaurar copias de seguridad, mover y editar archivos, etc.


# Establecer ruta de la variable
PATH="pathvariable"
PathLength=${#PATH}
if [[ "$PathLength" -gt 12 ]]; then
    PATH="$PATH"
else
    echo "No se puede establecer la variable de ruta. ¡Es probable que necesite descargar una versión actualizada de InstaladorMC.sh de GitHub!"
fi

# Obtener si el comando está automatizado
Automated=0
while getopts ":a:" opt; do
  case $opt in
    t)
      case $OPTARG in
        ''|*[!0-9]*)
          Automated=1
          ;;
        *)
          Automated=1
          ;;
      esac
      ;;
    \?)
      echo "Opción inválida: -$OPTARG; el tiempo de cuenta regresiva debe ser un número entero en minutos." >&2
      ;;
  esac
done

echo "Tomar posesión de todos los archivos/carpetas del servidor en directorio/MinecraftBedrock/nombreservidor..."
if [[ $Automated == 1 ]]; then
    sudo -n chown -R userxname directorio/MinecraftBedrock/nombreservidor
    sudo -n chmod -R 755 directorio/MinecraftBedrock/nombreservidor/*.sh
    sudo -n chmod 755 directorio/MinecraftBedrock/nombreservidor/bedrock_server
    sudo -n chmod +x directorio/MinecraftBedrock/nombreservidor/bedrock_server
else
    sudo chown -Rv userxname directorio/MinecraftBedrock/nombreservidor
    sudo chmod -Rv 755 directorio/MinecraftBedrock/nombreservidor/*.sh
    sudo chmod 755 directorio/MinecraftBedrock/nombreservidor/bedrock_server
    sudo chmod +x directorio/MinecraftBedrock/nombreservidor/bedrock_server

    NewestLog=$(find directorio/MinecraftBedrock/nombreservidor/logs -type f -exec stat -c "%y %n" {} + | sort -r | head -n1 | cut -d " " -f 4-)
    if [ -z "$NewestLog" ]; then
      echo "No se encontraron archivos de registro"
    else
      echo "Visualización de las últimas 10 líneas del archivo de registro $NewestLog en la carpeta /logs:"
      tail -10 "$NewestLog"
    fi
fi

echo "Completo"