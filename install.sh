#!/bin/bash

installDock()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about the application Selection
    echo "This script will now install Docker (community edition), Docker Compose, and Portainer."

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        echo "#######################################################"
        echo "###          Preparing for Installation             ###"
        echo "#######################################################"
        echo ""
        sleep 3s

         echo "    1. Installing System Updates. This may take a while."
            (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
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

        echo "    2. Installing Prerequisite Packages."
        sleep 2s

            sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1

        echo "    3. Installing Docker (Community Edition)."
        sleep 2s

            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

        echo "      - Docker version is now:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

        echo "    4. Starting Docker Service"
        sudo systemctl docker start >> ~/docker-script-install.log 2>&1

        echo ""
        echo "  - Adding this user account to the docker group."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo ""
        echo "    5. Installing Docker-Compose."
        echo ""
        echo ""
        sleep 2s

        sudo apt install docker-compose -y >> ~/docker-script-install.log 2>&1
        
        echo ""
        echo "      - Docker Compose Version is now: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

        # Enabling docker to start automatically on hardware reboot
        echo "    6. Enabling the Docker service to start automatically on boot."
        echo ""
        sudo systemctl enable docker
        sleep 1s

        # Installing portainer for Docker GUI Management
        echo "    7. Starting Docker Service"
        echo ""
        sudo docker volume create portainer_data
        docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
        echo ""
        echo ""

    exit 1

}

installMSP()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about the application Selection
    echo "This script will now install Docker and the applications to manage your home media collection."
        
        echo "    Please provide the path of the directory where your media files reside. "
        echo "      If there are no media files presently, the folders will be created for future use. "
        echo "          Provide the path in the format of '/data/path' without the trailing '/'"
        echo "              Eg: /home/user/movies (or) /media/videos "
        echo ""
        read -rp "Specify the path to Movies: " MOVPTH
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sudo mkdir "$MOVPTH" -p
        sleep 1s
        echo ""
        read -rp "Specify the path to TV Shows: " SHWPTH
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sudo mkdir "$SHWPTH" -p
        sleep 1s
        echo ""
        read -rp "Specify the path to Downloads: " DWNPTH
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sudo mkdir "$DWNPTH" -p
        sleep 1s

        _uid="$(id -u)"
        _gid="$(id -g)"

        echo "Thank you for the input. Just a few more choices left to make."
        echo "Now, lets install the applications as per your choice." 
        echo "  When prompted, please select 'y' for each item you would like to install."

        echo "Plex is the backbone for organizing and streaming the media that we have in home."
        sleep 1s
        read -rp "Install Plex? (y/n): " PLX
        sleep 1s
        echo ""
        echo "Tautulli monitors the Plex activity and collect the statistics "
        sleep 1s
        read -rp "Install Tautulli? (y/n): " TLI
        sleep 1s
        echo ""
        echo "Sonarr is a collection manager for TV Shows and Web Series "
        sleep 1s
        read -rp "Install Sonarr? (y/n): " SNR
        sleep 1s
        echo ""
        echo "Radarr is a collection manager for Movies "
        sleep 1s
        read -rp "Install Radarr? (y/n): " RDR
        sleep 1s
        echo ""
        echo "Sabnzbd is a USENET client/downloader "
        sleep 1s
        read -rp "Install Sabnzbd? (y/n): " SZBD
        sleep 1s
        echo ""
        echo "Deluge is a torrent tracker and downloader "
        sleep 1s
        read -rp "Install Deluge? (y/n): " DLG
        sleep 1s
        echo ""
        echo "Overseerr is a media discovery and request manager for Plex "
        sleep 1s
        read -rp "Install Overseerr? (y/n): " OVSR
        sleep 1s
        echo ""
        echo "Jackett is a bridge for apps listed above to communicate with the torrent indexers of your choice "
        sleep 1s
        read -rp "Install Jackett? (y/n): " JKT
        sleep 1s
        echo ""
        echo "Watchtower is a collection manager for TV Shows and Web Series "
        sleep 1s
        read -rp "Install Watchtower? (y/n): " WTR
        sleep 1s
        echo ""
        echo "Portainer is the web GUI application for managing all your Docker Containers."
        sleep 1s
        read -rp "Install Portainer-CE? (y/n): " PTAINR
        echo ""

        if [[ "$PTAINR" == [yY] ]]; then
        echo ""
        echo ""
        PS3="Please choose either Portainer-CE or just Portainer Agent: "
        select _ in \
            " Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
            " Portainer Agent - Remote Agent to Connect from Portainer-CE"
        do
            PORTMP="$REPLY"
            case $REPLY in
                1) startInstallMPApps ;;
                2) startInstallMPApps ;;
                *) echo "Invalid selection, please try again." ;;
            esac
        done
    fi
    
    if [[ "$PORTMP" == "1" ]]; then
        echo "########################################"
        echo "###      Installing Portainer-CE     ###"
        echo "########################################"
        echo ""
        echo "    1. Preparing to Install Portainer-CE"
        echo ""
        echo ""

        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
        echo ""
        echo ""
        echo "    Navigate to https://(your device's IP address):9443"
        echo "    (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""      
        sleep 3s
        cd
    fi

    if [[ "$PORTMP" == "2" ]]; then
        echo "###########################################"
        echo "###      Installing Portainer Agent     ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Portainer Agent"

        sudo docker volume create portainer_data
        sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:latest
        echo ""
        echo ""
        echo "    From Portainer or Portainer-CE add this Agent instance via the 'Endpoints' option in the left menu."
        echo "         Use the IP address of this server and port 9001"
        echo ""
        echo ""
        echo ""
        sleep 3s
    fi

    echo ""
        echo ""
        echo "    Navigate to https://(your device's IP address):9443"
        echo "    (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""      
        sleep 3s
        cd

    startInstallMPApps
}

