# ScholoApp: a big data analytics project

## Introduction to the project
This is a demo project that represents a hypothetical situation for a company that has a web application. In general, analytics in a business setting is like the central nervous system - the task is to collect the data from the external and internal environment, process and store the data, and distribute the relevant pieces of information to all parts of the organisation. In other words, business analytics is instrumental for survival in a competitive business environment. 

As organisations grow, so does the complexity and mass of the available data. We are headed towards Big Data. At that point, when the data gets big arises a complication. Now, what do we mean by big?

Well, if the amount of data can fit in the memory of a single computer, then we are talking about small data. Every tool under the sun, designed for data analytics can do the job, even if some of them might be an overkill for the task.

If the amount of data does not fit in memory of a single computer, but do fit in the hard disk, then we are in the territory of medium data. In that case we can use a database, we can process the data in smaller batches, or we can add more memory.

When the data do not fit in memory, nor in the hard disk, the above solutions do not work anymore.

That is where solutions like Apache Spark, that allow distributed computations, and distributed databases like MongoDB get into the picture. Although the data we use in this demo is definitely small, it the kind (user data) that can quickly grow big. In the section on the infrastructure, you can find more details about the proposed solution for tackling the 'Big' part of the problem.

Let us now take a look at the demo environment and its data.

## The ScholoApp Data Challenge

The Scholomance is a Magical School for Wizard children ( our story is adapted from the novel [`A Deadly Education`](https://en.wikipedia.org/wiki/A_Deadly_Education) by Naomi Novik ) ; it is meant to be a safe haven where wizard children can learn magic in a safer environment, until they are able to defend themselves. Maleficaria, or "mals", the mana-eating monsters, are particularly attracted to young sorcerers just after puberty, and ninety-five percent of magic children do not survive to adulthood. 

The school was constructed in the Void, a space outside of reality, and as such has a number of strange properties, even bordering on sentience. It is connected to the physical world at only one point, the graduation gates. Students are magically transported into the Scholomance at age fourteen and have no contact with the outside world until graduation day four years later, when they exit the school via the gates. There are no adults within the school building; students are remotely provided with a curriculum, materials, and assignments. It is no wonder then that both students and the school need a web app that will help with the organisation of the curricular and extra-curricular activities.

### The ScholoApp
We have built the said web application for Scholomance, and its students are the users of the ScholoApp. We have access to the data being produced by the users and we would like to get insights into how the app is being used.

### The dataset
The data come from two sources within the app:
- 1 The User registry that holds 3 pieces of information:
    - The user identification.
    - The timestamp that represents when the user registered with the service.
    - The enrolment year, that takes four values: Freshman, Sophomore, Junior, Senior.
- 2 The Actions registry that holds another 3 pieces of information
    - The user identification.
    - The timestamp that represents when the user performed an action.
    - The kind of action performed chosen from a wide range of actions offered by the app.

### Tentative objectives
Given the data, we have three main objectives:
- 1  We would like to provide an answer to certain questions with respect our users and the ways in which they use the app. In specific:

    - What is the average duration of a user session? For our purposes a session is defined as the time interval between two actions, but only if these actions take place less than 5 minutes apart; if two actions take place more than 5 minutes apart, then they are not part of the same session.

    - Which are the most active students in terms of total time spent performing actions and total number of actions performed?

    - Which students, with respect seniority, are the most active?

- 2 We would like to define a series of useful metrics on user engagement, analyse them and represent them graphically.

- 3 We would like to prepare a presentation for the business stakeholders where we communicate our main findings.


## Known limitations
Please, do not use this as anything else than an introduction to Spark deployed with Docker. In the infrastructure/infrastructure.md one can find a list of proper resources on the subject.

Here is a list of known limitations:
- We use dockerfiles that are not optimised. For example, we have added Scala although we are not planning on using it, and we haven't cleared the pip cache after installation. We should refactor the dockerfiles
- We use Spark 3.4 with Python 3.7, the support for which is deprecated. We should bump up the Python version.
- Instead of utilising the 'Mongo Connector for Spark', which for some reason we could not get it up and running, we use pymongo. If the data becomes properly big, this would be a bottleneck. Operations on MongoDB using pymongo, like selecting documents from a collection, should either be done iteratively, load into Spark document after document, which would be slower, or in batches loaded into Pandas dataframes first- limited by the available RAM on the node running the Jupyter notebook. We should make the connector work.
- Right now we have not set-up MongoDB to have proper replicas, so we are still operating on medium-sized data, instead of properly big data. We should add the replica docker containers.
- There is a problem with accessing files located on the containers, from within the Jupyter notebook for Spark (but not for other libraries like Pandas). Possibly, something with the Hadoop filesystem is not properly set-up. We should make sure that HDFS works. 