clc 
close all
clear




%carica dati necessari
load ../data/data_domenico/saved_variables/Net_COM_macro_store.mat


T = max(size(Positive_equity_Net_COM_macro_store));

Net= Positive_equity_Net_COM_macro_store;
leverage_limit = 100;

%%Rimuovi banche con leverage superiore al valore soglia
for t = 1:T
    X = Net{t}(:,2:end);
    a_t = sum(X,2);
    e_t = total_equity_positive{t};
    lev_t = a_t./e_t;
    
    to_rem = lev_t >leverage_limit;
    sum(to_rem)
    Net{t}(to_rem,:) = [];
    total_equity_positive{t}(to_rem) = [];
    
end
Positive_equity_Net_COM_macro_store = Net;

save ../data/data_domenico/saved_variables/Net_COM_macro_store_lim_lev.mat Positive_equity_Net_COM_macro_store total_equity_positive

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    