#!/bin/bash

printf "[Init] configSrv\n"
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [
    { _id: 0, host: "configSrv:27017" }
  ]
});
exit();
EOF

printf "\n[Init] shard-1\n"
docker compose exec -T shard-1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard-1",
  members: [
    { _id: 0, host: "shard-1:27018" }
  ]
});
exit();
EOF

printf "\n[Init] shard-2\n"
docker compose exec -T shard-2 mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "shard-2",
  members: [
    { _id: 0, host: "shard-2:27019" }
  ]
});
exit();
EOF

sleep 2s # Ждем, пока репликация поднимется

printf "\n[Init] mongos-router\n"
docker compose exec -T mongos-router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard-1/shard-1:27018");
sh.addShard("shard-2/shard-2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });
exit();
EOF