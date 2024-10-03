

pro mlt_to_phi,mlt=mlt,phi=phi,degree=degree

  phi=(mlt-12)*15.0
  pos=where(phi lt 0)
  phi[pos]=phi[pos]+360.0
  if undefined(degree) then begin
    phi=phi*!DTOR
  endif
end