# needed for pipe operator, %>%
install.packages("magrittr")
library(magrittr)

# reference the SparkR library location that comes with the Spark install, not CRAN or Github
library("SparkR", lib.loc="/root/spark/R/lib")
Sys.setenv(SPARK_HOME="/root/spark") # if you use the EC2 scripts, this will not change
# use the master url found on your driver at port 8080
sc <- sparkR.init(master = "spark://ec2-54-145-229-150.compute-1.amazonaws.com:7077", 
                  appName = "AirlineApp",
                  sparkEnvir=list(spark.executor.memory="12g"))

#initialize the sqlContext to use the DataFrame and SQL functionality
sqlContext <- sparkRSQL.init(sc)
sqlContext

# read in the entire 49 GB dataset from S3
flights <- read.df(sqlContext, "s3n://<access id>:<secret>@us-east-1.elasticmapreduce.samples/flightdata/input/", "parquet")

# if you want ot take a sample, here is how to take a 1% sample
#flightsSample <- sample(flights, withReplacement=FALSE, fraction=0.01, seed=12345)

# to cache the entire 49GB in memory
cache(flights)

# prints the schema
printSchema(flights)

head_flights <- head(flights) # first 6 records, 44 seconds
head_flights
nrow_flights <- count(flights) #nrows() took 5 seconds
nrow_flights # 162,212,419

# Example of nesting two functions rather than a pipe operator
head(filter(flights, flights$year > 2008))

# Same example using pipes
filter(flights, flights$year > 2008) %>%
  head()

# Business question: which destination cities have the worst average delay in 2008, leaving from CLT?

# sum of total delay time and flight count for each city
flightsCLTCount <- flights %>%
  filter(flights$departurecity == CLT)  # correct this line
  groupBy(flightsdestcityname) %>%
  summarize(delaySum = sum(flights$arrdelayminutes),
            flightCount = count(flights$arrdelayminutes))

# in lieu of mutate step here to demonstrate going back and forth
# compute average delay
flightsCLTCount$avgDelay <- flightsCLTCount$delaySum / flightsCLTCount$flightCount

#can't reference a newly created column in the chain of functions
# select a subset of columns, filter and sort
flightsCLTCountFinal <- flightsCLTCount %>%
  select(flightsCLTCount$destcityname, 
         flightsCLTCount$avgDelay, 
         flightsCLTCount$delaySum, 
         flightsCLTCount$flightCount) %>%
  filter(flightsCLTCount$flightCount>10) %>% #at least 10 flights
  filter(flightsCLTCount$avgDelay>20) %>%  #at least 20 min delay
  arrange(desc(flightsCLTCount$avgDelay)) #sort by average delay, greatest to least

# this collect() action kicks off the execution of the last three steps
flightsCLTCountLocal <- collect(flightsCLTCountFinal)
flightsCLTCountLocal

#############
# Spark SQL #
#############

# link this data so it can used in a SQL statement
registerTempTable(flights, "flightsTempTable")

# count the number of flights for each year
countFlightsByYear <- sql(sqlContext,sqlQuery = "select year, count(*) from flightsTempTable group by year")
collected_year_count <- collect(countFlightsByYear)  # 11 seconds
collected_year_count

