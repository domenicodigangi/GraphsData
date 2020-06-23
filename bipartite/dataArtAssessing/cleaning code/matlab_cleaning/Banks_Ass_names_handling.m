
clc
close all
clear


savepath = '../data/data_domenico/saved_variables/Names_COM.mat';
load ../data/data_domenico/saved_variables/Net_COM_macro_store.mat
Net = Positive_equity_Net_COM_macro_store;
T = max(size(Net));
%% crea cell con i nomi delle banche e altre informazioni (stato zip code ...)
%ATTENZIONE I FILE NELLA CARTELLA DEVONO ESSERE NOMINATI IN MODO TALE DA
%ESSERE CARICATI CRONOLOGICAMENTE!!!!!!!
path='../data/COM_data/banks_names/';
files_in_dir = dir([path,'*.txt']);
numfiles= length(files_in_dir);
delimiter = '\t';
formatSpec = '%s%s%s%s%s%s%s%s%s%[^\n\r]';
Names_Banks = cell(numfiles,1);
for i=1:numfiles
     filename =[path files_in_dir(i).name];
     fileID = fopen(filename,'r');
     dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
     fclose(fileID);
    temp = cell(size(dataArray{1,1},1),size(dataArray,2));
     for j=1:size(dataArray,2)
         temp(:,j) = dataArray{1,j};
         Names_Banks{i,1} = temp;
     end
end

%% list all banks appearing at least once in the data

allBanksEver=cell(1,length(Names_Banks{1}(1,:)));
for t=1:T
    allBanksEver = [allBanksEver;Names_Banks{t}]; 
end
allInds = str2double(allBanksEver(:, 1));
[~,uniqueInds] = unique(allInds);
allBanksEver = allBanksEver(uniqueInds,:);

%% seleziona banche presenti per tutto il periodo e salva i nomi a parte

    all_banks_names = [];

for t=1:T
    names_t = Net{t}(:,1);
    all_banks_names = [all_banks_names; names_t];
end
        

all_banks_names = unique(all_banks_names);
N_all_t_banks = length(all_banks_names);
% Persistetly present banks and mean size
pers_ids = all_banks_names; 
all_banks_sizes =zeros(N_all_t_banks,2); 
for t = 1
     X = Net{t}(:,2:end);
     a_t = sum(X,2);
     names_t = Net{t}(:,1);
     [~,ia,ib] = intersect(names_t,pers_ids,'Stable');
     % quali banche sono sempre presenti??
     pers_ids = pers_ids(ib);
  
     
end
%% seleziona nomi delle sole banche sempre presenti. in ordine di size
name_id_data = Names_Banks{1}(:,1);
name_id_data = str2mat(name_id_data);
name_id_data = str2num(name_id_data);

[~,ia,ib] = intersect(pers_ids,name_id_data,'Stable');

compl_names_t1 = str2mat(Names_Banks{1}(2:end,4));
compl_state_t1 =  str2mat(Names_Banks{1}(2:end,7));
Names_Banks_Pers = compl_names_t1(ib,:) ;
States_Banks_pers = compl_state_t1(ib,:) ;


%% crea cell con i nomi estesi e abbreviati delle asset classes
k=1;
Names_assets{k,1}=['Cash and balances due from depository institutions'];
Names_assets{k,2}=['cashab'];
Names_assets{k,3}=['cashab'];


k=k+1;
Names_assets{k,1}=['U.S. Treasury Securities'];
Names_assets{k,2}=['ust_sec'];
Names_assets{k,3}=['ust sec.'];

k=k+1;
Names_assets{k,1}=['U.S. Agency Securities'];
Names_assets{k,2}=['agency_sec'];
Names_assets{k,3}=['agency sec.'];

k=k+1;
Names_assets{k,1}=['Securities Issued by State and Local Government'];
Names_assets{k,2}=['stat_sec'];
Names_assets{k,3}=['state sec.'];

k=k+1;
Names_assets{k,1}=['Mortgage Backed Securities'];
Names_assets{k,2}=['mbs'];
Names_assets{k,3}=['mbs'];


