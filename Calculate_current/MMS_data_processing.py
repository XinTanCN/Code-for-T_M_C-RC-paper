"""
Created on Mon Oct 30 2023

@author: Tan Xin tanxin@buaa.edu.cn
"""

from pyspedas.mms import fgm,mec
import numpy as np
from multi_spacecraft_analysis import (fgm_substract_igrf,sm_gsm,size_elongation_planarity,
                                       b_car_sph,footpoint_on_xy_sm,curlometer)
import pyspedas.omni as omni
import pandas as pd
RE=6371.2 # Earth radiu
mission='mms' # Mission name in the data variable name
file_dir='...Data\\'

#%% Function for resampling tplot MMS data
# ----------------------------------

def average_data_mms(dataset,varname):

    probe=varname[:5]
    if 'fgm_b_gsm' in varname:
        name=probe+'gsm_B'
    elif 'mec_r_gsm' in varname:
        name=probe+'gsm_R'
    elif 'mec_dipole_tilt' in varname:
        name='dipole_Tilt'
    else:
        name=probe+varname[-4:]
        
    dim=dataset[varname]['y'].ndim
    if dim == 1:
        var=pd.DataFrame({name:dataset[varname]['y']},
                         index=dataset[varname]['x'])
    else:
        var=pd.DataFrame({name+'x':dataset[varname]['y'][:,0],
                          name+'y':dataset[varname]['y'][:,1],
                          name+'z':dataset[varname]['y'][:,2]},
                         index=dataset[varname]['x'])
        if 'fgm_b_gsm' in varname:
            var=var.resample('1T').mean().shift(1,freq='30S') # Resampling FGM data at each one-minute interval and shifting timestampto the middle
    return var

#%% Resampling FGM & MEC data within a given time range at one-minute intervals

trange=['2016-04-30', '2016-05-01'] # Timespan
probes=['1','2','3','4']
fgm_varnames=['fgm_b_gsm_srvy_l2'] # Magnetic field data in GSM coordinate system, units: nT
mec_varnames=['mec_r_gsm','mec_mlat','mec_mlt'] # Locations in GSM coordinate system, units: km  # MLAT: degree  # MLT: hour

#%%% Loading specific FGM data
varnames_fgm=[]
for i in probes:
    for j in fgm_varnames:
        varnames_fgm.append(mission+i+'_'+j)

fgm_vars=fgm(trange=trange,data_rate='srvy',probe=probes,varnames=varnames_fgm,notplot=True)

#%%% Loading specific MEC data
varnames_mec=[]
for i in probes:
    for j in mec_varnames:
        varnames_mec.append(mission+i+'_'+j)
varnames_mec.append(mission+'1_mec_dipole_tilt')

mec_vars=mec(trange=trange,data_rate='srvy',probe=probes,varnames=varnames_mec,notplot=True)

#%%% Combining resampled data

result=pd.DataFrame()
for varname in varnames_fgm:
    result=pd.concat([result,average_data_mms(fgm_vars,varname)],axis=1,verify_integrity=True)
for varname in varnames_mec:
    result=pd.concat([result,average_data_mms(mec_vars,varname)],axis=1,verify_integrity=True)
result.dropna(axis=0,how='any',inplace=True)
result['MLAT']=result[[mission+i+'_mlat' for i in probes]].mean(axis=1).values
# Considering the small spatial spacing of MMS, in order to avoid lengthy logical judgment and calculation, the smallest mlt of four spacecraft is directly used as the mlt of the constellation center
result['MLT']=result[[mission+i+'__mlt' for i in probes]].min(axis=1).values 
for i in probes:
    del result[mission+i+'_mlat']
    del result[mission+i+'__mlt']

#%% Calculating the residual values of FGM data substracting IGRF and converting to SM coordinate system
print('B-IGRF...')
for i in probes:
    probe=mission+i+'_'
    dBx_gsm,dBy_gsm,dBz_gsm=fgm_substract_igrf(result.index,
                                               result[probe+'gsm_Bx'].values,
                                               result[probe+'gsm_By'].values,
                                               result[probe+'gsm_Bz'].values,
                                               result[probe+'gsm_Rx'].values,
                                               result[probe+'gsm_Ry'].values,
                                               result[probe+'gsm_Rz'].values)
    dBx,dBy,dBz=sm_gsm(result.index,dBx_gsm,dBy_gsm,dBz_gsm,-1)
    Rx,Ry,Rz=sm_gsm(result.index,
                    result[probe+'gsm_Rx'].values,
                    result[probe+'gsm_Ry'].values,
                    result[probe+'gsm_Rz'].values,-1)
    result[probe+'sm_dBx']=dBx
    result[probe+'sm_dBy']=dBy
    result[probe+'sm_dBz']=dBz
    result[probe+'sm_Rx']=Rx
    result[probe+'sm_Ry']=Ry
    result[probe+'sm_Rz']=Rz
    del result[probe+'gsm_Bx']
    del result[probe+'gsm_By']
    del result[probe+'gsm_Bz']
    del result[probe+'gsm_Rx']
    del result[probe+'gsm_Ry']
    del result[probe+'gsm_Rz']

