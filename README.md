# Setup-dcoker-swarm-cluster

## Installation and run

Install this project and project "https://github.com/sydney900/Node-GraphQL-server-and-React-client" in same folder, then start docker terminal and go to the folder and run command
```
./initial_swarm_local_registry_deploy.sh
```
and then open browser at **http://192.168.99.101:63001**. Ip address 192.168.99.101 could be your manager1 ip address. Run command 
```
docker-machine ip manager1
```
to check out your manager1 ip address.

If you'd like to moniter your docker open browser at **http://192.168.99.101:8080**

![alt text](https://github.com/sydney900/Setup-docker-swarm-cluster/blob/master/moniter.png "Moniter Swarm")