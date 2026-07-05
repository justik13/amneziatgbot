#!/bin/bash

echo "Останавливаем компоненты Amnezia TG Bot..."

# Перебираем имена сессий, находим их точные PID и закрываем каждую индивидуально
for session in bot webapp miniapp; do
  screen -ls | grep -o -E "[0-9]+\.$session" | xargs -r -I {} screen -X -S {} quit
done

# Вычищаем сокеты мертвых сессий из памяти
screen -wipe > /dev/null 2>&1

echo "Остановлено"
