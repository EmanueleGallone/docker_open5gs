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

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

python3 /mnt/pgw/tun_if.py --tun_ifname ogstun --ipv4_range 192.168.100.0/24 --ipv6_range fd84:6aea:c36e:2b69::/64
python3 /mnt/pgw/tun_if.py --tun_ifname ogstun2 --ipv4_range 192.168.101.0/24 --ipv6_range fd1f:76f3:da9b:0101::/64 --nat_rule 'no'

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/pgw/pgw.yaml install/etc/open5gs
cp /mnt/pgw/pgw.conf install/etc/freeDiameter
cp /mnt/pgw/make_certs.sh install/etc/freeDiameter

sed -i 's|PGW_IP|'$PGW_IP'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PGW_IF|'$IF_NAME'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' install/etc/open5gs/pgw.yaml
sed -i 's|PGW_IP|'$PGW_IP'|g' install/etc/freeDiameter/pgw.conf
sed -i 's|PCRF_IP|'$PCRF_IP'|g' install/etc/freeDiameter/pgw.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/pgw.conf
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/freeDiameter/make_certs.sh

# Generate TLS certificates
./install/etc/freeDiameter/make_certs.sh install/etc/freeDiameter

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
