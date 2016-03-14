#!/bin/sh

# 起動ファイル転送メモ
# scp -i ~/.ssh/aws_gomi gomi_init.sh ubuntu@54.64.145.14:

###############################
# ミドルウェア、ユーザー設定
###############################

# [users]
# root:r0824
# ubuntu:u0824
# seven:g0824

# [group]
# seven

# [memo]
# port=80にてroot権が必要になったためsevenユーザーは保留

# [middle ware]
# java 8
# mysql 5.7
# [mysql users]
# root:mr0824
# mseven:mm0824

###############################
# 初期設定時一度のみ実行
###############################

homeDir=/home/ubuntu/
mkdir ${homeDir}
cd ${homeDir}

# 作業用ディレクトリの作成
mkdir scripts
mkdir workspace
mkdir downloads
mkdir production
mkdir output

# apt-get update
apt-get -y update
apt-get -y upgrade

# ポート開放の設定
apt-get -y install ufw
ufw enable
ufw default DENY
ufw allow 22/tcp
ufw allow 9443/tcp
ufw allow 9000/tcp

# ユーザーのパスワードの変更
cd scripts
echo 'root:r0824' > seven_account.txt
echo 'ubuntu:u0824' >> seven_account.txt
# echo 'seven:g0824' >> seven_account.txt
cat seven_account.txt | chpasswd 
cd ../

# tools
apt-get -y install git
apt-get -y install unzip
apt-get -y install ssh
apt-get -y install expect
apt-get -y install nodejs
apt-get -y install npm
update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10

# for github keygen
# echo '#!/bin/bash' > "pri-key-gen"
# echo '' >> "pri-key-gen"
# echo 'expect -c "' >> "pri-key-gen"
# echo 'set timeout 10' >> "pri-key-gen"
# echo 'spawn ssh-keygen -t ed25519 -f /root/.ssh/seven_key' >> "pri-key-gen"
# echo 'send \"\n\"' >> "pri-key-gen"
# echo 'expect \"Enter passphrase \(empty for no passphrase\):\"' >> "pri-key-gen"
# echo 'send \"\n\"' >> "pri-key-gen"
# echo 'expect \"Enter same passphrase again:\"' >> "pri-key-gen"
# echo 'send \"\n\"' >> "pri-key-gen"
# echo 'expect eof exit 0' >> "pri-key-gen"
# echo '"' >> "pri-key-gen"

# github ssh config 
echo 'Host github-seven-key' > "/root/.ssh/config"
echo '  User KeigoShiraishi' >> "/root/.ssh/config"
echo '  Port 22' >> "/root/.ssh/config"
echo '  HostName github.com' >> "/root/.ssh/config"
echo '  IdentityFile /root/.ssh/seven' >> "/root/.ssh/config"
echo '  TCPKeepAlive yes' >> "/root/.ssh/config"
echo '  IdentitiesOnly yes' >> "/root/.ssh/config"

echo '-----BEGIN OPENSSH PRIVATE KEY-----' > "/root/.ssh/seven"
echo 'b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW' >> "/root/.ssh/seven"
echo 'QyNTUxOQAAACB3ELrLtAQJhUo4kGjTbOymwGkdNLSs7u728yZxJeb/IgAAAKCBiTZ7gYk2' >> "/root/.ssh/seven"
echo 'ewAAAAtzc2gtZWQyNTUxOQAAACB3ELrLtAQJhUo4kGjTbOymwGkdNLSs7u728yZxJeb/Ig' >> "/root/.ssh/seven"
echo 'AAAEDdRiLPBtkB1Yct+egpNCKzTGOOH0dsuoW4Ab01SI6Wi3cQusu0BAmFSjiQaNNs7KbA' >> "/root/.ssh/seven"
echo 'aR00tKzu7vbzJnEl5v8iAAAAG3NoaXJhaXNoaWtlaWdvQG1ybmMtMi5sb2NhbAEC' >> "/root/.ssh/seven"
echo '-----END OPENSSH PRIVATE KEY-----' >> "/root/.ssh/seven"
chmod 600 /root/.ssh/seven


# application
cd workspace
git clone git@github-seven-key:KeigoShiraishi/play24-slick3.0-play2-auth-mysql.git
cd ../

# java 8
add-apt-repository "ppa:webupd8team/java"
apt-get -y update
apt-get -y install oracle-java8-installer

# mysql 5.7
cd downloads
wget "http://dev.mysql.com/get/mysql-apt-config_0.6.0-1_all.deb"
dpkg -i "mysql-apt-config_0.6.0-1_all.deb"
apt-get -y update
apt-get -y install mysql-server
cd ../

# mysql conf
echo 'character-set-server=utf8' >> "/etc/mysql/my.cnf"
echo '' >> "/etc/mysql/my.cnf"
echo '[mysql]' >> "/etc/mysql/my.cnf"
echo 'default-character-set=utf8' >> "/etc/mysql/my.cnf"

# mysql create db and users
mysql -u root -pmr0824 < "workspace/play24-slick3.0-play2-auth-mysql/conf/evolutions/default/create_db_users.sql"

# mysql remove
# apt-get remove --purge mysql-server* mysql-common
# apt-get autoremove --purge
# rm -rf /etc/mysql
# rm -rf /var/lib/mysql

# sysv-rc-conf
apt-get -y install sysv-rc-conf

