clc
close all
clear


%%
path='../data/COM_data/banks_names/';
files_in_dir = dir([path,'FFIEC*']);

for i = 1:size(files_in_dir,1)
    oldname = files_in_dir(i).name;
    date_i = oldname(35:42)
    new_name = ['FFIEC_names_' date_i(5:end) '_' date_i(1:2)]
     movefile([path oldname],[path new_name '.txt'])
end