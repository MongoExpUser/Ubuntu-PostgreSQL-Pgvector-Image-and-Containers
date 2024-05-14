
# Ubuntu-PostgreSQL-Pgvector-Image-and-Containers

<strong> Create Image and Deploy Containers for PostgreSQL 16 (1 Primary and 1 Replica) with pgvector extension and Manual Failover option for a Weather Application.</strong>

### Architectural Diagram Depicting Postgres Primary and Replica. The Replica is a Synchronous Standby - 'FIRST 1 (*)'
![Image description](https://github.com/MongoExpUser/Ubuntu-PostgreSQL-Pgvector-Image-and-Containers/blob/main/pgsql-pgvector-lambda-arch.png)

### 1) Build Image:                                                                                             
     * Build
       sudo docker build --no-cache -t weather/x86-64/ubuntu-22.04-postgres-16.1-pgvector:latest .

### 2) Edit config files and TLS files in the following path in the repository, as deem necessary:    
     - ./primary/cfg/pg_hba.conf         
     - ./primary/tls/ca.pem:/etc/ssl/certs/ca.pem
     - ./primary/tls/psql-cert.pem
     - ./primary/tls/psql-cert.key
     - ./replica/cfg/pg_hba.conf         
     - ./replica/tls/ca.pem:/etc/ssl/certs/ca.pem
     - ./replica/tls/psql-cert.pem
     - ./replica/tls/psql-cert.key

### 3) Deploy Containers and Destroy with Docker Compose:                                                                                             
     * Deploy containers 
       set PWD=%cd% && sudo docker compose -f docker-compose-psql.yml --project-directory $PWD --project-name "psql-weather-app" up -d
     
     * Stop and remove containers with related network and volumes
       set PWD=%cd% && sudo docker compose -f docker-compose-psql.yml --project-directory $PWD --project-name "psql-weather-app" down && sudo docker volume rm $(docker volume ls -q)

### 4) Stop, Re-Start and Log Services with Docker Compose: 
     * Stop services
       set PWD=%cd% && sudo docker compose -f docker-compose-psql.yml --project-directory $PWD --project-name "psql-weather-app" stop
     
     * Start services
       set PWD=%cd% && sudo docker compose -f docker-compose-psql.yml --project-directory $PWD --project-name "psql-weather-app" start
     
     * Log: view output from containers
       set PWD=%cd% && sudo docker compose -f docker-compose-psql.yml --project-directory $PWD --project-name "psql-weather-app" logs 

### 5) Check Replication Status After Deployment
    * Primary and Replica PostgreSQL Nodes
    sudo docker exec -it psql-node1 /bin/bash -c "sudo -u postgres psql -c 'SELECT pid, state, client_addr, client_port, replay_lsn, sync_state FROM pg_stat_replication;'"
    sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c 'SELECT pid, status, receive_start_lsn, written_lsn, latest_end_lsn, latest_end_time, sender_host, sender_port  FROM pg_stat_wal_receiver;'"


### 6) Confirmation
    * Primary and Replica PostgreSQL Nodes
      Primary State: If the value of "state" is  "streaming" and the values of the remaining parameters are displayed, then the primary is okay and replicating.
      Replica Status: If the value of "status" is "streaming" and the values of the remaining parameters are displayed, it implies the replica is also okay and it is receiving replication data.


### 7) Inspect the Postgres Services and the Container Logs:
     * Primary and Replica PostgreSQL Nodes
       sudo docker exec -it psql-node1 /bin/bash -c  "sudo tail -n 600 -f  /var/log/postgresql/postgresql-16-main.log"
       sudo docker exec -it psql-node2 /bin/bash -c  "sudo tail -n 600 -f  /var/log/postgresql/postgresql-16-main.log"
       sudo docker logs psql-node1 
       sudo docker logs psql-node2

### 8) Interact with Containers/Connect to Containers:                                                                                             
     * Primary and Replica PostgreSQL Nodes
       sudo docker exec -it psql-node1 /bin/bash
       sudo docker exec -it psql-node2 /bin/bash
     
### 9) Connect to PostgreSQL Servers From the Host:                                                                                          
     * Primary and Replica PostgreSQL Nodes
       sudo docker exec -it psql-node1 /bin/bash -c "sudo -u postgres psql"
       sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql"

### 10) Check Configuration Information: Run Directly with Bash:                                                                                                                    
    * Postgresql.conf on  the Primary and Replica PostgreSQL Nodes
      sudo docker exec -it psql-node1 /bin/bash -c "sudo -u postgres psql -c 'TABLE pg_file_settings;'"
      sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c 'TABLE pg_file_settings;'"
    * Pg_hba.conf on the Primary and Replica PostgreSQL Nodes
      sudo docker exec -it psql-node1 /bin/bash -c "sudo -u postgres psql -c 'TABLE pg_hba_file_rules;'"
      sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c 'TABLE pg_hba_file_rules;'"

### 11) Test Failover:
    * Run the following commands on the Standby/Replica (node 2) and promote into Primary.
      sudo docker exec -it psql-node2 /bin/bash -c 'sudo -u postgres psql -c "SELECT pg_promote(wait := FALSE);"'
      sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c \"ALTER SYSTEM SET synchronous_commit TO off;\" "
      sudo docker exec -it psql-node2 /bin/bash -c 'sudo service postgresql restart'
    * The above 3 statements can also be put into a bash script (promote-standy.sh) and execute on the docker host directly.
    * The application(s) can then be switched to point to the NEW Primary (i.e OLD Replica/Standby).

 ### 12) Production Failover:   
    * In production deployment, the database connection logic can be written to ensure that the primary active before any write or ready operation. 
      If not active (that is down), a promotion of the standy/replica can be initiated  with the bash script above (promote-standy.sh).
      After that, application(s) connection string can then be pointed to the NEW Primary (i.e OLD Replica/Standby).
    



# License

Copyright © 2023. MongoExpUser

Licensed under the MIT license.
