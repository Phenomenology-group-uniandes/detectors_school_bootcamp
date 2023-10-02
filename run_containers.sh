#!/bin/bash

# Pull the latest changes from the git repository
git pull ;

# Build the Docker image with the tag "ds_jupyter_server" and no cache
docker build -t ds_jupyter_server . ;

# Run 20 containers, linking port 8080 of each container with a port in 9000-9020
for i in {9000..9019}
do
  container_name="ds_jupyter_server_$i"
  docker run -d -p $i:8080 --name $container_name ds_jupyter_server
done

echo "Done!"