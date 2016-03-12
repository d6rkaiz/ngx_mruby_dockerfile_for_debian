#
# Dockerfile for ngx_mruby on Debian
#

#
# Manual Build
#
# Building
#   docker build -t your_name:ngx_mruby .
#
# custom build
#   mkdir -p onbuild/docker/{conf,hook}
#   create Dockerfile on onbuild:
#     FROM your_name:ngx_mruby
#     MAINTAINER your_name
#   docker build -t your_name:ngx_mruby_done onbuild/
#
# Runing
#   docker run -d -p 10080:80 your_name:ngx_mruby_done
#
# Access
#   curl http://127.0.0.1:10080/mruby-hello
#

FROM debian:latest
MAINTAINER d6rkaiz

ENV NGINX_CONFIG_OPT_ENV \
 --prefix=/usr/local/nginx \
 --with-http_ssl_module \
 --with-http_stub_status_module \
 --with-http_realip_module \
 --with-http_addition_module \
 --with-http_sub_module \
 --with-http_gunzip_module \
 --with-http_gzip_static_module \
 --with-http_random_index_module \
 --with-http_secure_link_module

RUN apt-get -qqy update \
 && apt-get -qqy install git curl wget make gcc libc-dev libc6-dev ruby ruby2.1 ruby2.1-dev rake bison libcurl4-openssl-dev libssl-dev \
    libhiredis-dev libmarkdown2-dev libcap-dev libcgroup-dev libpcre3 libpcre3-dev libmysqlclient-dev \
 && cd /usr/local/src/ && git clone https://github.com/matsumoto-r/ngx_mruby.git \
 && cd /usr/local/src/ngx_mruby && sh build.sh && make install \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 80
EXPOSE 443

ONBUILD ADD docker/hook /usr/local/nginx/hook
ONBUILD ADD docker/conf /usr/local/nginx/conf
ONBUILD ADD docker/conf/nginx.conf /usr/local/nginx/conf/nginx.conf

CMD ["/usr/local/nginx/sbin/nginx"]
