/*-------1---------2---------3---------4---------5---------6---------7--
 The product is not provided commercially and all warranties,
 guarantees are expressly denied and as such you are to determine the
 suitability of the code for your own purposes. The code is not
 maintained or supported. 
 -----------------------------------------------------------------------

 Module Name     : GREGWT.SAS (macro)
 Date written    : August 1999
 Language used   : SAS
 Inputs          : SAS dataset of unit data to be weighted
                   plus one or more SAS dataset of benchmark info
 Outputs         : SAS dataset of unit data with weights
                   three SAS datasets of reports
                   optionally a SAS dataset of estimates & variances
 Parameters      :
 -----------------------------------------------------------------------
 UNITDSN = Name of dataset to be weighted
 OUTDSN  = Name for output weighted unit dataset
            Default _outdsn_
 BENOUT  = Prefix for report datasets on benchmark convergence.  First
            six characters only are used, followed by an integer suffix.
            There will be one such dataset for each benchmark dataset
            with suffixes 1,...
            Default value is benout (i.e dataset names benout1,... )
 BYOUT   = Name for report dataset on BY group convergence
            Default _byout_
 EXTOUT  = Name for report dataset of extreme units
            Default _extout_

 BY      = as for BY statement - optional
 STRATUM = Stratum - optional
 VARGRP  = Variance group - optional
            To get weighted residual variances,
            STRATUM and VARGRP must be specified
            and data must be sorted by BY STRATUM VARGRP
 GROUP   = Level for weighting of groups rather than units.
            Optional
            In integrated weighting, specifies the grouping level
            at which the calibration is applied.
            The input weight for a group is that of the first unit
            in the group, unless OPTIONS=amean or OPTIONS=hmean.
            All units in a group will have the same final weight.
 UNIT    = Other variables in the sort order below GROUP level.
            Optional.  Used in integrated weighting: the list
              BY STRATUM VARGRP GROUP UNIT
            must contain any grouping variable used in the
            BnGRP macro variables.  For the use of these
            macro variables see description below.

 ** Unit data MUST be sorted by &BY &STRATUM &VARGRP &GROUP &UNIT
 **  (although any of these can be left blank)

 INWEIGHT= Input weight (compulsory)
 or  INWT=
 REPID   = Gives the replicate identifier, a variable giving
            numbers 1 to m identifying the replicate a unit is in
            Use instead of setting up replicate input weights
            Optional
 INREPWTS= Lists 2 or more replicate input weights - if these are
            provided, REPID is ignored.  Optional

 WEIGHT  = Name for output weight, default is &INWEIGHT
 or    WT=
 REPWTS  = Name for output replicate weights, default &INREPWTS

 ID      = Output dataset will include variables used by the
            macro plus any additional variables named in ID.
            To get all variables specify ID=_ALL_
 PENALTY = Variable used to specify a weighted distance function
            - the distance contributed by this unit or group
            is multiplied by the PENALTY value for the unit,
            or the PENALTY value of the first unit in the group
            A high PENALTY value makes the weight less subject
            to change than that of other units
            Default is to use 1

 Specifications for up to 30 datasets of benchmarks (n in 1-30):
 BnDSN   = Name of n-th dataset containing benchmarks
 BnCLASS = Variables defining category for these benchmarks
 BnVAR   = Variables on UNITDSN to be totaled to the benchmarks
            (default is to use weighted counts of units)
 BnTOT   = Variables on BnDSN giving the benchmarks
 BnREPS  = List of replicate benchmark totals
            - blank if this feature not used
            - otherwise lists <number of replicate weights>
              variables for each benchmark total
              e.g. B1TOT=psntot hhldtot, B1REPS=pt1-pt30 ht1-ht30
 BnRVAR  = List of replicate variables to be totalled to add to
           the replicate benchmarks
            - blank if this feature not used
            - otherwise lists <number of replicate weights>
              variables for each benchmark total
 BnGRP   = Used in integrated weighting.  Names a variable listed
            in &GROUP &UNITID that gives the grouping level at which
            this benchmark applies.
            Only the first record in the group is used in totals
            eg. if BnGRP=hhold then, for this benchmark,
            values from the first unit in the hhold are assumed
            to be hhold records and are used in totals.

 LOWER   = Smallest value which weights can take
            or (if followed by a % sign eg LOWER=50%)
            the smallest percentage that weights can be multiplied by
            (but if LOWER > 95% then 95% is used).
           The value may be a SAS expression involving variables
            available to the macro (can use ID to include them)
            eg. LOWER=max(1,0.7*weight)
 UPPER   = Largest value which weights can take
            or (if followed by a % sign eg UPPER=200%)
            the largest percentage that weights can be multiplied by
            (but if UPPER < 105% then 105% is used).

 OPTIONS = List of options - possible values are:
            NOPRINT: turn off printing of output reports
            BADPRINT:only print benchmark and BY group data
                     where a benchmark was not met
                     (also defaults EXTNO to 5)
            NOLOG  : turn off log information about BY groups
            NOTES  : turn on notes
                     (default is to turn most notes to log off)
            EXP or EXPONENTIAL : Use exponential distance function
                     instead of the default linear distance
            FIRSTWT: report on first weight (i.e. for iteration 1)
                     in addition to final weight
            REPS   : attach replicate estimates to any table produced
                     (use names est_1-est_n or names given by OUTREPS)
            UNIV   : print distribution of weights and weight
                     changes from PROC UNIVARIATE
            DEBUG  : do not delete intermediate datasets
            HMEAN  : Input weight for a group is the harmonic
                     mean of unit input weights
            AMEAN  : Input weight for a group is the
                     arithmetic mean of unit input weights
              Default input weight for a group (if neither HMEAN
              or AMEAN are specified) is the input weight from the
              first unit in the group

 MAXITER = Maximum numer of iterations in restricted version
            Default is 10
 EPSILON = Convergence criterion: how closely must benchmarks
            be met, expressed as the discrepancy of estimate
            from benchmark divided by benchmark

 Specification for an output table of estimates and variances:
 OUT     = Name for output dataset containing table
 CLASS   = Class variables defining categories for which
            estimates will be produced
            For ratio estimates, CLASS defines the categories
            to be used as denominators
            Estimates for totals across a class variable can be
            requested by giving the class variables prefixed by a #
            eg. CLASS = state #sex  gives estimates for states
            as well as for state by sex.
 SUBCLASS= For ratio estimates, SUBCLASS defines the categories
            used as numerators
 VAR     = List of continuous variables to be estimated for.
            For ratio estimates, these variables are used in the
            numerator only.
 DENOM   = For mean or ratio estimates:
            - contains a list of variables used as denominators
              for the corresponding variables in VAR.
            - If DENOM lists fewer variables than VAR, the last
              variable in DENOM is used for the extra VAR members.
            - If more variables in DENOM than VAR the macro stops.
            - The keyword _one_ signifies using 1 as the denominator,
              giving estimates of mean
 OUTGRP  = Used in integrated weighting.  Names a variable listed
            in &GROUP &UNITID that gives the grouping level at which
            the table is being produced.
            Only the first record in the group is used in totals
            eg. if OUTGRP=hhold then values from the first unit in the
            hhold are hhold records and are to be used in totals.

 OUTREPS = Replicate estimates will be attached to the table
             if OUTREPS is given (in which case OUTREPS gives names
             for the variables).
 NPREDICT= Number of predicted values to be attached to unit data
            on &OUTDSN.  Predictions will be named
            hat_1-hat_&NPREDICT and (for level estimates)
            will correspond to the first &NPREDICT elements of the
            output tables.
            hat_n is the prediction under the regression model
            of the contribution of the unit to cell n of the
            output table.
            If tables are not specified, NPREDICT has no effect.
            (Note that for a table of ratio estimates or means
            the predictions of numerator and denominator
            level estimates are produced )
 WROUT   = Name for file of weighted residuals for tabulated estimates
            Default is to not produce this file
 WRLIST  = List of variable names to contain the weighted residuals.
            Residuals are output in the same order as the output tables.
            WRLIST is only used if WROUT is specified.
            Default is wr_1 i.e. only output the first residual
 WRWEIGHT= True final weight for use in tabulations and weighted
            residual calculations.  This is only required when the
            weighted residual calculations are being re-done using a
            different benchmark specification than that used for the
            original weighting.  This could be done to minimise
            calculations (eg. reduce to a post-stratified ratio case),
            or because the original weighting scheme is unknown.

 TITLELOC= On output prints, the line at which GREGWT titles
            should appear (using a title<n> statment)
            leaving pre-existing titles on previous lines intact
            Default is the first line (i.e. a title statement)
            _NONE_ avoids printing any GREGWT titles
 REPORTID= Unit identifiers to be used on extreme values report
            (default uses as many as possible of the variables listed in
             &BY &B1CLASS... &STRATUM &VARGRP &GROUP &UNIT &B1VAR...)

 MAXSPACE= Space available in kilobytes (roughly) for table calcs
            (RAM, not hard drive space). Usually leave at 500 -
            there is no advantage in specifying more unless
            it is needed.
            Program requires for each table category (in bytes)
             total length of CLASS and SUBCLASS variables
               + 8*(number of replicates + 1)
                  *(number of VAR and DENOM variables)
               + some extra
 REPWTMAX= Maximum number of replicate weights, default 5000
            - used only with REPID, values over REPWTMAX are
            considered invalid values of the REPID variable
 EXTNO   = Number of extreme values of each type to be printed
 LINESIZE= Number of characters per line on output file.
           ONLY needed if the version of SAS does not support SYSFUNC
           or to fool the extreme values report into changing the number
           of id variables it prints (it allows 8 characters/variable).
 RUNID   = Not used in this version
 STEP    = Not used in this version
 -----------------------------------------------------------------------

 Called by       :
 Calls           :
 Overview        : A generalised regression weighting macro.

   GREGWT takes a unit dataset and one or more datasets of
     benchmarks, and outputs a weighted file calibrated so
     that the weights add to the benchmarks.
   GREGWT will perform replicated weighting if required
   GREGWT also outputs files required in order to
     produce weighted residual estimates of variances.
   GREGWT incorporates optional production of a table,
      with "weighted residual" and/or "jackknife" variances.

   Other macros in this series: (currently experimental)
   The macro TABLE produces jackknife estimates of variance,
     using the replicate weights
   The macro WRVAR enables production of weighted residuals estimates
     of variance for complex estimates

 Special Instructions: (Eg compiling/datamodel source/priming program)

 Documentation: GREGWT Users Guide (on ABS IT client guide)

 Copyright (c) 1999, Australian Bureau of Statistics
*----------------------------------------------------------------------*
 Update history:
 Vsn  dd/mm/yyyy Person Change
 ---- ---------- ------ ------
 1.00 23/08/1999 BELLPH Copied from gregtest/gregwt8.sas (version 0.8)
 1.01 02/09/1999 VIVIAN Replaced | characters with ! (OR, concatenation)
 1.02 02/09/1999 VIVIAN Replaced [&] with EBCDIC characters AD & BD in
                        format okfmt (which uses formats as values)
                        (put them back again on LAN version)
 2.0  21/06/2000 BELLPH Starting with version 1.00 on LAN:
                        Use !! for concatenation, OR for or
                        Remove the format that used square braces
                        Remove PRINT option, introduce DEBUG option
                        New ERROR if insufficient space for benchmarks
                        Add WROUT and WRLIST function
                        Add WRWEIGHT function
                        Identify post-stratified ratio estimator case,
                        and use this to reduce computation and memory
                        use (since matrices are then diagonal)
                        Simplify matrix decomposition algorithm
                        Add OUTREPS function
                        Add REPORTID parameter
                        Change reports produced to remove first weight
                        Add count of contributors to benchmarks report
                        Produce a separate report dataset for each
                        benchmark, with names prefixed by &BENOUT
                        Add FIRSTWT option
                        Add REPS option
                        Move printing of reports to generic macros
                        Add OUTGRP for grouping level of table
 2.01 08/09/2000 BELLPH Change test for missing dataset to HSF standard
                        Fix bug in applying AMEAN and HMEAN options
 2.02 15/09/2000 BELLPH Corrected bug by sorting proc contents output
 2.03 10/10/2000 BELLPH Correct bug in naming of BENOUT datasets
 2.04 02/11/2000 BELLPH Correct bug in HMEAN option for zero weights
 2.05 03/11/2000 BELLPH Correct bug in EXP option by changing DISTANCE
 2.06 06/07/2001 BELLPH Add NEWWT to %LOCAL statement
                        Correct bug with VAR list for weighted residuals
                        Change default value of REPORTID parameter
                        At finish, resets notes/nonotes to initial value
                        Avoid naming a variable _freq_ in main data step
 2.07 24/09/2001 BELLPH Correct bug in BY groups by setting cwncat&B = 0
                        Correct for SUBSTR problem in GREGPBEN macro
 2.08 31/07/2002 BELLPH Change length of names to 32 characters for
                        compatibility with SAS V8 *;
 2.09 20/08/2002 BELLPH Fix extreme value printout for uc and lc names
 2.10 24/09/2002 BELLPH Include error message when calcs run out of room

 Known problems with version 2.10:
 1.  Early versions of SAS do not allow %SYSFUNC(getoption(linesize))
     The workaround is to specify the parameter LINESIZE.
*--------1---------2---------3---------4---------5---------6---------7*/

%MACRO GREGWT
(UNITDSN=,OUTDSN=,BENOUT=,BYOUT=,EXTOUT=,RUNID=,STEP=
,BY=,STRATUM=,VARGRP=, GROUP=,UNIT=,INWEIGHT=,INWT=,REPID=
,REPWTS=,INREPWTS=,WEIGHT=,WT=,ID=,PENALTY=
,B1DSN= ,B1GRP= ,B1CLASS= ,B1VAR= ,B1TOT= ,B1REPS=,B1RVAR=
,B2DSN= ,B2GRP= ,B2CLASS= ,B2VAR= ,B2TOT= ,B2REPS=,B2RVAR=
,B3DSN= ,B3GRP= ,B3CLASS= ,B3VAR= ,B3TOT= ,B3REPS=,B3RVAR=
,B4DSN= ,B4GRP= ,B4CLASS= ,B4VAR= ,B4TOT= ,B4REPS=,B4RVAR=
,B5DSN= ,B5GRP= ,B5CLASS= ,B5VAR= ,B5TOT= ,B5REPS=,B5RVAR=
,B6DSN= ,B6GRP= ,B6CLASS= ,B6VAR= ,B6TOT= ,B6REPS=,B6RVAR=
,B7DSN= ,B7GRP= ,B7CLASS= ,B7VAR= ,B7TOT= ,B7REPS=,B7RVAR=
,B8DSN= ,B8GRP= ,B8CLASS= ,B8VAR= ,B8TOT= ,B8REPS=,B8RVAR=
,B9DSN= ,B9GRP= ,B9CLASS= ,B9VAR= ,B9TOT= ,B9REPS=,B9RVAR=
,B10DSN=,B10GRP=,B10CLASS=,B10VAR=,B10TOT=,B10REPS=,B10RVAR=
,B11DSN=,B11GRP=,B11CLASS=,B11VAR=,B11TOT=,B11REPS=,B11RVAR=
,B12DSN=,B12GRP=,B12CLASS=,B12VAR=,B12TOT=,B12REPS=,B12RVAR=
,B13DSN=,B13GRP=,B13CLASS=,B13VAR=,B13TOT=,B13REPS=,B13RVAR=
,B14DSN=,B14GRP=,B14CLASS=,B14VAR=,B14TOT=,B14REPS=,B14RVAR=
,B15DSN=,B15GRP=,B15CLASS=,B15VAR=,B15TOT=,B15REPS=,B15RVAR=
,B16DSN=,B16GRP=,B16CLASS=,B16VAR=,B16TOT=,B16REPS=,B16RVAR=
,B17DSN=,B17GRP=,B17CLASS=,B17VAR=,B17TOT=,B17REPS=,B17RVAR=
,B18DSN=,B18GRP=,B18CLASS=,B18VAR=,B18TOT=,B18REPS=,B18RVAR=
,B19DSN=,B19GRP=,B19CLASS=,B19VAR=,B19TOT=,B19REPS=,B19RVAR=
,B20DSN=,B20GRP=,B20CLASS=,B20VAR=,B20TOT=,B20REPS=,B20RVAR=
,B21DSN=,B21GRP=,B21CLASS=,B21VAR=,B21TOT=,B21REPS=,B21RVAR=
,B22DSN=,B22GRP=,B22CLASS=,B22VAR=,B22TOT=,B22REPS=,B22RVAR=
,B23DSN=,B23GRP=,B23CLASS=,B23VAR=,B23TOT=,B23REPS=,B23RVAR=
,B24DSN=,B24GRP=,B24CLASS=,B24VAR=,B24TOT=,B24REPS=,B24RVAR=
,B25DSN=,B25GRP=,B25CLASS=,B25VAR=,B25TOT=,B25REPS=,B25RVAR=
,B26DSN=,B26GRP=,B26CLASS=,B26VAR=,B26TOT=,B26REPS=,B26RVAR=
,B27DSN=,B27GRP=,B27CLASS=,B27VAR=,B27TOT=,B27REPS=,B27RVAR=
,B28DSN=,B28GRP=,B28CLASS=,B28VAR=,B28TOT=,B28REPS=,B28RVAR=
,B29DSN=,B29GRP=,B29CLASS=,B29VAR=,B29TOT=,B29REPS=,B29RVAR=
,B30DSN=,B30GRP=,B30CLASS=,B30VAR=,B30TOT=,B30REPS=,B30RVAR=
,CLASS=,SUBCLASS=,VAR=,DENOM=,OUT=,OUTREPS=,OUTGRP=,MAXSPACE=500
,OPTIONS =,TITLELOC=,REPORTID=,REPORTVS=
,MAXITER=,EPSILON =,LOWER=,UPPER=,REPWTMAX=200, EXTNO=
,NPREDICT=,WROUT=,WRLIST=,WRWEIGHT=,LINESIZE=);

%LOCAL XOPTIONS NOTESOFF MACID NUMALPHA DISTANCE CWDIST2 LASTGRP
 LOCODE UPCODE ELAPTIME TEMP WORD I B CWFIRST
 WTDRES CK_TRASH GO_END EXTRA PRINTREP CWTIT CWTIT2 CWTIT3
 BADPRINT EXP NEWWT ORIGNOTE ;

run ; %* So any preceding data step gives notes *;
%* Turn off notes on log *;

