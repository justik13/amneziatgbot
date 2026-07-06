#!/bin/bash
set -e

echo "=================================================="
echo "🚀 Начинаем автоматическую установку Amnezia TG Bot..."
echo "=================================================="

if [ "$EUID" -ne 0 ]; then
  echo "❌ Пожалуйста, запустите скрипт из-под root (sudo bash)"
  exit 1
fi

echo "📦 Обновляем систему и ставим зависимости..."
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git screen curl sqlite3

PROJECT_DIR="/root/bot"
if [ ! -d "$PROJECT_DIR" ]; then
  echo "📥 Клонируем репозиторий проекта..."
  git clone https://github.com/justik13/amneziatgbot.git "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

echo "🐍 Настраиваем виртуальное окружение Python..."
if [ ! -d "me" ]; then
  python3 -m venv me
fi

source me/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "⚙️ Переходим к настройке конфигурации..."
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
  else
    touch .env
  fi

  echo "--- Заполнение параметров .env ---"
  
  # Обязательное поле: BOT_TOKEN
  while [ -z "$bot_token" ]; do
    read -p "Введите токен Telegram бота (BOT_TOKEN) [ОБЯЗАТЕЛЬНО]: " bot_token < /dev/tty
  done

  # Поле с дефолтом: ADMIN_IDS
  read -p "Введите ID админа (через запятую) [По умолчанию: 1234567890]: " admin_ids < /dev/tty
  admin_ids=${admin_ids:-"1234567890"}

  # Поле с дефолтом: AMNEZIA_API_URL
  read -p "Введите URL Amnezia API [По умолчанию: http://localhost:4001]: " amnezia_url < /dev/tty
  amnezia_url=${amnezia_url:-"http://localhost:4001"}

  # Обязательное поле: AMNEZIA_API_KEY
  while [ -z "$amnezia_key" ]; do
    read -p "Введите API-ключ Amnezia API (FASTIFY_API_KEY) [ОБЯЗАТЕЛЬНО]: " amnezia_key < /dev/tty
  done

  # Поле с дефолтом: MINIAPP_URL
  read -p "Введите публичный URL Mini App [По умолчанию: http://domain.wtf]: " miniapp_url < /dev/tty
  miniapp_url=${miniapp_url:-"http://domain.wtf"}

  # Запись в .env
  sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${bot_token}|" .env || echo "BOT_TOKEN=${bot_token}" >> .env
  sed -i "s|^ADMIN_IDS=.*|ADMIN_IDS=${admin_ids}|" .env || echo "ADMIN_IDS=${admin_ids}" >> .env
  sed -i "s|^AMNEZIA_API_URL=.*|AMNEZIA_API_URL=${amnezia_url}|" .env || echo "AMNEZIA_API_URL=${amnezia_url}" >> .env
  sed -i "s|^AMNEZIA_API_KEY=.*|AMNEZIA_API_KEY=${amnezia_key}|" .env || echo "AMNEZIA_API_KEY=${amnezia_key}" >> .env
  sed -i "s|^MINIAPP_URL=.*|MINIAPP_URL=${miniapp_url}|" .env || echo "MINIAPP_URL=${miniapp_url}" >> .env

  db_key=$(python3 -c "import cryptography.fernet; print(cryptography.fernet.Fernet.generate_key().decode())")
  sed -i "s|^DB_ENCRYPTION_KEY=.*|DB_ENCRYPTION_KEY=${db_key}|" .env || echo "DB_ENCRYPTION_KEY=${db_key}" >> .env
fi

chmod +x start.sh stop.sh

echo "🔄 Запускаем компоненты бота..."
./stop.sh || true
./start.sh

echo "=================================================="
echo "🎉 Установка успешно завершена!"
echo "Бот, Web API и Mini App запущены в screen."
echo "=================================================="
