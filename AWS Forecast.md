The project is currently utilizing AWS Forecast via the console.  

When dealing with multiple dataset, it is important to get naming conventions correct.

**1. Create Dataset Group ** - create a unique identifier easy not to repeat. Example of partitioned set: 'ds_drr_ab_7_10_v1'  
     There is also a prompt to choose a forecasting domain. The options:  
     1. **Retail** - forecasting demand for a retailer. **This is the example used here.**  
     2. **Custom** - if your dataset does not conform to any other options.  
     3. **Inventory planning** - forecasting raw materials to determine how much of an item to stock.  
     4. **Ec2 capacity**  
     5. **Work Force**  
     6. **Web Traffic**  
     7. **Metrics** - forecasting financieal revenue metrics such as revenue, sales, cashflow.

**2. Create Target Time Series Data Set Group ** - Example of partitioned set: 'dsnm_drr_ab_7_10_v2'  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Fitting data into the precise JSON format is critical.  Example:
     
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

     
