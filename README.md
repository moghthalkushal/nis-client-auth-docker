# nis-client-auth-docker
Assumption : NIS Server is running 

Docker Container with NIS Authentication - Client Configuration only

docker build -t ldap-nis-client .

To run with NIS Configuration

docker run --env-file .\NIS.env  -d  --privileged=TRUE -P  -u 0 ldap-nis-client

Sample .env file :

DOMAIN_NAME=YP.INDIA
NAME_SERVER_IP=0.0.0.0
NAME_SERVER_FIRST=fire
NAME_SERVER=fire.domain.net
MOUNT_PATH=fire.domain.net:/usr/people 
