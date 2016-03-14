#!/bin/sh

./activator dist
cd target/universal/
rm -rf play24-slick3-auth-example-1.0-SNAPSHOT
unzip play24-slick3-auth-example-1.0-SNAPSHOT.zip
./play24-slick3-auth-example-1.0-SNAPSHOT/bin/play24-slick3-auth-example