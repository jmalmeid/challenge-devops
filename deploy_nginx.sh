#!/usr/bin/env bash
ROUTER=router
echo "Stop \"$ROUTER\" container"
docker-compose rm -f -s -v $ROUTER

echo "Building new \"ROUTER\" container"
docker-compose build $ROUTER
echo "Starting new \"$ROUTER\" container"
docker-compose up -d $ROUTER
rv=$?
if [ $rv -eq 0 ]; then
    echo "New \"$ROUTER\" container started"
else
    echo "Docker compose failed with exit code: $rv"
    echo "Aborting..."
    exit 1
fi