#%% Calculating in-situ current density using curlmeter technique and Tetrahedron Geometric Factors
print('Calculating current density...')
label=['x','y','z']
current_density,curlB,divB=curlometer(result[[mission+'1_sm_dB'+i for i in label]].values,
                                      result[[mission+'2_sm_dB'+i for i in label]].values,
                                      result[[mission+'3_sm_dB'+i for i in label]].values,
                                      result[[mission+'4_sm_dB'+i for i in label]].values,
                                      result[[mission+'1_sm_R'+i for i in label]].values,
                                      result[[mission+'2_sm_R'+i for i in label]].values,
                                      result[[mission+'3_sm_R'+i for i in label]].values,
                                      result[[mission+'4_sm_R'+i for i in label]].values)
result['sm_Jx']=np.array(current_density)[:,0]
result['sm_Jy']=np.array(current_density)[:,1]
result['sm_Jz']=np.array(current_density)[:,2]

Size,Elongation,Planarity=size_elongation_planarity(result[[mission+i+'_sm_Rx' for i in probes]].values,
                                                    result[[mission+i+'_sm_Ry' for i in probes]].values,
                                                    result[[mission+i+'_sm_Rz' for i in probes]].values)
result['Char_Size']=Size
result['Elongation']=Elongation
result['Planarity']=Planarity
result['sm_Rx']=result[[mission+i+'_sm_Rx' for i in probes]].mean(axis=1).values
result['sm_Ry']=result[[mission+i+'_sm_Ry' for i in probes]].mean(axis=1).values
result['sm_Rz']=result[[mission+i+'_sm_Rz' for i in probes]].mean(axis=1).values
for i in probes:
    for j in ['x','y','z']:
        del result[mission+i+'_sm_R'+j]
        del result[mission+i+'_sm_dB'+j]

#%% Calculating Jphi
print('Calculating Jphi...')
Jr,Jtheta,Jphi=b_car_sph(result['sm_Rx'].values,
                         result['sm_Ry'].values,
                         result['sm_Rz'].values,
                         np.array(current_density)[:,0],
                         np.array(current_density)[:,1],
                         np.array(current_density)[:,2])
result['sm_Jr']=Jr
result['sm_Jtheta']=Jtheta
result['sm_Jphi']=Jphi


#%% Loading geomagneti indices from OMNI dataset

varname_omni=['AE_INDEX','SYM_H']
omni_vars=omni.data(trange=trange,datatype='1min',level='hro',varnames=varname_omni,notplot=True)
AE=pd.DataFrame({'AE':omni_vars['AE_INDEX']['y']},index=omni_vars['AE_INDEX']['x'])
SYM_H=pd.DataFrame({'SYM_H':omni_vars['SYM_H']['y']},index=omni_vars['SYM_H']['x'])
result=pd.concat([result,AE.resample('1T').mean().shift(1,freq='30S')],axis=1,verify_integrity=True)
result=pd.concat([result,SYM_H.resample('1T').mean().shift(1,freq='30S')],axis=1,verify_integrity=True)
result.dropna(axis=0,how='any',inplace=True)

#%% Calculating L-value
print('Calculating L_value...')
Fx_sm,Fy_sm=footpoint_on_xy_sm(result.index,result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values)
result['L']=np.sqrt(Fx_sm*Fx_sm+Fy_sm*Fy_sm)/RE

#%% Save result to file
print('Saving result...')
result['Mission']=109
fn=file_dir+mission+' '+trange[0]+'-'+trange[1]+' result.cdf'
from spacepy import pycdf
import datetime
cdf=pycdf.CDF(fn,'')
epoch=[]
for t in result.index:
    epoch.append(datetime.datetime.utcfromtimestamp(t.timestamp()))
cdf['Epoch']=epoch
for var in result.columns:
    cdf[var]=result[var]
cdf.close()
