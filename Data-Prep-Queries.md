The first step requires extracting the shipped data from the SQL Server database feeding the ERP.  Often the forecasting hierarchy will be determined by the operations and SIOP teams, and often is not in the ERP.  

In this particular case, I have two fact tables. 1. A customer hierarchy. 2. A sku hierarchy.

  The first priority was obtaining both historical order and historical shipped data by unit and gross $. The company ships approximately 85,000 sku's across approximately 2,500 unique billable customers. If every customer ordered every sku, we would not to generate 212,500,000 unique forecasts for each month, or 2.55 billion forecasts for a 12 month view. This is prohibitively expensive in compute and $.  So the first task: consolidate customers into a hierarchy.  
  
 **1. Customer Hierarchy  
 
 **Key customer hierarchy - level 1:** Top customers (those driving the most revenue). Any customer that does not meet a certain revenue threshold falls into an "All Other" bucket. This will be referred to as **Key Customer 1** going forward.
  
 **Key customer hierarchy - level 2:** Territory (corresponding to rep groups). This will be referred to as **Key Customer 2** going forward.
  
 **Key customer hierarchy - level 3:** Concatanate of level 1 and level 3. Top customer and territory. This will be referred to as **Key Customer 3** going forward.
 
 The forecasting base of the machine learning model is the sku at key customer 3.
 
 For each key customer level, there is a corresponding sales person associated with it. The one exception is the key customer 1 All Other bucket, which the senior sales leader is traditionally responsible for.

**2. Sku Level Hierarchy

**Line Code** - the broadest level of a product

**Class Code** - specific categories under the line code. In this case, numbers

**cc_type (aka Class Code Type)** grouping the class code into easily identifiable groupings. In this case: economy, mid-grade, premium, ultra-premium.  
  
**pop_code** - Item velocity

There are three aggregate fields in the query below:
  
  a. **gross** - high level dollars. Used for analysis only.  
  b. **qtyship** - the quantity of shipped skus.  
  c. **frcst_qty** - the base unit level measure of forecasting. qtyship does not accurately capture lost sales due to stockouts, shipping issues, etc... Quantifying lost orders can be tricky. A customer may order the same product every day until it is in stock. In this case our forecast base is the shipped quantity plus 25 % of the variance between quantity order and quantity shipped. 

```

DROP TABLE IF EXISTS [AWS_Stage]

CREATE TABLE [AWS_Stage] (
						 [mnth]         INT
						,[yr]           INT
						,[year_month]   DATETIME
						,[item_id]      VARCHAR(54)
						,[line_code]    VARCHAR(54)
						,[class_code]   VARCHAR(54)
						,[cc_type]      VARCHAR(54)
						,[pop_code]     VARCHAR(54)
						,[keycust1]     VARCHAR(54)
						,[territory]    VARCHAR(54)
						,[keycust3]     VARCHAR(54)
						,[sales1]       VARCHAR(54)
						,[sales2]       VARCHAR(54)
						,[sales3]       VARCHAR(54)
						,[gross]        NUMERIC(10, 2)
						,[qtyship]      NUMERIC(10, 2)
						,[frcst_qty]    NUMERIC(10, 2)
						) 
						
INSERT INTO [AWS_Stage] (
						 [mnth]
						,[yr]
						,[year_month]
						,[item_id]
						,[line_code]
						,[class_code]
						,[cc_type]
						,[pop_code]
						,[keycust1]
						,[territory]
						,[keycust3]
						,[sales1]
						,[sales2]
						,[sales3]
						,[gross]
						,[qtyship]
						,[frcst_qty]
						)
SELECT 
         [masterlist].[Month]                                                           AS [mnth]
        ,[masterlist].[Year]                                                            AS [yr]	
        ,[masterlist].[Year_Month]                                                      AS [year_month]
        ,[masterlist].[PartNumber]                                                      AS [item_id]
        ,[masterlist].[LineCode]                                                        AS [line_code]
        ,[masterlist].[ClassCode]                                                       AS [class_code]
        ,[ilu].[cc_type]                                                                AS [cc_type]
        ,[ilu].[pop_code]                                                               AS [pop_code]
        ,[ah].[keycust1]                                                                AS [keycust1]
        ,[ah].[keycust2]                                                                AS [keycust2]
        ,[ah].[keycust3]                                                                AS [keycust2]
        ,[ah].[sales1]                                                                  AS [sales1]
        ,[ah].[sales2]                                                                  AS [sales2]
        ,[ah].[sales3]                                                                  AS [sales3]
        ,SUM(masterlist.[Gross])                                                        AS [Gross]
        ,SUM(masterlist.[QtyShip])                                                      AS [QtyShip]
        ,SUM(masterlist.QtyShip + ( (masterlist.QtyOrd - masterlist.QtyShip) * 0.25) )	AS [Forecast Qty]

FROM (
              SELECT 
                 DISTINCT [AccountNumber]
							  ,MONTH([InvDate])                                 AS [Month]
							  ,YEAR([InvDate])                                  AS [Year]
							  ,DATEADD(MONTH, DATEDIFF(MONTH, 0, [InvDate]), 0) AS [year_month]
							  ,[LineCode]
							  ,[ClassCode]
							  ,[PartNumber]
							  ,SUM([GrossSales])                                AS [gross]
							  ,SUM([QtyShip])                                   AS [qtyship]
							  ,SUM([QtyOrd])                                    AS [qtyord]	  
              FROM [FrcstFactTbl] ff
              GROUP BY   [AccountNumber]
					              ,[LineCode]
					              ,[ClassCode]
					              ,[PartNumber]
					              ,MONTH([InvDate])
					              ,YEAR([InvDate])
					              ,DATEADD(MONTH, DATEDIFF(MONTH, 0, InvDate), 0)
	) AS [masterlist]

LEFT OUTER JOIN [item_lu] ilu
             ON [masterlist].[PartNumber] = [ilu].[part_number]
LEFT OUTER JOIN [account_hierarchy_lu] ah
             ON [masterlist].[AccountNumber] = [ah].[AccountNumber]

GROUP BY   [masterlist].Month
          ,[masterlist].Year
          ,[masterlist].[year_month]
          ,[masterlist].[PartNumber]
          ,[masterlist].[LineCode]
          ,[masterlist].[ClassCode]
          ,[ilu].[cc_type]
          ,[ilu].[pop_code]
          ,[masterlist].[AccountNumber]
          ,[ah].[keycust1]
          ,[ah].[keycust2]
          ,[ah].[keycust3]
          ,[ah].[sales1]
          ,[ah].[sales2]
          ,[ah].[sales3]
          
```
The next step involves prepping the data for AWS Forecast. 4 fields seems  most effective for the primary time series data.

