The project is currently utilizing AWS Forecast via the console.  

When dealing with multiple partitioned dataset, it is important to get naming conventions correct.

**1. Create dataset group** - create a unique identifier easy not to repeat. Example of partitioned set: 'ds_drr_ab_7_10_v1'  
     There is also a prompt to choose a forecasting domain. The options:  
     1. **Retail** - forecasting demand for a retailer. **This is the example used here.**  
     2. **Custom** - if your dataset does not conform to any other options.  
     3. **Inventory planning** - forecasting raw materials to determine how much of an item to stock.  
     4. **Ec2 capacity**  
     5. **Work Force**  
     6. **Web Traffic**  
     7. **Metrics** - forecasting financial revenue metrics such as revenue, sales, cashflow.

**2. Create target time series data set group** - Example of partitioned set name: 'dsnm_drr_ab_7_10_v2'  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- The time interval specification is here. In this example, I am forecasting in monthly intervals.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  Fitting data into the precise JSON format is critical.  Example:
     
     {
        "Attributes": [
          {
            "AttributeName": "timestamp",
            "AttributeType": "timestamp"
          },          
          {
            "AttributeName": "item_id",
            "AttributeType": "string"
          },
          {
            "AttributeName": "keycust3",
            "AttributeType": "string"
          },
          {
            "AttributeName": "demand",
            "AttributeType": "float"
          }
        ]
      }

**3. Import target time series data** - Example of partitioned set name: 'dsimp_drr_ab_7_10_v2'  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Here you specify the timestamp format. Forecast will only accept the following two formats:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; a. yyyy-MM-dd HH:mm:ss  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; b. yyyy-MM-dd  
&nbsp;&nbsp;&nbsp; In this example I am using yyyy-MM-dd, as I am forecasting in monthly buckets.  
You assign the IAM Role, and copy the path of your CSV data located in S3.

There are additional prompts for item metadata datasets and related time series. In this example I use item metadata.

Below is the JSON for the item metadata used in this project.


     {
        "Attributes": [
          {
            "AttributeName": "item_id",
            "AttributeType": "string"
          },
          {
            "AttributeName": "line_code",
            "AttributeType": "string"
          },
          {
            "AttributeName": "class_code",
            "AttributeType": "string"
          },
          {
            "AttributeName": "cc_type",
            "AttributeType": "string"
          },
          {
            "AttributeName": "pop_code",
            "AttributeType": "string"
          }

        ]
      }
      
**4. Train a Predictor** - Example of a predictor name: 'pred_drr_ab_7_10_v2'.

Set your forecast horizon here. Keep in mind that the your forecast is maxed out at 1/3 of your historical dataset.

It is here where you choose your algorithm. I settled on Prophet. ARIMA and NPTS were giving me static flat forecasts with minimal seasonality. DEEP AR+ was generating a progressive decay curve (possibly as a result of the outlier April). Prophet most accurately caught the seasonal curves.

You also set the forecast dimension. For my project, it is the Key Customer 3 level.

Backtest window: 1 (default)

Backtest window offset: 10 (default)

**5. Forecast Generation** Example of a predictor name: 'frcst_drr_ab_7_10_v2'  

Choose the predictor (trained in the previous step).  

Choose the Quantiles you want to forecast. Quantiles determine the % of time the forecast is predicted to exceed the true value. For example - a quantile forecast of .50 predicts that the forecast will exceed the true value 50% of the time. AWS will default .10, .50, .90. These 3 forecasts cover 80% of the confidence interval.  

When the forecast is generated, create an export to migrate that forecast to an S3 bucket.  

NB - delete all of your resource once done, for the following reasons:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp a. AWS will charge you to store forecasts
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp b. You can only store 10 forecasts at a time.
