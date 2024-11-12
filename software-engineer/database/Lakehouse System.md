---
title: Lakehouse System
date: 2024-11-12T12:20
dg-publish: true
dg-permalink: software-engineer/database/Lakehouse System
description:
---
## Lakehouse System

There are a few key technology advancements that have enabled the data lakehouse:
  • metadata layers for data lakes
  • new query engine designs providing high-performance SQL execution on data lakes
  • optimized access for data science and machine learning tools. ([View Highlight](https://read.readwise.io/read/01j3ez59bsxq8q40sdwhvyq4qy))
- **Metadata layers**, like the open source Delta Lake, sit on top of open file formats (e.g. [Parquet files](https://databricks.com/glossary/what-is-parquet)) and track which files are part of different table versions to offer rich management features like ACID-compliant transactions. The metadata layers enable other features common in data lakehouses, like support for streaming I/O (eliminating the need for message buses like Kafka), time travel to old table versions, schema enforcement and evolution, as well as data validation. ([View Highlight](https://read.readwise.io/read/01j3ez7xx1xjhafsk9ccraxjf1))
- While data lakes using low-cost object stores have been slow to access in the past, new query engine designs enable high-performance SQL analysis. These optimizations include caching hot data in RAM/SSDs (possibly transcoded into more efficient formats), data layout optimizations to cluster co-accessed data, auxiliary data structures like statistics and indexes, and vectorized execution on modern CPUs. ([View Highlight](https://read.readwise.io/read/01j3ez96vjm28fd0nqv8gf8vxk))
- Data warehouses have a long history in decision support and business intelligence applications, though were not suited or were expensive for handling unstructured data, semi-structured data, and data with high variety, velocity, and volume. ([View Highlight](https://read.readwise.io/read/01j3ey7pjan60eh0r87may86nz))
    - Note: Challenges of Data Warehousing for Unstructured and Semi-Structured Data: Data warehousing traditionally focuses on structured data, which makes it difficult to manage unstructured and semi-structured data types, such as text documents, images, and social media posts. These data types often lack a predefined schema, leading to complexities in data integration, storage, and retrieval. Additionally, the varying formats and sizes of unstructured data can complicate data analysis, requiring advanced tools and techniques to derive meaningful insights.
- In a two-tier data architecture, data is ETLd from the operational databases into a data lake. This lake stores the data from the entire enterprise in low-cost object storage and is stored in a format compatible with common machine learning tools but is often not organized and maintained well. ([View Highlight](https://read.readwise.io/read/01j3ey3sr75ay4vk2mbh9bga6e))
- Next, a small segment of the critical business data is ETLd once again to be loaded into the data warehouse for business intelligence and data analytics. Due to multiple ETL steps, this two-tier architecture requires regular maintenance and often results in data staleness, a significant concern of data analysts and data scientists ([View Highlight](https://read.readwise.io/read/01j3ey4rcqq3y243a2p4xvp92r))