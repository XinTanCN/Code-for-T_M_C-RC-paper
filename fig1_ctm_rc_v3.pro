;Cluster、THEMIS、MMS Orbit (Figure 1)
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig1_ctm_rc_v3
  fn='Data\Result_20231122.cdf'
  loadcdf,fn,'Epoch',epoch
  loadcdf,fn,'MLAT',mlat
  loadcdf,fn,'Tilt',tilt
  loadcdf,fn,'Mission',mission
  loadcdf,fn,'MLT',mlt
  mlt_to_phi,mlt=mlt,phi=phi
  loadcdf,fn,'L',l
  re=6371.2
  x=l*cos(phi)*re
  y=l*sin(phi)*re
  
  pos=where(l ge 4)
  epoch=epoch[pos]
  x=x[pos]
  y=y[pos]
  tilt=tilt[pos]
  mlat=mlat[pos]
  mission=mission[pos]
  
  up=10.0
  bottom=120.0
  left=100.0
  right=10.0
  width=400.0
  hight=400.0
  color=['deep_sky_blue','firebrick','navy']
  ;----Plotting-----
  n=3;Number of vertical panels
  w=window(dimension=[left+right+width,up+n*hight+bottom],window_title='Figure 1')
  for i=0,2 do begin
    position=[left/(left+right+width),(bottom+(n-i-1)*hight)/(up+n*hight+bottom),$
      (left+width)/(left+right+width),(bottom+(n-i)*hight)/(up+n*hight+bottom)]
    fig1_ctm_rc_panel_v3,position,epoch,x,y,tilt,mlat,mission,i,n,color
  endfor
  x1=0.05
  y1=0.01
  y2=0.035
  font_size=12
  sym_size=2.5
  t=text(x1,y1,'$Tilt Angle$','k',font_size=font_size,font_name='Times',font_style=0)
  t=text(x1+0.2,y1,'$[min,-11.5\deg]$',color[0],font_size=font_size,font_name='Times',font_style=0)
  t=text(x1+0.45,y1,'$(-11.5\deg,11.5\deg)$',color[1],font_size=font_size,font_name='Times',font_style=0)
  t=text(x1+0.7,y1,'$[11.5\deg,max]$',color[2],font_size=font_size+1,font_name='Times',font_style=0)
  t=text(x1,y2,'$MLAT          [-30\deg,-10\deg]        (-10\deg,10\deg)         [10\deg,30\deg]$','k',$
    font_size=font_size,font_name='Times',font_style=0)
  s=symbol(x1+0.19,y2+0.005,'td',sym_size=sym_size)
  s=symbol(x1+0.465,y2+0.005,'x',sym_size=sym_size)
  s=symbol(x1+0.74,y2+0.002,'tu',sym_size=sym_size,/sym_filled)
  fn='Figures\Figure1_l.png'
;  w.save,fn,RESOLUTION=600,border=0,/overwrite
;  w.close
;  stop
end