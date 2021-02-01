Now that we have the historical and forecast data merged and standardized, we can decide upon a forecast. Recall that I generated 5 quantile forecasts. In this example, those were p20, p35, p50, p62, p80. From those, we have to choose one:  

For actuals, set both the units and the gross $ to historicals. Since actuals are spread across each quantile, just pick any.  

```
UPDATE [analysis_historical] 
	SET [unit_frcst_use] = [p50]
                         WHERE [measure] IN ('actuals');
             
UPDATE [analysis_historical] 
	SET [$_frcst_use] = [gross_p50]
                       WHERE [measure] IN ('actuals');
```
For the forecast, set the units at the desired quantile. And then multiply that by the gross price that you are using. In the below example, I am choosing the quantile that says, "50% of the time, the actuals will come in more than the forecasted quantity." Since we are forecasting the actual orders (rather than needed inventory), forecasting at or around the 50% quantile works best in my experience.

I have two primary tools when adjusting the forecast (in order of priority) based on sales input:  
1. Adjust the quantile.  
2. Multiply the unit forecast.

```
UPDATE [analysis_historical] 
	SET [unit_frcst_use] = [p50]
                               WHERE [measure] IN ('actuals')

 UPDATE [analysis_historical] 
	SET [$_frcst_use] = [unit_frcst_use] * [price].[avergae_sales_price]
					 FROM [analysis_historical] 
					 JOIN [price]
					   ON [analysis_historical] .[item_id] = [price].[item_id]
					WHERE [measure] IN ('forecast')
```