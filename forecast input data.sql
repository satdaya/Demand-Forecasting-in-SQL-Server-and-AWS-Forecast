DROP TABLE IF EXISTS [s3_load_no_partition];

CREATE TABLE [s3_load_no_partition] (
   [year_month]   VARCHAR(10)
  ,[item_id]      VARCHAR(54)
  ,[top_customer] VARCHAR(54)
  ,[frcst_qty]    INT
  ,PRIMARY KEY ([year_month], [item_id], [top_customer])
  ) ;

WITH
	
[last_6_month cte]
  ( [year_month]
   ,[trailing_6])
 AS (
     SELECT
       DISTINCT [year_month_date]
      ,CASE WHEN DATEDIFF ( MONTH, [year_month_date], GETDATE()) <= 6 THEN 'Past 6 Mnths' END AS [trailing_6]
     FROM [aws_base]
     )
,
				
[items_cte]
  (
    [item_id]
   ,[top_customer] 
   ,[frcst_qty]
   )
  AS
   ( 
    SELECT 
	   [item_id]
      ,[top_customer] 
      ,SUM([frcst_qty_a])
    FROM
      (
       SELECT
          [aws_base].[item_id]                AS [item_id]
         ,[aws_base].[top_customer_fb_w_perf] AS [top_customer]
         ,SUM( SUM([frcst_qty]) ) 
             OVER (PARTITION BY [aws_base].[item_id], [aws_base].[top_customer_fb_w_perf]) AS [frcst_qty_a]
        FROM [aws_base]
       JOIN [last_6_month cte]
         ON [aws_base].[year_month_date] = [last_6_month cte].[year_month]
       WHERE [last_6_month cte].[trailing_6] = 'Past 6 Mnths'
       GROUP BY  
          [item_id]
         ,[aws_base].[top_customer_fb_w_perf] 
      ) [subquery]
    WHERE [subquery].[frcst_qty_a] >= 1
    GROUP BY
       [item_id]
      ,[top_customer] 
		)
,

[ym_cte]
  (  
    [year_month]
   ,[item_id]
   ,[top_customer] 
   ,[frcst_qty])
  AS 
   (
    SELECT 
       CONVERT(VARCHAR(10), [aws_base].[year_month_date], 20) 
      ,[aws_base].[item_id] 
      ,[items_cte].[top_customer]
      ,CASE WHEN SUM(ISNULL([aws_base].[frcst_qty], 0)) <= 0
            THEN 0 ELSE SUM(ISNULL([aws_base].[frcst_qty], 0))
			END
    FROM [aws_base]
    JOIN [items_cte] 
	    ON [aws_base].[item_id] = [items_cte].[item_id]
	   AND [aws_base].[top_customer_fb_w_perf] = [items_cte].[top_customer]
	  WHERE [aws_base].[year_month_date] != DATEADD(MM,DATEDIFF(MM,0,Getdate()),0)
	    AND [line_code] NOT IN ('PKE', 'PKG', 'LAB', 'CAT', 'OBS')
    GROUP BY
       [aws_base].[year_month_date]
      ,[aws_base].[item_id] 
      ,[items_cte].[top_customer]
   )
,

[cte_metrics]
  ( 
    [year_month]
   ,[item_id]
   ,[top_customer]
   ,[sum_frcst_qty]
   ,[avg_frcst_qty]
   ,[stddev_frcst_qty]
   )
  AS 
   ( 
    SELECT 
       [year_month]
      ,[item_id]
      ,[top_customer]
      ,SUM([frcst_qty]) AS [sum_frcst_qty]
      ,AVG( SUM([frcst_qty]) ) OVER ( PARTITION BY [item_id], [top_customer] ) AS [avg_frcst_qty]
      ,STDEV (SUM([frcst_qty]) ) OVER ( PARTITION BY [item_id], [top_customer] ) AS [stddev_frcst_qty]
	FROM [ym_cte]
    GROUP BY
      [year_month]
     ,[item_id]
     ,[top_customer]
   )
,

[ym_prior_3_avg_cte]
   (
     [year_month] 
    ,[item_id]
    ,[top_customer] 
    ,[frcst_qty]
   )
  AS
   (
    SELECT 
       '2020-04-01' 
      ,[item_id] 
      ,[top_customer]
      ,(SUM ([frcst_qty]) / 3 )
    FROM ym_cte
    WHERE [year_month] IN ('2020-01-01', '2020-02-01', '2020-03-01')
    GROUP BY 
      [year_month]
     ,[item_id]
     ,[top_customer]
    )
 ,

[cte_aggregate]
    ( [year_month]  
     ,[item_id]
     ,[top_customer]  
     ,[frcst_qty]
     )
  AS
   (  
SELECT
   DISTINCT [ym_cte].[year_month]
  ,[ym_cte].[item_id]
  ,[ym_cte].[top_customer]
   --,SUM([cte_metrics].[sum_frcst_qty])
  ,CASE WHEN 
     ABS ( SUM([cte_metrics].[sum_frcst_qty]) - SUM([cte_metrics].[avg_frcst_qty]) ) 
       > 
     ABS ( SUM([cte_metrics].[stddev_frcst_qty]) * 3 )
	 THEN SUM([cte_metrics].[avg_frcst_qty])
     ELSE SUM([cte_metrics].[sum_frcst_qty]) END
FROM [ym_cte]
JOIN [cte_metrics]
  ON [ym_cte].[year_month] = [cte_metrics].[year_month]
 AND [ym_cte].[item_id] = [cte_metrics].[item_id]
 AND [ym_cte].[top_customer] = [cte_metrics].[top_customer]
WHERE [ym_cte].[year_month] <> '2020-04-01'
GROUP BY
   [ym_cte].[year_month]
  ,[ym_cte].[item_id]
  ,[ym_cte].[top_customer]

UNION ALL

SELECT *
FROM [ym_prior_3_avg_cte]
)


INSERT INTO [s3_load_no_partition]
    ( [year_month]  
     ,[item_id]
     ,[top_customer]  
     ,[frcst_qty]
     )

SELECT
   DISTINCT [year_month]
  ,[item_id]
  ,[top_customer]  
  ,SUM([frcst_qty])
FROM [cte_aggregate]
GROUP BY
   [year_month]
  ,[item_id]
  ,[top_customer]
