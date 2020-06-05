; #############################################################################
undef("coswgt_areaave")
function coswgt_areaave(field:numeric)
;
; Arguments
;    field: numeric field.
;
; Return value
;    The area average using cosine lat weights.
;
; Description
;    Computes the area average using cosine lat weights and lon weights=1.
;
; Caveats
;
; References
;
; Modification history
;    20131209-evaldsson_martin: written.
;
local funcname, scriptname, lat, wgt_lat, lon, lon_size, wgt_lon, ave
begin

  funcname = "coswgt_areaave"
  scriptname = "diag_scripts/shared/statistics.ncl"

  ;enter_msg(scriptname, funcname)

  lat = field&lat
  wgt_lat = tofloat(NormCosWgtGlobe(lat))

  lon = field&lon
  lon_size = dimsizes(lon)
  wgt_lon = new((/lon_size(0)/), float)
  wgt_lon = 1.0

  ave = wgt_areaave_Wrap(field, wgt_lat, wgt_lon, 0)
  print(ave)
  ;leave_msg(scriptname, funcname)
  return(ave)

end
; #############################################################################
undef("coswgt_areastd")
function coswgt_areastd(field:numeric)
;
; Arguments
;    field: numeric field.
;
; Return value
;    The area average using cosine lat weights.
;
; Description
;    Computes the area average using cosine lat weights and lon weights=1.
;
; Caveats
;
; References
;
; Modification history
;    20131209-evaldsson_martin: written.
;
local funcname, scriptname, lat, wgt_lat, lon, lon_size, wgt_lon, ave
begin

  funcname = "coswgt_areastd"
  scriptname = "diag_scripts/shared/statistics.ncl"

  ;enter_msg(scriptname, funcname)
   lat = field&lat
   lon = field&lon
   re   = 6.37122e06
   rad  = 4.0 * atan(1.0) / 180.0  
   con  = re * rad
   clat = cos(lat * rad)           ; cosine of latitude
   dlon = (lon(2) - lon(1))        ; assume dlon is constant
   dlat = (lat(2) - lat(1))        ; assume dlat is constant
   
   dx   = con * dlon * clat        ; dx at each latitude
   dy   = con * dlat               ; dy is constant
   dydx = dy * dx                  ; dydx(nlat)
   nlat=dimsizes(lat)
   mlon=dimsizes(lon)
   wgt  = new((/nlat, mlon/), typeof(dydx))
   wgt=conform (wgt, dydx, 0)



   ave = wgt_areaave2(field, wgt, 0)
   print(ave)
   print(field(10,10))
   d2 = (field - ave) ^ 2 ;
   print(d2)
     ; Calculate weighted standard deviation
   ss=sum(d2)
   print(ss)
   arg = wgt_areasum2(d2, wgt, 0)

   print(arg)
   print( num(.not.ismissing(field)))
   v1 = sum(where(ismissing(field), wgt@_FillValue, wgt))
   v2 = sum(where(ismissing(field), wgt@_FillValue, wgt) ^ 2)
   dd=(v1 / (v1 ^ 2 - v2))

   out = sqrt( arg*dd)

  ;leave_msg(scriptname, funcname)
  return(out)


end
; #############################################################################

