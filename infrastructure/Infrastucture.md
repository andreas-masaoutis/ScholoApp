# Infrastructure

In this section we will be building the software infrastructure for the ScholApp Big Data Analysis project. For putting this, kind of, guide together, we used three main resources:
- [Apache Spark Cluster on Docker](https://www.kdnuggets.com/2020/07/apache-spark-cluster-docker.html) This one is about setting up an Apache Spark cluster in standalone mode on a single machine.
- [Getting started with MongoDB, PySpark, and Jupyter Notebook](https://www.mongodb.com/blog/post/getting-started-with-mongodb-pyspark-and-jupyter-notebook) This is an extension of the previous, adding a MongoDB database for data persistence.
- [Docker-Spark-Tutorial](https://github.com/sdesilva26/docker-spark/blob/master/TUTORIAL.md) In the last one, there is a thorough exposition of how a Spark cluster works and how to build one using multiple machines.

My re-hash, would not have been possible without these - at least not in this time frame.

## The definition of the problem
Main aim: set-up a local big data cluster using off-the-self-hardware
Motivation: There are certain organisations that have access to cheap hardware, that is underutilised. Examples are university computer labs, all kinds of businesses that provide laptops and workstations to their employees, etc.
There are two sources of cheap underutilised hardware, an absolute and a relative one:
- hardware that are being removed from use
- hardware that is being used only during office hours
Of course, the hardware can be sold on the used-hardware market. But it can also be used internally. What would we gain by getting into the trouble to so so? 
1- A local environment for developers to train
2- A local environment to develop applications that can latter deployed to the cloud
In both scenarios we gain a cost reduction in the expenses for a cloud provider, since we utilize computing power that is simply available and unused and we avoid costly mistakes like long running forgotten batch jobs (we assume that the electricity consumption is not greater that the cloud provider expenses). Additionally, we reduce the security risks by staying on a local network.

## Big Data Analytics
For our specific big data analytics demo we are going to use Apache Spark and MongoDB. Each tools addresses each side of the definition we gave on Big Data; that it does not fit in memory, nor in disk. Each tool addresses one side of the problem.

MongoDB is a document database that can be sharded (be broken down into pieces) and be distributed across many nodes. Assuming that a document database is suitable for the available data, then MongoDB offers a solution for storing Terabytes of data.

Apache Spark implements many of the algorithms relevant for data analytics (and Machine Learning) with two additional twists; it distributes the computation across many nodes and does so in memory. In that way, we can do computations even with datasets that do not fit in one machine's memory

What keeps everything together, is Docker. With Docker we can pool together in a swarm many machines that are on the same network and run parts of our processes in isolated 'containers' across the nodes; one for the database, many for the Spark computations, another for the Jupyter Notebook.

With this setting we can handle data that grow big, and we can easily add resources in order to match the side of the data. In the following sections we setup the necessary infrastructure.

## The setup

We assume that we have a collection of machines with docker installed on them, connected to the same network.

There is a scenario variation that we have examined, where some, or even all the machines, are being booted using external resources - in our case Linux bootable usb's. The reason for that is the requirement that some of the machines might be used only during the non-office hours, in which case we would not like to change the installed systems.

### The bootable USBs

For this demo, we have used a permanently installed Lubuntu 22.04 distribution on a USB. 

Lubuntu was chosen over a couple of alternatives like Alpine or Manjaro for: 
- the hardware support which is crucial when assuming that the same USB might be used to boot different machines
- the access to debian repo's which included docker
- the relative lightness on resource use

By choosing permanent installation over booting from RAM we lost on speed, but we can have as many Gigabytes of images on the USB that otherwise should be loaded onto the RAM. It is slow to build the images, but fast to clone to USBs. In this setup, we assume that we build the images once on one USB, and then clone to as many times as the number of machines we are going to use. Of course, any change to the initial images will have to be re-cloned to the rest of the USBs.

If the images we want to use, are relatively small compared to the available RAM we could create a single USB with a persistence layer for the images, and use the boot-to-ram feature of the Linux Kernel. We would then repeatedly load the OS from the single USB to all machines that become available. In that way we would have a single repository of images, and greater speed with the OS, but adding new machines to the cluster would be bottlenecked by the single USB.


### Step 1: Create Dockerfiles and images


#### The Dockerfiles
We have created five Dockerfiles with the templates for the various containers that we are going to use.

- The base installs most of the software that we are going to use: Java, Scala, Python, Spark.
- The master controls and organises
- the workers, that actually perform the calculations
- The submit is where the context for the application is being defined and through which the user interacts with the cluster. For us this will be through a Jupyter notebook.
- The mongo will create the database container


NOTE: If you make any changes, please make sure that the versions of the various pieces of software are compatible.
In our case we use Python 3.7, Scala 2.12, Spark 3.4.0, Hadoop 3, pymongo 4.3.3, and MongoDB 6.0.6. The requirements file, with the python libraries, is left without specified versions so that changing the python version will not create conflicts with not supported library versions. This choice has the downside that the code might stop working with newer library versions.

#### The images
With
```
bash build.sh
```
we can build all the images from the individual Dockerfiles. The build.sh file repeats the 'docker build' command for each images and assigns an name to each. Modify the file at will, or execute the build commands individually.

#### Multiple machines
When we build the images, we build them on a single machine. Depending on the setup utilised, as explained above, there are some ways to have the images on all machines. Firstly, one can use a repository, push the images to it and then download them to any machine that needs them. Without the use of a repository, either we build the images on every machine using the Dockerfiles, or [copy](https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-using-a-repository) the images themselves from one machine to another.

Of course, in case of a single USB that boots-to-ram, as explained above, we do not need to do that.

### Step 2: Create the swarm

The following command will initialise the swarm in the first machine, which will also be the leader of the swarm

```
docker swarm init
```

The result will be a message like 

```
docker swarm join --token <YOUR_TOKEN> <YOUR_PRIVATE_IP>:2377
```

In each of the rest of the machines we should execute the above, and the machine will join the swarm.


In order to verify that all the machines have properly joined the swarm we should execute in the first machine - the leader of the swarm

```
docker node ls
```

and the result will be a list of all the nodes in the swarm, with ID,  hostname, etc.


### Step 3: Create the overlay network

Now we should create an attachable overlay network. Docker has five kinds of networks; the overlay allows the creation of a network spanning multiple docker hosts. That will be particularly useful since in this way containers can communicate among them using their identifiers, without the need to manually configure all the ports.

Before the creation of our new overlay network, there should be at least five networks. The ones with the names bridge, host, and none, are the defaults. The docker_gwbridge and ingress, are the ones created by the swarm init. There might be other user-created networks as well.

Let us create the network on the swarm leader

```
docker network create --driver overlay --attachable desired_network_name
```
 
We could check that it works by starting a container and connecting it to our newly created network
```
docker run -it --name container_name --network newly_created_network --entrypoint /bin/bash image_name
```

With 
```
docker inspect container_name
```

we can verify that our new container is indeed connected to our overlay network


On another machine, list the networks available with

```
docker network ls
```

and notice that our newly_created_network is not there yet.

Start a container that connects to the network, and although not initially present on the machine, the swarm will handle the request.

```
docker run -dit --name container_name --network newly_created_network --entrypoint /bin/bash image_name
```

Now, on the second machine, one can see the newly_created_network in the list of networks. One can also verify that the newly_created_network has the same network ID in both machines; it is the same network.


### Step 4: Create the volume

We are going to use a MongoDB database for storing data, but since the container amd all its data will be gone every time the container will be removed, we need a way to persist the database data. Docker does so with volumes. These are like named 'disks' saved internally by Docker, that are being mapped to a specific folder on a container.

```
docker volume create desired_volume_name
```

For our purposes, we named the new volume mymongo_volume, and it will be mapped to /data/db by using the flag '-v mymongo_volume:/data/db'. The /data/db is the place where MongoDB saves the actual database, so whenever we start a mongo container with this flag, it will load the saved data from the docker volume inside the container. Any changes within the container will be persisted in the volume. In this way our database will persist.

### Step 5: Initialise the containers


1. We start with initialising the swarm at the main machine
```
docker swarm init
``` 
2. You will see a join token, and you can copy and paste this command into the other machines, in order to form a docker swarm. 
The whole command looks like that:
```
docker swarm join --token <YOUR_TOKEN> <main_machine_IP>:2377
```

3. Then on the main machine create the overlay network
``` 
docker network create --driver overlay --attachable spark-net
```
3. Run a spark_master image to create a master container
``` 
docker run -it --rm --name spark-master --network spark-net -p 8080:8080 spark-master:latest
```
*NOTE: it is important to remember the name of this container (spark-master in this case) as this is what other containers in the network will use to resolve its IP address.

4. Check the master web UI and verify it has been setup correctly by going to http://<PUBLIC_IPv4_ADDRESS_OF_spark-masetr_CONTAINER>:8080 or http://<localhost>:8080.

5. Now, on the other machines you can create one or more worker containers, by using 
``` 
docker run -it --rm --name spark-workerX --network spark-net -p 8081:8081 -e MEMORY=1G -e CORES=1 spark-worker:latest
```
NOTE: For each worker, increment the name by 1. For as long each worker is located on different machines, you can map port of the container to the port of the host machine (-p 8081:8081 {host/container} ) without having to increment them as they are located on different host's. If, for some reason you need to have more workers on the same machine, then you need to increment the port numbering (like -p 8082:8081), since the 8081 port on the host is already in use by the previous worker.
    
6. To make sure the workers were added successfully, we can check the master web UI, or through the interactive bash shells where the workers should report that they have successfully registered with the master, while the master should verify that

7. Now we also need a spark-submit container with the Jupyter interface to communicate with the spark master ans submit jobs
``` 
docker run -it --rm --name spark-submit --network spark-net -p 4040:4040 -p 8888:8888 spark-submit:latest
```

8. Next we will need to add the data persistence to the mix; in our case MongoDB.

```
docker run -it --rm --name mymongo --network spark-net -p 27017:27017 -v mymongo_volume:/data/db mongo:5
```

