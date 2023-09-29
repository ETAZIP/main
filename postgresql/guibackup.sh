#!/usr/bin/env bash

backupfolder=/data/backup
dump=$backupfolder/test-$(date +%d-%m-%Y_%H-%M).dump
disk=/dev/sdb1
minspace=80
freespace=`df -Th | grep $disk| awk '{ print $5 }' | cut -c 1,2,3`

# Проверка запуска скрипта под пользователем postgres

if [[ $EUID -ne 26 ]]; then
    echo "Скрипт должен быть запущен под пользователем postgres (Сделайте sudo su postgres)"

    exit 1
fi

# Проверка доступного места

if [ ${freespace} -lt ${minspace} ]; then
    echo "Недостаточно места на диске для бэкапа"
    exit 1
fi

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="(c) Provorov Aleksey Sergeevich INC Version 0.1.5 Last update: 28-06-2023"
TITLE=" Работа с базами данных PostgreSQL PRO"
MENU=" Выберите нужный пункт меню:"

OPTIONS=(1 "Создание резервной копии"
         2 "Создание новой базы данных"
         3 "Восстановление базы данных"
         4 "Сброс действующих подключений"
         5 "Список баз данных" 
         6  "Выход")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo -en "Введите название базы данных: "
            psql -c "\l" | cut -f 1 -d "|"
            read -r database

            if pg_dump -Fc $database > $dump ; then 
               echo $dump
            else 
               echo "Failed to create backup"
            fi

            echo "Нажмите любую кнопку для возврата в меню..."
            read -s -n 1
            /usr/bin/guibackup.sh
            ;;
        2)
            echo "Введите название новой базы данных: "
            read -r newdbname

            if createdb $newdbname ; then
              echo "База данных создана"
            else
              echo "Не удалось создать базу данных"
              exit 1
            fi
            
            echo "Нажмите любую кнопку для возврата в меню..."
            read -s -n 1
            /usr/bin/guibackup.sh
            ;;
        3)
            echo "Введите название базы данных, куда произвести восстановление: "
            psql -c "\l" | cut -f 1 -d "|"
            read -r database

            echo -e "Введи полное название бэкапа из которого необходимо произвести восстановление"
            echo ""
            ls  $backupfile *.dump 
            read -r backupfile

            if pg_restore -d $database $backupfile ; then
              echo "Резервная копия '$backupfile' восстановлена"
              echo ""
            else
              echo "Не удалось восстановить резервную копию"
              exit 1
            fi

            echo "Нажмите любую кнопку для возврата в меню..."
            read -s -n 1
            /usr/bin/guibackup.sh
            ;;
        4)
            echo "Введите имя базы данных, в которой необходимо очистить активные подключения"
            psql -c "\l" | cut -f 1 -d "|"
            read -r db
            psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${db}' AND pid <> pg_backend_pid(); "
            
            echo "Нажмите любую кнопку для возврата в меню..."
            read -s -n 1
            /usr/bin/guibackup.sh
            ;;
        5)
            psql -c "\l+" | awk -F "|" '{print $1 $7}' 
            echo ""
            echo "Нажмите любую кнопку для возврата в меню..."
            read -s -n 1
            /usr/bin/guibackup.sh
            ;;
        6)  
            exit 1    
esac

