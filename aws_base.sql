DROP TABLE IF EXISTS [aws_base];

CREATE TABLE [aws_base]
  (
   [mnth_date]             INT
  ,[yr_date]               INT
  ,[year_month_date]       DATETIME
  ,[item_id]               VARCHAR(54)
  ,[line_code]             VARCHAR(54)
  ,[class_code]            VARCHAR(54)
  ,[cc_type]               VARCHAR(54)
  ,[pop_code_legacy]       VARCHAR(54)
  ,[pop_code_new]          VARCHAR(54)
  ,[finance_hierarchy]     VARCHAR(54)
  ,[active_flag]           VARCHAR(54)
  ,[Nov_keycust1]          VARCHAR(54)
  ,[Oct_keycust1]          VARCHAR(54)
  ,[Sep_keycust1]          VARCHAR(54)
  ,[Aug_keycust1]          VARCHAR(54)
  ,[Jul_keycust1]          VARCHAR(54)
  ,[keycust1_high_level]   VARCHAR(54)
  ,[keycust2_top_customer] VARCHAR(54)
  ,[keycust3_territory]	   VARCHAR(54)
  ,[keycust4]              VARCHAR(54)
  ,[sales1]                VARCHAR(54)
  ,[sales2]                VARCHAR(54)
  ,[sales3]                VARCHAR(54)
  ,[sales4]                VARCHAR(54)
  ,[gross]                 NUMERIC(18, 2)
  ,[qtyship]               INT
  ,[qtyord]                INT
  ,[qtyord_neg_rem]        INT
  ,[qtyship_neg_rem]       INT
  ,[frcst_qty]             INT
   ) ;

WITH [cte_unconsolidated_dates] (
    [mnth_date]
   ,[yr_date]
   ,[year_month_date]
   ,[item_id]
   ,[line_code]
   ,[class_code]
   ,[cc_type]
   ,[pop_code_legacy]
   ,[pop_code_new]
   ,[finance_hierarchy]
   ,[active_flag]
   ,[Nov_keycust1]
   ,[Oct_keycust1]
   ,[Sep_keycust1]
   ,[Aug_keycust1]
   ,[Jul_keycust1]
   ,[keycust1_high_level]
   ,[keycust2_top_customer]
   ,[keycust3_territory]
   ,[keycust4]
   ,[sales1]
   ,[sales2]
   ,[sales3]
   ,[sales4]
   ,[gross]
   ,[qtyship]
   ,[qtyord]
   ,[qtyord_neg_rem]
   ,[qtyship_neg_rem]
   ,[frcst_qty]
  )

  AS
  (
    SELECT 
      DISTINCT MONTH([FrcstFactTbl].[InvDate])                         AS [mnth_date]
     ,YEAR([FrcstFactTbl].[InvDate])                                   AS [yr]	
     ,DATEADD(MONTH, DATEDIFF(MONTH, 0, [FrcstFactTbl].[InvDate]), 0)  AS [year_month]
     ,[FrcstFactTbl].[PartNumber]                                      AS [item_id]
     ,[FrcstFactTbl].[LineCode]                                        AS [line_code]
     ,[FrcstFactTbl].[ClassCode]                                       AS [class_code]
     ,[ilu].[cc_type]                                                  AS [cc_type]
     ,[ilu].[pop_code]                                                 AS [pop_code_legacy]
     ,[pc].[pop_code]                                                  AS [pop_code_new] 
     ,[ah].[finance_hierarchy]                                         AS [finance_hierarchy]
     ,[ah].[status]                                                    AS [active_flag]
     ,[ah].[Nov_keycust1]                                              AS [Nov_keycust1]
     ,[ah].[Oct_keycust1]                                              AS [Oct_keycust1]
     ,[ah].[Sep_keycust1]                                              AS [Sep_keycust1]
     ,[ah].[Aug_keycust1]                                              AS [Aug_keycust1] 
     ,[ah].[Jul_keycust1]                                              AS [Jul_keycust1]
     ,[ah].[keycust1_high_level]                                       AS [keycust1]
     ,[ah].[keycust2_top_customer]                                     AS [keycust2]
     ,[ah].[keycust3_territory]                                        AS [keycust3]
     ,[ah].[keycust4]                                                  AS [keycust4]
     ,[ah].[sales1]                                                    AS [sales1]
     ,[ah].[sales2]                                                    AS [sales2]
     ,[ah].[sales3]                                                    AS [sales3]
     ,[ah].[sales4]                                                    AS [sales4]
     ,SUM([FrcstFactTbl].[GrossSales])                                 AS [Gross]
     ,SUM([FrcstFactTbl].[QtyShip])                                    AS [QtyShip]
     ,SUM([FrcstFactTbl].[QtyOrd])                                     AS [QtyOrd]
     ,SUM([FrcstFactTbl].[QtyOrdNegRem])                               AS [QtyOrdNegRem]
     ,SUM([FrcstFactTbl].[QtyShipNegRem])                              AS [QtyShipNegRem]
     ,SUM([FrcstFactTbl].[QtyShipNegRem])  
      +
     ( SUM([FrcstFactTbl].[QtyOrdNegRem]) 
        - 
       SUM([FrcstFactTbl].[QtyShipNegRem])
     ) * 0.25                                                          AS [Forecast Qty]
	   
			   

    FROM [FrcstFactTbl]
    LEFT JOIN [item_lu] ilu
      ON [FrcstFactTbl].[PartNumber] = [ilu].[part_number]
    LEFT JOIN [account_hierarchy_lu_dec_20] ah 
      ON [FrcstFactTbl].[AccountNumber] = [ah].[AccountNumber]
    LEFT JOIN [pop_codes_12.4.2020] pc
      ON [FrcstFactTbl].[PartNumber] = [pc].[part_number]

    GROUP BY
       MONTH([FrcstFactTbl].[InvDate])
      ,YEAR([FrcstFactTbl].[InvDate])
      ,DATEADD(MONTH, DATEDIFF(MONTH, 0, [FrcstFactTbl].[InvDate]), 0)   
      ,[FrcstFactTbl].[PartNumber]
      ,[FrcstFactTbl].[LineCode]
      ,[FrcstFactTbl].[ClassCode]
      ,[ilu].[cc_type]
      ,[ilu].[pop_code]
      ,[pc].[pop_code]
      ,[FrcstFactTbl].[AccountNumber]
      ,[ah].[finance_hierarchy]
      ,[ah].[status]
      ,[ah].[Nov_keycust1]
      ,[ah].[Oct_keycust1]
      ,[ah].[Sep_keycust1]
      ,[ah].[Aug_keycust1]
      ,[ah].[Jul_keycust1]
      ,[ah].[keycust1_high_level]
      ,[ah].[keycust2_top_customer]
      ,[ah].[keycust3_territory] 
      ,[ah].[keycust4]
      ,[ah].[sales1]	
      ,[ah].[sales2]
      ,[ah].[sales3]
      ,[ah].[sales4] 
		 
)
						 
