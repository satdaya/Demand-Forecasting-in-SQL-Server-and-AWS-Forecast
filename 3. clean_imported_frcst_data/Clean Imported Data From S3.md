 The AWS exports to S3 are sharded into 10-27 CSV's per export. I used the following AWS CLI to download all contents of the bucket:
 
 ```
 aws s3 sync <s3 bucket address> <local dir>
 ```
 Make sure to remove any spaces in the local destination address.
 
 Once the files are downloaded, I use the following Python script to concatanate the sharded files:
 
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

Once the data is concatanated, I load the csv into SQL Server via SSMS Import Flat File import.

**Create Historical Data for Analysis**

```
DROP TABLE IF EXISTS [analysis_historical];


CREATE TABLE [analysis_historical](
									  
									 [date_use] VARCHAR(12)
									 ,[yr] INT
									 ,[mnth] INT
									 ,[item_id] VARCHAR(54)
									 ,[keycust4] VARCHAR(54)
									 ,[p20] FLOAT
									 ,[p35] FLOAT
									 ,[p50] FLOAT
									 ,[p65] FLOAT
									 ,[p80] FLOAT
									 ,[gross_p20] FLOAT
									 ,[gross_p35] FLOAT
									 ,[gross_p50] FLOAT
									 ,[gross_p65] FLOAT
									 ,[gross_p80] FLOAT
									 ,[qtyord] FLOAT
									 ,[qtyship] FLOAT
									 )
INSERT INTO [analysis_historical](
									 [date_use]
									 ,[yr]
									 ,[mnth]
									 ,[item_id]
									 ,[keycust4]
									 ,[p20]
									 ,[p35]
									 ,[p50]
									 ,[p65]
									 ,[p80]  
									 ,[gross_p20]
									 ,[gross_p35]
									 ,[gross_p50]
									 ,[gross_p65]
									 ,[gross_p80]
									 ,[qtyord]
									 ,[qtyship]
									)
SELECT  
	 [year_month]
	,[yr]
	,[mnth]
	,[item_id]
	,[keycust4]
	,SUM([qtyship])
	,SUM([qtyship])
	,SUM([qtyship])
        ,SUM([qtyship])
	,SUM([qtyship])
	,SUM([gross])
	,SUM([gross])
	,SUM([gross])
	,SUM([gross])
	,SUM([gross])
	,SUM([qtyord])
	,SUM([qtyship])
FROM [AWS_Stage]
	 GROUP BY [year_month]
                  ,[yr]
		  ,[mnth]
		  ,[item_id]
		  ,[keycust4]
	 ORDER BY [year_month]
	 
 ```
In some cases I need to pull data from disaparate locations. The following uses CTE's to use unique sources for different product categories.

