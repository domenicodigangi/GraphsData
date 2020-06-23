
clear all
close all
clc 

% Data loading
tic

path='../data/COM_data/sorted/';
files = dir([path,'*.txt']);
numfiles= length(files);
data = cell(1, numfiles);
codici = cell(1,numfiles);
delimiter = '\t';
startRow = 3;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

indices_RCFD = cell(1,numfiles);
indices_RCON = cell(1,numfiles);
T = numfiles;

for i=1:T
    filename = [path,files(i).name];
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);
    data{i} = cell2mat(dataArray(1:end-1));
    
    
    
    %if the RCFD code for total asset is absent(NaN) than the bank belongs
    %to the group domestic RCON
    indices_RCON{i} = isnan(data{i}(:,3));
    %otherwhise if the RCFD code for total asset is present , the bank
    %belongs to the consolidated group
    indices_RCFD{i} = ~isnan(data{i}(:,3));
    data{i}(isnan(data{i}))=0;
    N_codici = length(data{i}(1,:));
    fileID = fopen([path,files(i).name]);
    C_text = textscan(fileID,'%s',N_codici+1,'delimiter','\t');
    codici{i} = C_text{1,1};
    N_banks(i) = length(indices_RCON{i});
end


m=cell(1,T);



toc

   %% BAnks names
tic

column_pos =1;
    
    for t = 1:T
         m{t}(:,column_pos) = data{t}(:,1);
    end
   
    


%% Total assets

    column_pos = column_pos + 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num =['2170' ; '2123'; '3123' ] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
        
    end
    
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1))        
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo
                break
            end
        end
        if(found == 0)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
 for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1:3; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


       end
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
 end

 
  