installNxtCld()
{
    clear
    echo "This script will now install Docker (community edition), Docker Compose, and Portainer."

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        echo "#######################################################"
        echo "###          Preparing for Installation             ###"
        echo "#######################################################"
        echo ""
        sleep 3s

         echo "   Installing System Updates. This may take a while."
            (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
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

        echo "    Installing Prerequisite Packages."
        sleep 2s

            (sudo apt install curl wget git -y) >> ~/docker-script-install.log 2>&1 &
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

        echo "    Installing Docker (Community Edition)."
        sleep 2s

            (curl -fsSL https://get.docker.com | sh) >> ~/docker-script-install.log 2>&1 &
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

        echo "      - Version check:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

        echo "    Starting Docker Service"
        (sudo systemctl docker start) >> ~/docker-script-install.log 2>&1 &
        
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
        echo "  - Adding this user account to the docker group."

        sleep 2s
        (sudo usermod -aG docker "${USER}") >> ~/docker-script-install.log 2>&1 &
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo ""
        echo "    Installing Docker-Compose."
        echo ""
        echo ""
        sleep 2s

        (sudo apt install docker-compose -y) >> ~/docker-script-install.log 2>&1 &
        
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
        echo "    Version check: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker-Compose appears to be installed."
        echo ""
        echo ""
    fi

        # Enabling docker to start automatically on hardware reboot
        echo "    Enabling the Docker service to start automatically on boot."
        echo ""
        (sudo systemctl enable docker) >> ~/docker-script-install.log 2>&1 
        sleep 1s

        # Installing portainer for Docker GUI Management
        echo "    Installing Portainer."
        echo ""
        (sudo docker volume create portainer_data) >> ~/docker-script-install.log 2>&1
        (sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest) >> ~/docker-script-install.log 2>&1 &
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

        echo "    Installing Nextcloud AIO Program."

        # Pull the Nextcloud docker-compose file from github
        echo "    Pulling a default Nextcloud docker-compose.yml file."

        sudo mkdir -p docker/nextcloud
        cd docker/nextcloud

        echo "Now you need to provide the path of the directory to store your files and folders in Nextcloud."
        echo "Provide the path in the format of '/data/path' without the trailing '/' "
        echo "Eg: /home/user/data (or) /mnt/data "
        echo ""
        read -rp "Specify the path to store Nextcloud data on: " NXTPTH
        sed -i 's,/mnt/ncdata,"$NXTPTH",g' *
        sudo mkdir "$NXTPTH" -p
        sleep 1s
        sudo chown -R 33:0 "$NXTPTH"
        sudo chmod -R 750 "$NXTPTH"
        sleep 1s

        echo "Running the docker commands to install and start Nextcloud instance."
        echo ""
        
        ARCH=$( (uname -m ) 2>&1 )

        if [[ "$ARCH" == "x86_64" || "$ARCH" == "i386" || "$ARCH" == "i486" || "$ARCH" == "i586" || "$ARCH" == "i686" ]]; then

        #sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudx86-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
        #(sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
        
        (sudo docker run -d --name nextcloud-aio-mastercontainer --restart always -p 80:80 -p 8080:8080 -p 8443:8443 -e NEXTCLOUD_DATADIR="$NXTPTH" --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro nextcloud/all-in-one:latest) >> ~/docker-script-install.log 2>&1 &
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

        #sudo curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Nextcloud%20AIO%20Package/nextcloudarm64-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
        #(sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &

            (sudo docker run -d \
            --name nextcloud-aio-mastercontainer \
            --restart always \
            -p 80:80 \
            -p 8080:8080 \
            -p 8443:8443 \
            -e NEXTCLOUD_DATADIR="$NXTPTH" \
            --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
            --volume /var/run/docker.sock:/var/run/docker.sock:ro \
            nextcloud/all-in-one:latest-arm64) >> ~/docker-script-install.log 2>&1 &

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
        echo ""
        echo "    Go to https://(your device's IP address):8080 to setup  Nextcloud AIO instance."
        echo ""
        echo ""       
        sleep 3s
        cd

        exit 1

}

startInstallMPApps()

{
    clear
    echo "#######################################################"
    echo "###          Preparing for Installation             ###"
    echo "#######################################################"
    echo ""
    sleep 3s

    echo "    1. Installing System Updates. This may take a while."
        (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
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

        echo "    2. Installing Prerequisite Packages."
        sleep 2s

        sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1

        echo "    3. Installing Docker (Community Edition)."
        sleep 2s

        curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

        echo "      - docker-ce version is now:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

        echo "    4. Starting Docker Service"
            sudo systemctl docker start >> ~/docker-script-install.log 2>&1

        # add current user to docker group so sudo isn't needed
        echo ""
        echo "    5. Adding this user account to the docker group."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo ""
        echo ""
        sleep 3s

        echo ""
        echo "    6. Installing Docker-Compose."
        echo ""
        echo ""
        sleep 2s

        sudo apt install docker-compose -y >> ~/docker-script-install.log 2>&1
        
        echo ""

        echo "      - Docker Compose Version is now: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s


    ##########################################
    ## Testing if Docker Service is Running ##
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo "Giving the Docker service some time to start."
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
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
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

    if [[ "$PLX" == [yY] ]]; then
        echo "##########################################"
        echo "###          Installing Plex           ###"
        echo "##########################################"
    
        # Pull the plex docker-compose file from github
        echo "    1. Pulling a default Plex docker-compose.yml file."

        mkdir -p docker/plex
        cd docker/plex
        
        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/plex-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sleep 1s

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Plex Media Server"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):32400/web/index.html to setup"
        echo "    your Plex account and the instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$TLI" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Tautulli         ###"
        echo "##########################################"
    
        # Pull the tautulli docker-compose file from github
        echo "    1. Pulling a default tautulli docker-compose.yml file."

        mkdir -p docker/tautulli
        cd docker/tautulli

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/tautulli-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Tautulli"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8181 to setup"
        echo "    your Tautulli with you Plex account."
        echo ""       
        sleep 3s
        cd
    fi 

    if [[ "$SNR" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Sonarr          ###"
        echo "##########################################"
    
        # Pull the Sonarr docker-compose file from github
        echo "    1. Pulling a default Sonarr docker-compose.yml file."

        mkdir -p docker/sonarr
        cd docker/sonarr

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sonarr-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Sonarr"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8989 to setup"
        echo "    your Sonarr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$RDR" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Radarr          ###"
        echo "##########################################"
    
        # Pull the Radarr docker-compose file from github
        echo "    1. Pulling a default Radarr docker-compose.yml file."

        mkdir -p docker/radarr
        cd docker/radarr

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/radarr-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Radarr"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):7878 to setup"
        echo "    your Radarr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$SZBD" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Sabnzbd          ###"
        echo "##########################################"
    
        # Pull the Sabnzbd docker-compose file from github
        echo "    1. Pulling a default Sabnzbd docker-compose.yml file."

        mkdir -p docker/sabnzbd
        cd docker/sabnzbd

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/sabnzbd-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Sabnzbd"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8080 to setup"
        echo "    your Sabnzbd instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$DLG" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Deluge          ###"
        echo "##########################################"
    
        # Pull the Deluge docker-compose file from github
        echo "    1. Pulling a default Deluge docker-compose.yml file."

        mkdir -p docker/deluge
        cd docker/deluge

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/deluge-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Deluge"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8112 to setup"
        echo "    Deluge instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$OVSR" == [yY] ]]; then
        echo "##########################################"
        echo "###        Installing Overseerr        ###"
        echo "##########################################"
    
        # Pull the Overseerr docker-compose file from github
        echo "    1. Pulling a default Overseerr docker-compose.yml file."

        mkdir -p docker/overseerr
        cd docker/overseerr

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/overseerr-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Overseerr"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):5055 to setup"
        echo "    the Overseerr instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$JKT" == [yY] ]]; then
        echo "##########################################"
        echo "###         Installing Jackett         ###"
        echo "##########################################"
    
        # Pull the Jackett docker-compose file from github
        echo "    1. Pulling a default Jackett docker-compose.yml file."

        mkdir -p docker/jackett
        cd docker/jackett

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/jackett-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Jackett"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):9117 to setup"
        echo "    the Jackett instance."
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$WTR" == [yY] ]]; then
        echo "##########################################"
        echo "###       Installing Watchtower        ###"
        echo "##########################################"
    
        # Pull the Watchtower docker-compose file from github
        echo "    1. Pulling a default Watchtower docker-compose.yml file."

        mkdir -p docker/watchtower
        cd docker/watchtower

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/watchtower-docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Media%20Server%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *

        echo "    2. Running the docker-compose.yml to install and start Watchtower"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Once installed, the Watchtower instance will automatically start"
        echo "    checking for updates to the applications once every 24 hours."
        echo ""       
        sleep 3s
        cd
    fi

    exit 1
}


installWP()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about the application Selection
    echo "This script will now install Docker and Wordpress with a MySQL Database."

    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        echo "#######################################################"
        echo "###          Preparing for Installation             ###"
        echo "#######################################################"
        echo ""
        sleep 3s

         echo "    1. Installing System Updates. This may take a while."
            (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
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

        echo "    2. Installing Prerequisite Packages."
        sleep 2s

            sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1

        echo "    3. Installing Docker (Community Edition)."
        sleep 2s

            curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

        echo "      - Docker version is now:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

        echo "    4. Starting Docker Service"
            sudo systemctl docker start >> ~/docker-script-install.log 2>&1

        echo ""
        echo "  - Adding this user account to the docker group."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        echo ""
        echo "    5. Installing Docker-Compose."
        echo ""
        echo ""
        sleep 2s

        sudo apt install docker-compose -y >> ~/docker-script-install.log 2>&1
        
        echo ""
        echo "      - Docker Compose Version is now: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

        # Enabling docker to start automatically on hardware reboot
        echo "    6. Enabling the Docker service to start automatically on boot."
        echo ""
        sudo systemctl enable docker
        sleep 1s

        # Installing portainer for Docker GUI Management
        echo "    7. Starting Docker Service."
        echo ""
        sudo docker volume create portainer_data
        docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
        echo ""
        echo ""
        sleep 3s

        echo "    8. Installing Wordpress and MySQL Database."

        # Pull the Wordpress docker-compose file from github
        echo "    Pulling a default Wordpress docker-compose.yml file."

        mkdir -p docker/wordpress
        cd docker/wordpress

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/wordpress-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/.env -0 .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *

        echo "    In order to proceed with the Website Package setup, you need to provide some additional details. "
        echo ""
        echo "    Provide your E-Mail ID. "
        echo "    This is for acquiring free SSL certificates from Let's Encrypt that automatically renews upon expiry."
        echo ""
        read -rp "Your E-Mail ID: " WPMLID
        sed -i 's,"examplemail","$WPMLID",g' *
        sleep 1s
        echo ""
        echo "    Finally, provide your Domain Name (Eg: awesome.$username.com). This will be registered with the SSL certificate generation."
        echo "    If you don't have a domain name, you can get a free DNS from duckdns.org"
        echo ""
        read -rp "Your domain name: " WPDMN
        sed -i 's,"exampledomain","$WPDMN",g' *
        sleep 1s
        echo ""
        echo "Thank you for the input, the installation is resuming now."
        echo ""
        echo "Running the docker-compose.yml to install and start the Wordpress instance."
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://yourdomain.name to complete the "
        echo "    “famous five-minute installation” as a WordPress administrator."
        echo ""
        echo ""       
        sleep 3s

        echo "    9. Installing Matomo."

        # Pull the Matomo docker-compose file from github
        echo "    Pulling a default Matomo docker-compose.yml file."

        mkdir -p docker/matomo
        cd docker/matomo

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/matomo-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/Website%20Package/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    Running the docker-compose.yml to install Matomo"
        echo ""
        echo ""
        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8384 "
        echo "      to view your Matomo instance."
        echo ""
        echo ""       
        sleep 3s
        cd

    exit 1 

}

installApps()
{
    clear
    OS="$REPLY" ## <-- This $REPLY is about application Selection
    echo "Now, lets install the applications as per your choice."
    echo "When prompted, please select 'y' for each item you would like to install."
    echo "  NOTE: Without Docker you cannot use any applications in this script."
    echo "       You also must have Docker-Compose for all the applications to be installed."
    echo ""
    echo ""
    
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Install Docker? (y/n): " DOCK
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Install Docker-Compose (y/n): " DCOMP
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

    echo "Nginx Proxy manager is the application that lets users to expose their "
    echo "  self-hosted applications and make them accessible via a domain name."
    sleep 1s
    read -rp "Install Nginx Proxy Manager? (y/n): " NPM
    sleep 1s  
    echo "File Browser is a software where you can install it on a server, direct it to a path"
    echo "  and then access your files through a nice web interface."
    sleep 1s
    read -rp "Install Filebrowser? (y/n): " FLBW
    sleep 1s
    echo "Snapdrop is a local file sharing server accessible from your browser."
    echo "  Inspired by Apple's Airdrop."    
    sleep 1s
    read -rp "Install Snapdrop? (y/n): " SNPDP
    sleep 1s
    echo "Code Server lets you run VS Code on any machine anywhere and access it in the browser."
    echo "  This lets you offload the heavy-lifting to your server."
    sleep 1s
    read -rp "Install Code Server? (y/n): " CDESRVR
    sleep 1s
    echo "Dillinger is an online cloud-enabled, HTML5, buzzword-filled Markdown editor."
    sleep 1s
    read -rp "Install Dillinger? (y/n): " DLNGR
    sleep 1s
    echo "Cryptgeon is a secure, open source note or file sharing service inspired by PrivNote"
    sleep 1s
    read -rp "Install Cryptgeon? (y/n): " CPTGN
    sleep 1s
    echo "Vaultwarden is a strong password manager that supports many features and integrates with Bitwarden API."
    sleep 1s
    read -rp "Install Vaultwarden? (y/n): " VLWDN
    sleep 1s
    echo "Uptime Kuma is a self-hosted monitoring tool like Uptime Robot."
    sleep 1s
    read -rp "Install Uptime Kuma? (y/n): " UPKMA
    sleep 1s
    echo "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases."
    sleep 1s
    read -rp "Install Trilium Notes? (y/n): " TLMNTS
    sleep 1s
#    echo "Rallly is a Self-hostable doodle poll alternative."
#    echo " Find the best date for a meeting with your colleagues or friends without the back and forth emails."
#    sleep 1s
#    read -rp "Install Rallly? (y/n): " RLLY
#    sleep 1s
    echo "Pinry is a a tiling image board system for people who want to save,"
    echo "  tag, and share images, videos and webpages in an easy to skim through format."
    sleep 1s
    read -rp "Install Pinry? (y/n): " PNRY
    sleep 1s
#    echo "Vikunja is an open-source, self-hostable to-do app to organize everything, on all platforms. "
#    sleep 1s
#    read -rp "Install Vikunja? (y/n): " VKNJA
#    sleep 1s
#    echo "Polr is a quick, modern, and open-source link shortener. It allows you to host your own URL shortener, and to brand your URLs. "
#    sleep 1s
#    read -rp "Install Polr? (y/n): " POLR
#    sleep 1s
    echo "Whoogle lets you get Google search results, but without any ads, javascript, AMP links, cookies, or IP address tracking. "
    sleep 1s
    read -rp "Install Whoogle? (y/n): " WGLE
    sleep 1s
    echo "Wiki.Js The most powerful and extensible open source Wiki software"
    sleep 1s
    read -rp "Install Wiki.Js? (y/n): " WJS
    sleep 1s
    echo "JDownloader is a free, open-source download management tool. "
    sleep 1s
    read -rp "Install JDownloader? (y/n): " JDWN
    sleep 1s
    echo "Dashy is an open source, highly customizable, easy to use, privacy-respecting dashboard app."
    sleep 1s
    read -rp "Install Dashy? (y/n): " DASHY
    sleep 1s
    echo "Portainer is the web GUI application for managing all your Docker Containers."
    sleep 1s
    read -rp "Install Portainer-CE? (y/n): " PTAIN

    if [[ "$PTAIN" == [yY] ]]; then
        echo ""
        echo ""
        PS3="Please choose either Portainer-CE or just Portainer Agent: "
        select _ in \
            " Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
            " Portainer Agent - Remote Agent to Connect from Portainer-CE"
        do
            PORT="$REPLY"
            case $REPLY in
                1) startInstallApps ;;
                2) startInstallApps ;;
                *) echo "Invalid selection, please try again." ;;
            esac
        done
    fi
    
    if [[ "$PORT" == "1" ]]; then
        echo "########################################"
        echo "###      Installing Portainer-CE     ###"
        echo "########################################"
        echo ""
        echo "    1. Preparing to Install Portainer-CE"
        echo ""
        echo ""

        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
        echo ""
        echo ""
        echo "    Navigate to https://(your device's IP address):9443"
        echo "    (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""      
        sleep 3s
        cd
    fi

    if [[ "$PORT" == "2" ]]; then
        echo "###########################################"
        echo "###      Installing Portainer Agent     ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Portainer Agent"

        sudo docker volume create portainer_data
        sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:latest
        echo ""
        echo ""
        echo "    From Portainer or Portainer-CE add this Agent instance via the 'Endpoints' option in the left menu."
        echo "         Use the IP address of this server and port 9001"
        echo ""
        echo ""
        echo ""
        sleep 3s
    fi

    echo ""
        echo ""
        echo "    Navigate to https://(your device's IP address):9443"
        echo "    (Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)"
        echo ""      
        sleep 3s
        cd

    startInstallApps
}

