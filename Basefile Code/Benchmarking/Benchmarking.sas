
**************************************************************************************
* Program:      Benchmarking.sas                                                     *
* Description:  Perform benchmarking of CAPITA basefiles to the set of demographic   *
*               and administrative benchmarks contained in the Benchmarks.xlsx       *
*               spreadsheet.                                                         * 
**************************************************************************************;
OPTIONS NOFMTERR MINOPERATOR ;

%MACRO RunBenchmarking ;

    * STEP ONE - Initialisation ;
    * This module will set the relevant libname for the basefile and for output ;

    %Initialise 

    * STEP TWO - Read in all of the Benchmarks ;

    %BenchIn 
    * The rest of the code runs through for each year ;

	%LET BMYearsList = &SurveyYear ;
    %DO BMY = %SYSEVALF( &SurveyYear + 1 ) %TO %SYSEVALF( &SurveyYear + 7 ) ;
        %LET BMYearsList = &BMYearsList - &BMY ;                      
            * This provides the list of years we want to benchmark to ;
    %END ;

    %PUT Now Benchmarking for years &BMYearsList ;

    %DO y = 1 %TO ( %SYSFUNC(COUNTW( &BMYearsList , '-' ) ) ) ; 
        %LET BMYear = %SCAN( &BMYearsList , &y , '-' ) ; 
        %LET BMYearL1 = %EVAL( &BMYear - 1 ) ; 
        
        * Create Capita_Outfile in the work folder running for the particular benchmarking year ;
        %GLOBAL RunBenchmarkFlag ;
        %LET RunBenchmarkFlag = Y ;

        PROC SORT 
            DATA = Basefile&BMYear ;
            BY HHID FamID IUID ;
        RUN ;

        %INCLUDE "&RunCapita" ;

        %CreatePreBenchMark 

        * Add on the appropriate Start Weights ;

        %IF &BMYear = &SurveyYear %THEN %DO ;

            DATA PersonBenchmark ;
                SET PersonBenchmark ;
                In_wgt = IUWeightSu ;
            RUN ;

        %END ;

        %ELSE %DO ;

            DATA OldWts ;
                SET NewWts(KEEP = HHID FamID IUID Psn new_wgt) ;
                BY HHID FamID IUID Psn ;
            RUN ;

            DATA PersonBenchmark ;
                MERGE PersonBenchmark OldWts ;
                BY HHID FamID IUID Psn ;
                RENAME new_wgt = In_wgt ;
            RUN ;

		%Preweight

        %END ;

        * Use GregWt to hit our benchmarks ;

        %GregWtWriter

        %GREGWT( &&GregWtCall&BMyear )

        DATA _BYOUT_ ;
            SET _BYOUT_ ;
            CALL SYMPUT('result', _result_ ) ;
        RUN ; 

        %IF &result = C %THEN %DO;
            %PUT ***** BENCHMARKING CONVERGED FOR &BMYear ***** ;
        %END ;

        %ELSE %DO ;
            %PUT ***** ERROR: BENCHMARKING FAILED TO CONVERGE FOR &BMYear ***** ;
            %ABORT CANCEL ;
        %END ;

        * Finally merge the new weights onto a new benchmarked file ;

        PROC SORT DATA = NewWts ;
            BY HHID FamID IUID Psn ;
        RUN ;

        DATA PersonBenchmarked&BMyear ;
            MERGE PersonBenchmark NewWts(KEEP = HHID FamID IUID Psn new_wgt ) ;
            BY HHID FamID IUID Psn ;
        RUN ;

        DATA WeightMerge&BMYear ;
            SET PersonBenchmarked&BMyear(KEEP = IUID new_wgt) ;
            BY IUID ;
            IF First.IUID THEN OUTPUT ;
            RENAME new_wgt = weight ;
        RUN ;

        PROC SORT DATA = WeightMerge&BMYear ;
            BY IUID ;  
        RUN ;

        DATA bsOUTlb.basefile&BMYear ;
            MERGE bsINlb.basefile&BMYear WeightMerge&BMYear ;
            BY IUID ;
        RUN ;

    %END ;

%MEND RunBenchmarking ;

/* STEP ONE: Tell us what to do, what to do it on, what's saved where */

