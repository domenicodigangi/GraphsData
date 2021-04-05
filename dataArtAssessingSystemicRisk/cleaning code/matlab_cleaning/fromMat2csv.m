clc
clear 
close all

%%

load('/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/USComBanksMatsAndEquities.mat')

tmp  = size(Positive_equity_Net_COM_macro_store)
T = tmp(1)

%%

filename = '/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/US_com_banks/asset_names.csv';
writetable(cell2table(Names_assets), filename)
filename = '/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/US_com_banks/banks_names.csv';
writetable(cell2table(allBanksEver), filename)
for t=1:T
    mat = Positive_equity_Net_COM_macro_store{t};
    filename = ['/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/US_com_banks/matr_' num2str(t) '.csv' ];
    
    dlmwrite(filename, mat, 'delimiter', ',', 'precision', 12);  
end
   
for t=1:T
    eq = total_equity_positive{t};
    banks_ids = Positive_equity_Net_COM_macro_store{t}(:,1);

    filename = ['/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/US_com_banks/equities_' num2str(t) '.csv' ];
    % assuming that equities and assets are ordered in the same way!!
    dlmwrite(filename, [banks_id,eq], 'delimiter', ',', 'precision', 12)

end
  
    
    


