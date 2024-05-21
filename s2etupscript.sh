#! /usr/bin/bash
echo ""
UserName="$(whoami)"
USBname="71D0-8A5F"

echo "Linux script"
echo "User: $UserName"
echo ""

GITNVIM="https://github.com/LigoliPuschkin/nvim" 					# nvim config
# Software to to choose from repo to install
Software=('freecad' 'timeshift' 'kicad' 'veracrypt' 'openscad' 'keepassxc' 'firefox' 'haruna' 'pdfarranger' 'xournalpp'
	'libreoffice-impress' 'libreoffice-langpack-en' 'libreoffice-writer' 'libreoffice-calc' 'prusa-slicer' 'gnome-tweaks'
	'easyeffects' 'gimp' 'audacity' 'obs-studio' 'neovim' 'qtcreator' 'gstreamer1-plugin-openh264 mozilla-openh264')
# software to remove
SoftwareD=('cheese' 'gnome-color-manager' 'gnome-maps' 'rhythmbox' 'gnome-weather' 'gnome-color-manager')
# Gnome Plugins
shellEXT=('gnome-browser-connector' 'gnome-extensions-app')			# required Apps in order to have Plugins(extentions)
		# ↓below↓ extentions to install
extensions=('https://extensions.gnome.org/extension/1460/vitals/' 'https://extensions.gnome.org/extension/517/caffeine/'
	'https://extensions.gnome.org/extension/744/hide-activities-button/' 'https://extensions.gnome.org/extension/3193/blur-my-shell/'
	'https://extensions.gnome.org/extension/4839/clipboard-history/' "https://extensions.gnome.org/extension/8/places-status-indicator/")

draw_line(){						# function to draw line across the terminal window
	w=$(tput cols)					# gets number of characters needed
	d=""
	#echo $w						# debug
	for ((i = 0; i < $w; i++)); do
		d+="$1"						# adds one more 
	done 
	echo $d							# prints to terminal window
}

USBNAME() {
	echo "is: $USBname your USB-drife [y/N]"
	read yourUSB
	if [[ $yourUSB != "y" ]] then
		echo "Input USB-Name"
		read USBname
	fi
	echo "$USBname is the selected USB-device"
} 

#--------------------------------------------------------------------------------------------------------------------------
USBsetup(){
	echo "copy Documents to PC? [y/N]"
	read instrep
	if [[ $instrep == "y" ]] then
		if -d /run/media/$UserName/$USBname/Documents/bash; then
			cp -a /run/media/$UserName/$USBname/Documents/bash /home/$UserName
			echo "setting up Terminal script"
			chmod u+x /home/$UserName/Documents/bash/configs/terminal.sh							# makes script executable
			echo "bash /home/$UserName/Documents/bash/configs/terminal.sh" >> /home/.bashrc			# puts the line in brakets in the bashrc fil so that it will execute every time you open a new terminal window
		else
			echo "could not find find Documents in: $USBname"
		fi
	fi

	drwa_line "="
	echo "USB-setup"
		echo "		- Appimages [executabledesctop entry]"
		echo "		- RPM Packages [Veracrypt]"
		#echo "		- Appimages [executabledesctop entry]"
	echo ""
	echo "install AppImages from USB? [y/N]"
	read AppImUSB
	echo ""
	if [[ $AppImUSB == "y" ]] then 						# checks if folder for AppImages already exists
		cd /home/UserName
		if cd AppImage &> /dev/null; then
			cd Appimage
		else
			mkdir Appimage								# if it not exist it creat
		fi

		cd /run/media/$UserName/$USBname/software/AppImages				# place on USB for AppImages
		
		USBoneMore="y"
		
		while [[ $USBoneMore == "y" ]]; do
			echo ""
			echo "the following AppImages are avilable:"
			echo ""
			ls
			echo ""
			echo "which AppImage to Add? Input the exact name of the listed Images"
			read WhichAppIM
			
			cp /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/*.AppImage /home/$UserName/AppImages		# copys Appimage and png Icon to AppImages folder
			cp /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/*.png /home/$UserName/AppImages
			
			readarray -t USBdesktop< /run/media/$UserName/$USBname/software/AppImages/$WhichAppIM/$WhichAppIM.desktop 			# reads the .desktop file from the usb
			
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
	drwa_line "="
}

#--------------------------------------------------------------------------------------------------------------------------
installREPO(){
	draw_line "="
	echo "start Repo App install"
	echo ""
	SoftwareTo=()											# Array to store software to be installed
	
	for val in "${SoftwareD[@]}"; do 						# delets software i dont need
		if dnf list installed $val &> /dev/null; then		# checks if sotware is installed
			echo "removing: $val"
			sudo dnf remove -y "$val"
		fi
	done
	sudo dnf autoremove -y

	
	sudo dnf update -y

	for val in "${Software[@]}"; do 						# cycles thrue Software Arry and asks you which you want to install and pust it in SoftwareTo
		if dnf list installed $val &> /dev/null; then		# checks if software is already installed
			echo ""
		else 
			echo "install $val? [y/N]"
			read instrep
			if [[ $instrep == "y" ]] then
				SoftwareTo+=("$val")
				if [[ $val == "neovim" ]] then
					SoftwareTo+=('g++')
					SoftwareTo+=('cmake')
					SoftwareTo+=('pip')
					if cd /run/media/$UserName/$USBname/Documents/bash/configs/nvim &> /dev/null; then				# checks if USB is Pluged in and if it contains the nvim folder
						cp -a /run/media/$UserName/$USBname/Documents/bash/configs/nvim /home/$UserName/.config		# copies nvim folder
					elif cd /home/$UserName/Documents/bash/configs/nvim &> /dev/null; then							# checks if there is a nvim folder in Documents
						cp -a /home/$UserName/Documents/bash/configs/nvim /home/$UserName/.config					# copies it 
					else
						echo "no config found use github? [y/N]"													# gets nvim config from my github
						read instrep
						if [[ $instrep == "y" ]] then
							cd /home/$UserName/.config
							git clone $GITNVIM
						fi
					fi
				fi
			fi
		fi
	done

	for val in "${SoftwareTo[@]}"; do
		sudo dnf install -y "$val"
	done
			
	sudo dnf autoremove
	echo ""
	echo "stop Repo App install"
	draw_line "="	
}

#--------------------------------------------------------------------------------------------------------------------------
BATTchGlimit(){
	#https://www.linuxuprising.com/2021/02/how-to-limit-battery-charging-set.html
	draw_line "="	
	echo "start Battary chg limit"
	echo ""
		
	echo "check below For BAT0 or similar"
	#ls /sys/class/power_supply
		
	ls /sys/class/power_supply/BAT*/charge_control_end_threshold
	if dnf list installed gedit &> /dev/null; then
		echo ""
	else
		echo "installing Gedit"
		sudo dnf install -y gedit
	fi	
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
	echo ""
	echo ""

	sudo touch /etc/systemd/system/battery-charge-threshold.service			# creates file in wch above text will be stored
	gedit admin:///etc/systemd/system/battery-charge-threshold.service
	
	echo ""
	echo "ready to proced? [y/N]"
	read proced
	if [[ $proced == y ]]	then
		sudo systemctl enable battery-charge-threshold.service
		sudo systemctl start battery-charge-threshold.service
	# the below tow line shuldent be necesarry but apparently you dont have toi restart youtr pc when theey ther
		sudo systemctl daemon-reload
		sudo systemctl restart battery-charge-threshold.service
		
		echo "current Battery status:"	
		cat /sys/class/power_supply/BAT0/status
		echo ""
		echo "end Battary chg limit"
		draw_line "="	
	fi
}

