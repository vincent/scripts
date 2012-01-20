#!/bin/bash

# Load config file if exists
if test -f config.sh; then
	source config.sh
fi;

# Script usage
function func_usage() {
	echo "$0 generate a federated schema from one DB to another"
    echo "Usage: $0 <user_db_from> <pass_db_from> <host_db_from> <dbname_db_from> <user_db_to> <pass_db_to> <host_db_to> <dbname_db_to>"
}

# If not specified from the config file, use arguments
if test "$old_db_user" = ""; then
	if test $# = 1; then
	    case "$1" in
	      --help | --hel | --he | --h )
	        func_usage; exit 0 ;
	    esac
	else
		if test $# != 10; then
			func_usage; exit 0 ;
		fi;
	fi;

	old_db_user="$1"
	old_db_pass="$2"
	old_db_host="$3"
	old_db_name="$4"
	
	new_db_user="$5"
	new_db_pass="$6"
	new_db_host="$7"
	new_db_name="$8"

	federateddb="${new_db_name}_remote"

	cred_old=" -u$old_db_user -p$old_db_pass -h $old_db_host $old_db_name"
	cred_new=" -u$new_db_user -p$new_db_pass -h $new_db_host $new_db_name"
fi;


echo -n "I will DROP, and CREATE a FEDERATED database from $old_db_host.$old_db_name to $new_db_host.$federateddb ..."

if test ! -f config.sh; then
	echo "Press any key" | read
fi;

echo -n "recreate database.."
echo "DROP DATABASE IF EXISTS $federateddb; CREATE DATABASE $federateddb" | mysql $cred_new
echo "ok"

echo "create all federated tables structure.."
for table in `mysql --batch --skip-column-names $cred_old -e "SHOW TABLES"`; do
	echo "  federate $table"
	mysqldump --no-data $cred_old $table |sed "s/ENGINE=[^ ]*/ENGINE=FEDERATED CONNECTION='mysql:\/\/$old_db_user:$old_db_pass@$old_db_host\/jamendo_live\/$table'/g" | mysql -u$new_db_user -p$new_db_pass -h $new_db_host $federateddb ;
done
echo "ok"












echo

