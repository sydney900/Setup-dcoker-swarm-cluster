declare -a manager_notes=("master" "slave")
declare -a worker_notes=("work-1" "work-2")

# Now we’ll start manager nodes:
for n in ${manager_notes[@]};do \
   docker-machine start $n
done

# Now we’ll start worker nodes:
for n in ${worker_notes[@]};do \
   docker-machine start $n 
done


# Unsetting docker-machine shell variable settings
docker-machine env -u