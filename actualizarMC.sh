#!/bin/bash
# Autor: Marcus Mayorga

# Script de actualizacion del servidor Minecraft Bedrock


# Recuperar la última versión del servidor dedicado de Minecraft Bedrock
echo "Buscando la última versión del servidor Minecraft Bedrock..."

# Pruebe la conectividad a Internet primero
curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -s google.com -o /dev/null
if [ "$?" != 0 ]; then
    echo "No se puede conectar al sitio web de actualización (la conexión a Internet puede estar caída). Saltando actualización..."
else

# Descargar server index.html para comprobar la última versión

    curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o downloads/version.html https://www.minecraft.net/en-us/download/server/bedrock
    LatestURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' downloads/version.html)

    LatestFile=$(echo "$LatestURL" | sed 's#.*/##')

    echo "Latest version online is $LatestFile"
    if [ -e version_pin.txt ]; then
        echo "version_pin.txt found with override version, using version specified: $(cat version_pin.txt)"
        PinFile=$(cat version_pin.txt)
    fi

    if [ -e version_installed.txt ]; then
        InstalledFile=$(cat version_installed.txt)
        echo "Current install is: $InstalledFile"
    fi

    if [[ "$PinFile" == *"zip" ]] && [[ "$InstalledFile" == "$PinFile" ]]; then
        echo "Requested version $PinFile is already installed"
    elif [ ! -z "$PinFile" ]; then
        echo "Installing $PinFile"
        DownloadFile=$PinFile
        DownloadURL="https://minecraft.azureedge.net/bin-linux/$PinFile"

# Descargue la versión del servidor dedicado Minecraft Bedrock si aún no es local
        if [ ! -f "downloads/$DownloadFile" ]; then
            curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o "downloads/$DownloadFile" "$DownloadURL"
        fi

# Instale la versión de Minecraft solicitada
        if [ ! -z "$DownloadFile" ]; then
            unzip -o "downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            Permissions=$(chmod u+x dirname/minecraftbe/servername/bedrock_server >/dev/null)
            echo "$DownloadFile" >version_installed.txt
        fi
    elif [[ "$InstalledFile" == "$LatestFile" ]]; then
        echo "Ultima versión $LatestFile ya está instalado"
    else
        echo "Instalando $LatestFile"
        DownloadFile=$LatestFile
        DownloadURL=$LatestURL

# Descargue la versión del servidor dedicado Minecraft Bedrock si aún no es local
        if [ ! -f "downloads/$DownloadFile" ]; then
            curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.$RandNum.212 Safari/537.36" -o "downloads/$DownloadFile" "$DownloadURL"
        fi

# Instale la versión de Minecraft solicitada
        if [ ! -z "$DownloadFile" ]; then
            unzip -o "downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*whitelist.json*" "*valid_known_packs.json*" "*allowlist.json*"
            Permissions=$(chmod u+x dirname/MinecraftBedrock/servername/bedrock_server >/dev/null)
            echo "$DownloadFile" >version_installed.txt
        fi
    fi
fi