%MACRO Initialise ;

    %GLOBAL Basefilecreate ;

    %IF &Basefilecreate = Y %THEN %DO ;

        %LET Work = %SYSFUNC( GETOPTION( Work ) ) ;
        LIBNAME bsINlb "&Work" ;
        LIBNAME bsOUTlb "&Work" ;

    %END ;

    %ELSE %DO ;

        %LET Work = %SYSFUNC( GETOPTION( Work ) ) ;
        LIBNAME bsINlb "&CapitaDirectory.Basefiles\" ;
        LIBNAME bsOUTlb "&Work" ;

        * Will create the full Capita policy code run basefile, 
            which will be stored in the Work directory as Capita_Outfile ;
        %GLOBAL RunCapita ;
        %LET RunCapita = &CapitaDirectory.RunCAPITA.sas ;

        * Year of the SIH survey ;
        %GLOBAL SurveyYear ;
        %LET SurveyYear = 2013 ;

        * Location of the benchmarks and the GregWt module ;
        %GLOBAL Benchfolder ;
        %LET Benchfolder = &CapitaDirectory.Basefile Code\Benchmarking\ ;

    %END ;

    * Excel spreadsheet in which full benchmarks for all years are stored, with a tab for each benchmark ;

    %GLOBAL BenchmarkIn ;
    %LET BenchmarkIn = &Benchfolder.Benchmarks.xlsx ;

    * Include the Macro for GregWt ;

    %INCLUDE "&Benchfolder.GregWt.sas" ;

    * THE SURVEY YEAR BENCHMARKS ;

    * The benchmarks we wish to hit in GREGWT for the year which apply at an individual / flagging level ;

    %GLOBAL BenchList1 ;
    %LET BenchList1 = 			BmAgeBySex -
                                BmLabForceStat -
                                BmHousehold -
                                BmPaymentType -
                                BmCarerAllow -
                                BmFTBA -
                                BmFTBB -
                                BmBabies
                                ;

    * The benchmarks we wish to hit in GREGWT for the year which requires aggregation over individuals - eg benchmarking to dollars, or children numbers ;

    %GLOBAL BenchList2 ;
    %LET BenchList2 = 			BmFtbaKids ;

    * OUT YEARS BENCHMARKS ;

    * Can create different lists, to benchmark to different variables in different years.
      Default is the same for all years. ;            

    /* Insert new lists here */ 
    /*                       */
    /*                       */
    /* Insert new lists here */ 

    %DO BMY = &SurveyYear %TO %SYSEVALF( &SurveyYear + 7 ) ;

        %GLOBAL BenchList1_&BMY ;
        %LET BenchList1_&BMY = &BenchList1 ;               

        %GLOBAL BenchList2_&BMY ;
        %LET BenchList2_&BMY = &BenchList2 ;

    %END ;

    * The complete list of all variables of interest, for comparison and/or benchmarking ;

    %GLOBAL benchlist ;
    %LET benchlist = BmAgeBySex -
                     BmLabForceStat -
                     BmHousehold -
                     BmPaymentType -
                     BmCarerAllow -
                     BmFTBA -
                     BmFTBB -
                     BmFtbaKids -
                     BmBabies
                     ;

    %GLOBAL benchkeeplist ;
    %LET benchkeeplist = %SYSFUNC( COMPRESS ( &benchlist , '-' ) ) ;

    %GLOBAL benchvarlist ;
    %LET benchvarlist = BmFtbaKids ;

	* The benchmark used for pre-weighting - select aggregate benchmark for pre-GREGwt population growth ;

	%GLOBAL benchpreweight ;
	%LET benchpreweight = BmAgeBySex ;

    * Variables which apply to all members of the income unit ;

    %GLOBAL unitlist ;
    %LET unitlist =     HHID -
                        FAMID -
                        IUID -
                        Psn -
                        IUWeightSU -
                        IUTypeSU -
                        AgeYoungDepU -
                        CoupleU -
                        FamilyCompH - 
                        DepsFtbA -
                        FtbaFinalA -
                        FtbbFinalA - 
                        StateH -
                        NpdFlag -
                        Kids0U -
                        Kids0to14U -
						PartnerCheckFlag -
						WifePenAgeCheckFlag
                        ;

    * Variables of interest which are recorded for all members of the income unit ;

    %GLOBAL varlistfam ;
    %LET varlistfam =   ActualAge -
                        AllowType -
                        LfStat -
                        PenType -
                        Sex -
                        StudyType
                        ;

    * Variables of interest which are recorded for reference and spouse for the income unit ;

    %GLOBAL varlistcoup ;
    %LET varlistcoup =  CareAllFlag -
                        DvaType -
                        DvaDisPenSW
                        ;

    * Variables of interest which are recorded for the spouse only ;

    /*%GLOBAL varlistsps ;*/
    /*%LET varlistsps = ;*/

    * Variables of interest which are recorded for the reference person only ;

    /*%GLOBAL varlistref ;*/
    /*%LET varlistref =     ;*/

    %GLOBAL personsfam ;
    %LET personsfam =   r -
                        s -
                        1 -
                        2 -
                        3 -
                        4 
                        ;

    %GLOBAL personsps ;
    %LET personssps =   s ;

    %GLOBAL personsref ;
    %LET personsref =   r ;

    %GLOBAL personscoup ;
    %LET personscoup =  r -
                        s
                        ;