#--------------------------------------------------------------------------------------------------------------------------
fixportacess(){
#https://support.arduino.cc/hc/en-us/articles/360016495679-Fix-port-access-on-Linux
	draw_line "="
	echo "start Port acess settings"
	echo "https://support.arduino.cc/hc/en-us/articles/360016495679-Fix-port-access-on-Linux"
	echo ""
	sudo usermod -a -G dialout $UserName
	echo "stop Fix terminal Acess"
	draw_line "="
}

#--------------------------------------------------------------------------------------------------------------------------
addAppImage(){
	#https://www.youtube.com/watch?v=bXZma0t0PKE App Image install
	draw_line "="
	echo "start adding AppImag"
	echo ""
	echo "In Preperation for this Download requoired AppImages along with Icons you wanna use for them"
	echo ""
		
	cd /home/UserName
		if cd AppImage &> /dev/null; then
			cd Appimage
		else
			mkdir Appimage								# if it not exist it creat
		fi
	
	echo ""
	
	echo "Now you have to move All your AppImages along with theyer Icons to: /home/AppImages"
	oneMore="y"

	while [[ $oneMore == "y" ]]; do

#		echo "you are supposed to Sore all your AppImages along with theyer Icons there"
		echo "now you have to input the Application details i.e meaning you have to give the absolut path to Icon and Exec"
		echo "further more you have to name the Application and add it to a category"
	
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
	draw_line "="
}

#--------------------------------------------------------------------------------------------------------------------------
shellExtensions(){
	draw_line "="														# print spaces in terminal
	echo "start gnome extentions"
		
	for val in "${shellEXT[@]}"; do										# checks if required Sotware is in stalled
		if dnf list installed $val  &> /dev/null; then 
			#echo "$val already installed"
			echo ""
		else															# if not installd install it
			echo "installing: $val"
			sudo dnf install $val
		fi
	done
	
	echo ""
	echo "each Pluging will be opend in its own Window, close ot to get to the next one"
	
	for val in "${extensions[@]}"; do 
		firefox --new-window $val
	done
	gnome-extensions-app					# opens extentions app in order activate deactivate extentions
		
	echo ""
	echo "stop gnome shell ext"
	draw_line "="
}

#--------------------------------------------------------------------------------------------------------------------------
options(){
echo "Options:"
echo "		usb		- install AppImages and RPM from USB"
echo "		repo		- Install Applications from repo"
echo "		addAppIm	- Add AppImages to Desktop"
echo "		setBatt		- Set max Battary charge value"
echo "		exten		- Add shell Extensions"
echo "		fixPort		- If Arduino or vs code cant acess Ports"
echo "		bleach		- install terminal auto compleation"
echo "-h			- schows Options again"
echo "exit 			- ends script"
}
#=========================================================================================================================

# option

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
	
	fixPort)
		fixportacess
	;;
	
	bleach)
		git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
		make -C ble.sh install PREFIX=~/.local
		echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
		# https://github.com/akinomyoga/ble.sh
	;;	
	
	"exit")
		oneMore_2="n"
	;;
	
	-h)
		options
	;;

	*)
		echo "Faild Input"
		options
	;;
	
	esac
done


# install g++
