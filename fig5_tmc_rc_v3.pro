;绘制统计图 （CTM比较文章）
;

pro fig5_ctm_rc_v3
  condition=['Quiet','Storm']
  for mlt=0,23 do begin
    for txt_id=0,1 do begin
      fig5_tmc_rc_mlt_v3,mlt,condition[txt_id]
    endfor
  endfor
end