startInstallApps() 
{
    clear
    echo "#######################################################"
    echo "###          Preparing for Installation             ###"
    echo "#######################################################"
    echo ""
    sleep 3s

    echo "    1. Installing System Updates. This may take a while."
        (sudo apt update && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
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

        echo "    2. Installing Prerequisite Packages."
        sleep 2s

        sudo apt install curl wget git -y >> ~/docker-script-install.log 2>&1

        echo "    3. Installing Docker (Community Edition)."
        sleep 2s

        curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1

        echo "      - docker-ce version is now:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

        echo "    5. Starting Docker Service"
            sudo systemctl docker start >> ~/docker-script-install.log 2>&1

    if [[ "$DOCK" == [yY] ]]; then
        # add current user to docker group so sudo isn't needed
        echo ""
        echo "  - Adding this user account to the docker group."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo ""
        echo ""
        sleep 3s
    fi

    if [[ "$DCOMP" = [yY] ]]; then
        echo ""
        echo "    1. Installing Docker-Compose."
        echo ""
        echo ""
        sleep 2s

        sudo apt install docker-compose -y >> ~/docker-script-install.log 2>&1
        
        echo ""

        echo "      - Docker Compose Version is now: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s
    fi

    ##########################################
    ## Testing if Docker Service is Running ##
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo "Giving the Docker service some time to start."
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
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
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

    if [[ "$NPM" == [yY] ]]; then
        echo "##########################################"
        echo "###     Install Nginx Proxy Manager    ###"
        echo "##########################################"
    
        # Pull the nginx proxy manager docker-compose file from github
        echo "    1. Pulling a default NGinX Proxy Manager docker-compose.yml file."

        mkdir -p docker/nginx-proxy-manager
        cd docker/nginx-proxy-manager

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/npm-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install and start NGinX Proxy Manager"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):81 to setup"
        echo "    Nginx Proxy Manager admin account."
        echo ""
        echo "    The default login credentials for Nginx Proxy Manager are:"
        echo "        username: admin@example.com"
        echo "        password: changeme"

        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$FLBW" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Filebrowser        ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Filebrowser"

        mkdir -p docker/filebrowser
        cd docker/filebrowser

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/filebrowser-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Filebrowser"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8083"
        echo "      to setup your Filebrowser instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$SNPDP" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Snapdrop          ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Snapdrop"

        mkdir -p docker/snapdrop
        cd docker/snapdrop

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/snapdrop-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Snapdrop"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):82"
        echo "      to view your Snapdrop instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$CDESRVR" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Codeserver         ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Codeserver"

        mkdir -p docker/codeserver
        cd docker/codeserver

        https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/codeserver-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Codeserver"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):7443"
        echo "      to setup your Codeserver instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$DLNGR" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Dillinger         ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Dillinger"

        mkdir -p docker/dillinger
        cd docker/dillinger

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dillinger-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Dillinger"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8085"
        echo "      to setup your Dillinger instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$CPTGN" == [yY] ]]; then
        echo "##########################################"
        echo "###          Install Cryptgeon         ###"
        echo "##########################################"
    
        # Pull the cryptgeon docker-compose file from github
        echo "    1. Getting the docker-compose.yml file."

        mkdir -p docker/cryptgeon
        cd docker/cryptgeon

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/cryptgeon-docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2.Cryptgeon uses your system's RAM to store the data and share it with full encryption."
        echo "      This is done with the help of Redis container. Hence you need to specify a comfortable"
        echo "          size limit (in MB) for the application to reserve in RAM. "
        echo ""
        read -rp "Specify size limit in megabytes (Eg: 32): " CPTGNLM
        sed -i 's,SZLM,"$CPTGNLM",g' *
        sleep 1s
        echo "    3. Running the docker-compose.yml to install the application."
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):5000"
        echo "      to setup your Cryptgeon instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi
    
    if [[ "$VLWDN" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Vaultwarden        ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Vaultwarden"

        mkdir -p docker/vaultwarden
        cd docker/vaultwarden

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/vaultwarden-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Vaultwarden"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8062"
        echo "      to view your Vaultwarden instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$UPKMA" == [yY] ]]; then
        echo "###########################################"
        echo "###       Installing Uptime Kuma        ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Uptime Kuma"

        mkdir -p docker/uptimekuma
        cd docker/uptimekuma

        (curl -o kuma_install.sh http://git.kuma.pet/install.sh && sudo bash kuma_install.sh) >> ~/docker-script-install.log 2>&1 &

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
        echo "    Go to http://(your device's IP address):3001"
        echo "      to view your Uptime Kuma instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$TLMNTS" == [yY] ]]; then
        echo "###########################################"
        echo "###      Installing Trilium Notes       ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Trilium Notes"

        mkdir -p docker/trilium
        cd docker/trilium

        https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/trilium-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
        
        echo "    2. Running the docker-compose.yml to install Trilium Notes"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):85"
        echo "      to view your Trilium Notes instance."
        echo ""
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
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
#
#        echo "    2. Running the docker-compose.yml to install Rallly"
#        echo ""
#        echo ""
#
#        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
#        echo "    Go to http://(your device's IP address):86"
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
        echo "    1. Preparing to install Pinry"

        mkdir -p docker/pinry
        cd docker/pinry

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/pinry_docker_compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        echo "    2. Running the docker-compose.yml to install Pinry"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8981"
        echo "      to view your Pinry instance."
        echo ""
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
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
#
#        echo "    2. Running the docker-compose.yml to install Vikunja"
#        echo ""
#        echo ""
#
#        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
#        echo "    Go to http://(your device's IP address):87 "
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
#        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

