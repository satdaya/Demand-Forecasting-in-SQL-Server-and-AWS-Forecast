# Demand-Forecasting-in-SQL-Server-and-AWS-Forecast

The purpose of this project is to:  
  
  a. Clean and prep historical order/invoice data in SQL Server, building out a customer and sku level hierarchy.
    
  b. Use AWS Forecast to train/deploy a machine learning model to forecast customer demand in monthly buckets using time series history.
    
  c. Pipe the resulting forecast back into SQL Server for data cleaning and analysis.
  
  d. Display the resultant data in PowerBI in a manner accessible to multiple business end users (executive team, sales, operations).
  
  #Data Status  
  The first priority was obtaining both historical order and historical shipped data by unit and gross $. The company ships approximately 85,000 sku's across approximately 2,500 unique billable customers. If every customer ordered every sku, we would not to generate 212,500,000 unique forecasts for each month, or 2.55 billion forecasts for a 12 month view. This is prohibitively expensive in compute and $.  So the first task: consolidate customers into a hierarchy.  
  
  Key customer hierarchy level 1: Top customers (those driving the most revenue). Any customer that does not meet a certain revenue threshold falls into an "All Other" bucket.
  
  Key customer hierarchy level 2: Territory (corresponding to rep groups).
  
  Key customer hierarchy level 3: Concatanate of level 1 and level 3. Top customer and territory.  
