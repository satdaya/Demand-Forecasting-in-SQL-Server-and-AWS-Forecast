**Create Historical Data for Load**

``` DROP TABLE IF EXISTS [analysis_historical]

CREATE TABLE [analysis_historical](
									  
									 [date_use] VARCHAR(12)
									 ,[yr] INT
									 ,[mnth] INT
									 ,[item_id] VARCHAR(54)
									 ,[keycust3] VARCHAR(54)
									 ,[p40] FLOAT
									 ,[p50] FLOAT
									 ,[p60] FLOAT
									 ,[p70] FLOAT
									 ,[p80] FLOAT
									 ,[gross_p40] FLOAT
									 ,[gross_p50] FLOAT
									 ,[gross_p60] FLOAT
									 ,[gross_p70] FLOAT
									 ,[gross_p80] FLOAT
									 )
INSERT INTO [analysis_historical](
									 [date_use]
									 ,[yr]
									 ,[mnth]
									 ,[item_id]
									 ,[keycust3]
									 ,[p40]
									 ,[p50]
									 ,[p60]
									 ,[p70]
									 ,[p80]  
									 ,[gross_p40]
									 ,[gross_p50]
									 ,[gross_p60]
									 ,[gross_p70]
									 ,[gross_p80]
									)
SELECT  
     [year_month]
    ,[yr]
    ,[mnth]
    ,[item_id]
    ,[keycust3]
    ,SUM([frcst_qty])
    ,SUM([frcst_qty])
    ,SUM([frcst_qty])
    ,SUM([frcst_qty])
    ,SUM([frcst_qty])
    ,SUM([gross])
    ,SUM([gross])
    ,SUM([gross])
    ,SUM([gross])
    ,SUM([gross])
FROM [AWS_Stage] 
	 GROUP BY  [year_month]
		   ,[yr]
		   ,[mnth]
		   ,[item_id]
		   ,[keycust3]
	 ORDER BY [year_month]
 ```
**Add Columns to Historical Data** 
 
```
ALTER TABLE [analysis_historical]
		ADD [date_use] VARCHAR(11)
ALTER TABLE [analysis_historical]
		ADD [mnth] INT
ALTER TABLE [analysis_historical]
		ADD [yr] INT
ALTER TABLE [analysis_historical]
		ADD [gross25] NUMERIC(10, 2)
ALTER TABLE [analysis_historical]
		ADD [gross38] NUMERIC(10, 2)
ALTER TABLE [analysis_historical]
		ADD [gross50] NUMERIC(10, 2)
ALTER TABLE [analysis_historical]
		ADD [gross62] NUMERIC(10, 2)
ALTER TABLE [analysis_historical]
		ADD [gross75] NUMERIC(10, 2)
ALTER TABLE [analysis_historical]
		ADD [measure] VARCHAR(54)
ALTER TABLE[analysis_historical]
		ADD [measure2] VARCHAR(54) 
```
**Update Added Columns**

```
UPDATE [analysis_historical]
   SET [date_use] = DATEADD(dd, 1, [date]) ;

UPDATE [analysis_historical]
   SET [mnth] = MONTH([date_use]);

UPDATE [analysis_historical]
   SET [yr] = YEAR([date_use]); 

UPDATE [analysis_historical]
   SET [p25] = CASE WHEN [p25] < 0 THEN 0 ELSE [p25] END ;

UPDATE [analysis_historical]
   SET [p38] = CASE WHEN [p38] < 0 THEN 0 ELSE [p38] END ;

UPDATE [analysis_historical]
   SET [p50] = CASE WHEN [p50] < 0 THEN 0 ELSE [p50] END ;

UPDATE [analysis_historical]
   SET [p62] = CASE WHEN [p62] < 0 THEN 0 ELSE [p62] END ;

UPDATE [analysis_historical]
   SET [p75] = CASE WHEN [p75] < 0 THEN 0 ELSE [p75] END ;

UPDATE [analysis_historical]
   SET [gross25] = [analysis_historical].[p25] * [50%_price].[50%_jobber]
					 FROM [analysis_historical]
					 JOIN [50%_price]
					   ON [analysis_historical].[item_id] = [50%_price].[item_id];

UPDATE [analysis_historical]
   SET [gross38] = [analysis_historical].[p38] * [50%_price].[50%_jobber]
					 FROM [analysis_historical]
					 JOIN [50%_price]
					ON  [analysis_historical].[item_id] = [50%_price].[item_id];

UPDATE [analysis_historical]
   SET [gross50] = [analysis_historical].[p50] * [50%_price].[50%_jobber]
					 FROM [analysis_historical]
					 JOIN [50%_price]
					ON  [analysis_historical].[item_id] = [50%_price].[item_id];

UPDATE [analysis_historical]
   SET [gross62] = [analysis_historical].[p62] * [50%_price].[50%_jobber]
					 FROM [analysis_historical]
					 JOIN [50%_price]
					ON  [analysis_historical].[item_id] = [50%_price].[item_id];
					

UPDATE [analysis_historical]
   SET [gross75] = [analysis_historical].[p75] * [50%_price].[50%_jobber]
					 FROM [analysis_historical]
					 JOIN [50%_price]
					ON  [analysis_historical].[item_id] = [50%_price].[item_id];


UPDATE [analysis_historical]
   SET [measure] = 'forecast';

UPDATE [analysis_historical]
   SET [measure2] = CONCAT([yr],[measure]);
  ```
  
 **Update Measure**
```
 ALTER TABLE [analysis_historical]
		ADD [measure] VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [measure2] VARCHAR(54)

UPDATE [analysis_historical]
   SET [measure] = 'actuals';

UPDATE [analysis_historical]
   SET [measure2] = CONCAT([yr],[measure]); 
```
