# Script to uniformly aggregate all streaming graphs data available  into discrete time sequences of networks

#%% Import packages
import os
import pandas as pd
import networkx as nx
import numpy as np
#%% load all datasets
all_df = []
load_direct = "./raw_data_files/"
files = os.listdir(load_direct) 
for f in files:
    if f[-5:] == "edges":
        print(f)
        df_load = pd.read_csv(load_direct + f, sep = " ", skiprows=1)

        if df_load.shape[1]==3:
            all_df.append(df_load)


#%% given a target size N for the subnetwork, select the minimal aggregation that guarantees a subnetwork density of 0.5

N = 15
all_df_dense = []
for df in all_df:
    time_steps_max = df.iloc[:,2].unique()
    edges = df.iloc[:,:2].rename(columns = {df.columns[0]:"source", df.columns[1]:"target"})
    num_nodes = pd.unique(edges[['source', 'target']].values.ravel('K')).shape[0]

    # select most active nodes using an euristic rule on the network collapsed on one snapshot
    G = nx.from_pandas_edgelist(edges,  create_using = nx.MultiDiGraph)

    degs = sorted(G.degree, key=lambda x: x[1], reverse=True)

    nodes_dense = [d[0] for d in degs[:N]]
    df_dense = df[edges.source.isin(nodes_dense) & edges.target.isin(nodes_dense)]
    time_steps_max_dense = df_dense.iloc[:,2].unique().shape[0]
    if time_steps_max_dense >= 500:
        all_df_dense.append(df_dense)
        print(time_steps_max_dense)


#%%

N_pox_links = N*(N-1)/2
df = all_df_dense[1]

edges = df.iloc[:,:3].rename(columns = {df.columns[0]:"source", df.columns[1]:"target", df.columns[2]:"time"})

edges["undir_link_id"] = edges.apply(lambda x: frozenset({x.source, x.target}), axis=1)

edges.drop_duplicates(subset=["time", "undir_link_id"], inplace=True)

snapshots = edges.groupby(["time"]).agg({ "undir_link_id":lambda x: np.round(x.shape[0]/(N_pox_links), decimals=4)}).rename(columns={"undir_link_id":"density"}).reset_index()


snapshots.plot( y="density", use_index=True)





# %%