%* ORIGNOTE gives the NOTES or NONOTES option before the GREGWT call *;
%IF %LENGTH(&LINESIZE)=0 %THEN %DO ;
 %LET ORIGNOTE=%SYSFUNC(getoption(notes)) ; %* Store NOTES or NONOTES *;
 %LET LINESIZE=%SYSFUNC(getoption(linesize)) ; %* Store linesize *;
%END ;
%ELSE %LET ORIGNOTE=NOTES ; %* Assume that %SYSFUNC does not work - so
                               default to NOTES *;
%LET XOPTIONS = %UPCASE(XXXXXXXX &OPTIONS X) ;
 %* Version of OPTIONS string that is long enough to use %INDEX *;
%IF %INDEX(&XOPTIONS,%STR( NOTES )) = 0
%THEN %LET NOTESOFF = %STR(options nonotes ;) ;
&NOTESOFF

data _null_ ; %* Store the time in ELAPTIME (to monitor elapsed time) *;
  call symput("ELAPTIME",put(datetime(),32.)) ;
run ;
%LET MACID=GREGWT ; %* Name of this macro *;
%LET NUMALPHA=123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ ;

%* CWTIT, CWTIT2 and CWTIT3 will be used instead of title statements
   for up to three lines of GREGWT titles *;
%IF %UPCASE(&TITLELOC)=_NONE_ %THEN %DO ;
 %LET CWTIT=* ; %LET CWTIT2=* ; %LET CWTIT3=* ;
%END ;
%ELSE %DO ;
 %LET CWTIT=title&TITLELOC ;
 %IF %BQUOTE(&TITLELOC)= %THEN %LET TITLELOC = 1 ;
 %ELSE %LET TITLELOC=%SUBSTR(&TITLELOC,1,1) ;
 %LET CWTIT2 = title%EVAL(&TITLELOC+1) ;
 %LET CWTIT3 = title%EVAL(&TITLELOC+2) ;
%END ;

%********* MACROS used by the main macro ***********************;

%MACRO GREGPEXT(DATA=,EXTNO=,ID=,OPTIONS=,FIRST=
,TITLELOC=,WTFORMAT=) ;
%* This macro prints the EXTOUT dataset in the format
   required *;

 %LOCAL XOPTIONS CWFIRST ;
 run ; %* So any preceding data step gives notes *;
 %* Turn off notes on log *;
 %LET XOPTIONS = %UPCASE(XXXXXXXX &OPTIONS X) ;
 %IF %INDEX(&XOPTIONS,%STR( NOTES )) = 0
 %THEN %LET NOTESOFF = %STR(options nonotes ;) ;
 &NOTESOFF

 %IF (&FIRST=1) OR (&FIRST=Y) %THEN %LET FIRST = 1 ;
 %ELSE %LET FIRST = 0 ;
 %IF %BQUOTE(&DATA)= %THEN %LET DATA=_extout_ ;
 %IF &EXTNO = %THEN %LET EXTNO = 5 ;
 %IF %BQUOTE(&WTFORMAT)= %THEN %LET WTFORMAT=6.1 ;
 %IF %UPCASE(&TITLELOC)=_NONE_ %THEN %DO ;
  %LET CWTIT=* ; %LET CWTIT2=* ; %LET CWTIT3=* ;
 %END ;
 %ELSE %DO ;
  %LET CWTIT=title&TITLELOC ;
  %IF %BQUOTE(&TITLELOC)= %THEN %LET TITLELOC = 1 ;
  %ELSE %LET TITLELOC=%SUBSTR(&TITLELOC,1,1) ;
  %LET CWTIT2 = title%EVAL(&TITLELOC+1) ;
  %LET CWTIT3 = title%EVAL(&TITLELOC+2) ;
 %END ;
 %IF &EXTNO > 0 %THEN %DO ;
  proc format ;
   value sevfmt
    -8  ="Negative weight"
    -7  ="Low weight, large change, adjusted:"
    -6  ="Low weight, large change:"
    -5  ="Low weight, adjusted:"
    -4  ="Low weight:"
   -3,3 ="Large change, adjusted:"
   -2,2 ="Adjusted:"
    -1  ="Large downward change:"
     1  ="Large upward change:"
     4  ="High weight:"
     5  ="High weight, adjusted:"
     6  ="High weight, large change:"
     7  ="High weight, large change, adjusted:" ;
  run ;

  data cwext(drop=_count_) ck_dsn(keep=severity _count_);
   set &DATA ;
   by severity ;
   if first.severity then _count_ = 0 ;
   _count_ + 1 ;
   if _count_ <= &EXTNO then output cwext ;
   if last.severity then output ck_dsn ;
  run ;
  data cwext ;
   merge cwext ck_dsn ;
   by severity ;
  run ;
  proc print data=cwext split='@' label ;
   &CWTIT "Extreme units (top &EXTNO in each type)" ;
   label _inwt_="input@weight"
   %IF &FIRST %THEN _regwt_="first@weight" ;
       _finwt_="final@weight"
       _wtrat_="final@/input"
       severity="type"
       _count_="number";
   format severity sevfmt. _finwt_ _inwt_
          %IF &FIRST %THEN _regwt_ ;
          &WTFORMAT _wtrat_ 5.3 ;
   by severity _count_ ;
   %IF &EXTNO>15 %THEN pageby _count_ ;;
   %IF %BQUOTE(&ID)^= %THEN id &ID ;;
   var _inwt_ _finwt_
   %IF &FIRST %THEN _regwt_ ;
       _wtrat_ ;
  run ;
  proc catalog c=formats et=format;
   delete sevfmt ;
  run ;
  quit ;
 %END ;
 options notes ;
%MEND GREGPEXT ;

%MACRO GREGPBEN(DATA=,BY=,ID=,OPTIONS=,FIRST=,TITLELOC=,TYPE=1) ;
%* This macro prints the BENOUTn dataset(s) in the format
   required *;

 %LOCAL XOPTIONS CWRULER ;
 run ; %* So any preceding data step gives notes *;
 %* Turn off notes on log *;
 %LET XOPTIONS = %UPCASE(XXXXXXXX &OPTIONS X) ;
 %IF %INDEX(&XOPTIONS,%STR( NOTES )) = 0
 %THEN %LET NOTESOFF = %STR(options nonotes ;) ;
 &NOTESOFF

 %IF (&FIRST=1) OR (&FIRST=Y) %THEN %LET FIRST = 1 ;
 %ELSE %LET FIRST = 0 ;
 %IF %BQUOTE(&DATA)= %THEN %LET DATA=benout1 ;
 %IF %UPCASE(&TITLELOC)=_NONE_ %THEN %DO ;
  %LET CWTIT=* ; %LET CWTIT2=* ; %LET CWTIT3=* ;
 %END ;
 %ELSE %DO ;
  %LET CWTIT=title&TITLELOC ;
  %IF %BQUOTE(&TITLELOC)= %THEN %LET TITLELOC = 1 ;
  %ELSE %LET TITLELOC=%SUBSTR(&TITLELOC,1,1) ;
  %LET CWTIT2 = title%EVAL(&TITLELOC+1) ;
  %LET CWTIT3 = title%EVAL(&TITLELOC+2) ;
 %END ;
 %LET BADPRINT = (%INDEX(&XOPTIONS,%STR( BADPRINT ))>0) ;

 data cwrep&B(drop=cwi) ;
   set &DATA ;
   %* Produce formatted versions of totals variables *;
   array cw_est{*} _bench_ _best_ _iest_ %IF &FIRST %THEN _rest_ ;;
   array cwxest{*} $ 7 cwbench cwbest cwiest %IF &FIRST %THEN cwrest ;;
   do cwi = 1 to dim(cw_est) ;
    if cwi > 1 &
     abs(cw_est{cwi} - _bench_) < 0.5 then cwxest{cwi} = '   ..  ' ;
    else if (-9999999.5 <= cw_est{cwi} < -999.5)
         or (999.5 < cw_est{cwi} <= 9999999.5)
         then cwxest{cwi}=put(cw_est{cwi},7.) ;
    else if (-999.5 <= cw_est{cwi} < -0.995)
         or (0.995 < cw_est{cwi} <= 999.5)
         then cwxest{cwi}=put(cw_est{cwi},7.3) ;
    else cwxest{cwi}=put(cw_est{cwi},best7.) ;
   end ;
   if _bench_ <= 0.5*_iest_ then cwvs ='<<' ;
   else if _bench_ <= 0.9*_iest_ then cwvs ='< ' ;
   else if _iest_ <= 0.5*_bench_ then cwvs ='>>' ;
   else if _iest_ <= 0.9*_bench_ then cwvs ='> ' ;
   else cwvs ='  ' ;

  run ;

%IF %BQUOTE(&TYPE) ^= 2 %THEN %DO ;
  proc print data=cwrep&B
%IF &BADPRINT %THEN (where=(cwbest^='   ..  ')) ;
   label split='@';
    &CWTIT
"Estimate to benchmark &B comparison" ;
    &CWTIT2
".. indicates estimate = benchmark" ;
    %IF %BQUOTE(&BY)^= %THEN %STR(by &BY ;) ;
    %IF %BQUOTE(&ID)^= %THEN id &ID ;;
    label _count_="count"
          cwbench="bench@-mark"
          cwiest="input@weight"
  %IF &FIRST %THEN cwrest="first@weight" ;
          cwbest="final@weight"
          cwvs="vs" ;
    format _crit_ best6. ;
    var _count_ cwbench cwvs cwiest
        %IF &FIRST %THEN cwrest ;
        cwbest ;
  run ;
%END ;
%ELSE %DO ;
 %LET CWRULER=Rep. no.@_123456789012345678901234567890 ;
 %LET CWRULER=%SUBSTR(&CWRULER,1,10+&NWREPORT) ;
  proc print data=cwrep&B
   %IF &BADPRINT %THEN (where=(cwbest^='   ..  ')) ;
   label split="@";
      &CWTIT
"Convergence of replicates, benchmark &B" ;
      &CWTIT2
"  .=ok, I=impossible to meet, N=not converged  " ;
     %IF %BQUOTE(&BY)^= %THEN %STR(by &BY ;) ;
     %IF %BQUOTE(&ID)^= %THEN id &ID ;;
      label _report_="&CWRULER" ;
      var _report_ ;
  run ;
%END ;

%MEND GREGPBEN ;

%MACRO GREGPBY(DATA=,BYVARS=,OPTIONS=,GROUP=,TITLELOC=) ;
%* This macro prints the BYOUT dataset in the format required *;

 %LOCAL XOPTIONS ;
 run ; %* So any preceding data step gives notes *;
 %* Turn off notes on log *;
 %LET XOPTIONS = %UPCASE(XXXXXXXX &OPTIONS X) ;
 %IF %INDEX(&XOPTIONS,%STR( NOTES )) = 0
 %THEN %LET NOTESOFF = %STR(options nonotes ;) ;
 &NOTESOFF

 %IF %BQUOTE(&DATA)= %THEN %LET DATA=_byout_ ;
 %IF %UPCASE(&TITLELOC)=_NONE_ %THEN %DO ;
  %LET CWTIT=* ; %LET CWTIT2=* ; %LET CWTIT3=* ;
 %END ;
 %ELSE %DO ;
  %LET CWTIT=title&TITLELOC ;
  %IF %BQUOTE(&TITLELOC)= %THEN %LET TITLELOC = 1 ;
  %ELSE %LET TITLELOC=%SUBSTR(&TITLELOC,1,1) ;
  %LET CWTIT2 = title%EVAL(&TITLELOC+1) ;
  %LET CWTIT3 = title%EVAL(&TITLELOC+2) ;
 %END ;
 %LET BADPRINT = (%INDEX(&XOPTIONS,%STR( BADPRINT ))>0) ;

 proc print data=&DATA
%IF &BADPRINT %THEN (where=(_result_^='C')) ;
  label split='@' ; ;
  &CWTIT 'Report on overall convergence for BY groups' ;
  &CWTIT2 "C=met benchmarks, N=not converged, I=impossible" ;
  &CWTIT3 "R=met benchmarks but a replicate did not" ;
  label _iters_='iters@used'
    _result_='result@code' ;
  id &BYVARS _iters_ _result_ ;
  %IF %BQUOTE(&GROUP)^= %THEN %DO ;
   label
    _freq_='!----@non-@nils'
    _nilwt_=' unit@@nils'
    _negin_='count@-ve@input'
    _negwt_='----!@-ve@final' ;
   label
    _gfreq_='!----@non-@nils'
    _gnilwt_='group@@nils'
    _gnegin_='count@-ve@input'
    _gnegwt_='----!@-ve@final' ;
   var _freq_ _nilwt_ _negin_ _negwt_
    _gfreq_ _gnilwt_ _gnegin_ _gnegwt_ ;
   sum _freq_ _nilwt_ _negin_ _negwt_
    _gfreq_ _gnilwt_ _gnegin_ _gnegwt_ ;
  %END ;
  %ELSE %DO ;
   label _nilwt_='nils'
    _freq_='non-@nils'
    _negin_='-ve@input'
    _negwt_='-ve@final' ;
   var _freq_ _nilwt_ _negin_ _negwt_ ;
   sum _freq_ _nilwt_ _negin_ _negwt_ ;
  %END ;
 run ;

%MEND GREGPBY ;

%LOCAL LASTBY BYVARS PUTBY BYCODE NBYVARS
BYVAR1 BYVAR2 BYVAR3 BYVAR4 BYVAR5 BYVAR6 BYVAR7 BYVAR8 BYVAR9 ;
%MACRO HANDLEBY(BY=, PUTBLANK="all obs") ;
%* Produces macro variables LASTBY, BYVARS, PUTBY and BYCODE *;
%* Normally stored as 'O:\sasprogs\utility\handleby.sas',
   see there for documented version *;

%LOCAL I WORD ;
%LET LASTBY = _last_ ;
%LET BYVARS = ;
%LET PUTBY = ;
%LET BYCODE = ;
%LET NBYVARS = 0 ;
%IF %QUOTE(&BY) ^= %THEN %DO ;
  %DO I = 1 %TO 20 ;
    %LET WORD = %SCAN(&BY,&I) ;
    %* Change for SAS V8 to accomodate names up to 32 char long *;
    %IF %LENGTH(&WORD) = 0 %THEN %LET I = 20 ;
    %ELSE %IF (%BQUOTE(&WORD) ^= DESCENDING)
            & (%BQUOTE(&WORD) ^= NOTSORTED) %THEN %DO ;
      %LET NBYVARS = &I ;
      %LET BYVAR&I = &WORD ;
      %LET LASTBY = LAST.&WORD ;
      %LET BYVARS = &BYVARS &WORD ;
      %LET PUTBY = %STR(&PUTBY "&WORD=" &WORD " ") ;
    %END ;
  %END ;
  %LET BYCODE = %STR(by &BY ;) ;
%END ;
%ELSE %LET PUTBY = &PUTBLANK ;
%MEND HANDLEBY ;

%LOCAL CWTESTPR ;
%MACRO TESTPR(LIST,NPRINTS=50) ;
%* Used for diagnostic prints within a data step *;
  %LOCAL WORD ;
  %LET CWTESTPR = %EVAL(&CWTESTPR+1) ;
  cwpr&CWTESTPR + 1 ;
  drop cwpr&CWTESTPR ;
  if cwpr&CWTESTPR <= &NPRINTS then do ;
    %DO I = 1 %TO 50 ;
      %LET WORD=%SCAN(&LIST,&I,%STR( )) ;
      %IF %BQUOTE(&WORD)= %THEN %LET I = 50 ;
      %ELSE %DO ;
        cwtptemp = &WORD ;
        put "&WORD=" cwtptemp @ ;
      %END ;
    %END ;
    put ;
  end ;
%MEND ;
%LOCAL CWPRINT ;
%MACRO PR(DSN,TIT) ;
  %* Prints dataset if CWPRINT = 1 *;
  %IF &CWPRINT %THEN %DO ;
    proc print data=&DSN ;
      %IF %BQUOTE(&TIT)= %THEN &CWTIT "&DSN" ;
      %ELSE &CWTIT "&DSN, &TIT" ;;
    run ;
  %END ;
%MEND PR ;

%MACRO CHECKERR(BOOLEAN,MESSAGE) ;
%* Reports an error message if the BOOLEAN is true
   Sets the macro variable GO_END to 1 to show error
*;
  %IF (&BOOLEAN) %THEN %DO ;
    %LET GO_END =1;
    %IF %QUOTE(&MESSAGE)^= %THEN %DO ;
%PUT ***********************************************************;
%PUT ERROR: &MESSAGE ;
%PUT ***********************************************************;
    %END ;
  %END ;
%MEND CHECKERR ;

%MACRO CK_TRASH(DSN) ;
%* Used for disposing of temporary datasets produced by the macro
   If a dataset is named, adds it to the list in &CK_TRASH
   If blank, deletes all the datasets in the list &CK_TRASH
*;
  %IF %BQUOTE(&DSN) ^= %THEN %DO ;
    %LET DSN = %UPCASE(&DSN) ;
    %IF %INDEX(%STR( &CK_TRASH ),%STR( &DSN )) = 0
    %THEN %LET CK_TRASH = &CK_TRASH &DSN ;
  %END ;
  %ELSE %IF %BQUOTE(&CK_TRASH)^= %THEN %DO ;
    proc datasets ddname=work nolist;
      delete &CK_TRASH ;
    run ;
    quit;
    %LET CK_TRASH = ;
  %END ;
%MEND CK_TRASH;
%************* End of macros used by the main macro ************;

%* Now set up default values for macro variables *;
%LET GO_END= ;
%LET CK_TRASH= ;

%IF %BQUOTE(&INWEIGHT)= %THEN %LET INWEIGHT=&INWT ;
%IF %BQUOTE(&WEIGHT)= %THEN %LET WEIGHT = &WT ;

%HANDLEBY(BY=&BY &STRATUM &VARGRP &GROUP &UNIT)
%LET UNITCODE=&BYCODE ;
%HANDLEBY(BY=&BY &STRATUM &VARGRP &GROUP)
%LET GRPCODE = &BYCODE ;
%IF %BQUOTE(&GROUP)^= %THEN %LET LASTGRP = &LASTBY ;
%ELSE %LET LASTGRP = 1 ;
%HANDLEBY(BY=&BY &STRATUM &VARGRP)
%LET LASTVG =&LASTBY ;
%HANDLEBY(BY=&BY &STRATUM)
%LET LASTSTRA = &LASTBY ;
%HANDLEBY(BY=&BY) %* Produces &BYVARS &BYCODE &PUTBY &LASTBY *;

