declare -a manager_notes=("manager1" "manager2")
#declare -a worker_notes=("worker1")
declare -a worker_notes=("")

# Unsetting docker-machine shell variable settings
docker-machine env -u

# Now we’ll remove manager nodes:
for n in ${manager_notes[@]};do \
   docker-machine rm $n --force
done

# Now we’ll remove worker nodes:
for n in ${worker_notes[@]};do \
   docker-machine rm $n --force
done


