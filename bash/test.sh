#!/bin/bash

# Имя группы cgroup и ограничение на память
CGROUP_NAME="test2"
MEMORY_LIMIT="60M"
CPU_MAX="50000" 

# Создание группы cgroup
sudo cgcreate -a $USER -t $USER -g memory,cpu:$CGROUP_NAME

# Установка ограничений на память и CPU
sudo cgset -r memory.max=$MEMORY_LIMIT $CGROUP_NAME
sudo cgset -r memory.hight=$MEMORY_LIMIT $CGROUP_NAME
sudo cgset -r cpu.max=$CPU_MAX $CGROUP_NAME

# Проверка значений
echo "Ограничения для группы $CGROUP_NAME:"
cgget -r memory.max $CGROUP_NAME
cgget -r cpu.max $CGROUP_NAME

# Запуск ресурсоемкого процесса в группе
echo "Запуск процесса stress в группе cgroup..."
sudo cgexec -g memory,cpu:$CGROUP_NAME stress --cpu 2 --vm 1 --vm-bytes 128M --timeout 20s &

# Ожидание завершения процесса
sleep 30

# Очистка: удаление группы cgroup
sudo cgdelete -r memory,cpu:$CGROUP_NAME

# Сообщение об успешном завершении
echo "Скрипт завершен. Cgroup удален."