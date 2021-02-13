DROP TABLE IF EXISTS [frcst_analysis_feb21_sku];

CREATE TABLE [frcst_analysis_feb21_sku]
  (
    [date_use]              VARCHAR(12)
   ,[yr_date]               INT
   ,[mnth_date]             INT
   ,[qrtr]                  INT
   ,[item_id]               VARCHAR(54)
   ,[line_code]             VARCHAR(54)
   ,[line_code_condensed]   VARCHAR(54)
   ,[class_code]            VARCHAR(54)
   ,[pop_code_legacy]       VARCHAR(11)
   ,[pop_code_new]          VARCHAR(11)
   ,[top_customer]          VARCHAR(54)
   ,[p20]                   NUMERIC(18, 2)
   ,[p35]                   NUMERIC(18, 2)
   ,[p50]                   NUMERIC(18, 2)
   ,[p65]                   NUMERIC(18, 2)
   ,[p80]                   NUMERIC(18, 2)
   ,[gross_p20]             NUMERIC(18, 2)
   ,[gross_p35]             NUMERIC(18, 2)
   ,[gross_p50]             NUMERIC(18, 2)
   ,[gross_p65]             NUMERIC(18, 2)
   ,[gross_p80]             NUMERIC(18, 2)
   ,[qtyord]                NUMERIC(18, 2)
   ,[qtyship]               NUMERIC(18, 2)
   ,[unit_frcst_use]        NUMERIC(18, 2)
   ,[$_frcst_use]           NUMERIC(18, 2)
   ,[measure]               VARCHAR(54)
   ,[measure2]              VARCHAR(54)
   ,[color_measure]         INT
   ,[3]                     VARCHAR(54)
   ,[6]                     VARCHAR(54)
   ,[3_order]               INT
   ,[6_order]               INT
  )

INSERT INTO [frcst_analysis_feb21_sku]
  (
    [date_use]
   ,[yr_date]
   ,[mnth_date]
   ,[qrtr]
   ,[item_id]
   ,[line_code]
   ,[line_code_condensed]
   ,[class_code]
   ,[pop_code_legacy]
   ,[top_customer]
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
   ,[unit_frcst_use]
   ,[$_frcst_use]
   ,[measure]
   ,[measure2]  
   ,[color_measure] 
   ,[3]
   ,[6]    
   ,[3_order]
   ,[6_order]
  )
--Load historical data
SELECT
   DISTINCT [year_month_date]
  ,[yr_date]
  ,[mnth_date]
  ,CASE WHEN [mnth_date] IN ('1', '2', '3')
        THEN '1'
        WHEN [mnth_date] IN ('4', '5', '6')
        THEN '2'
        WHEN [mnth_date] IN ('7', '8', '9')
        THEN '3'
        WHEN [mnth_date] IN ('10', '11', '12')
        THEN '4'
        END
  ,[item_id]
  ,[line_code]
  ,[line_code_condensed]
  ,[class_code]
  ,[pop_code_legacy]
  ,[top_customer_fb_w_perf]
  --populate historicals probability quantiles with historicals
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyord])  AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([qtyship]) AS NUMERIC(18, 2) )
  ,CAST ( SUM([gross])   AS NUMERIC(18, 2) )
  ,'actuals'
  ,CONCAT([yr_date],'actuals')
  ,0
  ,CASE WHEN [year_month_date] >= DATEADD(MONTH, -4, GETDATE())
        AND [year_month_date] < DATEADD(MONTH, -1, GETDATE())
        THEN 'trailing 3'
        END
  ,CASE WHEN [year_month_date] >= DATEADD(MONTH, -7, GETDATE())
        AND [year_month_date] < DATEADD(MONTH, -1, GETDATE())
        THEN 'trailing 6'
        END
--the following two lines set index columns to ensure correct ordering of the trailing_3 and trailing 6 metrics
  ,CASE WHEN [year_month_date] >= DATEADD(MONTH, -4, GETDATE())
        AND [year_month_date] < DATEADD(MONTH, -1, GETDATE())
        THEN '1'
        END
  ,CASE WHEN [year_month_date] >= DATEADD(MONTH, -7, GETDATE())
        AND [year_month_date] < DATEADD(MONTH, -1, GETDATE())
        THEN '1'
        END
 FROM [aws_base]
WHERE [year_month_date] != DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
  AND [line_code] NOT IN ('INS', 'LAB', 'OBS')
GROUP BY
   [year_month_date]
  ,[yr_date]
  ,[mnth_date]
  ,[item_id]
  ,[line_code]
  ,[line_code_condensed]
  ,[class_code]
  ,[pop_code_legacy]
  ,[top_customer_fb_w_perf]
  ,CONCAT([yr_date],'actuals')