Field 1: **timestamp** AWS Forecast will only read dates in yyyy-MM-dd HH:mm:ss OR yyyy-MM-dd. In this example I will use the latter, as I am forecasting sales by month. When setting the timestamp column, I cast the datetime as VARCHAR type 20. Both DATETIME and DATETIME contain millisecond data that AWS Forecast will not read.

Field 2: **item_id** The unique item identifier

Field 3: **keycust3** The unique customer by territory aggregate

Field 4: **demand** The historical shipped data

AWS Forecast has a 100,000 forecast iteration limit. In this example, I need to partition the data into multiple sets for AWS Forecast ingestion.

```

DROP TABLE IF EXISTS [s3_load_drr_ab]

CREATE TABLE [s3_load_drr_ab] (
				 [year_month] VARCHAR(10)
				,[item_id] VARCHAR(54)
				,[keycust3] VARCHAR(54)
				,[frcst_qty] NUMERIC(10, 0)
				)
INSERT INTO [s3_load_drr_ab] (
                                 [year_month]
                                ,[item_id]
                                ,[keycust3]
                                ,[frcst_qty]
			     )
SELECT  CONVERT (VARCHAR(10), a.[year_month], 20 ) AS [year_month]
       ,a.[item_id]
       ,a.[keycust3]
       ,SUM ( ISNULL(a.[frcst_qty], 0) ) AS [frcst_qty]
  FROM AWS_Stage a
  JOIN (
	     SELECT DISTINCT [item_id]
	       FROM [AWS_Stage]
	      WHERE [yr] in ('2020')
           GROUP BY [item_id]
         HAVING SUM ( ISNULL([frcst_qty], 0) ) >= 0 
		) b 
    ON a.[item_id] = b.[item_id]
 WHERE a.[line_code] IN ('DRR')
   AND a.[pop_code] IN ('a', 'b')
GROUP BY  a.[year_month]
         ,a.[item_id
         ,a.[keycust3]
HAVING SUM(a.[frcst_qty]) > 0
ORDER BY a.[year_month]
```
Sometimes you need to smooth out outlier months. In this example, April 2020 shipped approximately half of a normal month due to COVID 19 pandemic. The query below removes April 2020 and replaces it with an average of the prior 3 months.

```
DROP TABLE IF EXISTS [s3_load_cte_drr_a]

CREATE TABLE [s3_load_cte_drr_a] (
				 [year_month] VARCHAR(10)
				,[item_id] VARCHAR(54)
				,[keycust3] VARCHAR(54)
				,[frcst_qty] NUMERIC(10, 0)
				) ;

WITH items_cte([item_id])
     AS (SELECT [item_id]
         FROM [AWS_Stage]
         WHERE [yr] IN('2020')
         GROUP BY [item_id]
         HAVING SUM(ISNULL([frcst_qty], 0)) >= 0)
	,
     ym_cte([year_month]
            ,[item_id]
            ,[keycust3] 
            ,[frcst_qty])
     AS (SELECT CONVERT(VARCHAR(10), a.[year_month], 20) 
                ,a.[item_id] 
                ,a.[keycust3]
                ,SUM(ISNULL(a.[frcst_qty], 0))
         FROM [AWS_Stage] a
              JOIN items_cte b 
                ON a.[item_id] = b.[item_id]
		WHERE [line_code] IN ('DRR')
		  AND [pop_code] IN ('a')
		  AND [year_month] NOT IN ('2020-08-01')
         GROUP BY  a.[year_month]
                  ,a.[item_id] 
                  ,a.[keycust3])
                  ,
  ym_prior_3_avg_cte([year_month] 
                     ,[item_id]
                     ,[keycust3] 
                     ,[frcst_qty])
     AS (SELECT '2020-04-01' 
                ,[item_id] 
                ,[keycust3]
                --,AVG([frcst_qty]) -- Avg does not work
                ,(SUM ([frcst_qty]) / 3 )
         FROM ym_cte
         WHERE [year_month] IN ('2020-01-01', '2020-02-01', '2020-03-01')
         GROUP BY [year_month]
                  ,[item_id]
                  ,[keycust3])
     INSERT INTO [s3_load_cte_drr_a]
     ( [year_month]  
      ,[item_id]
      ,[keycust3] 
      ,[frcst_qty]
     )
            SELECT *
            FROM ym_cte
            WHERE [year_month] <> '2020-04-01'
            UNION ALL
            SELECT *
            FROM ym_prior_3_avg_cte;
```