#        echo "    2. Running the docker-compose.yml to install POLR"
#        echo ""
#        echo ""

#        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
#        echo "    Go to http://(your device's IP address):88 "
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
        echo "    1. Preparing to install Whoogle"

        mkdir -p docker/whoogle
        cd docker/whoogle

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/whoogle-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Whoogle"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8082 "
        echo "      to view your Whoogle instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$WJS" == [yY] ]]; then
        echo "###########################################"
        echo "###        Installing Wiki.Js           ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Wiki.Js"

        mkdir -p docker/wikijs
        cd docker/wikijs

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/wikijs-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *

        echo "    2. Running the docker-compose.yml to install Wiki.Js"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):8084 "
        echo "      to view your Wiki.Js instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$JDWN" == [yY] ]]; then
        echo "###########################################"
        echo "###      Installing JDownloader         ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install JDownloader"

        mkdir -p docker/jdownloader
        cd docker/jdownloader

        curl https://*****/docker_compose_filebrowser.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        echo "    2. Running the docker-compose.yml to install JDownloader"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):5800 "
        echo "      to view your JDownloader instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    if [[ "$DASHY" == [yY] ]]; then
        echo "###########################################"
        echo "###          Installing Dashy           ###"
        echo "###########################################"
        echo ""
        echo "    1. Preparing to install Dashy"

        mkdir -p docker/dashy/public
        mkdir -p docker/dashy/icons
        
        cd docker/dashy/icons

        git clone https://github.com/walkxcode/dashboard-icons.git

        cd docker/dashy/public
        git clone DASHY CONF.YMLLL**********

        cd docker/dashy
        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/dashy-docker-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

        curl https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/General%20Apps/.env -o .env >> ~/docker-script-install.log 2>&1

        sed -i 's,user_id,"$_uid",g' *
        sed -i 's,group_id,"$_gid",g' *
        sed -i 's,path_for_movies,"$MOVPTH",g' *
        sed -i 's,path_for_series,"$SHWPTH",g' *
        sed -i 's,path_for_down,"$DWNPTH",g' *
        sed -i 's,exampleuser,"$WPUNAME",g' *
        sed -i 's,examplepass,"$WPPSWD",g' *
        sed -i 's,"examplemail","$WPMLID",g' *
        sed -i 's,"exampledomain","$WPDMN",g' *
                
        echo "    2. Running the docker-compose.yml to install Dashy"
        echo ""
        echo ""

        (sudo docker-compose up -d) > ~/docker-script-install.log 2>&1 &
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
        echo "    Go to http://(your device's IP address):4000"
        echo "      to setup your Dashy instance."
        echo ""
        echo ""       
        sleep 3s
        cd
    fi

    exit 1
}

