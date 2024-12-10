#!/bin/bash

CGROUP_NAME="test2"
MEMORY_LIMIT="60M"
CPU_MAX="50000" 


sudo cgcreate -a $USER -t $USER -g memory,cpu:$CGROUP_NAME

sudo cgset -r memory.max=$MEMORY_LIMIT $CGROUP_NAME
sudo cgset -r cpu.max=$CPU_MAX $CGROUP_NAME

echo "Ограничения для группы $CGROUP_NAME:"
cgget -r memory.max $CGROUP_NAME
cgget -r cpu.max $CGROUP_NAME

echo "Запуск процесса stress в группе cgroup..."
sudo cgexec -g memory,cpu:$CGROUP_NAME stress --cpu 2 --vm 1 --vm-bytes 3000M --timeout 20s &

sleep 30

sudo cgdelete -r memory,cpu:$CGROUP_NAME
echo "Скрипт завершен. Cgroup удален."