# Script to  download temporal networks datasets from network repository

#%% Import packages
import requests
import os
from bs4 import BeautifulSoup
import zipfile

#%% fetch html of page with listing of all dynamic networks
url = "http://networkrepository.com/dynamic.php"
headers = {  'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:55.0) Gecko/20100101 Firefox/55.0',}
page = requests.get(url, headers=headers)
soup = BeautifulSoup(page.content, 'html.parser')
all_icons_download = soup.find_all('i', class_ = 'icon-download-alt')


#%% download all networks
for d in all_icons_download:
    url_d = d.next_sibling.next_sibling["href"]
    print(url_d)
    data = requests.get(url_d, headers=headers)
    name = url_d[41:]
    print(name)
    # look up the specific page for this dataset and search for metadata
    foundMetaDataText = BeautifulSoup(requests.get(f"http://networkrepository.com/{name[:-4]}.php", headers=headers).content, 'html.parser').find_all(text=" Metadata")
    print(foundMetaDataText)
    # if the dataset has some metadata associated, download it    
    if len(foundMetaDataText) > 0 :
        open(f"raw_data_files/zip_files/{name}", 'wb').write(data.content)
        print(f"Downloading {name}")
    else:
        print(f"Metadata not found for  {name}")




#%% unzip downloaded files
load_direct = "./raw_data_files/zip_files/"
unzip_direct = "./raw_data_files/"
files = os.listdir(load_direct) 
files = list(filter(lambda f: f.endswith('.zip'), files))

for f in files:
    with zipfile.ZipFile(load_direct + f, 'r') as zip_ref:
        zip_ref.extractall(unzip_direct)


























# %%
