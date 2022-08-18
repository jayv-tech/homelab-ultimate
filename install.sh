#!/bin/bash

installDock()
{
    clear

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
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
        sleep 3s

        echo " Okay $username, let's start by installing the system updates. This could take a while."
        (sudo apt update && sudo apt upgrade -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The updates are done. Now the system is installing some prerequisite packages."
        sleep 2s
        echo ""
        (sudo apt install curl wget git -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
        sleep 2s
        (curl -fsSL https://get.docker.com | sh) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The installation of Docker Engine is complete and the version installed was - "
        DOCKERV=$(docker -v)
        echo "    "${DOCKERV}
        sleep 3s
        echo ""
        echo " Starting the Docker Service"
        (sudo systemctl docker start) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        echo " Adding this user account to the docker group for getting necessary permissions."
        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker appears to be already installed and running in this system."
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo " The script will now install the stable version of Docker-Compose."
        sleep 2s
        (sudo apt install docker-compose -y) >> ~docker/homelab-install-script.log 2>&1     
        echo ""
        echo " The installation of Docker-Compose is also done. The version installed was - " 
        DOCKCOMPV=$(docker-compose --version)
        echo "   "${DOCKCOMPV}
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker-compose appears to be already installed."
        echo ""
    fi
        # Enabling docker to start automatically on hardware reboot
        echo " Enabling the Docker service to start automatically on boot."
        (sudo systemctl enable docker) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 1s
        # Installing portainer for Docker GUI Management
        echo " Finishing up by installing Portainer's community edition image."
        (sudo docker volume create portainer_data) >> ~docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
echo ""
echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker and Portainer instance."
echo ""
echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
echo ""
echo " That's it $username, the installation of Docker, Docker-Compose, and Portainer is over. Thank you for using the script." 
echo ""
echo ""
sleep 1s
#LocalIP - ip a | grep "scope global" | head -1 | awk '{print $2}' | sed 's|/.*||'
#CloudIP - host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}'
    exit 1
}

installNxtCld()
{
    clear

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

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

#### Try to check whether docker is installed and running - don't prompt if it is
if [[ "$ISACT" != "active" ]]; then
        echo " Okay $username, let's start by installing the system updates. This could take a while."
        (sudo apt update && sudo apt upgrade -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The updates are done. Now the system is installing some prerequisite packages."
        sleep 2s
        echo ""
        (sudo apt install curl wget git -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
        sleep 2s
        (curl -fsSL https://get.docker.com | sh) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The installation of Docker Engine is complete and the version installed was - "
        DOCKERV=$(docker -v)
        echo "    "${DOCKERV}
        sleep 3s
        echo ""
        echo " Starting the Docker Service"
        (sudo systemctl docker start) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        echo " Adding this user account to the docker group for getting necessary permissions."
        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker appears to be already installed and running in this system."
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo " The script will now install the stable version of Docker-Compose."
        sleep 2s
        (sudo apt install docker-compose -y) >> ~docker/homelab-install-script.log 2>&1     
        echo ""
        echo " The installation of Docker-Compose is also done. The version installed was - " 
        DOCKCOMPV=$(docker-compose --version)
        echo "   "${DOCKCOMPV}
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker-compose appears to be already installed."
        echo ""
    fi
        # Enabling docker to start automatically on hardware reboot
        echo " Enabling the Docker service to start automatically on boot."
        (sudo systemctl enable docker) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 1s
        # Installing portainer for Docker GUI Management
        echo " Installing Portainer's community edition image."
        (sudo docker volume create portainer_data) >> ~docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Installing Nextcloud AIO Image."
        echo ""
        # Pull the Nextcloud docker-compose file from github
        echo " Pulling a default Nextcloud docker-compose.yml file."
        sudo mkdir -p docker/nextcloud
        cd docker/nextcloud
        echo ""
        echo " Now you need to provide the path of the directory to store your files and folders in Nextcloud."
        echo ""
        echo " Provide the path in the format of '/data/path' without the trailing '/'. If the folder doesn't exist, it will automatically be created."
        echo " Eg: /home/${USER}/data (or) /mnt/data/nxtcld "
        echo ""
        read -rp " Specify the path to store Nextcloud data on: " NXTPTH
        sudo mkdir "$NXTPTH" -p
        sleep 1s
        sudo chown -R 33:0 "$NXTPTH"
        sudo chmod -R 750 "$NXTPTH"
        sleep 1s
        echo ""
        echo " Running the docker commands to install and start Nextcloud instance."
        echo ""
        
        ARCH=$( (uname -m ) 2>&1 )

        if [[ "$ARCH" == "x86_64" || "$ARCH" == "i386" || "$ARCH" == "i486" || "$ARCH" == "i586" || "$ARCH" == "i686" ]]; then

        sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudx86-docker-compose.yml -o docker-compose.yml >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        
        #(sudo docker run -d --name nextcloud-aio-mastercontainer --restart always -p 80:80 -p 8080:8080 -p 8443:8443 -e NEXTCLOUD_DATADIR=$NXTPTH --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest) >> ~docker/homelab-install-script.log 2>&1 &
        
        sleep 3s

        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        fi

        if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm" || "$ARCH" == "arm64" || "$ARCH" == "armv8" ]]; then

        sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudarm64-docker-compose.yml -o docker-compose.yml >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        #(sudo docker run -d --name nextcloud-aio-mastercontainer --restart always -p 80:80 -p 8080:8080 -p 8443:8443 -e NEXTCLOUD_DATADIR=$NXTPTH --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest-arm64) >> ~docker/homelab-install-script.log 2>&1 &
        
        sleep 3s

        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        fi

    echo ""
    echo " Navigate to https://${LOCALIP}:8080 to start the Nextcloud AIO setup"
    echo ""
    echo " Nextcloud recommends setting up the instance with a domain name and the AIO container is configured to get SSL certificates automatically."
    echo ""
    echo " That's it $username, the installation of Nextcloud is complete and you can now start using your own storage cloud." 
    echo ""
    echo ""
sleep 1s
    cd
    exit 1

}

installMSP()
{
    clear
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
echo " Please provide the path of the directory where you want the applications to be installed and the media files reside. This is required for proper configuration."
echo " If there are no media files presently, the folders will be created for future use. "
echo ""
echo " Provide the path in the format of '/data/path' without the trailing '/'"
echo " Eg: /docker/apps (or) /home/$USER/movies etc. "
echo ""
echo ""
        read -rp " Specify the path to install the applications: " INSPTH
        sudo mkdir "$INSPTH" -p
        sleep 1s
        echo ""
        read -rp " Specify the path to Movies: " MOVPTH
        sudo mkdir "$MOVPTH" -p
        sleep 1s
        echo ""
        read -rp " Specify the path to TV Shows: " SHWPTH
        sudo mkdir "$SHWPTH" -p
        sleep 1s
        echo ""
        read -rp " Specify the path to Downloads: " DWNPTH
        sudo mkdir "$DWNPTH" -p
        sleep 1s
        echo ""
echo " Thank you for the input. Just a few more choices left to make."
echo "" 
echo " When prompted, please select 'y' for each item you would like to install."
echo ""
sleep 1s
echo ""
echo " Plex is the backbone for organizing and streaming the media that we have in home."
read -rp "Install Plex? (y/n): " PLX
sleep 1s
echo ""
echo " Tautulli monitors the Plex activity and collect the statistics "
read -rp "Install Tautulli? (y/n): " TLI
sleep 1s
echo ""
echo " Sonarr is a collection manager for TV Shows and Web Series "
read -rp "Install Sonarr? (y/n): " SNR
sleep 1s
echo ""
echo " Radarr is a collection manager for Movies "
read -rp "Install Radarr? (y/n): " RDR
sleep 1s
echo ""
echo " Sabnzbd is a USENET client/downloader "
read -rp "Install Sabnzbd? (y/n): " SZBD
sleep 1s
echo ""
echo " Deluge is a torrent tracker and downloader "
read -rp "Install Deluge? (y/n): " DLG
sleep 1s
echo ""
echo " Overseerr is a media discovery and request manager for Plex "
read -rp "Install Overseerr? (y/n): " OVSR
sleep 1s
echo ""
echo " Jackett is a bridge for apps listed above to communicate with the torrent indexers of your choice "
read -rp "Install Jackett? (y/n): " JKT
sleep 1s
echo ""
echo " Watchtower checks for and updates all the docker applications on a regular basis."
read -rp "Install Watchtower? (y/n): " WTR
sleep 1s
echo ""
echo ""
            echo " Okay $username, I got the list of apps to install. Let's start by installing the system updates."
            echo " Please note that this could take a while."
            echo ""
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    if [[ "$ISACT" != "active" ]]; then        
            (sudo apt update && sudo apt upgrade -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The updates are done. Now the system is installing some prerequisite packages."
        sleep 2s
        echo ""
        (sudo apt install curl wget git -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
        sleep 2s
        (curl -fsSL https://get.docker.com | sh) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The installation of Docker Engine is complete and the version installed was - "
        DOCKERV=$(docker -v)
        echo "    "${DOCKERV}
        sleep 3s
        echo ""
        echo " Starting the Docker Service"
        (sudo systemctl docker start) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        echo " Adding this user account to the docker group for getting necessary permissions."
        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker appears to be already installed and running in this system."
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo " The script will now install the stable version of Docker-Compose."
        sleep 2s
        (sudo apt install docker-compose -y) >> ~docker/homelab-install-script.log 2>&1     
        echo ""
        echo " The installation of Docker-Compose is also done. The version installed was - " 
        DOCKCOMPV=$(docker-compose --version)
        echo "   "${DOCKCOMPV}
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker-compose appears to be already installed."
        echo ""
    fi
        # Enabling docker to start automatically on hardware reboot
        echo " Enabling the Docker service to start automatically on boot."
        (sudo systemctl enable docker) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 1s

    if [[ "$PLX" == [yY] ]]; then
        echo "##########################################"
        echo "###          Installing Plex           ###"
        echo "##########################################"
    
        # Pull the plex docker-compose file from github
        echo " Pulling a default Plex docker-compose.yml file."

        sudo mkdir -p docker/plex
        cd docker/plex
        
        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/plex-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Plex Media Server"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo "" 
        echo " Go to http://${LOCALIP}:32400/web/index.html to setup your Plex account and the instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$TLI" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Tautulli         ###"
        echo "##########################################"
    
        # Pull the tautulli docker-compose file from github
        echo " Pulling a default tautulli docker-compose.yml file."

        sudo mkdir -p docker/tautulli
        cd docker/tautulli

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/tautulli-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Tautulli"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8181 to setup your Tautulli with you Plex account."
        echo ""       
        sleep 3s
        cd
    fi 

    if [[ "$SNR" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Sonarr          ###"
        echo "##########################################"
    
        # Pull the Sonarr docker-compose file from github
        echo " Pulling a default Sonarr docker-compose.yml file."

        sudo mkdir -p docker/sonarr
        cd docker/sonarr

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sonarr-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Sonarr"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8989 to setup your Sonarr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$RDR" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Radarr          ###"
        echo "##########################################"
    
        # Pull the Radarr docker-compose file from github
        echo " Pulling a default Radarr docker-compose.yml file."

        sudo mkdir -p docker/radarr
        cd docker/radarr

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/radarr-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Radarr"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:7878 to setup your Radarr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$SZBD" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Sabnzbd          ###"
        echo "##########################################"
    
        # Pull the Sabnzbd docker-compose file from github
        echo " Pulling a default Sabnzbd docker-compose.yml file."

        sudo mkdir -p docker/sabnzbd
        cd docker/sabnzbd

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sabnzbd-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Sabnzbd"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8080 to setup your Sabnzbd instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$DLG" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Deluge          ###"
        echo "##########################################"
    
        # Pull the Deluge docker-compose file from github
        echo " Pulling a default Deluge docker-compose.yml file."

        sudo mkdir -p docker/deluge
        cd docker/deluge

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/deluge-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Deluge"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8112 to setup Deluge instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$OVSR" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Overseerr        ###"
        echo "##########################################"
    
        # Pull the Overseerr docker-compose file from github
        echo " Pulling a default Overseerr docker-compose.yml file."

        sudo mkdir -p docker/overseerr
        cd docker/overseerr

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/overseerr-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Overseerr"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:5055 to setup the Overseerr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$JKT" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Jackett         ###"
        echo "##########################################"
    
        # Pull the Jackett docker-compose file from github
        echo " Pulling a default Jackett docker-compose.yml file."

        sudo mkdir -p docker/jackett
        cd docker/jackett

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/jackett-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s
        
        echo " Running the docker-compose.yml to install and start Jackett"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:9117 to setup the Jackett instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$WTR" == [yY] ]]; then
        echo "##########################################"
        echo "###       Installing Watchtower        ###"
        echo "##########################################"
    
        # Pull the Watchtower docker-compose file from github
        echo " Pulling a default Watchtower docker-compose.yml file."

        sudo mkdir -p docker/watchtower
        cd docker/watchtower

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/watchtower-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start Watchtower"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Once installed, the Watchtower instance will automatically start checking for updates to the applications once every 24 hours."
        echo ""       
        sleep 3s
        cd
    fi

        # Installing portainer for Docker GUI Management
        echo " Finishing up by installing Portainer's community edition image."
        (sudo docker volume create portainer_data) >> ~docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
echo ""
echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker instance."
echo ""
echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
echo ""
echo " That's it $username, the installation of Media Server Package is over. Thank you for using the script." 
echo ""
echo ""
sleep 1s

exit 1

}


installWP()
{
    clear    
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
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        echo " Okay $username, let's install Docker and Wordpress with a MySQL Database, and also Matomo."
        echo ""
        echo " Updating the system prior to starting the installation."
            (sudo apt update && sudo apt upgrade -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The updates are done. Now the system is installing some prerequisite packages."
        sleep 2s
        echo ""
        (sudo apt install curl wget git -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
        sleep 2s
        (curl -fsSL https://get.docker.com | sh) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The installation of Docker Engine is complete and the version installed was - "
        DOCKERV=$(docker -v)
        echo "    "${DOCKERV}
        sleep 3s
        echo ""
        echo " Starting the Docker Service"
        (sudo systemctl docker start) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        echo " Adding this user account to the docker group for getting necessary permissions."
        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker appears to be already installed and running in this system."
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo " The script will now install the stable version of Docker-Compose."
        sleep 2s
        (sudo apt install docker-compose -y) >> ~docker/homelab-install-script.log 2>&1     
        echo ""
        echo " The installation of Docker-Compose is also done. The version installed was - " 
        DOCKCOMPV=$(docker-compose --version)
        echo "   "${DOCKCOMPV}
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker-compose appears to be already installed."
        echo ""
    fi
        # Enabling docker to start automatically on hardware reboot
        echo " Enabling the Docker service to start automatically on boot."
        (sudo systemctl enable docker) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 1s
        # Installing portainer for Docker GUI Management
        echo " Installing Portainer's community edition image."
        (sudo docker volume create portainer_data) >> ~docker/homelab-install-script.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"

        echo " In order to proceed with the Website Package setup, you need to provide some additional details. "
        echo " Please note that these values are not editable later on."
        echo ""
        echo " We can set a memory limit for the instance to hold. This has to be provided in megabytes."
        echo ""
        read -rp "Specify a comfortable memory limit (Eg: 64 or 128 etc.): " WPMEM
        echo ""
        echo " The maximum file size limit needs to be set. This is to ensure that the uploads are done properly to your instance."
        echo ""
        read -rp "Specify a comfortable file size limit (Eg: 128 or 256 etc.): " WPFLM
        echo ""
        sleep 1s
        echo ""
        echo ""
        echo " Thank you for the input, the installation is resuming now."
        echo ""
        sleep 1s
        echo " Installing Matomo (It is a self-hosted analytics platform that integrates well with Wordpress)."
        sudo mkdir -p docker/wordpress
        cd docker/wordpress

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/wordpress-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/uploads.ini -o uploads.ini) >> ~docker/homelab-install-script.log 2>&1

        sleep 3s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,mem_lm,'"$(echo "$WPMEM"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,file_lm,'"$(echo "$WPFLM"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
                
        sleep 30s
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        sleep 3s
        cd

        echo " Installing Matomo (It is a self-hosted analytics platform that integrates well with Wordpress)."

        # Pull the Matomo docker-compose file from github
        sudo mkdir -p docker/matomo
        cd docker/matomo

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/matomo-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1     
        
        sleep 1s

        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8384 to view your Matomo instance."
        echo ""
        sleep 3s

        echo " Installing NGinX Proxy Manager."

        sudo mkdir -p docker/nginx-proxy-manager
        cd docker/nginx-proxy-manager

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/npm-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

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
        sleep 3s
        cd

    exit 1 

}

installApps()
{
    clear
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


echo " Now, you will be shown a short description of various applications supported by me (as of now)."
echo ""       
echo " Before that, please provide the path of the directory where you want the applications to be installed. This is required for proper configuration."
echo " If the folder doesn't exist, it will be created for future use. "
echo ""
echo " Provide the path in the format of '/data/path' without the trailing '/'"
echo " Eg: /docker/apps (or) /home/$USER/apps etc. "
echo ""
echo ""
        read -rp " Specify the path to install the applications: " INSPTH
        sudo mkdir "$INSPTH" -p
        sleep 1s
        echo ""
echo ""
echo " Now, lets choose what applications to install. When prompted, please select 'y' for each item you would like to install."

echo ""
echo " Nginx Proxy manager is the application that lets users to expose their self-hosted applications and make them accessible via a domain name."  
read -rp "Install Nginx Proxy Manager? (y/n): " NPM
sleep 1s
echo ""  
echo " File Browser is a software where you can install it on a server, direct it to a path and then access your files through a nice web interface."
read -rp "Install Filebrowser? (y/n): " FLBW
sleep 1s
echo ""
echo " Snapdrop is a local file sharing server accessible from your browser, kind of like Airdrop."
read -rp "Install Snapdrop? (y/n): " SNPDP
sleep 1s
echo ""
echo " Code Server lets you run VS Code on any machine anywhere and access it in the browser."
read -rp "Install Code Server? (y/n): " CDESRVR
sleep 1s
echo ""
echo " Dillinger is an online cloud-enabled, HTML5, buzzword-filled Markdown editor."
read -rp "Install Dillinger? (y/n): " DLNGR
sleep 1s
echo ""
echo " Cryptgeon is a secure, open source note or file sharing service inspired by PrivNote"
read -rp "Install Cryptgeon? (y/n): " CPTGN
sleep 1s
echo ""
echo " Vaultwarden is a strong password manager that supports many features and integrates with Bitwarden API."
read -rp "Install Vaultwarden? (y/n): " VLWDN
sleep 1s
echo ""
echo " Uptime Kuma is a self-hosted monitoring tool like Uptime Robot."
read -rp "Install Uptime Kuma? (y/n): " UPKMA
sleep 1s
echo ""
echo " Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases."
read -rp "Install Trilium Notes? (y/n): " TLMNTS
sleep 1s
echo ""
#echo " Rallly is a Self-hostable doodle poll alternative. Find the best date for a meeting with your colleagues or friends without the back and forth emails."
#read -rp "Install Rallly? (y/n): " RLLY
#sleep 1s
#echo ""
echo " Pinry is a a tiling image board system for people who want to save, tag, and share images, videos and webpages in an easy to skim through format."
read -rp "Install Pinry? (y/n): " PNRY
sleep 1s
echo ""
#echo "Vikunja is an open-source, self-hostable to-do app to organize everything, on all platforms. "
#read -rp "Install Vikunja? (y/n): " VKNJA
#sleep 1s
#echo ""
#echo "Polr is a quick, modern, and open-source link shortener. It allows you to host your own URL shortener, and to brand your URLs. "
#    read -rp "Install Polr? (y/n): " POLR
#    sleep 1s
#echo ""
echo " Whoogle lets you get Google search results, but without any ads, javascript, AMP links, cookies, or IP address tracking. "
read -rp "Install Whoogle? (y/n): " WGLE
sleep 1s
echo ""
echo " Wiki.Js The most powerful and extensible open source Wiki software"
read -rp "Install Wiki.Js? (y/n): " WJS
sleep 1s
echo ""
echo " JDownloader is a free, open-source download management tool. "
read -rp "Install JDownloader? (y/n): " JDWN
sleep 1s
echo ""
echo " Dashy is an open source, highly customizable, easy to use, privacy-respecting dashboard app."
read -rp "Install Dashy? (y/n): " DASHY
sleep 1s
echo ""
echo ""

echo " Okay $username, I've taken the list of what apps to install. Let's start by installing the system updates."
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
            (sudo apt update && sudo apt upgrade -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The updates are done. Now the system is installing some prerequisite packages."
        sleep 2s
        echo ""
        (sudo apt install curl wget git -y) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " Now the installation of Docker Engine begins. Please be patient as this could take a while."
        sleep 2s
        (curl -fsSL https://get.docker.com | sh) >> ~docker/homelab-install-script.log 2>&1 &
            ## Show a spinner for activity progress
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
        echo ""
        echo " The installation of Docker Engine is complete and the version installed was - "
        DOCKERV=$(docker -v)
        echo "    "${DOCKERV}
        sleep 3s
        echo ""
        echo " Starting the Docker Service"
        (sudo systemctl docker start) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        echo " Adding this user account to the docker group for getting necessary permissions."
        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker appears to be already installed and running in this system."
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo " The script will now install the stable version of Docker-Compose."
        sleep 2s
        (sudo apt install docker-compose -y) >> ~docker/homelab-install-script.log 2>&1     
        echo ""
        echo " The installation of Docker-Compose is also done. The version installed was - " 
        DOCKCOMPV=$(docker-compose --version)
        echo "   "${DOCKCOMPV}
        echo ""
        sleep 3s
    else
        echo ""
        echo " Docker-compose appears to be already installed."
        echo ""
    fi
        # Enabling docker to start automatically on hardware reboot
        echo " Enabling the Docker service to start automatically on boot."
        (sudo systemctl enable docker) >> ~docker/homelab-install-script.log 2>&1
        echo ""
        sleep 1s
        cd

    if [[ "$NPM" == [yY] ]]; then
        echo "##########################################"
        echo "###     Install Nginx Proxy Manager    ###"
        echo "##########################################"
    
        # Pull the nginx proxy manager docker-compose file from github
        echo " Pulling a default NGinX Proxy Manager docker-compose.yml file."

        sudo mkdir -p docker/nginx-proxy-manager
        cd docker/nginx-proxy-manager

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/npm-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install and start NGinX Proxy Manager"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:81 to setup the Nginx Proxy Manager admin account."
        echo ""
        echo " The default login credentials for Nginx Proxy Manager are:"
        echo "  username: admin@example.com"
        echo "  password: changeme"
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$FLBW" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Filebrowser        ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Filebrowser"

        sudo mkdir -p docker/filebrowser
        cd docker/filebrowser

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/filebrowser-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Filebrowser"
        echo ""

        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:8083 to setup your Filebrowser instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$SNPDP" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Snapdrop          ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Snapdrop"

        sudo mkdir -p docker/snapdrop
        cd docker/snapdrop

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/snapdrop-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Snapdrop"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:82 to view your Snapdrop instance."
        echo ""  
        sleep 3s
        cd
    fi

    if [[ "$CDESRVR" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Codeserver         ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Codeserver"

        sudo mkdir -p docker/codeserver
        cd docker/codeserver

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/codeserver-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Codeserver"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:7443 to setup your Codeserver instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$DLNGR" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Dillinger         ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Dillinger"

        sudo mkdir -p docker/dillinger
        cd docker/dillinger

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dillinger-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Dillinger"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:8085 to setup your Dillinger instance."
        echo ""
        sleep 3s
        cd
    fi

    if [[ "$CPTGN" == [yY] ]]; then
        echo "##########################################"
        echo "###          Install Cryptgeon         ###"
        echo "##########################################"
    
        # Pull the cryptgeon docker-compose file from github
        echo " Preparing to install Cryptgeon"

        sudo mkdir -p docker/cryptgeon
        cd docker/cryptgeon

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/cryptgeon-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        echo " Cryptgeon uses your system's RAM to store the data and share it with full encryption. This is done with the help of Redis container."
        echo " Hence you need to specify a comfortable size limit (in MB) for the application to reserve in RAM."
        echo ""
        read -rp "Specify size limit in megabytes (Eg: 32): " CPTGNLM
        
        (find . -type f -exec sed -i 's,SZLM,'"$(echo "$CPTGNLM"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        echo " Running the docker-compose.yml to install the application."
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:5000 to setup your Cryptgeon instance."
        echo ""     
        sleep 3s
        cd
    fi
    
    if [[ "$VLWDN" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Vaultwarden        ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Vaultwarden"

        sudo mkdir -p docker/vaultwarden
        cd docker/vaultwarden

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/vaultwarden-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Vaultwarden"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:8062 to view your Vaultwarden instance."
        echo ""      
        sleep 3s
        cd
    fi

    if [[ "$UPKMA" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Uptime Kuma        ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Uptime Kuma"

        sudo mkdir -p docker/uptimekuma
        cd docker/uptimekuma

        (curl -o kuma_install.sh http://git.kuma.pet/install.sh && sudo bash kuma_install.sh) >> ~docker/homelab-install-script.log 2>&1 &

        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:3001 to view your Uptime Kuma instance."
        echo ""   
        sleep 3s
        cd
    fi

    if [[ "$TLMNTS" == [yY] ]]; then
        echo "###########################################"
        echo "###      Installing Trilium Notes       ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Trilium Notes"

        sudo mkdir -p docker/trilium
        cd docker/trilium

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/trilium-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Trilium Notes"
        echo ""
        echo ""

        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:85 to view your Trilium Notes instance."
        echo ""   
        sleep 3s
        cd
    fi

#    if [[ "$RLLY" == [yY] ]]; then
#        echo "###########################################"
#        echo "###         Installing Rallly           ###"
#        echo "###########################################"
#        echo ""
#        echo "    1. Preparing to install Rallly"
#
#        mkdir -p docker/rallly
#        cd docker/rallly
#
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~docker/homelab-install-script.log 2>&1
#
#        echo "    2. Running the docker-compose.yml to install Rallly"
#        echo ""
#        echo ""
#
#        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
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
#        sleep 3s
#        cd
#    fi

    if [[ "$PNRY" == [yY] ]]; then
        echo "###########################################"
        echo "###         Installing Pinry            ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Pinry"

        sudo mkdir -p docker/pinry
        cd docker/pinry

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/pinry_docker_compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Pinry"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"

        echo ""
        echo " Go to http://${LOCALIP}:8981 to view your Pinry instance."
        echo ""   
        sleep 3s
        cd
    fi

#    if [[ "$VKNJA" == [yY] ]]; then
#        echo "###########################################"
#        echo "###        Installing Vikunja           ###"
#        echo "###########################################"
#        echo ""
#        echo "    1. Preparing to install Vikunja"
#
#        mkdir -p docker/vikunja
#        cd docker/vikunja
#
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~docker/homelab-install-script.log 2>&1
#
#        echo "    2. Running the docker-compose.yml to install Vikunja"
#        echo ""
#        echo ""
#
#        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
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
#        sleep 3s
#        cd
#    fi

#    if [[ "$POLR" == [yY] ]]; then
#        echo "###########################################"
#        echo "###        Installing POLR           ###"
#        echo "###########################################"
#        echo ""
#        echo "    1. Preparing to install POLR"
#
#        mkdir -p docker/polr
#        cd docker/polr
#
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~docker/homelab-install-script.log 2>&1

#        echo "    2. Running the docker-compose.yml to install POLR"
#        echo ""
#        echo ""

#        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
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
#        sleep 3s
#        cd
#    fi

    if [[ "$WGLE" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Whoogle           ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Whoogle"

        sudo mkdir -p docker/whoogle
        cd docker/whoogle

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/whoogle-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Whoogle"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8082 to view your Whoogle instance."
        echo ""   
        sleep 3s
        cd
    fi

    if [[ "$WJS" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Wiki.Js           ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Wiki.Js"

        sudo mkdir -p docker/wikijs
        cd docker/wikijs

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/wikijs-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install Wiki.Js"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:8084 to view your Wiki.Js instance."
        echo ""     
        sleep 3s
        cd
    fi

    if [[ "$JDWN" == [yY] ]]; then
        echo "###########################################"
        echo "###      Installing JDownloader         ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install JDownloader"

        sudo mkdir -p docker/jdownloader
        cd docker/jdownloader

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/jdown-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s

        echo " Running the docker-compose.yml to install JDownloader"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:5800 to view your JDownloader instance."
        echo ""
        sleep 3s
        cd
    fi

    if [[ "$DASHY" == [yY] ]]; then
        echo "###########################################"
        echo "###          Installing Dashy           ###"
        echo "###########################################"
        echo ""
        echo " Preparing to install Dashy"

        sudo mkdir -p docker/dashy
        sudo mkdir -p docker/dashy/public
        sudo mkdir -p docker/dashy/icons
        
        cd docker/dashy/icons

        (sudo git clone https://github.com/walkxcode/dashboard-icons.git) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s
        cd
        sleep 1s

        cd docker/dashy/public
        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dashy-docker-compose.yml -o docker-compose.yml) >> ~docker/homelab-install-script.log 2>&1

        sleep 1s

        (sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Variables/env -o .env) >> ~docker/homelab-install-script.log 2>&1
        
        sleep 1s

        (find . -type f -exec sed -i 's,user_id,'"$(echo "$_uid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,group_id,'"$(echo "$_gid"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,time_zone,'"$(echo "$WPTZ"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_conf,'"$(echo "$INSPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_movies,'"$(echo "$MOVPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_series,'"$(echo "$SHWPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_down,'"$(echo "$DWNPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampleuser,'"$(echo "$WPUNAME"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplepass,'"$(echo "$WPPSWD"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,examplemail,'"$(echo "$WPMLID"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,exampledomain,'"$(echo "$WPDMN"),g" {} +) >> ~docker/homelab-install-script.log 2>&1
        (find . -type f -exec sed -i 's,path_for_nxtdata,'"$(echo "$NXTPTH"),g" {} +) >> ~docker/homelab-install-script.log 2>&1

        sleep 2s
                
        echo " Running the docker-compose.yml to install Dashy"
        echo ""
        (sudo docker-compose up -d) >> ~docker/homelab-install-script.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$! # Process Id of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .1
        done
        printf "\r"
        echo ""
        echo " Go to http://${LOCALIP}:4000 to setup your Dashy instance."
        echo ""       
        sleep 3s
        cd
    fi
# Installing portainer for Docker GUI Management
echo " Finishing up by installing Portainer's community edition image."
(sudo docker volume create portainer_data) >> ~docker/homelab-install-script.log 2>&1
(sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~docker/homelab-install-script.log 2>&1 &
## Show a spinner for activity progress
    pid=$! # Process Id of the previous running command
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r${spin:$i:1}"
        sleep .1
    done
    printf "\r"
echo ""
echo " Navigate to https://${LOCALIP}:9443 to start playing with your new Docker setup."
echo ""
echo " (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
echo ""
echo " That's it $username, the installation of the selected applications are done. Thank you for using the script." 
echo ""
echo ""
sleep 1s

exit 1

}

echo ""
echo ""

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
(sudo mkdir docker)
echo " Welcome to the interactive and customizable Homelab Setup."
read -p " Please provide your name - " username
echo ""
echo " It's nice to interact with you $username. Thank you for choosing to install Docker with this script."
sleep 1s
echo ""
echo " You will be asked a series of questions, which lets you customize this installation to your needs."
echo " Please be mindful of the instructions and also grab a cup of coffee."
sleep 1s
echo ""
echo " Let's start by figuring out which distribution of Debian am I being used in."
echo ""
echo "    This system is based on: "
echo ""
echo "        --  " $(lsb_release -i)
echo "        --  " $(lsb_release -d)
echo "        --  " $(lsb_release -r)
echo "        --  " $(lsb_release -c)
echo ""
echo "------------------------------------------------"
echo ""
echo ""

echo " Before proceeding with the installation, you need to provide some basic details to be used for configuration. "
echo ""
echo " Provide your desired username for the applications and databases. "
echo ""
read -rp " Desired Username: " WPUNAME
sleep 1s
echo ""
echo " Provide your desired password for the applications and databases. "
echo " For security reasons, the password that you type will not be visible. So, please make sure that you type the password correctly."
echo ""
read -rsp " Desired Password: " WPPSWD
LOCALIP=$(ip a | grep "scope global" | head -1 | awk '{print $2}' | sed 's|/.*||') > ~docker/homelab-install-script.log
CLOUDIP=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}') >> ~docker/homelab-install-script.log
_uid="$(id -u)">> ~docker/homelab-install-script.log
_gid="$(id -g)">> ~docker/homelab-install-script.log
sleep 1s
echo ""
echo ""
echo "Provide the timezone in your location. "
echo "If you are not familiar with this, you can visit http://www.timezoneconverter.com/cgi-bin/findzone.tzc and select your country."
echo "Make sure to provide it in the correct format. Eg: Asia/Kolkata."
echo ""
read -rp "Timezone: " WPTZ
sleep 1s
echo ""
echo ""
echo "Thank you for the input. Note that this script comes with some packages."
echo "You can choose from a list of options as detailed in the Readme page in Github."
echo ""
sleep 1s
echo ""
PS3="Please select the package that you would like to install: "
select _ in \
    "Just Docker, Docker-Compose and Portainer." \
    "Nextcloud AIO Package (Transform your system into a Google Drive alternative, with more advanced features.)" \
    "Media Server Package (Transform your system into a home media server.)" \
    "Website package (Transforms your system into a Wordpress Host.)" \
    "General Apps (A list of self-hostable applications to choose from.)" \
    "End this Installer"
    
do
  case $REPLY in
    1) installDock ;;
    2) installNxtCld ;;
    3) installMSP ;;
    4) installWP ;;
    5) installApps ;;
    6) exit ;;
    *) echo "Invalid selection, please try again." ;;
  esac
done
