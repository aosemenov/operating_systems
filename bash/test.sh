#!/bin/bash

# Имя группы cgroup и ограничение на память
CGROUP_NAME="test"
MEMORY_LIMIT="60M"
CPU_MAX="50000" 

# Проверка, что cgroup смонтирован
if ! grep -q cgroup /proc/mounts; then
    echo "Cgroup не смонтирован. Убедитесь, что cgroup включен."
    exit 1
fi

# Создание группы cgroup
sudo cgcreate -a $USER -t $USER -g memory,cpu:$CGROUP_NAME

# Установка ограничений на память и CPU
sudo cgset -r memory.max=$MEMORY_LIMIT $CGROUP_NAME
sudo cgset -r memory.hight=$MEMORY_LIMIT $CGROUP_NAME
sudo cgset -r cpu.max=$CPU_SHARES $CGROUP_NAME

# Проверка значений
echo "Ограничения для группы $CGROUP_NAME:"
cgget -r memory.max $CGROUP_NAME
cgget -r cpu.shares $CGROUP_NAME

# Запуск ресурсоемкого процесса в группе
echo "Запуск процесса stress в группе cgroup..."
cgexec -g memory,cpu:$CGROUP_NAME stress --vm 1 --vm-bytes 128M --vm-keep --timeout 20s &

# Ожидание завершения процесса
wait

# Очистка: удаление группы cgroup
sudo cgdelete -r memory,cpu:$CGROUP_NAME

# Сообщение об успешном завершении
echo "Скрипт завершен. Cgroup удален."