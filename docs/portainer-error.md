## Portainer Timeout Error

On a new Portainer installation, the web GUI gets disabled if not accessed within a certain period of time. It will show this error message.

![image](https://user-images.githubusercontent.com/101336634/185431625-4aa9c475-860e-459f-aead-0a15d7a4722c.png)

In order to fix this, we just need to restart the container from the command line.

1. Log in to the SSH session (or) open the Command Line interface.

2. Type in 

```sh 
   sudo docker ps
```

This will list out all the docker containers installed in host machine. Now, copy the **Container ID** of the Portainer instance.

![dockerps](https://user-images.githubusercontent.com/101336634/185433212-bbc94c71-4cf4-437e-8582-dbbe33170e45.png)

3. Let's now restart this instance. Type

```sh
    sudo docker restart **Container ID**
```

![dockerrestart](https://user-images.githubusercontent.com/101336634/185433205-f2ec7fa0-e952-4ca2-a923-ed0c6a1bb17b.png)

The restart will now re-enable the Portainer instance and you can visit `https://yourip:9443`.

Once logged in, you need to set up your admin account, and you'll be presented with the dashboard.

That's it!
