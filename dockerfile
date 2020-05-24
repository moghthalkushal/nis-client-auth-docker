FROM ubuntu
USER root

# SET ENVIRONMENT VARIABLES FOR CONFIG SETTINGS
ENV AUTH_CONFIG=$AUTH_CONFIG
ENV DOMAIN_NAME=$DOMAIN_NAME
ENV NAME_SERVER_IP=$NAME_SERVER_IP
ENV NAME_SERVER_FIRST=$NAME_SERVER_FIRST
ENV NAME_SERVER=$NAME_SERVER
ENV MOUNT_PATH=$MOUNT_PATH

# GENERIC TOOLS AND UPDATES
RUN chmod 777 -R /home
RUN apt-get update -y --fix-missing
RUN apt-get install -y vim

# NIS INSTALLATION 
RUN	 DEBIAN_FRONTEND=noninteractive apt-get install -y nis network-manager portmap
RUN apt-get install -y nfs-common


# SSH INSTALLATION
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:root' |chpasswd && adduser root sudo
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM yes/UsePAM yes/g' /etc/ssh/sshd_config

# SET HOST DETAILS FOR NIS
RUN echo "$NAME_SERVER_IP  $NAME_SERVER_FIRST $NAME_SERVER" >> /etc/hosts

# NIS SSH CONFIGURATIONS
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create a default home directory
RUN echo "session    required   pam_mkhomedir.so skel=/mnt/site/etc/skel/ umask=0022 silent" >> /etc/pam.d/common-account

# NIS CONFIGURATIONS

RUN echo "$DOMAIN_NAME" > /etc/defaultdomain \
	&& echo "rpcbind: $NAME_SERVER" >> /etc/hosts.allow \
	&& echo "rpcbind: $DOMAIN_NAME" >> /etc/hosts.allow \
	&& echo "+::::::" >> /etc/passwd \
	&& echo "+:::" >> /etc/group \
	&& echo "+::::::::" >> /etc/shadow


RUN sed -i 's/\(passwd:.*$\)/\1 nis/' /etc/nsswitch.conf
RUN sed -i 's/\(group:.*$\)/\1 nis/' /etc/nsswitch.conf
RUN sed -i 's/\(shadow:.*$\)/\1 nis/' /etc/nsswitch.conf
RUN sed -i 's/\(hosts:.*$\)/\1 nis/' /etc/nsswitch.conf
RUN echo "${DOMAIN_NAME}" > /etc/defaultdomain

# YP CONCFIGURATION
RUN echo "domain ${DOMAIN_NAME} server ${NAME_SERVER}" >> /etc/yp.conf

RUN domainname $DOMAIN_NAME

# NIS SERVICE RESTART AND MOUNT
RUN service rpcbind restart
RUN service nis start
mount $MOUNT_PATH /home 

EXPOSE 22

CMD [/usr/sbin/sshd, -D]
