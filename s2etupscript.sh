#! /usr/bin/bash
echo ""
UserName="$(whoami)"
USBname="71D0-8A5F"
spaceLogfile="==================================================================================================================================================="
terminalSPACE="================================================================================"

echo "Linux script"
echo "User: $UserName"
echo ""

# für: installREPO()
Software=('freecad' 'timeshift' 'kicad' 'veracrypt' 'openscad' 'keepassxc' 'firefox' 'haruna' 'pdfarranger' 'xournalpp' 'libreoffice-impress' 'libreoffice-langpack-en' 'libreoffice-writer' 'libreoffice-calc' 'prusa-slicer' 'gnome-tweaks' 'easyeffects' 'gimp' 'audacity' 'obs-studio')
			

USBNAME() {
	echo "is: $USBname your USB-drife [y/N]"
	read yourUSB
	if [[ $yourUSB != "y" ]] then
		echo "Input USB-Name"
		read USBname
	fi
	echo "U are using $USBname as your USB-device"
}
#============================================================================================
#Not used jet
USBFolderStruct(){
	echo "chreating USB Folder Strucktur"
	mkdir /run/media/$UserName/$USBname/Documents
		mkdir /run/media/$UserName/$USBname/Documents/DIY
		mkdir /run/media/$UserName/$USBname/Documents/logseq
		mkdir /run/media/$UserName/$USBname/Documents/FH
			mkdir /run/media/$UserName/$USBname/Documents/FH/S.1
			mkdir /run/media/$UserName/$USBname/Documents/FH/S.2
			mkdir /run/media/$UserName/$USBname/Documents/FH/S.3
		
}