%******************** Defaults *********************************;
%IF (%INDEX(&XOPTIONS,%STR( EXP )))
  OR (%INDEX(&XOPTIONS,%STR( EXPONENTIAL )))
  OR (%INDEX(&XOPTIONS,%STR( EXPA )))
  %THEN %LET EXP = 1 ; %* Exponential *;
  %ELSE %LET EXP = 0 ; %* Linear *;
%* Note that exp() is undefined in SAS for large values *;
%IF &EXP %THEN %LET DISTANCE = exp(min(100,cwcutwt{_k_})) ;
  %ELSE %LET DISTANCE = (1 + cwcutwt{_k_}) ;
%IF (%INDEX(&XOPTIONS,%STR( EXP )))
  OR (%INDEX(&XOPTIONS,%STR( EXPONENTIAL )))
  %THEN %LET CWDIST2 = cwcutwt{_k_} ;
  %ELSE %LET CWDIST2 = cwgrpwt{_k_} ;
%LET CWFIRST = %EVAL(%INDEX(&XOPTIONS,%STR( FIRSTWT )) > 0) ;

%IF %BQUOTE(&MAXITER)= %THEN %LET MAXITER = 10 ;
%IF (0&MAXITER<=1) OR ((%BQUOTE(&UPPER&LOWER)=) & ^&EXP)
%THEN %LET MAXITER = 0 ;
%* MAXITER = 0 is most efficient way to run a single iteration *;

%IF (&MAXITER=0) OR (%BQUOTE(&UPPER)=) %THEN %LET UPPER=1E12 ;
%IF (&MAXITER=0) OR (%BQUOTE(&LOWER)=) %THEN %LET LOWER=-1E12 ;
%IF %BQUOTE(&EPSILON)= %THEN %LET EPSILON=0.001 ;
%IF %BQUOTE(%UPCASE(&ID))=_ALL_ %THEN %DO ;
  %LET ID = ;
  %LET KEEPID = 0 ;
%END ;
%ELSE %LET KEEPID = 1 ;

%IF %BQUOTE(&WEIGHT)= %THEN %LET WEIGHT = &INWEIGHT ;
%IF %BQUOTE(&INWEIGHT)= %THEN %LET INWEIGHT = &WEIGHT ;
%IF %BQUOTE(&INWEIGHT)= %THEN %CHECKERR(1,
 No input weight variable defined) ;
%LET INWEIGHT = %SCAN(&INWEIGHT,1,%STR( -)) ; %* Only first variable *;
%LET WEIGHT = %SCAN(&WEIGHT,1,%STR( -)) ; %* Only first variable *;
%IF (%BQUOTE(&INREPWTS)=) & (%BQUOTE(&REPID)=)
%THEN %LET INREPWTS = &REPWTS ;
%IF %BQUOTE(&REPWTS)= %THEN %LET REPWTS = &INREPWTS ;
%IF %BQUOTE(&WRWEIGHT)= %THEN %LET NEWWT = cwnewwt{0} ;
%ELSE %LET NEWWT = &WRWEIGHT ;

%LOCAL BENPREF BENSUFF ;
%* BENPREF is the dataset name part of BENOUT *;
%* BENSUFF is any trailing dataset options eg (drop=sex)  *;
%IF %BQUOTE(&BENOUT)= %THEN %LET BENPREF=benout ;
%ELSE %LET BENPREF = %SCAN(&BENOUT,1,%STR(() )) ;
%IF %LENGTH(&BENOUT)>%LENGTH(&BENPREF)
%THEN %LET BENSUFF=%SUBSTR(&BENOUT,%LENGTH(&BENPREF)+1) ;
%ELSE %LET BENSUFF = ;
%LET TEMP = %EVAL(6 + %INDEX(&BENPREF,%STR(.))) ;
%IF %LENGTH(&BENPREF)>&TEMP
%THEN %LET BENPREF=%SUBSTR(&BENPREF,1,&TEMP) ;

%IF %BQUOTE(&BYOUT)= %THEN %LET BYOUT=_byout_ ;
%IF %BQUOTE(&EXTOUT)= %THEN %LET EXTOUT=_extout_ ;
%IF %BQUOTE(&OUTDSN)= %THEN %LET OUTDSN=_outdsn_ ;
%IF %BQUOTE(&REPWTMAX)= %THEN %LET REPWTMAX=5000 ;
%IF %BQUOTE(&NPREDICT)= %THEN %LET NPREDICT = 0 ;

%IF %INDEX(&XOPTIONS,%STR( HMEAN )) %THEN %LET MEANWT=H ;
%ELSE %IF %INDEX(&XOPTIONS,%STR( AMEAN )) %THEN %LET MEANWT=A ;
%ELSE %LET MEANWT= ;

%* EXPA gives an alternative approach to calculation of the
   exponential method - try it if the other is not working *;

%* Now we need code for the LOWER and UPPER specifications. *;

%IF %INDEX(&LOWER,%BQUOTE(%))=0 %THEN %LET LOCODE = &LOWER ;
%ELSE %DO ; %* LOWER includes a % sign *;
  %LET LOCODE = %SCAN(&LOWER,1,%BQUOTE(%)) ; %* Remove % sign *;
  %LET LOCODE = min(0.95,0.01*(&LOCODE))*cwgrpwt{_k_} ;
  %* the smaller of 95% and &LOCODE is used *;
%END ;
%IF %INDEX(&UPPER,%BQUOTE(%))=0 %THEN %LET UPCODE = &UPPER ;
%ELSE %DO ; %* UPPER includes a % sign *;
  %LET UPCODE = %SCAN(&UPPER,1,%BQUOTE(%)) ; %* Remove % sign *;
  %LET UPCODE = max(1.05,0.01*(&UPCODE))*cwgrpwt{_k_} ;
%END ;

%*LET CWPRINT = %EVAL(%INDEX(&XOPTIONS,%STR( PRINT ))>0) ;
%* CWPRINT gives 1 if PRINT was an option *;

%LET EXTRA = %EVAL(%INDEX(&XOPTIONS,%STR( NOLOG ))=0) ;
%LET PRINTREP = (%INDEX(&XOPTIONS,%STR( NOPRINT ))=0) ;
%LET BADPRINT = (%INDEX(&XOPTIONS,%STR( BADPRINT ))>0) ;
%IF %BQUOTE(&EXTNO)= %THEN
 %IF &BADPRINT %THEN %LET EXTNO = 5 ;
 %ELSE %LET EXTNO = 30 ;
%IF (%BQUOTE(&PENALTY)=_ONE_) OR (%BQUOTE(&PENALTY)=1)
 %THEN %LET PENALTY = ;

%LOCAL I WORD ;
%LET TEMP = ; %* Will hold last element of list &GROUP *;
%DO I = 1 %TO 999 ;
 %LET WORD = %SCAN(&GROUP,&I) ;
 %IF %BQUOTE(&WORD) = %THEN %LET I = 1000 ;
 %ELSE %LET TEMP = &WORD ;
%END ;
%IF %BQUOTE(&TEMP)^= %THEN %LET TEMP = &TEMP &UNIT ;
%* These are the variables that may be named in a BnGRP parameter *;

%DO B=1 %TO 30 ;
 %* Check the BnGRP parameters *;
 %IF %BQUOTE(&&B&B.GRP)^=
 %THEN %IF %BQUOTE(&GROUP)= %THEN %CHECKERR(1,
  B&BGRP invalid when GROUP is not specified) ;
 %ELSE %IF %SCAN(&&B&B.GRP,2)>0 %THEN %CHECKERR(1,
  B&BGRP must name a single variable from: &TEMP) ;
 %ELSE %IF %INDEX(
  %UPCASE(XXXXXXXX &TEMP X),
                   %UPCASE(%STR( &&B&B.GRP ))) = 0
 %THEN %CHECKERR(1, B&B.GRP variable &&B&B.GRP not listed in: &TEMP) ;
%END ;

%IF %BQUOTE(&OUT)= %THEN %LET OUTGRP = ;
%IF %BQUOTE(&OUTGRP)^=
%THEN %IF %BQUOTE(&GROUP)= %THEN %CHECKERR(1,
 OUTGRP invalid when GROUP is not specified) ;
%ELSE %IF %SCAN(&OUTGRP,2)>0 %THEN %CHECKERR(1,
  OUTGRP must name a single variable from: &TEMP) ;
%ELSE %IF %INDEX(
 %UPCASE(XXXXXXXX &TEMP X),
                   %UPCASE(%STR( &OUTGRP ))) = 0
%THEN %CHECKERR(1, OUTGRP variable &OUTGRP not listed in: &TEMP) ;

%IF %BQUOTE(&VAR) = %THEN %LET VAR=_one_ ;
%IF %BQUOTE(&OUT)^= & %BQUOTE(&VARGRP)^= & %BQUOTE(STRATUM)^=
%THEN %LET WTDRES =1 ; %* Calculate weighted residual variance *;
%ELSE %LET WTDRES =0 ; %* Default is no calculation *;

