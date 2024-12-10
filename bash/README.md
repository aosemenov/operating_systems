## ОПИСАНИЕ СКРИПТА

bash скрипт для создания cgroup test и ограничения процессов данной группы по памяти и потреблению CPU.
### ДАНО
В скрипте устанавливаются лимиты на memory.max = 60M и cpu.max = 50%
```stress --cpu 2 --vm 1 --vm-bytes 3000M --timeout 20s``` имитирует нагрузку на 2 ядра и создает 1 воркер с потреблением 3000M памяти.

### РЕЗУЛЬТАТ
После запуска скрипта можно заметит: 
1. Процессы вызванные stress используют в сумме 50% CPU одного ядра было использовано
2. 60M оперативной памяти было выделено, остальные 2940 были перемещены в swap-память

Начальное состояние
<img width="714" alt="Снимок экрана 2024-12-10 в 15 37 05" src="https://github.com/user-attachments/assets/5be70c51-d843-4890-9843-b967830b0e7f">
После запуска
<img width="714" alt="Снимок экрана 2024-12-10 в 15 37 05" src="https://github.com/user-attachments/assets/46288fda-a438-4608-b653-9597c1f654e3">

## CHROOT

### Проверить установлен ли chroot и его версия
- ``` chroot --version || util-linux --version ```


### Сделать пространство для chroot a.k.a **chroot jail**
- ``` cd / ```
- ``` mkdir chroot-test ```
- ``` cp -R /bin /lib /lib64 /usr /etc /chroot-test/ ```

### Запуск процесса внутри chroot
- ``` mkdir /chroot-test/ ```
- ``` chroot /chroot-test/ /bin/bash ```

### Удаление папки chroot
- ``` rm -rf /chroot-test/ ```

## CGROUP

### Проверка cgroup
- ``` cat /proc/mounts | grep cgroup ```

### Создание группы
- ``` cgcreate -a $USER -t $USER -g memory:test ```

### Удаление группы
- ``` cgdelete -r memory:test ```

### Изменение параметров
- ``` echo 4000000000 > /sys/fs/cgroup/test/memory.max ```
- ``` echo 4M > /sys/fs/cgroup/test/memory.max ```
- ``` cgset -r memory.max=60M test ```

### Связать уже запущенный процесс с группой
- ``` cgclassify -g memory:test $(pidof firefox) ИЛИ PID процесса ```

### Запустить процесс в группе
- ``` cgexec -g memory:test id ```
- ``` cgexec -g memory:test stress -c 1 --timeout 20s ```

--------------------------
ENABLE cgroup v1 and DISABLE cgroup v2
--------------------------
sudo nano /etc/default/grub

GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=false"

sudo update-grub

Не забудьте перезагрузиться (sudo reboot)


---
DOCUMENTATION: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/cgroup-v2.rst

INFO: https://facebookmicrosites.github.io/cgroup2/docs/create-cgroups.html
