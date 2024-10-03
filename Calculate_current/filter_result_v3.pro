;Filter the calculated results
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro filter_result_v3
  
  fn='...tcm_rc_result.cdf'
;  My data file is here: https://zenodo.org/records/13884268
  loadcdf,fn,'Epoch',epoch
  loadcdf,fn,'Jphi',jphi
  loadcdf,fn,'L',l
  loadcdf,fn,'MLT',mlt
  loadcdf,fn,'MLAT',mlat
  loadcdf,fn,'Tilt',tilt
  loadcdf,fn,'SYM_H',symh
  loadcdf,fn,'AE',ae
  loadcdf,fn,'Angle',angle
  loadcdf,fn,'X',x
  loadcdf,fn,'Y',y
  loadcdf,fn,'Z',z
  loadcdf,fn,'Size',cs
  loadcdf,fn,'E',e
  loadcdf,fn,'P',p
  loadcdf,fn,'Q',q
  loadcdf,fn,'Mission',mission
  
;  filter
  pos=where((abs(mlat) le 30) and (e lt 0.85) and ((p lt 0.85) or ((mission eq 116) and (90-abs(90-angle) lt 60))) and (cs lt 1) and (l ge 2) and (l le 9))
  epoch=epoch[pos]
  jphi=jphi[pos]
  l=l[pos]
  mlt=mlt[pos]
  mlat=mlat[pos]
  tilt=tilt[pos]
  symh=symh[pos]
  ae=ae[pos]
  angle=angle[pos]
  x=x[pos]
  y=y[pos]
  z=z[pos]
  cs=cs[pos]
  e=e[pos]
  p=p[pos]
  q=q[pos]
  mission=mission[pos]
  
  ;-------------------------------------
  fn='Data\Result_20231230_mlat30_ep085_cs1.cdf'
  id=cdf_create(fn,/clobber)
  epoch_id=cdf_varcreate(id,'Epoch',[1],/cdf_epoch,/zvar,/rec_vary,dimensions=[])
  Jphi_id=cdf_varcreate(id,'Jphi',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  L_id=cdf_varcreate(id,'L',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  MLT_id=cdf_varcreate(id,'MLT',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  MLAT_id=cdf_varcreate(id,'MLAT',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  tilt_id=cdf_varcreate(id,'Tilt',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  SYMH_id=cdf_varcreate(id,'SYM_H',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  AE_id=cdf_varcreate(id,'AE',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  Angle_id=cdf_varcreate(id,'Angle',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  X_id=cdf_varcreate(id,'X',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  Y_id=cdf_varcreate(id,'Y',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  Z_id=cdf_varcreate(id,'Z',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  CS_id=cdf_varcreate(id,'Size',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  E_id=cdf_varcreate(id,'E',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  P_id=cdf_varcreate(id,'P',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  Q_id=cdf_varcreate(id,'Q',[1],/cdf_double,/zvar,/rec_vary,dimensions=[])
  Mission_id=cdf_varcreate(id,'Mission',[1],/cdf_uint1,/zvar,/rec_vary,dimensions=[])
  ;------------------------------------
  cdf_varput,id,'Epoch',epoch,/zvar
  cdf_varput,id,'Jphi',jphi,/zvar
  cdf_varput,id,'L',l,/zvar
  cdf_varput,id,'MLT',mlt,/zvar
  cdf_varput,id,'MLAT',mlat,/zvar
  cdf_varput,id,'Tilt',tilt,/zvar
  cdf_varput,id,'SYM_H',symh,/zvar
  cdf_varput,id,'AE',ae,/zvar
  cdf_varput,id,'Angle',angle,/zvar
  cdf_varput,id,'X',x,/zvar
  cdf_varput,id,'Y',y,/zvar
  cdf_varput,id,'Z',z,/zvar
  cdf_varput,id,'Size',cs,/zvar
  cdf_varput,id,'E',e,/zvar
  cdf_varput,id,'P',p,/zvar
  cdf_varput,id,'Q',q,/zvar
  cdf_varput,id,'Mission',mission,/zvar
  ;------------------------------------
  cdf_close,id
;  stop
  
end
