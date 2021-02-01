Now that we have the historical and forecast data merged and standardized, we can decide upon a forecast. Recall that I generated 5 quantile forecasts. In this example, those were p20, p35, p50, p62, p80. From those, we have to choose one:  

For actuals, set both the units and the gross $ to historicals. Since actuals are spread across each quantile, pick any.  

For the forecast, set the units at the desired quantile, nd then multiply that by the gross price that you are using. In the below example, I am choosing the quantile that says, "50% of the time, the actuals will come in more than the forecasted quantity."

I have two primary tools when adjusting the forecast (in order of priority) based on sales input:  
1. Adjust the quantile.  
2. Multiply the unit forecast.
