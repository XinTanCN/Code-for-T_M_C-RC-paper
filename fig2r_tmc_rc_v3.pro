;Cluster、THEMIS、MMS Characteristic Size (Figure 2R)
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig2r_tmc_rc_v3
  
  mission=['Cluster','THEMIS','MMS']
  up=20.0
  bottom=60.0
  left=70.0
  right=20.0
  width=300.0
  hight=100.0
  
  n=n_elements(mission);Number of panels in the vertical direction
  dimw=left+right+width
  dimh=up+n*hight+bottom
  
  w=window(dimension=[dimw,dimh],window_title='Figure 2R')
  for i=0,n-1 do begin
    x0=left/dimw
    y0=(dimh-up-(i+1)*hight)/dimh
    position=[x0,y0,x0+width/dimw,y0+hight/dimh]
    fig2r_tmc_rc_panel_v3,mission[i],position
  endfor
  dir='Figures\'
  fn1=dir+'Figure 2R.png'
;  w.save,fn1,RESOLUTION=600,border=0,/overwrite
;  w.close
;  stop
  
  
end