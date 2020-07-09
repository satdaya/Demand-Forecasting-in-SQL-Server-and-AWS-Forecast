# Demand-Forecasting-in-SQL-Server-and-AWS-Forecast

The purpose of this project is to:  
  
  a. Clean and prep historical order/invoice data in SQL Server, building out a customer and sku level hierarchy.
    
  b. Use AWS Forecast to train/deploy a machine learning model to forecast customer demand in monthly buckets.
    
  c. Pipe the resulting forecast back into SQL Server for data cleaning and analysis.
  
  #Data Status  
  The first priority was obtaining both historical order and historical shipped data by unit and gross $. The company ships approximately 85,000 sku's across approximately 2,500 unique billable customers. 
