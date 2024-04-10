#!/bin/bash
# Push-Authentifizierung per privacyIDEA-Server von der Kommandozeile

PI_SERVER=https://pi.example.net
PI_USER=scooper
PI_TIMEOUT=30

# Die Tools curl und jq müssen installiert sein.
which jq   >/dev/null 2>&1 || (echo "jq fehlt.";   exit 2)
which curl >/dev/null 2>&1 || (echo "curl fehlt."; exit 2)


# Push-Authentifizierung beim privacyIDEA-Server anfragen.
echo -n "Push-Authentifizierung läuft "
tid=$(curl --silent --request POST \
  --data "user=${PI_USER}&pass=" \
  ${PI_SERVER}/validate/check \
  | jq --raw-output '.detail.multi_challenge[0].transaction_id')
#echo "Transaction ID: $tid"

# Kurze Pause, während der Anwender die Smartphone-App startet.
sleep 2

# Regelmäßig beim Server nachfragen, ob der User bestätigt hat.
for i in $(seq 1 ${PI_TIMEOUT}); do

  result=$(curl --silent --request GET \
  --data "transaction_id=${tid}" \
  ${PI_SERVER}/validate/polltransaction \
  | jq --raw-output '.result.authentication')
  echo -n "."

  if [ "${result}" = 'ACCEPT' ] ; then
    echo " akzeptiert."
    exit 0
  fi

  sleep 1
done
echo " abgelehnt."
exit 1
