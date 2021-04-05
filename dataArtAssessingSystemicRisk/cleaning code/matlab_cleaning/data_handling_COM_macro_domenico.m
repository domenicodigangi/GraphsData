


%This code loads the data produced with clean_data and organizes
%it in one weighted matrix for each year representing a network
%it removes the empty rows(banks not reporting anything)

%% Load data  
clear all
close all
clc
i=1;
for year=2001:2014
    for Q=1:4

        str=['../data/data_domenico/networks_commercial/macro_nodes_network/RC',num2str(year),'_Q',num2str(Q)];
        M{i}=load(str);              
        i=i+1;
    end    
end
year = 2015;
     for Q=1:3
        str=['../data/data_domenico/networks_commercial/macro_nodes_network/RC',num2str(year),'_Q',num2str(Q)];
        M{i}=load(str);              
        i=i+1;
    end
T = i-1;  %non considero l'ultimo quarto altrimenti sarebbe i-1

%% carica nomi all banks
load('../data/data_domenico/saved_variables/Names_COM.mat')


%% Import Inflaction's discount factors
% filepath
filename = '../data/data_domenico/consumer_prices_oecd.csv';
% import procedure code generated automatically by matlab
delimiter = ',';
startRow = 3;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
% Variable name
consumerpricesoecd = [dataArray{1:end-1}];
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
disc_infl= (consumerpricesoecd./consumerpricesoecd(1));
disc_infl(T+1:end) = [];

%% Build net 

K=[];
Names_banks_sorted = cell(T,1);
for t=1:T         
        
    [K, inds]=sortrows(M{t},-2);   
%     %discount all the matrix (hence all the quantities in dollars of the subsequent analysis)
%     K(:,2:end) = K(:,2:end) ./disc_infl(t);
    Net = [];
    %the first column  ontains each bank's ID
    Net(:,1) = K(:,1);
    Net(:,2:21) = K(:,4:23);
    
%     %remove the negative entries
   % Net(Net<0) = 0;
  
    Net_COM_macro_store_empty_rows{t} = Net;
    Names_banks_sorted{t} = Names_Banks{t}(inds,:);       
    total_asset_macro_COM{t} = K(:,2);
    total_equity_macro_COM{t} = K(:,3);
    other_asset_macro_COM{t} = K(:,23);
    
 
end
   


%% Remove empty rows 
 
bank_id = cell(T,1); 
Net_micro_store= cell(T,1);
collect_bank_id_micro =[];
removed= zeros(T,5);
collect_all_bank_id_COM =[];
Net_COM_macro_store = cell(T,1);
for t=1:T
    collect_all_bank_id_COM = [collect_all_bank_id_COM;  K(:,1);];
    K =  Net_COM_macro_store_empty_rows{t};
    N=length(K);    
    rowstoremove=[];
    removed(t,1) = N;
    K(isnan(K)) = 0; %necessario perche alcune banche non tiportano alcuni valori 
    %remove empty rows   
    for n=1:N
        if((sum(K(n,2:end)~=0))==0)
            removed(t,2)=removed(t,2) +1;
            rowstoremove(removed(t,2)) = n;
            
        end
    end
    K(rowstoremove,:) = [];
    
    total_asset_macro_COM{t}(rowstoremove) =[] ;
    total_equity_macro_COM{t}(rowstoremove) =[] ;
    other_asset_macro_COM{t}(rowstoremove) =[];
   
    removed(t,3) = removed(t,1) - removed(t,2);
    removed(t,4) = removed(t,2)/removed(t,1);
    removed(t,5) = length(find(K(:)==0))/length(K(:));
    %keep track of all the banks that appear at least once
    collect_bank_id_micro =[collect_bank_id_micro;K(:,1)];
    bank_id{t} = K(:,1);
    Net_COM_macro_store{t}=K;
  
end

collect_all_bank_id_COM = unique(collect_all_bank_id_COM);
%% check for negative values and put them to zero

