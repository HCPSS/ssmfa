#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Create environment files
cat << EOF > $SCRIPTPATH/src/environments/environment.ts
export const environment = {
  production: false,
  baseUrl: "$MFA_BASE_URL",
  excludedDomains: "$MFA_EXCLUDED_DOMAINS",
  ssoRedirect: "$SSO_REDIRECT",
  ssoReqToken: "$SSO_REQTOKEN",
  logoUrl: "$MFA_LOGOURL",
  logoutUrl: "$MFA_LOGOUTURL",
  supportUrl: "$MFA_SUPPORT_URL"
}
EOF

# Get favicon
curl -s -o src/favicon.ico $MFA_FAVICONURL

cat $SCRIPTPATH/src/environments/environment.ts | sed 's/production: false/production: true/' > $SCRIPTPATH/src/environments/environment.prod.ts

# get node_modules
npm install

# serve the dev server
ng serve --port 9001 --host 0.0.0.0 --disable-host-check
