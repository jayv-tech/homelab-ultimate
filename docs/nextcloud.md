# Nextcloud AIO

Nextcloud is a wonderful application that acts as your own personal cloud storage or a collaboration suite for your business. It is open source and has a large user base.

This script uses the official Nextcloud All in One's repository to handle the installation and configuration.

The only input required from your end is the path to store the files and folders when you use the application. 

Example is provided below, you can either go for the same or change as per your needs.

```sh
/data/nextcloud
```

Few things to note:
 -  You should not include the trailing '/' when you type in to the script.
 -  The specified folder's permissions will be modified automatically for the application to recognize it properly. 
  
  You will not be able to access the contents on this folder via SSH or anything else. Only Nextcloud can read and write to it.


Use the drive in which you have a lot of free space. You can use `df -h` command to take a look at your system's free space and partitions.

Post the installation, visit https://yourip:8080 to start setting up the AIO instance.

>Steps to setup:

1. Go to https://yourip:8080 and you will be provided with a password. Please note this down and save it in a secure location.
   
<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185341656-69515fdb-ace6-441a-a0af-c830f93b9bf2.png">
</p>

2. Click on the "Login" button which opens a new tab and confirms your password. Once you provide the password (displayed in the previous step), you will be presented with the AIO dashboard.

<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185342735-bae48fc4-9c46-48b0-8983-b27f4289adc1.png">
</p>

3. You should then provide your domain name and the location to setup the backups.
>You will not be allowed to change the domain later on.
>You should not include the trailing '/' when you type in the location for the backups.

4. Choose the addons that are available, if your system meets the requirements and also update the Time Zone at the bottom. 
   
<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185343725-b2890245-9738-4b78-9078-7c103a04ff0c.png">
</p>

5. Make sure to provide the correct TZ database name for your region. If you are not familiar with this, you can visit the following link -
[Find Zone](http://www.timezoneconverter.com/cgi-bin/findzone.tzc) and select your country. 

<p align="center">
  <img width="300" height="200" src="https://user-images.githubusercontent.com/101336634/185328347-06021cb5-78b4-4dd1-a476-1b6a1a26e3a2.png">
</p>

6. The AIO instance will now setup your Nextcloud container along with Apache webserver and print out the User name and Password. Click on "Open your Nextcloud" button and enter the username and password displayed earlier.
   
7.  That's it. You can start using your new Nextcloud setup.

## Support

If you face any issues during installation, you can reach out to me. But if you face any bugs or issues with your Nextcloud instance, I'd suggest you visit their official page (https://github.com/nextcloud/all-in-one) and take a look at the FAQ section.
