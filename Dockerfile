FROM ubuntu:19.10
MAINTAINER kelvin.xue@outlook.com
RUN apt-get update && apt-get install -y apt-transport-https && apt-get install -y python-pip
RUN pip install shadowsocks
RUN sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/g' /usr/local/lib/python2.7/dist-packages/shadowsocks/crypto/openssl.py
RUN ssserver -p 443 -k Calvin123 -m aes-256-cfb --user nobody -d start