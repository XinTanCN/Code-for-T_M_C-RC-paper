;
; The following program will load all of the data for a specific CDF file and
; variable into IDL or Part of the file by using REC_COUNT & REC_START
; If REC_COUNT IS too large the file will be loaded to the end of file
;
; Modified 10/06/1995 to fix single record access
;

pro loadcdf,CDF_file,CDF_var,x,REC_COUNT=rcnt,REC_START=rstr

ON_IOERROR,BAD
;
; Open CDF file
;
id = -1
id = cdf_open(CDF_file)
;
; Get file CDF structure information
;
inq = cdf_inquire(id)
;
; Get variable structure information
;
vinq = cdf_varinq(id,CDF_var)
;
; Check to see if REC_START keyword is used
;
IF KEYWORD_SET(rstr) EQ 0 THEN rstr = 0
;
; Check to see if variable requested is a Z variable
;
case 1 of

   (vinq.is_zvar eq 0): begin    ; NOT Z var

        dims = total(vinq.dimvar)
        dimc = vinq.dimvar * inq.dim
        dimw = where(dimc eq 0)
        if (dimw(0) ne -1) then dimc(dimw) = 1
        IF KEYWORD_SET(rcnt) EQ 0 THEN rcnt = inq.maxrec+1
        if (vinq.recvar eq 'NOVARY') then rcnt = 1
        if ((rstr+rcnt) gt inq.maxrec+1) then rcnt = inq.maxrec+1 - rstr
        CDF_varget,id,CDF_var,x,COUNT=dimc,REC_COUNT=rcnt,REC_START=rstr

        end

    else: begin                 ; IS Z var

        dims = total(vinq.dimvar)
        dimc = vinq.dimvar * vinq.dim
        dimw = where(dimc eq 0)
        if (dimw(0) ne -1) then dimc(dimw) = 1
        !QUIET = 1
        CDF_control,id,variable=CDF_var,/zvariable,get_var_info=vinfo
        !QUIET = 0
;
; Removed 06/01/1996 JBB
; Caused read-only files to fail
;
;        CDF_control,id,variable=CDF_var,/zvariable,set_padvalue=0.0
        IF KEYWORD_SET(rcnt) EQ 0 THEN rcnt = vinfo.maxrec+1
        if (vinq.recvar eq 'NOVARY') then rcnt = 1
        if ((rstr+rcnt) gt vinfo.maxrec+1) then rcnt = vinfo.maxrec+1 - rstr
        CDF_varget,id,CDF_var,x,COUNT=dimc,REC_COUNT=rcnt,REC_START=rstr,/zvariable

        end

endcase

sa = size(x)
sa = sa(1:sa(0))
;print, sa
if (vinq.recvar eq 'VARY' and dims ne 0 and rcnt gt 1) then begin

   x = reform(x,[marray(sa(0:(n_elements(sa)-2))),sa(n_elements(sa)-1)])
   x = transpose(x)
   sa = shift(sa,1)
   x = reform(x,sa)

endif

saw = where(sa ne 1)
x = reform(x,sa(saw))

goto, DONE

BAD: x = -1


DONE: if (id ne -1) then CDF_close,id

return
end

