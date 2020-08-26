 The AWS exports are broken into smaller pieces. I download the individual forecasts, and aggregate them using the following Python script to concatanate the multiple files:
 
 ```
 
import pandas as pd
import glob

path = r''
all_files = glob.glob(path +"/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0)
    li.append(df)

frame = pd.concat(li, axis=0, ignore_index=True)
frame.to_csv(r'')


 ```

**Create Historical Data for Load**

``` DROP TABLE IF EXISTS [hist_analysis_Aug_Sku_v4];


CREATE TABLE [analysis_historical](
									  
									 [date_use] VARCHAR(12)
									 ,[yr] INT
									 ,[mnth] INT
									 ,[item_id] VARCHAR(54)
									 ,[keycust3] VARCHAR(54)
									 ,[p12] FLOAT
									 ,[p25] FLOAT
									 ,[p38] FLOAT
									 ,[p50] FLOAT
									 ,[p62] FLOAT
									 ,[gross_p12] FLOAT
									 ,[gross_p25] FLOAT
									 ,[gross_p38] FLOAT
									 ,[gross_p50] FLOAT
									 ,[gross_p62] FLOAT
									 ,[qtyord] FLOAT
									 ,[qtyship] FLOAT
									 )
INSERT INTO [analysis_historical](
									 [date_use]
									 ,[yr]
									 ,[mnth]
									 ,[item_id]
									 ,[keycust3]
									 ,[p12]
									 ,[p25]
									 ,[p38]
									 ,[p50]
									 ,[p62]  
									 ,[gross_p12]
									 ,[gross_p25]
									 ,[gross_p38]
									 ,[gross_p50]
									 ,[gross_p62]
									 ,[qtyord]
									 ,[qtyship]
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
		,SUM([qtyord])
		,SUM([qtyship])
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
		ADD [measure] VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [measure2] VARCHAR(54)	 ;

ALTER TABLE [analysis_historical]
		ADD [gross_p12] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p25] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p38] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p50] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p62] NUMERIC(10, 2)
```
**Insert Forecast Data **

```
 INSERT INTO [hist_analysis_Aug_Sku_v4]
			([date_use]
			,[mnth]
			,[yr]
			,[item_id]
			,[keycust3]
			,[p12]
			,[p25]
			,[p38]
			,[p50]
			,[p62]
			,[gross_p12]
			,[gross_p25]
			,[gross_p38]
			,[gross_p50]
			,[gross_p62]

			)
SELECT   [date_use]
		,[mnth]
		,[yr]
		,[item_id]
		,[keycust3]
		,[p12]
		,[p25]
		,[p38]
		,[p50]
		,[p62]
		,[gross_p12]
		,[gross_p25]
		,[gross_p38]
		,[gross_p50]
		,[gross_p62]
		
FROM [8_12_2020_Frcst_Run_Expt]
  ```
  

