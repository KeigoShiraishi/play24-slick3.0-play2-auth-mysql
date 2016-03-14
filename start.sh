#!/bin/sh

./activator dist
cd target/universal/
rm -rf play24-slick3.0-play2-auth-mysql-1_0_0
unzip play24-slick3.0-play2-auth-mysql.zip
./play24-slick3.0-play2-auth-mysql/bin/play24-slick3-auth-example
