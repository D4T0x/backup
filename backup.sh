#!/bin/bash

# Author: Enrique Sanz (enrique.sanz.gil@alumnos.upm.es)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Exiting...\n${endColour}"
	exit 1
}

function menu(){
	echo -e "\nASO 2021-2022\nSanz Gil Enrique"
	echo -e "\nBackup tool for directories\n"
	echo -e "---------------------------"
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
	
	echo -e "\n${greenColour}Backup Cron${endColour}"
	read -p 'Absolute path of the direcroty: ' absD
	if [ -d "$absD"]; then
		if [ -w $"$absD" ]; then
			echo -e "\n\n"
		else
			echo -e "\n${redColour}You don't have permisions to write in $absD. Returning to menu...${endColour}"
			menu
		fi
	else
		echo -e "\n${redColour}Directory not found returning to menu ...${endColour}"
		menu
	fi
	read -p 'Hour for the backup (0:00-23:59) ' hour
	echo -e "\nThe backup will execute at $hour."
	read -p 'Do you agree? (y/n)' y
	if [ $y = y ]; then
		(crontab -l; echo "$(echo $hour | cut -d ':' -f2) $(echo $hour | cut -d ':' -f1) * * * ./backupCron.sh") | sort -u | crontab -
		# Crear la tarea cron
	else
		echo -e "\n"
		read -p 'Do you want to close?(y/n)' close
		if [ $close = y ]; then
			ctr_c
		else
			menu
		fi
	fi
}


function backup(){
	# Falta directorio relativo
	echo -e "\n${greenColour}Perform a backup${endColour}"
	read -p 'Path of the directory: ' directory
	#funcion para ver si el directorio indicado es correcto
	if [ -d "$directory" ]; then
		if [ -w "$directory" ]; then
			echo -e "\n\nWe will do a backup of the directory $directory"
			read -p 'Do you want to proceed(y/n)? ' proceed
			if [[ $proceed = y ]]; then
				# Realizamos el backup
				echo -e "\nRealizando backup"
				#name=$(echo $(echo $directory | rev | cut -d '/' -f1 | rev)-$(date '+%y%m%d-%H%M'))
				name=$(echo $(basename $directory)-$(date '+%y%m%d-%H%M'))
				echo -e "\n${greemColour}Backup name: $name${endColour}"
				if [ -d "/backups" ]; then
					echo -e "\n${greenColour}Directory $HOME/backup found, making backup ...${endColour}"
				else
					echo -e "\n${redColour}Directory $HOME/backup not found${endColour}"
					mkdir /backups
					echo -e "\n${greenColour}Direcrory $HOME/backup created, making backup...${endColour}"
				fi
				tar -cfz /backups/$name.tar $directory/*
			else
				read -p 'Do you want to proceed with an other directory(y/n)?' proceed
				if [ $proceed = y ]; then
					backup
				else
					ctrl_c
				fi
			fi
		else
			echo -e "\n${redColour}You cant write in this directory${endColour}"
			read -p 'Do you want to proceed with an other directory(y/n)?' p
			if [ $p = y ]; then
				backup
			else
				ctrl_c
			fi
		fi
	else
		echo -e "\n${redColour}Directory not found${endColour}"
			read -p 'Do you want to proceed with an other directory(y/n)?' p
			if [ $p = y ]; then
				backup
			else
				ctrl_c
			fi
	fi
}

function log(){
	echo $1 >> /backups/$(date '+%F')backup.log
}

menu
