**Create Historical Data for Load**

``` DROP TABLE IF EXISTS [analysis_prophet_full_6.16.2020]

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
