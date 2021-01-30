DROP TABLE IF EXISTS [frcst_import_clean_dec_20];

CREATE TABLE [frcst_import_clean_dec_20]
 (
   [item_id]  VARCHAR(54)
  ,[date_use] VARCHAR(11)
  ,[keycust4] VARCHAR(54)
  ,[p20]      NUMERIC(10,2)
  ,[p35]      NUMERIC(10,2)
  ,[p50]      NUMERIC(10,2)
  ,[p65]      NUMERIC(10,2)
  ,[p80]      NUMERIC(10,2)
  ,[measure]  VARCHAR(27)
 )

INSERT INTO [frcst_import_clean_dec_20]
 (
   [item_id]
  ,[date_use]
  ,[keycust4]
  ,[p20]
  ,[p35]
  ,[p50]
  ,[p65]
  ,[p80]
  ,[measure]
 )
   

SELECT
   CASE WHEN LEN([item_id]) < 9
        THEN LEFT( [item_id] + REPLICATE('0', 9), 9)
        WHEN LEN([item_id]) = 18
        THEN LEFT( [item_id], LEN([item_id]) - 9)
		ELSE [item_id]
        END
		AS [item_id]
  ,DATEADD(dd, 1, [date]) AS [date_use]
  ,[keycust4]
  ,CASE WHEN SUM ([p20]) < 0
        THEN 0
        ELSE CAST( SUM ([p20]) AS NUMERIC(10, 2))
        END
        AS [p20]
  ,CASE WHEN SUM ([p35] ) < 0
        THEN 0
        ELSE CAST( SUM ([p35])  AS NUMERIC(10, 2))
        END
        AS [p35]
  ,CASE WHEN SUM ([p50] ) < 0
        THEN 0
        ELSE CAST( SUM ([p50])  AS NUMERIC(10, 2))
        END
        AS [p50]
  ,CASE WHEN SUM ([p65] ) < 0
        THEN 0
        ELSE CAST( SUM ([p65])  AS NUMERIC(10, 2))
        END
        AS [p65]
  ,CASE WHEN SUM ([p80] ) < 0
        THEN 0
        ELSE CAST( SUM ([p80])  AS NUMERIC(10, 2))
        END
        AS [p80]
   ,'forecast'
FROM [raw_frcst_load_dec_20]
GROUP BY [item_id]
        ,DATEADD(dd, 1, [date])
        ,[keycust4]
