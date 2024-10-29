;panels in Fig 5
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024


pro fig5_tmc_rc_panel_v3,fn=fn,mlt_range,symh_range,L_range,symbol,sym_size,position,font_size,par,id,n,color
  
  ;------载入数据-------
  if undefined(fn) then begin
    fn='Data\Result_20241029_mlat30_ep085_cs1_48.cdf'
  endif
  loadcdf,fn,'Epoch',epoch
  cdf_epoch,epoch,year,month,day,/break
  days=julday(month,day,year)-julday(1,1,year)+1
  loadcdf,fn,'Jphi',jphi
  loadcdf,fn,'L',l
  loadcdf,fn,'MLT',mlt
  loadcdf,fn,'MLAT',mlat
  loadcdf,fn,'Tilt',tilt
  loadcdf,fn,'SYM_H',symh
  loadcdf,fn,'AE',ae
  loadcdf,fn,'Angle',angle
  loadcdf,fn,'Size',cs
  loadcdf,fn,'E',e
  loadcdf,fn,'P',p
  loadcdf,fn,'Q',q
  loadcdf,fn,'Mission',mission
  ;------------------
  medianflag=0
  linestyle=''
  thick=0.5
  p_a=plot(/current,l,jphi,position=position,xrange=L_range,xtickvalue=indgen(L_range[1]-L_range[0]+1)+L_range[0],xminor=9,/nodata)
  case par of
    'MLAT':begin
      ydata='MLAT (\deg)'
      y=mlat
      yrange=[-35,35]
      ytickvalue=indgen(5)*10-20
      yminor=1
      l_0=polyline(L_range,[-10,-10],/data,target=p_a,'gray', linestyle='--')
      l_0=polyline(L_range,[10,10],/data,target=p_a,'gray', linestyle='--')
    end
    'TILT':begin
      ydata='  Tilt (\deg)'
      y=tilt
      yrange=[-35,35]
      ytickvalue=indgen(7)*10-30
      yminor=1
      l_0=polyline(L_range,[-11.5,-11.5],/data,target=p_a,'gray', linestyle='--')
      l_0=polyline(L_range,[11.5,11.5],/data,target=p_a,'gray', linestyle='--')
    end
    'SYMH':begin
      ydata='SYM_H (nT)'
      y=symh
      yrange=[]
      ytickvalue=[]
      yminor=1
    end
    'AE':begin
      ydata='  AE (nT)'
      y=ae
      yrange=[]
      ytickvalue=[]
      yminor=1
    end
    'ANGLE':begin
      ydata='     \alpha (\deg)'
      y=angle
      yrange=[0,60]
      ytickvalue=indgen(5)*10+10
      yminor=1
    end
    'Jphi':begin
      ydata='J_{\phi} (nA/m^2)'
      y=Jphi
      yrange=[]
      ytickvalue=[]
      yminor=1
    end
    'J_MLT':begin
      ydata=strtrim(string(mlt_range[0],format='(i2.2)'),2)+':00-'+strtrim(string(mlt_range[1],format='(i2.2)'),2)+':00
      y=Jphi
      yrange=[]
      ytickvalue=[]
      yminor=1
    end
    'SIZE':begin
      ydata='Size (R_E)'
      y=cs
      yrange=[0,1]
      ytickvalue=[0.2,0.4,0.6,0.8]
      yminor=1
    end
    'E':begin
      ydata='Elongation'
      y=e
      yrange=[0,1]
      ytickvalue=[]
      yminor=1
    end
    'P':begin
      ydata='Planarity'
      y=p
      yrange=[0,1]
      ytickvalue=[]
      yminor=1
    end
    'Q':begin
      ydata='     Q'
      y=q
      yrange=[0,10]
      ytickvalue=[]
      yminor=1
    end
    'Median':begin
      ydata='J_{\phi   Median}'
      y=jphi
      yrange=[]
      ytickvalue=[]
      yminor=1
      medianflag=1
    end
    'DOY':begin
      ydata='Day of Year'
      y=days
      yrange=[1,365]
      ytickvalue=[100,200,300]
      yminor=4
      l_0=polyline(L_range,[79,79],/data,target=p_a,'gray', linestyle='--')
      l_0=polyline(L_range,[171,171],/data,target=p_a,'gray', linestyle='--')
      l_0=polyline(L_range,[263,263],/data,target=p_a,'gray', linestyle='--')
      l_0=polyline(L_range,[355,355],/data,target=p_a,'gray', linestyle='--')
    end
    else: begin
;      stop
    end
  endcase