#=================================================================================================================================================
USBsetup(){
	echo "$terminalSPACE"
	echo "USB-setup"
		echo "		- Appimages [executabledesctop entry]"
		echo "		- RPM Packages [Veracrypt]"
		#echo "		- Appimages [executabledesctop entry]"
	echo ""

	USBNAME
	echo ""
	echo "Do you want to install AppImages from USB [y/N]"
	read AppImUSB
	echo ""
	if [[ $AppImUSB == "y" ]] then 
		#USBdesktop=()
		echo "do you already have a folder called Appimages located at /home/AppImages [y/N]"
		read USBAppImFolder
		if [[ $AppImFolder == "N" || "n" ]] then
			cd
			mkdir AppImages
		fi
		
		cd /run/media/$UserName/$USBname/software/AppImages
		
		USBoneMore="y"
		
		while [[ $USBoneMore == "y" ]]; do
			echo ""
			echo "the following AppImages are avilable:"
			echo ""
			ls
			echo ""
			echo "which AppImage to Add? Input the exact name of the listed Images"
			read WhichAppIM
			
			cp /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/*.AppImage /home/$UserName/AppImages
			cp /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/*.png /home/$UserName/AppImages
			
			readarray -t USBdesktop< /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/$WhichAppIM.desktop
			
			firstString="${USBdesktop[3]}"
			secondString=$UserName
			USBdesktop[3]="${firstString/lhl/$secondString}"
			
			firstString="${USBdesktop[4]}"
			USBdesktop[4]="${firstString/lhl/$secondString}"
			
	#		echo "${USBdesktop[3]}"
	#		echo "${USBdesktop[4]}"
			rm /home/$UserName/.local/share/applications/$WhichAppIM.desktop				
			for todos in "${USBdesktop[@]}"; do
				echo "${todos}" >> /home/$UserName/.local/share/applications/$WhichAppIM.desktop
			done
				
			echo "add a nother one [y/N]"
			read USBoneMore
		done
			
		chmod +x /home/$UserName/AppImages/*.AppImage
	fi
		
	echo "Do you want to install RPM-Packages from USB [y/N]"
	read RPMUSB
	echo ""
	if [[ $RPMUSB == "y" ]] then
		cd /run/media/$UserName/$USBname/software/rpm
		#cd /run/media/lhl/71D0-8A5F/software/rpm
		echo "The following RPM's are Arrivable"
		echo ""
		ls 
		echo ""
			
		USBoneMore="y"
		while [[ $USBoneMore == "y" ]]; do
			echo "enter the exact name of the above shown RPM,s"
			read RPMtoInstall
			echo ""
			sudo dnf install /run/media/$UserName/$USBname/software/rpm/$RPMtoInstall
			echo "add a nother one [y/N]"
			read USBoneMore
		done
	fi
		
	echo "end USB-Stetup"
	echo "$terminalSPACE"
}

#=========================================================================================================================
installREPO(){
	echo "$terminalSPACE"
	echo "start Repo App install"
	echo ""
	
	sudo dnf upgrade --refresh
		
	for val in "${Software[@]}"; do
		if dnf list installed $val  &> /dev/null; then 
			echo "$val already installed"
		else
			echo "install $val [y/N]"
			read mio
			if [[ $mio == "y" ]] then
				echo "installing"
				sudo dnf install "$val"
			fi
		fi
	done
		
	echo ""
	echo "end Repo App install"
	echo "$terminalSPACE"
	sudo dnf autoremove

}

#=========================================================================================================================
BATTchGlimit(){
	#https://www.linuxuprising.com/2021/02/how-to-limit-battery-charging-set.html
	echo "$terminalSPACE"
	echo "start Battary chg limit"
	echo ""
		
	echo "check below For BAT0 or similar"
	#ls /sys/class/power_supply
		
	ls /sys/class/power_supply/BAT*/charge_control_end_threshold
		
	echo ""
	echo "coppy the text below and EDIT the /BAT0/ to watever your system calls the battary and past it in the apearing window "
	echo "[Unit]
	Description=Set the battery charge threshold
	After=multi-user.target

	StartLimitBurst=0
	[Service]
	Type=oneshot
	Restart=on-failure

	ExecStart=/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'
	[Install]
	WantedBy=multi-user.target"
	echo"installing gedit"
	sudo dnf install gedit
	sudo touch /etc/systemd/system/battery-charge-threshold.service
	gedit admin:///etc/systemd/system/battery-charge-threshold.service
	
	echo ""
	echo ""
	echo "ready to proced? [y/N]"
	read proced
	if [[ $proced == y ]]	then
	sudo systemctl enable battery-charge-threshold.service
	sudo systemctl start battery-charge-threshold.service
		
	echo ""
	echo "end Battary chg limit"
	echo "$terminalSPACE"
	fi
}
fixportacess(){
#https://support.arduino.cc/hc/en-us/articles/360016495679-Fix-port-access-on-Linux
	echo "$terminalSPACE"
	echo "start Fix Terminal acess"
	echo "https://support.arduino.cc/hc/en-us/articles/360016495679-Fix-port-access-on-Linux"
	echo ""
	sudo usermod -a -G dialout $UserName
	echo "stop Fix terminal Acess"
	echo "$terminalSPACE"
}

