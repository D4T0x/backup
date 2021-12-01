#!/bin/bash

# Author: Enrique Sanz (enrique.sanz.gil@alumnos.upm.es)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Exiting...\n${endColour}"
	exit 1
}

function init(){
	if [ ! -d $HOME/backup ]; then
		mkdir $HOME/backup
	fi
	if [ ! -f $HOME/backup/backup.log ]; then
		touch $HOME/backup/backup.log
	fi
}

function menu(){
	echo -e "\nASO 2021-2022\nSanz Gil Enrique"
	echo -e "\nBackup tool for directories\n"
	echo -e "---------------------------"
	init
	echo -e "\nMenu\n"
	echo -e "\n1) ${greenColour}Perform a backup${endColour}"
	echo -e "\n2) ${greenColour}Perform a backup with cron${endColour}"
	echo -e "\n3) ${greenColour}Restore the content of a backup${endColour}"
	echo -e "\n4) ${redColour}Exit${endColour}"
	echo -e "\n\n"
	read -p 'Option: ' option
	case $option in
		1)
			backup
			;;
		2)
			backupCron
			;;
		3)
			restoreBackup
			;;
		4)
			ctrl_c
			;;
	esac
}

function backupCron(){
	clear
	echo -e "\n${greenColour}Backup Cron${endColour}"
	read -p 'Absolute path of the direcroty: ' absD
	read -p 'Hour for the backup (0:00-23:59) ' hour
	echo -e "\nThe backup will execute at $hour."
	read -p 'Do you agree? (y/n)' y
	if [ $y = y ]; then
		ho=$(echo $hour | cut -d ':' -f1)
		min=$(echo $hour | cut -d ':' -f2)
		if [[ "$ho" =~ ^[0-9]+$ ]] && [ "$ho" -ge 0 ] && [ "$ho" -le 24 ]; then 
			if [[ "$min" =~ ^[0-9]+$ ]] && [ "$min" -ge 0 ] && [ "$min" -le 60 ]; then
				if [ -d $absD ]; then
					(crontab -l; echo "$min $ho * * * $(pwd)/backupCron.sh $absD") | sort -u | crontab -
				else
					echo -e "\n${redColour}[!] Directory for corn not found\n${endColour}"
					log "Error - Directory selected for cron $absD not found"
					ctrl_c
				fi
			else
				echo -e "\n${redColour}[!] Bad time for cron\n${endColour}"
				log "Error - Bad time for cron - $hour - $min"
				ctrl_c
			fi
		else
			echo -e "\n${redColour}[!] Bad time for cron\n${endColour}"
			log "Error - Bad time for cron - $hour - $ho"
			ctrl_c
		fi
	else
		echo -e "\n"
		read -p 'Do you want to close?(y/n)' close
		if [ $close = y ]; then
			ctr_c
		else
			backupCron
		fi
	fi
}


function backup(){
	clear
	echo -e "\n${greenColour}Perform a backup${endColour}"
	read -p 'Path of the directory: ' directory
    if [ $(echo $directory | cut -c 1) != "/" ]; then
        if [ $(echo $directory | cut -c 1) == "." ]; then
			if [ ${#directory} -le 2 ]; then
				directory=$(pwd)
			else	
            			directory=$(echo $(pwd)$(echo $directory | cut -c 2-))
			fi
        else
            directory=$(echo $(pwd)/$directory)
        fi
    fi
	echo -e "\n\nWe will do a backup of the directory $directory"
	read -p 'Do you want to proceed(y/n)? ' proceed
	if [[ $proceed = y ]]; then
		if [ -d $directory ]; then
			echo -e "\nRealizando backup"
			name=$(echo $(basename $directory)-$(date '+%y%m%d-%H%M'))
			echo -e "\n${greemColour}Backup name: $name${endColour}"
			if [ -d "$HOME/backup" ]; then
				echo -e "\n${greenColour}Directory $HOME/backup found, making backup ...${endColour}"
				tar -czf $HOME/backup/$name.tar.gz $directory 2> log
			fi
		else
			log "Error - Directory $directory not found"
		fi
	else
		read -p 'Do you want to proceed with an other directory(y/n)?' proceed
		log "Error - Cancelada la seleccion de directorio, directorio seleccionado: $directory"
		if [ $proceed = y ]; then
			backup
		else
			log "Error - Programa cerrado al cancelar la seleccion de directorio"
			ctrl_c
		fi
	fi
}

function log(){
	echo "$(date '+%F') $(date '+%H:%M') $1" >> $HOME/backup/backup.log
}

function restoreBackup(){
	clear
	echo -e "\nMenu 3\n"
	echo -e "\n${greenColour}The list of existing backups is:\n\n${endColour}$(ls --ignore=backup.log $HOME/backup)"
	echo -e "\n"
	read -p "Which one you want to recover:" recover
	if [ -f $recover ]; then
		tar -xzf $recover
	else
		log "Error - Backup selected to recover not found. Input: $recover"
	fi
}

menu
