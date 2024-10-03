;Panels in Fig 1
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024
;
pro fig1_ctm_rc_panel_v3,position,epoch,x1,y1,tilt1,mlat1,mission,i,n,color
  font_size=12
  sym_size=1
  sym_thick=2
  font_style=2
  symbol1='tu'
  symbol2='x'
  symbol3='td'
  m_txt=['Cluster 20010107-20191201','THEMIS 20100301-20121231','MMS 20150901-20161231']
  panel=['a','b','c']
  tilt_b=11.5
  mlat_b=10
  re=6371.2
  cdf_epoch,epoch,year,month,day,hour,minute,second,/break
  pos=where(mission eq i+1 and (day mod 4) eq 0 and (minute mod 15) eq 0 )
  x=x1[pos]/re
  y=y1[pos]/re
  tilt=tilt1[pos]
  mlat=mlat1[pos]
  x0=dindgen(101)/50-1
  y0=sqrt(1-x0^2)
  p1=plot(x0,y0,/current,/aspect_ratio,xrange=[-9,9],yrange=[-9,9],position=position)
  p2=plot(x0,-y0,/current,/overplot)
  P3=barplot(x0[50:*],-y0[50:*],/current,/overplot)
  pos=where(abs(tilt) le tilt_b and mlat gt mlat_b,k)
  if k ne 0 then begin
    p5=plot(-x[pos],-y[pos],color[1],/current,/overplot,linestyle='none',symbol=symbol1,sym_size=sym_size,/sym_filled)
  endif
  pos=where(abs(tilt) le tilt_b and abs(mlat) le mlat_b,k)
  if k ne 0 then begin
    p6=plot(-x[pos],-y[pos],color[1],/current,/overplot,linestyle='none',symbol=symbol2,sym_size=sym_size)
  endif
  pos=where(abs(tilt) le tilt_b and mlat lt -mlat_b,k)
  if k ne 0 then begin
    p7=plot(-x[pos],-y[pos],color[1],/current,/overplot,linestyle='none',symbol=symbol3,sym_size=sym_size)
  endif
  pos=where(tilt lt -tilt_b and mlat gt mlat_b,k)
  if k ne 0 then begin
    p6=plot(-x[pos],-y[pos],color[0],/current,/overplot,linestyle='none',symbol=symbol1,sym_size=sym_size,/sym_filled)
  endif
  pos=where(tilt lt -tilt_b and abs(mlat) le mlat_b,k)
  if k ne 0 then begin
    p8=plot(-x[pos],-y[pos],color[0],/current,/overplot,linestyle='none',symbol=symbol2,sym_size=sym_size)
  endif
  pos=where(tilt lt -tilt_b and mlat lt -mlat_b,k)
  if k ne 0 then begin
    p9=plot(-x[pos],-y[pos],color[0],/current,/overplot,linestyle='none',symbol=symbol3,sym_size=sym_size)
  endif
  pos=where(tilt gt tilt_b and mlat gt mlat_b,k)
  if k ne 0 then begin
    p10=plot(-x[pos],-y[pos],color[2],/current,/overplot,linestyle='none',symbol=symbol1,sym_size=sym_size,/sym_filled)
  endif
  pos=where(tilt gt tilt_b and abs(mlat) le mlat_b,k)
  if k ne 0 then begin
    p11=plot(-x[pos],-y[pos],color[2],/current,/overplot,linestyle='none',symbol=symbol2,sym_size=sym_size)
  endif
  pos=where(tilt gt tilt_b and mlat lt -mlat_b,k)
  if k ne 0 then begin
    p12=plot(-x[pos],-y[pos],color[2],/current,/overplot,linestyle='none',symbol=symbol3,sym_size=sym_size)
  endif
  P4=barplot(x0[50:*],y0[50:*],/current,/overplot,$
    xtickvalues=[-8,-6,-4,-2,0,2,4,6,8],ytickvalues=[-8,-6,-4,-2,0,2,4,6,8],ytickname=['8','6','4','2','0','-2','-4','-6','-8'],$
    xtickfont_name='Times',ytickfont_name='Times',font_name='Times',xminor=1,yminor=1,$
    ytitle='$Y_{SM} (R_E)$',ytickfont_size=font_size)
  if i ne n-1 then begin
    p4.xtickformat='(a1)'
  endif else begin
    p4.xtitle='$X_{SM} (R_E)$'
    p4.xtickfont_size=font_size
    p4.xtickname=['8','6','4','2','0','-2','-4','-6','-8']
  endelse
  t=text(position[0]+0.05,position[1]+(position[3]-position[1])*0.9,'('+panel[i]+')',font_size=font_size,font_name='Times',font_style=1)
  t=text(0.05,position[1]+(position[3]-position[1])*0.21,m_txt[i],font_size=font_size,font_name='Times',orientation=90,font_style=0)
end