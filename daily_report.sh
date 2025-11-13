#!/bin/bash

# === CONFIGURACIÓN ===
TOKEN="1234567890:ABCDEFghijklmnopqRsTuVWxyZ"
CHAT_ID="XXXXXXXX"
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# === FUNCIONES ===

# Obtener temperatura
get_temperature() {
    RAW_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C=$(echo "scale=1; $RAW_TEMP / 1000" | bc)
    echo "$TEMP_C"
}

# Estado de ZeroTier
get_zerotier_status() {
    STATUS=$(sudo zerotier-cli status 2>/dev/null)
    if echo "$STATUS" | grep -q "ONLINE"; then
        echo "✅ ONLINE"
    else
        echo "❌ OFFLINE"
    fi
}

# Estado de conexión a Internet
get_internet_status() {
    ping -c 1 -W 2 google.com > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Conectado"
    else
        echo "❌ Sin conexión"
    fi
}

# Estado de taky
get_taky_status() {
    if pgrep -f "taky" > /dev/null; then
        echo "✅ En ejecución"
    else
        echo "❌ No activo"
    fi
}

# Uso de CPU (%)
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.1f", $1}'
}

# Uso de RAM (%)
get_ram_usage() {
    free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100.0}'
}

# Uso de red (entrada/salida en Mbps)
get_network_usage() {
    RESULT=""
    INTERFACES=("eth0" "wlan0" "wlan1")
    INTERVAL=5

    for IFACE in "${INTERFACES[@]}"; do
        RX_PATH="/sys/class/net/$IFACE/statistics/rx_bytes"
        TX_PATH="/sys/class/net/$IFACE/statistics/tx_bytes"
        STATE_PATH="/sys/class/net/$IFACE/operstate"

        if [[ ! -f $RX_PATH || ! -f $TX_PATH || ! -f $STATE_PATH ]]; then
            RESULT+="📶 $IFACE: ❌ No disponible\n"
            continue
        fi

        IF_STATE=$(cat "$STATE_PATH")
        if [[ "$IF_STATE" != "up" ]]; then
            RESULT+="📶 $IFACE: ⚠️ Inactiva\n"
            continue
        fi

        RX1=$(cat "$RX_PATH")
        TX1=$(cat "$TX_PATH")
        sleep $INTERVAL
        RX2=$(cat "$RX_PATH")
        TX2=$(cat "$TX_PATH")

        RX_DIFF=$((RX2 - RX1))
        TX_DIFF=$((TX2 - TX1))

        RX_MBPS=$(awk "BEGIN {printf \"%.2f\", ($RX_DIFF * 8) / (1000000 * $INTERVAL)}")
        TX_MBPS=$(awk "BEGIN {printf \"%.2f\", ($TX_DIFF * 8) / (1000000 * $INTERVAL)}")

        RESULT+="📶 $IFACE: ⬇️ ${RX_MBPS} Mbps | ⬆️ ${TX_MBPS} Mbps\n"
    done
    echo -e "$RESULT"
}

# === RECOPILAR INFORME ===

TEMP=$(get_temperature)
ZT_STATUS=$(get_zerotier_status)
NET_STATUS=$(get_internet_status)
TAKY_STATUS=$(get_taky_status)
CPU_USAGE=$(get_cpu_usage)
RAM_USAGE=$(get_ram_usage)
NET_USAGE=$(get_network_usage)

MESSAGE="📋 *Daily Report - Raspberry Pi*
🕒 $NOW

🔥 *Temp*: ${TEMP}°C

🌐 *Network*: $NET_STATUS
🔌 *ZeroTier*: $ZT_STATUS
💡 *Taky*: $TAKY_STATUS 
🧠 *CPU*: $CPU_USAGE% 
💾 *RAM*: $RAM_USAGE%
📶 *Net Use* (Mbps):
$NET_USAGE"

# === ENVIAR A TELEGRAM ===
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown"
