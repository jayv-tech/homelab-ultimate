# General Apps

This package contains some of the commonly self-hosted applications that is useful for many people. 


You will first be asked where to store the applications' data. This will then be updated as the storage location for all the config files.

Example is provided below, you can either go for the same or change as per your needs.

```sh
/data/apps
```

Few things to note:
 -  You should not include the trailing '/' when you type in to the script.
 -  Each application will be created as a sub directory within the specified folder.

>So if you have provided "/data/apps" to be the path, the Snapdrop application will be installed under "/data/apps/snapdrop".

That's it. From now on, it is just a matter of pressing either 'y' or 'n' to the applications to install.

---
The list of apps that can be installed are:

1. [Nginx Proxy Manager](https://nginxproxymanager.com/) - A simple reverse proxy for all your web services 
2. [File Browser](https://filebrowser.org/) - Browse your files from any browser 
3. [Snapdrop](https://github.com/RobinLinus/snapdrop) - Simple file sharing based on your browser 
4. [Code Server](https://coder.com/) - Code on the cloud (in this case, your system) from anywhere. VSCode accessible from web-browser 
5. [Dillinger](https://github.com/joemccann/dillinger) - Online HTML5 Markdown editor 
6. [Cryptgeon](https://github.com/cupcakearmy/cryptgeon) - A secure note and file sharing service 
7. [Vaultwarden](https://github.com/dani-garcia/vaultwarden) - Your own password manager in your system 
8. [Uptime Kuma](https://github.com/louislam/uptime-kuma/) - A simple yet elegant uptime monitoring service 
9. [Trilium Notes](https://github.com/zadam/trilium) - A note taking application with focus on building large personal knowledge bases 
10. [Pinry](https://docs.getpinry.com/) - A self-hosted Pinterest clone 
11. [Whoogle](https://github.com/benbusby/whoogle-search) - Your own search engine, just without any trackers or ads 
12. [Wiki.Js](https://js.wiki/) - The most powerful and extensible open source Wiki software 
13. [JDownloader](https://jdownloader.org/) - A server based downloader that downloads files directly to your system 
14. [Dashy](https://dashy.to/) - An amazing dashboard app for all your self-hosted services 

*More apps on the way~*

---

Once you finish making your choices, the script will start by initializing the system updates, followed by Docker, Docker Compose, Portainer and the list of apps chosen.

When the installation completes, I suggest that you visit the Portainer's URL (https://yourip:9443) and set up the admin account.
