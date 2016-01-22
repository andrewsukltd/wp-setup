#!/bin/bash -e
clear
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "Do you need to setup new MySQL database? (y/n)"
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#VARIABLE= basename "$DIR"
#b= awk '{ print tolower($VARIABLE) }'

read -e setupmysql
if [ "$setupmysql" == y ] ; then
	echo "MySQL Admin User (Enter for default 'root'): "
	read -e mysqluser
		mysqluser=${mysqluser:-root}
	echo "MySQL Admin Password: (Enter for default 'none'): "
	read -s mysqlpass
		mysqlpass=${mysqlpass:-}
	echo "MySQL Host (Enter for default 'localhost'): "
	read -e mysqlhost
		mysqlhost=${mysqlhost:-localhost}
fi



echo "WP Database Name: (Enter for default)"
read -e dbname
echo "WP User: "
read -e dbuser
	dbuser=${dbuser:-root}
echo "WP Password: "
read -s dbpass
	dbpass=${dbpass:-}
#echo "WP Database Table (Enter for default 'dbz_'): "
#read -e dbtable
	dbtable=dbz_
echo "Last chance - sure you want to run the install? (y/n)"
read -e run
if [ "$run" == y ] ; then
	if [ "$setupmysql" == y ] ; then
		echo "============================================"
		echo "Setting up the database."
		echo "============================================"
		#login to MySQL, add database, add user and grant permissions
		dbsetup="CREATE DATABASE IF NOT EXISTS $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@$mysqlhost IDENTIFIED BY '$dbpass';FLUSH PRIVILEGES;"
		
		mysql -u $mysqluser -p $mysqlpass -e "$dbsetup"

		#mysql -u $mysqluser -p $mysqlpass -e "INSERT INTO `databasename`.`wp_users` (`ID`, `user_login`, `user_pass`, `user_nicename`, `user_email`, `user_activation_key`, `user_status`, `display_name`) VALUES ('1', 'admin@', MD5('admin'), 'Admin', 'info@aukglobal.com', '', '0', 'Admin User');"
		#mysql -u $mysqluser -p $mysqlpass -e "INSERT INTO `databasename`.`wp_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`) VALUES (NULL, '1', 'wp_capabilities', 'a:1:{s:13:"administrator";s:1:"1";}');"
		#mysql -u $mysqluser -p $mysqlpass -e "INSERT INTO `databasename`.`wp_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`) VALUES (NULL, '1', 'wp_user_level', '10');"

		if [ $? != "0" ]; then
			echo "============================================"
			echo "[Error]: Database creation failed. Aborting."
			echo "============================================"
			exit 1
		fi
	fi
	echo "============================================"
	echo "Installing WordPress for you."
	echo "============================================"
	#download wordpress
	#echo "Downloading..."
	#curl -O https://wordpress.org/latest.tar.gz
	#unzip wordpress
	#echo "Unpacking..."
	#tar -zxf latest.tar.gz
	#move /wordpress/* files to this dir
	#echo "Moving..."
	#mv wordpress/* ./
	echo "Configuring..."
	#create wp config
	cp public/wp-config-sample.php public/wp-config.php
	#set database details with perl find and replace
	perl -pi -e "s/database_name_here/$dbname/g" public/wp-config.php
	perl -pi -e "s/username_here/$dbuser/g" public/wp-config.php
	perl -pi -e "s/password_here/$dbpass/g" public/wp-config.php
	perl -pi -e "s/wp_/$dbtable/g" public/wp-config.php
	#set WP salts
	perl -i -pe'
	  BEGIN {
	    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
	    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
	    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
	  }
	  s/put your unique phrase here/salt()/ge
	' public/wp-config.php
	#create uploads folder and set permissions
	mkdir public/wp-content/uploads
	chmod 775 public/wp-content/uploads
	#echo "Cleaning..."
	#remove wordpress/ dir
	#rmdir wordpress
	#remove zip file
	#rm latest.tar.gz
	#remove bash script if it exists in this dir
	#[[ -f "$file" ]] && rm "wp.sh"
	echo "========================="
	echo "[Success]: Installation is complete."
	echo "========================="
else
	exit
fi