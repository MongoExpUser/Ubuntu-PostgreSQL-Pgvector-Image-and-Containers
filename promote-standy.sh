# ***************************************************************************************************************************************
#  * promote-standy.sh                                                                                                                  *
#  **************************************************************************************************************************************
#  *                                                                                                                                    *
#  * @License Starts                                                                                                                    *
#  *                                                                                                                                    *
#  * Copyright © 2023. MongoExpUser.  All Rights Reserved.                                                                              *
#  *                                                                                                                                    *
#  * icense: MIT - https://github.com/MongoExpUser/Ubuntu-PostgreSQL-Pgvector-Image-and-Containers/blob/main/LICENSE                    *
#  *                                                                                                                                    *
#  * @License Ends                                                                                                                      *
#  **************************************************************************************************************************************
#  *                                                                                                                                    *
#  *  Project: Ubuntu-PostgreSQL Image & Container Project                                                                              *
#  *                                                                                                                                    *
#  *  This script implements the promotion of the node-2 (replica/hot standby) to primary                                               *
#  *                                                                                                                                    *
#  *  Version: PostgresSQL v16                                                                                                          *
#  *                                                                                                                                    *
#  *                                                                                                                                    *
# ***************************************************************************************************************************************


#promote-standy.sh

sudo docker exec -it psql-node2 /bin/bash -c 'sudo -u postgres psql -c "SELECT pg_promote(wait := FALSE);"'

sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c \"ALTER SYSTEM SET synchronous_commit TO off;\" "

sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c \"SELECT * FROM pg_create_physical_replication_slot('main_slot');\" "

sudo docker exec -it psql-node2 /bin/bash -c 'sudo service postgresql restart'

sudo docker exec -it psql-node2 /bin/bash -c "sudo -u postgres psql -c \"ALTER SYSTEM SET synchronous_commit TO on;\" "

