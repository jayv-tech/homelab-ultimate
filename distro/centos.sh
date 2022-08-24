#!/bin/bash

# Must be root to continue with installation. To avoid any permission issues!
echo ""
if [[ $EUID -eq 0 ]];then
    echo " You are root."
else
    echo " sudo will be used for the install."
    # Check if sudo is installed
    # If it isn't, exit because the installation cannot proceed.
    if [[ $(rpm -q sudo) ]];then
        export SUDO="sudo"
        export SUDOE="sudo -E"
    else
        echo " Please install sudo or run this as root."
        exit 1
    fi
fi

installDock()
{
  clear

        #Defining a spinner function beforehand to denote progress instead of showing output.
        spinner()
        {
            local pid=$1
            local delay=0.25
            local spinstr='/-\|'
            while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
                local temp=${spinstr#?}
                printf " [%c]  " "${spinstr}"
                local spinstr=${temp}${spinstr%"$temp"}
                sleep ${delay}
                printf "\b\b\b\b\b\b"
            done
            printf "    \b\b\b\b"
        }

    #Updates check
        checkForUpdates() 
        {
            #Running yum update to check for the updates available.
                echo ""
                echo -n " Hey $username, I am now running the package updates. This is necessary to proceed with installing Docker."
                $SUDO yum check-update & spinner $!
                echo " It's Done."
            echo ""
            echo " Checking dependencies now"
            ($SUDO yum -y --quiet install git curl wget grep dnsutils expect whiptail >> ~/docker/homelab-install-script.log || echo "Installation Failed!") & spinner $!
            sleep 2s
            echo ""
            echo " Done."

        }

        DockCheck()
        {
            ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
            ISCOMP=$( (docker compose -v ) 2>&1 )

            #### Try to check whether docker is installed and running - don't prompt if it is
            if [[ "$ISACT" != "active" ]]; then

            echo ""
            checkForUpdates
            echo ""

                echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
                
                (curl -fsSL https://get.docker.com | sh) >> ~/docker/homelab-install-script.log 2>&1 &
                    spinner $!
                echo ""
                echo " The installation of Docker Engine is complete and the version installed was - "
                DOCKERV=$(docker -v)
                echo "    "${DOCKERV}
                
                echo ""
                sleep 3s
                echo " Starting the Docker Service"
                (sudo systemctl start docker) >> ~/docker/homelab-install-script.log 2>&1
                sleep 10s
                echo ""
                echo " Done."
                sleep 1s
                
            else
                echo ""
                echo " Docker appears to be already installed and running in this system."
                echo ""
            fi

            if [[ "$ISCOMP" == *"command not found"* ]]; then
                echo " The script will now install the latest version of Docker-Compose."        
                
                (COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo chmod +x /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 

                echo ""
                echo " The installation of Docker-Compose is also done. The version installed was - " 
                DOCKCOMPV=$(docker compose version)
                echo "   "${DOCKCOMPV}
                echo ""
                
            else
                echo ""
                echo " Docker Compose appears to be already installed."
                echo ""
            fi
                # Enabling docker to start automatically on hardware reboot
                echo " Enabling the Docker service to start automatically on boot."
                (sudo systemctl enable docker) >> ~/docker/homelab-install-script.log 2>&1
                (sudo usermod -aG docker $USER) >> ~/docker/homelab-install-script.log 2>&1
                echo ""
                echo "Done."
        }

    installportainer ()
    {
      #Defining a spinner function beforehand to denote progress instead of showing output.
      spinner()
      {
          local pid=$1
          local delay=0.25
          local spinstr='/-\|'
          while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
              local temp=${spinstr#?}
              printf " [%c]  " "${spinstr}"
              local spinstr=${temp}${spinstr%"$temp"}
              sleep ${delay}
              printf "\b\b\b\b\b\b"
          done
          printf "    \b\b\b\b"
      }

      #Portainer installation
      PTAIN_FULLCE ()
      {
        echo "Installing Portainer's Community Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      PTAIN_AGNT ()
      {
        echo "Installing Portainer Agent."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " From your main Portainer or Portainer-CE instance, add this Agent instance via the 'Endpoints' option in the left menu."
        echo " Use the IP ${CLOUDIP} port 9001 and also check if you need Port Forwarding enabled in your network."
        echo ""
      }

      PTAIN_FULLBE ()
      {
        echo "Installing Portainer's Business Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      #Setting up a function to see if Portainer already exists from any previous installation.
      PTAINCE_CHECK ()
      {
            portainerce_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerce_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerce_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLCE
          fi
      }

      PTAINBE_CHECK ()
      {
            portainerbe_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerbe_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerbe_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLBE
          fi
      }

      PTAINAG_CHECK ()
      {
            portainerag_check=$( docker ps -a -f name=portainer_agent | grep portainer_agent 2> /dev/null )
          if [[ ! -z ${portainerag_check} ]]; then 
            echo "A container with a name: Portainer Agent already exists and has status: $( echo ${portainerag_check} | awk '{ print $7 }' ), so skipping the Agent installation."
          else
            PTAIN_AGNT
          fi
      }

      PTAIN_CHOICES=$(whiptail --title "Portainer Selection" --menu "Choose an option" 20 110 7 \
        "1" "Community Edition - Standard installation of Portainer's free edition" \
        "2" "Portainer Agent - Installation of just the Agent service to connect to other Portainer instances." \
        "3" "Business Edition - Installation of Portainer's Business Edition." \
        "4" "Nevermind, I don't need Portainer to be setup now." 3>&1 1>&2 2>&3)

      if [ -z "$PTAIN_CHOICES" ]; then
        echo "No option was selected, the installer will exit now."
      else
        for PTAIN_CHOICE in $PTAIN_CHOICES; do
          case "$PTAIN_CHOICE" in
          "1")
            PTAINCE_CHECK
            ;;
          "2")
            PTAINAG_CHECK
            ;;
          "3")
            PTAINBE_CHECK
            ;;
          "4")
            exit 1
            ;;
          *)
            echo "Unsupported item $PTAIN_CHOICE!" >&2
            exit 1
            ;;
          esac
        done
      fi
    }

  echo ""
  echo ""
  echo "  ____             _               ____       _               ";
  echo " |  _ \  ___   ___| | _____ _ __  / ___|  ___| |_ _   _ _ __  ";
  echo " | | | |/ _ \ / __| |/ / _ \ '__| \___ \ / _ \ __| | | | '_ \ ";
  echo " | |_| | (_) | (__|   <  __/ |     ___) |  __/ |_| |_| | |_) |";
  echo " |____/ \___/ \___|_|\_\___|_|    |____/ \___|\__|\__,_| .__/ ";
  echo "                                                       |_|    ";
  echo ""
  echo ""

  echo " You have chosen to install Docker, Docker-Compose and Portainer."

  DockCheck

  echo ""

  echo " Let's now complete this setup by installing Portainer"

  # Installing portainer for Docker GUI Management
  installportainer

  echo ""
  echo " That's it $username, the installation of Docker, Docker-Compose, and Portainer is over. Thank you for using the script." 
  echo ""
  echo ""
  cd
  exit 1

}

installNxtCld()
{
  clear

    #Defining a spinner function beforehand to denote progress instead of showing output.
        spinner()
        {
            local pid=$1
            local delay=0.25
            local spinstr='/-\|'
            while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
                local temp=${spinstr#?}
                printf " [%c]  " "${spinstr}"
                local spinstr=${temp}${spinstr%"$temp"}
                sleep ${delay}
                printf "\b\b\b\b\b\b"
            done
            printf "    \b\b\b\b"
        }

    #Updates check
        checkForUpdates() 
        {
            #Running yum update to check for the updates available.
                echo ""
                echo -n " Hey $username, I am now running the package updates. This is necessary to proceed with installing Docker."
                $SUDO yum check-update & spinner $!
                echo " It's Done."
            echo ""
            echo " Checking dependencies now"
            ($SUDO yum -y --quiet install git curl wget grep dnsutils expect whiptail >> ~/docker/homelab-install-script.log || echo "Installation Failed!") & spinner $!
            sleep 2s
            echo ""
            echo " Done."

        }

        DockCheck()
        {
            ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
            ISCOMP=$( (docker compose -v ) 2>&1 )

            #### Try to check whether docker is installed and running - don't prompt if it is
            if [[ "$ISACT" != "active" ]]; then

            echo ""
            checkForUpdates
            echo ""

                echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
                
                (curl -fsSL https://get.docker.com | sh) >> ~/docker/homelab-install-script.log 2>&1 &
                    spinner $!
                echo ""
                echo " The installation of Docker Engine is complete and the version installed was - "
                DOCKERV=$(docker -v)
                echo "    "${DOCKERV}
                
                echo ""
                sleep 3s
                echo " Starting the Docker Service"
                (sudo systemctl start docker) >> ~/docker/homelab-install-script.log 2>&1
                sleep 10s
                echo ""
                echo " Done."
                sleep 1s
                
            else
                echo ""
                echo " Docker appears to be already installed and running in this system."
                echo ""
            fi

            if [[ "$ISCOMP" == *"command not found"* ]]; then
                echo " The script will now install the latest version of Docker-Compose."        
                
                (COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo chmod +x /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 

                echo ""
                echo " The installation of Docker-Compose is also done. The version installed was - " 
                DOCKCOMPV=$(docker compose version)
                echo "   "${DOCKCOMPV}
                echo ""
                
            else
                echo ""
                echo " Docker Compose appears to be already installed."
                echo ""
            fi
                # Enabling docker to start automatically on hardware reboot
                echo " Enabling the Docker service to start automatically on boot."
                (sudo systemctl enable docker) >> ~/docker/homelab-install-script.log 2>&1
                (sudo usermod -aG docker $USER) >> ~/docker/homelab-install-script.log 2>&1
                echo ""
                echo "Done."
        }

    installportainer ()
    {
      #Defining a spinner function beforehand to denote progress instead of showing output.
      spinner()
      {
          local pid=$1
          local delay=0.25
          local spinstr='/-\|'
          while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
              local temp=${spinstr#?}
              printf " [%c]  " "${spinstr}"
              local spinstr=${temp}${spinstr%"$temp"}
              sleep ${delay}
              printf "\b\b\b\b\b\b"
          done
          printf "    \b\b\b\b"
      }

      #Portainer installation
      PTAIN_FULLCE ()
      {
        echo "Installing Portainer's Community Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      PTAIN_AGNT ()
      {
        echo "Installing Portainer Agent."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " From your main Portainer or Portainer-CE instance, add this Agent instance via the 'Endpoints' option in the left menu."
        echo " Use the IP ${CLOUDIP} port 9001 and also check if you need Port Forwarding enabled in your network."
        echo ""
      }

      PTAIN_FULLBE ()
      {
        echo "Installing Portainer's Business Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      #Setting up a function to see if Portainer already exists from any previous installation.
      PTAINCE_CHECK ()
      {
            portainerce_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerce_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerce_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLCE
          fi
      }

      PTAINBE_CHECK ()
      {
            portainerbe_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerbe_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerbe_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLBE
          fi
      }

      PTAINAG_CHECK ()
      {
            portainerag_check=$( docker ps -a -f name=portainer_agent | grep portainer_agent 2> /dev/null )
          if [[ ! -z ${portainerag_check} ]]; then 
            echo "A container with a name: Portainer Agent already exists and has status: $( echo ${portainerag_check} | awk '{ print $7 }' ), so skipping the Agent installation."
          else
            PTAIN_AGNT
          fi
      }

      PTAIN_CHOICES=$(whiptail --title "Portainer Selection" --menu "Choose an option" 20 110 7 \
        "1" "Community Edition - Standard installation of Portainer's free edition" \
        "2" "Portainer Agent - Installation of just the Agent service to connect to other Portainer instances." \
        "3" "Business Edition - Installation of Portainer's Business Edition." \
        "4" "Nevermind, I don't need Portainer to be setup now." 3>&1 1>&2 2>&3)

      if [ -z "$PTAIN_CHOICES" ]; then
        echo "No option was selected, the installer will exit now."
      else
        for PTAIN_CHOICE in $PTAIN_CHOICES; do
          case "$PTAIN_CHOICE" in
          "1")
            PTAINCE_CHECK
            ;;
          "2")
            PTAINAG_CHECK
            ;;
          "3")
            PTAINBE_CHECK
            ;;
          "4")
            exit 1
            ;;
          *)
            echo "Unsupported item $PTAIN_CHOICE!" >&2
            exit 1
            ;;
          esac
        done
      fi
    }

echo ""
echo ""
echo "  _   _           _       _                 _      _    ___ ___  ";
echo " | \ | | _____  _| |_ ___| | ___  _   _  __| |    / \  |_ _/ _ \ ";
echo " |  \| |/ _ \ \/ | __/ __| |/ _ \| | | |/ _\'|   / _ \  | | | | |";
echo " | |\  |  __/>  <| || (__| | (_) | |_| | (_| |  / ___ \ | | |_| |";
echo " |_| \_|\___/_/\_|\__\___|_|\___/ \__,_|\__,_| /_/   \_|___\___/ ";
echo "                                                                 ";
echo ""
echo ""

      DockCheck

      echo ""
      echo " Let's now proceed with installing the Nextcloud AIO Image."
      echo ""
      echo " Portainer setup will follow later on."
      echo ""
      (sudo mkdir -p docker/nextcloud)
      cd docker/nextcloud
      echo ""

      NXTPTH=$(whiptail --inputbox --title "Path Selection" "Now you need to provide the path of the directory to store your files and folders in Nextcloud.\nProvide the path in the format of '/data/path' without the trailing '/'. If the folder doesn't exist, it will automatically be created.\nEg: /home/${USER}/data (or) /mnt/data/nxtcld" 20 110 3>&1 1>&2 2>&3)

        exitstatus=$?
      
            if [ $exitstatus = 0 ]; then
            
                if [[ -d "$NXTPTH" ]]; then
                    (sudo chown -R 33:0 "$NXTPTH")>/dev/null
                    (sudo chmod -R 750 "$NXTPTH")>/dev/null
                else    
                    (sudo mkdir "$NXTPTH" -p)
                    (sudo chown -R 33:0 "$NXTPTH")>/dev/null
                    (sudo chmod -R 750 "$NXTPTH")>/dev/null
                fi
            
            else
                echo ""
                echo "No input was provided, the installer has exited."
                echo ""
                sleep 1s
                continue
            fi

      echo ""
      echo " Running the docker commands to install and start Nextcloud instance."
      echo ""
      
      ARCH=$( (uname -m ) 2>&1 )

      if [[ "$ARCH" == "x86_64" || "$ARCH" == "AMD64"|| "$ARCH" == "i386" || "$ARCH" == "i486" || "$ARCH" == "i586" || "$ARCH" == "i686" ]]; then

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudx86-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1
        
        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

        #Replacing the placeholder texts with user provided inputs.
        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        
        #(sudo docker run -d --name nextcloud-aio-mastercontainer --restart always -p 80:80 -p 8080:8080 -p 8443:8443 -e NEXTCLOUD_DATADIR=$NXTPTH --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest) >> ~/docker/homelab-install-script.log 2>&1 &      

        (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!

      fi

      if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm" || "$ARCH" == "arm64" || "$ARCH" == "armv8" ]]; then

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudarm64-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1 

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1
        
        #Replacing the placeholder texts with user provided inputs.
        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

        #(sudo docker run -d --name nextcloud-aio-mastercontainer --restart always -p 80:80 -p 8080:8080 -p 8443:8443 -e NEXTCLOUD_DATADIR=$NXTPTH --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest-arm64) >> ~/docker/homelab-install-script.log 2>&1 &
        
        (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!

      fi

      echo ""
      echo "Let's now complete this setup by installing Portainer"
      echo ""
      installportainer
      echo ""
      echo ""
      echo " Navigate to https://${LOCALIP}:8080 to start the Nextcloud AIO setup"
      echo ""
      echo " Nextcloud recommends setting up the instance with a domain name and the AIO container is configured to get SSL certificates automatically."
      echo ""
      echo " That's it $username, the installation of Nextcloud is complete and you can now start using your own storage cloud." 
      echo ""
      echo ""
      cd
      exit 1
}

installMSP()
{
  clear

    #Defining a spinner function beforehand to denote progress instead of showing output.
        spinner()
        {
            local pid=$1
            local delay=0.25
            local spinstr='/-\|'
            while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
                local temp=${spinstr#?}
                printf " [%c]  " "${spinstr}"
                local spinstr=${temp}${spinstr%"$temp"}
                sleep ${delay}
                printf "\b\b\b\b\b\b"
            done
            printf "    \b\b\b\b"
        }

    #Updates check
        checkForUpdates() 
        {
            #Running yum update to check for the updates available.
                echo ""
                echo -n " Hey $username, I am now running the package updates. This is necessary to proceed with installing Docker."
                $SUDO yum check-update & spinner $!
                echo " It's Done."
            echo ""
            echo " Checking dependencies now"
            ($SUDO yum -y --quiet install git curl wget grep dnsutils expect whiptail >> ~/docker/homelab-install-script.log || echo "Installation Failed!") & spinner $!
            sleep 2s
            echo ""
            echo " Done."

        }

        DockCheck()
        {
            ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
            ISCOMP=$( (docker-compose -v ) 2>&1 )

            #### Try to check whether docker is installed and running - don't prompt if it is
            if [[ "$ISACT" != "active" ]]; then

            echo ""
            checkForUpdates
            echo ""

                echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
                
                (curl -fsSL https://get.docker.com | sh) >> ~/docker/homelab-install-script.log 2>&1 &
                    spinner $!
                echo ""
                echo " The installation of Docker Engine is complete and the version installed was - "
                DOCKERV=$(docker -v)
                echo "    "${DOCKERV}
                
                echo ""
                sleep 3s
                echo " Starting the Docker Service"
                (sudo systemctl start docker) >> ~/docker/homelab-install-script.log 2>&1
                sleep 10s
                echo ""
                echo " Done."
                sleep 1s
                
            else
                echo ""
                echo " Docker appears to be already installed and running in this system."
                echo ""
            fi

            if [[ "$ISCOMP" == *"command not found"* ]]; then
                echo " The script will now install the latest version of Docker-Compose."        
                
                (COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo chmod +x /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 

                echo ""
                echo " The installation of Docker-Compose is also done. The version installed was - " 
                DOCKCOMPV=$(docker compose version)
                echo "   "${DOCKCOMPV}
                echo ""
                
            else
                echo ""
                echo " Docker Compose appears to be already installed."
                echo ""
            fi
                # Enabling docker to start automatically on hardware reboot
                echo " Enabling the Docker service to start automatically on boot."
                (sudo systemctl enable docker) >> ~/docker/homelab-install-script.log 2>&1
                (sudo usermod -aG docker $USER) >> ~/docker/homelab-install-script.log 2>&1
                echo ""
                echo "Done."
        }

    installportainer ()
    {
      #Defining a spinner function beforehand to denote progress instead of showing output.
      spinner()
      {
          local pid=$1
          local delay=0.25
          local spinstr='/-\|'
          while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
              local temp=${spinstr#?}
              printf " [%c]  " "${spinstr}"
              local spinstr=${temp}${spinstr%"$temp"}
              sleep ${delay}
              printf "\b\b\b\b\b\b"
          done
          printf "    \b\b\b\b"
      }

      #Portainer installation
      PTAIN_FULLCE ()
      {
        echo "Installing Portainer's Community Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      PTAIN_AGNT ()
      {
        echo "Installing Portainer Agent."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " From your main Portainer or Portainer-CE instance, add this Agent instance via the 'Endpoints' option in the left menu."
        echo " Use the IP ${CLOUDIP} port 9001 and also check if you need Port Forwarding enabled in your network."
        echo ""
      }

      PTAIN_FULLBE ()
      {
        echo "Installing Portainer's Business Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      #Setting up a function to see if Portainer already exists from any previous installation.
      PTAINCE_CHECK ()
      {
            portainerce_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerce_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerce_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLCE
          fi
      }

      PTAINBE_CHECK ()
      {
            portainerbe_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerbe_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerbe_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLBE
          fi
      }

      PTAINAG_CHECK ()
      {
            portainerag_check=$( docker ps -a -f name=portainer_agent | grep portainer_agent 2> /dev/null )
          if [[ ! -z ${portainerag_check} ]]; then 
            echo "A container with a name: Portainer Agent already exists and has status: $( echo ${portainerag_check} | awk '{ print $7 }' ), so skipping the Agent installation."
          else
            PTAIN_AGNT
          fi
      }

      PTAIN_CHOICES=$(whiptail --title "Portainer Selection" --menu "Choose an option" 20 110 7 \
        "1" "Community Edition - Standard installation of Portainer's free edition" \
        "2" "Portainer Agent - Installation of just the Agent service to connect to other Portainer instances." \
        "3" "Business Edition - Installation of Portainer's Business Edition." \
        "4" "Nevermind, I don't need Portainer to be setup now." 3>&1 1>&2 2>&3)

      if [ -z "$PTAIN_CHOICES" ]; then
        echo "No option was selected, the installer will exit now."
      else
        for PTAIN_CHOICE in $PTAIN_CHOICES; do
          case "$PTAIN_CHOICE" in
          "1")
            PTAINCE_CHECK
            ;;
          "2")
            PTAINAG_CHECK
            ;;
          "3")
            PTAINBE_CHECK
            ;;
          "4")
            exit 1
            ;;
          *)
            echo "Unsupported item $PTAIN_CHOICE!" >&2
            exit 1
            ;;
          esac
        done
      fi
    }

    installPlex()
    {
            
            echo "          Installing Plex           "
            
        
            # Pull the plex docker-compose file from github
            echo " Pulling a default Plex docker-compose.yml file."

            sudo mkdir -p docker/plex
            cd docker/plex
            
            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/plex-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Plex Media Server"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo "" 
            echo " Go to http://${LOCALIP}:32400/web/index.html to setup your Plex account and the instance."
            echo ""       
            cd
    }

    installTautulli()
    {
            
            echo "        Installing Tautulli         "
            
        
            # Pull the tautulli docker-compose file from github
            echo " Pulling a default tautulli docker-compose.yml file."

            sudo mkdir -p docker/tautulli
            cd docker/tautulli

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/tautulli-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Tautulli"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8181 to setup your Tautulli with you Plex account."
            echo ""               
            cd
    }

    installSonarr()
    {
            
            echo "         Installing Sonarr          "
            
        
            # Pull the Sonarr docker-compose file from github
            echo " Pulling a default Sonarr docker-compose.yml file."

            sudo mkdir -p docker/sonarr
            cd docker/sonarr

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sonarr-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Sonarr"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8989 to setup your Sonarr instance."
            echo ""        
            cd
    }

    installRadarr()
    {
            
            echo "         Installing Radarr          "
            
        
            # Pull the Radarr docker-compose file from github
            echo " Pulling a default Radarr docker-compose.yml file."

            sudo mkdir -p docker/radarr
            cd docker/radarr

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/radarr-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Radarr"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:7878 to setup your Radarr instance."
            echo ""       
            cd
    }

    installSabnzbd()
    {
            
            echo "        Installing Sabnzbd          "
            
        
            # Pull the Sabnzbd docker-compose file from github
            echo " Pulling a default Sabnzbd docker-compose.yml file."

            sudo mkdir -p docker/sabnzbd
            cd docker/sabnzbd

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sabnzbd-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Sabnzbd"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8182 to setup your Sabnzbd instance."
            echo ""       
            cd
    }

    installDeluge()
    {
            
            echo "         Installing Deluge          "
            
        
            # Pull the Deluge docker-compose file from github
            echo " Pulling a default Deluge docker-compose.yml file."

            sudo mkdir -p docker/deluge
            cd docker/deluge

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/deluge-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Deluge"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8112 to setup Deluge instance."
            echo ""         
            cd
    }

    installOverseerr()
    {
            
            echo "        Installing Overseerr        "
            
        
            # Pull the Overseerr docker-compose file from github
            echo " Pulling a default Overseerr docker-compose.yml file."

            sudo mkdir -p docker/overseerr
            cd docker/overseerr

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/overseerr-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Overseerr"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:5055 to setup the Overseerr instance."
            echo ""        
            cd
    }

    installJackett()
    {
            
            echo "         Installing Jackett         "
            
        
            # Pull the Jackett docker-compose file from github
            echo " Pulling a default Jackett docker-compose.yml file."

            sudo mkdir -p docker/jackett
            cd docker/jackett

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/jackett-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Jackett"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:9117 to setup the Jackett instance."
            echo ""          
            cd
    }

    installWatchT()
    {
            
            echo "       Installing Watchtower        "
            
        
            # Pull the Watchtower docker-compose file from github
            echo " Pulling a default Watchtower docker-compose.yml file."

            sudo mkdir -p docker/watchtower
            cd docker/watchtower

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/watchtower-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Watchtower"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Once installed, the Watchtower instance will automatically start checking for updates to the applications once every 24 hours."
            echo ""  
            cd
    }

  echo ""
  echo ""
  echo "  __  __          _ _         ____                             ____            _                    ";
  echo " |  \/  | ___  __| (_) __ _  / ___|  ___ _ ____   _____ _ __  |  _ \ __ _  ___| | ____ _  __ _  ___ ";
  echo " | |\/| |/ _ \/ _\'| |/ _\'| \___ \ / _ | '__\ \ / / _ | '__| | |_) / _\'|/ __| |/ / _\'|/ _\' |/ _|";
  echo " | |  | |  __| (_| | | (_| |  ___) |  __| |   \ V |  __| |    |  __| (_| | (__|   | (_| | (_| || __|";
  echo " |_|  |_|\___|\__,_|_|\__,_| |____/ \___|_|    \_/ \___|_|    |_|   \__,_|\___|_|\_\__,_|\__, |\___|";
  echo "                                                                                         |___/      ";
  echo ""
  echo ""

  echo " This script will now install the latest version of Docker and other applications to manage your home media collection."
  echo ""
  whiptail --msgbox --title "Path Selection" "Please provide the path of the directory where you want the applications to be installed and the media files reside.
  
  If there are no media files presently, the folders will be created for future use.
  
  Provide the path in the format of '/data/path' without the trailing '/' \n Eg: /docker/apps (or) /home/$USER/movies etc." 20 110 3>&1 1>&2 2>&3       
  echo ""
  INSPTH=$(whiptail --inputbox --title "Installation Path" "Specify the path to install the applications:" 20 110 3>&1 1>&2 2>&3)
    
    exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
    
        if [[ -d "$INSPTH" ]]; then
            sleep 1s
        else    
            (sudo mkdir "$INSPTH" -p)
        fi
       
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        continue
    fi

  MOVPTH=$(whiptail --inputbox --title "Media Path" "Specify the path to Movies:" 20 110 3>&1 1>&2 2>&3)
  
    exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
    
        if [[ -d "$MOVPTH" ]]; then
            sleep 1s
        else    
            (sudo mkdir "$MOVPTH" -p)
        fi
       
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        continue
    fi

  SHWPTH=$(whiptail --inputbox --title "Media Path" "Specify the path to TV Shows:" 20 110 3>&1 1>&2 2>&3)
  
    exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
    
        if [[ -d "$SHWPTH" ]]; then
            sleep 1s
        else    
            (sudo mkdir "$SHWPTH" -p)
        fi
       
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        continue
    fi

  DWNPTH=$(whiptail --inputbox --title "Media Path" "Specify the path to Downloads:" 20 110 3>&1 1>&2 2>&3)
  
    exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
    
        if [[ -d "$DWNPTH" ]]; then
            sleep 1s
        else    
            (sudo mkdir "$DWNPTH" -p)
        fi
       
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        continue
    fi
  
  echo ""
  echo " Thank you for the input. Now you'll see a screen from which you need to select the applications that you'd like to have installed."
  echo " Just use the arrow keys for navigation and space bar to select/unselect the items." 
  echo ""       
          # Installing Docker, Docker Compose.
          DockCheck
  echo ""
  echo ""
  MSP_CHOICES=$(whiptail --separate-output --checklist "Choose applications" 18 55 10 \
    "1" "Plex       " OFF \
    "2" "Tautulli       " OFF \
    "3" "Sonarr       " OFF \
    "4" "Radarr       " OFF \
    "5" "Sabnzbd        " OFF \
    "6" "Deluge       " OFF \
    "7" "Overseerr        " OFF \
    "8" "Jackett        " OFF \
    "9" "Watchtower       " OFF 3>&1 1>&2 2>&3)

    exitstatus=$?
        
        if [ $exitstatus = 0 ]; then
            for MSP_CHOICE in $MSP_CHOICES; do
                case "$MSP_CHOICE" in
                "1")
                    installPlex
                    ;;
                "2")
                    installTautulli
                    ;;
                "3")
                    installSonarr
                    ;;
                "4")
                    installRadarr
                    ;;
                "5")
                    installSabnzbd
                    ;;
                "6")
                    installDeluge
                    ;;
                "7")
                    installOverseerr
                    ;;
                "8")
                    installJackett
                    ;;
                "9")
                    installWatchT
                    ;;
                *)
                    echo "Unsupported item $MSP_CHOICE!" >&2
                    exit 1
                    ;;
                esac
            done

        else
            echo ""
            echo "No option was selected, the installer has exited."
            echo ""
            sleep 1s
            exit
        fi

  echo ""
          # Installing portainer for Docker GUI Management
          installportainer
  echo ""
  echo " That's it $username, the installation of Media Server Package is over. Thank you for using the script." 
  echo ""
  echo ""
  cd
  exit 1
}

