#!/bin/bash

# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

sh -c "echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind"
sh -c "echo 1 > /proc/sys/net/ipv6/ip_nonlocal_bind"

mkdir /etc/kamailio_pcscf
cp /mnt/pcscf/pcscf.cfg /etc/kamailio_pcscf
cp /mnt/pcscf/pcscf.xml /etc/kamailio_pcscf
cp /mnt/pcscf/kamailio_pcscf.cfg /etc/kamailio_pcscf
cp -r /mnt/pcscf/route /etc/kamailio_pcscf
cp -r /mnt/pcscf/sems /etc/kamailio_pcscf
cp /mnt/pcscf/tls.cfg /etc/kamailio_pcscf
cp /mnt/pcscf/dispatcher.list /etc/kamailio_pcscf

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 5;

# Create PCSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='pcscf'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database pcscf;"
	mysql -u root -h ${MYSQL_IP} pcscf < /usr/local/src/kamailio/utils/kamctl/mysql/standard-create.sql
	mysql -u root -h ${MYSQL_IP} pcscf < /usr/local/src/kamailio/utils/kamctl/mysql/presence-create.sql
	mysql -u root -h ${MYSQL_IP} pcscf < /usr/local/src/kamailio/utils/kamctl/mysql/ims_usrloc_pcscf-create.sql
	mysql -u root -h ${MYSQL_IP} pcscf < /usr/local/src/kamailio/utils/kamctl/mysql/ims_dialog-create.sql
	mysql -u root -h ${MYSQL_IP} -e "grant delete,insert,select,update on pcscf.* to pcscf@$PCSCF_IP identified by 'heslo';"
	mysql -u root -h ${MYSQL_IP} -e "GRANT ALL PRIVILEGES ON pcscf.* TO 'pcscf'@'%' identified by 'heslo';"
	mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
fi

# if [ ! -z "$PCSCF_PUB_IP" ]
# then
# 	sed -i 's|#!define IPSEC_LISTEN_ADDR "PCSCF_IP"|##!define IPSEC_LISTEN_ADDR "PCSCF_IP"|g' /etc/kamailio_pcscf/pcscf.cfg
# 	sed -i 's|##!define IPSEC_LISTEN_ADDR "PCSCF_PUB_IP"|#!define IPSEC_LISTEN_ADDR "PCSCF_PUB_IP"|g' /etc/kamailio_pcscf/pcscf.cfg
# 	sed -i 's|listen=udp:PCSCF_IP:5060|#listen=udp:PCSCF_IP:5060|g' /etc/kamailio_pcscf/pcscf.cfg
# 	sed -i 's|#listen=udp:PCSCF_IP:5060 advertise PCSCF_PUB_IP:5060|listen=udp:PCSCF_IP:5060 advertise PCSCF_PUB_IP:5060|g' /etc/kamailio_pcscf/pcscf.cfg
# 	sed -i 's|#!define RX_AF_SIGNALING_IP "PCSCF_IP"|##!define RX_AF_SIGNALING_IP "PCSCF_IP"|g' /etc/kamailio_pcscf/pcscf.cfg
# 	sed -i 's|##!define RX_AF_SIGNALING_IP "PCSCF_PUB_IP"|#!define RX_AF_SIGNALING_IP "PCSCF_PUB_IP"|g' /etc/kamailio_pcscf/pcscf.cfg
# fi

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|PCSCF_PUB_IP|'$PCSCF_PUB_IP'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_pcscf/pcscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_pcscf/pcscf.cfg

sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' /etc/kamailio_pcscf/pcscf.xml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_pcscf/pcscf.xml
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' /etc/kamailio_pcscf/pcscf.xml

sed -i 's|RTPENGINE_IP|'$RTPENGINE_IP'|g' /etc/kamailio_pcscf/kamailio_pcscf.cfg