%MEND Initialise ;
 
/* STEP TWO: Read in the benchmarks */

%MACRO BenchIn ;

    * Macro to find sheets in the global benchmarks.xlsx spreadsheet and read them in as individual datasets. ;
    * Sheet names in the spreadsheet must match those in the benchmark list and the flag variable names. ;

    %DO i = 1 %TO %SYSFUNC( countw( &benchlist , '-' ) ) ;
        %LET bnch = %SCAN( &benchlist , &i , '-' ) ;   
        * set bnch = name of the benchmark, which must match its variable identifier name below ;

        PROC IMPORT 
            DATAFILE="&BenchmarkIn"
            REPLACE OUT = &bnch DBMS = excelcs;
            SHEET = "&bnch";
        RUN;

    %END ;

%MEND BenchIn ;

* STEP THREE: Attach new flags to the basefile for benchmarking in each year ;

/* First create a person level file containing the information we care about */

%MACRO IndPersData(pers) ;

   %LET keeplist&pers = %SYSFUNC( COMPRESS( &unitlist , '-' ) ) ; 
    
    DATA PsnBnchmrk&pers ;
        SET Capita_Outfile ;
        FORMAT _ALL_ ;

/* 		Flag all records in a unit if there is a partner recipient, to allow for pre-benchmark re-weighting */

		IF (AllowTyper = "PARTNER" OR AllowTypes = "PARTNER") THEN PartnerCheckFlag = 1;
		ELSE PartnerCheckFlag = 0 ;

/* 		Set weight of Wife Pensioners over age pension age to zero - flag all records to allow for pre-benchmark re-weighting */

		IF (WifePenSWs > 0 AND ActualAges >= FemaleAgePenAge) THEN WifePenAgeCheckFlag = 1;
		ELSE WifePenAgeCheckFlag = 0 ;

/*		* Split out to different person type individual datasets ;*/

        %DO i = 1 %TO %SYSFUNC( countw( &&persons&pers , '-' ) ) ;    
            %LET suffix = %SCAN( &&persons&pers , &i , '-' ) ;   
            IF actualage&suffix > 0 THEN DO ;                   
                Psn = "&suffix" ;
    
                %DO j = 1 %TO %SYSFUNC( countw( &&varlist&pers , '-' ) ) ;   
                    %LET var = %SCAN( &&varlist&pers , &j , '-' ) ; 
                    %IF &i = 1 %THEN %DO ; 
                        %LET keeplist&pers = &&keeplist&pers &var ; 
                    %END ;
                        
                    &var = &var.&suffix ;
                    
                %END ;
                OUTPUT PsnBnchmrk&pers ;
            END ;
        %END ;

        KEEP &&keeplist&pers ; 
    RUN ;

    PROC SORT DATA = PsnBnchMrk&pers ;
        BY IUID Psn ;
    RUN;

%MEND IndPersData ;


