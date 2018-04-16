declare -a manager_notes=("manager1" "manager2")
#declare -a worker_notes=("worker1")
declare -a worker_notes=("")

# Now we’ll start manager nodes:
for n in ${manager_notes[@]};do \
   #docker-machine regenerate-certs $n
   docker-machine start $n
done

# Now we’ll start worker nodes:
for n in ${worker_notes[@]};do \
   #docker-machine regenerate-certs $n
   docker-machine start $n 
done
#docker-machine regenerate-certs manager2

# Unsetting docker-machine shell variable settings
docker-machine env -u