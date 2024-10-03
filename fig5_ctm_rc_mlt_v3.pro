;subroutine for fig5 plotting
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig5_ctm_rc_mlt_v3,k,txt
  mlt_range=[k,k+1]
  case txt of
    'Quiet':symh_range=[-30,3000]
    'Storm':symh_range=[-30000,-30]
  endcase


  L_range=[4,8]
  up=50.0
  bottom=50.0
  left=80.0
  right=10.0
  width=510.0
  hight=125.0
  font_size=12
  sym_size=0.2
  sym_thick=0.2
  font_style=2
  symbol=['tu','D','o']
  par=['Jphi','Median','MLAT','TILT','SIZE','DOY','SYMH']
  color=['deep_sky_blue','firebrick','navy']
  n=n_elements(par)
  dim=[left+right+width,up+n*hight+bottom]
  ;-----图窗准备-----
  title=txt+strtrim(string(mlt_range[0],format='(i2.2)'),2)+'-'+strtrim(string(mlt_range[1],format='(i2.2)'),2)+' MLT'
  w=window(window_title=title,dimensions=dim)
  fn='Figures\'+title+'.png'
  for i=0,n-1 do begin
    position=[left/(left+right+width),(bottom+(n-i-1)*hight)/(up+n*hight+bottom),$
      (left+width)/(left+right+width),(bottom+(n-i)*hight)/(up+n*hight+bottom)]
    fig5_ctm_rc_panel_v3,mlt_range,symh_range,L_range,symbol,sym_size,position,font_size,par[i],i,n,color
  end
  title=txt+''+strtrim(string(mlt_range[0],format='(i2.2)'),2)+':00-'+strtrim(string(mlt_range[1],format='(i2.2)'),2)+':00 MLT'
  t=text(0.12,(dim[1]-0.65*up)/dim[1],title,font_size=font_size+1,font_name='Times',font_style=0)
  t1=text(0.51,(dim[1]-0.65*up)/dim[1],'Cluster',color[0],font_size=font_size+1,font_name='Times',font_style=0)
  t2=text(0.65,(dim[1]-0.65*up)/dim[1],'THEMIS',color[1],font_size=font_size+1,font_name='Times',font_style=0)
  t1=text(0.84,(dim[1]-0.65*up)/dim[1],'MMS',color[2],font_size=font_size+1,font_name='Times',font_style=0)
  w.save,fn,RESOLUTION=600,border=0,/overwrite
  w.close
;  stop
end