I will play the role of a data engineer on the Tasty Bytes team. Tasty Bytes is a fictional food truck company that runs 450 food trucks around the world. Here's the scenario:

I work directly with analysts that track the sales performance of Tasty Bytes food trucks. On occasion, they approach me for help on pinpointing exact causes behind unexpected food truck performance, or for help building pipelines to extract new insights.

Recently, they've approached you with concerns about the performance of a food truck in Hamburg, Germany. Throughout the project, I'll build functionality to help them get answers to their concerns. 

To do this, I've already set up my Snowflake account with Tasty Bytes data imported from S3 bucket.

I also imported data from the snowflake market place named 'FROSTBYTE_WEATHERSOURCE'.

The ultimate goal is to combine the two project, and the final project is a data-engineering project of Tasty Bytes data analysis with dbt tools in snowflake.

dbt tools:/Users/siming/Desktop/vs code/snowflake-data-engineering-course/modern-data-engineering-snowflake
This directory is a dbt-db project. I want to transfer this project to dbt using snowflake instead.
The output should be of the same structure, including data(using broanze, silver and gold or similar), logs, analyses, macros, models, etc and configuration files.

snowflake projects: /Users/siming/Desktop/vs code/snowflake-data-engineering-course/modern-data-engineering-snowflake
Only use the two datasets: FROSTBYTE_WEATHERSOURCE and TASTY_BYTES
You should do the ingestion, transformation, and delivery, following the structure of the existing project.

The delivery is a directory with all needed direcotries and files that can run smoothly without error. These should be ready to clone to my github repo.
I also need an instructing file to guide me step bu step what this project does and how each step is set.