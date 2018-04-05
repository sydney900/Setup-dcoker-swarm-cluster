declare -a manager_notes=("manager1" "manager2")
declare -a worker_notes=("worker1" "worker2")

# create manager nodes:
for n in ${manager_notes[@]};
do
   echo "==== Creating manager machine $n...";
   docker-machine create -d virtualbox $n;
done

# create worker nodes:
for n in ${worker_notes[@]};
do 
   echo "==== Creating worker machine $n...";
   docker-machine create -d virtualbox $n;
done

# setup master (first of manager_notes) node to swarm mode
masternode=${manager_notes[0]}
masterip=$(docker-machine ip $masternode)
echo "==== Initializing first swarm manager $masternode..."
docker-machine ssh $masternode "docker swarm init --listen-addr $masterip --advertise-addr $masterip"

# get manager and worker tokens
export manager_token=`docker-machine ssh $masternode "docker swarm join-token manager -q"`
export worker_token=`docker-machine ssh $masternode "docker swarm join-token worker -q"`

# Joinig other manager nodes to the swarm
for n in ${manager_notes[@]:1};
do
	echo "==== $n joining swarm as manager ..."
	docker-machine ssh $n \
		"docker swarm join \
		--token $manager_token \
		--listen-addr $(docker-machine ip $n) \
		--advertise-addr $(docker-machine ip $n) \
		$masterip"
done

# show members of swarm
echo "==== show members of swarm ..."
docker-machine ssh $masternode "docker node ls"


# Joinig worker nodes to the master
for n in ${worker_notes[@]};
do
	echo "==== $n joining swarm as worker ..."
	docker-machine ssh $masternode \
	"docker swarm join \
	--token $worker_token \
	--listen-addr $(docker-machine ip $n) \
	--advertise-addr $(docker-machine ip $n) \
	$masterip:2377"
done

# show members of swarm
echo "==== show members of swarm ..."
docker-machine ssh $masternode "docker node ls"


# Unsetting docker-machine shell variable settings
#docker-machine env -u

# docker-machine ssh manager1 "docker service create -p 80:80 --name web nginx:1.13.9-alpine"
# docker-machine ssh manager1 "docker service ls"
# docker-machine ssh manager1 "docker service inspect web"
# docker-machine ssh manager1 "docker service scale web=7"
# docker-machine ssh manager1 "docker service ls"
# docker-machine ssh manager1 "docker node update --availability drain worker1"
# docker-machine ssh manager1 "docker service ps web"
# docker-machine ssh manager1 "docker node ls"
# docker-machine ssh manager1 "docker service scale web=5"
# docker-machine ssh manager1 "docker service ps web"
# docker-machine ssh manager1 "docker node update --availability active worker1"
# docker-machine ssh manager1 "docker node inspect worker1 --pretty"
# docker-machine ssh manager1 "docker swarm leave --force"
# docker-machine ssh manager2 "docker node ls"
# docker-machine ssh manager2 "docker service rm web"









