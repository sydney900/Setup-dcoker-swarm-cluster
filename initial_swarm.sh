declare -a manager_notes=("master" "slave")
declare -a worker_notes=("work-1" "work-2")

# Now we’ll create manager nodes:
for n in ${manager_notes[@]};do \
   docker-machine create -d virtualbox $n
done

# Now we’ll create worker nodes:
for n in ${worker_notes[@]};do \
   docker-machine create -d virtualbox $n 
done

# setup master (first of manager_notes) node to swarm mode
masternode=${manager_notes[0]}
echo $masternode
master_ip=$(docker-machine ip $masternode)
eval $(docker-machine env $masternode)
docker swarm init --advertise-addr $master_ip

# Swarm tokens
manager_token=$(docker swarm join-token manager -q)
worker_token=$(docker swarm join-token worker -q)

# Joinig other manager nodes to the master
for n in ${manager_notes[@]:1};do \
  # switch to this machine
  eval $(docker-machine env $n)
  docker swarm join --token $manager_token $master_ip:2377
done

# Joinig worker nodes to the master
for n in ${worker_notes[@]};do \
  # switch to this machine
  eval $(docker-machine env $n)
  docker swarm join --token $worker_token $master_ip:2377
done

# Unsetting docker-machine shell variable settings
docker-machine env -u