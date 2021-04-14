#%% Import packages
import os
import pandas as pd
import networkx as nx
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import torch
import pickle

#%% load all datasets
all_data = []
load_direct = "./raw_data_files/"
files = os.listdir(load_direct) 
for f in files:
    if (f[-5:] == "edges") and ("copresence" in f):

        print(f)
        df_load = pd.read_csv(load_direct + f, sep = " ", skiprows=3)

        if df_load.shape[1]==3:
            all_data.append((f, df_load))


#%% filter dataset that have too few time steps
all_edges = []
for (f, df) in all_data:
    time_steps_max = df.iloc[:,2].unique().shape[0]
    
    edges = df.iloc[:,:3].rename(columns = {df.columns[0]:"source", df.columns[1]:"target", df.columns[2]:"time"})

    edges["undir_link"] = edges.apply(lambda x: frozenset({x.source, x.target}), axis=1)

    edges.drop_duplicates(subset=["time", "undir_link"], inplace=True)

    if time_steps_max >= 500:
        all_edges.append((f, edges))
        print(time_steps_max)


#%% convert data into a sequence of spins (one for each link ever observed)
save_direct = "./data_for_K_ising/"

for (name, df) in all_edges:

    all_links = df["undir_link"].unique() 
    n_links = all_links.shape[0]

    tmp = (df.groupby("time").agg({"undir_link":lambda x : x.unique().shape[0]})/n_links)

    plt.figure()
    plt.plot(tmp.values, ".")
    plt.title(name)

    df["value"] = True
    df_spins = df.pivot(index="time", columns=["undir_link"], values="value").fillna(False)

    s_T = torch.tensor(df_spins.values, dtype=bool)
    data = {"link_names":df_spins.columns, "times" :df_spins.index.values, "links_ts":s_T }

    pickle.dump(data, open(save_direct+ name[:name.find(".edges")] + ".pkl", "wb"))



# plt.plot(df_spins.mean(axis=1), ".")
# plt.plot(df_spins.mean(axis=0), ".")







# %%
