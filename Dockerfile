# ***************************************************************************************************************************************
# * Dockerfile                                                                                                                          *
#  **************************************************************************************************************************************
#  *                                                                                                                                    *
#  * @License Starts                                                                                                                    *
#  *                                                                                                                                    *
#  * Copyright © 2023. MongoExpUser.  All Rights Reserved.                                                                              *
#  *                                                                                                                                    *
#  * License: MIT - https://github.com/MongoExpUser/Ubuntu-PostgreSQL-Pgvector-Image-and-Containers/blob/main/LICENSE                   *
#  *                                                                                                                                    *
#  * @License Ends                                                                                                                      *
#  **************************************************************************************************************************************
# *                                                                                                                                     *
# *  Project: Ubuntu-Postgres-Pgvector Image & Containers Project                                                                       *
# *                                                                                                                                     *
# *  This dockerfile creates an image based on:                                                                                         *
# *                                                                                                                                     *
# *   1)  Ubuntu Linux 22.04                                                                                                            *
# *                                                                                                                                     *
# *   2)  Additional Ubuntu Utility Packages                                                                                            *
# *                                                                                                                                     *
# *   3)  PostgreSQL v16  (Architecture: x86_64) with pgvector extension (Vector Storage & Search Capabilities)                         *
# *                                                                                                                                     *
# *   4)  Python v3.x                                                                                                                   *
# *                                                                                                                                     *
# *   5)  Python3-pip                                                                                                                   *
# *                                                                                                                                     *
# *   6)  Python3 Packages: boto3, pg8000, etc.                                                                                         *
# *                                                                                                                                     *
# *   7)  Python3 Awscli Upgrade                                                                                                        *
# *                                                                                                                                     *
# *   8)  Awscli v2                                                                                                                     *
# *                                                                                                                                     *
# *   9)  NodeJS v21.x                                                                                                                  *
# *                                                                                                                                     *
# *   10) NodeJS Packages: @aws-sdk/client-s3, pg, etc.                                                                                 *
# *                                                                                                                                     *
# *   11) Docker 26.1: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin                                 *
# *                                                                                                                                     *
# *   12) Files clean up                                                                                                                *
# *                                                                                                                                     *
# *                                                                                                                                     *
# ***************************************************************************************************************************************

# 1a. Base Image. Version: Any of 22.04, jammy-20230425, jammy. Ref: https://hub.docker.com/_/ubuntu
FROM ubuntu:22.04

# 1b. Labels
LABEL maintainer="MongoExpUser"
LABEL maintainer_email="MongoExpUser@domain.com"
LABEL company="MongoExpUser"
LABEL version="1.0"

# 1c. Create user(s) and add  to the sudoers group
RUN apt-get -y update && apt-get -y install sudo
RUN adduser --disabled-password --gecos 'dbs-1' dbs && adduser dbs sudo
RUN adduser --disabled-password --gecos 'app-1' app && adduser app sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 1c. Make and change to base dir
RUN cd /home/ && sudo mkdir /home/base && cd /home/base && sudo chmod 777 /home/base

# 1d. Update & Upgrade
RUN sudo apt-get -y update 
RUN sudo apt-get -y upgrade 
RUN sudo apt-get -y dist-upgrade
RUN sudo apt-get -y update 

# 2. Additional Ubuntu Packages
RUN  sudo apt-get install -y systemd apt-utils nfs-common nano unzip zip gzip 
RUN sudo apt-get install -y sshpass cmdtest snap nmap net-tools wget curl tcl-tls 
RUN sudo apt-get install -y iputils-ping certbot python3-certbot-apache gnupg gnupg2 telnet 
RUN sudo apt-get install -y aptitude build-essential gcc make screen snapd spamc parted openssl   
RUN sudo apt-get install -y systemd procps spamassassin 

# 3a. Postgresql v16  (Architecture: x86_64)
RUN sudo apt-get -y update 
RUN sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' 
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - 
RUN sudo apt-get -y update 
RUN sudo apt-get -y install postgresql 

# 3b. Pgvector extension (for vector storage and search)
RUN sudo apt install -y postgresql-common 
RUN sudo apt install curl ca-certificates 
RUN sudo install -d /usr/share/postgresql-common/pgdg 
RUN sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc 
RUN sudo apt-get -y install postgresql-16-pgvector 
RUN echo -ne '\n'
# CREATE EXTENSION IF NOT EXISTS vector;  => Add to postgres via docker compose file (docker-compose-psql.yml)

# 4. Python3.x 
RUN sudo apt-get -y install python3  

# 5. Python3-pip
RUN sudo apt-get -y install python3-pip 

# 6. Python3 packages
RUN sudo python3 -m pip install boto3 
RUN sudo -H python3 -m pip install pg8000 psycopg-binary psycopg_pool sb-json-tools jupyterlab jupyterlab-night

# 7. Python3 Awscli upgrade
RUN sudo python3 -m pip install --upgrade awscli 

# 8.  Awscli v2 (Architecture: x86_64)
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
RUN sudo chmod 777 awscliv2.zip 
RUN sudo unzip awscliv2.zip 
RUN sudo ./aws/install 

# 9. Node.js v21.x 
RUN sudo apt-get -y update
RUN sudo apt-get install -y ca-certificates curl gnupg
RUN sudo mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_21.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN sudo apt-get -y update
RUN sudo apt-get install -y nodejs

# 10. Node.js packages
RUN npm install --prefix "/home/base" @aws-sdk/client-s3 pg sqlite3 duckdb 

# 11. Docker 26.1: docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
RUN sudo apt-get -y update 
RUN sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release 
RUN sudo mkdir -m 0755 -p /etc/apt/keyrings 
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
RUN sudo apt-get -y update 
RUN sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 

# 12. Finally, clean up files
RUN sudo rm -rf /var/lib/apt/lists/* 
RUN sudo apt-get autoclean 
RUN sudo apt-get autoremove
