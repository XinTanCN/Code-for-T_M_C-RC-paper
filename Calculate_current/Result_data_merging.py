# -*- coding: utf-8 -*-
"""
Created on Mon Nov 27 2023

@author: Tan Xin tanxin@buaa.edu.cn
"""

from spacepy import pycdf
import pandas as pd
import numpy as np
from General_function import search_files
RE=6371.2

#%% Initial setting
folder_path='...Data\\'
EP_threshold=0.85
MLAT_threshold=30
Angle_threshold=60
L_min=2
L_max=8

#%% Filter result

def filter_result(temp_result):
    result=temp_result.dropna(subset=['MLT'])
    result=result[((result['Mission']==116) & (result['Elongation']<EP_threshold)) | ((result['Elongation']<EP_threshold) & (result['Planarity']<EP_threshold))]
    result=result[(result['L'] > L_min) & (result['L'] < L_max)]
    result=result[(result['Angle'].isnull()) | ((90-abs(90-result['Angle'])) < Angle_threshold)]
    result=result[abs(result['MLAT']) < MLAT_threshold]
    return result
#%% MMS
result=pd.DataFrame()
files = search_files(folder_path, 'mms *-* result.cdf')

for fn in files:
    print('Loading  '+fn)
    cdf=pycdf.CDF(fn)
    cdf_dat=cdf.copy()
    temp_result=pd.DataFrame(cdf_dat)
    temp_result['Angle']=np.nan
    result=pd.concat([result,filter_result(temp_result)],axis=0,verify_integrity=True,ignore_index=True)
    cdf.close()
#%% THEMIS

files = search_files(folder_path, 'th *-* result.cdf')

for fn in files:
    print('Loading  '+fn)
    cdf=pycdf.CDF(fn)
    cdf_dat=cdf.copy()
    result=pd.concat([result,filter_result(pd.DataFrame(cdf_dat))],axis=0,verify_integrity=True,ignore_index=True)
    cdf.close()    
#%% Cluster

files = search_files(folder_path, 'C *-* result.cdf')

for fn in files:
    print('Loading  '+fn)
    cdf=pycdf.CDF(fn)
    cdf_dat=cdf.copy()
    temp_result=pd.DataFrame(cdf_dat)
    temp_result['Angle']=np.nan
    result=pd.concat([result,filter_result(temp_result)],axis=0,verify_integrity=True,ignore_index=True)
    cdf.close()
#%% Save result
print('Saving result...')
from datetime import datetime
fn=folder_path+datetime.now().strftime('%Y-%m-%d')+' tcm_rc_result.cdf'
cdf=pycdf.CDF(fn,'')
epoch=[]
for t in result['Epoch']:
    epoch.append(datetime.utcfromtimestamp(t.timestamp()))
cdf['Epoch']=epoch

cdf['Jphi']=result['sm_Jphi']
cdf['Jphi'].attrs['description']='phi component of current density in sm sphere coordinate system'
cdf['Jphi'].attrs['units']='nA/m2'

cdf['L']=result['L']
cdf['L'].attrs['description']='L value'
cdf['L'].attrs['units']='RE'

cdf['MLT']=result['MLT']
cdf['MLT'].attrs['description']='magnetic local time'
cdf['MLT'].attrs['units']='hour'

cdf['MLAT']=result['MLAT']
cdf['MLAT'].attrs['description']='magnetic latitude'
cdf['MLAT'].attrs['units']='degree'

cdf['Tilt']=result['dipole_Tilt']
cdf['Tilt'].attrs['description']='dipole tilt angle'
cdf['Tilt'].attrs['units']='degree'

cdf['SYM_H']=result['SYM_H']
cdf['SYM_H'].attrs['units']='nT'

cdf['AE']=result['AE']
cdf['AE'].attrs['units']='nT'

cdf['Angle']=result['Angle']
cdf['Angle'].attrs['description']='angle between normal direction of the three-spacecraft plane and the phi direction'
cdf['Angle'].attrs['units']='degree'

cdf['X']=result['sm_Rx']
cdf['X'].attrs['description']="x component of constellation's mesocenter position in sm coordinate system"
cdf['X'].attrs['units']='km'

cdf['Y']=result['sm_Ry']
cdf['Y'].attrs['description']="y component of constellation's mesocenter position in sm coordinate system"
cdf['Y'].attrs['units']='km'

cdf['Z']=result['sm_Rz']
cdf['Z'].attrs['description']="z component of constellation's mesocenter position in sm coordinate system"
cdf['Z'].attrs['units']='km'

cdf['Size']=result['Char_Size']
cdf['Size'].attrs['description']="characteristic size of constellation"
cdf['Size'].attrs['units']='km'

cdf['E']=result['Elongation']

cdf['P']=result['Planarity']

cdf['Mission']=result['Mission']
cdf['Mission'].attrs['description']="Cluster:99 THEMIS:116 MMS:109"

cdf.attrs['Author']='Tan Xin  tanxin@buaa.edu.cn'
cdf.attrs['CreatDate']=datetime.now().strftime('%Y-%m-%d')

cdf.close()
