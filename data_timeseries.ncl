;*************************************************
load "statistics2.ncl"
load "select_region.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  att="DAY"
  a = addfile("/Users/irenecionni/obs_c3s/Tier3/CDS-TTC-IASI-B"+att+"/OBS_CDS-TTC-IASI-B_sat_L3_Amon_tropoz_201401-201812.nc" ,"r")
;************************************************
; read in zonal winds
;************************************************
  tropoz=a->tropoz                                
  printVarSummary(tropoz)
  dim=dimsizes(tropoz)
  print(dim)
  clim1=clmMonTLL(tropoz)
  anom_clim1= calcMonAnomTLL(tropoz,clim1)
  printVarSummary(anom_clim1)
  anom_ann=month_to_annual(anom_clim1, 1)
  print(anom_ann)
  printVarSummary(anom_ann)
  time=tropoz&time
  date= cd_calendar(time, 0)
  yy=toint(date(:,0)) 
  print(yy)
  dim=dimsizes(anom_ann)
  ts1_avg=coswgt_areaave(tropoz)
  printVarSummary(ts1_avg)


 
;regions
;region_label=(/"WNA","ENA","CAM","TSA","SSA","EUM","NAF","CAF","SAF",\
;        "NAS","CAS","EAS","SAS","SEA","AUS"/)
region_label=(/"ENA","EUM","EAS","SAS","TSA","NAF","SAF"/)
ts_regions=new((/dimsizes(ts1_avg),dimsizes(region_label)/),typeof(ts1_avg))
latrange=new((/dimsizes(region_label),2/),"double")
lonrange=new((/dimsizes(region_label),2/),"double")
do ir=0,dimsizes(region_label)-1
       region=select_region(region_label(ir))
       latrange(ir,:)=region(0:1)
       lonrange(ir,:)=region(2:3)
       ts_regions(:,ir)=area_operations(tropoz,latrange(ir,0),latrange(ir,1),lonrange(ir,0),lonrange(ir,1),"average",True)
 end do
print(latrange)
print(lonrange)
ts_regions!0="time"
ts_regions!1="region"
ts_regions&region=region_label
printVarSummary(ts_regions)

ts_distribution=new((/7,dimsizes(tropoz&time)/),typeof(tropoz))
do itim=0,dimsizes(tropoz&time)-1
 stat=stat_dispersion(tropoz(itim,:,:), False )
 
 ts_distribution(1:2,itim)=stat(23:24)
 ts_distribution(3,itim)=stat(6)
 ts_distribution(4,itim)=stat(10)
 ts_distribution(5:6,itim)=stat(25:26)
 delete(stat)
end do

