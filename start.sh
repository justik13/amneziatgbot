#!/bin/bash
set -e

cd /root/bot

# Не допускаем несколько polling/Flask-инстансов: это вызывает TelegramConflictError и занятые порты.
for session in bot webapp miniapp; do
  screen -ls | grep -o -E "[0-9]+\.$session" | xargs -r -I {} screen -X -S {} quit
done
screen -wipe > /dev/null 2>&1 || true
sleep 2

screen -L -Logfile bot.log -dmS bot bash -c 'source ./me/bin/activate && python bot.py'
screen -L -Logfile webapp.log -dmS webapp bash -c 'source ./me/bin/activate && python web_service.py'
screen -L -Logfile miniapp.log -dmS miniapp bash -c 'source ./me/bin/activate && python miniapp.py'

echo "Запущено:"
echo "  bot.py     → screen -r bot"
echo "  web_service.py - screen -r webapp"
echo "  miniapp.py → screen -r miniapp"