%*Process the CLASS and SUBCLASS lists *;
%LOCAL CNUM SCNUM CAG1 CAG2 CAG3 CAG4 CAG5 CAG5 CAG7 CAG8 CAG9
CNAM1 CNAM2 CNAM3 CNAM4 CNAM5 CNAM5 CNAM7 CNAM8 CNAM9 ;
%LET TEMP = ;
%LET CNUM = 0 ;
%DO I = 1 %TO 1000 ;
  %LET WORD = %SCAN(&CLASS,&I,%STR( *+-)) ;
  %IF %BQUOTE(&WORD)= %THEN %LET I = 1001 ; %* Exit Loop *;
  %ELSE %DO ;
    %IF %INDEX(&WORD,%STR(#))>0 %THEN %LET CAG&I = 1 ;
    %ELSE %LET CAG&I = ;
    %LET CNAM&I = %SCAN(&WORD,1,%STR(#)) ;
    %LET CNUM = &I ;
    %LET TEMP = &TEMP &&CNAM&I ;
  %END ;
%END ;
%LET CLASS = &TEMP ;
%LET TEMP = ;
%LET SCNUM = &CNUM ;
%DO I = &CNUM+1 %TO 1000 ;
  %LET WORD = %SCAN(&SUBCLASS,&I-&CNUM,%STR( *+-)) ;
  %IF %BQUOTE(&WORD)= %THEN %LET I = 1001 ; %* Exit Loop *;
  %ELSE %DO ;
    %IF %INDEX(&WORD,%STR(#))>0 %THEN %LET CAG&I = 1 ;
    %ELSE %LET CAG&I = ;
    %LET CNAM&I = %SCAN(&WORD,1,%STR(#)) ;
    %LET SCNUM = &I ;
    %LET TEMP = &TEMP &&CNAM&I ;
  %END ;
%END ;
%LET SUBCLASS = &TEMP ;

%LOCAL NOUTREPS NUMSTA ;
%********* Check out the unit dataset ***************;
%IF %BQUOTE(&UNITDSN)^= %THEN %DO ;
  %* Check that the dataset exists *;
  %LET NUMSTA = 0 ;
  data ck_dsn ;
   if cwnumsta>0 then do ;
    set &UNITDSN nobs=cwnumsta ;
    call symput('NUMSTA',left(put(cwnumsta,8.))) ;
    _one_ = 1 ;
    cw_temp = 1 ;
    output ;
   end ;
   stop;
  run;

  %CHECKERR((&NUMSTA=0),
    Could not access dataset &UNITDSN) ;
  %IF (&NUMSTA>0) %THEN %DO ;
    %CK_TRASH(ck_dsn) %* Put on list for later deletion *;
    %* Check that the variables exist and that weights and vbls
       are numeric.
       Count &NREPWTS, the number of replicate weights *;
    %LOCAL NREPWTS NVAR NDEN
           NB1VAR NB2VAR NB3VAR NB4VAR NB5VAR
           NB6VAR NB7VAR NB8VAR NB9VAR NB10VAR
           NB11VAR NB12VAR NB13VAR NB14VAR NB15VAR
           NB16VAR NB17VAR NB18VAR NB19VAR NB20VAR
           NB21VAR NB22VAR NB23VAR NB24VAR NB25VAR
           NB26VAR NB27VAR NB28VAR NB29VAR NB30VAR
           NB1RVAR NB2RVAR NB3RVAR NB4RVAR NB5RVAR
           NB6RVAR NB7RVAR NB8RVAR NB9RVAR NB10RVAR
           NB11RVAR NB12RVAR NB13RVAR NB14RVAR NB15RVAR
           NB16RVAR NB17RVAR NB18RVAR NB19RVAR NB20RVAR
           NB21RVAR NB22RVAR NB23RVAR NB24RVAR NB25RVAR
           NB26RVAR NB27RVAR NB28RVAR NB29RVAR NB30RVAR ;

    data ck_dsn ;
      set ck_dsn(keep=_one_ &BYVARS &STRATUM &VARGRP &GROUP &UNIT
        &INWEIGHT &INREPWTS &REPID &WRWEIGHT
        &CLASS &SUBCLASS &VAR &DENOM
      %DO B=1 %TO 30 ;
        &&B&B.CLASS &&B&B.VAR &&B&B.RVAR
      %END ;
        &ID &PENALTY) ;
      %DO B=1 %TO 30 ;
        %* Count the benchmark variables, check numeric *;
        array cwvar&B{*} _one_ &&B&B.VAR ;
        call symput("NB&B.VAR",
         left(put(max(1,dim(cwvar&B)-1),6.))) ;
        %* NB&B.VAR contains 1 if no benchmark variables *;
        array cwrvar&B{*} _one_ &&B&B.RVAR ;
        call symput("NB&B.RVAR",left(put(dim(cwrvar&B)-1,6.))) ;
      %END ;
      ;
      %* Count the weight variables, check they are numeric *;
      array cwwt{*} _one_ &INWEIGHT &PENALTY &WRWEIGHT ;
      array cwwts{*} _one_ &INREPWTS ;
      call symput("NREPWTS",left(put(dim(cwwts)-1,6.))) ;
      %* NREPWTS is the number of replicate weights listed *;
      %IF %BQUOTE(&OUTREPS)^= %THEN %DO ;
       array cwoutrep{*} _one_ &OUTREPS ;
       call symput("NOUTREPS",left(put(dim(cwoutrep)-1,6.))) ;
      %END ;

      %* Count the var variables, check they are numeric *;
      array cwvar{*} _one_ &VAR ;
      call symput("NVAR",left(put(dim(cwvar)-1,6.))) ;
      %* Count the DENOM variables, check they are numeric *;
      array cwden{*} _one_ &DENOM ;
      call symput("NDEN",left(put(dim(cwden)-1,6.))) ;
      output ;
      stop ;
    run ;
    %LET NREPWTS = &NREPWTS ;
    %CHECKERR((&SYSERR^=0),
      Variable(s) missing or of wrong type on dataset &UNITDSN) ;
    %IF (&SYSERR=0) %THEN %DO ;
      %CHECKERR((&NDEN > &NVAR),
      DENOM lists more variables than VAR)
      %IF &NREPWTS > 0 %THEN %LET REPID = ;
    %END ;
  %END ;
%END ;
%ELSE %CHECKERR(1, No unit dataset given in macro call) ;

%IF %BQUOTE(&OUTREPS)^= %THEN %IF &NOUTREPS < &NREPWTS %THEN
 %CHECKERR(1, Not enough OUTREPS variables for &NREPWTS replicates) ;

%IF &GO_END=1 %THEN %GOTO SKIPEND ;

%***********Initial creation of unit and BY datasets ***********;

%* cw_unit is a copy of &UNITDSN to which we attach
     _one_ (=1 for all units) and cw_order (original order)
   Eventually we will also attach category variables
     cwcat1,.. indexing the categories for benchmark dataset 1,..
   cw_by has a record for each BY group with
     cw_beg, cw_end pointers to first and last obs
   Eventually we will attach
     cwb1-cwb&MAXRPARS containing all the benchmarks
     for that BY group in the first cw_nb elements
     cwncat1-cwncat&B the number of categories for that
     BY group and benchmark
*;
data cw_unit
 %IF &KEEPID %THEN %DO ;
  (keep=_one_ cwgrpflg &BYVARS &INWEIGHT &INREPWTS &REPID &WRWEIGHT
  %DO B=1 %TO 30 ;
   &&B&B.CLASS &&B&B.VAR &&B&B.RVAR
  %END ;
  &CLASS &SUBCLASS &VAR &DENOM
  &STRATUM &VARGRP &GROUP &UNIT &ID &PENALTY)
 %END ;
 %ELSE %DO ;
  (drop=cw_beg cw_end cw_nb cw_nrb cwnrep)
 %END ;
 cw_by(keep=_one_ &BYVARS cw_beg cw_end cw_nb cw_nrb) ;

 set &UNITDSN end=_last_ ;
 length _one_ cwgrpflg 3 ;
        %* cwgrpflg = 0 if not last in group
             = 1 if last in group, not last in psu
             = 2 if last in VARGRP, not last in stratum
             = 3 if last in STRATUM, not last in BY
             = 4 if last in BY *;

 &UNITCODE
 retain cw_beg 1 cw_end 0 cw_nb cw_nrb 0 cwnrep 0 ;
*  cw_order = _n_ ; %* Input sort order *;
 _one_ = 1 ;     %* Dummy variable taking value 1 *;
 cw_end + 1 ;
 %IF %BQUOTE(&REPID)^= %THEN %DO ;
  if &REPID = int(&REPID) and 0 <= &REPID <= &REPWTMAX
  then cwnrep = max(cwnrep,&REPID) ;
  else cwnrep = 99999 ;
  if _last_ then call symput("NREPWTS",left(put(cwnrep,6.))) ;
 %END ;
 cwgrpflg = 0 ;
 if &LASTGRP then cwgrpflg + 1 ;
 if &LASTVG then cwgrpflg + 1 ;
 if &LASTSTRA then cwgrpflg + 1 ;
 if &LASTBY then cwgrpflg + 1 ;
 output cw_unit ;

 if &LASTBY then do ;
  output cw_by ;
  cw_beg = cw_end + 1 ;
 end ;
run ;
%CK_TRASH(cw_unit)
%CK_TRASH(cw_by)
%CHECKERR((&SYSERR^=0),
Check unit data is sorted by &BY &STRATUM &VARGRP &GROUP &UNIT)
%CHECKERR((&NREPWTS>99998),
 Invalid value for replicate identifier &REPID)

%IF &GO_END=1 %THEN %GOTO SKIPEND ;

%IF &NREPWTS = 0 %THEN %LET OUTREPS= ;
%ELSE %IF (%BQUOTE(&OUTREPS) =) & (%INDEX(&XOPTIONS,%STR( REPS ))>0)
%THEN %DO ;
 %LET OUTREPS = est_1-est_&NREPWTS ;
 %LET NOUTREPS = &NREPWTS ;
%END ;

%*********** Deal with each benchmark dataset **************;
%* New inputs are BbDSN=,BbCLASS=,BbVAR=,BbTOT= *;

%LOCAL MAXBEN BENVBLS NBENVBLS NBENREPS NNVBLS MAXPARS MAXRPARS
       NBTOT NBREP BNUM CW_MAXNB CWMAXNRB
       BNAM1 BNAM2 BNAM3 BNAM4 BNAM5 BNAM6 BNAM7 BNAM8 BNAM9
       BTYP1 BTYP2 BTYP3 BTYP4 BTYP5 BTYP6 BTYP7 BTYP8 BTYP9
       TNAM1 TNAM2 TNAM3 TNAM4 TNAM5 TNAM6 TNAM7 TNAM8 TNAM9 ;
%LET MAXBEN = 0 ;
%LET BENVBLS = ;
%LET NBENVBLS = ;
%LET NBENREPS = ;
%LET NNVBLS = 0 ;
%* How many categories to set as upper limit? *;
%LET MAXPARS = %EVAL(&MAXSPACE*1000 / (50 + 16*(&NREPWTS + 1))) ;
%LET MAXRPARS = %EVAL(&MAXPARS*(&NREPWTS+1)) ;

%DO B = 1 %TO 30 ; %* For each benchmark specification *;
 %IF %LENGTH(&&B&B.DSN)=0 %THEN %LET B=1000 ; %* Exit loop *;
 %ELSE %DO ; %* More benchmark datasets *;
  %LET MAXBEN = &B ;
  %IF %BQUOTE(&&B&B.TOT) =
  %THEN %CHECKERR(1,No value for B&B.TOT given) ;
  %IF %BQUOTE(&&B&B.VAR)= %THEN %LET B&B.VAR = _one_ ;
  %IF %BQUOTE(&GO_END)= %THEN %DO ;
   %* Check benchmark dataset exists *;
  %LET NUMSTA = 0 ;
  data ck_dsn ;
   if cwnumsta>0 then do ;
    set &&B&B.DSN nobs=cwnumsta ;
    call symput('NUMSTA',left(put(cwnumsta,8.))) ;
    _one_ = 1 ;
    output ;
   end ;
   stop;
  run;

  %CHECKERR((&NUMSTA=0),
     Could not access dataset &&B&B.DSN) ;
   %IF (&NUMSTA>0) %THEN %DO ;
    %CK_TRASH(ck_dsn) ;
    %* Check it contains the required variables and that the
       B&B.TOT variables are numeric *;
    data ck_dsn ;
     set ck_dsn(keep=_one_ &BYVARS
       &&B&B.CLASS &&B&B.TOT &&B&B.REPS) ;
     array cwtemp{*} _one_ &&B&B.TOT ;
     array cwreps{*} _one_ &&B&B.REPS ;

     output ;
     cwtemp1 = max(1,dim(cwtemp)-1) ;
     call symput("NBTOT",left(put(cwtemp1,6.))) ;
     %* NBTOT will contain 1 if no total variables listed *;
     cwtemp2 = dim(cwreps) - 1 ;
     if cwtemp2 = 0 then call symput("NBREP","0") ;
     else if cwtemp2=cwtemp1*&NREPWTS
     then call symput("NBREP","&NREPWTS") ;
     else call symput("NBREP",".") ;
     stop ;
    run ;
    %CHECKERR((&SYSERR^=0),
 Variable(s) missing or of wrong type on dataset &&B&B.DSN)
    %IF (&NBREP = .) %THEN %CHECKERR(1,
 B&B.REPS does not match B&B.TOT and INREPWTS) ;
    %ELSE %IF (&NBREP>0) & (&&NB&B.RVAR>0)
    %THEN %CHECKERR((&&NB&B.RVAR^=(&NBTOT*&NBREP)),
 B&B.RVAR does not match B&B.TOT and INREPWTS) ;
   %END ;
   %IF (&NUMSTA>0) & (&SYSERR=0) %THEN %DO ; %* Dataset looks ok *;
    %IF %BQUOTE(&&B&B.CLASS)^= %THEN %DO ;
     %* Get info about the category variables *;
     proc contents data=ck_dsn(keep=&&B&B.CLASS)
       out=cwnames(keep=name type length nobs) noprint;
     run ;
     %CK_TRASH(cwnames)
     data _null_ ;
      set cwnames end=_last_;
      call symput("BNAM"!!left(put(_n_,3.)),name) ;
      if type = 1
       then call symput("BTYP"!!left(put(_n_,3.)),
        left(put(length,3.))) ;
       else call symput("BTYP"!!left(put(_n_,3.)),
        '$ '!! left(put(length,3.))) ;
      if _last_ then call symput("BNUM",left(put(_n_,3.))) ;
     run ;
     %* Now BNUM gives the number of category variables,
        BNAM1-BNAM&BNUM are names of the category variables
        BTYP1-BTYP&BNUM are type specifications for use in
        an array statement eg $ 4  *;
    %END ;
    %ELSE %LET BNUM=0 ; %* No category variables *;
   %END ;

   %IF %BQUOTE(&GO_END)= %THEN %DO ; %* Benchmark dataset ok *;
    data ck_dsn ;
     set &&B&B.DSN ;
    run ;
    %* Get names of the TOT variables *;
    proc contents data=ck_dsn(keep=&&B&B.TOT)
         out=cwnames(keep=name) noprint;
    run ;
    %CK_TRASH(cwnames)
    data _null_ ;
     set cwnames end=_last_;
     call symput("TNAM"!!left(put(_n_,3.)),name) ;
    run ;

    %* This code sets up arrays to store values for all
       categories present on B&B.DSN,
       then uses them to assign a category identifier cwcat&B to
       each record on cw_unit (the unit dataset)
    *;

    data cw_by(keep=_one_ &BYVARS cw_beg cw_end cw_nb cw_nrb
                    cwncat1-cwncat&B)
         cw_unit(drop=cw_beg cw_end cwtbeg cwtend cw_nb cw_nrb
                 cw_nblo cw_nrblo _count_
                 %IF &NBREP > 0 %THEN cwrep ;
                 cw_maxnb cwmaxnrb cwi cwj cwtemp cwlo cwhi
                 cwdone _name_ _value_ _i_ cwbentot
                 cwncat1-cwncat&B &&B&B.TOT &&B&B.REPS)
         cwrep&B(keep=&BYVARS &&B&B.CLASS _i_ _name_ _count_ _value_)
         cwben&B(keep=cwbentot) ;
     set cw_by(in=incw_by)
         ck_dsn(in=inb keep=&BYVARS
                  &&B&B.CLASS &&B&B.TOT &&B&B.REPS)
         cw_unit end=_last_ ;
     &BYCODE
     %* Set up arrays for each category variable.
        The ith element of each array gives the value of that
        category variable for the ith category on B&B.DSN.
        The categories are kept sorted. *;
     %DO I = 1 %TO &BNUM ;
      array cw_&I {0:&MAXPARS} &&BTYP&I _temporary_ ;
     %END ;
     array cwtots{0:&NBTOT} _one_ &&B&B.TOT ;
     %IF &NBREP > 0 %THEN %DO ;
      array cwrtots{1:&NBTOT,1:&NBREP} &&B&B.REPS ;
     %END ;
     %* cwagben is temporary storage for these same values *;
     array cwagben{0:&MAXRPARS} _temporary_ ;
     array cwcount{0:&MAXPARS} _temporary_ ;
     array cwncats{&B} cwncat1-cwncat&B ;
     array temncats{&B} _temporary_ ;
     length cwcat&B 4 ;

     retain cwncat&B cw_maxnb cwmaxnrb cw_nblo cw_nrblo
      cwtbeg cwtend 0 ;

     if incw_by then do ;
      %* cw_nrb is the number of variables already used up *;
      cwncat&B = 0 ;
      cw_nblo = cw_nb ; %* Store for later recall *;
      cw_nrblo = cw_nrb ;
      do cwi = 1 to &B-1 ;
       temncats{cwi} = cwncats{cwi} ;
      end ;
      cwtbeg = cw_beg ;
      cwtend = cw_end ;
     end ;
     else do ;
      cwlo = 0 ; %* 1 below lowest category *;
      cwhi = cwncat&B + 1 ; %* id 1 above highest category *;
      cwdone = cwhi <= (cwlo + 1) ; %* 1 if no categories *;
      %* cwdone = 1 means: tried all categories and none match
           the category variables on this record
         cwdone = 2 means: found a match
         cwdone = 0 means: still looking *;
      do while(^cwdone) ; %* Try to find *;
       cwi = int(0.5*(cwlo+cwhi)) ; %* Check this category *;
       %* If category cwi is too small set cwlo to cwi
          if category cwi is too big set cwhi to cwi
          If category matches then set cwdone=2  *;
       %DO I = 1 %TO &BNUM ;
        if cw_&I{cwi} < &&BNAM&I then cwlo = cwi ;
        else if &&BNAM&I < cw_&I{cwi} then cwhi = cwi ;
        else
       %END ;
       do ;
        cwdone = 2 ; %* Found it *;
        if inb then do ;
         %* Category found on benchmark dataset *;
         cwtemp = &NBTOT*(&NBREP+1)*(cwi-1) ;
         do cwj = 1 to &NBTOT ;
          cwtemp + 1 ;
          %* Add into the appropriate benchmarks *;
          cwagben{cwtemp} + cwtots{cwj} ; %* Store benchmark *;
          %IF &NBREP > 0 %THEN %DO ;
           do cwrep = 1 to &NBREP ;
            cwtemp + 1 ;
            cwagben{cwtemp} + cwrtots{cwj,cwrep} ;
           end ;
          %END ;
         end ;
        end ;
        else cwcat&B = cwi ; %* Category number for cw_unit *;
       end ;
       if ^cwdone then cwdone = cwhi <= (cwlo + 1) ;
      end ;
      if cwdone = 1 then do ; %* Didnt find it *;
       if inb
       then if (cw_nblo + (cwncat&B+1)*&NBTOT) > &MAXPARS
       then do ;
        call symput("GO_END","1") ;
        stop ;
       end ;
       else do ;
       %* Store this category in the list of categories
          at its appropriate sort place.  First move up all
          the other categories to make space *;
        do cwi = cwncat&B to cwhi by -1 ;
         cwtemp = &NBTOT*(&NBREP+1)*(cwi-1) ;
         cwcount{cwi+1} = 0 ;
         do cwj = 1 to &NBTOT*(&NBREP+1) ;
          %* Copy benchmarks into next slot *;
          cwagben{cwtemp+cwj+&NBTOT*(&NBREP+1)}
           = cwagben{cwtemp+cwj} ;
         end ;
         %* Copy category values to next slot*;
         %DO I = 1 %TO &BNUM ;
          cw_&I{cwi+1} = cw_&I{cwi} ;
         %END ;
        end ;
        cwtemp = &NBTOT*(&NBREP+1)*(cwhi-1) ;
        cwcount{cwhi} = 1 ;
        do cwj = 1 to &NBTOT ;
         cwtemp + 1 ;
         %* Copy benchmarks into the newly available slot *;
         cwagben{cwtemp} = cwtots{cwj} ; %* Store benchmark *;
         %IF &NBREP > 0 %THEN %DO ;
          do cwrep = 1 to &NBREP ;
           cwtemp + 1 ;
           cwagben{cwtemp} = cwrtots{cwj,cwrep} ;
          end ;
         %END ;
        end ;

        %DO I = 1 %TO &BNUM ;
         cw_&I{cwhi} = &&BNAM&I ;
        %END ;
        cwncat&B = cwncat&B + 1 ;
       end ;
       else if ^inb then cwcat&B = 0 ;
        %* Category not on benchmark dataset *;
      end ;
      if ^inb then do ;
       output cw_unit ;
       cwcount{cwcat&B} + 1 ;
      end ;
     end ;
     if &LASTBY then do ;

      %* Output reports dataset *;
      _i_ = cw_nblo ;
      do cwhi = 1 to cwncat&B ;
       %DO I = 1 %TO &BNUM ;
        &&BNAM&I = cw_&I{1+(cwhi-1)*&NBTOT} ;
       %END ;
       length _name_ $ 32 ; %* SAS V8 names can be 32 chars long *;
       _count_ = cwcount{cwhi} ;
       do cwlo = 1 to &NBTOT ;
        _i_ + 1 ;
        if 0 then ;
        %DO I = 1 %TO &NBTOT ;
         else if cwlo=&I then _name_="&&TNAM&I" ;
        %END ;
        _value_ = cwagben{1 + (_i_-cw_nblo-1)*(&NBREP+1)} ;
        output cwrep&B ;
       end ;
      end ;

      %* Increase number of benchmarks used for this BY group *;
      cw_nb = cw_nblo + cwncat&B*&NBTOT ;
      cw_nrb = cw_nrblo + cwncat&B*&NBTOT*(&NBREP+1) ;
      cw_end = cwtend ;
      cw_beg = cwtbeg ;
      do cwi = 1 to cwncat&B*&NBTOT*(&NBREP+1) ;
       %* Copy benchmarks into variables on cw_by for output *;
       cwbentot = cwagben{cwi} ;
       cwagben{cwi} = . ;
       output cwben&B ;
      end ;
      do cwi = 1 to &B-1 ;
       cwncats{cwi} = temncats{cwi} ;
      end ;
      output cw_by ;
      cwncat&B = 0 ;  %* Added 24/10/01 to reset category count *;
      cw_maxnb = max(cw_maxnb,cw_nb) ;
      cwmaxnrb = max(cwmaxnrb,cw_nrb) ;
      cwtend = 0 ;
      cwtbeg = 1 ;
      cw_nblo = 0 ;
      cw_nrblo = 0 ;
      do cwi = 1 to &B-1 ;
       temncats{cwi} = 0 ;
      end ;
     end ;
     if _last_ then do ;
      call symput("CW_MAXNB",left(put(cw_maxnb,6.))) ;
      call symput("CWMAXNRB",left(put(cwmaxnrb,6.))) ;
     end ;
    run ;
    %CK_TRASH(cwrep&B)
    %CK_TRASH(cwben&B)
    %CHECKERR(0&GO_END,
 Not enough storage space: increase MAXSPACE parameter) ;

    %IF &&B&B.GRP ^= %THEN %DO ;
     %* Only the first record in each &&B&B.GRP gets used *;
     data cw_unit ;
      set cw_unit ;
      &UNITCODE
      if ^first.&&B&B.GRP then do ;
       cwcat&B=0 ;
      end ;
     run ;
    %END ;

    %LET BENVBLS=&BENVBLS &&B&B.VAR ;
    %IF (&NBTOT ^= &&NB&B.VAR) %THEN
     %CHECKERR(1,
  B&B.TOT and B&B.VAR contain different numbers of variables) ;
    %ELSE %DO ;
     %LET NBENVBLS = &NBENVBLS &&NB&B.VAR ;
     %LET NNVBLS = %EVAL(&NNVBLS + &&NB&B.VAR) ;
     %LET NBENREPS = &NBENREPS &NBREP ;
    %END ;
 %*PUT NB&B.TOT=&NBTOT B&B.TOT=&&B&B.TOT
   NB&B.VAR=&&NB&B.VAR B&B.VAR=&&B&B.VAR
   NBENVBLS=&NBENVBLS BENVBLS=&BENVBLS ;

   %END ; %* %IF &GO_END *;
  %END ; %* %IF &GO_END *;
 %END ;
%END ;

%IF &MAXBEN=0 %THEN %CHECKERR(1,No benchmark datasets specified) ;
%ELSE %IF (&CWMAXNRB < &MAXRPARS) %THEN %DO ;
 %LET MAXPARS = &CW_MAXNB ;
 %* Largest number of parameters in any BY group *;
 %LET MAXRPARS = &CWMAXNRB ;
 %* Total number of variables needed to store
    benchmarks and replicate benchmarks in any BY group *;
%END ;
%IF &GO_END=1 %THEN %GOTO SKIPEND ;

%*PUT MAXTAB=&MAXTAB NTABVBLS=&NTABVBLS TABVBLS=&TABVBLS
      NTABCATS=&NTABCATS ;
%*PUT MAXBEN=&MAXBEN NBENVBLS=&NBENVBLS BENVBLS=&BENVBLS ;
%*PR(cw_unit(obs=20), unit data) %* Diagnostic print *;
%*PR(cw_ben(obs=20), benchmarks) %* Diagnostic print *;

%*PUT INWEIGHT=&INWEIGHT REPID=&REPID NREPWTS=&NREPWTS *;
%IF (%BQUOTE(&REPID)^=) & (&NREPWTS > 1) %THEN %DO ;
 %* Attach replicate weights to unit data *;
 %LET INREPWTS = rwt1-rwt&NREPWTS ;
 %IF %BQUOTE(&REPWTS)=
 %THEN %LET REPWTS = rwt1-rwt&NREPWTS ;
 data cw_unit(drop=cw_ix_
 %IF &KEEPID %THEN &REPID ;
  )  ;
  set cw_unit ;
  array cwwts{1:&NREPWTS} 4 &INREPWTS ;
  do cw_ix_ = 1 to &NREPWTS ;
   if cw_ix_=&REPID then cwwts{cw_ix_} = 0 ;
   else cwwts{cw_ix_} = &INWEIGHT*&NREPWTS/(&NREPWTS-1) ;
  end ;
 run ;
%END ;

%IF &GO_END=1 %THEN %GOTO SKIPEND ;

%IF %BQUOTE(&OUT)^= %THEN %DO ;
 %LOCAL TOTLENG
  VNAM1 VNAM2 VNAM3 VNAM4 VNAM5 VNAM6 VNAM7 VNAM8 VNAM9
  BYTYP1 BYTYP2 BYTYP3 BYTYP4 BYTYP5 BYTYP6 BYTYP7 BYTYP8 BYTYP9
  CTYP1 CTYP2 CTYP3 CTYP4 CTYP5 CTYP6 CTYP7 CTYP8 CTYP9 ;


 %* Get list of variable names for table *;
 data ttnames ;
  array temp{*} &VAR ;
  output ;
 run ;
 %CK_TRASH(ttnames)
 proc contents data=ttnames
    out=ttnames(keep=name npos) noprint;
 run ;
 proc sort data=ttnames out=ttnames(drop=npos) ;
  by npos ;
 run ;
 data _null_ ;
  set ttnames end=_last_;
  call symput("VNAM"!!(left(put(_n_,3.))),
            translate(trim(name)
            ,"abcdefghijklmnopqrstuvwxyz"
            ,"ABCDEFGHIJKLMNOPQRSTUVWXYZ")) ;
 run ;
 %LET VARNAMES="&VNAM1" ;
 %DO I = 2 %TO &NVAR ;
  %LET VARNAMES = &VARNAMES "&&VNAM&I" ;
 %END ;

 %IF %BQUOTE(&CLASS &SUBCLASS &BYVARS)^= %THEN %DO ;

  data ttnames(keep=&CLASS &SUBCLASS &BYVARS) ;
   set cw_unit ;
   output ;
   stop ;
  run ;
  proc contents data=ttnames
       out=ttnames(keep=name type length nobs) noprint;
  run ;
  data _null_ ;
   set ttnames end=_last_;
   length ttctype $ 5 ;
   retain totleng 0 ;
   if type=1 then ttctype=left(put(length,3.)) ;
   else ttctype = '$ ' !! left(put(length,3.)) ;
   %DO I = 1 %TO &SCNUM ;
    if upcase(name)=upcase("&&CNAM&I")
    then do ;
     call symput("CTYP&I",ttctype) ;
     if type=1 then totleng + 8 ;
     else totleng + length ;
    end ;
   %END ;
   %DO I = 1 %TO &NBYVARS ;
    if upcase(name)=upcase("&&BYVAR&I")
    then call symput("BYTYP&I",ttctype) ;
   %END ;
   if _last_ then call symput("TOTLENG",left(put(totleng,3.))) ;
  run ;
%*DO I = 1 %TO &SCNUM ;
  %*PUT CNAM&I=&&CNAM&I CAG&I=&&CAG&I CTYP&I=&&CTYP&I;
%*END ;
%*DO I = 1 %TO &NBYVARS ;
  %*PUT BYVAR&I=&&BYVAR&I BYTYP&I=&&BYTYP&I ;
%*END ;
  %CK_TRASH(ttnames) ;
 %END ;
 %ELSE %LET TOTLENG = 0 ;

 %LET NVAR_1 = %EVAL(&NVAR - 1) ;
 %LET NVD_1 = %EVAL(&NVAR_1 + &NDEN) ;
 %LET NVD = %EVAL(&NVAR + &NDEN) ;
 %LET TOTLENG = %EVAL(&TOTLENG + 8
               + 8*((&NVAR+&NDEN)*(1+&NREPWTS)) ;
 %IF &WTDRES %THEN %LET TOTLENG
   = %EVAL(&TOTLENG + &MAXPARS*&NVD) ;

 %LET MAXCATS = %EVAL(1000*&MAXSPACE / &TOTLENG) ;
 %*PUT MAXSPACE=&MAXSPACE TOTLENG=&TOTLENG MAXCATS=&MAXCATS;

 %IF &OUTGRP ^= %THEN %DO ;
  %* Flag the first record in each &OUTGRP *;
  data cw_unit ;
   set cw_unit ;
   &UNITCODE
   cwoutgrp = first.&OUTGRP ;
  run ;
 %END ;

%END ; %* Ready now for tables *;
%ELSE %LET MAXCATS = 0 ;
%IF &GO_END=1 %THEN %GOTO SKIPEND ;

%LOCAL CWREG ;
%LET CWREG = 0 ;
%IF &MAXBEN >= 1 %THEN %DO ;
 %LOCAL CATKEEP ;
 %IF %BQUOTE(&GROUP)= %THEN
  %LET CATKEEP=cwgrpflg cwcat1-cwcat&MAXBEN ;
 %* Run code to weight the data *;

 %*PR(cw_unit(obs=50),) *;
 %*PR(cw_by(obs=50),) *;

 %IF &EXTRA %THEN %DO ;
  %PUT ;
  %PUT Main calculations begin: ;
 %END ;
 %* START OF MAIN CALCULATIONS PORTION

 Outline of calculations:
 The input data arrive as:
 macro variables:
  &NREPWTS the number of replicate weights
    (not counting the full weight)
  &MAXPARS the largest number of beta parameters in any BY group
  &MAXRPARS the number of variables required to store benchmarks
     and replicate benchmarks for any BY group
  &MAXBEN the number of sets of benchmarks
  &BENVBLS the variables used in each benchmark set, concatenated
    eg with 3 benchmarks the list could be _one_ _one_ dairy meat
  &NBENVBLS the list of numbers of variables in each benchmark
    eg for above example list would be 1 1 2
    cwnvbl{b} allows access to these numbers for benchmark b
  &LOCODE, &UPCODE bounds on changes to weights

 cw_unit: unit data sorted by BY groups
  cwwt{i} weights, with i=0 the full input weight,
    i>0 the replicate weights
  cwcat{b} give the category the unit is in for benchmark b
  cwvbl{v} all the variables used in all benchmark sets

 cw_by: one record for each BY group
  cw_beg,cw_end point to the first and last obs of cw_unit
    in this BY group
  cwncat{b} the number of categories for benchmark b
  cwxben{p} the benchmarks for the p-th beta parameter
    in this BY group

 The program proceeds by
 1. reading in cw_by for the next BY group
 2. iteratively reading through cw_unit
  a) calculating new weights using cwxben,cwxest and matrix
    as calculated (step 2b) on the previous iteration
    and adjusted to lie in the range given by &LOCODE and &UPCODE
    (at iteration 1 the input weights are used)
  b) aggregating across units to obtain
    cwxest{p} the estimate for benchmark p
      based on these new weights
    matrix{ } a lower triangular representation of the X`X matrix
      based on those new weights which did not need adjustment
 3. a) matrix{ } is decomposed ready for calculations
      at the next iteration
    b) repeat step 2 until &MAXITER iters or cwxest near cwxben
 4. do step 2 a final time to output the new weights attached to
   the unit dataset.
 *;

 %LOCAL NMAXGRPS NCWEST NMAT NMATRIX CWREP NREPORT CWRULER CWPSRAT ;
 %IF (&NNVBLS <= 1) & (&MAXBEN = 1) & (%BQUOTE(&GROUP)= )
 %THEN %LET CWPSRAT = 1 ; %* This is a simple post-stratification *;
 %ELSE %LET CWPSRAT = 0 ;
 %LET NMAXGRPS = 20 ; %* Largest number of units in any group *;
 %LET NCWXEST = %EVAL((&NREPWTS+1)*&MAXPARS) ;
  %* Need enough room for an estimate from each parameter
     by each weight *;
 %IF &CWPSRAT %THEN %LET NMAT = %EVAL(&MAXPARS) ;
  %* Only need to store diagonal elements of the X`X matrix *;
 %ELSE %LET NMAT = %EVAL(&MAXPARS*(&MAXPARS+1)/2) ;
  %* Number of elements in lower triangle of the X`X matrix *;
 %LET NMATRIX = %EVAL((&NREPWTS+1)*&NMAT) ;
 %* Need an X`X matrix for each weight *;
 %IF &NMATRIX > 1000000 %THEN %DO ;
  %PUT WARNING: This request demands a lot of RAM memory ;
  %PUT
 * It uses &MAXPARS parameters and &NREPWTS replicate weights ;
  %PUT
 * As a result, one matrix in the program has &NMATRIX elements ;
  %PUT
 * It will be slow if your computer has insufficient RAM ;
  %PUT * Possible ways to improve speed by: ;
  %PUT * . Use of the BY statement, or ;
  %PUT * . Running repeatedly on subsets of the replicates ;
 %END ;
 %IF &MAXCATS = 0 %THEN %LET NPREDICT = 0 ;
 %IF (&WTDRES) OR (&NPREDICT>0)
 %THEN %LET NVECTOR = %EVAL(&MAXPARS*(1+&MAXCATS*&NVD)) ;
 %ELSE %LET NVECTOR = &MAXPARS ;
 %IF &NREPWTS <=30 %THEN %LET NWREPORT = &NREPWTS ;
 %ELSE %LET NWREPORT = 30 ; %* Report on first 30 replicates *;

 %LOCAL WRFLAG;
 %IF (%BQUOTE(&WROUT)^=) & (&WTDRES) & (&MAXCATS>0) %THEN %DO ;
  %LET WRFLAG = 1 ;
  %IF %BQUOTE(&WRLIST)= %THEN %LET WRLIST=wr_1 ;
 %END ;
 %ELSE %LET WRFLAG = 0 ;

 data cw_wtd(keep=_bygrp_ cwunitid &BYVARS &STRATUM &VARGRP &GROUP
                  _inwt_ &WEIGHT &REPWTS &WRWEIGHT &CATKEEP
  %IF (&MAXCATS > 0) & (&NPREDICT>0) %THEN hat_1-hat_&NPREDICT ;
            )

      cw_out(keep=_bygrp_ cwunitid &BYVARS &STRATUM &VARGRP &GROUP
                  _inwt_ _regwt_ _regcwt_)
  %IF &WRFLAG %THEN
      cw_wrout(keep=&BYVARS &STRATUM &VARGRP _ncells_
                    &WRLIST) ;
      cwreport(keep=&BYVARS cw_iter _i2_ _i_ _bench_ _best_
                    _crit_ _report_
               rename=(_i2_=_b_))
      cwbyrep(keep=&BYVARS _iters_ _result_
                   _nilwt_ _negin_ _negwt_ cwfreq
%IF %BQUOTE(&GROUP)^= %THEN _gnilwt_ _gnegin_ _gnegwt_ _gfreq_ ;
                   rename=(cwfreq=_freq_))
  %IF &MAXCATS > 0 %THEN %DO ;
   cw_tab(keep=_est_ &BYVARS
   %IF %UPCASE(&VAR) ^= _ONE_ %THEN varname ;
   %DO I = 1 %TO &SCNUM ;
    &&CNAM&I
   %END ;
   %IF (&NREPWTS > 1) OR (&WTDRES) %THEN _var_ _se_ _rse_ ;
   %IF (&NREPWTS > 1) & (&WTDRES) %THEN _typ_ ;
   &OUTREPS
         )
  %END ;
      ;

  length _bygrp_ 4 ;
  %IF &MAXCATS > 0 %THEN %DO ;
   length
   %DO I = 1 %TO &NBYVARS ;
    &&BYVAR&I &&BYTYP&I
   %END ;
   %DO I = 1 %TO &SCNUM ;
    &&CNAM&I &&CTYP&I
   %END ;
   &VAR 8 ;
  %END ;

  %* For each benchmark specification: *;
  array cwncat{&MAXBEN} cwncat1-cwncat&MAXBEN ;
   %* No of categories *;
  array cwnvbl{&MAXBEN} _temporary_ (&NBENVBLS) ;
   %* No of variables *;
  array cwnrep{&MAXBEN} _temporary_ (&NBENREPS) ;
   %* No of replicates *;

  array cwcat{&MAXBEN} cwcat1-cwcat&MAXBEN ; %* Category id *;
  array cwvbl{&NNVBLS} &BENVBLS ; %* List of variables used *;
  %IF &NREPWTS > 0 %THEN %DO B = 1 %TO &MAXBEN ;
   %IF &&NB&B.RVAR > 0 %THEN %DO ;
    array cwrvbl&B{&&NB&B.VAR,&NREPWTS} &&B&B.RVAR ;
    array cwrvs&B{&NMAXGRPS,&&NB&B.VAR,&NREPWTS} _temporary_ ;
   %END ;
  %END ;

  array cwcats{1:&NMAXGRPS,&MAXBEN} _temporary_ ;
   %* cats from units in a group *;
  array cwvbls{1:&NMAXGRPS,&NNVBLS} _temporary_ ;
   %* vbls from units in a group *;

  array cwstatus{0:&NREPWTS} _temporary_ ;
   %* Status of calculations *;
  array cwepsi{0:&NREPWTS} _temporary_ ; %* epsilon *;
  array cwxben{0:&MAXRPARS} _temporary_ ; %* Benchmarks for X *;
  array cwxest{0:&NCWXEST} _temporary_ ; %* Estimates for X *;
  array cwadj {0:&NCWXEST} _temporary_ ;
   %* Adjustment is this times X *;
  array matrix{0:&NMATRIX} _temporary_ ;
   %* Lower triangle of X`X matrix *;
  array vector{0:&NVECTOR} _temporary_ ;
   %* Vector used in matrix operations *;
  %* Vector entries 1:&MAXPARS are for standard weighting,
     remaining entries will store beta parameters for tables *;

  %LET TEMP=%EVAL(&NWREPORT + 1) ;
  array cwreptxt{0:&MAXPARS} $ &TEMP _temporary_ ;
   %* Report on final status *;

  %IF &MAXCATS > 0 %THEN %DO ;
   %* Arrays to store values of each class and subclass variable
      corresponding to each category on the output table *;
   %IF &NPREDICT>0 %THEN %DO ;
    array tthat{1:&NPREDICT} hat_1-hat_&NPREDICT ;
    retain hat_1-hat_&NPREDICT ;
   %END ;
   %DO I = 1 %TO &SCNUM ;
    array ttc&I{0:&MAXCATS} &&CTYP&I _temporary_ ;
    %IF %SUBSTR(&&CTYP&I,1,1) = $
    %THEN %LET CTYP&I = '' ;
    %ELSE %LET CTYP&I = . ;
   %END ;
   %* Array to give position in ttsums array *;
   array ttposs{0:&MAXCATS} _temporary_ ;
   %IF &SCNUM > &CNUM %THEN %DO ;
    %* Position of denominator category *;
    array ttdposs{0:&MAXCATS} _temporary_ ;
   %END ;

   %* Array to store totals for each VAR and DENOM variable
      for every category on the output table *;
   array ttsums{0:&NREPWTS,0:&NVD_1,0:&MAXCATS} _temporary_ ;

   array ttvds{0:&NVD_1} &VAR &DENOM ;
   array ttvnam{0:&NVAR_1} $ 32 _temporary_ (&VARNAMES) ;
                                %* SAS V8 names can be 32 chars long *;
   array ttunpos{1:&NMAXGRPS} _temporary_ ;
   %* Stores position in category array for each unit in group *;
   array ttunvds{1:&NMAXGRPS,0:&NVD_1} _temporary_ ;

   %IF &WTDRES %THEN %DO ;
    array ttgest {0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttgpred{0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttrsum {0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttrssq {0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttrprod{0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttsvar {0:&NVD_1,0:&MAXCATS} _temporary_ ;
    array ttscov {0:&NVD_1,0:&MAXCATS} _temporary_ ;
   %END ;
  %END ;

  %* Status indicators are separate for each replicate weight.
     They take values
      0 has not converged yet
      n converged on iteration n
     After it has converged, no further computations occur
     for that weight until cw_iter=&MAXITER+1, when
      the final weights are computed,
      values are added into Y estimates, and
      unit data is output
  *;
  retain _cwreg_ 0 ;
  retain ttmaxcat ttnpsu cwgrpfst 0 ;

do cwbygrp = 1 to cwnumby ; %* For each BY group in turn *;
 %* Bring in this BY group *;
 set cw_by point=cwbygrp nobs=cwnumby ;
 _bygrp_=cwbygrp ;
 _nilwt_ = 0 ;
 _negin_ = 0 ;
 _negwt_ = 0 ;
 cwfreq  = 0 ;
%IF %BQUOTE(&GROUP)^= %THEN %DO ;
 _gnilwt_ = 0 ;
 _gnegin_ = 0 ;
 _gnegwt_ = 0 ;
 _gfreq_  = 0 ;
%END ;
 %* Bring in the benchmark data for this BY group *;
 _k_ = 0 ;
 %DO B = 1 %TO &MAXBEN ;
  do _i_ = 1 to cwnvbl{&B}*cwncat{&B}*(cwnrep{&B}+1) ;
   _k_ + 1 ;
   cwbenp&B + 1 ;
   set cwben&B point=cwbenp&B ;
   cwxben{_k_} = cwbentot ;
  end ;
 %END ;

 do _k_ = 0 to &NREPWTS ;
  cwstatus{_k_} = -1 ;
 end ;
 cwdone = 0 ; %* Not all weights have converged *;
 do _i_ = 0 to &NCWXEST ;
  cwadj{_i_} = 0 ;
 end ;

 do cw_iter = 0 to (&MAXITER+1) ;

  if ^cwdone or cw_iter > &MAXITER then do ;
*put cw_iter= ;
   %* Clear the arrays into which values will be aggregated *;
   do _i_ = 0 to &NCWXEST ;
    cwxest{_i_} = 0 ;
   end ;
   do _i_ = 0 to &NMATRIX ;
    matrix{_i_} = 0 ;
   end ;

   %* Bring in unit data for each unit in the BY group *;
   _unix_ = 0 ;
   cwgrpfst = 1 ; %* Next unit will be first in a group *;

   do cwunitid = cw_beg to cw_end ;
    cwuptr = cwunitid ;
    set cw_unit point=cwuptr ;

    array cwwt{0:&NREPWTS} &INWEIGHT &INREPWTS ;
    array cwgrpwt{0:&NREPWTS} _temporary_ ;
    array cwcutwt{0:&NREPWTS} _temporary_ ;
    array cwnewwt{0:&NREPWTS} &WEIGHT &REPWTS ;

    if _unix_ < &NMAXGRPS then do ;
     %* Store cat and vbl info for this unit in the group *;
     _unix_ + 1 ;
     do _ix_ = 1 to &MAXBEN ;
      cwcats{_unix_,_ix_} = cwcat{_ix_} ;
     end ;
     do _ix_ = 1 to &NNVBLS ;
      cwvbls{_unix_,_ix_} = cwvbl{_ix_} ;
     end ;
     %IF &NREPWTS > 0 %THEN %DO B = 1 %TO &MAXBEN ;
      %IF &&NB&B.RVAR > 0 %THEN %DO ;
       do cwj = 1 to &&NB&B.VAR ;
        do _ix_ = 1 to &NREPWTS ;
         cwrvs&B{_unix_,cwj,_ix_} = cwrvbl&B{cwj,_ix_} ;
        end ;
       end ;
      %END ;
     %END ;

     %IF &MAXCATS > 0 %THEN %DO ;
      if cw_iter > &MAXITER
      %IF (&WTDRES) OR (&NPREDICT>0) %THEN or cw_iter = 0 ;
      then do ;
       do ttj = 0 to &NVD_1 ;
        %* Store values for this unit *;
        %IF %BQUOTE(&OUTGRP)^= %THEN %DO ;
         if ^cwoutgrp then ttunvds{_unix_,ttj} = 0 ;
         else
        %END ;
        ttunvds{_unix_,ttj} = ttvds{ttj} ;
       end ;


       %* Now to find the table categories this unit belongs to
          The following code sets up categories for each unit
          _unix_ in the group, and sets ttunpos{_unix_} to point
          to the appropriate category.
          It also makes sure categories are set up for all
          required aggregates of the unit. *;
       ttcode = 0 ; %* Indicates nway cell not an aggregate *;
       %DO I = 1 %TO &SCNUM ;
        do ttix&I = 0
        %IF (&&CAG&I=1) OR (&I > &CNUM) %THEN to 1 ;;
         if ttix&I = 0 then ttc&I{0} = &&CNAM&I ;
         else ttc&I{0} = &&CTYP&I ; %* Missing *;
         if (ttix&I = 0) or (&&CNAM&I ^= &&CTYP&I) then
       %END ;
        if ttcode >= 0 then do ; %* Look for the category *;
         ttlo = 0 ;
         tthi = ttmaxcat + 1 ;
         ttdone = tthi <= (ttlo + 1) ;
         %* 0 = continue search for this category
            1 = category not in arrays
            2 = category found in arrays *;
         do while(^ttdone) ;
          tti = int(0.5*(ttlo+tthi)) ;
          %DO I = 1 %TO &SCNUM ;
           if ttc&I{tti} < ttc&I{0} then ttlo = tti ;
           else if ttc&I{0} < ttc&I{tti} then tthi = tti ;
           else
          %END ;
          do ;
           ttdone = 2 ; %* Found it *;
          end ;
          if ^ttdone then ttdone = tthi <= (ttlo + 1) ;
         end ;
         if ttdone = 2 and ttcode = 0 then do ;
          ttcode = -1 ;
          %* A category for this unit already exists
           - so its aggregates will already exist
           - hence no need to look for aggregates *;
          ttunpos{_unix_} = ttposs{tti} ;
         end ;
         else if ttdone = 2 then do ;
          %* This aggregate is already there *;
          ttcode = 1 ;
         end ;
         else if ttmaxcat < &MAXCATS then do ;
          %* Didnt find this category *;
          do tti = ttmaxcat to tthi by -1 ;
           %* Move these up to make space *;
           %DO I = 1 %TO &SCNUM ;
            ttc&I{tti+1} = ttc&I{tti} ;
           %END ;
           ttposs{tti+1} = ttposs{tti} ;
          end ;
          ttmaxcat = ttmaxcat + 1 ;
          if ttcode = 0 then ttunpos{_unix_} = ttmaxcat ;
          %* Data for this category goes here *;
          %DO I = 1 %TO &SCNUM ; %* Store category identifiers *;
           ttc&I{tthi} = ttc&I{0} ;
          %END ;
          ttposs{tthi} = ttmaxcat ;
          %* Store position of data for this category *;
          if ttcode = 0 then ttnway = ttmaxcat ;

          do ttw = 0 to &NREPWTS ;
           do ttj = 0 to &NVD_1 ;
            ttsums{ttw,ttj,ttmaxcat} = 0 ;
            %* Clear for later use *;
           end ;
          end ;

          %IF &WTDRES %THEN %DO ;
           %* Clear information for the new category *;
%*TESTPR(ttmaxcat)  ;
           do ttj = 0 to &NVD_1 ;
            do ttw = 1 to &MAXPARS ;
             ttsub = (&NVD*(ttmaxcat-1)+ttj+1)*&MAXPARS + ttw ;
%*TESTPR(ttsub)   ;
             vector{(&NVD*(ttmaxcat-1)+ttj+1)*&MAXPARS + ttw}
              = 0 ;
            end ;
            ttgest{ttj,ttmaxcat} = 0 ;
            ttgpred{ttj,ttmaxcat} = 0 ;
            ttrsum{ttj,ttmaxcat} = 0 ;
            ttrssq{ttj,ttmaxcat} = 0 ;
            ttrprod{ttj,ttmaxcat} = 0 ;
            ttsvar{ttj,ttmaxcat} = 0 ;
            ttscov{ttj,ttmaxcat} = 0 ;
           end ;
%*TESTPR(ttj)  ;
          %END ;
          %ELSE %IF &NPREDICT>0 %THEN %DO ;
           do ttj = 0 to &NVD_1 ;
            do ttw = 1 to &MAXPARS ;
             vector{(&NVD*(ttmaxcat-1)+ttj+1)*&MAXPARS + ttw}
              = 0 ;
            end ;
           end ;
          %END ;

          ttcode = 1 ;
         end ;
         else do ;
          call symput("GO_END","1") ;
          stop ;
         end ;
        end ;
       %DO I = 1 %TO &SCNUM ;
        end ;
       %END ;

       %IF &NPREDICT>0 %THEN %DO ;
        if cw_iter > &MAXITER & cwgrpfst
        then do ttw = 1 to &NPREDICT ;
         tthat{ttw} = 0 ;
        end ;
       %END ;

      end ;
     %END ; %* IF &MAXCATS > 0 *;
    end ; %* if _unix_ *;

    if cwgrpfst = 1 then do ; %* first in group *;
     do _ix_ = 0 to &NREPWTS ;
      %* group weight is weight from first in group *;
      cwgrpwt{_ix_} = cwwt{_ix_} ;
     end ;
     cwgrpfst = 0 ;
%IF %BQUOTE(&PENALTY)^= %THEN %STR(cwgrppen = &PENALTY ;) ;
    end ;
    %* Code for average weight or harmonic mean weight *;
    %IF &MEANWT = A %THEN %DO ;
     else do _ix_ = 0 to &NREPWTS ;
      cwgrpwt{_ix_} = ((_unix_-1)*cwgrpwt{_ix_}
                             + cwwt{_ix_}) /_unix_ ;
     end ;
    %END ;
    %ELSE %IF &MEANWT = H %THEN %DO ;
     else do _ix_ = 0 to &NREPWTS ;
      if cwgrpwt{_ix_} > 0 & cwwt{_ix_} > 0 then
      cwgrpwt{_ix_} = _unix_/((_unix_-1)/cwgrpwt{_ix_}
                                  + 1/cwwt{_ix_}) ;
     end ;
    %END ;


    if cwgrpflg>=1 then do ; %* last in group *;
     cwnunits = _unix_ ;

     %* First compute the weight for this iteration *;
     if cw_iter = 0 then do ;
      do _k_ = 0 to &NREPWTS ;
       cwnewwt{_k_} = cwgrpwt{_k_} ;
       cwcutwt{_k_} = cwgrpwt{_k_} ;
      end ;
     end ;
     else do ;
      %* Formula to be applied here is given by
         newwt = weight*restrict(1 + x*cwadj,&LOCODE,&UPCODE)
         where restrict applies the range restrictions *;
      do _k_ = 0 to &NREPWTS ;
       if (cwstatus{_k_}=-1) or (cw_iter>&MAXITER) then
        cwcutwt{_k_} = 0 ; %* Start to compute new weight *;
      end ;
      do _unix_ = 1 to cwnunits ; %* Go through units in group *;
       cwbase = 0 ; %* X columns for this benchmark start here *;
       cwvbase = 0 ; %* Variables start here *;
       do _b_ = 1 to &MAXBEN ; %* For each benchmark *;
        %* If this benchmark applies go through each variable *;
        if cwcats{_unix_,_b_} > 0
        then do _j_ = 1 to cwnvbl{_b_} ;
         %* Column of X affected by this benchmark *;
         _i_ = cwbase + (cwcats{_unix_,_b_}-1)*cwnvbl{_b_}
               + _j_ ;
         do _k_ = 0 to &NREPWTS ;
          cwtemp = cwvbls{_unix_,cwvbase+_j_} ;
          %IF &NREPWTS > 0 %THEN %DO B = 1 %TO &MAXBEN ;
           %IF &&NB&B.RVAR > 0 %THEN %DO ;
            if _b_=&B & _k_>0
            then cwtemp = cwrvs&B{_unix_,_j_,_k_} ;
           %END ;
          %END ;
          if (cwstatus{_k_}=-1) or (cw_iter>&MAXITER) then
          cwcutwt{_k_} + cwadj{&MAXPARS*_k_+_i_}*cwtemp
%IF %BQUOTE(&PENALTY)^= %THEN / cwgrppen ;
          ;
         end ;
        end ;
        cwbase + cwnvbl{_b_}*cwncat{_b_} ;
        cwvbase + cwnvbl{_b_} ;
       end ;
      end ; %* do _unix_ *;

      if cw_iter=1 & cw_iter<=&MAXITER then do ;
       %* Put on the GREG unit data output dataset *;
       _k_ = 0 ;
       _inwt_ = cwgrpwt{_k_} ;
       if (cwgrpwt{_k_}=0) or (cwgrpwt{_k_}=.) then do ;
        _regwt_ = 0 ;
        _regcwt_ = 0 ;
       end ;
       else do ;
        _regwt_ = cwgrpwt{_k_}*&DISTANCE ;
        _regcwt_ = max(&LOCODE,min(&UPCODE,_regwt_)) ;
       end ;
       output cw_out ;
       if _cwreg_=0 then do ;
        call symput("CWREG","1") ;
        _cwreg_=1 ;
       end ;
      end ;

      do _k_ = 0 to &NREPWTS ;
       if (cwstatus{_k_}=-1) or (cw_iter>&MAXITER) then do ;
        if (cwgrpwt{_k_}=0) or (cwgrpwt{_k_}=.) then do ;
         cwcutwt{_k_} = 0 ;
         cwnewwt{_k_} = 0 ;
        end ;
        else do ;
         cwcutwt{_k_} = cwgrpwt{_k_}*&DISTANCE;

         %* New value before imposing upper and lower bounds *;
         cwnewwt{_k_} = max(&LOCODE,min(&UPCODE,cwcutwt{_k_})) ;
         %* New value after imposing bounds *;
         if cwcutwt{_k_} ^= cwnewwt{_k_} then cwcutwt{_k_} = 0 ;
         else cwcutwt{_k_} = &CWDIST2 ;
         %* cwcutwt is set to 0 for weights set to a boundary *;
        end ;
       end ;
      end ;

     end ;

     %* Now run through the different benchmarks
        and hence through each x value for this unit. *;
     do _unix_ = 1 to cwnunits ;

      %IF &MAXCATS > 0 %THEN %DO ;
       if cw_iter > &MAXITER then do ;
        %* Add weighted values into table cells
           (but not marginals) *;
        do ttw = 0 to &NREPWTS ;
         do ttj = 0 to &NVD_1 ;
          if ttunvds{_unix_, ttj} > .z %* i.e. not missing *;
          then do ;
           %* Overall estimates *;
           %IF %BQUOTE(&WRWEIGHT)^= %THEN %DO ;
            if ttw = 0 then ttsums{ttw,ttj,ttunpos{_unix_}}
            + &NEWWT*ttunvds{_unix_,ttj} ;
            else
           %END ;
           ttsums{ttw,ttj,ttunpos{_unix_}}
            + cwnewwt{ttw}*ttunvds{_unix_,ttj} ;
          end ;
         end ;
        end ;
        %IF (&WTDRES) OR (&NPREDICT>0) %THEN %DO ;
         do ttj = 0 to &NVD_1 ;
          if ttunvds{_unix_, ttj} > .z %* i.e. not missing *;
          then do ;
           %* Weighted totals of y variables
              (needed at group level) *;
           %IF &WTDRES %THEN %DO ;
            ttgest{ttj,ttunpos{_unix_}}
             + &NEWWT*ttunvds{_unix_,ttj} ;
           %END ;
           %IF &NPREDICT>0 %THEN %DO ;
            ttw = (ttunpos{_unix_}-1)*&NVD+ttj+1 ;
           %END ;
          end ;
         end ;
        %END ;
       end ;
      %END ; %* IF &MAXCATS > 0 *;

      cwbase = 0 ; %* X columns for this benchmark start here *;
      cwvbase = 0 ; %* Variables for this benchmark start here *;
      do _b_ = 1 to &MAXBEN ; %* For each benchmark *;
       %* If this benchmark applies go through each variable *;
       if cwcats{_unix_,_b_} > 0 then do _j_ = 1 to cwnvbl{_b_} ;
        if cwvbls{_unix_,cwvbase+_j_}>.z then do ;
         %* Column of X affected by this benchmark *;
         _i_ = cwbase + (cwcats{_unix_,_b_}-1)*cwnvbl{_b_}
               + _j_ ;

         %* Calculate the X estimates *;
         do _k_ = 0 to &NREPWTS ;
          cwtemp = cwvbls{_unix_,cwvbase+_j_} ;
          %IF &NREPWTS > 0 %THEN %DO B = 1 %TO &MAXBEN ;
           %IF &&NB&B.RVAR > 0 %THEN %DO ;
            if _b_=&B & _k_>0
            then cwtemp = cwrvs&B{_unix_,_j_,_k_} ;
           %END ;
          %END ;
          if cwstatus{_k_}=-1 or cw_iter>&MAXITER then
          cwxest{&MAXPARS*_k_+_i_} + cwnewwt{_k_}*cwtemp ;
         end ;
         %IF (&WTDRES) OR (&NPREDICT>0) %THEN %DO ;
          if cw_iter = 0 then do _unix2_ = 1 to cwnunits ;
           %* Add x*y into vector elements for this category *;
           do ttj = 0 to &NVD_1 ;
            if ttunvds{_unix2_, ttj} > .z %* i.e. not missing *;
            then
            vector{(&NVD*(ttunpos{_unix2_}-1)+ttj+1)*&MAXPARS
                   + _i_}
             + &NEWWT*cwvbls{_unix_,cwvbase+_j_}
               *ttunvds{_unix2_,ttj}
%IF %BQUOTE(&PENALTY)^= %THEN / cwgrppen ;
                ;
           end ;
          end ;
          if cw_iter > &MAXITER then do tti = 1 to ttmaxcat ;
           %* Add x*beta into prediction for this psu *;
           do ttj = 0 to &NVD_1 ;
            cwtemp = vector{(&NVD*(ttposs{tti}-1)+ttj+1)*&MAXPARS
                            + _i_} ;
             %* Element of beta corresponding to this x *;
            %IF &WTDRES %THEN %DO ;
             ttgpred{ttj,ttposs{tti}} +
              &NEWWT*cwvbls{_unix_,cwvbase+_j_}*cwtemp ;
            %END ;
            %IF &NPREDICT>0 %THEN %DO ;
             ttw = (tti-1)*&NVD+ttj+1 ;
             if ttw <= &NPREDICT then do ;
              tthat{ttw}
               + cwvbls{_unix_,cwvbase+_j_}*cwtemp ;
             end ;
            %END ;

           end ;
          end ;
         %END ; %* IF &WTDRES *;

         %IF &CWPSRAT %THEN %DO ;
          do _k_ = 0 to &NREPWTS ;
           cwtemp = cwvbls{_unix_,cwvbase+_j_} ;
           %IF &NREPWTS > 0 %THEN %IF &NB1RVAR > 0 %THEN %DO ;
            if _k_>0 then cwtemp = cwrvs1{_unix_,_j_,_k_} ;
           %END ;
           matrix{&NMAT*_k_+_i_} + cwcutwt{_k_}*cwtemp*cwtemp ;
          end ;
         %END ;
         %ELSE %DO ;
          %* Calculate the X`X matrix *;
          do _unix2_ = 1 to cwnunits ;
           cwbase2 = 0 ;
           cwvbase2 = 0 ;
           do _b2_=1 to _b_ ;
            cwcatb = cwcats{_unix2_,_b2_} ;
            if cwcatb > 0
            & ((_b2_<_b_) or (cwcatb <= cwcats{_unix_,_b_}))
            then do ;
             if _b2_=_b_ & cwcatb = cwcats{_unix_,_b_}
             then cwtemp = _j_ ;
             else cwtemp = cwnvbl{_b2_} ;
             do _j2_ = 1 to cwtemp ;
              _i2_ = cwbase2 + (cwcats{_unix2_,_b2_}-1)
                               *cwnvbl{_b2_} + _j2_ ;
              %* Add into appropriate element of lower triangle *;
              do _k_ = 0 to &NREPWTS ;
               cwtemp = cwvbls{_unix_,cwvbase+_j_} ;
               cwtemp2 = cwvbls{_unix2_,cwvbase2+_j2_} ;
               %IF &NREPWTS > 0 %THEN %DO B = 1 %TO &MAXBEN ;
                %IF &&NB&B.RVAR > 0 %THEN %DO ;
                 if _b_=&B & _k_>0
                 then cwtemp = cwrvs&B{_unix_,_j_,_k_} ;
                 if _b2_=&B & _k_>0
                 then cwtemp2 = cwrvs&B{_unix2_,_j2_,_k_} ;
                %END ;
               %END ;
               if cwstatus{_k_}=-1 or cw_iter>&MAXITER then
               matrix{&NMAT*_k_+_i_*(_i_-1)/2 + _i2_}
                + cwcutwt{_k_}*cwtemp*cwtemp2
%IF %BQUOTE(&PENALTY)^= %THEN / cwgrppen ;
                ;
              end ;
             end ;
            end ;
            cwbase2 + cwnvbl{_b2_}*cwncat{_b2_} ;
            cwvbase2 + cwnvbl{_b2_} ;
           end ;
          end ; %* do _unix2_ *;
         %END ;
        end ;
       end ;

       %* Now move to base values for next benchmark *;
       cwbase + cwnvbl{_b_}*cwncat{_b_} ;
       cwvbase + cwnvbl{_b_} ;
      end ;
     end ; %* do _unix_ *;

     _unix_ = 0 ;
     cwgrpfst = 1 ;

     %* Put on the unit data output dataset *;
     if cw_iter>&MAXITER then do ;
      _inwt_ = cwgrpwt{0} ;
      if (_inwt_ = 0) or (_inwt_ = .) then _nilwt_ + cwnunits ;
      else cwfreq + cwnunits ;
      if . < &WEIGHT < 0 then _negwt_ + cwnunits ;
      if . < _inwt_ < 0 then _negin_ + cwnunits ;
      %IF %BQUOTE(&GROUP)^= %THEN %DO ;
       if (_inwt_ = 0) or (_inwt_ = .) then _gnilwt_ + 1 ;
       else _gfreq_ + 1 ;
       if . < &WEIGHT < 0 then _gnegwt_ + 1 ;
       if . < _inwt_ < 0 then _gnegin_ + 1 ;
      %END ;

      output cw_wtd ;
     end ;

    end ; %* if cwgrpflg *;

    %IF &MAXCATS > 0 %THEN %DO ;
     %* This part aggregates across table categories
        i.e. for computing the marginals from the nway values *;

     if cw_iter > &MAXITER
     %IF &WTDRES %THEN & (cwgrpflg >=2) or (cw_iter=0) ;
     %ELSE %IF &NPREDICT > 0 %THEN & (cwgrpflg >= 4) or (cw_iter=0) ;
     & cwgrpflg >= 4
     then do ;
     do ttfrom = 1 to ttmaxcat ; %* For every category *;
      ttpos = ttposs{ttfrom} ; %* Where the data is *;

      %IF &SCNUM > &CNUM %THEN %DO ;
       %IF &WTDRES %THEN if cwgrpflg = 4 & cw_iter=0 then ;
       if 1
       %DO I = &CNUM+1 %TO &SCNUM ;
        & ttc&I{ttfrom} = &&CTYP&I %* Missing *;
       %END ;
       then ttdposs{ttpos} = ttpos ;
       else ttdposs{ttpos} = -1 ;
       %*TESTPR(ttfrom ttc1{ttfrom} ttdposs{ttpos}) *;
      %END ;

      ttcode = 0 ;
      %DO I = 1 %TO &SCNUM ;
       do ttix&I = 0
       %IF (&&CAG&I=1) OR (&I > &CNUM) %THEN to 1 ;;
       if ttix&I = 0 then ttc&I{0} = ttc&I{ttfrom} ;
       else ttc&I{0} = &&CTYP&I ; %* Missing *;
       if (ttix&I = 0) or (ttc&I{ttfrom} ^= &&CTYP&I) then
      %END ;
       if ttcode = 0 then ttcode = 1 ;
        %* Dont need to find the category itself *;
       else do ; %* Look for the category *;
        ttlo = 0 ;
        tthi = ttfrom ;
         %* Look to the left of the current category *;
        ttdone = tthi <= (ttlo + 1) ;
         %* 0 = continue search for this category
            1 = category not in arrays
            2 = category found in arrays *;
        do while(^ttdone) ;
         tti = int(0.5*(ttlo+tthi)) ;
         %DO I = 1 %TO &SCNUM ;
          if ttc&I{tti} < ttc&I{0} then ttlo = tti ;
          else if ttc&I{0} < ttc&I{tti} then tthi = tti ;
          else
         %END ;
         do ;
          ttdone = 2 ; %* Found it *;
          ttcpos = ttposs{tti} ; %* Where to aggregate to *;

          %IF &SCNUM > &CNUM %THEN %DO ;
           if ttdposs{ttpos}=-1
           %DO I = &CNUM+1 %TO &SCNUM ;
            & ttc&I{tti} = &&CTYP&I %* Missing *;
           %END ;
           then ttdposs{ttpos} = ttposs{tti} ;
          %END ;

          %* Aggregate into this cell *;
          if cw_iter > &MAXITER & cwgrpflg >=4
          then do ttw = 0 to &NREPWTS ;
           do ttj = 0 to &NVD_1 ;
            ttsums{ttw,ttj,ttcpos} + ttsums{ttw,ttj,ttpos} ;
           end ;
          end ;
          %IF (&WTDRES) OR (&NPREDICT >0) %THEN %DO ;
           if cw_iter = 0 then do ttj = 0 to &NVD_1 ;
            %* Aggregate vector ready for obtaining beta *;
            %* This is the change made on 6/8/2001 in order to fix
               the weighted residuals variances for &VAR with more
               than 1 element: previously it assumed NVD = 1 *;
            do ttw = 1 to &MAXPARS ;
             vector{(&NVD*(ttcpos-1)+ttj+1)*&MAXPARS + ttw}
              + vector{(&NVD*(ttpos-1)+ttj+1)*&MAXPARS + ttw} ;
            end ;
           end ;
           %IF &WTDRES %THEN %DO ;
            if cw_iter>&MAXITER then do ttj = 0 to &NVD_1 ;
             %* Aggregate estimates at psu level *;
             ttgest{ttj,ttcpos} + ttgest{ttj,ttpos} ;
            end ;
           %END ;
          %END ;
         end ;
         if ^ttdone then ttdone = tthi <= (ttlo + 1) ;
        end ;
        if ttdone ^= 2 then do ;
         call symput("GO_END","1") ;
         stop ;
        end ;
       end ;
      %DO I = 1 %TO &SCNUM ;
       end ;
      %END ;
     end ;

     %LOCAL DORAT ;
     %IF (%BQUOTE(&DENOM)^=) OR (&SCNUM > &CNUM)
     %THEN %LET DORAT = 1 ;
     %ELSE %LET DORAT = 0 ;
     %IF &WTDRES %THEN %DO ;
     %* Now for each aggregation level *;
      if cw_iter>&MAXITER & cwgrpflg >= 2 then do ;
       ttnpsu + 1 ;
       %IF &WRFLAG %THEN %DO ;
        length _ncells_ &WRLIST 4 ;
        array ttwr{*} &WRLIST ;
        _ncells_ = min(dim(ttwr),ttmaxcat*(&NVD)) ;
        ttk = 0 ;
       %END ;
       do tti = 1 to ttmaxcat ;
        do ttj = 0 to &NVD_1 ;
         cwtemp = ttgest{ttj,tti} - ttgpred{ttj,tti} ;
         %IF &WRFLAG %THEN %DO ;
          ttk + 1 ;
          ttcpos = ttposs{tti} ;
          if ttk<=dim(ttwr) then
           ttwr{ttk} = ttgest{ttj,ttcpos} - ttgpred{ttj,ttcpos} ;
         %END ;

%*TESTPR(ttj tti (ttgest{ttj,tti}) (ttgpred{ttj,tti})) ;
         ttrsum{ttj,tti} + cwtemp ;
         ttrssq{ttj,tti} + cwtemp*cwtemp ;
         %IF &DORAT %THEN %DO ;
          %* Product with denominator residual *;
          if ttj < &NVAR then do ;
            %IF &SCNUM>&CNUM %THEN tttemp = ttdposs{tti} ;
            %ELSE tttemp = tti ;;
            ttw = min(&NVAR+ttj,&NVD_1) ;
%*TESTPR(ttj ttw tttemp)  ;
            ttrprod{ttj,tti}
            + cwtemp*(ttgest{ttw,tttemp} - ttgpred{ttw,tttemp}) ;
          end ;
         %END ;
        end ;
       end ;
       %IF &WRFLAG %THEN %STR(output cw_wrout ;) ;
       do tti = 1 to ttmaxcat ;
        do ttj = 0 to &NVD_1 ;
         ttgest{ttj,tti} = 0 ;
         ttgpred{ttj,tti} = 0 ;
        end ;
       end ;
       if cwgrpflg >=3 then do ; %* last in stratum *;
        ttnpsu = max(2,ttnpsu) ;
        do tti = 1 to ttmaxcat ;
         do ttj = 0 to &NVD_1 ;
          ttsvar{ttj,tti} + ttnpsu/(ttnpsu-1)
            *(ttrssq{ttj,tti} - (ttrsum{ttj,tti}**2)/ttnpsu) ;
          %IF &DORAT %THEN %DO ;
           ttw = min(&NVAR+ttj,&NVD_1) ;
           %IF &SCNUM>&CNUM %THEN tttemp = ttdposs{tti} ;
           %ELSE tttemp = tti ;;
           ttscov{ttj,tti} + ttnpsu/(ttnpsu-1)
                *(ttrprod{ttj,tti}
                  - ttrsum{ttj,tti}*ttrsum{ttw,tttemp}/ttnpsu) ;
          %END ;
         end ;
        end ;
        ttnpsu = 0 ;
        do tti = 1 to ttmaxcat ;
         do ttj = 0 to &NVD_1 ;
          ttrssq{ttj,tti} = 0 ;
          ttrsum{ttj,tti} = 0 ;
          %IF &DORAT %THEN %STR(ttrprod{ttj,tti} = 0 ;) ;
         end ;
        end ;
        if cwgrpflg >=4 then do ; %* last in BY *;
         %* Nothing here - output later *;

        end ;
       end ;
      end ; %* if cwgrpflg >= 2 ; *;
     %END ; %* IF &WTDRES *;

    end ; %* if cwgrpflg >= *;

   %END ; %* IF &MAXCATS > 0 *;

  end ; %* do cwunitid *;

  cwdimen=cw_nb ;
  do _b_=0 to &NREPWTS ;
   if cwstatus{_b_}=-1 or cw_iter>&MAXITER then do ;
    %* Decompose this X`X matrix *;
    cwmbase = _b_*&NMAT ;
    link decomp ;
   end ;
  end ;

  %IF &EXTRA %THEN %DO ;
   if cw_iter=0 then put "BY group " &PUTBY ":" @ ;
  %END ;
  %* Output decomposed X`X matrix *;
  %*if cw_iter=0 then do ;
  %* array cwxtx{&NMAT} xtx1-xtx&NMAT ;
  %* do _b_ = 1 to cw_nb*(cw_nb+1)/2 ;
  %*  cwxtx{_b_} = matrix{_b_} ;
  %* end ;
  %* output &RUNID.B&STEP ;
  %*end ;

  cwreport = (cw_iter>&MAXITER) or (cw_iter<=1) ;
  _result_ = 'C' ;
  if cwreport then do _i_ = 1 to &MAXPARS ;
   %* Prepare for reporting whether benchmarks match *;
   cwreptxt{_i_}=repeat(".",&NWREPORT) ;
  end ;

  do _b_ = 0 to &NREPWTS ;
   cwstat = cwstatus{_b_} ;
   if cwstat=-1 or cw_iter>&MAXITER then do ;
    %IF &EXTRA %THEN %DO ;
     if cw_iter>&MAXITER>0 & _b_=0 then
     if cwstat=-1 then put
" did not converge in &MAXITER iterations"  ;
     else if cwstat > 1 then put
" converged in" cwstat 3. " iterations" ;
     else if cwstat = 0 then put
" no iterations required" ;
     else put " used 1 iteration" ;
     else if cw_iter>&MAXITER & &MAXITER=0 & _b_=0 then
       if cwstat = 0 then put " no iterations required" ;
     else put " used 1 iteration" ;
    %END ;

    if cw_iter>&MAXITER>0 & _b_=0 then
     if cwstat=-1 then _iters_ = . ;
     else if (cwstat > 1) or (cwstat = 0) then _iters_ = cwstat ;
     else _iters_ = 1 ;
    else if cw_iter>&MAXITER & &MAXITER=0 & _b_=0 then
     if cwstat = 0 then _iters_ = 0 ;
     else _iters_ = 1 ;

    cwepsi{_b_} = 0 ;

    cwbase = 0 ;
    _i_ = 0 ;
    do _i2_ = 1 to &MAXBEN ;
     if cwnrep{_i2_} = 0 then _ir_ = cwbase+1 ;
     else _ir_ = cwbase + _b_ + 1 ;
     do _i3_ = 1 to cwncat{_i2_}*cwnvbl{_i2_} ;
      _i_ + 1 ;
      vector{_i_} = cwxben{_ir_} - cwxest{&MAXPARS*_b_+_i_} ;
      _ir_ + (cwnrep{_i2_} + 1) ;
     end ;
     cwbase + cwncat{_i2_}*cwnvbl{_i2_}*(1+cwnrep{_i2_}) ;
    end ;

    cwmbase = _b_*&NMAT ;
    ttvbase = 0 ;
    link solve ;

    cwbase = 0 ;
    _i_ = 0 ;

    do _i2_ = 1 to &MAXBEN ;
     if cwnrep{_i2_} = 0 then _ir_ = cwbase+1 ;
     else _ir_ = cwbase + _b_+1 ;
     do _i3_ = 1 to cwncat{_i2_}*cwnvbl{_i2_} ;
      _i_ + 1 ;
      if 1 or (cwxben{_ir_} > &EPSILON) then do ;
       %* Sensible constraint *;
       cwtemp = abs(cwxben{_ir_} - cwxest{&MAXPARS*_b_+_i_})
                / max(1,abs(cwxben{_ir_})) ;
       if abs(vector{_i_}) > 1E-9  %* Adjustment worth doing *;
       then do ;
        cwepsi{_b_} = max(cwepsi{_b_},cwtemp) ;
        if cwreport then if cwtemp > &EPSILON then do ;
         if _b_ = 0 then _result_='N' ;
         else if _result_ = 'C' then _result_='R' ;
         if _b_<=&NWREPORT
         then substr(cwreptxt{_i_},_b_+1,1) = "N" ;
        end ;
%*put "Benchmark" _i_ 4. " not met, criterion=" cwtemp best8. ;
       end ;
       else if cwreport
       then if cwtemp > &EPSILON then do ;
        if _b_ = 0 & _result_^='N' then _result_='I' ;
         else if _result_='C' then _result_='R' ;
        if _b_<=&NWREPORT
        then substr(cwreptxt{_i_},_b_+1,1) = "I" ;
%*put "Benchmark" _i_ 4. " impossible, criterion=" cwtemp best8.;
       end ;
      end ;
      _ir_ + (cwnrep{_i2_} + 1) ;
     end ;
     cwbase + cwncat{_i2_}*cwnvbl{_i2_}*(1+cwnrep{_i2_}) ;
    end ;

    if cwstatus{_b_} = -1 and cwepsi{_b_} < &EPSILON
    then cwstatus{_b_} = cw_iter ; %* Has now converged *;
    do _i_ = 1 to cw_nb ;
     %* Modify adjustment *;
     cwadj{&MAXPARS*_b_+_i_} + vector{_i_} ;
    end ;
   end ;
  end ;

  if cwreport then do ;
   cwbase = 0 ;
   _b_=0 ;
   _i_ = 0 ;

   do _i2_ = 1 to &MAXBEN ;
    if cwnrep{_i2_} = 0 then _ir_ = cwbase+1 ;
    else _ir_ = cwbase + _b_+1 ;
    do _i3_ = 1 to cwncat{_i2_}*cwnvbl{_i2_} ;
     _i_ + 1 ;
     _bench_=cwxben{_ir_} ;
     _best_=cwxest{&MAXPARS*_b_+_i_} ;
     if cwxben{_ir_} > &EPSILON then
      _crit_ = abs(cwxben{_ir_} - cwxest{&MAXPARS*_b_+_i_})
               / cwxben{_ir_} ;
      else _crit_=. ;
      _report_=cwreptxt{_i_} ;
      output cwreport ;
      _ir_ + (cwnrep{_i2_} + 1) ;
     end ;
     cwbase + cwncat{_i2_}*cwnvbl{_i2_}*(1+cwnrep{_i2_}) ;
    end ;
   end ;

   cwdone = 1 ;
   do _b_ = 0 to &NREPWTS ;
    cwdone = cwdone and cwstatus{_b_}>-1 ;
   end ;

   %IF (&WTDRES) OR (&NPREDICT>0) %THEN %DO ;
    if cw_iter = 0 then do ;
     %* Calculate beta parameters for each nway table cell *;
     cwmbase = 0 ; %* Use X`X matrix for the 0th weight *;
     do tti = 1 to ttmaxcat ;
      do ttj = 0 to &NVD_1 ;
       ttvbase = (&NVD*(tti-1)+ttj+1)*&MAXPARS ;
       %*TESTPR(ttvbase);
       %*TESTPR(vector{ttvbase+1} vector{ttvbase+2} ) ;
       link solve ;
       %*TESTPR(vector{ttvbase+1} vector{ttvbase+2}) ;
      end ;
     end ;
    end ;
   %END ;

   %IF &MAXCATS > 0 %THEN %DO ;
    if cw_iter > &MAXITER then do ;

     %* Now copy into variables for output *;
     do ttcat =1 to ttmaxcat ;
      %DO I = 1 %TO &SCNUM ;
       &&CNAM&I = ttc&I{ttcat} ;
      %END ;

      %DO I = 1 %TO &SCNUM ;
       %IF &&CAG&I^=1
       %THEN %STR(if ttc&I{ttcat} ^= &&CTYP&I then ) ;
      %END ;
      do ; %* if output required *;
       ttcpos = ttposs{ttcat} ;

       %IF &SCNUM > &CNUM %THEN %DO ; %* Some subclasses *;
        %* Find denominator class for this subclass *;
        ttpos = ttdposs{ttcpos} ;
       %END ;
       %ELSE %DO ;
        ttpos = ttcpos ;
       %END ;

       do ttj = 0 to &NVAR_1 ;
        varname = ttvnam{ttj} ;
        length _est_ 8 ;
        %IF &NREPWTS > 1 %THEN %DO ;
         length _var_ _se_ _rse_ 8 ;
         _var_ = 0 ;
        %END ;

        do ttw = 0 to &NREPWTS ;
         %IF %BQUOTE(&DENOM)=
         %THEN %IF &SCNUM > &CNUM %THEN %DO ;
          tttemp = ttsums{ttw,ttj,ttpos} ;
          if (tttemp = 0) or (tttemp <= .z) then tttemp = . ;
          else tttemp = ttsums{ttw,ttj,ttcpos} / tttemp ;
         %END ;
         %ELSE %DO ;
          tttemp = ttsums{ttw,ttj,ttcpos} ;
         %END ;
         %ELSE %DO ;
          tttemp = ttsums{ttw,min(&NVAR+ttj,&NVD_1),ttpos} ;
          if (tttemp = 0) or (tttemp <= .z) then tttemp = . ;
          else tttemp = ttsums{ttw,ttj,ttcpos} / tttemp ;
         %END ;
         if ttw = 0 then _est_ = tttemp ;
         %IF &NREPWTS > 1 %THEN %DO ;
          else if tttemp> .z then _var_ + (tttemp-_est_)**2 ;
         %END ;
         %IF %BQUOTE(&OUTREPS)^= %THEN %DO ;
          array ttrest{0:&NOUTREPS} _est_ &OUTREPS ;
          ttrest{ttw} = tttemp ;
         %END ;

        end ;
        %IF &NREPWTS > 1 %THEN %DO ;
         _var_ = _var_ * (&NREPWTS-1)/&NREPWTS ;
         _se_  = sqrt(max(0,_var_)) ;
         if _est_ <= 1E-12 then _rse_ = . ;
         else _rse_ = _se_ / _est_ ;
         _typ_ = 'J' ;
         %IF &WTDRES %THEN %STR(output cw_tab;) ;
        %END ;

        %IF &WTDRES %THEN %DO ;
%*TESTPR(ttj ttpos ttcpos) ;
         _var_=ttsvar{ttj,ttcpos} ;
         %IF &DORAT %THEN %DO ;
          %IF %BQUOTE(&DENOM)= %THEN %DO ;
           _var_ = (_var_ - 2*_est_*ttscov{ttj,ttcpos}
            + _est_*_est_*ttsvar{ttj,ttpos})
              / ttsums{0,ttj,ttpos}**2 ; ;
          %END ;
          %ELSE %DO ;
           _var_ = (_var_ - 2*_est_*ttscov{ttj,ttcpos}
            + _est_*_est_*ttsvar{min(&NVAR+ttj,&NVD_1),ttpos})
              / ttsums{0,min(&NVAR+ttj,&NVD_1),ttpos}**2 ; ;
          %END ;
         %END ;
         _se_  = sqrt(max(0,_var_)) ;
         if _est_ <= 1E-12 then _rse_ = . ;
         else _rse_ = _se_ / _est_ ;
         _typ_ = 'W' ;
        %END ;
        output cw_tab;
       end ;
%*put ttcat= tti= ttsums{0,ttcat}= ttsums{0,tti}= ttvds{0}= ;

      end ; %* if output required *;
     end ; %* do ttcat *;

     %* Clean up for next BY group *;
     %IF &WTDRES %THEN %DO ;
      do ttj = 0 to &NVD_1 ;
       do tti = 1 to ttmaxcat ;
        ttsvar{ttj,tti} = 0 ;
        ttscov{ttj,tti} = 0 ;
       end ;
      end ;
     %END ;
     ttmaxcat = 0 ;
    end ;
   %END ; %* IF &MAXCATS > 0 *;

  end ; %* if ^cwdone or cw_iter>&MAXITER *;

 end ; %* do cw_iter *;

 output cwbyrep ;



end ; %* do cwbyid *;
stop ;
return ;

%* linked code: decomp, solve:
   inputs are arrays matrix and vector
   and macro variables &DIMEN, &MBASE, &VBASE, &DECEPSI
     (which may name variables or give a number)
   outputs are changed matrix and vector
   Temporary variables used are _i_ _j_ _k_ _i2_ _j2_ *;
%LOCAL DIMEN MBASE VBASE DECEPSI ;
%LET DIMEN=cwdimen ;
%LET MBASE=cwmbase ;
%LET VBASE=ttvbase ;
decomp:
%*  Triangular decomposition:           j
    Symmetric matrix assumed.       1  2  4  7
    Numbering of cells is        i  2  3  5  8
      shown at right for            4  5  6  9
    &MBASE = 0, &DIMEN = 4          7  8  9 10
    That is, only the upper (or lower) half of the symmetric
    matrix is entered.  Result is an upper (or lower) triangular
    matrix U such that U`U = A, the original symmetric matrix.
*;

%LET DECEPSI = %SCAN(&DECEPSI?1e-8,1,?) ;
%IF &CWPSRAT %THEN ; %* No need to decompose if matrix is diagonal *;
%ELSE %DO ;
 _i2_ = &MBASE ;
 do _i_ = 1 to &DIMEN ;
  do _k_ = 1 to _i_-1 ;
   cwtemp = -matrix{_i2_+_k_} ;
   _j2_ = _i2_ ;
   if fuzz(cwtemp) ^= 0 then
   do _j_ = _i_ to &DIMEN ;
    matrix{_j2_+_i_} + cwtemp*matrix{_j2_+_k_} ;
    _j2_ + _j_ ;
   end ;
  end ;
  _j2_ = _i2_ ;
  do _j_ = _i_ to &DIMEN ;
   if _i_ = _j_ then if matrix{_i2_+_i_} < &DECEPSI
    then matrix{_i2_+_i_} = 0 ;
    else matrix{_i2_+_i_} = sqrt(matrix{_i2_+_i_}) ;
   else if matrix{_i2_+_i_} = 0 then matrix{_j2_+_i_} = 0 ;
   else matrix{_j2_+_i_} = matrix{_j2_+_i_}/matrix{_i2_+_i_} ;
   _j2_ + _j_ ;
  end ;
  _i2_ + _i_ ;
 end ;
%END ;
return ;

solve:
%* Given that matrix contains the triangular decomposition of A,
   (or the diagonal elements if A is diagonal i.e. if &CWPSRAT)
   and vector contains the elements of a vector b
   solve replaces vector with the elements of x
   such that Ax = b
*;

%IF &CWPSRAT %THEN %DO ;
 %* Simple solution if matrix is diagonal *;
 do _i_ = 1 to &DIMEN ;
  _k_ = &VBASE + _i_ ;
  _i2_ = matrix{&MBASE + _i_} ;
  if _i2_ > &DECEPSI then vector{_k_} = vector{_k_} / _i2_ ;
 end ;
%END ;
%ELSE %DO ;
 _i2_ = &MBASE ;
 do _i_ = 1 to &DIMEN ;
  _k_ = &VBASE+_i_ ;
  if matrix{_i2_+_i_} > &DECEPSI then do ;
   do _j_ = 1 to _i_-1 ;
    vector{_k_} + -matrix{_i2_+_j_}*vector{&VBASE+_j_} ;
   end ;
   vector{_k_} = vector{_k_} / matrix{_i2_+_i_} ;
  end ;
  _i2_ + _i_ ;
 end ;
 do _i_ = &DIMEN to 1 by -1 ;
  _j2_ = _i2_ ;
  _i2_ + -_i_ ;
  _k_ = &VBASE+_i_ ;
  if matrix{_i2_+_i_} > &DECEPSI then do ;
   do _j_ = _i_+1 to &DIMEN ;
    vector{_k_} + -matrix{_j2_+_i_}*vector{&VBASE+_j_} ;
    _j2_ + _j_ ;
   end ;
   vector{_k_} = vector{_k_} / matrix{_i2_+_i_} ;
  end ;
  else vector{_k_} = 0 ;
 end ;
%END ;

return ;
run ;


%* END OF MAIN CALCULATIONS PORTION *;
%CK_TRASH(cw_wtd)
%CK_TRASH(cw_out)
%CK_TRASH(cwreport)
%CK_TRASH(cwbyrep)

 %IF &GO_END=1 %THEN %DO ;
  %CHECKERR(1,Not enough space for calcs - increase MAXSPACE)
  %GOTO SKIPEND ;
 %END ;
 %ELSE %IF &EXTRA %THEN %DO ;
  %PUT Main calculations finished ; %PUT ;
 %END ;

 %IF &WRFLAG %THEN %DO ;
  options notes ;
  %PUT ;
  %PUT Output weighted residuals dataset: ;
  data &WROUT ;
   set cw_wrout ;
  run ;
  &NOTESOFF
  %CK_TRASH(cw_wrout)
 %END ;

%END ;

%LOCAL _REGWT_ _REGRAT_ CWCHANGE ;
%LET CWCHANGE = 0 ;
%LET CWFIRST = %EVAL(&CWFIRST & &CWREG) ;

data cw_wtd(drop=cwunitid cwchange) ;
  %IF &CWREG
  %THEN merge cw_wtd cw_out(keep=cwunitid _regwt_ _regcwt_) ;
  %ELSE set cw_wtd ;
   end=_last_ ;
  by cwunitid ;
  retain cwchange 0 ;
  %IF &CWREG %THEN %DO ;
    if _regwt_ & _inwt_ then _regrat_ = _regwt_/_inwt_ ;
    %LET _REGWT_=_regwt_ ;
    %LET _REGRAT_=_regrat_ ;
  %END ;
  if _inwt_ then do ;
    _wtrat_ = &WEIGHT/_inwt_ ;
    if abs(_wtrat_ - 1)>=0.05 then cwchange = 1 ;
  end ;
  output cw_wtd ;
  if _last_ then call symput("CWCHANGE",put(cwchange,1.)) ;
run ;
%LET CWREG = %EVAL(&CWREG & &CWCHANGE) ;
%*PR(cw_out(obs=30)) *;
%IF %BQUOTE(&GROUP)^= %THEN %DO ;
  data cw_wtd ;
    merge cw_unit(keep=&BYVARS &STRATUM &VARGRP &GROUP
      %IF &MAXBEN >=1 %THEN cwgrpflg cwcat1-cwcat&MAXBEN ;
          )
          cw_wtd ;
    &GRPCODE
  run ;
%*PR(cw_out(obs=30)) *;
%END ;

%* Diagnostic reports on unit weights *;

%IF &CWCHANGE %THEN %DO ;
 proc univariate data=cw_wtd(where=(&WEIGHT>0)) plot
 %IF %INDEX(&XOPTIONS,%STR( UNIV ))=0 %THEN noprint ;;
  label _inwt_="input weight"
        &WEIGHT="final weight"
        _wtrat_="final weight/input weight" ;
  var _inwt_ &WEIGHT _wtrat_ ;
  &CWTIT "Weights and weight changes, positive weights only" ;
  output out=cwuniv p1=i_p1  w_p1  wr_p1
                median=i_m   w_m   wr_m
                   p99=i_p99 w_p99 wr_p99
    ;
 run ;
%CK_TRASH(cwuniv)
%END ;
%LOCAL CWEXT ;
data cwext(drop=_one_ w_m cw_keep rename=(&WEIGHT=_finwt_)) ;
%IF &CWCHANGE %THEN %DO ;
  if _n_=1 then set cwuniv ;
   drop
    i_p1 w_p1 wr_p1
    i_m wr_m
    i_p99 w_p99 wr_p99
%END ;
%ELSE w_m = 0 ;;
  _one_ = 1 ;
  set cw_unit(keep=&BYVARS
      %DO B=1 %TO 30 ;
        &&B&B.CLASS &&B&B.VAR
      %END ;
     &STRATUM &VARGRP &GROUP &UNIT &ID &PENALTY) ;
  set cw_wtd(keep=&WEIGHT _inwt_ _wtrat_
    %IF &CWREG %THEN _regwt_ _regcwt_ _regrat_ ;
                   ) ;
  length severity 3 ;
  severity = 0 ;
  if . < &WEIGHT < 0 then severity = 8 ;
%IF &CWCHANGE %THEN %DO ;
  else if &WEIGHT > 0 then do ;
   if ^(w_p1 < &WEIGHT < w_p99) then severity + 4 ;
   if ^(wr_p1 < _wtrat_ < wr_p99) then severity + 2 ;
   %IF (&MAXITER > 0) & &CWREG %THEN %DO ;
    if _regwt_ ^= _regcwt_ then severity + 1 ;
   %END ;
  end ;
%END ;
   %IF (&MAXITER > 0) & &CWREG %THEN %DO ;
    drop _regcwt_ _regrat_ ;
   %END ;
  retain cw_keep 0 ;
  if severity > 0 then do ;
    if cw_keep = 0 then do ;
      if cw_keep = 0 then call symput("CWEXT","1") ;
      cw_keep = 1 ;
    end ;
    if severity = 2 then do ;
      if _wtrat_<= wr_p1 then do ;
        severity = -1 ;
        _order_ = _wtrat_ ;
      end ;
      else do ;
        severity = 1 ;
        _order_ = -_wtrat_ ;
      end ;
    end ;
    else do ;
      if severity = 1 then severity = 2 ;
      if &WEIGHT < w_m then do ;
        severity = -severity ;
        _order_ = &WEIGHT ;
      end ;
      else _order_=-&WEIGHT ;
    end ;
    output cwext ;
  end ;
run ;
proc sort data=cwext ;
  by severity _order_ ;
run ;
options notes ;
%PUT ;
%IF &PRINTREP & (&CWEXT^=1) %THEN
 %PUT Extreme units report (not printed, empty): ;
 %ELSE %PUT Extreme units report: ;
data &EXTOUT ;
 set cwext(drop=_order_) ;
run ;
&NOTESOFF
%LOCAL FULLID ;
%IF (&CWEXT=1) & (&PRINTREP) & (&EXTNO>0) %THEN %DO ;
 %IF %LENGTH(&REPORTID)=0 %THEN %DO ;
  %* Put together list of variables to be used as ID variables
      on the extreme values printout *;
  %LET FULLID = &BYVARS ;
  %DO B=1 %TO 30 ;
   %LET FULLID=&FULLID &&B&B.CLASS ;
  %END ;
  %LET FULLID=&FULLID &STRATUM &VARGRP &GROUP &UNIT ;
  %DO B=1 %TO 30 ;
   %LET FULLID=&FULLID &&B&B.VAR ;
  %END ;
  %LET FULLID = %UPCASE(&FULLID) ;

  %* TEMP will store the approximate number of characters required
     to print the REPORTID variables plus the weight information *;
  %IF &CWFIRST %THEN %LET TEMP = 38 ;
  %ELSE %LET TEMP = 30 ; %* characters required by weight information *;

  %* Now remove repeated variable names and the name _ONE_
     and cut down to a suitable number of variables for the linesize *;
  %DO I = 1 %TO 999 ;
   %LET WORD = %SCAN(&FULLID,&I) ; %* Next variable in FULLID *;
   %IF %LENGTH(&WORD)=0 %THEN %LET I = 1000 ; %* Leave loop *;
   %ELSE %DO ;
    %IF %INDEX(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ _ONE_ &REPORTID @,
               %STR( &WORD )) = 0 %THEN %DO ; %* Not in REPORTID *;
     %LET TEMP = %EVAL(&TEMP + 2 + %LENGTH(&WORD)) ;
      %* Assume each variable requires as many characters to print as
         the length of its name + 2 . *;
     %IF &TEMP <= &LINESIZE %THEN %LET REPORTID = &REPORTID &WORD ;
     %ELSE %LET I = 1000 ; %* No room for more variables on line *;
    %END ;
   %END ;
  %END ;
 %END ;
 %GREGPEXT(DATA=cwext, EXTNO=&EXTNO, ID=&REPORTID, FIRST=&CWFIRST
 ,OPTIONS=&OPTIONS, TITLELOC=&TITLELOC)
%END ;

%CK_TRASH(cwext)

options notes ; %* put on output log *;
%IF &PRINTREP & (&CWCHANGE^=1) %THEN
%PUT Benchmark report(s) (not printed, <1% change to any weight): ;
%ELSE %PUT Benchmark report(s): ;
&NOTESOFF
%* Diagnostic reports on benchmarks *;
data cwbenout ;
  merge cwreport(where=(cw_iter>&MAXITER))
        cwreport(where=(cw_iter=0)
          keep=&BYVARS _i_ _best_ cw_iter rename=(_best_=_iest_))
     %IF &CWREG %THEN
       cwreport(where=(cw_iter=1)
        keep=&BYVARS _i_ _best_ cw_iter rename=(_best_=_rest_)) ;
        ;
  by &BYVARS _i_ ;
  drop cw_iter ;
run ;
%CK_TRASH(cwbenout)

%LOCAL CONPROB ;
%DO B = 1 %TO &MAXBEN ;
 %LET CONPROB = 0 ;
 options notes ;
  data &BENPREF&B&BENSUFF ;
   merge cwrep&B cwbenout(where=(_b_=&B)) end=_last_ ;
   retain cw_prob cw_prob2 0 ;
   by &BYVARS _i_ ;

   if _value_ ^= _bench_ then cw_prob2 = 1 ;
   if _report_^=repeat(".",&NWREPORT) then cw_prob = 1 ;
   if _last_ & cw_prob then call symput("CONPROB","1") ;
   if _last_ & cw_prob2
   then put "WARNING: Report benchmarks mismatched" ;
   drop _i_ _b_ _value_ cw_prob2 ;
  run ;
 &NOTESOFF
 %IF &PRINTREP %THEN %DO ;
  %IF &CWCHANGE=1 %THEN %DO ;
   %LET REPORTID = &BYVARS &&B&B.CLASS ;
   %IF &&NB&B.VAR>1 %THEN %LET REPORTID = &REPORTID _name_ ;
   %GREGPBEN(DATA=&BENPREF&B,BY=&BY,ID=&REPORTID,OPTIONS=&OPTIONS
   ,FIRST=&CWFIRST,TITLELOC=&TITLELOC) ;

   %IF (&NREPWTS>0) & &CONPROB %THEN %DO ;
    %GREGPBEN(DATA=&BENPREF&B,BY=&BY,ID=&REPORTID,OPTIONS=&OPTIONS
    ,FIRST=&CWFIRST,TITLELOC=&TITLELOC,TYPE=2) ;
   %END ;
  %END ; %* If &CWCHANGE *;
 %END ;
%END ;

options notes ;
%PUT Report on overall convergence for BY groups: ;
data &BYOUT ;
 set cwbyrep ;
run ;
&NOTESOFF
%IF &PRINTREP %THEN %DO ;
 %GREGPBY(DATA=cwbyrep,BYVARS=&BYVARS
 ,OPTIONS=&OPTIONS,GROUP=&GROUP,TITLELOC=&TITLELOC) ;
%END ;

options notes ;
%IF &MAXCATS > 0 %THEN %DO ;
%PUT Output table data set: ;
  data &OUT ;
    set cw_tab ;
  run ;
  %CK_TRASH(cw_tab)
%END ;
%PUT Output weighted unit data set: ;
data &OUTDSN ;
  set cw_unit
  %IF &KEEPID %THEN %DO ;
    (keep=&BYVARS
      %DO B=1 %TO 30 ;
        &&B&B.CLASS &&B&B.VAR
      %END ;
     &STRATUM &VARGRP &GROUP &UNIT &ID
     &CLASS &SUBCLASS &VAR &DENOM)
  %END ;
  %ELSE %DO ;
    (drop=cwgrpflg
    %IF &MAXBEN >=1 %THEN cwcat1-cwcat&MAXBEN ;
    )
  %END ;
  ;
  set cw_wtd(keep=&WEIGHT &REPWTS
%IF (&MAXCATS > 0) & (&NPREDICT>0) %THEN hat_1-hat_&NPREDICT ;
  ) ;
  _one_=1 ;
  drop _one_ ;
run ;
&NOTESOFF

%SKIPEND:
%* Any problems cause a jump to here *;

%LET GO_END = ;

data _null_ ;
  call symput("ELAPTIME",put(datetime() - &ELAPTIME, tod7.)) ;
run ;

%IF %INDEX(&XOPTIONS,%STR( DEBUG )) = 0
%THEN %CK_TRASH() ; %* Delete temporary datasets *;
&CWTIT ;
options &ORIGNOTE ;
%PUT
NOTE: The macro &MACID took elapsed time &ELAPTIME (hh:mm:ss) ;
%PUT ;

%MEND GREGWT ;