#=========================================================================================================================
addAppImage(){
	#https://www.youtube.com/watch?v=bXZma0t0PKE App Image install
	echo "$terminalSPACE"
	echo "start adding AppImag"
	echo ""
	echo "In Preperation for this Download requoired AppImages along with Icons you wanna use for them"
	echo ""
		
	echo "do you already have a folder called Appimages located at /home/Appimages [y/N]"
	read AppImFolder
	if [[ $AppImFolder == "N" || "n" ]] then
		cd
		echo ""
		echo "creating folder Appimages in /home/"
		mkdir AppImages
	fi

	echo ""
	
	echo "Now you have to move All your AppImages along with theyer Icons to: /home/AppIcons"
	oneMore="y"

	while [[ $oneMore == "y" ]]; do

#		echo "you are supposed to Sore all your AppImages along with theyer Icons there"
		echo "now you have to input the Application details i.e meaning you have to give the absolut path to Icon and Exec further mor you have to name the Application and add it to a category"
	
		echo "input ImageApp Name example: Logseq"
		read ImAppName
		echo "input ImageApp absolut path to icon || example: /home/lhl/AppImages/logseq-icon.jpg"
		read ImAppIcon
		echo "input ImageApp absolut path to .ImageApp file example: /home/lhl/AppImages/Logseq-linux-x64-0.10.3.AppImage"
		read ImAppExce
		echo "input ImageApp Category example: Work"
		read ImAppCat
			echo "[Desktop Entry]" 		>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Type=Application" 	>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Name=$ImAppName" 		>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Icon=$ImAppIcon" 		>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Exec=$ImAppExce" 		>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Terminal=false" 		>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Category=$ImAppCat" 	>> /home/$UserName/.local/share/applications/$ImAppName.desktop
			echo "Do you want to add another AppImage to your Desktop [y/N]"
			read oneMore
	done
		
	echo ""
	echo "stop add AppImag"
	echo "$terminalSPACE"
}

#=========================================================================================================================
shellExtensions(){
	echo "$terminalSPACE"
	echo "start gnome shell ext"
	shellEXT=('gnome-browser-connector' 'gnome-extensions-app')
		
	extensions=('https://extensions.gnome.org/extension/1460/vitals/' 'https://extensions.gnome.org/extension/517/caffeine/' 'https://extensions.gnome.org/extension/744/hide-activities-button/' 'https://extensions.gnome.org/extension/3193/blur-my-shell/' 'https://extensions.gnome.org/extension/4839/clipboard-history/' "https://extensions.gnome.org/extension/8/places-status-indicator/")
	echo "wil atomaticliy install all necesary software"
	echo "will open gnome shell extension Website to to recomended extensions"
	echo "close each window after clicing installing"
	for val in "${shellEXT[@]}"; do
		if dnf list installed $val  &> /dev/null; then 
			echo "$val already installed"
		else
			sudo dnf install "$val"
		fi
	done
		
	for val in "${extensions[@]}"; do 
		firefox --new-window $val
	done
		
	echo ""
	echo "stop gnome shell ext"
	echo "$terminalSPACE"
}

printDIR(){
	cd "$1"
	echo "$3"
	if [[ $mapTerminal != "y" ]] then 
		case $2 in
			1)		
			;;		
			2)	echo " |------- $1" >> "$3"
			;;		
			3)	echo " |--------------- $1" >> "$3"
			;;		
			4)	echo " |----------------------- $1" >> "$3"
			;;		
			5)	echo " |------------------------------- $1" >> "$3"
			;;		
			6)	echo " |--------------------------------------- $1" >> "$3"
			;;		
			7)	echo " |----------------------------------------------- $1" >> "$3"
			;;		
			8)	echo " |------------------------------------------------------- $1" >> "$3"
			;;		
			9)	echo " |--------------------------------------------------------------- $1" >> "$3"
			;;		
			10)	echo " |----------------------------------------------------------------------- $1" >> "$3"
			;;		
			11)	echo " |------------------------------------------------------------------------------- $1" >> "$3"
			;;		
			12)	echo " |--------------------------------------------------------------------------------------- $1" >> "$3"
			;;
			13)	echo " |----------------------------------------------------------------------------------------------- $1" >> "$3"
			;;
			*)		
			;;
		esac
 
		for file in * ; do 
			if [ -f "$file" ]; then 
				case $2 in	
					1)	echo " |------- $(wc -c "$file")" >> "$3"
					;;				
					2)	echo " |        |------ $(wc -c "$file")" >> "$3"
					;;				
					3)	echo " |                |------ $(wc -c "$file")" >> "$3"
					;;				
					4)	echo " |                        |------ $(wc -c "$file")" >> "$3"
					;;				
					5)	echo " |                                |------ $(wc -c "$file")" >> "$3"
					;;
					6)	echo " |                                        |------ $(wc -c "$file")" >> "$3"
					;;
					7)	echo " |                                                |------ $(wc -c "$file")" >> "$3"
					;;
					8)	echo " |                                                        |------ $(wc -c "$file")" >> "$3"
					;;
					9)	echo " |                                                                |------ $(wc -c "$file")" >> "$3"
					;;
					10)	echo " |                                                                        |------	$(wc -c "$file")" >> "$3"
					;;
					11)	echo " |                                                                                |------ $(wc -c "$file")" >> "$3"
					;;
					12)	echo " |                                                                                        |------ $(wc -c "$file")" >> "$3"
					;;
					13)	echo " |                                                                                                |------ $(wc -c "$file")" >> "$3"
					;;
					*)
					;;
				esac
			fi
		done
		echo " |"  >> "$3"
	else
