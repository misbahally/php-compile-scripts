#!/bin/bash
VERSION=php-7.1.26
GIT_REPO=https://github.com/php/php-src.git
TAR_GZ=http://au1.php.net/distributions/${VERSION}.tar.gz
INSTALL_PATH=/opt/${VERSION}m
SRC_PATH=/usr/local/src

# Cleanup
rm -rf pkg
mkdir pkg

echo "#!/bin/bash
yum install -y epel-release
yum install -y git gcc gcc-c++ make libxml2-devel pkgconfig openssl-devel \
	bzip2-devel curl-devel libpng-devel libjpeg-devel libXpm-devel freetype-devel \
	gmp-devel libmcrypt-devel mariadb-devel aspell-devel recode-devel autoconf bison \
	re2c libicu-devel m install libwebp-devel readline-devel libxslt-devel
mkdir -v -p $INSTALL_PATH $SRC_PATH 
if [ -z $TAR_GZ ]; then
	git clone $GIT_REPO $SRC_PATH/$VERSION
	cd $SRC_PATH/$VERSION
	git checkout $GIT_TAG
else
	curl $TAR_GZ > $VERSION.tar.gz
	tar -xzvf $VERSION.tar.gz -C $SRC_PATH
	cd $SRC_PATH/$VERSION
fi
./configure \
	--prefix=$INSTALL_PATH \
	--with-config-file-path=$INSTALL_PATH/etc \
	--with-config-file-scan-dir=$INSTALL_PATH/etc/php.d \
	--enable-fpm \
	--with-fpm-user=www-data \
	--with-fpm-group=www-data \
	--disable-short-tags \
	--enable-opcache \
	--enable-inline-optimization \
	--with-openssl \
	--with-pcre-regex \
	--with-pcre-jit \
	--with-zlib \
	--enable-bcmath \
	--with-bz2 \
	--enable-calendar \
	--with-curl \
	--enable-exif \
	--with-gd \
	--enable-mbstring \
	--with-mysqli \
	--with-mysql-sock \
	--enable-pcntl \
	--with-pdo-mysql \
	--enable-soap \
	--enable-sockets \
	--with-xmlrpc \
	--enable-zip \
	--with-webp-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--enable-ftp \
	--with-gettext \
	--with-gmp \
	--with-mcrypt \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--with-xsl \
	--enable-wddx \
	--with-libxml-dir \
	--with-freetype-dir \
	--with-iconv-dir \
	--enable-shmop \
	--with-readline \
	--enable-intl \
	--with-xpm-dir \
	--with-mhash \
&& make \
&& make install \
&& tar -czf /pkg/$VERSION.tar.gz $INSTALL_PATH" > pkg/build.sh

chmod +x pkg/build.sh

# Install build dependencies
docker run --rm --name cs6-$GIT_TAG -i -v `pwd`/pkg:/pkg centos:6 /pkg/build.sh