k=k+1;
Names_assets{k,1}=['Asset Backed Securities'];
Names_assets{k,2}=['abs'];
Names_assets{k,3}=['abs'];

k=k+1;
Names_assets{k,1}=['Other Domestic Debt Securities'];
Names_assets{k,2}=['dom_debt_oth_sec'];
Names_assets{k,3}=['dom. debt. sec.'];

k=k+1;
Names_assets{k,1}=['Foreign Debt Securities'];
Names_assets{k,2}=['for_debt_sec'];
Names_assets{k,3}=['for. debt. sec.'];

k=k+1;
Names_assets{k,1}=['Residual Securities'];
Names_assets{k,2}=['res_sec'];
Names_assets{k,3}=['res. sec.'];

k=k+1;
Names_assets{k,1}=['Futures Forwards Sold and Securities '....
    'Purchased Under Agreement to Resell'];
Names_assets{k,2}=['ffrepo_ass'];
Names_assets{k,3}=['ffrepo ass.'];

k=k+1;
Names_assets{k,1}=['Loans Secured by Real Estates in Domestic Offices'];
Names_assets{k,2}=['ln_re_dom'];
Names_assets{k,3}=['ln. re. dom.'];

k=k+1;
Names_assets{k,1}=['Loans Secured by Real Estates in Foreign Offices'];
Names_assets{k,2}=['ln_re_for'];
Names_assets{k,3}=['ln. re. for.'];

k=k+1;
Names_assets{k,1}=['Commercial and Industrial Loans in Domestic Offices'];
Names_assets{k,2}=['ln_ci_dom'];
Names_assets{k,3}=['ln. ci. dom.'];

k=k+1;
Names_assets{k,1}=['Commercial and Industrial Loans in Foreign Offices'];
Names_assets{k,2}=['ln_ci_for'];
Names_assets{k,3}=['ln. ci. for.'];

k=k+1;
Names_assets{k,1}=['Loans to Consumers in Domestic Offices'];
Names_assets{k,2}=['ln_cons_dom'];
Names_assets{k,3}=['ln. cons. dom.'];

k=k+1;
Names_assets{k,1}=['Loans to Consumers in Foreign Offices'];
Names_assets{k,2}=['ln_cons_for'];
Names_assets{k,3}=['ln. cons. for.'];

k=k+1;
Names_assets{k,1}=['Loans to Depository Institutions  and Acceptances of Other Banks'];
Names_assets{k,2}=['ln_dep_inst_banks'];
Names_assets{k,3}=['ln. dep. inst.'];

k=k+1;
Names_assets{k,1}=['Other Loans'];
Names_assets{k,2}=['oth_loans'];
Names_assets{k,3}=['oth. loans'];

k=k+1;
Names_assets{k,1}=['Equity Securities that do not have Readly  Determinable Fair Value'];
Names_assets{k,2}=['equ_sec_nondet'];
Names_assets{k,3}=['equ. sec. undet.'];

k=k+1;
Names_assets{k,1}=['Other Assets'];
Names_assets{k,2}=['oth_ass'];
Names_assets{k,3}=['oth. ass.'];

k=k+1;
Names_assets{k,1}=['All Assets'];
Names_assets{k,2}=['all_ass'];
Names_assets{k,3}=['all ass.'];
%% Save Names
save(savepath , 'Names_assets','Names_Banks','allBanksEver','Names_Banks_Pers','States_Banks_pers') 
savepath_pers = '../data/data_domenico/saved_variables/Names_Banks_Pers.mat';
save(savepath_pers , 'Names_assets','Names_Banks_Pers','allBanksEver','States_Banks_pers') 
%% Add Names to files of matrices

save('../data/data_domenico/saved_variables/Net_COM_macro_store.mat','Positive_equity_Net_COM_macro_store','total_equity_positive', 'Positive_equity_Names_COM', 'Names_assets','Names_Banks','allBanksEver');
save('../../data/Real_networks_raw_data/bipartite/dataArtAssessing/USComBanksMatsAndEquities.mat',  'Positive_equity_Net_COM_macro_store','total_equity_positive', 'Positive_equity_Names_COM', 'Names_assets','Names_Banks','allBanksEver');