%MACRO CreatePreBenchmark ;

    * A macro which will create the person level data set to benchmark to as well as create flags. ;

    * Create the Person level data set with relevant variables required for flagging ;

    %IndPersData(coup) 
    %IndPersData(fam) 

    DATA PersonBenchmark ;
        MERGE PsnBnchmrkcoup PsnBnchmrkfam ;
        BY IUID Psn ;
    RUN ;

    * Label basefile for benchmarking ;

    DATA PersonBenchmark ;
        LENGTH  &benchkeeplist $ 64 ;
        SET PersonBenchmark ;
        BY HHID FamID IUID Psn ;

        * Label Age by Sex ;

        IF sex = 'M' THEN DO ;
            IF ActualAge LE 15 THEN BmAgeBySex = '01. 15 male' ;
            ELSE IF ActualAge LE 16 THEN BmAgeBySex = '02. 16 male' ;
            ELSE IF ActualAge LE 17 THEN BmAgeBySex = '03. 17 male' ;
            ELSE IF ActualAge LE 20 THEN BmAgeBySex = '04. 18 - 20 male' ;
            ELSE IF ActualAge LE 24 THEN BmAgeBySex = '05. 21 - 24 male' ;
            ELSE IF ActualAge LE 29 THEN BmAgeBySex = '06. 25 - 29 male' ;
            ELSE IF ActualAge LE 34 THEN BmAgeBySex = '07. 30 - 34 male' ;
            ELSE IF ActualAge LE 39 THEN BmAgeBySex = '08. 35 - 39 male' ;
            ELSE IF ActualAge LE 44 THEN BmAgeBySex = '09. 40 - 44 male' ;
            ELSE IF ActualAge LE 49 THEN BmAgeBySex = '10. 45 - 49 male' ;
            ELSE IF ActualAge LE 54 THEN BmAgeBySex = '11. 50 - 54 male' ;
            ELSE IF ActualAge LE 59 THEN BmAgeBySex = '12. 55 - 59 male' ;
            ELSE IF ActualAge LE 64 THEN BmAgeBySex = '13. 60 - 64 male' ;
            ELSE IF ActualAge LE 69 THEN BmAgeBySex = '14. 65 - 69 male' ;
            ELSE IF ActualAge LE 74 THEN BmAgeBySex = '15. 70 - 74 male' ;
            ELSE /* IF ActualAge GT 74 THEN */ BmAgeBySex = '16. 75+ male' ;
        END ;

        ELSE IF sex = 'F' THEN DO ;
            IF ActualAge LE 15 THEN BmAgeBySex = '17. 15 female' ;
            ELSE IF ActualAge LE 16 THEN BmAgeBySex = '18. 16 female' ;
            ELSE IF ActualAge LE 17 THEN BmAgeBySex = '19. 17 female' ;
            ELSE IF ActualAge LE 20 THEN BmAgeBySex = '20. 18 - 20 female' ;
            ELSE IF ActualAge LE 24 THEN BmAgeBySex = '21. 21 - 24 female' ;
            ELSE IF ActualAge LE 29 THEN BmAgeBySex = '22. 25 - 29 female' ;
            ELSE IF ActualAge LE 34 THEN BmAgeBySex = '23. 30 - 34 female' ;
            ELSE IF ActualAge LE 39 THEN BmAgeBySex = '24. 35 - 39 female' ;
            ELSE IF ActualAge LE 44 THEN BmAgeBySex = '25. 40 - 44 female' ;
            ELSE IF ActualAge LE 49 THEN BmAgeBySex = '26. 45 - 49 female' ;
            ELSE IF ActualAge LE 54 THEN BmAgeBySex = '27. 50 - 54 female' ;
            ELSE IF ActualAge LE 59 THEN BmAgeBySex = '28. 55 - 59 female' ;
            ELSE IF ActualAge LE 64 THEN BmAgeBySex = '29. 60 - 64 female' ;
            ELSE IF ActualAge LE 69 THEN BmAgeBySex = '30. 65 - 69 female' ;
            ELSE IF ActualAge LE 74 THEN BmAgeBySex = '31. 70 - 74 female' ;
            ELSE                         BmAgeBySex = '32. 75+ female' ;
        END ;

        * Label Labour force status ;

        IF LFstat = 'FT'            THEN BmLabForceStat = '01. FT' ;
        ELSE IF LFstat = 'PT'       THEN BmLabForceStat = '02. PT' ;
        ELSE IF LFstat = 'UNEMP'    THEN BmLabForceStat = '03. Unemployed' ;
        ELSE IF LFstat = 'NILF'     THEN BmLabForceStat = '04. NILF' ; 

        * Label State Household - Label only applies once per household ;

        IF First.HHID AND NpdFlag = 0 THEN DO ;
            IF StateH = 'NSW'       THEN BmHousehold = '01. NSW' ;
            ELSE IF StateH = 'VIC'  THEN BmHousehold = '02. VIC' ;
            ELSE IF StateH = 'QLD'  THEN BmHousehold = '03. QLD' ;
            ELSE IF StateH = 'SA'   THEN BmHousehold = '04. SA' ;
            ELSE IF StateH = 'WA'   THEN BmHousehold = '05. WA' ;
            ELSE IF StateH = 'TAS'  THEN BmHousehold = '06. TAS' ;
            ELSE IF StateH = 'ACT or NT' THEN BmHousehold = '07. ACT / NT' ;
        END ;
      
        * Label Payment Type ;

        IF PenType          = 'AGE'     THEN BmPaymentType = '01. AgePen' ;
        ELSE IF PenType     = 'DSP'     THEN BmPaymentType = '02. DSP' ;
        ELSE IF PenType     = 'DSPU21'  THEN BmPaymentType = '02. DSP' ;
        ELSE IF PenType     = 'CARER'   THEN BmPaymentType = '03. CarerPay' ;
        ELSE IF PenType     = 'WIFE'    THEN BmPaymentType = '04. WifePen' ;
        ELSE IF AllowType   = 'NSA'     THEN BmPaymentType = '05. NSA' ; 
        ELSE IF AllowType   = 'YAOTHER' THEN BmPaymentType = '06. YAOther' ;
        ELSE IF AllowType   = 'YASTUD'  THEN BmPaymentType = '07. YAStud' ;
        ELSE IF AllowType   = 'SICK'    THEN BmPaymentType = '08. SickAllow' ;
        ELSE IF AllowType   = 'SPB'     THEN BmPaymentType = '09. SpecBft' ;
        ELSE IF AllowType   = 'PPP'     THEN BmPaymentType = '10. PPP' ;
        ELSE IF PenType     = 'PPS'     THEN BmPaymentType = '11. PPS' ;
        ELSE IF AllowType   = 'WIDOW'   THEN BmPaymentType = '12. WidAllow' ;
        ELSE IF DVAType = 'DVASERVDIS' THEN BmPaymentType = '13. DvaServDis' ;
        ELSE IF DVAType = 'SERVICE' THEN BmPaymentType = '14. DvaServ' ;
        ELSE IF DVAType = 'DVADIS'  THEN BmPaymentType = '15. DvaDis' ;
        ELSE IF DVAType = 'WARWID'  THEN BmPaymentType = '16. DvaWWid' ; 
        ELSE IF AllowType = 'AUSTUDY' THEN BmPaymentType = '17. Austudy' ;
		ELSE IF AllowType = 'PARTNER' THEN BmPaymentType = '18. Partner' ;

        * Label Carer Allowance ;

        IF CareAllFlag > 0 THEN BmCarerAllow = '01. CarerAllow' ;
     
        * Label FTBA - Label applies only once per income unit ;

        IF First.IUID THEN DO ;        
            IF FtbaFinalA > 0 THEN BmFTBA = '01. FTBA' ;
        END ;

        * Label FTBB - Label applies only once per income unit ;

        IF First.IUID THEN DO ;         
            IF FtbbFinalA > 0       THEN BmFTBB = '01. FTBB' ;
        END ;

        * Label Family Tax Benefit Part A Children - Label applies only once per income unit ;
        
        IF First.IUID THEN DO ;       
            IF DepsFtbA > 0 AND FtbaFinalA > 0    THEN DO ;
                                        BmFTBAKids = '01. FTB-A Children' ;
                                        BmFTBAKidsCount = DepsFtbA ;
            END ;
        END ;
        
        * Label Baby Flag - Label applies only once per income unit ;

        IF kids0U > 0 AND First.IUID THEN BmBabies = '01. Babies' ;    
 
    RUN ;

