FROM nginxproxy/nginx-proxy
COPY zscaler_certs/ZscalerRootCertificate-2048-SHA256.crt /usr/local/share/ca-certificates/zscaler/ZscalerRootCertificate-2048-SHA256.crt
RUN apt-get update && \
      apt-get upgrade -y && \
      apt-get install -y wget tar apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2 libxml2-dev libssl-dev libyajl-dev pkgconf zlib1g-dev && \
      apt-get install -y --reinstall ca-certificates && \
      mkdir /usr/local/share/ca-certificates/cacert.org && \
      wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt && \
      update-ca-certificates && \
      git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt && \
      git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity.git && \
      cd ModSecurity && \
      git submodule init && \
      git submodule update && \
      ./build.sh && \
      ./configure && \
      make && \
      make install && \
      cd / && \
      git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git && \
      wget http://nginx.org/download/nginx-1.18.0.tar.gz && \
      tar zxvf nginx-1.18.0.tar.gz && \
      cd nginx-1.18.0 && \
      ./configure  --user=root --group=root --with-debug --with-ipv6 --with-http_ssl_module  --with-compat --add-module=/ModSecurity-nginx --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_empty_gif_module --without-http_fastcgi_module --without-http_referer_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module && \
      make && \
      make install && \
      cd / && \
      git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs && \
      cp -R /usr/src/owasp-modsecurity-crs/rules/ /usr/local/nginx/conf/  && \
      mv /usr/local/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example  /usr/local/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf && \
      mv /usr/local/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example  /usr/local/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf && \
      apt-get remove -y --purge apt-utils autoconf automake build-essential git pkgconf && \
      apt-get autoremove -y
COPY modsec_includes.conf /usr/local/nginx/conf/modsec_includes.conf
COPY modsecurity.conf /usr/local/nginx/conf/modsecurity.conf
COPY crs-setup.conf /usr/local/nginx/conf/rules/crs-setup.conf
COPY nginx.tmpl /app/nginx.tmpl
