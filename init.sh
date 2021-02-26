# 1. init docker network
docker network remove efk;
docker network create efk --driver=bridge --subnet=172.254.0.0/16;
