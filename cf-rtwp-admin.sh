#!/usr/bin/env bash 

# status=$(cf app rtwp-keycloak | sed -n 3p)
# if [[ $status = "FAILED" ]]; then
#   exit 1
# else
#   keycloak_url=https://$(cf app rtwp-keycloak | awk '{print $2}' | sed -n 5p)/auth
#   echo keycloak_url=$keycloak_url
# fi

keycloak_url='https://rtwp-keycloak.cfapps.us10.hana.ondemand.com/auth'

status=$(cf app nnguyen-rtwp-api | sed -n 3p)
if [[ $status = "FAILED" ]]; then
  exit 1
else
  express_url=https://$(cf app nnguyen-rtwp-api | awk '{print $2}' | sed -n 5p)/
  echo express_url=$express_url
fi

app=nnguyen-rtwp-admin

cd rtwp-admin

npm run build

cf push $app \
    -m 64M \
    -k 128M \
    -b https://github.com/cloudfoundry/nginx-buildpack.git \
    -c '$HOME/cf-custom-command.sh' \
    --no-start

cf se $app KEYCLOAK_URL $keycloak_url
cf se $app KEYCLOAK true
cf se $app EXPRESS_URL $express_url

cf start $app