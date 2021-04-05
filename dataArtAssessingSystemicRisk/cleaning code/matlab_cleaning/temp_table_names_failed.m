%script pensato per produrre un file di testo con una tabella in latex che
%mostri i nomi delle banche fallite organizzati per anni di fallimento
%sempre secondo last tick interpolation
clear all
close all
clc 
addpath ../../matlab/
load ../data/data_domenico/saved_variables/Net_COM_macro_store.mat
load ../data/data_domenico/saved_variables/Names_COM.mat
load ../data/data_domenico/saved_variables/banks_popolation.mat
%plotta le figure full screen nel secondo monitor
set(0,'DefaultFigurePosition', [1986 311 1600 1000])

T = max(size(Net_COM_macro_store));
%% 
for t=12:12
    
    names_t = sort(Net_COM_macro_store{t-1}(:,1));
    failures_t = failures_times_COM{t};
    [C,ia,ib] = intersect(names_t,failures_t)
end