#--------------------------------------------------------------------------------------------------------------------------
		case $2 in
			1)		
			;;		
			2)	echo " |----- $1" 
			;;		
			3)	echo " |	|------ $1"
			;;		
			4)	echo " |		|------ $1"
			;;		
			5)	echo " |			|------ $1"
			;;		
			6)	echo " |				|------ $1"
			;;		
			7)	echo " |					|------ $1"
			;;		
			8)	echo " |						|------ $1"
			;;		
			9)	echo " |							|------ $1"
			;;		
			10)	echo " |								|------ $1"
			;;		
			11)	echo " |									|------ $1"
			;;		
			12)	echo " |										|------$1"
			;;
			13)	echo " |											|------ $1"
			;;
			*)
			;;
		esac
				
		for file in * ; do 
			if [ -f "$file" ]; then 
				case $2 in
					1)	
						echo " |------- $(wc -c "$file")"
					;;				
					2)	#echo " |	|"	
						echo " |	|------	$(wc -c "$file")"
					;;				
					3)	#echo " |		|"
						echo " |		|------	$(wc -c "$file")"
					;;				
					4)	#echo " |			|"
						echo " |			|------	$(wc -c "$file")"
					;;				
					5)	#echo " |				|"
						echo " |				|------	$(wc -c "$file")"
					;;
					6)	#echo " |					|"
						echo " |					|------	$(wc -c "$file")"
					;;
					7)	
						echo " |						|------	$(wc -c "$file")"
					;;
					8)	
						echo " |							|------	$(wc -c "$file")"
					;;
					9)	
						echo " |								|------	$(wc -c "$file")"
					;;
					10)	
						echo " |									|------	$(wc -c "$file")"
					;;
					11)	
						echo " |										|------	$(wc -c "$file")"
					;;
					12)	
						echo " |											|------	$(wc -c "$file")"
					;;
					13) 	echo " |												|------	$(wc -c "$file")"
					;;
					*)
					;;
				esac
			fi
		done
		echo " |"
	fi
}



