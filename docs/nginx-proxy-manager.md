# Nginx Proxy Manager

Nginx Proxy Manager is a simple and easy-to-use reverse proxy application to expose your webservices and applications.

Most of the packages in this script comes bundled with this application and this is a short how-to on how to use your domain to access the applications.

## Prerequisites

You need to have the ports 80 and 443 open in your firewall or router. It involves modifying the "Port Forwarding" settings in your router. Also, some ISPs require that you purchase the Static IP option and some do not. Make sure to check with your ISP first.

## Proxy Setup
We will be setting up Proxy host to forward the request to the application's port.

1. Visit the Nginx Proxy Manager's GUI by going to http://yourip:81.

![npm_proxy_hots](https://user-images.githubusercontent.com/101336634/185412691-e6a82ea6-53ee-4820-b7d8-a7801b1b5793.png)

2. Go to the "Proxy Hosts" tab and click on **"Add a new Proxy Host"**

<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185412687-5c270f4d-cd1c-495e-905b-e4a59fae0bd7.png">
</p>

3. Input the following details as decribed here:
   - In the **"Domain Names"** field, enter the desired domain (example.com or drive.example.com)
   - Provide your IP Address in the **"Forward Hostname/IP"** section. If a service is documented to work on **https://**, you'd need to select it in the **"Scheme"** section. Else, leave it as **"http"** itself.
   - Type in the Port number that the service runs on (Eg: 82 or 8080 etc.). This is the location where the public requests will be forwarded to.
   - Make sure to enable the **"Block Common Exploits"** and **"Websockets Support"** options.

4. Go to the "SSL" tab click on **"Request a new SSL Certificate"**

<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185412674-6d9b44ef-fa90-4d06-88c1-a3f8c0332564.png">
</p>

   - Select the options **"Force SSL"** and **"HTTP/2 Support"**

<p align="center">
<img src="https://user-images.githubusercontent.com/101336634/185412685-516a4b12-9b1c-43e7-9173-a9661b8a51f7.png">
</p>

   - Enter your E-Mail address in the last field. This is important and will be used for getting the free SSL certificate. Also, you'd need to agree to the "Terms of Service" and once done click on **"Save"**.

5. That's it. You have now successfully setup a new Proxy Host and started to forward the web requests.
