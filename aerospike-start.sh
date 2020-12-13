echo "RESTARTING AEROSPIKE SERVER"
#service aerospike restart
/etc/init.d/aerospike restart
echo $?
