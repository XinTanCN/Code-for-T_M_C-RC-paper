

pro fig4_ctm_rc_panel_v3_1,position,flag,jphi,l,symh0,mission,mlt_range,mlt0,color,lat0,tilt0
  L_shell_min=4
  L_shell_max=8
  L_range=[L_shell_min,L_shell_max]
  data_number_threshold=30
  ;---Plot parameter---
  text_size_a=10
  text_size_b=12
  text_size_c=14
  text_size_d=16
  errorbar_capsize=0
  errorbar_thick=0
  sym_size=0.5
  sym_thick=2
  font_style_a=0
  font_style_b=1
  font_style_c=2
  symbol='D'


  x=dindgen(21)*0.2+L_range[0]
  y=dblarr(21)
  case flag of
    1:begin
      ytitle='3 MISSIONS'
      pos=where(mission ne 0)
      xtickformat='(a1)'
      xtitle=''
    end
    3:begin
      ytitle='THEMIS'
      pos=where(mission eq 116)
      xtickformat=''
      xtitle=''
    end
    2:begin
      ytitle='  MMS  '
      pos=where(mission eq 109)
      xtickformat='(a1)'
      xtitle=''
    end
    4:begin
      ytitle='CLUSTER'
      pos=where(mission eq 99)
      xtickformat=''
      xtitle=''
    end
  endcase
  p_a=plot(/current,x,y,'gray',position=position,xrange=L_range,xtickvalue=indgen(5)+4,$
    xminor=9,yrange=[-35,35],ytickvalue=indgen(7)*10-30,yminor=1)
  y=jphi[pos]
  x=l[pos]
  symh=symh0[pos]
  mlt=mlt0[pos]
  lat=lat0[pos]
  tilt=tilt0[pos]
  if mlt_range[0] le mlt_range[1] then begin
    pos_quiet=where(mlt gt mlt_range[0] and mlt lt mlt_range[1] and symh ge -30)
    pos_storm=where(mlt gt mlt_range[0] and mlt lt mlt_range[1] and symh le -30)
  endif else begin
    pos_quiet=where((mlt gt mlt_range[0] or mlt lt mlt_range[1]) and symh ge -30)
    pos_storm=where((mlt gt mlt_range[0] or mlt lt mlt_range[1]) and symh le -30)
  endelse
  y_quiet=y[pos_quiet]
  y_storm=y[pos_storm]
  x_quiet=x[pos_quiet]
  x_storm=x[pos_storm]
  lat_quiet=lat[pos_quiet]
  lat_storm=lat[pos_storm]
  tilt_quiet=tilt[pos_quiet]
  tilt_storm=tilt[pos_storm]
  dim=fix((L_shell_max-L_shell_min)/0.2)
  L_value=indgen(dim)*0.2+0.1+L_shell_min
  J_quiet_a=dblarr(dim)+500
  error_quiet=dblarr(dim)
  lat_quiet_a=dblarr(dim)
  tilt_quiet_a=dblarr(dim)
  J_storm_a=dblarr(dim)+500
  error_storm=dblarr(dim)
  lat_storm_a=dblarr(dim)+500
  tilt_storm_a=dblarr(dim)+500
  for i=0,dim-1 do begin
    lmin=L_shell_min+i*0.2
    lmax=L_shell_min+(i+1)*0.2
    pos_quiet=where((x_quiet gt lmin) and (x_quiet le lmax),k_quiet)
    if k_quiet gt data_number_threshold then begin
      J_quiet_a[i]=median(y_quiet[pos_quiet])
      error_quiet[i]=median(abs(y_quiet[pos_quiet]-median(y_quiet[pos_quiet])));median absolute deviation

      lat_quiet_a[i]=median(lat_quiet[pos_quiet])
      tilt_quiet_a[i]=median(tilt_quiet[pos_quiet])
    endif
    pos_storm=where((x_storm gt lmin) and (x_storm le lmax),k_storm)
    if k_storm gt data_number_threshold then begin
      J_storm_a[i]=median(y_storm[pos_storm])
      error_storm[i]=median(abs(y_storm[pos_storm]-median(y_storm[pos_storm])))
      
      lat_storm_a[i]=median(lat_storm[pos_storm])
      tilt_storm_a[i]=median(tilt_storm[pos_storm])
    endif
  endfor
  pos=where(J_storm_a ne 500,k)
  if k ne 0 then begin
    p_b1=plot(L_value[pos],lat_storm_a[pos],sym_color=color[1],symbol='+',sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot)
    p_c1=plot(L_value[pos],tilt_storm_a[pos],sym_color=color[1],symbol='o',sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot)
  endif

  pos=where(J_quiet_a ne 500)
  p_b2=plot(L_value[pos],lat_quiet_a[pos],sym_color=color[0],symbol='+',sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot)
  p_c2=plot(L_value[pos],tilt_quiet_a[pos],sym_color=color[0],symbol='o',sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot)
  p_a2=errorplot(L_value[pos],J_quiet_a[pos],error_quiet[pos],sym_color=color[0],errorbar_color=color[0],symbol=symbol,sym_size=0,sym_thick=0,linestyle=6,/current,/overplot,$
    ytickfont_size=text_size_b,ytickfont_style=font_style_a,ytickfont_name='Times',xtickfont_size=text_size_b,xtickfont_style=font_style_a,xtickfont_name='Times',xtitle=xtitle,ytitle=ytitle,$
    font_name='Times',font_size=text_size_c,font_style=font_style_a,xtickformat=xtickformat,ERRORBAR_CAPSIZE=errorbar_capsize,errorbar_thick=errorbar_thick,ERRORBAR_LINESTYLE=6)
  ;  stop
end