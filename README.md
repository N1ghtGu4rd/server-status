# 🛰️ Notificador del estado del servidor vía Telegram (Bash)

Este script en **Bash** envía automáticamente el **estado de tu servidor** a un chat de **Telegram** mediante un bot.  
Ideal para monitorear tu VPS o servidor casero sin necesidad de herramientas externas.

---

## 🚀 Requisitos

- Bash (disponible por defecto en la mayoría de sistemas Linux)
- `curl` instalado
- Una cuenta de Telegram
- Un bot de Telegram configurado (ver más abajo)

---

## 🤖 Cómo crear tu bot de Telegram

1. **Abre Telegram** y busca el usuario [@BotFather](https://t.me/BotFather).  
2. Escribe los siguientes comandos:
   ```
   /start
   /newbot
   ```
3. Elige un nombre y un nombre de usuario (debe terminar en `_bot`).  
4. BotFather te responderá con un **TOKEN** parecido a esto:
   ```
   123456789:ABCdefGhIjKlmnOpQRsTUVwxyZ
   ```
   Guarda este token: lo necesitarás para el script.

---

## 🧩 Cómo obtener tu Chat ID

1. Envía un mensaje cualquiera a tu nuevo bot.  
2. Luego abre este enlace en tu navegador (sustituye `TOKEN` por el tuyo):
   ```
   https://api.telegram.org/botTOKEN/getUpdates
   ```
3. En la respuesta JSON, busca algo como:
   ```json
   "chat": {"id": 987654321, "first_name": "..."}
   ```
   Ese número (`987654321`) es tu **CHAT_ID**.

---

## ⚙️ Configuración del script

Guarda tu script, por ejemplo como `server_status.sh`, y edita las variables:

```bash
#!/bin/bash

# Configuración del bot
TOKEN="TU_TOKEN_AQUI"
CHAT_ID="TU_CHATID_AQUI"

# Información del sistema
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')

# Mensaje
MESSAGE="📡 *Estado del servidor: $HOSTNAME*
🕒 *Uptime:* $UPTIME
💻 *IP:* $IP
📈 *Carga:* $LOAD"

# Envío del mensaje
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage"      -d "chat_id=${CHAT_ID}"      -d "parse_mode=Markdown"      -d "text=${MESSAGE}"
```

Dale permisos de ejecución:
```bash
chmod +x server_status.sh
```

Y prueba ejecutarlo:
```bash
./server_status.sh
```

Deberías recibir el mensaje en tu chat de Telegram 📩

---

## 🕒 Ejecución automática con `crontab`

Para que el script se ejecute automáticamente cada cierto tiempo (por ejemplo, cada 10 minutos):

1. Edita el cron:
   ```bash
   crontab -e
   ```

2. Añade una línea como esta (ajusta la ruta al script):

   ```bash
   */10 * * * * /ruta/completa/server_status.sh >> /ruta/completa/server_status.log 2>&1
   ```

   Esto ejecutará el script cada 10 minutos y guardará un log de salida.

3. Guarda y verifica con:
   ```bash
   crontab -l
   ```

---

## 🧾 Ejemplo de mensaje recibido

```
📡 Estado del servidor: vps-01
🕒 Uptime: up 3 days, 5 hours
💻 IP: 192.168.1.23
📈 Carga: 0.12, 0.20, 0.18
```

---

## 🧠 Consejos

- Puedes personalizar el mensaje añadiendo más información del sistema, como memoria o espacio en disco:
  ```bash
  MEM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
  DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
  ```
- Luego añádelo al mensaje:
  ```bash
  MESSAGE+="\n💾 *Memoria:* $MEM\n🗄️ *Disco:* $DISK"
  ```

---

## 📄 Licencia

Proyecto distribuido bajo la licencia MIT.  
Si lo mejoras o adaptas, ¡no dudes en compartirlo! 😄
