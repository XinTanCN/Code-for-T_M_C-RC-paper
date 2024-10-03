# -*- coding: utf-8 -*-
"""
Created on Wed Nov  1  2023

@author: Tan Xin tanxin@buaa.edu.cn
"""
from pyspedas.themis import fgm,state
import numpy as np
from multi_spacecraft_analysis import fgm_substract_igrf,sp_curlometer,sm_gsm,size_elongation_planarity,footpoint_on_xy_sm,sph_car,phi_mlt
import pyspedas.omni as omni
import pandas as pd
from scipy.interpolate import interp1d as interp
import datetime
import geopack.geopack as gp
import math
RE=6371.2 # Earth radiu
mission='th' # Mission name in the data variable name
file_dir='...Data\\'

#%% Function for resampling tplot data
# ----------------------------------

def average_data_themis(dataset,varname):

    probe=varname[-11:-8]+'_'
    if 'fgs_gsm' in varname:
        name=probe+'gsm_B'
    elif 'pos_gsm' in varname:
        name=probe+'gsm_R'
    else:
        print('Wrong varname! Return NULL!!!')
        return []
    time=[]
    for t1 in dataset[varname]['x']:
        time.append(datetime.datetime.utcfromtimestamp(t1))
    var=pd.DataFrame({name+'x':dataset[varname]['y'][:,0],name+'y':dataset[varname]['y'][:,1],name+'z':dataset[varname]['y'][:,2]},index=time)
    var=var.resample('1T').mean().shift(1,freq='30S') # Resampling FGM data at each one-minute interval and shifting timestampto the middle
    if 'pos_gsm' in varname:
        x= dataset[varname]['x']
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

trange=['2016-04-30','2016-05-01'] # Timespan
probes=['a','d','e']
fgm_varnames=['_fgs_gsm'] # Magnetic field data in GSE coordinate system, units: field nT,position km
state_varnames=['_pos_gsm']

#%%% Loading specific FGM data

varnames_fgm=[]
for i in probes:
    for j in fgm_varnames:
        varnames_fgm.append(mission+i+j)    
fgm_vars=fgm(trange=trange,probe=probes,varnames=varnames_fgm,notplot=True)

varnames_state=[]
for i in probes:
    for j in state_varnames:
        varnames_state.append(mission+i+j)
state_vars=state(trange=trange,probe=probes,varnames=varnames_state,notplot=True)

#%%% Combining resampled data

result=pd.DataFrame()
for varname in varnames_fgm:
    result=pd.concat([result,average_data_themis(fgm_vars,varname)],axis=1,verify_integrity=True)
result.dropna(how='any',inplace=True)

for varname in varnames_state:
    result=pd.concat([result,average_data_themis(state_vars,varname)],axis=1,verify_integrity=True)
result.dropna(axis=0,thresh=10,inplace=True)  

#%% Calculating dipole tilt
print('Calculating dipole tilt angle...')

dip_tilt=[]
t0=datetime.datetime(1970,1,1)
for t1 in result.index:
    ut=(t1-t0).total_seconds()
    dip_tilt.append(gp.recalc(ut))
result['dipole_Tilt']=np.array(dip_tilt)*180/np.pi
#%% Calculating the residual values of FGM data substracting IGRF and converting to SM coordinate system

for i in probes:
    probe=mission+i+'_'
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
J_av_p=sp_curlometer(result[[mission+'a_sm_dB'+i for i in label]].values,
                         result[[mission+'d_sm_dB'+i for i in label]].values,
                         result[[mission+'e_sm_dB'+i for i in label]].values,
                         result[[mission+'a_sm_R'+i for i in label]].values,
                         result[[mission+'d_sm_R'+i for i in label]].values,
                         result[[mission+'e_sm_R'+i for i in label]].values)
result['sm_Jx']=np.array(J_av_p)[:,0]
result['sm_Jy']=np.array(J_av_p)[:,1]
result['sm_Jz']=np.array(J_av_p)[:,2]
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

#%% Calculating J_phi (Base on the assumption that space current is along the circular direction) 
# and the angle between spacecraft formed plane norm and the circular direction
print('Calculating J_phi...')
Angle=[]
J_phi=[]
Js_phi=[]
for i in range(result.shape[0]):
    rx=result['sm_Rx'].iloc[i]
    ry=result['sm_Ry'].iloc[i]
    rz=result['sm_Rz'].iloc[i]
    r,theta,phi=gp.sphcar(rx, ry, rz, -1)
    j_d=np.array(gp.bspcar(theta, phi, 0, 0, 1))
    j_p=np.array([result['sm_Jx'].iloc[i],result['sm_Jy'].iloc[i],result['sm_Jz'].iloc[i]])
    p_n=j_p/np.linalg.norm(j_p)
    Angle.append(np.rad2deg(math.acos(np.dot(j_d, p_n))))
    J_phi.append(np.dot(j_p,p_n)/np.dot(j_d,p_n))
result['sm_Jphi']=J_phi
result['Angle']=Angle

#%% Loading geomagneti indices from OMNI dataset

varname_omni=['AE_INDEX','SYM_H']
omni_vars=omni.data(trange=trange,datatype='1min',level='hro',varnames=varname_omni,notplot=True)
AE=pd.DataFrame({'AE':omni_vars['AE_INDEX']['y']},index=omni_vars['AE_INDEX']['x'])
SYM_H=pd.DataFrame({'SYM_H':omni_vars['SYM_H']['y']},index=omni_vars['SYM_H']['x'])
result=pd.concat([result,AE.resample('1T').mean().shift(1,freq='30S')],axis=1,verify_integrity=True)
result=pd.concat([result,SYM_H.resample('1T').mean().shift(1,freq='30S')],axis=1,verify_integrity=True)
result.dropna(axis=0,thresh=3,inplace=True)

#%% Calculating L-value
print('Calculating L_value...')
Fx_sm,Fy_sm=footpoint_on_xy_sm(result.index,result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values)
Fr,Ftheta,Fphi=sph_car(Fx_sm,Fy_sm,np.zeros(len(Fx_sm)),-1)
result['L']=Fr/RE
result['MLT']=phi_mlt(Fphi,1)
sm_R,sm_Theta,sm_Phi=sph_car(result['sm_Rx'].values,result['sm_Ry'].values,result['sm_Rz'].values,-1)
result['MLAT']=90-sm_Theta/(np.pi)*180

#%% Save result to file
print('Saving result...')
result['Mission']=116
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
