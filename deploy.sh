#!/usr/bin/env bash
if grep -q 'proxy_pass http://green-web;' ./services/router/conf.d/router.conf
then
    CURRENT_WEB="green-web"
    NEW_WEB="blue-web"
else
    CURRENT_WEB="blue-web"
    NEW_WEB="green-web"
fi

echo "Removing old \"$NEW_WEB\" container"
docker-compose rm -f -s -v $NEW_WEB

echo "Building new \"$NEW_WEB\" container"
docker-compose build $NEW_WEB
echo "Starting new \"$NEW_WEB\" container"
docker-compose up -d $NEW_WEB
rv=$?
if [ $rv -eq 0 ]; then
    echo "New \"$NEW_WEB\" container started"
else
    echo "Docker compose failed with exit code: $rv"
    echo "Aborting..."
    exit 1
fi

echo "Sleeping 20 seconds"
sleep 20

echo "Checking \"$NEW_WEB\" container"
docker-compose exec -T $NEW_WEB curl -s 127.0.0.1/
rv=$?
n=`docker-compose exec -T $NEW_WEB curl -s 127.0.0.1/ | grep "$NEW_WEB" | wc -l`
if [ $rv -eq 0 ] && [ $n -gt 0 ]; then
    echo "New \"$NEW_WEB\" container passed http check"
else
    echo "\"$NEW_WEB\" container's check failed"
    echo "Aborting..."
    exit 1
fi

echo "Changing router config"
cp ./services/router/conf.d/router.conf ./services/router/conf.d/router.conf.back
sed -i "s|proxy_pass http://.*;|proxy_pass http://$NEW_WEB;|g" ./services/router/conf.d/router.conf

echo "Check router configs"
docker-compose exec -T router nginx -g 'daemon off; master_process on;' -t
rv=$?
if [ $rv -eq 0 ]; then
    echo "New router nginx config is valid"
else
    echo "New router nginx config is not valid"
    echo "Aborting..."
    cp ./services/router/conf.d/router.conf.back ./services/router/conf.d/router.conf
    exit 1
fi

echo "Reload router configs"
docker-compose exec -T router nginx -g 'daemon off; master_process on;' -s reload
rv=$?
if [ $rv -eq 0 ]; then
    echo "Router reloaded"
else
    echo "Router reloading is failed"
    echo "Aborting..."
    cp ./services/router/conf.d/router.conf.back ./services/router/conf.d/router.conf
    exit 1
fi

echo "Sleeping 2 seconds"
sleep 2

echo "Checking new router web"
curl  -s 127.0.0.1/ | grep "$NEW_WEB"
rv=$?
if [ $rv -eq 0 ]; then
    echo "New router web passed http check"
else
    echo "New router web's check failed"
    echo "Aborting..."
    cp ./services/router/conf.d/router.conf.back ./services/router/conf.d/router.conf
    exit 1
fi

echo "All done here! :)"
