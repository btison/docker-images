#!/bin/bash
# script to install ruby from source code

set -e

BUILD_DEPENDENCIES="gcc cpp glibc-devel glibc-headers \
  kernel-headers libmpc mpfr zlib-devel openssl-devel \
  keyutils-libs-devel krb5-devel libcom_err-devel \
  libselinux-devel libsepol-devel libverto-devel \
  pcre-devel readline-devel ncurses-devel gdbm-devel"
BUILD_DIR=/tmp/ruby
RUBY_SOURCE_VERSION=ruby-2.3.0
RUBY_SOURCE=http://cache.ruby-lang.org/pub/ruby/2.3/$RUBY_SOURCE_VERSION.tar.gz

yum install -y $BUILD_DEPENDENCIES

mkdir -p $BUILD_DIR
curl $RUBY_SOURCE | tar xz -C $BUILD_DIR
cd $BUILD_DIR/$RUBY_SOURCE_VERSION

./configure --disable-install-rdoc
make
make prefix=/usr/local install

cd /
gem install bundler --no-doc

yum remove -y $BUILD_DEPENDENCIES
yum clean all

rm -rf $BUILD_DIR
