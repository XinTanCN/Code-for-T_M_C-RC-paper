;Panels in Fig 2R
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig2r_tmc_rc_panel_v3,mission,position

  fn='Data\Result_20231230_mlat30_ep085_cs1.cdf'
  loadcdf,fn,'Epoch',epoch
  loadcdf,fn,'Size',sc
  loadcdf,fn,'Mission',m
  
  case strupcase(mission) of
    'MMS':begin
      mission_mark=109
      ytitle='MMS'
      xtickformat=''
      xtitle='$Characteristic Size (R_E)$'
      yrange=[0,1.1]
      ytickvalues=dindgen(3)*0.5
      yminor=4
;      ytickformat='(a1)'
    end
    'THEMIS':begin
      mission_mark=116
      ytitle='THEMIS'
      xtickformat='(a1)'
      xtitle=''
      yrange=[0,0.25]
      ytickvalues=dindgen(2)*0.1+0.1
      yminor=1
;      ytickformat='(a1)'
    end
    'CLUSTER':begin
      mission_mark=99
      ytitle='Cluster'
      xtickformat='(a1)'
      xtitle=''
      yrange=[0,0.25]
      ytickvalues=dindgen(2)*0.1+0.1
      yminor=1
;      ytickformat='(a1)'
    end
    else:begin
      stop
    end
  endcase
  pos=where(m eq mission_mark)
  sc_c=sc[pos]
  epoch_c=epoch[pos]
  pdf=histogram(sc_c,locations=xbin,binsize=0.05)
  pdf=pdf/total(pdf)
  h=barplot(xbin,pdf,'k',FILL_COLOR='navy',xrange=[-0.05,1.05],position=position,xtitle=xtitle,xtickformat=xtickformat,/current,$
    xtickvalue=indgen(6)*0.2,xminor=3,xtickfont_size=12,xtickfont_style=0,xtickfont_name='Times',$
    ytitle=ytitle,yminor=yminor,ytickfont_size=12,ytickfont_style=0,ytickfont_name='Times',width=1,$
    ytickformat=ytickformat,yrange=yrange,ytickvalues=ytickvalues)
  t=text(0.65,yrange[1]/2,'$SC_{Me}=$'+string(median(sc_c)*6371.2,format='(i4.0)')+' km',font_name='Times',font_size=12,/data,$
    target=h)
end