%MEND CreatePreBenchmark ;

/* STEP FOUR: BROAD uprating of weights to improve start weights */

%MACRO Preweight() ;

/* Store the target values as macro variables for age by sex  */
	DATA _NULL_ ;
		SET &benchpreweight ;
		RETAIN TotalPop TotalPopL1 0 ;
			TotalPop = TotalPop + y&BMYear ;
			TotalPopL1 = TotalPopL1 + y&BMYearL1 ;
		%GLOBAL y&BMYear._Total_Pop y&BMYearL1._Total_Pop ;
		CALL SYMPUT("y&BMYear._Total_Pop" , TotalPop ) ;
		CALL SYMPUT("y&BMYearL1._Total_Pop" , TotalPopL1 ) ;
	RUN ;

/* Preweight the benchmarks for Partner Allowance to assist with convergence */
/* Store the target values for Partner Allowance benchmarks as macro variables */
	DATA _NULL_ ;
		SET BMPaymentType ;
			WHERE BMPaymentType = "18. Partner" ; 
		%GLOBAL y&BMYear._Partner_Pop y&BMYearL1._Partner_Pop ;
		CALL SYMPUT("y&BMYear._Partner_Pop" , y&BMYear ) ;
		CALL SYMPUT("y&BMYearL1._Partner_Pop" , y&BMYearL1 ) ;
	RUN ;