echo ""
echo ""

clear
# Caching sudo access for install completion
sudo true
echo ""
echo ""
echo ""
echo "  _   _  _  _    _                    _           _   _                          _         _      ";
echo " | | | || || |_ (_) _ __ ___    __ _ | |_  ___   | | | |  ___   _ __ ___    ___ | |  __ _ | |__   ";
echo " | | | || || __|| || '_ \` _ \  / _\` ||  / _ \  | |_| | / _ \ | '_ \` _ \ / _ \| | / _\` || '_\  ";
echo " | |_| || || |_ | || | | | | || (_| || |_|  __/  |  _  || (_) || | | | | ||  __/| || (_| || |_) | ";
echo "  \___/ |_| \__||_||_| |_| |_| \__,_| \__|\___|  |_| |_| \___/ |_| |_| |_| \___||_| \__,_||_.__/  ";
echo "                                  ____         _                                                 ";
echo "                                 / ___|   ___ | |_  _   _  _ __                                  ";
echo "                                 \___ \  / _ \| __|| | | || '_ \                                 ";
echo "                                  ___) ||  __/| |_ | |_| || |_) |                                ";
echo "                                 |____/  \___| \__| \__,_|| .__/                                 ";
echo "                                                          |_|                                    ";
echo ""
echo ""
echo ""
echo "Welcome to the interactive and customizable Homelab Setup."
read -p "Please provide your name - " username
echo ""
echo "It's nice to interact with you $username. Thank you for choosing to install Docker with this script."
sleep 1s
echo ""
echo "You will be asked a series of questions, which lets you customize this installation to your needs."
echo "Please be mindful of the instructions. Grab a cup of coffee and let's start."
sleep 1s
echo ""
echo "Let's first figure out which distribution of Debian am I being used in."
echo ""
echo "    You appear to be running: "
echo "        --  " $(lsb_release -i)
echo "        --  " $(lsb_release -d)
echo "        --  " $(lsb_release -r)
echo "        --  " $(lsb_release -c)
echo ""
echo "------------------------------------------------"
echo ""
echo ""

echo "Before proceeding with the installation, you need to provide some basic details to be used for configuration. "
echo ""
echo ""
echo "Provide your desired username for the applications and databases. "
echo ""
read -rp "Desired Username: " WPUNAME
sleep 1s
echo ""
echo "Provide your desired password for the applications and databases. "
echo "For security reasons, the password that you type will not be visible. So, please make sure that you type the password correctly."
echo ""
read -rsp "Desired Password: " WPPSWD
sleep 1s
echo ""
echo ""
echo "Thank you for the input. Note that this script comes with some packages." 
echo "You can choose from a list of options as detailed in the Readme page in Github."
echo ""
sleep 1s
echo ""
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
