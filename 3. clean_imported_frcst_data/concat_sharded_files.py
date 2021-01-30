#concatanate sharded s3 export prior to load into SQL Server
import pandas as pd
import glob

path = r''
all_files = glob.glob(path +"/*.csv")

li = []

for filename in all_files:
   df = pd.read_csv(filename, index_col=None, header=0)
   li.append(df)

frame = pd.concat(li, axis=0, ignore_index=True)
frame.to_csv(r'')