/* Pre-weight by adjusting the weights sequentially */

DATA PersonBenchmark ;
	SET PersonBenchmark ;
	
		In_wgt = In_wgt * (&&y&BMYEAR._Total_Pop / &&y&BMYEARL1._Total_Pop) ;

/* Also adjust weights manually to account for grandfathered payments */
	/* Partner Allowance */

	%IF &BMYear > 2015 %THEN %DO ;
		IF PartnerCheckFlag = 1 THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._Partner_Pop / &&y&BMYEARL1._Partner_Pop) ;
		END ;
	%END ;

/*Set weights of observations to zero*/
	/*Wife Pensioners over age pension age - 2017-18 Budget Working Age Payment Reforms*/ 
	%IF &BMYear >= 2020 %THEN %DO; 
		IF WifePenAgeCheckFlag = 1 THEN DO; 
			In_wgt = 0 ; 
		END; 
	%END; 	

	DROP PartnerCheckFlag ;
	DROP WifePenAgeCheckFlag; 

RUN ;

%MEND Preweight ;

/* STEP FIVE: GREGWT to hit the benchmarks */

%MACRO GREGWTWriter ;

    * Development of code to automatically write GREGWT ;

    %LET GREGWTStart = UNITDSN = PersonBenchmark
                ,OUTDSN  = NewWts
                ,GROUP   = HHID
                ,UNIT    =
                ,ID      = Psn IUID FamID in_wgt
                ,PENALTY =
                ,BY      = 
                ,INWEIGHT= In_wgt
                ,WEIGHT  = new_wgt
                ,INREPWTS= 
                ,REPWTS  = 

    ;

    %LET GREGWTEnd =            ,MAXITER = 10
                ,UPPER   = 300%
                ,LOWER   = 50%
                ,EPSILON = 0.1
                ,OPTIONS = HMEAN
                
    ;

    %GLOBAL GREGWTCall&BMyear ;
    %LET GregWtCall&BMyear = &GregWtStart ;

    * Read in all of the GregWt lines for flagged variables at the person level ;

    %DO i = 1 %TO ( %SYSFUNC(countw( &&BenchList1_&BMyear , '-' ) ) ) ; 
    * loop through each of the benchmarks in the benchlist ; 
        %LET bnch = %SCAN( &&BenchList1_&BMyear , &i , '-' ) ;  
        * set bnch = name of the benchmark, which must match its dataset name ;

            %LET GregWtCall&BMyear = &&GregWtCall&BMyear        
                        ,B&i.DSN   = &bnch    ,B&i.CLASS  = &bnch       ,B&i.TOT  = Y&BMyear ;
    %END ;

    * Read in all of the GregWt lines which are benchmarked to aggregate sums, rather than number of people ;

    %DO j = 1 %TO ( %SYSFUNC(countw( &&BenchList2_&BMyear , '-' ) ) ) ; 
    * loop through each of the benchmarks in the aggregate variable benchlist ; 
        %LET bnch = %SCAN( &&BenchList2_&BMyear , &j , '-' ) ;   
        * set bnch = name of the benchmark, which must match its dataset name ;
        %LET k = %SYSEVALF ( &i + &j - 1 ) ;
            
            %LET GregWtCall&BMyear = &&GregWtCall&BMyear        
                        ,B&k.DSN   = &bnch    ,B&k.CLASS  = &bnch       ,B&k.TOT  = Y&BMyear       ,B&k.VAR = &bnch.count ;
    %END ;


    %LET GregWtCall&BMyear = &&GregWtCall&BMyear &GregWtEnd ;


%MEND GREGWTWriter ;

%RunBenchmarking ;
%SYMDEL BasefileCreate ;