print(){
	for F1 in $myfile*/ ; do
	#    	echo "$F1"
	    	printDIR "$F1" "1"
	    	
		if [ "$(find "$F1" -mindepth 1 -type d)" ]; then 
			for F2 in "$F1"*/ ; do
	#			echo "$F2"
				printDIR "$F2" "3" "$2"
				
				if [ "$(find "$F2" -mindepth 1 -type d)" ]; then
					for F3 in "$F2"*/ ; do
	#					echo "$F3"
						printDIR "$F3" "4" "$2"
						
						if [ "$(find "$F3" -mindepth 1 -type d)" ]; then
							for F4 in "$F3"*/ ; do
	#							echo "$F4"
								printDIR "$F4" "5" "$2"
								
								if [ "$(find "$F4" -mindepth 1 -type d)" ]; then
									for F5 in "$F4"*/ ; do
	#									echo "$F5"
										printDIR "$F5" "6" "$2"
										
										if [ "$(find "$F5" -mindepth 1 -type d)" ]; then
											for F6 in "$F5"*/ ; do
	#											echo "$F6"
												printDIR "$F6" "7" "$2"
												
												if [ "$(find "$F6" -mindepth 1 -type d)" ]; then
													for F7 in "$F6"*/ ; do
														printDIR "$F7" "8" "$2"
														#echo "$F7"
														
														if [ "$(find "$F7" -mindepth 1 -type d)" ]; then
															for F8 in "$F7"*/ ; do
																printDIR "$F8" "9" "$2"
																#echo "$F8"
																
																if [ "$(find "$F8" -mindepth 1 -type d)" ]; then
																	for F9 in "$F8"*/ ; do
																		printDIR "$F9" "10" "$2"
																		#echo "$F9"
																	
																		if [ "$(find "$F9" -mindepth 1 -type d)" ]; then
																			for F10 in "$F9"*/ ; do
																				printDIR "$F10" "11" "$2"
																				#echo "$F10"
																												
																				if [ "$(find "$F10" -mindepth 1 -type d)" ]; then
																					for F11 in "$F10"*/ ; do
																						printDIR "$F11" "12" "$2"
																						#echo "$F11"
																							
																						if [ "$(find "$F11" -mindepth 1 -type d)" ]; then
																							for F12 in "$F11"*/ ; do
																								printDIR "$F12" "13" "$2"
																								#echo "$F12"
																							done
																						fi
																					done
																				fi
																			done
																		fi
																	done
																fi
															done
														fi	
													done
												fi
											done
										fi	
									done
								fi	
							done
						fi
					done
				fi
			done
		fi
	done
}
#--------------------------------------------------------------------------------------------------------------------------

printdire(){
	echo "give path to dir to map ex: /home/lhl/Documents"
	read myfile

	echo "schow dir map in terminal [y/N]"
	read mapTerminal
	if [[ $mapTerminal != "y" ]] then
		echo "give path to store map: ex: /home/lhl/Documents/map.txt   (file will automaticly be createt if not already exists)"
		read mapfile
	fi
	print "$myfile" "$mapfile" 
}
#--------------------------------------------------------------------------------------------------------------------------


