#!/bin/bash

sleep 5

cd /root/bot

screen -L -Logfile bot.log -dmS bot bash -c 'source ./me/bin/activate && python bot.py'
screen -L -Logfile webapp.log -dmS webapp bash -c 'source ./me/bin/activate && python web_service.py'
screen -L -Logfile miniapp.log -dmS miniapp bash -c 'source ./me/bin/activate && python miniapp.py'

echo "Запущено:"
echo "  bot.py     → screen -r bot"
echo "  web_service.py - screen -r webapp"
echo "  miniapp.py → screen -r miniapp"
