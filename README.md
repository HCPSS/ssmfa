# Self-Service Multi-Factor Authentication
A web interface to initiate MFA enrollment in Office 365

## Overview

Enrolling users in Office 365 MFA can be very disruptive. After an admin enables MFA users are expected to complete the enrollment steps before they can access their accounts. If the user doesn't have access to a phone, they have no option but to request MFA be disabled for their account. SSMFA alleviates these challenges by allowing users to opt-in to MFA when they want. Also, if there's a problem with the users MFA settings, they can use SSMFA to clear their MFA settings and restart the enrollment process. More information about the purpose of this service is available in the [wiki](https://github.com/hcpss/ssmfa/wiki).

SSMFA uses a personal email address to validate a user's identity. Ownership of the email address is established at enrollment. When an MFA settings reset is started the user must verify control of the personal email address on file by clicking on a link.

SSMFA was designed to be deployed in an environment with hybrid on-prem AD and Office 365 accounts synced. You should expect to do a hefty amount of development work to get SSMFA to work the way you want in your environment. This project provides all of the necessary services (except Office 365 of course) to run SSMFA.

## Quickstart

To begin development on SSMFA for your environment, you'll need a development system. I recommend Linux with docker and docker-compose installed. The hostname for SSMFA and all the dev services is set to `ssmfa.example.com`. Create an entry in your `/etc/hosts` file for this name. You could also replace `ssmfa.example.com` with the FQDN of your dev system in the `docker-compose.yml` file.

### Clone the repo, build, up

```
git clone https://github.com/HCPSS/ssmfa.git
cd ssmfa
docker-compose build
docker-compose up
```

Open your browser to `https://ssmfa.example.com`

## Try it

### MFA Enrollment

The `client` should have redirected you to `jwt` which redirected you to `sso`. Fun right!?

`username: test, password: test`

![SSO Login](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/sso_login.png)

Click `Start MFA Enrollment`

![Setup MFA](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/setup_mfa.png)

Submit an email address that ends in the domain `@example.dev`

![Submit email](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/submit_email.png)

Login to the dev mail server `https://ssmfa.example.com/mail` `username: test, password: test`

![Email Login](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/email_login.png)

Click on the verify email link

![Verify email](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/verify_email.png)

Done, well not really. Nothing has happened on Office 365.

![Continue](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/continue.png)

You can see in the redis server we have stored the email address and the MFA status is pending. If the daemon was running, it would enable MFA on this GUID.

 ```
$ docker exec -it ssmfa_redis_1 redis-cli
127.0.0.1:6379> keys *
1) "MFA_RECOVERY_EMAIL:829de882-9de8-e882-9d82-e89d82e89d82"
2) "MFA_STATUS:829de882-9de8-e882-9d82-e89d82e89d82"
127.0.0.1:6379> get MFA_RECOVERY_EMAIL:829de882-9de8-e882-9d82-e89d82e89d82
"mrsaru@example.dev"
127.0.0.1:6379> get MFA_STATUS:829de882-9de8-e882-9d82-e89d82e89d82
"pending"
127.0.0.1:6379>
 ```

### MFA Settings Reset

Click `Reset MFA settings`

![Done](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/done.png)

![Reset request](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/reset_request.png)

Go back to the mail client, `https://ssmfa.example.com/mail` and click on `Continue MFA settings reset process`

![Reset](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/reset.png)

Done. But not really.

![Continue](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/continue.png)

We can see there is another entry in redis for resetting the settings. If the daemon was running it would reset MFA on this GUID.

```
$ docker exec -it ssmfa_redis_1 redis-cli
127.0.0.1:6379> keys *
1) "MFA_RESET:829de882-9de8-e882-9d82-e89d82e89d82"
2) "MFA_RECOVERY_EMAIL:829de882-9de8-e882-9d82-e89d82e89d82"
3) "MFA_STATUS:829de882-9de8-e882-9d82-e89d82e89d82"
127.0.0.1:6379> get MFA_RESET:829de882-9de8-e882-9d82-e89d82e89d82
"pending"
127.0.0.1:6379>
```

## Settings

![SSMFA Components](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/ssmfa.svg?sanitize=true)

SSO, JWT, Mail, and HAProxy are all services that are only relevant to the development environment and exist merely for testing and demonstration purposes. Ideally, you have production systems that can fill these roles. Client, API, Redis, and Daemon are the SSMFA production services. There are many environment variables that can be configured for your environment.

| Service | Variable             | Description                                                  |
| ------- | -------------------- | ------------------------------------------------------------ |
| API     | MFA_BASE_URL         | The desired URL for SSMFA                                    |
|         | MFA_TZ               | The desired timezone for logs                                |
|         | MFA_EXCLUDED_DOMAINS | Comma seperated list of email domains users cannot use       |
|         | MFA_LINKS_EXPIRE     | Time to allow verification links to survive                  |
|         | MFA_SMTP_HOST        | The SMTP server to send email                                |
|         | MFA_SMTP_PORT        | The listener of the SMTP server                              |
|         | MFA_FROM_EMAIL       | The from address of emails sent by SSMFA                     |
|         | MFA_RECOVERY_SUBJECT | The subject line of the email establishing a recovery address |
|         | MFA_RESET_SUBJECT    | The subject line of the email verifying a personal email for setting reset |
|         | MFA_JWT_AUTH_KEY_URL | URL of the public key for JWT user authentication            |
|         | MFA_SEARCH_SERVERS   | Comma seperated list of search servers to resolve GUIDs from AD |
|         | MFA_SUPPORT_URL      | URL to an MFA support page for users                         |
| Client  | MFA_BASE_URL         | The desired URL for SSMFA                                    |
|         | MFA_EXCLUDED_DOMAINS | Comma seperated list of email domains users cannot use       |
|         | SSO_REDIRECT         | URL of the SSO server to send users that aren't authenticated with the API |
|         | SSO_REQTOKEN         | URL of the SSO server to get a JWT for authentication with the API |
|         | MFA_FAVICONURL       | URL to the desired favicon.ico file                          |
|         | MFA_LOGOURL          | URL to the desired logo image file                           |
|         | MFA_LOGOUTURL        | URL of the SSO server to process a logout                    |
|         | MFA_SUPPORT_URL      | URL to an MFA support page for users                         |
| HAProxy | DEV_COMMON_NAME      | FQDN of SSMFA dev system                                     |
|         | DEV_ALT_NAMES        | Comma seperated list of alt names                            |
|         | DEV_DEFAULT_BACKEND  | The backend server for the root path /                       |
|         | DEV_SERVICE_ACLS     | Comma seperated list of haproxy ACLs that coincide with backends |
|         | DEV_SERVICE_BACKENDS | Comma seperated list of haproxy backends that coincide with ACLs |
| SSO     | MFA_BASE_URL         | The URL of the dev SSO IdP server                            |
|         | MFA_LDAP_HOST        | LDAP server (if you have one)                                |
|         | MFA_LDAP_PORT        | LDAP port (if you have one)                                  |
|         | MFA_LDAP_SEARCHBASES | LDAP search bases (if you have them)                         |
|         | MFA_LDAP_USERNAME    | LDAP read user (if you have one)                             |
|         | MFA_LDAP_PASSWORD    | LDAP read user password (if you have one)                    |
| JWT     | MFA_BASE_URL         | The URL of the dev SSO SP server                             |
| Mail    | MAIL_DOMAIN          | The domain that will act as a personal email domain for testing |

### Development

Running `docker-compose up` on this project will give you two services running in development mode; Angular 7, and expressjs running with nodemon. Do not use these in production. As you make changes to the project your client and API will reload/restart automatically, enabling you to see the changes real time.

#### API
The SSMFA API complies with the OpenAPI specification 3.0.0. Documentation for the API is available on [SwaggerHub](https://app.swaggerhub.com/apis/HCPSS/self-service-mfa/1.0).

### Installing the daemon

The daemon service is a powershell script that uses the ActiveDirectory and MSOnline modules to resolve UPNs from GUIDs and make the appropriate changes to Office 365. The daemon will check in with the API, do whatever work needs to be done, then sleeps for a minute and does it all over again. You can run the daemon manually or install it as a service.

I have tried to make the daemon install process as painless as possible by creating a setup script. First get the configuration variables from the API.

```
$ docker exec ssmfa_api_1 daemonconfig
Base URL: https://ssmfa.example.com
API Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYWVtb24iOnRydWUsImlhdCI6MTU1MzM1MjkxMn...
Run Setup.ps1 on the windows system
```

Then copy Daemon.ps1 and Setup.ps1 to a windows box and run Setup.ps1 from an elevated prompt as the service account. The script will check the appropriate modules are available and will install them if they are missing. It will also install chocolatey and nssm if you chose to install it as a service.

![Powershell](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/powershell.png)

You can see the password and API key are stored as secure strings, because why not.

### Authentication

SSMFA client is a single-page application written in Angular 7. The API is written in node using expressjs. When the user first loads the web client, it checks for the existence of an authentication string in the browser's local storage. If this doesn't exist, it requests one from `SSO_REQTOKEN`. If it doesn't get a good response from `SSO_REQTOKEN`, it redirects to `SSO_REDIRECT`.  `SSO_REQTOKEN` and `SSO_REDIRECT` are both the JWT service. The JWT service is a simpleSAMLphp application configured as a SAML Service Provider (SP) that requires authentication with the SAML Identity Provider (IdP) and hands out JWTs that expire in 10 minutes. The client will request a new token when the one stored locally is 5 minutes to expiry. The JWT contains the objectGUID from SAML IdP and is used to identify the user throughout the application.  

If you have such a service that can hand out JWTs to APIs you should use it. When the API starts it will attempt to pull the public key for authenticating users from `MFA_JWT_AUTH_KEY_URL`. You may have to modify this or publish your public key somewhere to facilitate the API getting the public key at startup. If you do not have a service that can hand out JWTs for authentication but you have a SAML IdP, you could use the development service provided here to hand out JWTs. If you don't have a SAML IdP you could use both the SSO and JWT services with your LDAP service to provide authentication. Just be sure to read the docs on simpleSAMLphp and configure the secrets and salts appropriately.

### Volumes

`docker-compose.yml` defines two persistent volumes for SSMFA operation; `jwt` and `db`. `jwt` holds the private key for verifying email links. By default email links are only good for 1 hour, so it's not that important if this key is destroyed. However, this key is also used to grant the daemon access to the API during the daemon setup process. If you replace the key in `jwt` you will have to update the API key by running Setup.ps1 again. `db` contains the redis `rdb` file. I recommend running redis in an HA cluster with append-only enabled so you can roll back to any point in time if there is a corruption event. See my example gist here, https://gist.github.com/nickadam/aebc1a3290d42df529fa2c4afc6aab4f.

### Building for production

Once you are happy with your changes you can build production images for deployment. Both the client and API have two Dockerfiles; `Dockerfile` and `Dockerfile-dev`. Modify the `docker-compose.yml` to build using `Dockerfile`. It's important to observe the content of `client/src/environments/environment.prod.js` before you build your production image. This file was created when the development environment was launched and used the environment variables from `docker-compose.yml`, see `client/docker-entrypoint-dev.sh`. You can modify this file manually of course, if there are significant differences between your dev and prod environments.

### Contributing

Please submit any issues you encounter. Pull requests are welcome. Have fun! 🥳🎉