ts_distribution(0,:)=ts1_avg
ts_distribution!0="stat"
ts_distribution!1="time"
ts_distribution&stat=(/"Mean","Lower 1.0%","Lower 5.0%","LowQuartile","HighQuartile","Upper 5.0%","Upper 1.0%"/)
  wks = gsn_open_wks("png","var_1_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file
  gsn_define_colormap(wks,"NEO_div_vegetation_c")
;  gsn_reverse_colormap(wks)
  plot=new(dim(0),"graphic")
  
  do itim=0,dim(0)-1
 
    avg_clim1=coswgt_areaave(anom_ann(itim,:,:))
    avg_std1=coswgt_areastd(anom_ann(itim,:,:))

     res = True                                    ; plot mods desired
     res@gsnDraw                  = False            ; don't draw yet
     res@gsnFrame                 = False            ; don't advance frame yet

     res@cnFillOn         = True               ; color Fill 
     res@cnFillMode       = "RasterFill"       ; Raster Mode
     res@cnLinesOn        =  False             ; Turn off contour lines
     res@cnLineLabelsOn       =False
     res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
     res@cnMinLevelValF       = -1.5               ; set min contour level
     res@cnMaxLevelValF       = 1.5               ; set max contour level
     res@cnLevelSpacingF      = 0.3               ; set contour spacing
     ;res@cnLabelBarEndStyle="ExcludeOuterBoxes"
     res@tiMainString         = "Annual map "+yy(12*itim)    ; plot title
     fmt = "%3.2f"
     res@gsnLeftString      = "[DU]"
     res@gsnRightString     = "mean: "+sprintf(fmt,avg_clim1)+" std:"+sprintf(fmt,avg_std1)           ; plot center string

     res@lbLabelBarOn = False
     plot(itim) = gsn_csm_contour_map(wks,anom_ann(itim,:,:), res)  ; create plot
  end do
  resP=True
  resP@gsnPanelLabelBar    = True                ; add common colorbar
   gsn_panel(wks,plot,(/3,2/),resP)
;***********************time serie************************************************


;************************************************
  wks1 = gsn_open_wks("png","ts_1_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file

; Set resources necessary to customize Y axis labels
  
  res11=True
  ;res11@gsnDraw                  = False            ; don't draw yet
  ;res11@gsnFrame                 = False            ; don't advance frame yet
  ;res@tiMainString  = "An xy plot Example"   ; title
  res11@tiYAxisString = "Tropospheric Ozone Column [DU]"           ; y axis title
  res11@vpHeightF= 0.4                    ; change aspect ratio of plot
  res11@vpWidthF = 0.6
  ;res@tiXAxisString = "Time"                 ; x axis title
  res11@trXMinF      = min(tropoz&time) 
  ;res11@trXMaxF      = 180.
  res11@trYMinF      = 10.
  res11@trYMaxF      = 16.
  res11@xyLineColor      = "NavyBlue"
  res11@xyLineThicknessF = 3.5
  resTick                = True
  resTick@ttmFormat      = "%N/%Y"
  resTick@ttmAxis        = "XB"
  resTick@ttmMajorStride = 12
  time_axis_labels( ts1_avg&time,  res11, resTick )
  plot2 = gsn_csm_xy(wks1,time,ts1_avg, res11)  ; create plot
  

;************************************************
  wks2 = gsn_open_wks("png","ts_2_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file

; Set resources necessary to customize Y axis labels

  res11=True
  ;res11@gsnDraw                  = False            ; don't draw yet
  ;res11@gsnFrame                 = False            ; don't advance frame yet
  res11@tiMainString  = "Regional time series"   ; title
  res11@tiYAxisString = "Tropospheric Ozone Column [DU]"           ; y axis title
  res11@vpHeightF= 0.4                    ; change aspect ratio of plot
  res11@vpWidthF = 0.6
  res11@trYMinF      = 0.
  res11@trYMaxF      = 30.
 res11@trXMinF      = min(tropoz&time)
  res11@xyLineColors     = (/"NavyBlue","yellow","green","Purple","LightBlue","orange","red"/)
  res11@xyLineThicknessF = 3
  res11@pmLegendDisplayMode    = "Always"            ; turn on legend
  res11@pmLegendSide           = "Top"               ; Change location of 
  res11@pmLegendParallelPosF   = 1.2                 ; move units right
  res11@pmLegendOrthogonalPosF =- 0.7                ; move units down
  res11@pmLegendWidthF         = 0.1                ; Change width and
  res11@pmLegendHeightF        = 0.18                ; height of legend.
  res11@lgPerimOn              = False               ; turn off box around
  res11@lgLabelFontHeightF     = .01                 ; label font height
  res11@xyExplicitLegendLabels = region_label         ; create explicit labels
  resTick                = True
  resTick@ttmFormat      = "%N/%Y"
  resTick@ttmAxis        = "XB"
  resTick@ttmMajorStride = 12
  time_axis_labels( ts1_avg&time,  res11, resTick )
  plot2 = gsn_csm_xy(wks2,time,ts_regions(region|:,time|:), res11)  ; create plot
;************************************************
;************************************************
  wks3 = gsn_open_wks("png","ts_stat_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file

; Set resources necessary to customize Y axis labels
  delete(res11)
  res11=True
  ;res11@gsnDraw                  = False            ; don't draw yet
  ;res11@gsnFrame                 = False            ; don't advance frame yet
  ;res11@tiMainString  = "Statistical distribution"   ; title
  res11@tiYAxisString = "Tropospheric Ozone Column [DU]"           ; y axis title
  res11@vpHeightF= 0.4                    ; change aspect ratio of plot
  res11@vpWidthF = 0.6
   res11@trXMinF      = min(tropoz&time)
  res11@trYMinF      = 0.
  res11@trYMaxF      = 30.
  res11@xyLineColors     = (/"Black","LightBlue","NavyBlue","Purple","Purple","NavyBlue","LightBlue"/)
  res11@xyMonoLineThickness =False
  res11@xyLineThicknesses = (/3,2,2,2,2,2,2./)
  res11@pmLegendDisplayMode    = "Always"            ; turn on legend
  res11@pmLegendSide           = "Top"               ; Change location of
  res11@pmLegendParallelPosF   = 1.2                  ; move units right
  res11@pmLegendOrthogonalPosF = -0.6                ; move units down
  res11@pmLegendWidthF         = 0.1                ; Change width and
  res11@pmLegendHeightF        = 0.18                ; height of legend.
  res11@lgPerimOn              = False               ; turn off box around
  res11@lgLabelFontHeightF     = .01                 ; label font height
  res11@xyExplicitLegendLabels = ts_distribution&stat         ; create explicit labels
  resTick                = True
  resTick@ttmFormat      = "%N/%Y"
  resTick@ttmAxis        = "XB"
  resTick@ttmMajorStride = 12
  time_axis_labels( ts1_avg&time,  res11, resTick )
  plot3 = gsn_csm_xy(wks3,time,ts_distribution(stat|:,time|:), res11)  ; create plot
end
