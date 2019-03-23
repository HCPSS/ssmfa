# Self-Service Multi-Factor Authentication (ssmfa)
A web interface to initiate MFA enrollment in Office 365

## Overview

Enrolling users in Office 365 MFA can be very disruptive. After an admin enables MFA users are expected to complete the enrollment steps before they can access their accounts. If the user doesn't have access to a phone, they have no option but to request MFA be disabled for their account. SSMFA alleviates these challenges by allowing users to opt-in to MFA when they want. Also if there's a problem with the users MFA settings, they can use SSMFA to clear their MFA settings and restart the enrollment process.

SSMFA uses a personal email address to validate a user's identity. Ownership of the email address is established at enrollment. When an MFA settings reset is started the user must verify control of the personal email address on file by clicking on a link.

SSMFA was designed to be deployed in an environment with hybrid on-prem AD and Office 365 accounts synced. You should expect to do a hefty amount of development work to get SSMFA to work the way you want in your environment. This project provides all of the necessary services (except Office 365 of course) to run SSMFA.

## Quickstart

![SSMFA Components](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/ssmfa.svg?sanitize=true)

To begin development on SSMFA for your environment, you'll need a development system. I recommend linux with docker and docker-compose installed. The hostname for SSMFA and all the dev services is set to `ssmfa.example.com`. Create an entry in your `/etc/hosts` file for this name.

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

Login to the dev mail server `https://ssmfa.example.com/mail`

![Email Login](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/email_login.png)

Click on the verify email link

![Verify email](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/verify_email.png)

Done, well not really. Nothing has happened on Office 365.

![Continue](https://raw.githubusercontent.com/wiki/HCPSS/ssmfa/images/continue.png)

You can see in the redis server we have stored the email address and the MFA status is pending. If the daemon was running it would enabled MFA on this GUID.

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

