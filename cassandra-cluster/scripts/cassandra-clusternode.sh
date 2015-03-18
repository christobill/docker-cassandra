#!/usr/bin/env bash

# Get running container's IP
IP=`hostname --ip-address`

# 0.0.0.0 Listens on all configured interfaces
# but you must set the broadcast_rpc_address to a value other than 0.0.0.0
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/" $CASSANDRA_CONFIG/cassandra.yaml

# Set broadcast_rpc_address
sed -i -e "s/^# broadcast_rpc_address.*/broadcast_rpc_address: $HOST/" $CASSANDRA_CONFIG/cassandra.yaml

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $HOST/" $CASSANDRA_CONFIG/cassandra.yaml

# Broadcast on IP:port of the container
sed -i -e "s/^# broadcast_address.*/broadcast_address: $HOST/" $CASSANDRA_CONFIG/cassandra.yaml

# Configure Cassandra seeds
if [ -z "$CASSANDRA_SEEDS" ]; then
	echo "No seeds specified, being my own seed..."
        if [ $# == 1 ]; then
            SEEDS="$1"
        else
            SEEDS="$HOST"
        fi
	CASSANDRA_SEEDS=$SEEDS
fi
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$CASSANDRA_SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml

# Most likely not needed
# relates to the folllowing issue (nodetool remote connection issue):
# http://www.datastax.com/documentation/cassandra/2.1/cassandra/troubleshooting/trblshootConnectionsFail_r.html
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$HOST\"" >> $CASSANDRA_CONFIG/cassandra-env.sh


echo "Starting Cassandra on $HOST..."

cassandra -f