for t=1:T
    W = Net_COM_macro_store{t};
    W(W<0) = 0;
    Net_COM_macro_store{t} = W;
    
end

%% check for empty colums
emptycol = [];
for t = 1:T
    for j=1:length(Net_COM_macro_store_empty_rows{t}(1,:))
        if(sum(Net_COM_macro_store_empty_rows{t}(:,j)) ~= 0 )
           emptycol =  [emptycol ; t j];

        end
    end
end

%% versione senza banche con equity negativa  
Positive_equity_Net_COM_macro_store = cell(T,1);
Positive_equity_Names_COM = cell(T,1);
for t=1:T
    K = Net_COM_macro_store{t};
    e = total_equity_macro_COM{t};
    N = Names_Banks{t}(2:end,:);
    Positive_equity_Net_COM_macro_store{t} = K(e > 0,:);
    total_equity_positive{t} = total_equity_macro_COM{t}(e>0);
    Positive_equity_Names_COM{t} = N(e>0, :);
end

% %% various tests 
% test = [];
% for t=1:T
%     total = sum(sum(Net_COM_macro_store{1}(:,2:end)));
%     [minval minpos] = min(sum(Net_COM_macro_store{t}(:,2:end))./total);
%     [maxval maxpos] = max(sum(Net_COM_macro_store{t}(:,2:end))./total);
%    test = [test; t mean(sum(Net_COM_macro_store{t}(:,2:end))./total) minval minpos  maxval maxpos];
%     
%   
% end
% 
% test1=[];
% sumvar=[];
% meanvar=[];
% for t = 1:T
% K = M{t};
% [r c] =find(K<0);
% test1 = [test1; c r  t*ones(length(c),1)];
% sumvar = [sumvar; sum(K)];
% meanvar=[meanvar; mean(K)];
% end
% 
% test2=[];
% 
%  for i =1:length(test1(:,1))
%      K = M{test1(i,3)};
%      test2= [test2; K(test1(i,2),test1(i,1)) ];
%  end
%  test1 = [test1 test2];
% 

%% save 
years = 2001:(2000 + ceil(T/4));
last_quarter = (T/4 - fix(T/4))*4;
numyears = length(years);
jan1s = zeros(numyears,1);
quarters = [];

for Yearno = 1:numyears
    thisyear = years(Yearno);
    jan1s(Yearno) = datenum([thisyear 1 1]);
    if(Yearno~=numyears)    
    for q = 0:3
    quarters = [quarters; datenum([thisyear  1+3*q 1]) ];
    end
    elseif(last_quarter==0)
        jan1s(Yearno) = datenum([thisyear 1 1]);
        thisyear=years(Yearno);
        for q = 0:3
        quarters = [quarters; datenum([thisyear  1+3*q 1]) ];
        end
    else
        jan1s(Yearno) = datenum([thisyear 1 1]);
        thisyear=years(Yearno);
        for q = 1:last_quarter
        quarters = [quarters; datenum([thisyear  1+3*q 1]) ];
        end
    end   
end


savefile = '../data/data_domenico/saved_variables/Net_COM_macro_store.mat';
save(savefile,  'Positive_equity_Net_COM_macro_store','total_equity_positive', 'Positive_equity_Names_COM', 'quarters');
savefile = '../../data/Real_networks_raw_data/bipartite/dataArtAssessing/USComBanksMatsAndEquities.mat'; 
save(savefile,  'Positive_equity_Net_COM_macro_store','total_equity_positive', 'Positive_equity_Names_COM', 'quarters');

%% Load .mat saved above and store in csv
load('/home/domenico/Dropbox/Network_Ensembles/data/Real_networks_raw_data/bipartite/dataArtAssessing/USComBanksMatsAndEquities.mat')
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
    dlmwrite(filename, [banks_ids eq], 'delimiter', ',', 'precision', 12)

end
  
    
    