;  color_scale=Jphi
  if mlt_range[0] le mlt_range[1] then begin
    pos=where(mlt gt mlt_range[0] and mlt lt mlt_range[1] and symh ge min(symh_range) and symh le max(symh_range) and ~finite(y, /nan),k)
  endif else begin
    pos=where(mlt gt mlt_range[0] or mlt lt mlt_range[1] and symh ge min(symh_range) and symh le max(symh_range) and ~finite(y, /nan),k)
  endelse
  if k eq 0 then begin
    return
  endif
  x=l[pos]
  mission=mission[pos]
  y=y[pos]
  pos=where(x ge L_range[0] and x le L_range[1])
  x=x[pos]
  mission=mission[pos]
  y=y[pos]
;  color_scale=color_scale[pos]
;  pos=where(color_scale lt -35)
;  color_scale[pos]=-35
;  pos=where(color_scale gt 35)
;  color_scale[pos]=35
;  ct = COLORTABLE(70)
;  color_scale=(color_scale+35)/70.1*255.0
  ;------绘图参数-------
  
  l_0=polyline(L_range,[0,0],/data,target=p_a,'gray')
  panel=['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
  ;----MMS----
  pos=where(mission eq 109,k)
  if k gt 0 then begin
    x_p=x[pos]
    y_p=y[pos]
    if medianflag then begin
      cal_median_v3,x_p,y_p,L_range
      p_b=plot(/current,/overplot,x_p,y_p,color[2],thick=thick,linestyle='-',symbol=symbol[2], sym_size=sym_size*5)
    endif
    p_b=plot(/current,/overplot,x_p,y_p,color[2],thick=thick,linestyle=linestyle,symbol=symbol[2], sym_size=sym_size);,$
      ;vert_colors=color_scale[pos],RGB_TABLE=CT)
  endif
  ;----Cluster----
  pos=where(mission eq 99,k)
  if k gt 0 then begin
    x_p=x[pos]
    y_p=y[pos]
    if medianflag then begin
      cal_median_v3,x_p,y_p,L_range
      p_b=plot(/current,/overplot,x_p,y_p,color[0],thick=thick,linestyle='-',symbol=symbol[0], sym_size=sym_size*5)
    endif
    p_b=plot(/current,/overplot,x_p,y_p,color[0],thick=thick,linestyle=linestyle,symbol=symbol[0], sym_size=sym_size);,$
    ;vert_colors=color_scale[pos],RGB_TABLE=CT)
  endif
  ;----THEMIS----
  pos=where(mission eq 116,k)
  if k gt 0 then begin
    x_p=x[pos]
    y_p=y[pos]
    if medianflag then begin
      cal_median_v3,x_p,y_p,L_range
      p_b=plot(/current,/overplot,x_p,y_p,color[1],thick=thick,linestyle='-',symbol=symbol[1], sym_size=sym_size*5)
    endif
    p_b=plot(/current,/overplot,x_p,y_p,color[1],thick=thick,linestyle=linestyle,symbol=symbol[1], sym_size=sym_size);,$
    ;vert_colors=color_scale[pos],RGB_TABLE=CT)
  endif
  
  p_b.ytickfont_name='Times'
  p_b.xtickfont_name='Times'
  p_b.xtickfont_size=font_size
  p_b.ytickfont_size=font_size
  p_b.yrange=yrange
  p_b.ytickvalue=ytickvalue
  p_b.yminor=yminor
  if id ne n-1 then begin
    p_b.xtickformat='(a1)'
  endif else begin
    p_b.xtitle='$L (R_E)$'
  endelse
  t=text(position[0]+0.02,position[1]+(position[3]-position[1])*0.8,'('+panel[id]+')',font_size=font_size,font_name='Times',font_style=1)
  t=text(0.035,position[1]+(position[3]-position[1])*0.15,'$'+ydata+'$',font_size=font_size,font_name='Times',orientation=90,font_style=1)
end

pro cal_median_v3,x,y,L_range
  x_in=x
  y_in=y
  step=0.2
  n=floor((L_range[1]-L_range[0])/step)
  x_out=dblarr(n)
  y_out=dblarr(n)
  for i=0,n-1 do begin
    xmin=i*step+L_range[0]
    xmax=xmin+step
    pos=where(x_in gt xmin and x_in le xmax,k)
    if k ne 0 then begin
      x_out[i]=xmin+0.5*step
      y_out[i]=median(y_in[pos])
    endif
  endfor
  pos=where(x_out ne 0)
  x=x_out[pos]
  y=y_out[pos]
end