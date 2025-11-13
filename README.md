# 🛰️ Server Status Notifier via Telegram (Bash)

This **Bash script** automatically sends your **server status** to a **Telegram chat** using a Telegram bot.  
Perfect for monitoring your VPS or home server easily, without any external tools.

---

## 🚀 Requirements

- Bash (available by default on most Linux systems)
- `curl` installed
- A Telegram account
- A Telegram bot (see below for setup)

---

## 🤖 How to Create Your Telegram Bot

1. **Open Telegram** and search for [@BotFather](https://t.me/BotFather).  
2. Send the following commands:
   ```
   /start
   /newbot
   ```
3. Choose a name and username for your bot (must end with `_bot`).  
4. BotFather will reply with a **TOKEN**, something like:
   ```
   123456789:ABCdefGhIjKlmnOpQRsTUVwxyZ
   ```
   Save this token — you’ll need it for the script.

---

## 🧩 How to Get Your Chat ID

1. Send any message to your new bot.  
2. Then open this link in your browser (replace `TOKEN` with your actual one):
   ```
   https://api.telegram.org/botTOKEN/getUpdates
   ```
3. In the JSON response, look for something like:
   ```json
   "chat": {"id": 987654321, "first_name": "..."}
   ```
   That number (`987654321`) is your **CHAT_ID**.

---

## ⚙️ Script Configuration

Save your script as `server_status.sh` and edit the variables:

```bash
#!/bin/bash

# Bot configuration
TOKEN="YOUR_TOKEN_HERE"
CHAT_ID="YOUR_CHATID_HERE"

# System information
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')

# Message
MESSAGE="📡 *Server Status: $HOSTNAME*
🕒 *Uptime:* $UPTIME
💻 *IP:* $IP
📈 *Load:* $LOAD"

# Send message
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage"      -d "chat_id=${CHAT_ID}"      -d "parse_mode=Markdown"      -d "text=${MESSAGE}"
```

Make it executable:
```bash
chmod +x server_status.sh
```

Test it manually:
```bash
./server_status.sh
```

You should receive a Telegram message with your server status 📩

---

## 🕒 Automate with `crontab`

To automatically run the script at regular intervals (e.g., every 10 minutes):

1. Edit the cron table:
   ```bash
   crontab -e
   ```

2. Add a line like this (adjust the path to your script):

   ```bash
   */10 * * * * /full/path/server_status.sh >> /full/path/server_status.log 2>&1
   ```

   This will run the script every 10 minutes and save logs to a file.

3. Save and check your cron jobs:
   ```bash
   crontab -l
   ```

---

## 🧾 Example Telegram Message

```
📡 Server Status: vps-01
🕒 Uptime: up 3 days, 5 hours
💻 IP: 192.168.1.23
📈 Load: 0.12, 0.20, 0.18
```

---

## 🧠 Tips

- You can extend the message with additional system info like memory or disk usage:
  ```bash
  MEM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
  DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
  ```
- Then append it to the message:
  ```bash
  MESSAGE+="\n💾 *Memory:* $MEM\n🗄️ *Disk:* $DISK"
  ```

---

## 📄 License

This project is licensed under the MIT License.  
If you modify or improve it, feel free to share! 😄
