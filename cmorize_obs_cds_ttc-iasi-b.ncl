; #############################################################################
; ESMValTool CMORizer for 06TC_IASIB data
; #############################################################################
;
; Tier
;    Tier 3: restricted dataset.
;
; Source
;    https://cds.climate.copernicus.eu/cdsapp#!/dataset/
;    satellite-methane?tab=form
;
; Last access
;    20190311
;
; Download and processing instructions
;    Select Processing level "Level 3", variable "tropoz related variables", Sensor and
;    algorithm "MERGED and OBS4MIPS".
;    A registration is required to download the data.
;
; Modification history
;    20200429-irene_cionni: written.
;
; ############################################################################
loadscript(getenv("esmvaltool_root") + \
           "/esmvaltool/cmorizers/obs/interface.ncl")

begin

  ; Script name (for logger)
  DIAG_SCRIPT = "cmorize_obs_cds_06tc-iasib.ncl"

  ; Source name
  OBSNAME = "CDS-IASI-B"

  ; Tier
  TIER = 3

  ; Period
  YEAR1 = 2013
  YEAR2 = 2018

  ; Selected variable (standard name)
  VAR = (/"tropoz"/)

  ; Name in the raw data
  NAME = (/"tropoz"/)

  ; MIP
  MIP = (/"Amon"/)

  ; Frequency
  FREQ = (/"mon"/)

  ; CMOR table
  CMOR_TABLE = getenv("cmor_tables") + "/custom/CMOR_tropoz.dat"

  ; Type
  TYPE = "sat"

  ; Version
  VERSION = "L3"

  ; Global attributes
  SOURCE = https://cds.climate.copernicus.eu/cdsapp#!/dataset/satellite-ozone?tab=form
  REF = "Boynard et al., Atmos. Meas. Tech., 9, 4327–4353, 2016, " + \
    "doi:10.5194/amt-9-4327-2016."
  COMMENT = ""

end

begin

  ; Loop over variables
  do vv = 0, dimsizes(VAR) - 1

    log_info("Processing " + VAR(vv) + " (" + MIP(vv) + ")")

    #fname = input_dir_path + "OBS_" + OBSNAME + "_sat_L3_" + NAME(vv) + \
    #  "_200301-201812.nc"
    fname = systemfunc("ls "+ input_dir_path + "C3S_OZONE-L3-06TC-IASI_METOPB_CCI-*_LT09-fv0001.nc")

    setfileoption("nc", "MissingToFillValue", False)
    f = addfiles(fname, "r")
    output = f->surface_6km_ozone_column

    ; Format coordinates
    format_coords(output, YEAR1 + "0105", YEAR2 + "1231", FREQ(vv))

    ; Set variable attributes
    tmp = format_variable(output, VAR(vv), CMOR_TABLE(vv))
    delete(output)
    output = tmp
    delete(tmp)

    ; Calculate coordinate bounds
    bounds = guess_coord_bounds(output, FREQ(vv))

    ; Set global attributes
    gAtt = set_global_atts(OBSNAME, TIER, SOURCE, REF, COMMENT, CMOR_TABLE(vv))

    ; Output file
    DATESTR = YEAR1 + "01-" + YEAR2 + "12"
    fout = output_dir_path + \
      str_join((/"OBS", OBSNAME, TYPE, VERSION, \
                 MIP(vv), VAR(vv), DATESTR/), "_") + ".nc"

    ; Write variable
    write_nc(fout, VAR(vv), output, bounds, gAtt)
    delete(gAtt)
    delete(output)
    delete(bounds)

  end do

end
