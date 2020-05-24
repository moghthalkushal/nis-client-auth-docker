#!/bin/sh

# NIS SERVICE RESTART AND MOUNT

service rpcbind restart
service nis start
mount $MOUNT_PATH /home 