INSERT INTO [aws_base]
 (
   [mnth_date]
  ,[yr_date]
  ,[year_month_date]
  ,[item_id]
  ,[line_code]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[pop_code_new]
  ,[finance_hierarchy]
  ,[active_flag]
  ,[Nov_keycust1]
  ,[Oct_keycust1]
  ,[Sep_keycust1]
  ,[Aug_keycust1]
  ,[Jul_keycust1]
  ,[keycust1_high_level]
  ,[keycust2_top_customer]
  ,[keycust3_territory]
  ,[keycust4]
  ,[sales1]
  ,[sales2]
  ,[sales3]
  ,[sales4]
  ,[gross]
  ,[qtyship]
  ,[qtyord]
  ,[qtyord_neg_rem]
  ,[qtyship_neg_rem]
  ,[frcst_qty]
	)
SELECT 
   DISTINCT [mnth_date]
  ,[yr_date]
  ,[year_month_date]
  ,[item_id]
  ,[line_code]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[pop_code_new]
  ,[finance_hierarchy]
  ,[active_flag]
  ,[Nov_keycust1]
  ,[Oct_keycust1]
  ,[Sep_keycust1]
  ,[Aug_keycust1]
  ,[Jul_keycust1]
  ,[keycust1_high_level]
  ,[keycust2_top_customer]
  ,[keycust3_territory]
  ,[keycust4]
  ,[sales1]
  ,[sales2]
  ,[sales3]
  ,[sales4]
  ,SUM( [gross] )
  ,SUM( [qtyship] )
  ,SUM( [qtyord] )
  ,SUM( [qtyord_neg_rem] )
  ,SUM( [qtyship_neg_rem] )
  ,SUM( [frcst_qty] )

FROM [cte_unconsolidated_dates]

GROUP BY
   [mnth_date]
  ,[yr_date]
  ,[year_month_date]
  ,[item_id]
  ,[line_code]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[pop_code_new]
  ,[finance_hierarchy]
  ,[active_flag]
  ,[Nov_keycust1]
  ,[Oct_keycust1]
  ,[Sep_keycust1]
  ,[Aug_keycust1]
  ,[Jul_keycust1]
  ,[keycust1_high_level]
  ,[keycust2_top_customer]
  ,[keycust3_territory]
  ,[keycust4]
  ,[sales1]
  ,[sales2]
  ,[sales3]
  ,[sales4]
		 
