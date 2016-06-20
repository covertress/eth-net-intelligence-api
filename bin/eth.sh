#!/usr/bin/env bash

trap "exit" INT

if [[ -f $(which ec2metadata 2>/dev/null) ]]
then
	# If ec2 instance then get ips from ec2metadata
	LOCALIP=$(ec2metadata --local-ipv4)
	IP=$(ec2metadata --public-ipv4)
else
	# Else get IPs from ifconfig and dig
	LOCALIP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | cut -d':' -f2)
	IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi

echo "Local IP: $LOCALIP"
echo "Public IP: $IP"

if [[ -f $(which geth 2>/dev/null) ]]
then
	echo "Starting gkr"
	echo gkr --rpc --bootnodes "enode://0fb920467bdc123eeee3c132519457967227ed80d255fc210b09bc070fb4612df90532604629f91c3f1912c298d5a20ef4c22824d1be33fef270b07448760362@[::]:17171" --nat "extip:$IP"
	gkr --rpc --bootnodes "enode://382b74a663581fe3559b52521415f9e7ee596f4873e0e88f8406e0e025d6ed1f2bed55f1f9739cab7d1e247cd5bcc4d944add0c282ea7232155da74b895f0e75@[::]:17172" --nat "extip:$IP"
	gkr --rpc --bootnodes "enode://809e1781a9da785ee6084ff38011f771c61ba9dce1e372ca8cbf2de9af119d9df5ded7728bc03f0b765b8ec9d14a3b296e6b248239d6cc8e4b2fbc3d3f9796a1@[::]:17173" --nat "extip:$IP"
elif [[ -f $(which eth 2>/dev/null) ]]
then
	echo "Starting KR"
	echo eth --bootstrap --peers 50 --remote 52.16.188.185:17171 --mining off --json-rpc -v 3 --public-ip $IP --listen-ip $LOCALIP --master $1
	eth --bootstrap --peers 50 --remote 52.16.188.185:17171 --mining off --json-rpc -v 3 --public-ip $IP --listen-ip $LOCALIP --master $1

else
	echo "Krypton was not found!"
	exit 1;
fi
