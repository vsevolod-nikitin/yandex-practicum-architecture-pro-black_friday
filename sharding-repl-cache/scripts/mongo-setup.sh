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
docker compose exec -T shard-1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard-1",
  members: [
    { _id: 0, host: "shard-1-1:27018" },
    { _id: 1, host: "shard-1-2:27019" },
    { _id: 2, host: "shard-1-3:27020" }
  ]
});
exit();
EOF

printf "\n[Init] shard-2\n"
docker compose exec -T shard-2-1 mongosh --port 27021 --quiet <<EOF
rs.initiate({
  _id: "shard-2",
  members: [
    { _id: 0, host: "shard-2-1:27021" },
    { _id: 1, host: "shard-2-2:27022" },
    { _id: 2, host: "shard-2-3:27023" }
  ]
});
exit();
EOF

sleep 2s # Ждем, пока репликация поднимется

printf "\n[Init] mongos-router\n"
docker compose exec -T mongos-router mongosh --port 27024 --quiet <<EOF
sh.addShard("shard-1/shard-1-1:27018,shard-1-2:27019,shard-1-3:27020");
sh.addShard("shard-2/shard-2-1:27021,shard-2-2:27022,shard-2-3:27023");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });
exit();
EOF