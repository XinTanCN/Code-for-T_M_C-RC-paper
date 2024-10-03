# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 2023

@author: Tan Xin tanxin@buaa.edu.cn
"""

# from pyspedas.cluster import pmp
from pyspedas.cluster import fgm
import numpy as np
from multi_spacecraft_analysis import fgm_substract_igrf,gsm_gse,sm_gsm,curlometer,size_elongation_planarity,b_car_sph,footpoint_on_xy_sm,sph_car,phi_mlt
import pyspedas.omni as omni
import pandas as pd
from scipy.interpolate import interp1d as interp
import datetime
import geopack.geopack as gp
RE=6371.2 # Earth radiu
mission='C' # Mission name in the data variable name
file_dir='...Data\\'

#%% Function for resampling tplot data
# ----------------------------------

def average_data_cluster(dataset,varname):

    probe=varname[-14:-12]+'_'
    if 'B_vec_xyz_gse' in varname:
        name=probe+'gse_B'
    elif 'sc_pos_xyz_gse' in varname:
        name=probe+'gse_R'
    elif 'L_value__C' in varname:
        probe=varname[-9:-7]
        name=probe+'_L'
        var=pd.DataFrame({name:dataset[varname]['y']},index=dataset[varname]['x'])
        var.replace([-1,-1e31],np.nan,inplace=True)
        var=var.resample('1T').ffill().shift(1,freq='30S')
        return var
    else:
        print('Wrong varname! Return NULL!!!')
        return []
        
    var=pd.DataFrame({name+'x':dataset[varname]['y'][:,0],name+'y':dataset[varname]['y'][:,1],name+'z':dataset[varname]['y'][:,2]},index=dataset[varname]['x'])
    var=var.resample('1T').mean().shift(1,freq='30S') # Resampling FGM data at each one-minute interval and shifting timestampto the middle
    if 'sc_pos_xyz_gse' in varname:
        x=[]
        for time in dataset[varname]['x']:
            x.append(time.timestamp())
        yx=dataset[varname]['y'][:,0]
        yy=dataset[varname]['y'][:,1]
        yz=dataset[varname]['y'][:,2]
        funx=interp(x, yx,fill_value='extrapolate')
        funy=interp(x, yy,fill_value='extrapolate')
        funz=interp(x, yz,fill_value='extrapolate')
        xnew=[]
        for time in var.index:
            xnew.append(time.timestamp())
        var[name+'x']==funx(xnew)
        var[name+'y']==funy(xnew)
        var[name+'z']==funz(xnew)
        
    return var

#%% Resampling FGM & PMP data within a given time range at one-minute intervals

trange=['2002-03-18','2002-06-14'] # Timespan
probes=['1','2','3','4']
fgm_varnames=['B_vec_xyz_gse','sc_pos_xyz_gse'] # Magnetic field data in GSE coordinate system, units: field nT,position km
# pmp_varnames=['L_value__C']
#%%% Loading specific FGM data

varnames_fgm=[]
for i in probes:
    for j in fgm_varnames:
        varnames_fgm.append(j+'__C'+i+'_CP_FGM_SPIN')    
fgm_vars=fgm(trange=trange,probe=probes,datatype='cp',varnames=varnames_fgm,notplot=True)

# from pyspedas.cluster import pmp
# varnames_pmp=[]
# for i in probes:
#     for j in pmp_varnames:
#         varnames_pmp.append(j+i+'_JP_PMP')
# pmp_vars=pmp(trange=trange,probe=probes,varnames=varnames_pmp,notplot=True)


#%%% Combining resampled data

result=pd.DataFrame()
for varname in varnames_fgm:
    result=pd.concat([result,average_data_cluster(fgm_vars,varname)],axis=1,verify_integrity=True)
result.dropna(how='any',inplace=True)

# for varname in varnames_pmp:
#     result=pd.concat([result,average_data_cluster(pmp_vars,varname)],axis=1,verify_integrity=True)
# result.dropna(axis=0,thresh=5,inplace=True)   
 
#%% Calculating dipole tilt
print('Calculating dipole tilt angle...')

dip_tilt=[]
t0=datetime.datetime(1970,1,1)
for t1 in result.index:
    ut=(t1-t0).total_seconds()
    dip_tilt.append(gp.recalc(ut))
result['dipole_Tilt']=np.array(dip_tilt)*180/np.pi

#%% Calculating the residual values of FGM data substracting IGRF and converting to SM coordinate system
print('B-IGRF...')
for i in probes:
    probe=mission+i+'_'
    varnames=['B','R']
    for j in varnames:
        x_gsm,y_gsm,z_gsm=gsm_gse(result.index,result[probe+'gse_'+j+'x'].values,result[probe+'gse_'+j+'y'].values,result[probe+'gse_'+j+'z'].values,-1)
        result[probe+'gsm_'+j+'x']=x_gsm
        result[probe+'gsm_'+j+'y']=y_gsm
        result[probe+'gsm_'+j+'z']=z_gsm
        del result[probe+'gse_'+j+'x']
        del result[probe+'gse_'+j+'y']
        del result[probe+'gse_'+j+'z']
    dBx_gsm,dBy_gsm,dBz_gsm=fgm_substract_igrf(result.index,result[probe+'gsm_Bx'].values,result[probe+'gsm_By'].values,result[probe+'gsm_Bz'].values,
                                               result[probe+'gsm_Rx'].values,result[probe+'gsm_Ry'].values,result[probe+'gsm_Rz'].values)
    dBx,dBy,dBz=sm_gsm(result.index,dBx_gsm,dBy_gsm,dBz_gsm,-1)
    Rx,Ry,Rz=sm_gsm(result.index,result[probe+'gsm_Rx'].values,result[probe+'gsm_Ry'].values,result[probe+'gsm_Rz'].values,-1)
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
Jr,Jtheta,Jphi=b_car_sph(result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values,
                         np.array(current_density)[:,0],np.array(current_density)[:,1],np.array(current_density)[:,2])
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
result.dropna(axis=0,thresh=3,inplace=True)

#%% Calculating L-value Plan A

print('Calculating L_value...')
Fx_sm,Fy_sm=footpoint_on_xy_sm(result.index,result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values)
Fr,Ftheta,Fphi=sph_car(Fx_sm,Fy_sm,np.zeros(len(Fx_sm)),-1)
result['L']=Fr/RE
result['MLT']=phi_mlt(Fphi,1)
sm_R,sm_Theta,sm_Phi=sph_car(result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values,-1)
result['MLAT']=90-sm_Theta/(np.pi)*180

#%% Calculating L-value Plan B

# result['L_pmp']=result[[mission+i+'_L' for i in probes]].mean(axis=1).values
# for i in probes:
#     del result[mission+i+'_L']

#%% Save result to file
print('Saving result...')
result['Mission']=99
fn=file_dir+mission+' '+trange[0]+'-'+trange[1]+' result.cdf'
from spacepy import pycdf
cdf=pycdf.CDF(fn,'')
epoch=[]
for t in result.index:
    epoch.append(datetime.datetime.utcfromtimestamp(t.timestamp()))
cdf['Epoch']=epoch
for var in result.columns:
    cdf[var]=result[var]
cdf.close()