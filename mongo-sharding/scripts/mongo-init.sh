#!/bin/bash


docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate({ _id : "config_server", configsvr: true, members: [ { _id : 0, host : "configSrv:27017" } ]})
print("config_server-------------------------------")
exit()
EOF 
sleep 5

docker compose exec -T shard1 mongosh --port 27018 <<EOF
print("ZZZZ------------------------------------------")
exit()
EOF
sleep 5

docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate({_id : "shard1", members: [{ _id : 1, host : "shard1:27018" }]})
print("shard1------------------------------------------")
exit()
EOF
sleep 5

docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.initiate({_id : "shard2", members: [{ _id : 2, host : "shard2:27019" }]})
print("shard2-------------------------------------------------")
exit()
EOF

sleep 5

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard("shard1/shard1:27018")
sh.addShard("shard2/shard2:27019")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
print(db.helloDoc.countDocuments())
print("END--------------------------------------------")
exit()
EOF

sleep 30