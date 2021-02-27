# 1. init docker network
docker network remove efk;
docker network create efk --driver=bridge --subnet=172.254.0.0/16;
# 2. RAM set
sysctl --write vm.max_map_count=262144;