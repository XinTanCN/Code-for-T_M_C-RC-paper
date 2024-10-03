

pro fig3_tmc_rc_panel_v3_1,position,flag,jphi,l,symh0,mission,mlt_range,mlt0,color
  L_shell_min=4
  L_shell_max=8
  L_range=[L_shell_min,L_shell_max]
  data_number_threshold=30
  ;---Plot parameter---
  text_size_a=10
  text_size_b=12
  text_size_c=14
  text_size_d=16
  errorbar_capsize=0.075
  errorbar_thick=0.5
  sym_size=0.75
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
    xminor=9,yrange=[-25,5],ytickvalue=indgen(3)*10-20,yminor=4)
  y=jphi[pos]
  x=l[pos]
  mission=mission[pos]
  symh=symh0[pos]
  mlt=mlt0[pos]
  if mlt_range[0] le mlt_range[1] then begin
    pos_quiet=where(mlt gt mlt_range[0] and mlt lt mlt_range[1] and symh ge -30)
    pos_storm=where(mlt gt mlt_range[0] and mlt lt mlt_range[1] and symh le -30)
  endif else begin
    pos_quiet=where((mlt gt mlt_range[0] or mlt lt mlt_range[1]) and symh ge -30)
    pos_storm=where((mlt gt mlt_range[0] or mlt lt mlt_range[1]) and symh le -30)
  endelse
  y_quiet=y[pos_quiet]
  y_storm=y[pos_storm]
  mission_quiet=mission[pos_quiet]
  mission_storm=mission[pos_storm]
  x_quiet=x[pos_quiet]
  x_storm=x[pos_storm]
  dim=fix((L_shell_max-L_shell_min)/0.2)
  L_value=indgen(dim)*0.2+0.1+L_shell_min
  J_quiet_a=dblarr(dim)+!values.F_NAN
  error_quiet=dblarr(dim)
  J_storm_a=dblarr(dim)+!values.F_NAN
  error_storm=dblarr(dim)
  for i=0,dim-1 do begin
    lmin=L_shell_min+i*0.2
    lmax=L_shell_min+(i+1)*0.2
    
    pos_quiet_themis=where((x_quiet gt lmin) and (x_quiet le lmax) and (mission_quiet eq 116),k_quiet_themis)
    if k_quiet_themis gt data_number_threshold then Jtemp_quiet_themis=median(y_quiet[pos_quiet_themis]) else Jtemp_quiet_themis=!values.F_NAN
    
    pos_quiet_mms=where((x_quiet gt lmin) and (x_quiet le lmax) and (mission_quiet eq 109),k_quiet_mms)
    if k_quiet_mms gt data_number_threshold then Jtemp_quiet_mms=median(y_quiet[pos_quiet_mms]) else Jtemp_quiet_mms=!values.F_NAN
    
    pos_quiet_cluster=where((x_quiet gt lmin) and (x_quiet le lmax) and (mission_quiet eq 99),k_quiet_cluster)
    if k_quiet_cluster gt data_number_threshold then Jtemp_quiet_cluster=median(y_quiet[pos_quiet_cluster]) else Jtemp_quiet_cluster=!values.F_NAN
    
    J_quiet_a[i]=mean([Jtemp_quiet_themis,Jtemp_quiet_mms,Jtemp_quiet_cluster],/nan)   
        
    pos_storm_themis=where((x_storm gt lmin) and (x_storm le lmax) and (mission_storm eq 116),k_storm_themis)
    if k_storm_themis gt data_number_threshold then Jtemp_storm_themis=median(y_storm[pos_storm_themis]) else Jtemp_storm_themis=!values.F_NAN

    pos_storm_mms=where((x_storm gt lmin) and (x_storm le lmax) and (mission_storm eq 109),k_storm_mms)
    if k_storm_mms gt data_number_threshold then Jtemp_storm_mms=median(y_storm[pos_storm_mms]) else Jtemp_storm_mms=!values.F_NAN

    pos_storm_cluster=where((x_storm gt lmin) and (x_storm le lmax) and (mission_storm eq 99),k_storm_cluster)
    if k_storm_cluster gt data_number_threshold then Jtemp_storm_cluster=median(y_storm[pos_storm_cluster]) else Jtemp_storm_cluster=!values.F_NAN

    J_storm_a[i]=mean([Jtemp_storm_themis,Jtemp_storm_mms,Jtemp_storm_cluster],/nan)  
    
    pos_quiet=where((x_quiet gt lmin) and (x_quiet le lmax),k_quiet)
    if k_quiet gt data_number_threshold then begin
      error_quiet[i]=median(abs(y_quiet[pos_quiet]-J_quiet_a[i]));median absolute deviation
    endif
    pos_storm=where((x_storm gt lmin) and (x_storm le lmax),k_storm)
    if k_storm gt data_number_threshold then begin
      error_storm[i]=median(abs(y_storm[pos_storm]-J_storm_a[i]));
    endif  
    
  endfor
  
  pos=where(finite(J_storm_a),k)
  if k ne 0 then begin
;    p_a1=plot(L_value[pos],J_storm_a[pos],sym_color=color[1],symbol=symbol,sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot)
    p_a1=errorplot(L_value[pos],J_storm_a[pos],error_storm[pos],sym_color=color[1],errorbar_color=color[1],symbol=symbol,sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot,$
  ERRORBAR_CAPSIZE=errorbar_capsize,errorbar_thick=errorbar_thick)
  endif
  
  pos=where(finite(J_quiet_a))
;  p_a2=plot(L_value[pos],J_quiet_a[pos],sym_color=color[0],symbol=symbol,sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot,$
;    ytickfont_size=text_size_b,ytickfont_style=font_style_a,ytickfont_name='Times',xtickfont_size=text_size_b,xtickfont_style=font_style_a,xtickfont_name='Times',xtitle=xtitle,ytitle=ytitle,$
;    font_name='Times',font_size=text_size_c,font_style=font_style_a,xtickformat=xtickformat)
p_a2=errorplot(L_value[pos],J_quiet_a[pos],error_quiet[pos],sym_color=color[0],errorbar_color=color[0],symbol=symbol,sym_size=sym_size,sym_thick=sym_thick,linestyle=6,/current,/overplot,$
  ytickfont_size=text_size_b,ytickfont_style=font_style_a,ytickfont_name='Times',xtickfont_size=text_size_b,xtickfont_style=font_style_a,xtickfont_name='Times',xtitle=xtitle,ytitle=ytitle,$
  font_name='Times',font_size=text_size_c,font_style=font_style_a,xtickformat=xtickformat,ERRORBAR_CAPSIZE=errorbar_capsize,errorbar_thick=errorbar_thick)
;  stop
end