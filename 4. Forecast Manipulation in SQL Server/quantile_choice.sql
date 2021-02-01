UPDATE [analysis_historical] 
	SET [unit_frcst_use] = [p50]
                            WHERE [measure] IN ('actuals');
             
UPDATE [analysis_historical] 
	SET [$_frcst_use] = [gross_p50]
                            WHERE [measure] IN ('actuals');
                       
UPDATE [analysis_historical] 
	SET [unit_frcst_use] = [p50]
                            WHERE [measure] IN ('forecast');

 UPDATE [analysis_historical] 
	SET [$_frcst_use] = [unit_frcst_use] * [price].[avergae_sales_price]
                            FROM [analysis_historical] 
                            JOIN [price]
                            ON [analysis_historical] .[item_id] = [price].[item_id]
                            WHERE [measure] IN ('forecast');
		      
					                      
