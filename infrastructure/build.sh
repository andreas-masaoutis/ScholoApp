## The base file with most of the needed software
docker build \
  -f Dockerfile_base \
  -t spark-base .

## The master, mostly exposing ports and entrypoint
docker build \
  -f Dockerfile_master \
  -t spark-master .

## The worker, mostly exposing ports and entrypoint
docker build \
  -f Dockerfile_worker \
  -t spark-worker .

## Different interfaces for interaction, including Jupyter
docker build \
  -f Dockerfile_submit \
  -t spark-submit .

## The MongoDB instance
docker build \
  -f Dockerfile_mongo \
  -t mongo:latest .