installWP()
{
  clear    

    #Defining a spinner function beforehand to denote progress instead of showing output.
        spinner()
        {
            local pid=$1
            local delay=0.25
            local spinstr='/-\|'
            while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
                local temp=${spinstr#?}
                printf " [%c]  " "${spinstr}"
                local spinstr=${temp}${spinstr%"$temp"}
                sleep ${delay}
                printf "\b\b\b\b\b\b"
            done
            printf "    \b\b\b\b"
        }

    #Updates check
        checkForUpdates() 
        {
            #Running yum update to check for the updates available.
                echo ""
                echo -n " Hey $username, I am now running the package updates. This is necessary to proceed with installing Docker."
                $SUDO yum check-update & spinner $!
                echo " It's Done."
            echo ""
            echo " Checking dependencies now"
            ($SUDO yum -y --quiet install git curl wget grep dnsutils expect whiptail >> ~/docker/homelab-install-script.log || echo "Installation Failed!") & spinner $!
            sleep 2s
            echo ""
            echo " Done."

        }

        DockCheck()
        {
            ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
            ISCOMP=$( (docker-compose -v ) 2>&1 )

            #### Try to check whether docker is installed and running - don't prompt if it is
            if [[ "$ISACT" != "active" ]]; then

            echo ""
            checkForUpdates
            echo ""

                echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
                
                (curl -fsSL https://get.docker.com | sh) >> ~/docker/homelab-install-script.log 2>&1 &
                    spinner $!
                echo ""
                echo " The installation of Docker Engine is complete and the version installed was - "
                DOCKERV=$(docker -v)
                echo "    "${DOCKERV}
                
                echo ""
                sleep 3s
                echo " Starting the Docker Service"
                (sudo systemctl start docker) >> ~/docker/homelab-install-script.log 2>&1
                sleep 10s
                echo ""
                echo " Done."
                sleep 1s
                
            else
                echo ""
                echo " Docker appears to be already installed and running in this system."
                echo ""
            fi

            if [[ "$ISCOMP" == *"command not found"* ]]; then
                echo " The script will now install the latest version of Docker-Compose."        
                
                (COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo chmod +x /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 

                echo ""
                echo " The installation of Docker-Compose is also done. The version installed was - " 
                DOCKCOMPV=$(docker compose version)
                echo "   "${DOCKCOMPV}
                echo ""
                
            else
                echo ""
                echo " Docker Compose appears to be already installed."
                echo ""
            fi
                # Enabling docker to start automatically on hardware reboot
                echo " Enabling the Docker service to start automatically on boot."
                (sudo systemctl enable docker) >> ~/docker/homelab-install-script.log 2>&1
                (sudo usermod -aG docker $USER) >> ~/docker/homelab-install-script.log 2>&1
                echo ""
                echo "Done."
        }
    
    installportainer ()
    {
      #Defining a spinner function beforehand to denote progress instead of showing output.
      spinner()
      {
          local pid=$1
          local delay=0.25
          local spinstr='/-\|'
          while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
              local temp=${spinstr#?}
              printf " [%c]  " "${spinstr}"
              local spinstr=${temp}${spinstr%"$temp"}
              sleep ${delay}
              printf "\b\b\b\b\b\b"
          done
          printf "    \b\b\b\b"
      }

      #Portainer installation
      PTAIN_FULLCE ()
      {
        echo "Installing Portainer's Community Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      PTAIN_AGNT ()
      {
        echo "Installing Portainer Agent."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " From your main Portainer or Portainer-CE instance, add this Agent instance via the 'Endpoints' option in the left menu."
        echo " Use the IP ${CLOUDIP} port 9001 and also check if you need Port Forwarding enabled in your network."
        echo ""
      }

      PTAIN_FULLBE ()
      {
        echo "Installing Portainer's Business Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      #Setting up a function to see if Portainer already exists from any previous installation.
      PTAINCE_CHECK ()
      {
            portainerce_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerce_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerce_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLCE
          fi
      }

      PTAINBE_CHECK ()
      {
            portainerbe_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerbe_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerbe_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLBE
          fi
      }

      PTAINAG_CHECK ()
      {
            portainerag_check=$( docker ps -a -f name=portainer_agent | grep portainer_agent 2> /dev/null )
          if [[ ! -z ${portainerag_check} ]]; then 
            echo "A container with a name: Portainer Agent already exists and has status: $( echo ${portainerag_check} | awk '{ print $7 }' ), so skipping the Agent installation."
          else
            PTAIN_AGNT
          fi
      }

      PTAIN_CHOICES=$(whiptail --title "Portainer Selection" --menu "Choose an option" 20 110 7 \
        "1" "Community Edition - Standard installation of Portainer's free edition" \
        "2" "Portainer Agent - Installation of just the Agent service to connect to other Portainer instances." \
        "3" "Business Edition - Installation of Portainer's Business Edition." \
        "4" "Nevermind, I don't need Portainer to be setup now." 3>&1 1>&2 2>&3)

      if [ -z "$PTAIN_CHOICES" ]; then
        echo "No option was selected, the installer will exit now."
      else
        for PTAIN_CHOICE in $PTAIN_CHOICES; do
          case "$PTAIN_CHOICE" in
          "1")
            PTAINCE_CHECK
            ;;
          "2")
            PTAINAG_CHECK
            ;;
          "3")
            PTAINBE_CHECK
            ;;
          "4")
            exit 1
            ;;
          *)
            echo "Unsupported item $PTAIN_CHOICE!" >&2
            exit 1
            ;;
          esac
        done
      fi
    }

    installMatomo()
    {
            
            echo "         Installing Matomo          "
              
            echo " It is a self-hosted analytics platform that integrates well with Wordpress."
            # Pull the Matomo docker-compose file from github
            sudo mkdir -p docker/matomo
            cd docker/matomo

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/matomo-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1     

            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8384 to view your Matomo instance."
            echo ""
    }

    installWordpress()
    {
            
            echo "        Installing Wordpress        "
            
            sudo mkdir -p docker/wordpress
            cd docker/wordpress

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/wordpress-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/uploads.ini -o uploads.ini) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,mem_lm,'"$(echo "$WPMEM"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,file_lm,'"$(echo "$WPFLM"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &           
            spinner $!
      
            cd
    }

    installNginxProxyManager()
    {
            
            echo "   Installing NGinX Proxy Manager   "
            
            sudo mkdir -p docker/nginx-proxy-manager
            cd docker/nginx-proxy-manager

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/npm-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo ""
            echo " Go to http://${LOCALIP}:81 to setup the Nginx Proxy Manager admin account and configure your domain to this instance."
            echo " Note that the Wordpress instance is running on port 8282. Use this port to setup the prox for your domain prior to starting"
            echo " the famous five-minute installation of wordpress."
            echo ""
            echo " The default login credentials for Nginx Proxy Manager are:"
            echo ""
            echo "  username: admin@example.com"
            echo "  password: changeme"
            echo ""
            echo ""
            echo " Thank you for using this script!"       
    }        

  echo ""
  echo ""
  echo " __        __   _         _ _         ____            _                    ";
  echo " \ \      / ___| |__  ___(_| |_ ___  |  _ \ __ _  ___| | ____ _  __ _  ___ ";
  echo "  \ \ /\ / / _ | '_ \/ __| | __/ _ \ | |_) / _\'|/ __| |/ / _\'|/ _\'|/ _ |";
  echo "   \ V  V |  __| |_) \__ | | ||  __/ |  __| (_| | (__|   | (_| | (_| |  __/";
  echo "    \_/\_/ \___|_.__/|___|_|\__\___| |_|   \__,_|\___|_|\_\__,_|\__, |\___|";
  echo "                                                                |___/      ";
  echo ""
  echo ""
  
  # Installing Docker, Docker Compose.
  DockCheck    

  whiptail --msgbox --title "Caution!" "In order to proceed with the Website Package setup, you need to provide some additional details.
  
  Please note that these values are not editable later on." 20 110
  
  WPMEM=$(whiptail --inputbox --title "Memory Limit" "Specify a comfortable memory limit.
  
  This has to be provided in megabytes (Eg: 64 or 128 etc.)" 20 110 3>&1 1>&2 2>&3)

    exitstatus=$?
        
        if [ $exitstatus = 1 ]; then
            echo ""
            echo "No input was provided, the installer has exited."
            echo ""
            sleep 1s
            exit
        fi

  WPFLM=$(whiptail --inputbox --title "File Limit" "The maximum file size limit needs to be set. 
  
  This is to ensure that the uploads are done properly to your instance. (Eg: 128 or 256 etc.)" 20 110 3>&1 1>&2 2>&3)

    exitstatus=$?
        
        if [ $exitstatus = 1 ]; then
            echo ""
            echo "No input was provided, the installer has exited."
            echo ""
            sleep 1s
            exit
        fi

  whiptail --msgbox  "Thank you for the input, now select the packages you'd like to have installed." 20 110 3>&1 1>&2 2>&3
  
WP_CHOICES=$(whiptail --separate-output --checklist "Choose options" 18 55 10 \
    "1" "Wordpress        " ON \
    "2" "Matomo Analytics       " OFF \
    "3" "Nginx Proxy Manager        " OFF 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
        for WP_CHOICE in $WP_CHOICES; do
            case "$WP_CHOICE" in
            "1")
            installWordpress
            ;;
            "2")
            installMatomo
            ;;
            "3")
            installNginxProxyManager
            ;;
            *)
            echo "Unsupported item $WP_CHOICE!" >&2
            exit 1
            ;;
            esac
        done
        
    else
        echo ""
        echo "No option was selected, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

  # Installing portainer for Docker GUI Management
  installportainer
  cd
  exit 1 

}

