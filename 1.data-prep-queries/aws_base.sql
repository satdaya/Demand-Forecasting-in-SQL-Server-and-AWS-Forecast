
DROP TABLE IF EXISTS [aws_base];

CREATE TABLE [aws_base]
  (
   [year_month_date]          DATETIME
  ,[mnth_date]                INT
  ,[yr_date]                  INT
  ,[item_id]                  VARCHAR(54)
  ,[line_code]                VARCHAR(54)
  ,[line_code_condensed]      VARCHAR(54)
  ,[class_code]               VARCHAR(54)
  ,[cc_type]                  VARCHAR(54)
  ,[pop_code_legacy]          VARCHAR(54)
  ,[top_customer_fb_w_perf]   VARCHAR(54)
  ,[gross]                    NUMERIC(18, 2)
  ,[qtyship]                  INT
  ,[qtyord]                   INT
  ,[qtyord_neg_rem]           INT
  ,[qtyship_neg_rem]          INT
  ,[frcst_qty]                INT
  ,PRIMARY KEY ( [year_month_date] , [item_id], [top_customer_fb_w_perf] )
   ) ;

WITH [cte_unconsolidated_dates] (
    [year_month_date]
   ,[mnth_date]
   ,[yr_date]
   ,[item_id]
   ,[line_code]
   ,[line_code_condensed]
   ,[class_code]
   ,[cc_type]
   ,[pop_code_legacy]
   ,[top_customer_fb_w_perf]
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
      DISTINCT DATEADD(MONTH, DATEDIFF(MONTH, 0, [FrcstFactTbl].[InvDate]), 0)  AS [year_month]
     ,MONTH([FrcstFactTbl].[InvDate])                                  AS [mnth_date]
     ,YEAR([FrcstFactTbl].[InvDate])                                   AS [yr]	
     ,[FrcstFactTbl].[PartNumber]                                      AS [item_id]
     ,[ilu].[line_code]                                                AS [line_code]
     ,[ilu].[line_code_condensed]                                      AS [line_code_condensed]
     ,[ilu].[class_code]                                               AS [class_code]
     ,[ilu].[cc_type]                                                  AS [cc_type]
     ,[ilu].[pop_code]                                                 AS [pop_code_legacy]
     ,CASE WHEN [ah].[top_customer_fb_w_perf] IS NULL
           THEN 'All Other'
           ELSE [ah].[top_customer_fb_w_perf]
           END                                                         AS [top_customer_fb_w_perf]
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
	   * 0.25
     )                                                                 AS [Forecast Qty]
	   

    FROM [FrcstFactTbl]
    LEFT JOIN [item_lu] ilu
      ON [FrcstFactTbl].[PartNumber] = [ilu].[item_id]
    LEFT JOIN [account_hierarchy_lu_dec_20] ah 
      ON [FrcstFactTbl].[AccountNumber] = [ah].[AccountNumber]
    LEFT JOIN [pop_codes_12.4.2020] pc
      ON [FrcstFactTbl].[PartNumber] = [pc].[part_number]
    WHERE [FrcstFactTbl].[PartNumber] IS NOT NULL
    GROUP BY
       MONTH([FrcstFactTbl].[InvDate])
      ,YEAR([FrcstFactTbl].[InvDate])
      ,DATEADD(MONTH, DATEDIFF(MONTH, 0, [FrcstFactTbl].[InvDate]), 0)   
      ,[FrcstFactTbl].[PartNumber]
      ,[ilu].[line_code]
      ,[ilu].[line_code_condensed]
      ,[ilu].[class_code] 
      ,[ilu].[cc_type]
      ,[ilu].[pop_code]
      ,CASE WHEN [ah].[top_customer_fb_w_perf] IS NULL
            THEN 'All Other'
            ELSE [ah].[top_customer_fb_w_perf]
            END
		 
)
						 
INSERT INTO [aws_base]
 (
   [year_month_date]
  ,[mnth_date]
  ,[yr_date]
  ,[item_id]
  ,[line_code]
  ,[line_code_condensed]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[top_customer_fb_w_perf]
  ,[gross]
  ,[qtyship]
  ,[qtyord]
  ,[qtyord_neg_rem]
  ,[qtyship_neg_rem]
  ,[frcst_qty]
	)
SELECT 
   DISTINCT [year_month_date]
  ,[mnth_date]
  ,[yr_date]
  ,[item_id]
  ,[line_code]
  ,[line_code_condensed]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[top_customer_fb_w_perf]
  ,SUM( [gross] )
  ,SUM( [qtyship] )
  ,SUM( [qtyord] )
  ,SUM( [qtyord_neg_rem] )
  ,SUM( [qtyship_neg_rem] )
  ,SUM( [frcst_qty] )

FROM [cte_unconsolidated_dates]

GROUP BY
   [year_month_date]
  ,[mnth_date]
  ,[yr_date]
  ,[year_month_date]
  ,[item_id]
  ,[line_code]
  ,[line_code_condensed]
  ,[class_code]
  ,[cc_type]
  ,[pop_code_legacy]
  ,[top_customer_fb_w_perf]