###############################
# 起動時に毎時実行するスクリプト群
###############################

# スワップ領域を作成するスクリプト
cd scripts
echo '#!/bin/sh' > "create_swap"
echo 'SWAPFILENAME=/swap.img' >> "create_swap"
echo 'MEMSIZE=`cat /proc/meminfo | grep MemTotal | awk' \''{print $2}'\'' `' >> "create_swap"
echo '' >> "create_swap"
echo '#if [ $MEMSIZE -lt 2097152 ]; then' >> "create_swap"
echo '  SIZE=$((${MEMSIZE}*2))k' >> "create_swap"
echo '#elif [ $MEMSIZE -lt 8388608 ]; then' >> "create_swap"
echo '#  SIZE=${MEMSIZE}k' >> "create_swap"
echo '#elif [ $MEMSIZE -lt 67108864 ]; then' >> "create_swap"
echo '#  SIZE={${MEMSIZE} / 2}k' >> "create_swap"
echo '#else' >> "create_swap"
echo '#  SIZE=4194304k' >> "create_swap"
echo '#fi' >> "create_swap"
echo '' >> "create_swap"
echo '#echo $SIZE' >> "create_swap"
echo 'fallocate -l $SIZE $SWAPFILENAME && mkswap $SWAPFILENAME && swapon $SWAPFILENAME' >> "create_swap"
chmod 755 create_swap
cd ../

# 上記create_swapを自動起動するように設定
cd /etc/init.d/
echo '#! /bin/sh' > "arc_swap"
echo 'case "$1" in' >> "arc_swap"
echo '  start)' >> "arc_swap"
echo '    ./home/ubuntu/scripts/create_swap' >> "arc_swap"
echo '    ;;' >> "arc_swap"
echo '#  stop)' >> "arc_swap"
echo '#    /home/[user_name]/scripts/sample stop' >> "arc_swap"
echo '#    ;;' >> "arc_swap"
echo '  *)' >> "arc_swap"
echo '    echo "Usage: service sample {start|stop}" >&2' >> "arc_swap"
echo '    exit 1' >> "arc_swap"
echo '    ;;' >> "arc_swap"
echo 'esac' >> "arc_swap"
echo '' >> "arc_swap"
echo 'exit 0' >> "arc_swap"
chmod 755 arc_swap
sysv-rc-conf arc_swap on
cd ${homeDir}

# applicationをgitから更新して起動するスクリプト
cd scripts
echo '#! /bin/sh' > "seven_script"
echo '# /etc/init.d/sample' >> "seven_script"
echo '# chmod 755 sample' >> "seven_script"
echo '' >> "seven_script"
echo 'case "$1" in' >> "seven_script"
echo '  start)' >> "seven_script"
echo '    cd /home/ubuntu/workspace/play24-slick3.0-play2-auth-mysql' >> "seven_script"
echo '    git pull' >> "seven_script"
echo '    ./activator playUpdateSecret' >> "seven_script"
echo '    ./activator dist' >> "seven_script"
echo '    cd /home/ubuntu' >> "seven_script"
echo '    rm -rf production/play24-slick3.0-play2-auth-mysql-1_0_0' >> "seven_script"
echo '    unzip workspace/play24-slick3.0-play2-auth-mysql/target/universal/play24-slick3.0-play2-auth-mysql-1_0_0.zip -d production/' >> "seven_script"
echo '    cd production/play24-slick3.0-play2-auth-mysql-1_0_0/bin/' >> "seven_script"
echo '    echo "play24-slick3.0-play2-auth-mysql start"' >> "seven_script"
echo '    ./play24-slick3.0-play2-auth-mysql' >> "seven_script"
echo '    ;;' >> "seven_script"
echo '  stop)' >> "seven_script"
echo '    kill $(cat /home/ubuntu/production/play24-slick3.0-play2-auth-mysql-1_0_0/RUNNING_PID)' >> "seven_script"
echo '    ;;' >> "seven_script"
echo '  *)' >> "seven_script"
echo '    echo "Usage: service seven_script {start|stop}" >&2' >> "seven_script"
echo '    exit 1' >> "seven_script"
echo '    ;;' >> "seven_script"
echo 'esac' >> "seven_script"
echo '' >> "seven_script"
echo 'exit 0' >> "seven_script"
chmod 755 seven_script
cd ../

# 上記seven_scriptを自動起動するように設定
cd /etc/init.d/
echo '#! /bin/sh' > "rc_seven"
echo 'case "$1" in' >> "rc_seven"
echo '  start)' >> "rc_seven"
echo '    ./home/ubuntu/scripts/seven_script start' >> "rc_seven"
echo '    ;;' >> "rc_seven"
echo ' stop)' >> "rc_seven"
echo '    ./home/ubuntu/scripts/seven_script stop' >> "rc_seven"
echo '   ;;' >> "rc_seven"
echo '  *)' >> "rc_seven"
echo '    echo "Usage: service rc_seven  {start|stop}" >&2' >> "rc_seven"
echo '    exit 1' >> "rc_seven"
echo '    ;;' >> "rc_seven"
echo 'esac' >> "rc_seven"
echo 'exit 0' >> "rc_seven"
chmod 755 rc_seven
sysv-rc-conf rc_seven off
cd ${homeDir}

echo "${date}" > "/home/ubuntu/UGOITERUYO.txt"




