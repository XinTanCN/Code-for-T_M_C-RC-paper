;Added the display of absent data 2024/06/19

pro fig6_tmc_rc_panel_v3,position,mission,activity,RGB_TABLE,L_range
  ;  mission='themis'
  ;  activity='quiet'
  ;  position=[0,0,1,1]
  ;  RGB_TABLE=72
  ;  L_range=[2,8]

  case strupcase(mission) of
    'MMS':begin
      mission_mark=109
      ;      L_range=[2,8]
    end
    'THEMIS':begin
      mission_mark=116
      ;      L_range=[2,8]
    end
    'CLUSTER':begin
      mission_mark=99
      ;      L_range=[2,8]
    end
    else:begin
      stop
    end
  endcase

  fn='Data\Result_20231230_mlat30_ep085_cs1.cdf'
  loadcdf,fn,'Jphi',jphi
  loadcdf,fn,'L',l
  loadcdf,fn,'MLT',mlt
  loadcdf,fn,'SYM_H',symh
  loadcdf,fn,'Mission',m
  loadcdf,fn,'MLAT',LAT
  pos=where(m eq mission_mark and l ge L_range[0] and l le L_range[1])
  jphi=jphi[pos]
  l=l[pos]
  mlt=mlt[pos]
  symh=symh[pos]
  lat=lat[pos]

  ;* 1/(cos(lat)^3)
  jphi=jphi/((cos(lat*!dtor))^3)

  case strupcase(activity) of
    'QUIET':begin
      pos=where(symh gt -30,k)
      if k eq 0 then stop
      jphi=jphi[pos]
      l=l[pos]
      mlt=mlt[pos]
    end
    'STORM':begin
      pos=where(symh le -30,k)
      if k eq 0 then stop
      jphi=jphi[pos]
      l=l[pos]
      mlt=mlt[pos]
    end
    else:begin
      stop
    end
  endcase

  mlt_step=1.0
  l_step=0.2
  mlt_num=24.0/mlt_step
  l_num=(L_range[1]-L_range[0])/l_step

  jphi_median=dblarr(mlt_num,l_num)
  mlt_median=dblarr(mlt_num,l_num)
  l_median=dblarr(mlt_num,l_num)

  for i=0,mlt_num-1 do begin
    mlt_min=i*mlt_step
    mlt_max=mlt_min+mlt_step
    for j=0,l_num-1 do begin
      l_min=j*l_step+L_range[0]
      l_max=l_min+l_step
      pos=where(mlt ge mlt_min and mlt lt mlt_max and l ge l_min and l lt l_max,k)
      mlt_median[i,j]=mlt_min
      l_median[i,j]=l_min
      if k ne 0 then begin
        jphi_median[i,j]=median(jphi[pos])
      endif
    endfor
  endfor

  pos=where(l_median ne 0,data_num)
  if data_num eq 0 then stop
  jphi_plot=jphi_median[pos]
  mlt_plot=mlt_median[pos]*!DPI/12.0
  l_plot=l_median[pos]

  color_scale=jphi_plot
  pos=where(color_scale gt 20,k)
  if k ne 0 then begin
    color_scale[pos]=20.0
  endif
  pos=where(color_scale lt -20,k)
  if k ne 0 then begin
    color_scale[pos]=-20.0
  endif

  res_num=5
  x=(findgen(201)-100)/100
  y=sqrt(1-x*x)
  p=plot(x,y,position=position,/current,xrange=[-(L_range[1]+0.5),(L_range[1]+0.5)],yrange=[-(L_range[1]+0.5),(L_range[1]+0.5)],/ASPECT_RATIO,AXIS_STYLE=4)
  P=plot(x,-y,/current,/overplot)
  P=barplot(x[100:*],y[100:*],/current,/overplot)
  P=barplot(x[100:*],-y[100:*],/current,/overplot)
  for i=0,data_num-1 do begin
    for j=0,res_num-1 do begin
      if color_scale[i] ne 0 then begin
        p=polarplot(dblarr(res_num+1)+l_plot[i]+(j+0.5)*l_step/res_num,dindgen(res_num+1)*mlt_step/res_num*!DPI/12.0+mlt_plot[i],/current,/overplot,thick=1,$
          RGB_TABLE=RGB_TABLE,vert_colors=(color_scale[i]+20.05)/40.1*255.0)  
      endif else begin
        p=polarplot(dblarr(res_num+1)+l_plot[i]+(j+0.5)*l_step/res_num,dindgen(res_num+1)*mlt_step/res_num*!DPI/12.0+mlt_plot[i],/current,/overplot,thick=1,$
          color='gray')
      endelse
      
    endfor
    ;    stop
  endfor
  ;  stop
  for i=0,23 do begin
    P=polarplot([L_range[0],L_range[1]],dblarr(2)+i*!DPI/12,/current,/overplot,LINESTYLE='-.')
  endfor

  x=[x,x]
  y=[y,-y]

  for i=1,4 do begin
    P=plot(x*2*i,y*2*i,/current,/overplot)
  endfor

  for i=1,3 do begin
    P=plot(x*(2*i+1),y*(2*i+1),/current,/overplot,LINESTYLE=':')
  endfor

  P=plot(dblarr(n_elements(x)),y*L_range[1],/current,/overplot)
  ;  stop
end