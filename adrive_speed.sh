#!/bin/bash

# AksTis Drive Speed Test Script

# Универсальный скрипт для запуска тестирования скорости чтения накопителей
# Для тестирования используется hdparm

# Автор: AksTis
# https://akstis.su/

# Версия: 1.0
# Дата: 28 Апреля 2025
# Лицензия: Общественное достояние

readonly RED='\e[91m'
readonly GREEN='\e[38;5;154m'
readonly BLUE='\e[96m'
readonly GREY='\e[90m'
readonly NC='\e[0m'

readonly GREEN_LINE_DASH=" ${GREEN}─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─${NC}"
readonly GREEN_BULLET=" ${GREEN}─${NC}"
readonly GREEN_SEPARATOR="${GREEN}:${NC}"

ok()     { echo -e  "${GREY}[${GREEN}  OK  ${GREY}]${NC} $1"; }
info()   { echo -e  "${GREY}[${GREEN} INFO ${GREY}]${NC} $1"; }
error()  { echo -e    "${GREY}[${RED}FAILED${GREY}]${NC} $1"; exit 1; }

command -v hdparm &>/dev/null || error "hdparm не установлен. Установите: sudo apt install hdparm"

info "Сканирование подключенных накопителей..."
disks=($(lsblk -d -n -o NAME | grep -E '^sd|^nvme')) || error "Накопители не найдены"

ok "Найдены следующие накопители${GREEN_SEPARATOR}"
for i in "${!disks[@]}"; do
    echo -e "         ${GREEN_BULLET} ${BLUE}[ $(($i + 1)) ]${NC} /dev/${disks[$i]}"
done

while true; do
    read -p "Выберите номер накопителя для тестирования (1-${#disks[@]}) или 'q' для выхода: " choice
    [[ "$choice" == "q" ]] && { info "Выход"; exit 0; }
    [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#disks[@]} ] && break
    error "Неверный выбор. Выберите число от 1 до ${#disks[@]} или 'q'"
done

selected_drive="/dev/${disks[$((choice - 1))]}"
info "Тестирование накопителя $selected_drive..."
echo -e "$GREEN_LINE_DASH"

info "Тест скорости чтения с кэшем:"
sudo hdparm -T "$selected_drive"
echo -e "$GREEN_LINE_DASH"

info "Тест скорости чтения без кэша:"
sudo hdparm -t "$selected_drive"
echo -e "$GREEN_LINE_DASH"

ok "Тестирование завершено"