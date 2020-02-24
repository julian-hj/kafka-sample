#! /bin/bash -e

echo "I feel fetching"
while [ true ]
do
  curl http://api.open-notify.org/iss-now.json 1> /tmp/loc.json 2> /dev/null
  kafkacat -b kafka-service.default:9092 -t iss-location -P -l /tmp/loc.json 
  cat /tmp/loc.json
  echo
  sleep 30
done
