#!/bin/bash
apt install -y build-essential libpcre3-dev libssl-dev libapr1-dev libaprutil1-dev make cmake gcc software-properties-common ca-certificates lsb-release apt-transport-https 

# Installation d'Apache HTTP Server 2.4.49 depuis les sources
cd /tmp
wget https://archive.apache.org/dist/httpd/httpd-2.4.49.tar.gz
tar -xzvf httpd-2.4.49.tar.gz
cd httpd-2.4.49

# Configuration, compilation et installation d'Apache
./configure --prefix=/usr/local/apache2 --enable-mods-shared=all --enable-ssl --enable-so --enable-cgid
make
make install
rm -rf /tmp/httpd-2.4.49.tar.gz /tmp/httpd-2.4.49

sed -i 's/User daemon/User killua/;s/Group daemon/Group user/' /usr/local/apache2/conf/httpd.conf
sed -i '/LoadModule cgid_module modules/s/^#//g' /usr/local/apache2/conf/httpd.conf
sed -i '/<Directory "\/usr\/local\/apache2\/cgi-bin">/ { N; N; s/Options None/Options +ExecCGI/; }' /usr/local/apache2/conf/httpd.conf