installApps()
{
  clear

    #Defining a spinner function beforehand to denote progress instead of showing output.
        spinner()
        {
            local pid=$1
            local delay=0.25
            local spinstr='/-\|'
            while [ "$(ps a | awk '{print $1}' | grep "${pid}")" ]; do
                local temp=${spinstr#?}
                printf " [%c]  " "${spinstr}"
                local spinstr=${temp}${spinstr%"$temp"}
                sleep ${delay}
                printf "\b\b\b\b\b\b"
            done
            printf "    \b\b\b\b"
        }

    #Updates check
        checkForUpdates() 
        {
            #Running yum update to check for the updates available.
                echo ""
                echo -n " Hey $username, I am now running the package updates. This is necessary to proceed with installing Docker."
                $SUDO yum check-update & spinner $!
                echo " It's Done."
            echo ""
            echo " Checking dependencies now"
            ($SUDO yum -y --quiet install git curl wget grep dnsutils expect whiptail >> ~/docker/homelab-install-script.log || echo "Installation Failed!") & spinner $!
            sleep 2s
            echo ""
            echo " Done."

        }

        DockCheck()
        {
            ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
            ISCOMP=$( (docker-compose -v ) 2>&1 )

            #### Try to check whether docker is installed and running - don't prompt if it is
            if [[ "$ISACT" != "active" ]]; then

            echo ""
            checkForUpdates
            echo ""

                echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
                
                (curl -fsSL https://get.docker.com | sh) >> ~/docker/homelab-install-script.log 2>&1 &
                    spinner $!
                echo ""
                echo " The installation of Docker Engine is complete and the version installed was - "
                DOCKERV=$(docker -v)
                echo "    "${DOCKERV}
                
                echo ""
                sleep 3s
                echo " Starting the Docker Service"
                (sudo systemctl start docker) >> ~/docker/homelab-install-script.log 2>&1
                sleep 10s
                echo ""
                echo " Done."
                sleep 1s
                
            else
                echo ""
                echo " Docker appears to be already installed and running in this system."
                echo ""
            fi

            if [[ "$ISCOMP" == *"command not found"* ]]; then
                echo " The script will now install the latest version of Docker-Compose."        
                
                (COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 
                
                (sudo chmod +x /usr/local/bin/docker-compose) >> ~/docker/homelab-install-script.log 2>&1 

                echo ""
                echo " The installation of Docker-Compose is also done. The version installed was - " 
                DOCKCOMPV=$(docker compose version)
                echo "   "${DOCKCOMPV}
                echo ""
                
            else
                echo ""
                echo " Docker Compose appears to be already installed."
                echo ""
            fi
                # Enabling docker to start automatically on hardware reboot
                echo " Enabling the Docker service to start automatically on boot."
                (sudo systemctl enable docker) >> ~/docker/homelab-install-script.log 2>&1
                (sudo usermod -aG docker $USER) >> ~/docker/homelab-install-script.log 2>&1
                echo ""
                echo "Done."
        }

      #Portainer installation
    installportainer ()
    {
      PTAIN_FULLCE ()
      {
        echo "Installing Portainer's Community Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      PTAIN_AGNT ()
      {
        echo "Installing Portainer Agent."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " From your main Portainer or Portainer-CE instance, add this Agent instance via the 'Endpoints' option in the left menu."
        echo " Use the IP ${CLOUDIP} port 9001 and also check if you need Port Forwarding enabled in your network."
        echo ""
      }

      PTAIN_FULLBE ()
      {
        echo "Installing Portainer's Business Edition."
        (sudo docker volume create portainer_data) >> ~/docker/homelab-install-script.log 2>&1
        (docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest) >> ~/docker/homelab-install-script.log 2>&1 &
        spinner $!
        echo ""
        echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
        echo ""
        echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""
      }

      #Setting up a function to see if Portainer already exists from any previous installation.
      PTAINCE_CHECK ()
      {
            portainerce_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerce_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerce_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLCE
          fi
      }

      PTAINBE_CHECK ()
      {
            portainerbe_check=$( docker ps -a -f name=portainer | grep portainer 2> /dev/null )
          if [[ ! -z ${portainerbe_check} ]]; then 
            echo "A container with a name: Portainer already exists and has status: $( echo ${portainerbe_check} | awk '{ print $7 }' ), so skipping the Portainer installation."
          else
            PTAIN_FULLBE
          fi
      }

      PTAINAG_CHECK ()
      {
            portainerag_check=$( docker ps -a -f name=portainer_agent | grep portainer_agent 2> /dev/null )
          if [[ ! -z ${portainerag_check} ]]; then 
            echo "A container with a name: Portainer Agent already exists and has status: $( echo ${portainerag_check} | awk '{ print $7 }' ), so skipping the Agent installation."
          else
            PTAIN_AGNT
          fi
      }

      PTAIN_CHOICES=$(whiptail --title "Portainer Selection" --menu "Choose an option" 20 110 7 \
        "1" "Community Edition - Standard installation of Portainer's free edition" \
        "2" "Portainer Agent - Installation of just the Agent service to connect to other Portainer instances." \
        "3" "Business Edition - Installation of Portainer's Business Edition." \
        "4" "Nevermind, I don't need Portainer to be setup now." 3>&1 1>&2 2>&3)

        if [ -z "$PTAIN_CHOICES" ]; then
            echo "No option was selected, the installer will exit now."
        else
            for PTAIN_CHOICE in $PTAIN_CHOICES; do
            case "$PTAIN_CHOICE" in
            "1")
                PTAINCE_CHECK
                ;;
            "2")
                PTAINAG_CHECK
                ;;
            "3")
                PTAINBE_CHECK
                ;;
            "4")
                exit 1
                ;;
            *)
                echo "Unsupported item $PTAIN_CHOICE!" >&2
                exit 1
                ;;
            esac
            done
        fi
    }

    installNginxProxyManager()
    {
            
            echo "   Installing NGinX Proxy Manager   "
            echo ""
            # Pull the nginx proxy manager docker-compose file from github
            echo " Pulling a default NGinX Proxy Manager docker-compose.yml file."

            sudo mkdir -p docker/nginx-proxy-manager
            cd docker/nginx-proxy-manager

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/npm-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start NGinX Proxy Manager"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:81 to setup the Nginx Proxy Manager admin account."
            echo ""
            echo " The default login credentials for Nginx Proxy Manager are:"
            echo "  username: admin@example.com"
            echo "  password: changeme"
            echo ""       
            
            cd
    }

    installFilebrowser()
    {
            
            echo "       Installing Filebrowser        "            
            echo ""
            echo " Preparing to install Filebrowser"

            sudo mkdir -p docker/filebrowser
            cd docker/filebrowser

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/filebrowser-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Filebrowser"
            echo ""

            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:8083 to setup your Filebrowser instance."
            echo ""       
            
            cd
    }

    installSnapdrop()
    {
            
            echo "        Installing Snapdrop          "            
            echo ""
            echo " Preparing to install Snapdrop"

            sudo mkdir -p docker/snapdrop
            cd docker/snapdrop

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/snapdrop-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1
    
            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Snapdrop"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:82 to view your Snapdrop instance."
            echo ""  
            
            cd
    }

    installCodeserver()
    {
            
            echo "       Installing Codeserver         "            
            echo ""
            echo " Preparing to install Codeserver"

            sudo mkdir -p docker/codeserver
            cd docker/codeserver

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/codeserver-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Codeserver"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:7443 to setup your Codeserver instance."
            echo ""       
            
            cd
    }

    installDillinger()
    {
            
            echo "        Installing Dillinger         "            
            echo ""
            echo " Preparing to install Dillinger"

            sudo mkdir -p docker/dillinger
            cd docker/dillinger

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dillinger-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Dillinger"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:8085 to setup your Dillinger instance."
            echo ""
            
            cd
    }

    installCryptgeon()
    {
            
            echo "          Installing Cryptgeon         "            
            echo ""
            # Pull the cryptgeon docker-compose file from github
            echo " Preparing to install Cryptgeon"

            sudo mkdir -p docker/cryptgeon
            cd docker/cryptgeon

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/cryptgeon-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            whiptail --msgbox  --title "Input Required" "Cryptgeon uses your system's RAM to store the data and share it with full encryption. This is done with the help of Redis container.\n\nHence you need to specify a comfortable size limit (in MB) for the application to reserve in RAM." 20 110
            
            CPTGNLM=$(whiptail --inputbox --title "Size Limit" "Specify size limit in megabytes (Eg: 32):" 20 110 3>&1 1>&2 2>&3)
            
                exitstatus=$?
        
                if [ $exitstatus = 1 ]; then
                    echo ""
                    echo "No input was provided, the installer has exited."
                    echo ""
                    sleep 1s
                    exit
                fi

            (find . -type f -exec sed -i 's,SZLM,'"$(echo "$CPTGNLM"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install the application."
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:5000 to setup your Cryptgeon instance."
            echo ""       
            cd
    }
        
    installVaultwarden()
    {
            
            echo "       Installing Vaultwarden        "            
            echo ""
            echo " Preparing to install Vaultwarden"

            sudo mkdir -p docker/vaultwarden
            cd docker/vaultwarden

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/vaultwarden-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Vaultwarden"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:8062 to view your Vaultwarden instance."
            echo ""      
            
            cd
    }

    installUptimeK()
    {
            
            echo "       Installing Uptime Kuma        "            
            echo ""
            echo " Preparing to install Uptime Kuma"

            sudo mkdir -p docker/uptimekuma
            cd docker/uptimekuma

            (curl -o kuma_install.sh http://git.kuma.pet/install.sh && sudo bash kuma_install.sh) >> ~/docker/homelab-install-script.log 2>&1 &

            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:3001 to view your Uptime Kuma instance."
            echo ""   
            
            cd
    }

    installTrilium()
    {
            
            echo "      Installing Trilium Notes       "            
            echo ""
            echo " Preparing to install Trilium Notes"

            sudo mkdir -p docker/trilium
            cd docker/trilium

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/trilium-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Trilium Notes"
            echo ""
            echo ""

            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:85 to view your Trilium Notes instance."
            echo ""   
            
            cd
    }

    #    if [[ "$RLLY" == [yY] ]]; then
    #        
    #        echo "         Installing Rallly           "
    #        
    #        echo ""
    #        echo "    1. Preparing to install Rallly"
    #
    #        mkdir -p docker/rallly
    #        cd docker/rallly
    #
    #        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker/homelab-install-script.log 2>&1
    #
    #        echo "    2. Running the docker-compose.yml to install Rallly"
    #        echo ""
    #        echo ""
    #
    #        (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
    #        ## Show a spinner for activity progress
    #        pid=$! # Process Id of the previous running command
    #        spin='-\|/'
    #        i=0
    #        while kill -0 $pid 2>/dev/null
    #        do
    #            i=$(( (i+1) %4 ))
    #            printf "\r${spin:$i:1}"
    #            sleep .1
    #        done
    #        printf "\r"

    #        echo ""
    #        echo ""
    #        echo "    Go to http://${LOCALIP}:86"
    #        echo "      to view your Rallly instance."
    #        echo ""
    #        echo ""       
    #        
    #        cd
    #    fi

    installPinry()
    {
            
            echo "         Installing Pinry            "            
            echo ""
            echo " Preparing to install Pinry"

            sudo mkdir -p docker/pinry
            cd docker/pinry

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/pinry_docker_compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1  

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Pinry"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!

            echo ""
            echo " Go to http://${LOCALIP}:8981 to view your Pinry instance."
            echo ""   
            
            cd
    }

    #    if [[ "$VKNJA" == [yY] ]]; then
    #        
    #        echo "        Installing Vikunja           "
    #        
    #        echo ""
    #        echo "    1. Preparing to install Vikunja"
    #
    #        mkdir -p docker/vikunja
    #        cd docker/vikunja
    #
    #        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker/homelab-install-script.log 2>&1
    #
    #        echo "    2. Running the docker-compose.yml to install Vikunja"
    #        echo ""
    #        echo ""
    #
    #        (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
    #        ## Show a spinner for activity progress
    #        pid=$! # Process Id of the previous running command
    #        spin='-\|/'
    #        i=0
    #        while kill -0 $pid 2>/dev/null
    #        do
    #            i=$(( (i+1) %4 ))
    #            printf "\r${spin:$i:1}"
    #            sleep .1
    #        done
    #        printf "\r"

    #        echo ""
    #        echo ""
    #        echo "    Go to http://${LOCALIP}:87 "
    #        echo "      to view your Vikunja instance."
    #        echo ""
    #        echo ""       
    #        
    #        cd
    #    fi

    #    if [[ "$POLR" == [yY] ]]; then
    #        
    #        echo "        Installing POLR           "
    #        
    #        echo ""
    #        echo "    1. Preparing to install POLR"
    #
    #        mkdir -p docker/polr
    #        cd docker/polr
    #
    #        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker/homelab-install-script.log 2>&1

    #        echo "    2. Running the docker-compose.yml to install POLR"
    #        echo ""
    #        echo ""

    #        (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
    #        ## Show a spinner for activity progress
    #        pid=$! # Process Id of the previous running command
    #        spin='-\|/'
    #        i=0
    #        while kill -0 $pid 2>/dev/null
    #        do
    #            i=$(( (i+1) %4 ))
    #            printf "\r${spin:$i:1}"
    #            sleep .1
    #        done
    #        printf "\r"

    #        echo ""
    #        echo ""
    #        echo "    Go to http://${LOCALIP}:88 "
    #        echo "      to view your POLR instance."
    #        echo ""
    #        echo ""       
    #        
    #        cd
    #    fi

    installWhoogle()
    {
            
            echo "        Installing Whoogle           "            
            echo ""
            echo " Preparing to install Whoogle"

            sudo mkdir -p docker/whoogle
            cd docker/whoogle

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/whoogle-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1   

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Whoogle"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8082 to view your Whoogle instance."
            echo ""         
            cd
    }

    installWikiJS()
    {
            
            echo "        Installing Wiki.Js           "
            echo ""
            echo " Preparing to install Wiki.Js"

            sudo mkdir -p docker/wikijs
            cd docker/wikijs

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/wikijs-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1  

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install Wiki.Js"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:8084 to view your Wiki.Js instance."
            echo ""     
            
            cd
    }

    installJDownloader()
    {
            
            echo "      Installing JDownloader         "     
            echo ""
            echo " Preparing to install JDownloader"

            sudo mkdir -p docker/jdownloader
            cd docker/jdownloader

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/jdown-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install JDownloader"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:5800 to view your JDownloader instance."
            echo ""
            
            cd
    }

    installDashy()
    {
            
            echo "          Installing Dashy           "           
            echo ""
            echo " Preparing to install Dashy"

            sudo mkdir -p docker/dashy
            sudo mkdir -p docker/dashy/public
            sudo mkdir -p docker/dashy/icons
            
            cd docker/dashy/icons

            (sudo git clone https://github.com/walkxcode/dashboard-icons.git) >> ~/docker/homelab-install-script.log 2>&1

            cd 

            cd docker/dashy/public
            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dashy-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1
    
            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            
            echo " Running the docker-compose.yml to install Dashy"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Go to http://${LOCALIP}:4000 to setup your Dashy instance."
            echo ""       
            
            cd
    }

    installWatchT()
    {
            
            echo "       Installing Watchtower        "         
            echo ""
            # Pull the Watchtower docker-compose file from github
            echo " Pulling a default Watchtower docker-compose.yml file."

            sudo mkdir -p docker/watchtower
            cd docker/watchtower

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/watchtower-docker-compose.yml -o docker-compose.yml) >> ~/docker/homelab-install-script.log 2>&1

            (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~/docker/homelab-install-script.log 2>&1

            (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1
            (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~/docker/homelab-install-script.log 2>&1

            echo " Running the docker-compose.yml to install and start Watchtower"
            echo ""
            (sudo docker compose up -d) >> ~/docker/homelab-install-script.log 2>&1 &
            spinner $!
            echo ""
            echo " Once installed, the Watchtower instance will automatically start checking for updates to the applications once every 24 hours."
            echo ""  
            cd
    }

  echo ""
  echo ""
  echo "   ____                           _      _                    ";
  echo "  / ___| ___ _ __   ___ _ __ __ _| |    / \   _ __  _ __  ___ ";
  echo " | |  _ / _ | '_ \ / _ | '__/ _\'| |   / _ \ | '_ \| '_ \/ __|";
  echo " | |_| |  __| | | |  __| | | (_| | |  / ___ \| |_) | |_) \__ \'";
  echo "  \____|\___|_| |_|\___|_|  \__,_|_| /_/   \_| .__/| .__/|___/";
  echo "                                             |_|   |_|        ";
  echo ""
  echo ""

    # Installing Docker, Docker Compose.
    DockCheck

    whiptail --msgbox --title "General Apps Installation" "Now, you will be shown a list with a short description of various applications supported by me(as of now)." 20 110     
    whiptail --msgbox --title "Installation Path" "Before that, please provide the path of the directory where you want the applications to be installed.\n\n This is required for proper configuration.\n\nIf the folder doesn't exist, it will be created for future use. " 20 110
    whiptail --msgbox --title "Installation Path" "Provide the path in the format of '/data/path' without the trailing '/' Eg: /docker/apps (or) /home/$USER/apps etc. " 20 110
    
    INSPTH=$(whiptail --inputbox --title "Installation Path" "Specify the path to install the applications:" 20 110 3>&1 1>&2 2>&3)
    
    exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
    
        if [[ -d "$INSPTH" ]]; then
            sleep 1s
        else    
            (sudo mkdir "$INSPTH" -p)
        fi
       
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi    
    echo ""
    echo ""

  APP_CHOICES=$(whiptail --separate-output --checklist "Choose options" 18 55 10 \
    "1" "Nginx Proxy manager        " OFF \
    "2" "File Browser       " OFF \
    "3" "Snapdrop       " OFF \
    "4" "Code Server        " OFF \
    "5" "Dillinger        " OFF \
    "6" "Cryptgeon        " OFF \
    "7" "Vaultwarden        " OFF \
    "8" "Uptime Kuma        " OFF \
    "9" "Trilium Notes        " OFF \
    "10" "Pinry       " OFF \
    "11" "Whoogle       " OFF \
    "12" "Wiki.Js       " OFF \
    "13" "JDownloader       " OFF \
    "14" "Dashy       " OFF\
    "15" "Watchtower        " OFF 3>&1 1>&2 2>&3)

    if [ $exitstatus = 0 ]; then
        for APP_CHOICE in $APP_CHOICES; do
            case "$APP_CHOICE" in
                "1")
                    installNginxProxyManager
                    ;;
                "2")
                    installFilebrowser
                    ;;
                "3")
                    installSnapdrop
                    ;;
                "4")
                    installCodeserver
                    ;;
                "5")
                    installDillinger
                    ;;
                "6")
                    installCryptgeon
                    ;;
                "7")
                    installVaultwarden
                    ;;
                "8")
                    installUptimeK
                    ;;
                "9")
                    installTrilium
                    ;;
                "10")
                    installPinry
                    ;;
                "11")
                    installWhoogle
                    ;;
                "12")
                    installWikiJS
                    ;;
                "13")
                    installJDownloader
                    ;;
                "14")
                    installDashy
                    ;;
                "15")
                    installWatchT
                    ;;
                *)
                    echo "Unsupported item $APP_CHOICE!" >&2
                    exit 1
                    ;;
            esac
        done

    else
        echo ""
        echo "No option was selected, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

  # Installing portainer for Docker GUI Management
  installportainer
  cd
  exit 1

}

