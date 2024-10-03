;Cluster、THEMIS、MMS Jphi Distribution (Figure 6)
;tanxin@buaa.edu.cn
;Last modified on 2 October 2024

pro fig6_tmc_rc_v3
  mission=['Cluster','THEMIS','MMS']
  activity=['Quiet','Storm']
  up=40.0
  bottom=80.0
  left=50.0
  right=10.0
  width=300.0
  hight=300.0
  midh=10.0
  midw=10.0
  
  RGB_TABLE=70
  L_range=[4,8]
  
  ;----Plot-----
  n=n_elements(mission);Number of panels in the vertical direction
  m=n_elements(activity);Number of panels in the horizontal direction
  dimw=left+right+m*width+(m-1)*midw
  dimh=up+n*hight+bottom+(n-1)*midh
  panel=[['(a)','(b)'],['(c)','(d)'],['(e)','(f)']]
  w=window(dimension=[dimw,dimh],window_title='Figure 6')
  for i=0,n-1 do begin
    t_mission=text(0.05,(dimh-(i+0.5)*hight-up-i*midh-30)/dimh,mission[i],'k',font_size=12,font_name='Times', font_style=0,ORIENTATION=90)
    for j=0,m-1 do begin
      x0=(left+j*(width+midw))/dimw
      y0=(dimh-up-(i+1)*hight-i*midh)/dimh
      position=[x0,y0,x0+width/dimw,y0+hight/dimh]
      t_panel=text(position[0]+(15/dimw),position[3]-(35/dimh),panel(j,i),'k',font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
      fig6_tmc_rc_panel_v3,position,mission[i],activity[j],RGB_TABLE,L_range
    endfor
  endfor
  for j=0,m-1 do begin
    x0=(left+j*(width+midw)+125)/dimw
    y0=(dimh-up+10)/dimh
    t_activity=text(x0,y0,activity[j],'k',font_size=12,font_name='Times', font_style=0,ORIENTATION=0)
  endfor
;  stop
  xc=(left+width*m/2+midh*(m-1)/2)/dimw
  y0=50/dimh
  cd_length=400.0
  cb=colorbar(position=[xc-cd_length/dimw/2,y0,xc+cd_length/dimw/2,y0+10/dimh],RGB_TABLE=RGB_TABLE,range=[-20,20],font_size=10,font_name='Times',$
    font_style=0,/border,title='$nA/m^2$',ticklen=0.5,minor=1)
  
  dir='Figures\'
  if file_test(dir) eq 0 then file_mkdir,dir
  fn1=dir+'Figure 6.png'
;  w.save,fn1,RESOLUTION=600,border=0,/overwrite
;  w.close
;  stop
end