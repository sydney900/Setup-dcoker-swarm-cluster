declare -a manager_notes=("manager1" "manager2")
#declare -a worker_notes=("worker1")
declare -a worker_notes=("")

# create manager nodes:
for n in ${manager_notes[@]};
do
   echo "==== Creating manager machine $n...";
   docker-machine create -d virtualbox $n;
   if [ $? -ne 0 ]
   then
	  docker-machine start $n
   fi   
done

# create worker nodes:
for n in ${worker_notes[@]};
do 
   echo "==== Creating worker machine $n...";
   docker-machine create -d virtualbox $n;
   if [ $? -ne 0 ]
   then
	  docker-machine start $n
   fi
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
	docker-machine ssh $n \
	"docker swarm join \
	--token $worker_token \
	--listen-addr $(docker-machine ip $n) \
	--advertise-addr $(docker-machine ip $n) \
	$masterip:2377"
done

# show members of swarm
echo "==== show members of swarm ..."
docker-machine ssh $masternode "docker node ls"

eval $(docker-machine env $masternode)

# create local registry
echo "==== create local registry ..."
docker service create --name registry --publish published=5000,target=5000 registry:2

# show registry serive status
echo "==== create local registry ..."
docker service ls

echo "==== build services ..."
eval $(docker-machine env $masternode)
docker-compose build

echo "==== publish to local registry ..."
docker-compose push

echo "==== deply to swarm ..."
eval $(docker-machine env $masternode)
docker stack deploy --compose-file docker-compose.yml nodegraphql

echo "==== show the service in the swarm ..."
docker-machine ssh $masternode "docker stack services nodegraphql"

echo "==== open browser ..."
weburl="http://"$masterip":63001"
explorer $weburl