######Start of the Script######
clear
# Caching sudo access for install completion
sudo true
echo ""
echo ""
echo "  _   _  _  _    _                    _           _   _                          _         _      ";
echo " | | | || || |_ (_) _ __ ___    __ _ | |_  ___   | | | |  ___   _ __ ___    ___ | |  __ _ | |__   ";
echo " | | | || || __|| || '_ \  _ \ / _  \| |  / _ \  | |_| | / _ \ | '_ \  _ \ / _ \| | / _  \| |_ \  ";
echo " | |_| || || |_ | || | | | | || (_| || |_|  __/  |  _  || (_) || | | | | ||  __/| || (_| || |_) | ";
echo "  \___/ |_| \__||_||_| |_| |_| \__,_| \__|\___|  |_| |_| \___/ |_| |_| |_| \___||_| \__,_||_.__/  ";
echo "                                  ____         _                                                  ";
echo "                                 / ___|   ___ | |_  _   _  _ __                                   ";
echo "                                 \___ \  / _ \| __|| | | || '_ \                                  ";
echo "                                  ___) ||  __/| |_ | |_| || |_) |                                 ";
echo "                                 |____/  \___| \__| \__,_|| .__/                                  ";
echo "                                                          |_|                                     ";
echo ""
echo ""
echo ""
if [[ ! -d ~/docker ]]; then 
    (sudo mkdir ~/docker)
