clc
close all
clear

%Importa i nomi delle banche fallite
filename = '../data/merger_data/merger_complete_file.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%*s%*s%*s%*s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
Names_failed_banks = dataArray{:, 1};
%clearvars filename delimiter startRow formatSpec fileID dataArray ans;

save ../data/data_domenico/saved_variables/All_failed_names.mat  'Names_failed_banks'

