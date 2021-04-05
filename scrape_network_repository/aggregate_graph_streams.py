# Script to uniformly aggregate all streaming graphs data available according to some common criteria

#%% Import packages
import os
import pandas as pd
#%% load all datasets
all_df = []
load_direct = "./raw_data_files/"
files = os.listdir(load_direct) 
for f in files[:5]:
    if f[-5:] == "edges":
        all_df.append(pd.read_csv(load_direct + f, sep = " "))

#%% 
all_df_3c = [df for df in all_df if df.shape[1] == 3]
all_df_4c = [df for df in all_df if df.shape[1] == 4]






