fi

(sudo yum install -y bind-utils whiptail) > ~/docker/homelab-install-script.log
# Display the welcome dialog
whiptail --msgbox --backtitle "Welcome" --title "Ultimate Homelab Setup" "This installer will set up Docker, and a set of different self-hostable applications!" 20 110

# Explain the need for a static address
whiptail --msgbox --backtitle "Documentation" --title "Read the Docs" "This installer has support for multiple applications and some are provided as packages.

There are several package specific instructions and it is strongly recommended to go through the documentation over at GitHub prior to starting this installation.

Please view the documentation at the following URL: https://github.com/Jayavel-S/homelab-ultimate/tree/main/docs" 20 110

username=$(whiptail --inputbox "Welcome to the interactive and customizable Homelab Setup. 

Please enter your name:" 20 110 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
        whiptail --msgbox  "It's nice to interact with you $username. Thank you for choosing to install Docker with this script.\n\nMost of the applications uses basic authentication. Hence you'd need to provide your desired Username and Password for the applications and databases to be setup properly." 20 110
    else
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

WPUNAME=$(whiptail --inputbox "Provide your desired Username:" 20 110 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 1 ]; then
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

WPPSWD=$(whiptail --passwordbox "Provide a strong password:" 20 110 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 1 ]; then
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

LOCALIP=$(ip a | grep "scope global" | head -1 | awk '{print $2}' | sed 's|/.*||') >> ~/docker/homelab-install-script.log
CLOUDIP=$(wget -qO - https://api.ipify.org) >> ~/docker/homelab-install-script.log
_uid="$(id -u)">> ~/docker/homelab-install-script.log
_gid="$(id -g)">> ~/docker/homelab-install-script.log

whiptail --msgbox  "Some applications require you to provide your Time Zone for proper configuration.

If you are not familiar with this, you can visit http://www.timezoneconverter.com/cgi-bin/findzone.tzc and select your country." 20 110

WPTZ=$(whiptail --inputbox "Provide the timezone in your location. Eg: Asia/Kolkata" 20 110 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 1 ]; then
        echo ""
        echo "No input was provided, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

whiptail --msgbox  "Thank you for the input. Now, you can choose from a list of options as detailed in the Readme page in Github." 20 110

MENU_CHOICES=$(whiptail --title "Package Selection" --menu "Choose an option" 20 110 8 \
  "1" "Basic Package - Just install Docker, Docker-Compose and Portainer." \
  "2" "Nextcloud Package - Install the Nextcloud AIO instance." \
  "3" "Website Package - Install WordPress, Matomo Analytics and Nginx Proxy Manager." \
  "4" "Media Server Package - Set up applications that helps in managing home media." \
  "5" "General Apps Package - A collection of different applications that can be self-hosted." 3>&1 1>&2 2>&3)

exitstatus=$?
      
    if [ $exitstatus = 0 ]; then
        for MENU_CHOICE in $MENU_CHOICES; do
            case "$MENU_CHOICE" in
                "1")
                installDock
                ;;
                "2")
                installNxtCld
                ;;
                "3")
                installWP
                ;;
                "4")
                installMSP
                ;;
                "5")
                installApps
                ;;
                *)
                echo "Unsupported item $MENU_CHOICE!" >&2
                exit 1
                ;;
            esac
        done

    else
        echo ""
        echo "No option was selected, the installer has exited."
        echo ""
        sleep 1s
        exit
    fi

echo "Installation Completed"
