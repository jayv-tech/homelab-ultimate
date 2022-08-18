# Website Package

WordPress is a powerful FOSS Content Management System that lets the user setup nearly any kind of website or blog with literally thousands of integrations.

>Choosing this package gets these three applications installed:
>    - WordPress with MySQL backend
>    - Matomo
>    - Nginx Proxy Manager

The script starts with installing the Docker, Docker Compose and Portainer and then proceeds to install these applications one by one.

Since the WordPress on Docker has a default memory and file upload limits assigned, we need to get that updated beforehand. This will allow us to set custom memory and file upload limits to our WordPress setup.


Please note:
 - The memory limit specified here is for the PHP to run on. Having this at the range of 64 to 128 MB is fine for most use cases and it is what being provided as default in many hosting provider's services. However, you can even go up to 256, but do your research on this prior to setting up.
 - The file upload limit refers to the maximum allowed size that a single file contains. Set this up as per your needs (You may need to set this higher if you plan on including videos and such).

Once set, the installation of the WordPress container resumes. It is then followed by Matomo instance.

Finally, the script will install Nginx Proxy Manager for connecting your domain name with this WordPress instance and act as a reverse proxy.

You can confirm the installation of all the containers by visiting https://yourip:9443 and accessing the Portainer's web GUI.

## Configuration
At this point, don't continue with setting up the WordPress instance. You need to assign your domain name and point it to the port **8282** to access this over your domain.

You'd need to setup a proxy host for this IP with the domain name that you own. You will also get a free Let's Encrypt SSL that gets renewed automatically.

You can visit this [document](https://github.com/Jayavel-S/homelab-ultimate/blob/main/docs/nginx-proxy-manager.md) if you'd like to know how to setup a domain to point to this instance.
