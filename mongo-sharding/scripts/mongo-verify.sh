#!/bin/bash

printf "[Total]\n"
docker compose exec -T mongos-router mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

printf "\n\n[Shard 1]\n"
docker compose exec -T shard-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

printf "\n\n[Shard 2]\n"
docker compose exec -T shard-2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF