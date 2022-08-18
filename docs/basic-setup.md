## Basic Docker Setup

This option lets you install **Docker** engine along with **Docker Compose** and **Portainer**.

The script will pull the latest version of docker according to the platform you are using (x86/x64/ARM) and install the docker-compose relevant to that binary. 

>Depending on your network speed and device specifications, this will take a few minutes.

Once the installation is complete, you can go to your Portainer GUI. It defaults to the port **9443**.

>Go to `https://(yourip):9443` 

(Portainer generates an SSL certificate by default in the new version, that's why we use https:// instead of http://)

Once logged in, you need to set up your admin account, and you'll be presented with the dashboard.