```
DROP TABLE IF EXISTS [hist_analysis_Sept20_Sku_v1];;


CREATE TABLE [hist_analysis_Sept20_Sku_v1](			  
                                            [date_use] VARCHAR(12)
                                           ,[yr] INT
                                           ,[mnth] INT
                                           ,[item_id] VARCHAR(54)
                                           ,[keycust4] VARCHAR(54)
                                           ,[p20] FLOAT
                                           ,[p23] FLOAT
                                           ,[p50] FLOAT
                                           ,[p65] FLOAT
                                           ,[p80] FLOAT
                                           ,[gross_p20] FLOAT
                                           ,[gross_p35] FLOAT
                                           ,[gross_p50] FLOAT
                                           ,[gross_p65] FLOAT
                                           ,[gross_p80] FLOAT
                                           ,[qtyord] FLOAT
                                           ,[qtyship] FLOAT
                                           ) ;

WITH [non_sas_cte] (
                                            [date_use]
                                           ,[yr]
                                           ,[mnth]
                                           ,[item_id]
                                           ,[keycust4]
                                           ,[p20]
                                           ,[p35]
                                           ,[p50]
                                           ,[p65]
                                           ,[p80]
                                           ,[gross_p20]
                                           ,[gross_p35]
                                           ,[gross_p50]
                                           ,[gross_p65]
                                           ,[gross_p80]
                                           ,[qtyord]
                                           ,[qtyship] 
					   ) 
AS(
SELECT  
            [year_month]
            ,[yr]
            ,[mnth]
            ,[item_id]
            ,[keycust4]
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
WHERE [line_code] NOT IN ('SAS')
GROUP BY  [year_month]
            ,[yr]
            ,[mnth]
            ,[item_id]
            ,[keycust4]
            ,[line_code]
	 
) ,

     [sas_cte] ( 
                                            [date_use]
                                           ,[yr]
                                           ,[mnth]
                                           ,[item_id]
                                           ,[keycust4]
                                           ,[p20]
                                           ,[p35]
                                           ,[p50]
					   ,[p65]
                                           ,[p80]
                                           ,[gross_p25]
                                           ,[gross_p35]
                                           ,[gross_p50]
                                           ,[gross_p65]
                                           ,[gross_p80]
                                           ,[qtyord]
                                           ,[qtyship]  ) 
AS ( 
SELECT  
             [year_month]
            ,[yr]
            ,[mnth]
            ,[item_id]
            ,[keycust4]
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
WHERE [line_code] NOT IN ('SAS')
GROUP BY  [year_month]
            ,[yr]
            ,[mnth]
            ,[item_id]
            ,[keycust4]
            ,[line_code]
	 
)

INSERT INTO [hist_analysis_Sept20_Sku_v1](
                                            [date_use]
                                           ,[yr]
                                           ,[mnth]
                                           ,[item_id]
                                           ,[keycust4]
                                           ,[p20]
                                           ,[p35]
                                           ,[p50]
                                           ,[p65]
                                           ,[p80]
                                           ,[gross_p20]
                                           ,[gross_p35]
                                           ,[gross_p50]
                                           ,[gross_p65]
                                           ,[gross_p80]
                                           ,[qtyord]
                                           ,[qtyship]
                                          )
SELECT *
  FROM [non_sas_cte]
UNION ALL
SELECT *
  FROM [sas_cte]
```

**Add Columns to Forecast Data** 
 
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
		ADD [gross_p20] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p35] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p50] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p65] NUMERIC(10, 2);
ALTER TABLE [analysis_historical]
		ADD [gross_p80] NUMERIC(10, 2)
```
**Insert Forecast Data into Historical Data Table**

```
 INSERT INTO [analysis_historical]
			([date_use]
			,[mnth]
			,[yr]
			,[item_id]
			,[keycust4]
                        ,[p20]
                        ,[p35]
                        ,[p50]
			,[p65]
                        ,[p80]
			,[gross_p20]
                        ,[gross_p35]
                        ,[gross_p50]
                        ,[gross_p65]
                        ,[gross_p80]

			)
SELECT   [date_use]
		,[mnth]
		,[yr]
		,[item_id]
		,[keycust4]
		,[p20]
                ,[p35]
                ,[p50]
		,[p65]
                ,[p80]
		,[gross_p20]
                ,[gross_p35]
                ,[gross_p50]
                ,[gross_p65]
                ,[gross_p80]
		
FROM [8_12_2020_Frcst_Run_Expt]
  ```
*** Add Columns to Merged Historical/Forecast***
```
ALTER TABLE [analysis_historical]
		ADD [qrtr]			INT
ALTER TABLE [analysis_historical]
		ADD [line_code]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [lc_prime]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [class_code]	VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [cc_type]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [cc_prime]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [keycust1]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [territory]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [sales1]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [sales2]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [sales3]		VARCHAR(54)
ALTER TABLE [analysis_historical]
		ADD [pop_code]		VARCHAR(54) 
ALTER TABLE [analysis_historical]
		ADD [unit_frcst_use] FLOAT
ALTER TABLE [analysis_historical]
		ADD [$_frcst_use]	FLOAT
		  ;
		  
UPDATE [analysis_historical]
   SET [qrtr] = CASE WHEN [mnth] IN ('1', '2', '3') THEN 1
					 WHEN [mnth] IN ('4', '5', '6') THEN 2
					 WHEN [mnth] IN ('7', '8', '9') THEN 3
					 WHEN [mnth] IN ('10', '11', '12') THEN 4
					 ELSE NULL END;

UPDATE [analysis_historical]
   SET [line_code] = [item_lu].[line_code]
					 FROM [item_lu]
					 JOIN [analysis_historical]
					   ON [item_lu].[part_number] = [analysis_historical].[item_id];

