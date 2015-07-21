Charlotte R Users Group - SparkR Intro
========================================================
author: Ben Porter
date: 7/20/2015
transition: rotate
transition-speed: slow
Press the right arrow or page down

Goals of this Discussion
========================================================
- Introduce R users to a powerful framework
- A live demo to prove to the R user that provisioning your own cluster isn't too difficult

Motivation for Spark
========================================================
![Spark](spark-logo.png)

Classic map reduce code suffers from two issues:
 - Disk I/O on every pass of the data
 - Lengthy code

***
![Spark](map-reduce.jpg)

Performance
========================================================
[2014 Gray Sort competition](http://sortbenchmark.org/): sort 100 TB of data (1 trillion records)

>"Using Spark on 206 EC2 machines, we sorted 100 TB of data on disk in 23 minutes. In comparison, the previous world record set by Hadoop MapReduce used 2100 machines and took 72 minutes. This means that Spark sorted the same data 3X faster using 10X fewer machines. All the sorting took place on disk (HDFS), without using Spark’s in-memory cache."

[Source](http://databricks.com/blog/2014/11/05/spark-officially-sets-a-new-record-in-large-scale-sorting.html)

What is Spark?
========================================================

<small>- [Open Source Apache project](https://spark.apache.org/), 230 developers from 70 companies</small>

<small>- Loads data into memory to reduce disk I/O</small>

<small>- Piped function results, allowing for chained operations </small>

<small>- Simplified API for dealing with data</small>

<small>- Orders of magnitude faster than map-reduce (10-100x)</small>

<small>- Excels at large scale, iterative processing</small>

<small>- Not limited to data that can fit in memory.</small>
***

<small>Languages Supported:
- Java
- Scala
- Python
- R (as of the 1.4 release, June 11th)

Goals:
- Focus on developer productivity, ease of use
- Reduce multiple special purpose tools
- Adding R was a deliberate attempt to grow the Spark user base outside of CS majors
</small>

R API Maturity on Spark
========================================================
![Spark](spark-stack.png)

Unified framework for distributed computing, machine learning, graph analytics, and streaming data.  There is no performance hit for using R over other languages.
<small> - R API for Spark core and Spark SQL come with v1.4 </small>
<small> - R API for MLlib is coming with v1.5 </small>
<small> - The [Spark Streaming](https://github.com/hlin09/spark/tree/SparkR-streaming) R API is experimental  </small>  
<small> - Graphx (API is TBD) </small>

RDD
========================================================
Resilent Distributed Dataset:
 - Resilent:  if a worker is lost, the data is rebuilt
 - Distributed:  data is distributed across the worker nodes
 - An RDD is just a set of instructions for how to build the data
 - Data is not replicated for resilency, just rebuilt when needed
 
Easily get data into Spark
```r
# from a local data frame
myRDD <- sc.parallelize(localDF)
```
DataFrames in Spark
========================================================
<small>- Name and concept was "inspired" or "borrowed" from the R dataframe
- From the perspective of Spark users, Spark DataFrames are RDDs with a schema
- From the perspective of R users, Spark DataFrames are distributed dataframes

What do we mean, "schema"?
- Column names 
- Data types 
- Automatically generated from the the source data

Use syntax that you know and love on Spark DataFrames</small>
```r
head(sparkDF)
sparkDF$newColumn <- sparkDF$existingColumn * sparkDF["otherColumn"]
```


Transformations, Actions and Lazy Evaluation
========================================================
<small>
Transformations are instructions to create a new RDD...but later
```r
flightsCLTCount <- flightsCLT %>%
  groupBy(flightsCLT$destcityname) %>%
  summarize(delaySum = sum(flightsCLT$arrdelayminutes) ,
            flightCount = count(flightsCLT$arrdelayminutes))
```
Actions asks for a result, full or partial
```r
local_flightsCLTCount <- collect(flightsCLTCount)
head(flightsCLTCount)
take(flightsCLTCount,6)
```

- Lazy Evaluation:  transformations are delayed until an action is called (grocery store example) 
- Spark wants to know everything you want done before it does any work, so it can do it smarter.
</small>

Live Demo
========================================================
Walk through my blog post:  

 - [SparkR on EC2 - Up and Running in 30 Minutes](http://benporter.io/blog/r/sparkr-on-ec2-up-and-running-in-30-minutes)

Data:
 - [Airline Dataset](https://aws.amazon.com/blogs/aws/category/amazon-emr/)
 - 79 GB on disk
 - 162,212,419 records
 - S3 Bucket: s3n://us-east-1.elasticmapreduce.samples/flightdata/input/

Resources 
========================================================

Helpful Links

- [SparkR API Reference](https://spark.apache.org/docs/latest/api/R/index.html)
- [Apache Spark User Group (post questions here)](http://apache-spark-user-list.1001560.n3.nabble.com/)
- [SparkHub - Community Site](http://sparkhub.databricks.com/)
- [Github - Apache Spark - R](https://github.com/apache/spark/tree/master/R)
- [Github - SparkR Package](https://github.com/amplab-extras/SparkR-pkg)
- [Spark Summit Presentations](https://spark-summit.org/2015/)
  - [A Data Frame Abstraction Layer for SparkR](https://spark-summit.org/2015/events/a-data-frame-abstraction-layer-for-sparkr/)
  - [SparkR: The Past, the Present and the Future](https://spark-summit.org/2015/events/sparkr-the-past-the-present-and-the-future/)

Pitfalls
========================================================
With online forums, be sure to to understand the date and version of Spark in question.  Posts prior to mid-June probably aren't relevant anymore for SparkR that shipped with the 1.4 release of Spark.

Spark DataFrames have dplyr-like syntax, not dplyr syntax.  Try breaking up long chains of code into smaller ones if need be and let Spark's catalyst optimizer sort things out.  Or try out the [SparkRext](https://github.com/hoxo-m/SparkRext) package for more dplyr like syntax.