backup(){
	USBNAME
	echo "Options"
	echo "		- sys (backups entire Documentsfolder) to veracrypt harddrive"
	echo "		- dir (backups several 'dir' of chois to location of choice)"
	echo "		- usb-a (backups logsecq; DIY; FH to USB)"
	echo "		- usb-l (backups logseq folder to USB)"
	echo "		- usb-diy (backups DIY to USB)"
	echo "		- usb-fh (backups DIY to USB)"
	read whichbackup
	mapTerminal="no"
	mapfile="/run/media/$UserName/$USBname/Documents/backupLog.txt"
	
	case $whichbackup in
		sys)
			echo "		make sure Ure Harddrive is already pluged in"
			echo "	mount the drive on 7"
			veracrypt
			
			mkdir /media/veracrypt7/backup_$(date +"%d.%m.%y")
			myfile="/media/veracrypt7/backup_$(date +"%d.%m.%y")"
			mapfile="/media/veracrypt7/backupLog.txt"
			cp -v -R /home/$UserName/Documents/ /media/veracrypt7/backup_$(date +"%d.%m.%y")/
				
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo "backup_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
				print "$myfile" "$mapfile"
		;;
	
		dir)
			echo "enter dir to backup ex: /home/$UserName/Documents"
			read myfile
			echo ""
			echo "enter path to backup to ex: /run/media/$UserName/$USBname/Documents {automaticly creats last folder if not already exists}"
			read backupto
			echo ""
			echo "give path to LOG file ex: /run/media/$UserName/$USBname/Documents/backupLog.txt "
			read mapfile
			mkdir "$backupto"
			cp -v -R $myfile/* $backupto/
				
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo ""$myfile"_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
				print "$myfile" "$mapfile"
		;;
		
		usb-a)
			mapfile="/run/media/$UserName/$USBname/Documents/backupLog.txt"
			
			echo "FH backup of: S.1; S.2; S.3; DIY of choice; logseq to USB: $USBname"
			#Folders to backup
			#FolderBackup=("/home/lhl/Documents/FH/S.1" "/home/lhl/Documents/FH/S.2" "/home/lhl/Documents/FH/S.3" "/home/lhl/Documents/logseq" "/home/lhl/Documents/DIY/a_howto's" )		
			echo "which Semester to backup: S.1 S.2 S.3"
			read SeBak
			
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo ""$SeBak"_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
			
			echo ""
			if [[ $SeBak == "S.1"  ]] then
				cp -v -R /home/$UserName/Documents/FH/S.1/* /run/media/$UserName/$USBname/Documents/FH/S.1/
				
				myfile="/home/$UserName/Documents/FH/S.1"
				
					print "$myfile" "$mapfile"
			elif [[ $SeBak == "S.2" ]] then
				cp -v -R /home/$UserName/Documents/FH/S.2/* /run/media/$UserName/$USBname/Documents/FH/S.2/
				
				myfile="/home/$UserName/Documents/FH/S.2"
					print "$myfile" "$mapfile"
			elif [[ $SeBak == "S.3" ]] then
				cp -v -R /home/$UserName/Documents/FH/S.3/* /run/media/$UserName/$USBname/Documents/FH/S.3/
				
				myfile="/home/$UserName/Documents/FH/S.3"
					print "$myfile" "$mapfile"
			fi
			
			#wc -c /run/media/$UserName/$USBname/Documents/FH/* >> /run/media/$UserName/$USBname/Documents/backupLog.txt
			echo "backup Logseq"
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo "Logseq_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
			
			cp -v -R /home/$UserName/Documents/logseq/* /run/media/$UserName/$USBname/Documents/logseq/
			#wc -c /run/media/$UserName/$USBname/Documents/logseq/* >> /run/media/$UserName/$USBname/Documents/backupLog.txt
			myfile="/home/$UserName/Documents/logseq"
				print "$myfile" "$mapfile"
			#/home/lhl/Documents/logseq
			
			echo "backup DIY"
			oneMore="y"
			while [[ $oneMore == "y" ]]; do
				ls /home/$UserName/Documents/DIY
				echo "input the Project u wanna backup"
				read backupDIY
				#/run/media/$UserName/$USBname/Documents/backupLog.txt
					echo "" >> $mapfile
					echo "$spaceLogfile" >> "$mapfile"
					echo ""$backupDIY"_$(date +"%d.%m.%y")" >> "$mapfile"
					echo "" >> "$mapfile"
				mkdir /run/media/$UserName/$USBname/Documents/DIY/$backupDIY
				cp -v -R /home/$UserName/Documents/DIY/$backupDIY/* /run/media/$UserName/$USBname/Documents/DIY/$backupDIY/
				#wc -c /run/media/$UserName/$USBname/Documents/DIY/* >> /run/media/$UserName/$USBname/Documents/backupLog.txt
				myfile="/home/$UserName/Documents/DIY/$backupDIY"
					print "$myfile" "$mapfile"
				echo "Do you want to backup a nothjer one [y/N]"
				read oneMore
			done		
		;;
		
		usb-l)
			echo "backup Logseq"
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo "Logseq_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
			
			cp -v -R /home/$UserName/Documents/logseq/* /run/media/$UserName/$USBname/Documents/logseq/
			#wc -c /run/media/$UserName/$USBname/Documents/logseq/* >> /run/media/$UserName/$USBname/Documents/backupLog.txt
			myfile="/home/$UserName/Documents/logseq"
				print "$myfile" "$mapfile"
		;;
		
		usb-diy)
			echo "backup DIY"
			oneMore="y"
			while [[ $oneMore == "y" ]]; do
				ls /home/$UserName/Documents/DIY
				echo "input the Project u wanna backup"
				read backupDIY
				#/run/media/$UserName/$USBname/Documents/backupLog.txt
					echo "" >> $mapfile
					echo "$spaceLogfile" >> "$mapfile"
					echo ""$backupDIY"_$(date +"%d.%m.%y")" >> "$mapfile"
					echo "" >> "$mapfile"
				mkdir /run/media/$UserName/$USBname/Documents/DIY/$backupDIY
				cp -v -R /home/$UserName/Documents/DIY/$backupDIY/* /run/media/$UserName/$USBname/Documents/DIY/$backupDIY/
				#wc -c /run/media/$UserName/$USBname/Documents/DIY/* >> /run/media/$UserName/$USBname/Documents/backupLog.txt
				myfile="/home/$UserName/Documents/DIY/$backupDIY"
					print "$myfile" "$mapfile"
				echo "Do you want to backup a nothjer one [y/N]"
				read oneMore
			done
		;;
		
		usb-fh)
			echo "FH backup of: S.1; S.2; S.3; DIY of choice; logseq to USB: $USBname"
			#Folders to backup
			#FolderBackup=("/home/lhl/Documents/FH/S.1" "/home/lhl/Documents/FH/S.2" "/home/lhl/Documents/FH/S.3" "/home/lhl/Documents/logseq" "/home/lhl/Documents/DIY/a_howto's" )		
			echo "which Semester to backup: S.1 S.2 S.3"
			read SeBak
			
				echo "" >> "$mapfile"
				echo "$spaceLogfile" >> "$mapfile"
				echo ""$SeBak"_$(date +"%d.%m.%y")" >> "$mapfile"
				echo "" >> "$mapfile"
			
			echo ""
			if [[ $SeBak == "S.1"  ]] then
				cp -v -R /home/$UserName/Documents/FH/S.1/* /run/media/$UserName/$USBname/Documents/FH/S.1/
				
				myfile="/home/$UserName/Documents/FH/S.1"
				
					print "$myfile" "$mapfile"
			elif [[ $SeBak == "S.2" ]] then
				cp -v -R /home/$UserName/Documents/FH/S.2/* /run/media/$UserName/$USBname/Documents/FH/S.2/
				
				myfile="/home/$UserName/Documents/FH/S.2"
					print "$myfile" "$mapfile"
			elif [[ $SeBak == "S.3" ]] then
				cp -v -R /home/$UserName/Documents/FH/S.3/* /run/media/$UserName/$USBname/Documents/FH/S.3/
				
				myfile="/home/$UserName/Documents/FH/S.3"
					print "$myfile" "$mapfile"
			fi
		;;
		
		*)
		;;
	esac
}



options(){
echo "Options:"
echo "		usb		- install AppImages and RPM from USB"
echo "		repo		- Install Applications from repo"
echo "		addAppIm	- Add AppImages to Desktop"
echo "		setBatt		- Set max Battary charge value"
echo "		exten		- Add shell Extensions"
echo "		backup		- Run Backup"
echo "		printdir	- print Dir overview"
echo "		fixPort		- If Arduino or vs code cant acess Ports"
echo "		bleach		- install terminal auto compleation"
echo "-h			- schows Options again"
echo "exit 			- ends script"
}
#=========================================================================================================================

option

oneMore_2="y"
while [[ $oneMore_2 == "y" ]]; do
	
	echo "Enter exact Option Name"
	read woption
	case $woption in
	usb)
		USBsetup
	;;
	
	repo)
		installREPO
	;;

	setBatt)
		BATTchGlimit
	;;
	
	exten)
		shellExtensions
	;;
	
	addAppIm)
		addAppImage
	;;
	
	backup)
		backup
	;;
	
	printdir)
		printdire
	;;
	
	"exit")
		oneMore_2="n"
	;;
	
	-h)
		options
	;;
	
	fixPort)
		fixportacess
	;;
	bleach)
		git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
		make -C ble.sh install PREFIX=~/.local
		echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
		# https://github.com/akinomyoga/ble.sh
	
	*)
		echo "Faild Input"
		options
	;;
	
	esac
done


# nstall g++
