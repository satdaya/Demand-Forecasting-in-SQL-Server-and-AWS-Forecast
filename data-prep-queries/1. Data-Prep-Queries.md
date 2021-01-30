The first step requires extracting the shipped data from the SQL Server database feeding the ERP.  Often the forecasting hierarchy will be determined by the operations and SIOP teams, and often is not in the ERP.  

In this particular case, I have two fact tables. 1. A customer hierarchy. 2. A sku hierarchy.

 The first priority was obtaining both historical order and historical shipped data by unit and gross $. The company this was sytem was designed for ships approximately 80,000 sku's across approximately 2,500 unique billable customers. If every customer ordered every sku, that would be 212,500,000 unique forecasts each month, or 2.55 billion forecasts for a 12 month view. This is prohibitively expensive in compute and $.  So the first task: consolidate customers into a hierarchy.  
   
 **1. Customer Hierarchy**
 
Determine customers that drive units and $. Any customers that do not fall into the top customers are placed in a "All Other" bucket.

**2. Sku Level Hierarchy**

**Line Code** - the broadest level of a product

**Class Code** - specific categories under the line code.  

Aggregate fields in the query below:  
  
  a. **gross** - high level dollars. Used for analysis only, as it is not fed into the machine learning model.
  b. **qtyord** - units ordered
  c. **qtyship** - units shipped.
  d. **qtyord_neg_rem** - units ordered with negatives (backorders) zeroed out
  e. **qtyship_neg_rem** - units shipped with negatives (backorders) zeroed out
  c. **frcst_qty** - the base unit level measure of forecasting. qtyship does not accurately capture lost sales due to stockouts, shipping issues, echo (repeatedley ordering product that is not in stock) etc... In this case our forecast base is the qtyship_neg_rem plus 25 % of the variance between qtyord_neg_rem and qtyship_neg_rem. 

This [query](https://github.com/satdaya/Demand-Forecasting-in-SQL-Server-and-AWS-Forecast/blob/master/data-prep-queries/aws_base.sql) prepares the requisite data.

The next step involves prepping the data for AWS Forecast ingestion. 4 fields seems most effective for the primary time series data.

Field 1: **timestamp** AWS Forecast will only read dates in yyyy-MM-dd HH:mm:ss OR yyyy-MM-dd. In this example I will use the latter, as I am forecasting sales by month. When setting the timestamp column, I cast the datetime as VARCHAR type 20. Both DATETIME and DATETIME contain millisecond data that AWS Forecast will not read.

Field 2: **item_id** The unique item identifier

Field 3: **keycust3** The unique customer by territory aggregate

Field 4: **demand** The historical shipped data

This [query](https://github.com/satdaya/Demand-Forecasting-in-SQL-Server-and-AWS-Forecast/blob/master/data-prep-queries/forecast%20input%20data.sql) preps the data for forecast ingestion. 
