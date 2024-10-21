#!/bin/bash


docker compose exec -T mongos_router mongosh --port 27020 <<EOF
use somedb;
print("mongos_router: " + db.helloDoc.countDocuments())
exit()
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF
use somedb
print("shard2: " + db.helloDoc.countDocuments())
exit()
EOF

docker compose exec -T shard1 mongosh --port 27018 <<EOF
use somedb
print("shard1: " + db.helloDoc.countDocuments())
exit()
EOF


sleep 30