INSERT INTO [frcst_analysis_feb21_sku]
  (
    [date_use]
   ,[mnth_date]
   ,[yr_date]
   ,[qrtr]
   ,[item_id]
   ,[line_code]
   ,[line_code_condensed]
   ,[class_code] 
   ,[pop_code_legacy]
   ,[pop_code_new]
   ,[top_customer]
   ,[p20]
   ,[p35]
   ,[p50]
   ,[p65]
   ,[p80]
   ,[unit_frcst_use]
   ,[$_frcst_use]
   ,[measure]
   ,[measure2]     
   ,[color_measure]  
   ,[3]
   ,[6] 
   ,[3_order]
   ,[6_order] 
  )
--Load forecast data from cleaned S3 import
SELECT
   [frcst_import_clean_feb_21].[date_use]
  ,MONTH([frcst_import_clean_feb_21].[date_use])
  ,YEAR([frcst_import_clean_feb_21].[date_use])
  ,CASE WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('1', '2', '3')
        THEN '1'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('4', '5', '6')
        THEN '2'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('7', '8', '9')
        THEN '3'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('10', '11', '12')
        THEN '4'
        END
   ,[frcst_import_clean_feb_21].[item_id]
   ,[item_lu].[line_code]
   ,[item_lu].[line_code_condensed]
   ,[item_lu].[class_code]
   ,[item_lu].[pop_code_legacy]
   ,[item_lu].[pop_code_new]
   ,CASE WHEN [top_customer] IN ('Canada', 'Smyth', 'us auto force', 'united auto supply', 'na')
                             THEN 'all other'
                             ELSE LOWER([top_customer])
                             END
   ,SUM([frcst_import_clean_feb_21].[p20])
   ,SUM([frcst_import_clean_feb_21].[p35])
   ,SUM([frcst_import_clean_feb_21].[p50])
   ,SUM([frcst_import_clean_feb_21].[p65])
   ,SUM([frcst_import_clean_feb_21].[p80])
 --setting initial unit_frcst
   ,SUM([frcst_import_clean_feb_21].[p50])
 --setting initial $ frcst
   ,CAST ( ROUND( SUM([frcst_import_clean_feb_21].[p50] ) * SUM([avg_wholesale_price].[avg_price]), 0 ) AS NUMERIC (18, 2))
   ,'forecast'
   ,CONCAT(YEAR([frcst_import_clean_feb_21].[date_use]),'forecast')
   ,1
  ,CASE WHEN [date_use] < DATEADD(MONTH, 3, GETDATE())
        AND [date_use] > DATEADD(MONTH, 0, GETDATE())
        THEN 'forward 3'
        END
  ,CASE WHEN [date_use] < DATEADD(MONTH, 6, GETDATE())
        AND [date_use] > DATEADD(MONTH, 0, GETDATE())
        THEN 'forward 6'
        END
--the following two lines set index columns to ensure correct ordering of the trailing_3 and trailing 6 metrics
  ,CASE WHEN [date_use] >= DATEADD(MONTH, -4, GETDATE())
        AND [date_use] < DATEADD(MONTH, -1, GETDATE())
        THEN '2'
        END
  ,CASE WHEN [date_use] >= DATEADD(MONTH, -7, GETDATE())
        AND [date_use] < DATEADD(MONTH, -1, GETDATE())
        THEN '2'
        END
FROM [frcst_import_clean_feb_21]
JOIN [item_lu]
  ON [frcst_import_clean_feb_21].[item_id] = [item_lu].[item_id]
JOIN [avg_wholesale_price]
  ON [frcst_import_clean_feb_21].[item_id] = [avg_wholesale_price].[item_id]
GROUP BY
   [frcst_import_clean_feb_21].[date_use]
  ,MONTH([frcst_import_clean_feb_21].[date_use])
  ,YEAR([frcst_import_clean_feb_21].[date_use])
  ,CASE WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('1', '2', '3')
        THEN '1'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('4', '5', '6')
        THEN '2'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('7', '8', '9')
        THEN '3'
        WHEN MONTH([frcst_import_clean_feb_21].[date_use]) IN ('10', '11', '12')
        THEN '4'
        END
   ,[frcst_import_clean_feb_21].[item_id]
   ,[item_lu].[line_code]
   ,[item_lu].[line_code_condensed]
   ,[item_lu].[class_code]
   ,[item_lu].[pop_code_legacy]
   ,[item_lu].[pop_code_new]
   ,[frcst_import_clean_feb_21].[top_customer]
   ,CONCAT(YEAR([frcst_import_clean_feb_21].[date_use]),'forecast')


