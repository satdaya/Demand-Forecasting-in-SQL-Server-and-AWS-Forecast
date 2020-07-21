The first step requires extracting the shipped data from the SQL Server database feeding the ERP.  

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
							  ,SUM([GrossSales])		                            AS [gross]
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
