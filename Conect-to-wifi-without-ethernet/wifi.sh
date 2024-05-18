#!/bin/bash

# Ruta del archivo de configuración
config_file="/wifi.conf"

# Ruta del archivo de log
log_file="/log.txt"

# Función para registrar en el archivo de log
log() {
    echo "$(date +"%Y-%m-%d %T") - $*" >> "$log_file"
}

# Verifica si el archivo de configuración existe
if [ ! -f "$config_file" ]; then
    log "El archivo de configuración $config_file no existe."
    exit 1
fi

# Lee los datos del archivo de configuración
while IFS='=' read -r key value || [ -n "$key" ]; do
    if [[ $key == "WIFI_NAME" ]]; then
        WIFI_NAME="$value"
    elif [[ $key == "PASSWORD" ]]; then
        PASSWORD="$value"
    elif [[ $key == "PERMANENT_CONNECT" ]]; then
        PERMANENT_CONNECT="$value"
    fi
done < "$config_file"

# Verifica si los campos necesarios están definidos
if [ -z "$WIFI_NAME" ] || [ -z "$PASSWORD" ]; then
    log "Los campos WIFI_NAME y/o PASSWORD no están definidos en $config_file."
    exit 1
fi

# Ejecutar nmcli hasta que se establezca la conexión
connected=false
while [ "$connected" != true ]; do
    log "Intentando conectarse a WiFi: $WIFI_NAME"
    nmcli dev wifi connect "$WIFI_NAME" password "$PASSWORD" >> "$log_file" 2>&1
    if [ $? -eq 0 ]; then
        log "Conexión establecida exitosamente."
        connected=true
    else
        log "Error al conectar. Intentando de nuevo en 5 segundos..."
        sleep 5
    fi
done

# Si PERMANENT_CONNECT es false, elimina los datos de WiFi
if [[ "$PERMANENT_CONNECT" == "false" ]]; then
    unset WIFI_NAME
    unset PASSWORD
    log "Datos de WiFi eliminados."
fi
