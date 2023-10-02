#!/bin/bash

# Clean Previous Containers
bash kill_containers.sh

# Pull the latest changes from the git repository
git pull ;

# Build the Docker image with the tag "ds_jupyter_server" and no cache
docker build -t ds_jupyter_server .  ;

# Run 20 containers, linking port 8080 of each container with a port in 9000-9020
for i in {9000..9040}
do
  container_name="ds_jupyter_server_$i"
  docker run -it -t \
  --mount type=bind,source=/disco1,target=/disco1,readonly \
  --mount type=bind,source=/disco2,target=/disco2,readonly \
  --mount type=bind,source=/disco3,target=/disco3,readonly \
  --mount type=bind,source=/disco4,target=/disco4,readonly \
  --mount type=bind,source=/disco1/Madgraph_Simulations,target=/Madgraph_Simulations,readonly \
  --cpus=2 -m=2048m --memory-swap=4096m \
  -d -p $i:8080 --name $container_name ds_jupyter_server
done

echo "Done!"