% Questo script è pensato per analizzare l'evoluzione della popolazione di
% banche presenti nel dataset e i loro fallimenti
clear all
close all
clc 
addpath ../../matlab/
load ../data/data_domenico/saved_variables/Net_COM_macro_store.mat
load ../data/data_domenico/saved_variables/Names_COM.mat
%plotta le figure full screen nel secondo monitor
set(0,'DefaultFigurePosition', [1986 311 1600 1000])


Net_COM_macro_store =[];
Net_COM_macro_store = Positive_equity_Net_COM_macro_store;

T = max(size(Net_COM_macro_store));



%la variabile seguente è strutturata :
%|Data|Merger Code|Termination Code|Stressed COM ID|<-Parent BHC|Acquiring
%COM ID|<-Parent BHC|
merger_COM = dlmread('../data/data_domenico/merger_sorted/merger_COM.csv', ' ', 1,0);
% affianca una colonna finale che indica l'indice della banca nella lista.
% mi serve per associare i nomi (stringhe) alle banche 
merger_COM= [merger_COM (1:length(merger_COM(:,1)))'];

quarters = quarters_fun(2001,2015);

%% Lista tutte le banche presenti nel dataset, non solo le fallite
collect_bank_id_COM = [];
All_names_rep = [];
for t =1:T
    collect_bank_id_COM = [collect_bank_id_COM; sort(Net_COM_macro_store{t}(:,1))];
    number_COM_banks = length(Net_COM_macro_store{t}(:,1));
    All_names_rep = [All_names_rep; Names_Banks{t}(2:end,:)];
   
end
[collect_bank_id_COM,ia,~] = unique(collect_bank_id_COM);
All_names = All_names_rep(ia,:);


%% Seleziona i nomi delle top n anno per anno
n=20;
for t=1:T
    %total assets value in miliardi di dollari
    tot_ass_t = round(sum(Net_COM_macro_store{t}(:,2:end),2)./(10^6));
    top_ids_t = Net_COM_macro_store{t}(1:n,1);
    ids_time_t = str2double(Names_Banks{t,1}(2:end,1));
    names_t = char(Names_Banks{t,1}(2:end,4));
    [~,ib] = ismember(top_ids_t,ids_time_t);
    unit_measure = '  ($10^9$  \$)  ';
    latex_sep = '& ';
    top_names{t} = [names_t(ib,:) char(ones(n,1)*latex_sep) num2str(tot_ass_t(1:n)) char(ones(n,1)*unit_measure) ];
end

        
        
        
%% failed and discontinued from  03/2001 to present
%%Com Banks     
%sort by date
merger_COM= sortrows(merger_COM,1);

%select the dates after 20010301
index_COM = find(merger_COM(:,1) > 20010301,1);
merger_COM(1:index_COM,:) = [];

%convert the dates in matlab format
alldates = merger_COM(:,1);
for i = 1:length(alldates)
     num_date = datenum(sprintf('%d',alldates(i)),'yyyymmdd') ;
     alldates(i) = num_date ; 
end
merger_COM(:,1) = alldates;
%select rows  describing a failure  merger code 50
temp1 = merger_COM(merger_COM(:,2) == 50,:);
temp2 = merger_COM(merger_COM(:,3) == 4,:);
temp3 =  merger_COM(merger_COM(:,3) == 5,:);
failures_COM = unique([temp1; temp2; temp3],'rows');
failures_COM = sortrows(failures_COM,1);
%seleziona i casi di asset sale , merger code 7
sale_COM = merger_COM(merger_COM(:,2)==7,:);
%rimuovi gli asset sale culminati in un fallimento
remove_from_asset_sale = sale_COM(:,3) == 5;
sale_COM(remove_from_asset_sale,:) = [];
%seleziona i casi di split , merger code 7
split_COM = merger_COM(merger_COM(:,2)==5,:);
%rimuovi gli asset sale culminati in un fallimento
remove_from_split = split_COM(:,3) == 5;
split_COM(remove_from_split,:) = [];


temp = merger_COM(merger_COM(:,2) == 1,:);
disco_COM = temp(temp(:,3)==2,:);


%% Quali di quest banche sono presenti nel dataset ?? predispone per stampare tabella latex

%codes of all the banks failed. I use unique because when a bank fails 
%it can be acquired by more than one institution. In those cases the failed
%bank's Id is reported more than once
all_failed_id = unique(failures_COM(:,4));
%Banche fallite apparse almeno una volta nei dati
failed_id_present_net = intersect(all_failed_id,collect_bank_id_COM);
temp = failures_COM(:,4);
[~,~,ib] = intersect(failed_id_present_net , temp);
%this variable contains the dates of failure the reason  the Id of the
%failed inst and of the parent BHC, for the failed banks present in the
%network dataset
failures_present_net = failures_COM(ib,:);
failures_present_net = sortrows(failures_present_net,1);

%stessa cosa per assett sales , splits e discontinued
all_sale_id = unique(sale_COM(:,4));
all_split_id = unique(split_COM(:,4));
all_disco_id = unique(disco_COM(:,4));
%Banche spolit ,disco, sale apparse almeno una volta nei dati
sale_id_present_net = intersect(all_sale_id,collect_bank_id_COM);
temp = sale_COM(:,4);
[~,~,ib] = intersect(sale_id_present_net , temp);
sale_present_net = sale_COM(ib,:);
sale_present_net = sortrows(sale_present_net,1);

split_id_present_net = intersect(all_split_id,collect_bank_id_COM);
temp = split_COM(:,4);
[~,~,ib] = intersect(failed_id_present_net , temp);
split_present_net = split_COM(ib,:);
split_present_net = sortrows(split_present_net,1);

disco_id_present_net = intersect(all_disco_id,collect_bank_id_COM);
temp = disco_COM(:,4);
[C,ia,ib] = intersect(disco_id_present_net , temp);
disco_present_net = disco_COM(ib,:);
disco_present_net = sortrows(disco_present_net,1);

failures_present_net=  [failures_present_net zeros(length(failures_present_net(:,4)),1)];
%% quando sono presenti?
n=20;
failures_time_presence = zeros(length(failures_present_net(:,4)),T);
asset_of_failed_banks = zeros(length(failures_present_net(:,4)),T);
sale_time_presence = zeros(length(sale_present_net(:,4)),T);
asset_of_sale_banks = zeros(length(sale_present_net(:,4)),T);
disco_time_presence = zeros(length(disco_present_net(:,4)),T);
asset_of_disco_banks = zeros(length(disco_present_net(:,4)),T);
for t=1:T
    tot_ass_t = sum(Net_COM_macro_store{t}(:,2:end),2);
    ids_t = Net_COM_macro_store{t}(:,1);
    [~,ia,ib]= intersect(failures_present_net(:,4),ids_t);
    failures_time_presence(ia,t) = ib;
    asset_of_failed_banks(ia,t) = tot_ass_t(ib);
    [~,ia,ib]= intersect(sale_present_net(:,4),ids_t);
    sale_time_presence(ia,t) = ib;
    asset_of_sale_banks(ia,t) = tot_ass_t(ib);
    [~,ia,ib]= intersect(disco_present_net(:,4),ids_t);
    disco_time_presence(ia,t) = ib;
    asset_of_disco_banks(ia,t) = tot_ass_t(ib);
end
unit_measure = '   ($10^9$  \$)  ';
 latex_sep = '  &  ';  
%failed 
%calcolo la media sui periodi di vita del total asset
failures_present_net(:,9) = sum(asset_of_failed_banks,2)./sum(logical(asset_of_failed_banks),2);
%ordino in base al valore medio tei total asset
temp= sortrows(failures_present_net,-9);
%seleziono gli id delle prime n
top_50_failed_id= temp(1:n,4);
[~,ia,ib]=intersect(top_50_failed_id,collect_bank_id_COM,'stable');
top_50_failed_names=[];
top_50_failed_names = All_names(ib,:);
Table_failed_top = [char(top_50_failed_names(:,4)) char(ones(n,1)*latex_sep) num2str(round(temp(1:n,9)./10^5)./10) char(ones(n,1)*unit_measure)];
%sale
sale_present_net(:,9) = sum(asset_of_sale_banks,2)./sum(logical(asset_of_sale_banks),2);
temp= sortrows(sale_present_net,-9);
top_50_sale_id= temp(1:n,4);
[~,ia,ib]=intersect(top_50_sale_id,collect_bank_id_COM,'stable');
top_50_sale_names=[];
top_50_sale_names = All_names(ib,:);
Table_sale_top = [char(top_50_sale_names(:,4)) char(ones(n,1)*latex_sep) num2str(round(temp(1:n,9)./10^5)./10) char(ones(n,1)*unit_measure)];
%disco
disco_present_net(:,9) = sum(asset_of_disco_banks,2)./sum(logical(asset_of_disco_banks),2);
temp= sortrows(disco_present_net,-9);
top_50_disco_id= temp(1:n,4);
[~,ia,ib]=intersect(top_50_disco_id,collect_bank_id_COM,'stable');
top_50_disco_names=[];
top_50_disco_names = All_names(ib,:);
Table_disco_top = [char(top_50_disco_names(:,4)) char(ones(n,1)*latex_sep) num2str(round(temp(1:n,9)./10^5)./10) char(ones(n,1)*unit_measure)];

%% Distributisci gli eventi via last tick interpolation
failures_times_COM =  cell(T,1);
number_failed = zeros(T,1);
for i=1:length(failures_present_net(:,1))
    
    allocated = false;
    t=1;
    last_viable_time = 1;
    while allocated == false && t<T
      
        if failures_present_net(i,1) <= quarters(t)
            failures_times_COM{last_viable_time,1} = [failures_times_COM{last_viable_time,1}; failures_present_net(i,4)];
            allocated = true;
            number_failed(last_viable_time) = number_failed(last_viable_time) +1;
        
        end
        
          if failures_time_presence(i,t)~=0
            last_viable_time = t;
          end
        t = t+1;
    end
        
end

sale_times_COM =  cell(T,1);
number_sale = zeros(T,1);
for i=1:length(sale_present_net(:,1))
    
    allocated = false;
    t=1;
    last_viable_time = 1;
    while allocated == false && t<T
      
        if sale_present_net(i,1) <= quarters(t)
            sale_times_COM{last_viable_time,1} = [sale_times_COM{last_viable_time,1}; sale_present_net(i,4)];
            allocated = true;
            number_sale(last_viable_time) = number_sale(last_viable_time) +1;
        
        end
        
          if sale_time_presence(i,t)~=0
            last_viable_time = t;
          end
        t = t+1;
    end
        
end
    
    
    
    
%%
% figure(1)
% plot(quarters(1:T),number_failed./number_COM_banks.*100,'b',....
%     quarters(1:T),number_sale./number_COM_banks.*100,'r')
%  date_ticks = sort([quarters(1,1:ceil(T/4)) quarters(3,1:ceil(T/4))]);
%    set(gca,'ColorOrder', jet(8),'XTick',date_ticks(1:end),'XGrid','on','XMinorGrid','on','YGrid','on')
% dateFormat = 27;
% datetick('x',dateFormat,'keepticks')
% xlabel('Times','Interpreter','Latex','FontSize',10)
% ylabel('Banks failed right after time t/Banks present at time t ','Interpreter','Latex','FontSize',10)
% rotateXLabels( gca(), 45 )
% xlabh = get(gca,'XLabel');
% set(xlabh,'Position',get(xlabh,'Position') - [0 .04 0])
% title('Percentage of Banks Failed','Interpreter','Latex','FontSize',18)
% legend('Failed','Assett Sale')
% savepath = '../figures/figures_domenico/Data_description_chpt/fraction_failed_banks.eps';
% saveas(gca,savepath,'epsc')
% 
% figure(2)
% plot(quarters(1:T),number_failed,'b',....
%     quarters(1:T),number_sale,'r')
%  date_ticks = sort([quarters(1,1:ceil(T/4)) quarters(3,1:ceil(T/4))]);
%    set(gca,'ColorOrder', jet(8),'XTick',date_ticks(1:end),'XGrid','on','XMinorGrid','on','YGrid','on')
% dateFormat = 27;
% datetick('x',dateFormat,'keepticks')
% xlabel('Times','Interpreter','Latex','FontSize',10)
% ylabel('Banks failed right after time t ','Interpreter','Latex','FontSize',10)
% rotateXLabels( gca(), 45 )
% xlabh = get(gca,'XLabel');
% set(xlabh,'Position',get(xlabh,'Position') - [0 .04 0])
% title('Failed Banks','Interpreter','Latex','FontSize',18)
% legend('Failed','Assett Sale')
% savepath = '../figures/figures_domenico/Data_description_chpt/total_failed_banks.eps';
% saveas(gca,savepath,'epsc')


%% save data

save('../data/data_domenico/saved_variables/banks_popolation.mat', 'failures_times_COM',.....
      'merger_COM','sale_times_COM','number_failed')
















