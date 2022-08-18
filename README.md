<h1 align="center" style="margin-top: 0px;">Ultimate Homelab Setup</h1>

<p align="center" >Shell based script to install Docker, and a set of different self-hostable applications compatible with Ubuntu/Debian based systems.</p>

## Prerequisites
  - You need to have an Ubuntu/Debian-based machine.
  - Your instance should have the updated version of 'git' installed. You can check if you have git installed or not by running the command `git version` and looking at the output.
 
       ![git version](https://user-images.githubusercontent.com/101336634/158008355-768918e3-7ced-462f-9a9f-e52e539c875b.png)
 - If it returns a value like it shows in this image, then you are all set. If not, you can use the following command to install the latest version of git in your system.
 `sudo apt update && sudo apt install git`
 
 
## Usage

Open Terminal (if using a desktop environment) or Putty/any SSH tool that you use (if using a server environment/headless machine) and connect to your instance. 

1. Download the script by running

```sh 
   wget https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/install.sh
```

<details><summary>Getting permission denied error?</summary>
<p>

Just add `sudo` in front.

```sh 
   sudo wget https://raw.githubusercontent.com/Jayavel-S/homelab-ultimate/main/install.sh
```

</p>
</details>

2. Now, you need to provide 'executable' permissions to it.
```sh 
   sudo chmod +x ./install.sh
```

3. Run the script
```sh 
   ./install.sh
```


## Available Choices

I have included some packages that lets you install and customize the applications to your needs. The available options are:

- [Basic setup](#ultimate-homelab-setup)
- [Nextcloud Package](#ultimate-homelab-setup)
- [Website Package](#ultimate-homelab-setup)
- [Media Server Package](#ultimate-homelab-setup)
- [General Apps](#ultimate-homelab-setup)

Once you make the selection, you might be asked additional questions that helps you tailor this installation to your needs. Make sure to read the prompts carefully and proceed with installation.

Choosing any option will get the default dependencies taken care of (i.e.) the script will install Docker, Docker-Compose and Portainer.

**[Back to Top](#ultimate-homelab-setup)**

## Features

1. Supports both AMD64 and ARM architectures with easy to follow instructions.
2. Grabs the latest version of Docker, Docker Compose (available in apt repo) and Portainer by default.
3. Skips the installation of Docker and Docker Compose if the system already has it installed.
4. Uses only FOSS (Free and Open Source Software) applications.
5. Includes database support (MySQL or MariaDB) for crucial applications.
6. Gives the ability to provide custom username and password along with desired directory/path mappings.
7. Takes the UID and GID by default (from the system) and applies it to the application's configuration.
8. Outputs all the information to a log file for reference or troubleshooting.
9. Provides the URL to access the application by taking notw of the IP allocation to the system.
10. Under active development.


## Legal Terms

Do note that there is no warranty provided with this script and it is completely open for everyone to provide contributions. This script is free to use in any private or a commercial deployment.

## Support

If you are facing any issues with using this script or if any of the applications are not getting installed properly, you can always create an issue through Github. Please make sure that you tried some basic troubleshooting steps prior to raising an issue here.


Thank you for visiting! 
**[Back to Top](#ultimate-homelab-setup)**
