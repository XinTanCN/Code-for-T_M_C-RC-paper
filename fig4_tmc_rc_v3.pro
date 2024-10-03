;Cluster、THEMIS、MMS MLAT tilt vs L (Figure 4)
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig4_tmc_rc_v3
  ;---Load data-------
  fn='Data\Result_20231230_mlat30_ep085_cs1.cdf'
  loadcdf,fn,'Epoch',epoch
  loadcdf,fn,'Jphi',j_phi
  loadcdf,fn,'L',l
  loadcdf,fn,'MLT',mlt
  loadcdf,fn,'MLAT',LAT
  loadcdf,fn,'Tilt',tilt
  loadcdf,fn,'SYM_H',sym_h
  loadcdf,fn,'AE',ae
  loadcdf,fn,'Angle',angle
  loadcdf,fn,'X',x
  loadcdf,fn,'Y',y
  loadcdf,fn,'Z',z
  loadcdf,fn,'E',e
  loadcdf,fn,'P',p
  loadcdf,fn,'Q',q
  loadcdf,fn,'Size',cs
  loadcdf,fn,'Mission',mission

  ;---thresholds------
  substorm_threshold=250.0
  storm_threshold=-30.0
  ;  Q_threshold=0.5
  L_shell_min=4.0
  L_shell_max=8.0
  data_number_threshold=10
  dir='Figures\'
  if file_test(dir) eq 0 then file_mkdir,dir

  pos=where(l ge L_shell_min and l le L_shell_max)
  epoch=epoch[pos]
  j_phi=j_phi[pos]
  l=l[pos]
  mlt=mlt[pos]
  lat=lat[pos]
  tilt=tilt[pos]
  sym_h=sym_h[pos]
  ae=ae[pos]
  angle=angle[pos]
  x=x[pos]
  y=y[pos]
  z=z[pos]
  e=e[pos]
  p=p[pos]
  q=q[pos]
  cs=cs[pos]
  mission=mission[pos]

  ;* 1/(cos(lat)^3)
  j_phi=j_phi/((cos(lat*!dtor))^3)

  up=50.0
  bottom=50.0
  left=90.0
  right=10.0
  width=400.0
  hight=125.0
  midh=70.0
  midw=100.0
  color=['deep_sky_blue','firebrick'];quiet,storm

  ;----Plot-----
  n=5;Number of panels in the vertical direction
  m=2;Number of panels in the horizontal direction
  dimw=left+right+m*width+(m-1)*midw
  dimh=up+2*n*hight+bottom+(n-1)*midh
  flag=[[1,2],[3,4]]
  w=window(dimension=[dimw,dimh],window_title='Figure 2')
  panel=['(a)','(b)','(c)','(d)','(e)']
  side=['','Dawn','Noon','Dusk','MidN']
  mlt_range=[[0,24],[3,9],[9,15],[15,21],[21,3]]
  ;  t_y=text((width)/dimw,(dimh-35)/dimh,'$X: L (R_E)  Y: J_{\phi} (nA/m^2)$',font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
  t_y=text((width-50)/dimw,(dimh-35)/dimh,'$X: L (R_E)  Y: MLAT     Tilt      (\circ)$',font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
  s_m=symbol(0.54,(dimh-27)/dimh,'+',sym_size=0.75,sym_thick=3)
  s_t=symbol(0.595,(dimh-27)/dimh,'o',sym_size=0.75,sym_thick=3)

  t_quiet=text(0.66,(dimh-35)/dimh,'$SYM_H \geq -30 nT$',color[0],font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
  t_storm=text(0.82,(dimh-35)/dimh,'$SYM_H < -30 nT$',color[1],font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
  t_x1=text(0.26,(bottom-40)/dimh,'$L   (R_E)$',font_size=12,font_name='Times', font_style=0)
  t_x1=text(0.76,(bottom-40)/dimh,'$L   (R_E)$',font_size=12,font_name='Times', font_style=0)
  for i=0,n-1 do begin
    x_t=left/dimw
    y_t=(dimh-up-i*(midh+2*hight)+15.0)/dimh
    txt=panel[i]+' '+side[i]+' '+string(mlt_range[0,i],format='(i2.2)')+':00 - '+string(mlt_range[1,i],format='(i2.2)')+':00 MLT'
    t_a=text(x_t,y_t,txt,'k',font_size=14,font_name='Times', font_style=0)
    for j=0,m-1 do begin
      for k=0,1 do begin
        x0=(left+j*(width+midw))/dimw
        y0=(dimh-up-i*(midh+2*hight)-(k+1)*hight)/dimh
        position=[x0,y0,x0+width/dimw,y0+hight/dimh]
        ;        fig2_ctm_rc_panel_v2,position,flag[j,k],j_phi,l,sym_h,mission,mlt_range[*,i],mlt,color
;        fig3_ctm_rc_panel_v2,position,flag[j,k],j_phi,l,sym_h,mission,mlt_range[*,i],mlt,color,lat,tilt
;        fig3_ctm_rc_panel_v2_test,position,flag[j,k],j_phi,l,sym_h,mission,mlt_range[*,i],mlt,color,lat,tilt,epoch
        if (j eq 0) and (k eq 0) then begin
          fig4_tmc_rc_panel_v3_0,position,flag[j,k],j_phi,l,sym_h,mission,mlt_range[*,i],mlt,color,lat,tilt
        endif else begin
          fig4_tmc_rc_panel_v3_1,position,flag[j,k],j_phi,l,sym_h,mission,mlt_range[*,i],mlt,color,lat,tilt
        endelse
      endfor
    endfor
  endfor
;  fn1=dir+'Figure 4_n.png'
;  w.save,fn1,RESOLUTION=600,border=0,/overwrite
;  w.close


;  stop
end