%% Total Equity

    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num =['3210'; '3000'; 'G105' ] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
        
    end
    
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo
                break
            end
        end
        if(found == 0)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
    
    for t = 1:32  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1:2; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


       end
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
 end

 for t = 33:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 3; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


       end
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
 end


  

 
    
    %% Cash and Balances : cashab


   column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num =['0081'] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
        
    end
    
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


       end
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
 end

  % cashab 2
  
  
   column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num =[ '0071' ] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
        
    end
    
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


       end
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end

  
   %% ust_sec 
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['0211'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
   
    %per il periodo definito dal ciclo seguente costruisco la variabile
    
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           
           m{t}(:,column_pos) = var_final;
    end
  
 
    %ust_sec2
    

    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1287'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
   
    %per il periodo definito dal ciclo seguente costruisco la variabile
    
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
    codes_needed_t = 1; %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           
           m{t}(:,column_pos) = var_final;
    end
  

 
    %ust_sec 3
    
    column_pos = column_pos +1;
     manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCON3531']; 
    end
    
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:T 
        var_final=[];
         var_RCFD = zeros(N_banks(t),1);
         var_RCON = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

          
           %same code for RCON and RCFD
           var_final = data{t}(:,var_code_col(1)) ;
            
             
           m{t}(:,column_pos) = var_final;
    end

    
    
    
    
     %% agency_sec

    
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1289'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    %agency_sec 2 
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1294' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
            var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    %agency_sec 3
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1293' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
            var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    %agency_sec 4
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1298' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    %agency_sec 5
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes = ['RCON3532' ];
    
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);;
      for c = 1 : length(var_codes(:,1))                     
           var_final = var_final +  data{t}(:,var_code_col(c)) ;        
           
      end
           m{t}(:,column_pos) = var_final;
    end
    
   
    %% State_sec
    
     
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['8496' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    
     %state_sec 2
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['8499' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    
     %state_sec 3
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes = ['RCON3533' ];
    
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);;
      for c = 1 : length(var_codes(:,1))                     
           var_final = var_final +  data{t}(:,var_code_col(c)) ;        
           
      end
           m{t}(:,column_pos) = var_final;
    end
    
    
    %% mbs
    %mbs 1
     
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1698';  '1703';  '1709'; 'G300';  'G304';  'G308'; 'G324'; 'K142'; 'K146' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:3;
    for t = 1:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
    end
   

    codes_needed_t = 4:7;
     for t = 34:40  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           if(manual_last_var==1)
             var_final = var_final;
           end
           
           m{t}(:,column_pos) = var_final;
     end
   
   
    codes_needed_t =[ 4:6 8:9];
     for t = 41:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
         end                 
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         
      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
     end
    
    
      %mbs 2
     
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = [ '1702'; '1707'; '1713'; 'G303'; 'G307';  'G311'; 'G327'; 'K145'; 'K149';  ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:3;
    for t = 1:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
    end
   

    codes_needed_t = 4:7;
     for t = 34:40  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           if(manual_last_var==1)
             var_final = var_final ;
           end
           
           m{t}(:,column_pos) = var_final;
     end
   
   
    codes_needed_t = [ 4:6 8:9];
     for t = 41:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
         end                 
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         
      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
     end
    
    
      %mbs 3
     
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1714'; '1718'; '1733'; 'G312'; 'G316'; 'G320'; 'G328'; 'K150'; 'K154'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:3;
    for t = 1:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
    end
   

    codes_needed_t = 4:7;
     for t = 34:40  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           if(manual_last_var==1)
             var_final = var_final;
           end
           
           m{t}(:,column_pos) = var_final;
     end
   
   
    codes_needed_t = [4:6 8:9];
     for t = 41:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
         end                 
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         
      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
     end
    
     %mbs 4
     
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1717'; '1732';'1736'; 'G315'; 'G319'; 'G323'; 'G331' ; 'K153'; 'K157';  ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:3;
    for t = 1:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
    
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
    end
   

    codes_needed_t = 4:7;
     for t = 34:40  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           if(manual_last_var==1)
             var_final = var_final ;
           end
           
           m{t}(:,column_pos) = var_final;
     end
   
   
    codes_needed_t = [ 4:6 8:9];
     for t = 41:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
     var_final = zeros(N_banks(t),1);
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
         end                 
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         
      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           
           m{t}(:,column_pos) = var_final;
     end
    
    
     %mbs5 trading
     
    
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes = ['RCON3534'; 'RCON3535'; 'RCON3536'];
    
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);;
      for c = 1 : length(var_codes(:,1))                     
           var_final = var_final +  data{t}(:,var_code_col(c)) ;        
           
      end
           m{t}(:,column_pos) = var_final;
    end
     
     
     
       var_codes = ['RCONG379'; 'RCONG380'; 'RCONG381'; 'RCONG382'];  
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 34:40  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);;
      for c = 1 : length(var_codes(:,1))                     
           var_final = var_final +  data{t}(:,var_code_col(c)) ;        
           
      end
           m{t}(:,column_pos) = var_final;
    end
     
     
      
     
       var_codes = ['RCONG379'; 'RCONG380'; 'RCONG381'; 'RCONK197'; 'RCONK198'];  
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t =41:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = zeros(N_banks(t),1);;
      for c = 1 : length(var_codes(:,1))                     
           var_final = var_final +  data{t}(:,var_code_col(c)) ;        
           
      end
           m{t}(:,column_pos) = var_final;
    end
     
     
     
     
      %% abs
    
         %abs 1
    column_pos = column_pos+1;
    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['B838';  'B842'; 'B846'; 'B850'; 
                    'B854';  'B858'; 'C026'; 'G336'; 'G340'; 'G344'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:6;
    for t = 1:20  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
      
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
   
    
    codes_needed_t = 7;
    for t = 21:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
      
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
   
      
    codes_needed_t = 7:10;
    for t = 34:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
     
     
     
     
     
     
      %abs 2
    column_pos = column_pos+1;
    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = [ 'B841';  'B845'; 'B849';  'B853'; 'B857'; 'B861'; 'C027';
                    'G339'; 'G343'; 'G347'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1:6;
    for t = 1:20  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
      
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
   
    
    codes_needed_t = 7;
    for t = 21:33  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
      
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
   
      
    codes_needed_t = 7:10;
    for t = 34:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           m{t}(:,column_pos) = var_final;
    end
     
     
     
      
    %% dom_debt_oth_sec
    
    %1
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1737' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
     
      
    %2
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1741' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
     
    %% For_DEBT_OTH_SEC 
      
    %1
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1742' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
     
      %2
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1746' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
    
    
    %% Residual securities
    
      %1
    column_pos = column_pos +1;    
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['A511' ];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile

    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    var_final = [];
      for c = 1 : length(var_codes_num(:,1))                     
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*c -1)) ;        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*c)) ;  
      end
      
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
    
     
  %% FF_REPO_ASS
   column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1350';  'B989'; ] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    if(manual_last_var ==1)
        var_codes =[var_codes ; 'RCONB987' ]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1;
    for t = 1:4  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
   
     codes_needed_t = 2;
    for t = 5:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
      
      if(manual_last_var ==1)
      %aggiungo RCONB987
        if(~strcmp( codici{t}{var_code_col(end)} , var_codes(end,:) ) )
              var_codes(end,:)
              t
              error('not found')
        end                     
      end    
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           if(manual_last_var==1)
             var_final = var_final +  data{t}(:,var_code_col(end)) ;
           end
           
           m{t}(:,column_pos) = var_final;
    end
   
  
    %% LN_RE_DOM
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    var_codes = ['RCON1415'; 'RCONF158'; 'RCONF159']; 
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:28  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    
       
    codes_needed_t = [2 3];
    for t = 29:T  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell lenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end 
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
 
    
    %ln_re_dom2
    
       column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes = ['RCON1420' ]; 
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:T  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    %ln_re_dom3
    
       column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes = ['RCON5367' ]; 
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t =1;
    for t = 1:T  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
   %ln_re_dom4
    
       column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    var_codes = [ 'RCON5368']; 
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:T  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    
   
    %ln_re_dom5
       column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    var_codes = ['RCON1797' ]; 
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:T 
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    
    %ln_re_dom6
       column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    var_codes = ['RCON1460' ]; 
    
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t =1;
    for t = 1:T  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    % ln_re_dom7
       column_pos = column_pos +1;
   
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    
    var_codes = [  'RCON1480'; 'RCONF160'; 'RCONF161' ]; 
    
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1;
    for t = 1:28  
         var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end

          
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
   
   
    
       
    codes_needed_t = [2 3];
    for t = 29:T 
        var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell lenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 var_final = var_final +  data{t}(:,var_code_col(codes_needed_t(l))) ;
         end 
           
           
            
         
           m{t}(:,column_pos) = var_final;
    end
 
    
    
    
    
   %% LN_RE_FOR
    
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
      var_codes = [];
    
   % a different composition is needed. see RC-C footnote 1
        var_codes= ['RCFD1410'; 'RCFDF158'; 'RCFDF159'; 'RCFD1420'; 'RCFD5367'; 'RCFD5368'; 
                    'RCFD1797'; 'RCFD1460';'RCFDF160'; 'RCFDF161'; ]; 
         found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
    codes_needed_t = 1;
    for t = 1:49 
        
       
         var_final = zeros(N_banks(t),1);
         var_RCFD1 =zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         
         
    
      codes_needed_t = 1;
           for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
           end
           
          indices_ln_re_for1 = find(data{t}(:,var_code_col(1))~=0);
          var_RCFD1 =  data{t}(:,var_code_col(1)) ;
          
          ln_re_dom = sum( m{t}(:,column_pos - [1:7]),2);
        
          var_final(indices_ln_re_for1) = var_RCFD1(indices_ln_re_for1) - ln_re_dom(indices_ln_re_for1);
            
         
           m{t}(:,column_pos) = var_final ; 
    end
   
   codes_needed_t = 1:10;
    for t = 50:T
        
        
         var_final = zeros(N_banks(t),1);
         var_RCFD1 =zeros(N_banks(t),1);
        
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end

         end
         
          var_RCFD1 =zeros(N_banks(t),1);
          var_RCFD1 = data{t}(:,var_code_col(1)) ;
          indices_ln_re_for1 = find(data{t}(:,var_code_col(1))~=0);
           
          
          temp =[];
          temp = [ find(data{t}(:,var_code_col(2))~=0); find(data{t}(:,var_code_col(3))~=0);
                   find(data{t}(:,var_code_col(4))~=0); find(data{t}(:,var_code_col(5))~=0);
                   find(data{t}(:,var_code_col(6))~=0); find(data{t}(:,var_code_col(7))~=0);
                   find(data{t}(:,var_code_col(8))~=0); find(data{t}(:,var_code_col(9))~=0);
                   find(data{t}(:,var_code_col(10))~=0) ] ;
                   
          temp = unique(temp);
          indices_ln_re_for2 = temp;
       
             
             var_RCFD2 = zeros(N_banks(t),1);
             codes_needed_t = 1;
             
           for l=2:10
               var_RCFD2 = var_RCFD2 +  data{t}(:,var_code_col(l)) ;
           end
          
          
         ln_re_dom = sum( m{t}(:,column_pos - [1:7]),2);
         var_final(indices_ln_re_for2) = var_RCFD2(indices_ln_re_for2) - ln_re_dom(indices_ln_re_for2);
         var_final(indices_ln_re_for1) = var_RCFD1(indices_ln_re_for1) - ln_re_dom(indices_ln_re_for1);
            
         
           m{t}(:,column_pos) = var_final ; 
    
    end
   
    
     %% LN_CI_DOM
  
  
  
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCON1766'; 'RCON1763'; 'RCON1764';]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1:3;
    for t = 1:T 
         var_RCFD = zeros(N_banks(t),1);
         var_RCON = zeros(N_banks(t),1);
         var_final = [];
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

          
           var_RCON = data{t}(:,var_code_col(1)) ;
           var_RCFD = data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3)) ;
           
             
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
   
    
    %% LN_CI_FOR
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCFD1763'; 'RCFD1764';]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1:2;
    for t = 1:T 
        var_final=[];
         var_RCFD = zeros(N_banks(t),1);
         var_RCON = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

          
           
           var_RCFD = data{t}(:,var_code_col(1)) + data{t}(:,var_code_col(2)) - m{t}(:,column_pos-1);
            
             
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
           m{t}(:,column_pos) = var_final;
    end
   
    
    
    
    
      %% LN_CONS_DOM
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCON2011'; 'RCONB538'; 'RCONB539'; 'RCONK137'; 'RCONK207';]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1:3;
    for t = 1:40 
        var_final = [];
         
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

         
             
           var_final = data{t}(:,var_code_col(1)) + data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3));
          
         
           m{t}(:,column_pos) = var_final;
    end
   
    codes_needed_t = 2:5;
    
     for t = 41:T 
         
          var_final = [];
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

         
             
           var_final = data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3)) + data{t}(:,var_code_col(4)) + data{t}(:,var_code_col(5));
          
         
           m{t}(:,column_pos) = var_final;
    end
   
    
    
    
        
      %% LN_CONS_FOR
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCFD2011'; 'RCFDB538'; 'RCFDB539'; 'RCFDK137'; 'RCFDK207';]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1:3;
    for t = 1:40 
        var_RCFD = [];
        var_final = zeros(N_banks(t),1);
         
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

         
             
           var_RCFD = data{t}(:,var_code_col(1)) + data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3)) - m{t}(:,column_pos-1);
                      
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
                 
         
         
           m{t}(:,column_pos) = var_final;
    end
   
    
       
     codes_needed_t = 2:5;
     for t = 41:T 
          var_RCFD = [];
          var_final = zeros(N_banks(t),1);
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

         
             
           var_RCFD = data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3)) + data{t}(:,var_code_col(4)) + data{t}(:,var_code_col(5)) - m{t}(:,column_pos-1);
              
          
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
         
           m{t}(:,column_pos) = var_final;
    end
   
    
    
    
    
    
        %% LN_DEP_INST_BANKS
    
    column_pos = column_pos +1;
    manual_last_var = 1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    
    if(manual_last_var ==1)
        var_codes = ['RCON1288'; 'RCFDB532'; 'RCFDB533'; 'RCFDB534'; 'RCFDB536'; 'RCFDB537';]; 
    end
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
    codes_needed_t = 1:6;
    for t = 1:T 
        var_final = [];
        var_RCON = [];
        var_RCFD = [];
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   
         for l=1:length(codes_needed_t)
             %cerca RCON
              if(~strcmp( codici{t}{var_code_col(codes_needed_t(l)) } , var_codes( codes_needed_t(l) ,:) ) )
                  var_codes(codes_needed_t(l) ,:)
                  t
                  error('not found')
              end


                 
         end

         
             
           var_RCON = data{t}(:,var_code_col(1)) ;
           var_RCFD = data{t}(:,var_code_col(2)) + data{t}(:,var_code_col(3)) + data{t}(:,var_code_col(4)) + data{t}(:,var_code_col(5)) + data{t}(:,var_code_col(6));
          
           var_final = var_RCON;
           
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
         
         
           m{t}(:,column_pos) = var_final;
    end
   
    
    %% other loans
    %oth_loans1
    
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['2081'];
   for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1;
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
   
  
    
      %oth_loans2
    
    column_pos = column_pos +1;
  
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1590'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1;
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
   
    
     %oth_loans3
    
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['2182';  '2183'; 'F162'; 'F163' ] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
     codes_needed_t = 1:2;
    for t = 1:24  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
     codes_needed_t = 3:4;
    for t = 25:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
                    
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
          
           m{t}(:,column_pos) = var_final;
    end
    
    
    
      %oth_loans4 (residual loans)
    
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['2122';  '2123'] ;
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
   
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
   
     codes_needed_t = 1:2;
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           preced_loans = sum( m{t}(:,column_pos - [1:16]),2);
           m{t}(:,column_pos) = var_final - preced_loans;
    end
   
   
    
    
    %% EQU_SEC_nondet
    
      
    
    column_pos = column_pos +1;
  
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['1752'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1;
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
    
    
     %% oth_ass 1
    
      
    
    column_pos = column_pos +1;
  
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
    var_codes = [];
    var_codes_num = [];
    var_codes_num = ['2150'];
    for i= 1: length(var_codes_num(:,1))
    
        var_codes =[var_codes ; 'RCFD' var_codes_num(i,:); 'RCON' var_codes_num(i,:)];
       
    end
    
     found = 0;    
    var_code_col = zeros(length(var_codes(:,1)),1); %conterrà l'indice di colonna corrispondente al codice in var_codes
    %cerco le posizioni dei codici necessari a formare la variabile
    for j=1:length(var_codes(:,1)) 
        found = 0;  
        for t=1:T
            for k = 1:N_codici
                    if(strcmp(var_codes(j,:) , codici{t}{k})) 
                        var_code_col(j) = k;
                        found = 1;
                        break                    
                    end               
            end
            if(found == 1) % se non è stato trovato cercalo al t successivo                
                break
            end
        end
        if(found == 0)
            var_codes(j,:)
            error('did not find the code at any time');
        end          
    end
    
    %per il periodo definito dal ciclo seguente costruisco la variabile
   
    codes_needed_t = 1;
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
    var_RCFD = zeros(N_banks(t),1);
    var_RCON = zeros(N_banks(t),1);
    
      for c = 1 : length(codes_needed_t)    
          %cerca RCFD
          if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c)) - 1} , var_codes( 2*codes_needed_t(c) -1,:) ) )
              var_codes(2*codes_needed_t(c) -1,:)
              t
              error('not found')
          end
          %cerca RCON
         if(~strcmp( codici{t}{var_code_col(2*codes_needed_t(c))} , var_codes( 2*codes_needed_t(c),:) ) )
              var_codes(2*codes_needed_t(c) ,:)
              t
              error('not found')
          end
                  
                      
           var_RCFD = var_RCFD +  data{t}(:,var_code_col(2*codes_needed_t(c) -1)) ;
        
           var_RCON = var_RCON +  data{t}(:,var_code_col(2*codes_needed_t(c))) ;
         


      end
     
           
           var_final = var_RCON;
           var_final(indices_RCFD{t}) = var_RCFD(indices_RCFD{t});
           
           m{t}(:,column_pos) = var_final;
    end
   
      %oth_ass 2
    
    column_pos = column_pos +1;
    %definisco e cerco i codici che uso successivamente per formare la
    %variabile in tutti i periodi. Quindi qui elenco tutti i codici
    %relativi alla variabile
   
    for t = 1:T  
    %compongo la variabile per le banche rispettivamente RCFD RFCON
     %contiene gli indici(nell elenco dei codici a quattro char) dei codici che servono nel periodo del ciclo for
   tot_ass =[];
   preced_ass = [];
    
           tot_ass = m{t}(:,2);
           preced_ass = sum( m{t}(:,[4:column_pos-1]),2);
           m{t}(:,column_pos) = tot_ass - preced_ass;
    end
  
    

    toc
     %% Save micro clean data
tic
year=2001;
quarter=1;

 for i=1:T
       
     tosavemicro = ['../data/data_domenico/networks_commercial/micro_nodes_network/RC',num2str(year),'_Q',num2str(quarter)];
    
     
     dlmwrite(tosavemicro, m{i}, 'delimiter' , ' ' ,  'precision' , 20 );

    quarter=quarter+1;
    if(quarter==5)
        quarter=1;
        year=year+1;
    end
 end
  
 
 toc
    