UPDATE [analysis_historical]
   SET [lc_prime] = [lc_prime_lu].[lc_prime]
					 FROM [lc_prime_lu]
					 JOIN [analysis_historical]
					   ON [lc_prime_lu].[line_code] = [analysis_historical].[line_code];

UPDATE [analysis_historical]
   SET [class_code] = [item_lu].[class_code]
					 FROM [item_lu]
					 JOIN [analysis_historical]
					   ON [item_lu].[part_number] = [analysis_historical].[item_id];

UPDATE [analysis_historical]
   SET [cc_type] = [item_lu].[cc_type]
					 FROM [item_lu]
					 JOIN [analysis_historical]
					   ON [item_lu].[part_number] = [analysis_historical].[item_id];

UPDATE [analysis_historical]
   SET [cc_prime] = [item_lu].[cc_prime]
					 FROM [item_lu]
					 JOIN [analysis_historical]
					   ON [item_lu].[part_number] = [analysis_historical].[item_id];

UPDATE [analysis_historical]
   SET [keycust1] = [account_hierarchy_lu 8.8.20].[keycust1]
					 FROM [account_hierarchy_lu 8.8.20]
					 JOIN [analysis_historical]
					   ON [account_hierarchy_lu 8.8.20].[keycust4] = [analysis_historical].[keycust4];

UPDATE [analysis_historical]
   SET [territory] =  [account_hierarchy_lu 8.8.20].[keycust2]
					  FROM [account_hierarchy_lu 8.8.20]
					 JOIN [analysis_historical]
					   ON [account_hierarchy_lu 8.8.20].[keycust4] = [analysis_historical].[keycust4];

UPDATE [analysis_historical]
   SET [sales1] = [account_hierarchy_lu 8.8.20].[sales1]
					  FROM [account_hierarchy_lu 8.8.20]
					 JOIN [analysis_historical]
					   ON [account_hierarchy_lu 8.8.20].[keycust4] = [analysis_historical].[keycust4];

UPDATE [analysis_historical]
   SET [sales2] = [account_hierarchy_lu 8.8.20].[sales2]
					  FROM [account_hierarchy_lu 8.8.20]
					 JOIN [analysis_historical]
					   ON [account_hierarchy_lu 8.8.20].[keycust4] = [analysis_historical].[keycust4];

UPDATE [analysis_historical]
   SET [sales3] = [account_hierarchy_lu 8.8.20].[sales3]
					  FROM [account_hierarchy_lu 8.8.20]
					 JOIN [analysis_historical]
					   ON [account_hierarchy_lu 8.8.20].[keycust4] = [analysis_historical].[keycust4];
*/
UPDATE [analysis_historical]
   SET [measure] = CASE WHEN [yr] IN ('2017', '2018', '2019') THEN 'actuals'
						WHEN [yr] IN ('2020') AND [mnth] IN ('1', '2', '3', '4', '5', '6', '7') THEN 'actuals'
						WHEN [yr] IN ('2020') AND [mnth] IN ('8', '9', '10', '11', '12') THEN 'forecast'
						WHEN [yr] IN ('2021') THEN 'forecast'
						ELSE NULL END

UPDATE [analysis_historical]
   SET [measure2] = CASE WHEN [yr] IN ('2017') THEN ('2017 actuals')
						 WHEN [yr] IN ('2018') THEN ('2018 actuals')
						 WHEN [yr] IN ('2019') THEN ('2019 actuals')
						 WHEN [yr] IN ('2020') AND [mnth] IN ('1', '2', '3', '4', '5', '6', '7') THEN ('2020 actuals')
						 WHEN [yr] IN ('2020') AND [mnth] IN ('8', '9', '10', '11', '12') THEN ('2020 forecast')
						 WHEN [yr] IN ('2021') THEN ('2021 forecast')
						 ELSE NULL END
						 
								


UPDATE [analysis_historical]
   SET [pop_code] = [item_lu].[pop_code]
					 FROM [item_lu]
					 JOIN [analysis_historical]
					   ON [item_lu].[part_number] = [analysis_historical].[item_id];
					
```
