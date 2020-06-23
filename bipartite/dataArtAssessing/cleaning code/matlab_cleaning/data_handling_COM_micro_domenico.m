


%This code loads the data produced with clean_data and organizes
%it in one weighted matrix for each year representing a network
%it removes the empty rows(banks not reporting anything)

%% Load data  
tic
clear all
close all
clc


i=1;

for year=2001:2013
    for Q=1:4
        str=['../data/data_domenico/networks_commercial/micro_nodes_network/RC',num2str(year),'_Q',num2str(Q)];
        M{i}=load(str);              
        i=i+1;
    end
end

T = i-2;  %non considero l'ultimo quarto altrimenti sarebbe i-1
toc
tic
%% Build net 

K=[];

for t=1:T         
        
    K=sortrows(M{t},-2);        
    
    Net = [];
    Net(:,1) = K(:,1);
    Net(:,2:47) = K(:,4:49);
    
    %remove the negative entries
    %Net(Net<0) = 0;
    
   Net_COM_micro_store_empty_rows{t} = Net;
   
           
    total_asset_micro_COM{t} = K(:,2);
    total_equity_micro_COM{t} = K(:,3);
    other_asset_micro_COM{t} = K(:,end);
   
 
end
   


%% Remove empty rows and NaNs



 
bank_id = cell(T,1); 
Net_micro_store= cell(T,1);
collect_bank_id_micro =[];
removed= zeros(T,5);
collect_all_bank_id_COM =[];

for t=1:T
      collect_all_bank_id_COM = [collect_all_bank_id_COM;  K(:,1);];
    K =  Net_COM_micro_store_empty_rows{t};
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
    
    total_asset_micro_COM{t}(rowstoremove) =[] ;
    total_equity_micro_COM{t}(rowstoremove) =[] ;
    other_asset_micro_COM{t}(rowstoremove) =[];
   
    removed(t,3) = removed(t,1) - removed(t,2);
    removed(t,4) = removed(t,2)/removed(t,1);
    removed(t,5) = length(find(K(:)==0))/length(K(:));
    %keep track of all the banks that appear at least once
    collect_bank_id_micro =[collect_bank_id_micro;K(:,1)];
    bank_id{t} = K(:,1);
    
           
    
    
    
    Net_COM_micro_store{t}=K;
  
end

collect_all_bank_id_COM = unique(collect_all_bank_id_COM);
toc
tic
%% check for empty colums
emptycol = [];
for t = 1:T
    for j=1:length(Net_COM_micro_store_empty_rows{t}(1,:))
        if(sum(Net_COM_micro_store_empty_rows{t}(:,j)) ~= 0 )
           emptycol =  [emptycol ; t j];

        end
    end
end
        
     
% %% various tests 
% test = [];
% for t=1:T
%     total = sum(sum(Net_COM_micro_store{1}(:,2:end)));
%     [minval minpos] = min(sum(Net_COM_micro_store{t}(:,2:end))./total);
%     [maxval maxpos] = max(sum(Net_COM_micro_store{t}(:,2:end))./total);
%    test = [test; t mean(sum(Net_COM_micro_store{t}(:,2:end))./total) minval minpos  maxval maxpos];
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



    savefile = '../data/data_domenico/saved_variables/Net_COM_micro_store.mat';

    save(savefile,'collect_all_bank_id_COM', 'Net_COM_micro_store', 'total_asset_micro_COM' , 'total_equity_micro_COM' , 'other_asset_micro_COM');


toc
