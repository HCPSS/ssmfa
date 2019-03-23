# Self-Service Multi-Factor Authentication (ssmfa)
A web interface to initiate MFA enrollment in Office 365

## Overview

Enrolling users in Office 365 MFA can be very disruptive. After an admin enables MFA users are expected to complete the enrollment steps before they can access their accounts. If the user doesn't have access to a phone, they have no option but to request MFA be disabled for their account. SSMFA alleviates these challenges by allowing users to opt-in to MFA when they want. Also if there's a problem with the users MFA settings, they can use SSMFA to clear their MFA settings and restart the enrollment process.

SSMFA uses a personal email address to validate a user's identity. Ownership of the email address is established at enrollment. When an MFA settings reset is started the user must verify control of the personal email address on file by clicking on a link.

SSMFA was designed to be deployed in an environment with hybrid on-prem AD and Office 365 accounts synced. You should expect to do a hefty amount of development work to get SSMFA to work the way you want in your environment. This project provides all of the necessary services (except Office 365 of course) to run SSMFA.

## Quickstart

![SSMFA Components](https://github.com/hcpss/ssmfa/wiki/images/ssmfa.svg)

To begin development on SSMFA for your environment, you'll need a development system. I recommend linux with docker and docker-compose installed. The hostname for SSMFA and all the dev services is set to `ssmfa.example.com`. Create an entry in your `/etc/hosts` file for this name.

##### Clone the repo, build, up

```
git clone https://github.com/HCPSS/ssmfa.git
cd ssmfa
docker-compose build
docker-compose up
```

Open your browser to `https://ssmfa.example.com`

