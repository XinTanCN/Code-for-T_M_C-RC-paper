# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 2023

@author: Tan Xin tanxin@buaa.edu.cn
"""
import numpy as np
from scipy.constants import mu_0
from scipy import linalg,interpolate
import datetime
import geopack.geopack as gp
RE=6371.2 # Earth radius 6371.2 km

#%% The curlometer technique (Dunlop et al. 1988)
"""
Input data unit: Field nT, Location km
"""

def curlometer(B1,B2,B3,B4,
               R1,R2,R3,R4):
    """
    The curlometer technique (Dunlop et al. 1988)
    Input data unit: Field nT, Location km
    """
    
    if np.array(B1).shape != np.array(B2).shape or np.array(B1).shape != np.array(B3).shape or np.array(B1).shape != np.array(B4).shape or  np.array(B1).shape != np.array(R1).shape or np.array(B1).shape != np.array(R2).shape or  np.array(B1).shape != np.array(R3).shape or np.array(B1).shape != np.array(R4).shape:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []

    # Inizialisation   

    R12=R2-R1
    R13=R3-R1
    R14=R4-R1
    dB12=B2-B1
    dB13=B3-B1
    dB14=B4-B1

    J_av=[]
    curlB_av=[]
    divB_av=[]
    for i in range(np.array(B1).shape[0]):
        r12=R12[i,:]
        r13=R13[i,:]
        r14=R14[i,:]
        db12=dB12[i,:]
        db13=dB13[i,:]
        db14=dB14[i,:]

        A=np.array([np.cross(r12,r13),np.cross(r13,r14),np.cross(r14,r12)])
        b=np.array([np.dot(db12,r13)-np.dot(db13,r12),np.dot(db13,r14)-np.dot(db14,r13),np.dot(db14,r12)-np.dot(db12,r14)])
        curlb=linalg.solve(A,b)*1e-12 # T/m
        curlB_av.append(curlb)
        J_av.append(curlb/mu_0*1e9) # Output current density unit: nA/m^2

        divb=abs((db12*np.cross(r13,r14)).sum()+(db13*np.cross(r14,r12)).sum()+(db14*np.cross(r12,r13)).sum())/((r12*np.cross(r13,r14)).sum())*1e-12 # T/m^2
        divB_av.append(divb)
    
    return J_av,curlB_av,divB_av  # Output: current density, curlB, divB

#%% singal plane curlmeter technique

def sp_curlometer(B1,B2,B3,
                  R1,R2,R3):
    """
    singal plane curlmeter technique
    Input data unit: Field nT, Location km
    """
    
    if np.array(B1).shape != np.array(B2).shape or np.array(B1).shape != np.array(B3).shape or np.array(B1).shape != np.array(R1).shape or np.array(B1).shape != np.array(R2).shape or np.array(B1).shape != np.array(R3).shape :
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []

    # Inizialisation   
    R12=R2-R1
    R13=R3-R1
    dB12=B2-B1
    dB13=B3-B1
    
    J_av=[]

    for i in range(np.array(B1).shape[0]):
        r12=R12[i,:]
        r13=R13[i,:]
        db12=dB12[i,:]
        db13=dB13[i,:]
        j_avi=(np.dot(db12,r13)-np.dot(db13,r12))/np.linalg.norm(np.cross(r12, r13))/mu_0*1e-3
        p_nori=np.cross(r12,r13)/np.linalg.norm(np.cross(r12, r13))
        J_av.append(j_avi*p_nori)                     
                    
    return J_av

#%% Spatial gradients method for current density calculating for regular/iregular configuation

def sp_spat_grad(B1,B2,B3,
                 R1,R2,R3):
    """
    Spatial gradients method for current density calculating for regular/iregular configuation
    Input data unit: Field nT, Location km
    """
    
    if np.array(B1).shape != np.array(B2).shape or np.array(B1).shape != np.array(B3).shape or np.array(B1).shape != np.array(R1).shape or np.array(B1).shape != np.array(R2).shape or np.array(B1).shape != np.array(R3).shape :
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
 
    J_av=[]
    
    for i in range(np.array(B1).shape[0]):
        R_x=[np.array(R1)[i,0],np.array(R2)[i,0],np.array(R3)[i,0]]
        R_y=[np.array(R1)[i,1],np.array(R2)[i,1],np.array(R3)[i,1]]
        R_z=[np.array(R1)[i,2],np.array(R2)[i,2],np.array(R3)[i,2]]
        R_x=R_x-np.mean(R_x)
        R_y=R_y-np.mean(R_y)
        R_z=R_z-np.mean(R_z)
        R=volumetric_tensor(R_x, R_y, R_z)
        eigenvalues,eigenvectors=np.linalg.eig(R)
        w1,w2,w3=sorted(eigenvalues,reverse=True)
        sorted_id=sorted(range(3), key=lambda k: eigenvalues[k], reverse=True)
        k1=eigenvectors.T[sorted_id[0]]
        k2=eigenvectors.T[sorted_id[1]]
        k3=np.cross(k1, k2)      
        r1=np.array(R1)[i]
        r2=np.array(R2)[i]
        r3=np.array(R3)[i]
        r1n=np.array([np.dot(r1,k1),np.dot(r1, k2),np.dot(r1, k3)])
        r2n=np.array([np.dot(r2,k1),np.dot(r2, k2),np.dot(r2, k3)])
        r3n=np.array([np.dot(r3,k1),np.dot(r3, k2),np.dot(r3, k3)])
        bc=np.array([np.mean([np.array(B1)[i,0],np.array(B2)[i,0],np.array(B3)[i,0]]),
                    np.mean([np.array(B1)[i,1],np.array(B2)[i,1],np.array(B3)[i,1]]),
                    np.mean([np.array(B1)[i,2],np.array(B2)[i,2],np.array(B3)[i,2]])])
        b1=np.array(B1)[i]-bc
        b2=np.array(B2)[i]-bc
        b3=np.array(B3)[i]-bc
        b1n=np.array([np.dot(b1,k1),np.dot(b1, k2),np.dot(b1, k3)])
        b2n=np.array([np.dot(b2,k1),np.dot(b2, k2),np.dot(b2, k3)])
        b3n=np.array([np.dot(b3,k1),np.dot(b3, k2),np.dot(b3, k3)])
        G1B2=(b1n[1]*r1n[0]+b2n[1]*r2n[0]+b3n[1]*r3n[0])/(3*w1)
        G2B1=(b1n[0]*r1n[1]+b2n[0]*r2n[1]+b3n[0]*r3n[1])/(3*w2)
        j_avi=(G1B2-G2B1)/mu_0*1e-3
        J_av.append(j_avi*k3)
        
    return J_av

#%% Volumetric Tensor R

def volumetric_tensor(R_x,R_y,R_z):
    
    rb=[np.mean(R_x),np.mean(R_y),np.mean(R_z)]
    rbt=np.array([rb]).T
    N=len(R_x)
    R=np.zeros([3,3])
    for i in range(N):
        ra=[R_x[i],R_y[i],R_z[i]]
        rat=np.array([ra]).T
        R=R+ra*rat
    R=R/N-rb*rbt
    return R

#%% Tetrahedron Geometric Factors

def size_elongation_planarity(Rx,Ry,Rz):
    """
    Tetrahedron Geometric Factors

    """
    
    if np.array(Rx).shape != np.array(Ry).shape or np.array(Rx).shape != np.array(Rz).shape :
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
    
    Size=[]
    Elongation=[]
    Planarity=[]
    number=np.array(Rx).shape[0]
    
    for i in range(number):
        R_x=np.array(Rx)[i,:]
        R_y=np.array(Ry)[i,:]
        R_z=np.array(Rz)[i,:]
        R=volumetric_tensor(R_x, R_y, R_z)
        eigenvalues,eigenvectors=np.linalg.eig(R)
        a,b,c=sorted(np.sqrt(abs(eigenvalues)),reverse=True)
        Elongation.append(1-(b/a))
        Planarity.append(1-(c/b))
        Size.append(2*a)
        
    return Size,Elongation,Planarity

#%% The residual values of FGM data substracting IGRF

def fgm_substract_igrf(time,Bx_gsm,By_gsm,Bz_gsm,Rx_gsm,Ry_gsm,Rz_gsm):
    """
    The residual values of FGM data substracting IGRF
    Input type/units: time datetime64[ns], Field nT in GSM coordinates, Location km in GSM coordinates 
    """
    
    flag=len(set([len(time),len(Bx_gsm),len(By_gsm),len(Bz_gsm),
                  len(Rx_gsm),len(Ry_gsm),len(Rz_gsm)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
    

    ut=[]
    t0=datetime.datetime(1970,1,1)
    for t1 in time:
        ut.append((t1-t0).total_seconds())
      
    dBx_gsm=[]
    dBy_gsm=[]
    dBz_gsm=[]
    for i in range(len(ut)):
        gp.recalc(ut[i])
        bx_gsm=Bx_gsm[i]
        by_gsm=By_gsm[i]
        bz_gsm=Bz_gsm[i]
        x_gsm=Rx_gsm[i]/RE # unit:RE
        y_gsm=Ry_gsm[i]/RE
        z_gsm=Rz_gsm[i]/RE
        igrf_bx_gsm,igrf_by_gsm,igrf_bz_gsm=gp.igrf_gsm(x_gsm,y_gsm,z_gsm) # unit:nT
        dBx_gsm.append(bx_gsm-igrf_bx_gsm)
        dBy_gsm.append(by_gsm-igrf_by_gsm)
        dBz_gsm.append(bz_gsm-igrf_bz_gsm)
    return dBx_gsm,dBy_gsm,dBz_gsm

#%% GSM coordinates <====> GSE coordinates

def gsm_gse(time,X_in,Y_in,Z_in,j):
    """
    converts geocentric solar magnetospheric (gsm) coords to solar ecliptic (gse) ones or vice versa.
                   j>0                       j<0
    input:  j,xgsm,ygsm,zgsm           j,xgse,ygse,zgse
    output:    xgse,ygse,zgse           xgsm,ygsm,zgsm
    """
    
    flag=len(set([len(time),len(X_in),len(Y_in),len(Z_in)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []

    ut=[]
    t0=datetime.datetime(1970,1,1)
    for t1 in time:
        ut.append((t1-t0).total_seconds())
    X_out=np.zeros(len(ut))
    Y_out=np.zeros(len(ut))
    Z_out=np.zeros(len(ut))
    for i in range(len(ut)):
        gp.recalc(ut[i])
        X_out[i],Y_out[i],Z_out[i]=gp.gsmgse(X_in[i],Y_in[i],Z_in[i],j)
    return X_out,Y_out,Z_out

#%% SM coordinates <====> GSM coordinates

def sm_gsm(time,X_in,Y_in,Z_in,j):
    """
    Converts solar magnetic (sm) to geocentric solar magnetospheric (gsm) coordinates or vice versa.
                   j>0                       j<0
    input:  j,xsm, ysm, zsm           j,xgsm,ygsm,zgsm
    output:    xgsm,ygsm,zgsm           xsm, ysm, zsm
    """    
    
    flag=len(set([len(time),len(X_in),len(Y_in),len(Z_in)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []

    ut=[]
    t0=datetime.datetime(1970,1,1)
    for t1 in time:
        ut.append((t1-t0).total_seconds())
    X_out=np.zeros(len(ut))
    Y_out=np.zeros(len(ut))
    Z_out=np.zeros(len(ut))
    for i in range(len(ut)):
        gp.recalc(ut[i])
        X_out[i],Y_out[i],Z_out[i]=gp.smgsm(X_in[i],Y_in[i],Z_in[i],j)
    return X_out,Y_out,Z_out


#%% Spherical coordinates <====> Cartesian coordinates

def sph_car(P1_in,P2_in,P3_in,j):
    """
    Converts spherical coords into cartesian ones and vice versa (theta and phi in radians).
                  j>0            j<0
    input:   j,r,theta,phi     j,x,y,z
    output:      x,y,z        r,theta,phi

    """
    
    flag=len(set([len(P1_in),len(P2_in),len(P3_in)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
    
    P1_out=np.zeros(len(P1_in))
    P2_out=np.zeros(len(P1_in))
    P3_out=np.zeros(len(P1_in))
    for i in range(len(P1_in)):
        P1_out[i],P2_out[i],P3_out[i]=gp.sphcar(P1_in[i],P2_in[i],P3_in[i],j)
    return P1_out,P2_out,P3_out


#%% Convert Cartesian vector components to spherical ones.
    
def b_car_sph(Rx,Ry,Rz,Bx,By,Bz):
    """
    Calculates spherical field components from those in cartesian system

    :param rx,ry,rz: cartesian components of the position vector
    :param bx,by,bz: cartesian components of the field vector
    :return: br,btheta,bphi. spherical components of the field vector
    """

    flag=len(set([len(Rx),len(Ry),len(Rz),len(Bx),len(By),len(Bz)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
    
    Br=np.zeros(len(Rx))
    Btheta=np.zeros(len(Rx))
    Bphi=np.zeros(len(Rx))
    for i in range(len(Rx)):
        Br[i],Btheta[i],Bphi[i]=gp.bcarsp(Rx[i],Ry[i],Rz[i],Bx[i],By[i],Bz[i])
    return Br,Btheta,Bphi


#%% Trace footpoint on the XY palne of SM coordinates along IGRF

def footpoint_on_xy_sm(time,Rx_sm,Ry_sm,Rz_sm):
    """
    Trace footpoint on the XY palne of SM coordinates along IGRF
    Input type/units: time datetime64[ns], Location km in SM coordinates
    """

    flag=len(set([len(time),len(Rx_sm),len(Ry_sm),len(Rz_sm)]))
    if flag != 1:
        print('The lengths of the input variables are inconsistent. Output NULL!')
        return []
    
    ut=[]
    t0=datetime.datetime(1970,1,1)
    for t1 in time:
        ut.append((t1-t0).total_seconds())
    Fx_sm=np.zeros(len(ut))
    Fy_sm=np.zeros(len(ut))
    for i in range(len(ut)):
        gp.recalc(ut[i])
        rx_gsm,ry_gsm,rz_gsm=gp.smgsm(Rx_sm[i],Ry_sm[i],Rz_sm[i],1)
        fx,fy,fz,lx_gsm,ly_gsm,lz_gsm=gp.trace(rx_gsm/RE, ry_gsm/RE, rz_gsm/RE, np.sign(Rz_sm[i]), rlim=35, r0=1, inname='igrf',exname='igrf', maxloop=1000)
        lx_sm=np.zeros(len(lx_gsm))
        ly_sm=np.zeros(len(lx_gsm))
        lz_sm=np.zeros(len(lx_gsm))
        for j in range(len(lx_gsm)):
            lx_sm[j],ly_sm[j],lz_sm[j]=gp.smgsm(lx_gsm[j],ly_gsm[j],lz_gsm[j],-1)
        if (lz_sm.max()*lz_sm.min()) < 0: # make sure trace line cross the equatarial plane
            funcx=interpolate.interp1d(lz_sm,lx_sm)
            funcy=interpolate.interp1d(lz_sm,ly_sm)
            Fx_sm[i]=funcx(0)*RE # unit:km
            Fy_sm[i]=funcy(0)*RE
        else:
            Fx_sm[i]=np.nan
            Fy_sm[i]=np.nan
    return Fx_sm,Fy_sm
        
#%% Phi in radian(SM sph coordinates) <====> MLT    

def phi_mlt(P_in,j):
    """
    Converts phi to mlt or vice versa.
                  j>0            j<0
    input:        phi            mlt
    output:       mlt            phi
    """
    
    def phimlt(Pin,flag):
        if j> 0:
            if Pin >= np.pi:
                return Pin/(np.pi)*12-12
            else:
                return Pin/(np.pi)*12+12
        else:
            if Pin >= 12:
                return Pin/12*(np.pi)-np.pi
            else:
                return Pin/12*(np.pi)+np.pi
    P_out=np.zeros(len(P_in))
    for i in range(len(P_in)):
        P_out[i]=phimlt(P_in[i],j)
    return P_out
    
#%% Calculate spatial gradient of scalar field data of > 3 spacecraft

def grad_scalar_field(Field,R_x,R_y,R_z):
    '''
    Calculate spatial gradient of scalar field data of > 3 spacecraft

    Parameters
    ----------
    Field : Scalar Field.
    R_x : Position x component.
    R_y : Position y component.
    R_z : Position z component.

    Returns
    -------
        Gradient vector.

    '''
    
    N=len(R_x)
    if N < 4:
        print('Number of spacecraft should lager than 3!')
        return []
      
    temp=np.zeros([3],dtype=float)
    R=np.array([R_x,R_y,R_z]).T
    
    for k in range(3):
        for i in range(N):
            for j in range(N):
                if i==j:
                    continue
                temp[k]=temp[k]+0.5*(Field[i]-Field[j])*(R[i][k]-R[j][k])
    
    grad_scalar=1/N/N*temp@np.linalg.inv(volumetric_tensor(R_x, R_y, R_z))
        
    return grad_scalar

#%% Calculate spatial gradient of vector field data of > 3 spacecraft
def grad_vector_field(F_x,F_y,F_z,R_x,R_y,R_z):
    '''
    Calculate spatial gradient of vector field data of > 3 spacecraft

    Parameters
    ----------
    F_x :Field x component.
    F_y :Field x component.
    F_z :Field x component.
    R_x : Position x component.
    R_y : Position y component.
    R_z : Position z component.

    Returns
    -------
    Gradient tensor.

    '''
    
    N=len(R_x)
    if N < 4:
        print('Number of spacecraft should lager than 3!')
        return []
      
    temp=np.zeros([3,3],dtype=float)
    F=np.array([F_x,F_y,F_z]).T
    R=np.array([R_x,R_y,R_z]).T
    
    
    for k in range(3):
        for l in range(3):
            for i in range(N):
                for j in range(N):
                    if i==j:
                        continue
                    temp[l][k]=temp[l][k]+0.5*(F[i][l]-F[j][l])*(R[i][k]-R[j][k])
    
    grad_vector=1/N/N*temp@np.linalg.inv(volumetric_tensor(R_x, R_y, R_z))
        
    return grad_vector

#%% Compute the parallel and perpendicular components of a spatial vector with respect to another vector
def parallel_perpendicular(in_X,in_Y,in_Z,n_X,n_Y,n_Z):
    '''
    Compute the parallel and perpendicular components of a spatial vector with 
    respect to another vector
    Parameters
    ----------
    in_X :
    in_Y :
    in_Z : 
    n_X :
    n_Y :
    n_Z :

    Returns
    -------
    parallel :
    perpendicular : 

    '''
    
    a=np.array([in_X,in_Y,in_Z])
    b=np.array([n_X,n_Y,n_Z])
    parallel=np.dot(a,b)/np.linalg.norm(b)
    perpendicular=np.sqrt(np.dot(a,a)-np.power(parallel,2))
    
    return parallel,perpendicular