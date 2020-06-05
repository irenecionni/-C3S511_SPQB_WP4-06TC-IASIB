;*************************************************
load "statistics2.ncl"
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
  media_clim=dim_avg_n_Wrap(tropoz,0)
  std_clim=dim_stddev_n_Wrap(tropoz,0)
  clim1=clmMonTLL(tropoz)
  printVarSummary(clim1)
  mer1=dim_avg_n_Wrap(tropoz,1)
  printVarSummary(mer1)
  mer1_avg=dim_avg_n_Wrap(mer1,0)
  zon1=dim_avg_Wrap(tropoz)
  printVarSummary(zon1)
  zon1_avg=dim_avg_n_Wrap(zon1,0)
  printVarSummary(zon1_avg)
  wks = gsn_open_wks("png","mean_1_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file
  gsn_define_colormap(wks,"MPL_RdYlGn")
  gsn_reverse_colormap(wks)
  plot=new(12,"graphic")
  month_nam=(/"Jannuary","February","March","April","May","June","July","August","September","October","November","December"/)
  do itim=0,11
 
    avg_clim1=coswgt_areaave(clim1(itim,:,:))
    avg_std1=coswgt_areastd(clim1(itim,:,:))

     res = True                                    ; plot mods desired
     res@gsnDraw                  = False            ; don't draw yet
     res@gsnFrame                 = False            ; don't advance frame yet

     res@cnFillOn         = True               ; color Fill 
     res@cnFillMode       = "RasterFill"       ; Raster Mode
     res@cnLinesOn        =  False             ; Turn off contour lines
     res@cnLineLabelsOn       =False
     res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
     res@cnMinLevelValF       = 7.               ; set min contour level
     res@cnMaxLevelValF       = 23.               ; set max contour level
     res@cnLevelSpacingF      = 1               ; set contour spacing
     ;res@cnLabelBarEndStyle="ExcludeOuterBoxes"
     res@tiMainString         = "Climatology "+month_nam(itim)    ; plot title
     fmt = "%3.2f"
     res@gsnLeftString      = "[DU]"
     res@gsnRightString     = "mean: "+sprintf(fmt,avg_clim1)+" std:"+sprintf(fmt,avg_std1)           ; plot center string

     res@lbLabelBarOn = False
     plot(itim) = gsn_csm_contour_map(wks,clim1(itim,:,:), res)  ; create plot
  end do
  resP=True
  resP@gsnPanelLabelBar    = True                ; add common colorbar
   gsn_panel(wks,plot,(/4,3/),resP)

;************************************************
  wks1 = gsn_open_wks("png","mer_1_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file
  plot2=new(2,"graphic")
  gsn_define_colormap(wks1,"MPL_RdYlGn")
  gsn_reverse_colormap(wks1)
  res1 = True                                    ; plot mods desired
  res1@gsnDraw                  = False            ; don't draw yet
  res1@gsnFrame                 = False            ; don't advance frame yet

  res1@cnFillOn         = True               ; color Fill
  res1@cnFillMode       = "RasterFill"       ; Raster Mode
  res1@cnLinesOn        =  False             ; Turn off contour lines
  res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res1@cnMinLevelValF       = 7.               ; set min contour level
  res1@cnMaxLevelValF       = 20.               ; set max contour level
  res1@cnLevelSpacingF      = 1               ; set contour spacing
  res1@cnLabelBarEndStyle="ExcludeOuterBoxes"
  res1@lbOrientation = "vertical"
  ;res1@tiMainString         = "Data Availability as a fraction [1]"    ; plot title
  fmt = "%3.2f"
;  res@gsnLeftString      = "mean: "+sprintf(fmt,avg_avail)
;  res@gsnRightString     = " std:"+sprintf(fmt,avg_std)           ; plot center string
  res1@vpHeightF= 0.4                    ; change aspect ratio of plot
  res1@vpWidthF = 0.7                  
  resTick                = True
  resTick@ttmFormat      = "%N/%Y" 
  resTick@ttmAxis        = "YL"
  resTick@ttmMajorStride = 12

; Set resources necessary to customize Y axis labels
  time_axis_labels( mer1&time,  res1, resTick )
  flip_mer1=lonFlip(mer1)
  plot2(0) = gsn_csm_contour(wks1,flip_mer1, res1)  ; create plot
  flip_mer1_avg=lonFlip(mer1_avg)
  res11=True
  res11@gsnDraw                  = False            ; don't draw yet
  res11@gsnFrame                 = False            ; don't advance frame yet
  ;res@tiMainString  = "An xy plot Example"   ; title
  res11@tiYAxisString = "Tropospheric Ozone Column [DU]"           ; y axis title
  res11@vpHeightF= 0.4                    ; change aspect ratio of plot
  res11@vpWidthF = 0.7
  ;res@tiXAxisString = "Time"                 ; x axis title
  res11@trXMinF      = -180. 
  res11@trXMaxF      = 180.
  res11@trYMinF      = 10.
  res11@trYMaxF      = 16.
  res11@xyLineColor      = "NavyBlue"
  res11@xyLineThicknessF = 3.5
  plot2(1) = gsn_csm_xy(wks1,flip_mer1_avg&lon,flip_mer1_avg, res11)  ; create plot

   gsn_panel(wks1,plot2,(/2,1/),False)
 frame(wks1)

;************************************************
  wks3 = gsn_open_wks("png","zon_"+"OBS_CDS-TTC-IASI-B"+att)                ; send graphics to PNG file
  plot3=new(2,"graphic")
  gsn_define_colormap(wks3,"MPL_RdYlGn")
  gsn_reverse_colormap(wks3)
  res2 = True                                    ; plot mods desired
  res2@gsnDraw                  = False            ; don't draw yet
  res2@gsnFrame                 = False            ; don't advance frame yet

  res2@cnFillOn         = True               ; color Fill
  res2@cnFillMode       = "RasterFill"       ; Raster Mode
  res2@cnLinesOn        =  False             ; Turn off contour lines
  res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res2@cnMinLevelValF       = 7.               ; set min contour level
  res2@cnMaxLevelValF       = 23.               ; set max contour level
  res2@cnLevelSpacingF      = 1               ; set contour spacing
  ;res2@lbOrientation = "vertical"
  ;res2@tiMainString         = "Data Availability as a fraction [1]"    ; plot title
  ;res2@lbLabelBarOn = False
  ;res2@cnLabelBarEndStyle="ExcludeOuterBoxes"
  fmt = "%3.2f"
;  res@gsnLeftString      = "mean: "+sprintf(fmt,avg_avail)
;  res@gsnRightString     = " std:"+sprintf(fmt,avg_std)           ; plot center string
  res2@vpHeightF= 0.4                    ; change aspect ratio of plot
  res2@vpWidthF = 0.7
  res2@tmYLMode        = "Explicit"	
  res2@tmYLValues      = (/-60,-30,0,30,60/)
  res2@tmYLLabels      = (/"60S","30S","Eq","30N","60N"/)
  res2@tmYLLabelFontHeightF=0.015
  res2@tmXBLabelFontHeightF=0.015
  res2Tick                = True
  res2Tick@ttmFormat      = "%N/%Y"
  res2Tick@ttmAxis        = "XB"
  res2Tick@ttmMajorStride = 12
  
; Set resources necessary to customize Y axis labels
  time_axis_labels( zon1&time,  res2, res2Tick )
  plot3(0) = gsn_csm_lat_time(wks3,zon1(lat|:,time|:), res2)  ; create plot
  res21=True
  res21@gsnDraw                  = False            ; don't draw yet
  res21@gsnFrame                 = False            ; don't advance frame yet
  ;res@tiMainString  = "An xy plot Example"   ; title
  res21@tiXAxisString = "Tropospheric Ozone Column [DU]"           ; y axis title
  res21@vpHeightF= 0.4                    ; change aspect ratio of plot
  res21@vpWidthF = 0.3
  ;res@tiXAxisString = "Time"                 ; x axis title
  res21@trYMinF      = -90.
  res21@trYMaxF      = 90.
  res21@trXMinF      = 10.
  res21@trXMaxF      = 16.
  res21@tmYLMode        = "Explicit"
  res21@tmYLValues      = (/-60,-30,0,30,60/)
  res21@tmYLLabels      = (/"60S","30S","Eq","30N","60N"/)
  res21@tmYLLabelFontHeightF=0.015
  res21@tmXBMode        = "Explicit"
  res21@tmXBValues      = (/0.,0.2,0.4,0.6,0.8,1.0/)
  res21@tmXBLabels      = (/"0.","0.2","0.4","0.6","0.8","1."/)
  res21@tmXBLabelFontHeightF=0.015

;  res1@gsnAttachPlotsXAxis=True
  res21@xyLineColor      = "NavyBlue"
  res21@xyLineThicknessF  =3.5
  plot3(1) = gsn_csm_xy(wks3,zon1_avg,zon1_avg&lat, res21)  ; create plot
;  newplot =  gsn_attach_plots(plot2(0),plot2(1),res1,res11)
 ;draw(plot2(0))
  resP1=True
  ;resP@gsnPanelLabelBar    = True                ; add common colorbar
   gsn_panel(wks3,plot3,(/1,2/),resP1)
 frame(wks3)
;---------mean clim---------------------------------------------
delete(res)
  wks4=gsn_open_wks("png","media_OBS_CDS-TTC-IASI-B"+att)   
 gsn_define_colormap(wks4,"MPL_RdYlGn")
  gsn_reverse_colormap(wks4)

  res = True                                    ; plot mods desired
     
     res@cnFillOn         = True               ; color Fill 
     res@cnFillMode       = "RasterFill"       ; Raster Mode
     res@cnLinesOn        =  False             ; Turn off contour lines 
     res@cnLineLabelsOn       =False             
     res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
     res@cnMinLevelValF       = 7.               ; set min contour level
     res@cnMaxLevelValF       = 23.               ; set max contour level
     res@cnLevelSpacingF      = 1               ; set contour spacing
     ;resn@cnLabelBarEndStyle="ExcludeOuterBoxes"
     res@tiMainString         = "Mean "    ; plot title
     fmt = "%3.2f"
     res@gsnLeftString      = "[DU]"
     res@gsnRightString     = "mean: "+sprintf(fmt,avg_clim1)+" std:"+sprintf(fmt,avg_std1)           ; plot center string

 ;    res@lbLabelBarOn = False
     plot4 = gsn_csm_contour_map(wks4,media_clim(:,:), res)  ; create plot
     delete(res)
    frame (wks4)
     wks5=gsn_open_wks("png","std_OBS_CDS-TTC-IASI-B"+att)
    gsn_define_colormap(wks5,"NEO_div_vegetation_c")

      res = True                                    ; plot mods desired

     res@cnFillOn         = True               ; color Fill
     res@cnFillMode       = "RasterFill"       ; Raster Mode
     res@cnLinesOn        =  False             ; Turn off contour lines
     res@cnLineLabelsOn       =False
     ;resn@cnLabelBarEndStyle="ExcludeOuterBoxes"
     res@tiMainString         = "Standard Deviation "    ; plot title
     fmt = "%3.2f"
     res@gsnLeftString      = "[DU]"
;     res@gsnRightString     = "mean: "+sprintf(fmt,avg_clim1)+" std:"+sprintf(fmt,avg_std1)           ; plot center string

;     res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels 
     res@cnMinLevelValF       = -1               ; set min contour level
     res@cnMaxLevelValF       = 3.               ; set max contour level
     res@cnLevelSpacingF      = 0.3               ; set contour spacing
      plot5 = gsn_csm_contour_map(wks5,std_clim(:,:), res)  ; create plot
    frame (wks5)

end
