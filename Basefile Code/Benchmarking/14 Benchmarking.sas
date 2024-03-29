
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

	%LET result = C ;

	%LET BMYearsList = &SurveyYear ;
    %DO BMY = %SYSEVALF( &SurveyYear + 1 ) %TO %SYSEVALF (&EndYear) ;
        %LET BMYearsList = &BMYearsList - &BMY ;                      
            * This provides this list of years we want to benchmark to ;
    %END ;


    %PUT Now Benchmarking for years &BMYearsList ;

    %DO y = 1 %TO ( %SYSFUNC(COUNTW( &BMYearsList , '-' ) ) ) ; 
        %LET BMYear = %SCAN( &BMYearsList , &y , '-' ) ; 
        %LET BMYearL1 = %EVAL( &BMYear - 1 ) ; 
		%LET BMYearL2 = %EVAL( &BMYear - 2 ) ; 

		%IF &result = C %THEN %DO ; 
	        
	        * Create Capita_Outfile in the work folder running for the particular benchmarking year ;
	        %GLOBAL RunBenchmarkFlag ;
	        %LET RunBenchmarkFlag = Y ;

			* Do not benchmark for the 2020-21 year due to the unavailability of benchmarks ;
			%IF &BMYear <= 2019 OR &BMYEAR >= 2021 %THEN %DO;

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
				%Preweight

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

				PROC TEMPLATE ; 
				DEFINE STYLE StdExcel ;
				Notes "This is the Standard Output Style for GregWt, direct to Excel";
				    CLASS HEADER / BACKGROUNDCOLOR = Black COLOR = White FONTFAMILY = "Arial" FONTSIZE = 10pt 
				                   FONTWEIGHT = Bold ;
				    CLASS TABLE / CELLPADDING = 4pt CELLSPACING = 0pt FRAME = Void RULES = None ;
				    CLASS DATA / BACKGROUNDCOLOR = White COLOR = Black FONTFAMILY = "Arial" FONTSIZE = 8pt ;
				    CLASS BODY FROM DATA ;
				    CLASS ROWHEADER FROM DATA/ FONTWEIGHT = Bold ;
				END ;
				RUN ;

				GOPTIONS DEVICE = ACTXIMG ;
				ODS EXCEL ( ID = INT ) FILE = "&CapitaDirectory.Basefile Code\Benchmarking\GregWt Output\GregWtOutput&BMyear..xlsx"  STYLE = StdExcel
				    OPTIONS ( SHEET_INTERVAL = "PROC" 
				                EMBEDDED_TITLES="YES" EMBED_TITLES_ONCE = "YES" 
				                EMBEDDED_FOOTNOTES="YES" EMBED_FOOTNOTES_ONCE = "YES"
				                INDEX = "OFF" ) ;


				ODS EXCEL ( ID = INT ) OPTIONS ( SHEET_NAME = "GregWt" ) ;

		        %GREGWT( &&GregWtCall&BMyear )

				ODS EXCEL ( ID = INT ) CLOSE ;

		        DATA _BYOUT_ ;
		            SET _BYOUT_ ;
		            CALL SYMPUT('result', _result_ ) ;
		        RUN ; 

		        %IF &result = C %THEN %DO;

		            %PUT ***** BENCHMARKING CONVERGED FOR &BMYear ***** ;

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

		        %ELSE %DO ;

		            %PUT ERROR: BENCHMARKING FAILED TO CONVERGE FOR &BMYear ;

		        %END ;

	    	%END ;

		%END ;

	%END ;	 


%MEND RunBenchmarking ;

/* STEP ONE: Tell us what to do, where to do it on, what's saved where */

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

        * Will creates the full Capita policy code run basefile, 
            which will be stored in the Work directory as Capita_Outfile ;
        %GLOBAL RunCapita ;
        %LET RunCapita = &CapitaDirectory.RunCAPITA.sas ;
 
        * Year of the SIH survey ;
        %GLOBAL SurveyYear ;
        %LET SurveyYear = 2017 ; 

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

    * The benchmarks we wish to hit in GREGWT for the year which require aggregation over individuals - eg benchmarking to dollars, or children numbers ;

    %GLOBAL BenchList2 ;
    %LET BenchList2 = 			BmFtbaKids ;

    * OUT YEARS BENCHMARKS ;

    * Can create different lists, to benchmark to different variables in different years.
      Default is the same for all years. ;            

    /* Insert new lists here */ 
    /*                       */
    /*                       */
    /* Insert new lists here */ 

    %DO BMY = &SurveyYear %TO %SYSEVALF (&EndYear)  ;

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
                        Kids0SU -
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

* This code to be based largely off the cameo code / parameters read in ;

%MACRO BenchIn ;

    * Macro to find sheets in the global benchmarks.xlsx spreadsheet and read them in as individual datasets. ;
    * Sheet names in the spreadsheet must match those in the benchmark list and the flag variable names. ;

    %DO i = 1 %TO %SYSFUNC( countw( &benchlist , '-' ) ) ;
        %LET bnch = %SCAN( &benchlist , &i , '-' ) ;   
        * set bnch = name of the benchmark, which must match its variable identifier name below ;

        PROC IMPORT 
            DATAFILE="&BenchmarkIn"
            REPLACE OUT = &bnch DBMS = excelcs ;
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

		IF (AllowTyper = "PARTNER" OR AllowTypes = "PARTNER") THEN PartnerCheckFlag = 1 ;
		ELSE PartnerCheckFlag = 0 ;

/* 		Set weight of Wife Pensioners over age pension age to zero - flag all records to allow for pre-benchmark re-weighting */

		IF (WifePenSWs > 0 AND ActualAges >= FemaleAgePenAge) THEN WifePenAgeCheckFlag = 1 ;
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
        LENGTH  &benchkeeplist $64 ;
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
            ELSE IF StateH = 'NT' 	THEN BmHousehold = '07. NT' ;
            ELSE IF StateH = 'ACT' 	THEN BmHousehold = '08. ACT' ;
        END ;
      
        * Label Payment Type ;
/*** Exclude some small payments as they are phasing out in 2020 and 2021 ***/
        IF PenType          = 'AGE'     THEN BmPaymentType = '01. AgePen' ;
        ELSE IF PenType     = 'DSP'     THEN BmPaymentType = '02. DSP' ;
        ELSE IF PenType     = 'DSPU21'  THEN BmPaymentType = '02. DSP' ;
        ELSE IF PenType     = 'CARER'   THEN BmPaymentType = '03. CarerPay' ;
/*        ELSE IF PenType     = 'WIFE'    THEN BmPaymentType = '04. WifePen' ;*/
        ELSE IF AllowType   = 'JSP'     THEN BmPaymentType = '05. JSP' ; 
        ELSE IF AllowType   = 'YAOTHER' THEN BmPaymentType = '06. YAOther' ;
        ELSE IF AllowType   = 'YASTUD'  THEN BmPaymentType = '07. YAStud' ;
/*        ELSE IF AllowType   = 'SICK'    THEN BmPaymentType = '08. SickAllow' ;*/
        ELSE IF AllowType   = 'SPB'     THEN BmPaymentType = '09. SpecBft' ;
        ELSE IF AllowType   = 'PPP'     THEN BmPaymentType = '10. PPP' ;
        ELSE IF PenType     = 'PPS'     THEN BmPaymentType = '11. PPS' ;
/*        ELSE IF AllowType   = 'WIDOW'   THEN BmPaymentType = '12. WidAllow' ;*/
        ELSE IF DVAType = 'DVASERVDIS' THEN BmPaymentType = '13. DvaServDis' ;
        ELSE IF DVAType = 'SERVICE' THEN BmPaymentType = '14. DvaServ' ;
        ELSE IF DVAType = 'DVADIS'  THEN BmPaymentType = '15. DvaDis' ;
        ELSE IF DVAType = 'WARWID'  THEN BmPaymentType = '16. DvaWWid' ; 
        ELSE IF AllowType = 'AUSTUDY' THEN BmPaymentType = '17. Austudy' ;
/*		ELSE IF AllowType = 'PARTNER' THEN BmPaymentType = '18. Partner' ;*/

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

        IF kids0SU > 0 AND First.IUID THEN BmBabies = '01. Babies' ;    
 
    RUN ;

	* Sort PersonBenchmark by HHID to allow use of by statement in following datastep ;

	PROC SORT DATA = PersonBenchmark ;
		BY HHID ; 
	RUN ; 

	* We create a dataset to flag HHIDs that contain any records where there is a partner allowance or wife pension recipient. 
	This flag is used to identify groups (by HHID) to scale as a pre-benchmark weighting process.
	Our definition of recipient is in line with the definition used for contribution to a benchmark shown above. ;

    DATA ScaleIndicators (KEEP = HHID Scale: );
		SET PersonBenchmark ;
		BY HHID ;

	* The above by statement allows us to commands to identify the first and last record with the same HHID.
	The below retain statement will keep the last value of our indicators. 
	Make sure all indicators in RETAIN statement ;

		RETAIN /* ScalePTA */ ScaleSPL ScaleYAO ScaleJSP ScalePPP ScalePPS /*ScaleSKA*/ ScaleDWW ScaleDSD ScaleAUS /* ScaleWID */ /*ScaleWFP*/ ; 

		IF FIRST.HHID THEN DO ; 

/*			ScaleWFP = 'N' ;*/
/*			ScalePTA = 'N' ;*/
			ScaleSPL = 'N' ;
			ScaleYAO = 'N' ; 
			ScaleJSP = 'N' ;
			ScalePPP = 'N' ;   
			ScalePPS = 'N' ;
/*			ScaleSKA = 'N' ;*/
			ScaleDWW = 'N' ;
			ScaleDSD = 'N' ;
/*			ScaleWID = 'N' ;*/
			ScaleAUS = 'N' ;

		END ;  

	* Below we check for conditions required for scaling. Please see above for definitions of
	BmPaymentType and WifePenAgeCheckFlag. ;
/*		IF BmPaymentType = '04. WifePen' AND WifePenAgeCheckFlag = 1 THEN ScaleWFP = 'Y' ; */
		IF BmPaymentType = '05. JSP'  THEN ScaleJSP = 'Y' ; 
		IF BmPaymentType = '06. YAOther' THEN ScaleYAO = 'Y' ; 
/*		IF BmPaymentType = '08. SickAllow' THEN ScaleSKA = 'Y' ; */
		IF BmPaymentType = '09. SpecBft' THEN ScaleSPL = 'Y' ; 
		IF BmPaymentType = '10. PPP' THEN ScalePPP = 'Y' ;  
		IF BmPaymentType = '11. PPS' THEN ScalePPS = 'Y' ;
/*		IF BmPaymentType = '12. WidAllow' THEN ScaleWID = 'Y' ;*/
		IF BmPaymentType = '13. DvaServDis' THEN ScaleDSD = 'Y' ;
		IF BmPaymentType = '16. DvaWWid' THEN ScaleDWW = 'Y' ;
		IF BmPaymentType = '17. Austudy' THEN ScaleAUS = 'Y' ;
/*		IF BmPaymentType = '18. Partner' THEN ScalePTA = 'Y' ; */

		IF LAST.HHID THEN OUTPUT ; 
	* If we have retained ScalePartner and ScaleWFP, the last record will identify if anyone in the HHID
		has a value of Y for each of these indicators. ;

	RUN ; 
		
	* We join the indicators from ScaleIndicators back onto PersonBenchmark by matching to HHID.
	This ensures that members of a household have the same scaling indicators. ;	
	
    DATA PersonBenchmark ;
        MERGE ScaleIndicators PersonBenchmark ;
        BY HHID ;
    RUN ;

%MEND CreatePreBenchmark ;

/* STEP FOUR: BROAD uprating of weights to improve start weights */

%MACRO Preweight() ;

/* Store the target values as macro variables for the age by sex  */
	DATA _NULL_ ;
		SET &benchpreweight ;
		RETAIN TotalPop TotalPopL1 TotalPopL2 0 ;
			TotalPop = TotalPop + y&BMYear ;
			TotalPopL1 = TotalPopL1 + y&BMYearL1 ;
			TotalPopL2 = TotalPopL2 + y&BMYearL2 ;
		%GLOBAL y&BMYear._Total_Pop y&BMYearL1._Total_Pop y&BMYearL2._Total_Pop;
		CALL SYMPUT("y&BMYear._Total_Pop" , TotalPop ) ;
		CALL SYMPUT("y&BMYearL1._Total_Pop" , TotalPopL1 ) ;
		CALL SYMPUT("y&BMYearL2._Total_Pop" , TotalPopL2 ) ;
	RUN ;


/*** After the first round of Reweighting, WifePen, PPP, DvaServDis and Partner are 4 payments with big gaps from benchmark data, need to be manually adjusted ***/

/* Preweight the benchmarks for Partner Allowance to assist with convergence */
/* Store the target values for Partner Allowance benchmarks as macro variables */
/*	DATA _NULL_ ;*/
/*		SET BMPaymentType ;*/
/*			WHERE BMPaymentType = "18. Partner" ; */
/*		%GLOBAL y&BMYear._Partner_Pop y&BMYearL1._Partner_Pop ;*/
/*		CALL SYMPUT("y&BMYear._Partner_Pop" , y&BMYear ) ; */
/*		CALL SYMPUT("y&BMYearL1._Partner_Pop" , y&BMYearL1 ) ;*/
/*	RUN ;*/


/* Preweight the benchmarks for Widow Allowance to assist with convergence */
/* Store the target values for Widow Allowance benchmarks as macro variables */
/*	DATA _NULL_ ;*/
/*		SET BMPaymentType ;*/
/*			WHERE BMPaymentType = "12. WidAllow" ; */
/*		%GLOBAL y&BMYear._Wid_Pop y&BMYearL1._Wid_Pop ;*/
/*		CALL SYMPUT("y&BMYear._Wid_Pop" , y&BMYear ) ;*/
/*		CALL SYMPUT("y&BMYearL1._Wid_Pop" , y&BMYearL1 ) ;*/
/*	RUN ;*/

/* Preweight the benchmarks for Wife Pension to assist with convergence */
/* Store the target values for Wife Pension benchmarks as macro variables */
/*	DATA _NULL_ ;*/
/*		SET BMPaymentType ;*/
/*			WHERE BMPaymentType = "04. WifePen" ; */
/*		%GLOBAL y&BMYear._Wif_Pop y&BMYearL1._Wif_Pop ;*/
/*		CALL SYMPUT("y&BMYear._Wif_Pop" , y&BMYear ) ;*/
/*		CALL SYMPUT("y&BMYearL1._Wif_Pop" , y&BMYearL1 ) ;*/
/*	RUN ;*/

/* Preweight the benchmarks for PPP Allowance to assist with convergence */
/* Store the target values for PPP Allowance benchmarks as macro variables */
	DATA _NULL_ ;
		SET BMPaymentType ;
			WHERE BMPaymentType = "10. PPP" ; 
		%GLOBAL y&BMYear._PPP_Pop y&BMYearL1._PPP_Pop y&BMYearL2._PPP_Pop ;
		CALL SYMPUT("y&BMYear._PPP_Pop" , y&BMYear ) ;
		CALL SYMPUT("y&BMYearL1._PPP_Pop" , y&BMYearL1 ) ;
		CALL SYMPUT("y&BMYearL2._PPP_Pop" , y&BMYearL2 ) ;
	RUN ;



	/* Preweight the benchmarks for DVAServDis Allowance to assist with convergence */
/* Store the target values for Widow DVAServDis benchmarks as macro variables */
	DATA _NULL_ ;
		SET BMPaymentType ;
			WHERE BMPaymentType = "13. DvaServDis" ; 
		%GLOBAL y&BMYear._DvaServDis_Pop y&BMYearL1._DvaServDis_Pop y&BMYearL2._DvaServDis_Pop ;
		CALL SYMPUT("y&BMYear._DvaServDis_Pop" , y&BMYear ) ;
		CALL SYMPUT("y&BMYearL1._DvaServDis_Pop" , y&BMYearL1 ) ;
		CALL SYMPUT("y&BMYearL2._DvaServDis_Pop" , y&BMYearL2 ) ; 
	RUN ;

	/* Preweight the benchmarks for Specific benefit to assist with convergence */
/* Store the target values for Specifit benefit benchmarks as macro variables */
	DATA _NULL_ ;
		SET BMPaymentType ;
			WHERE BMPaymentType = "09. SpecBft" ; 
		%GLOBAL y&BMYear._SpecBft_Pop y&BMYearL1._SpecBft_Pop ;
		CALL SYMPUT("y&BMYear._SpecBft_Pop" , y&BMYear ) ;
		CALL SYMPUT("y&BMYearL1._SpecBft_Pop" , y&BMYearL1 ) ;
	RUN ;

	/* Preweight the benchmarks for Austudy to assist with convergence */
/* Store the target values for Austudy benchmarks as macro variables */
	DATA _NULL_ ;
		SET BMPaymentType ;
			WHERE BMPaymentType = "17. Austudy" ; 
		%GLOBAL y&BMYear._Austudy_Pop y&BMYearL1._Austudy_Pop ;
		CALL SYMPUT("y&BMYear._Austudy_Pop" , y&BMYear ) ;
		CALL SYMPUT("y&BMYearL1._Austudy_Pop" , y&BMYearL1 ) ;
	RUN ;



/* Pre-weight by adjusting the weights sequentially */

DATA PersonBenchmark ;
	SET PersonBenchmark ;
	
/* Adjust weights mannually for 2021 year using 2019 as a base as 2020 skipped for benchmarking */

	%IF &BMYear = 2021 %THEN %DO ; 

		In_wgt = In_wgt * (&&y&BMYEAR._Total_Pop / &&y&BMYEARL2._Total_Pop) ;

		IF ScalePPP = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._PPP_Pop / &&y&BMYEARL2._PPP_Pop) ;
		END ;

		IF ScaleDSD = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._DvaServDis_Pop / &&y&BMYEARL2._DvaServDis_Pop) ;
		END ;

	%END ; 
	%ELSE %DO ;
	
		In_wgt = In_wgt * (&&y&BMYEAR._Total_Pop / &&y&BMYEARL1._Total_Pop) ;

	%END ; 

/* Also adjust weights manually to account for grandfathered payments */
	/* Partner Allowance */

	%IF &BMYear = 2017 %THEN %DO ;

		IF ScaleJSP = 'Y'  OR ScaleDWW = 'Y' OR ScaleAUS = 'Y' THEN DO ;

			OldWeight = In_wgt ;
			In_wgt = In_wgt * 1.5 ;

		END ;

/*		IF ScalePTA = 'Y' THEN DO ;*/
/**/
/*			OldWeight = In_wgt ;*/
/*			In_wgt = In_wgt * 3 ;*/
/**/
/*		END ;*/

		ELSE IF /*ScaleSPL = 'Y' OR */ ScaleYAO = 'Y' OR ScalePPS = 'Y' OR ScaleDSD = 'Y' /* OR ScaleWFP = 'Y' */ OR ScalePPP = 'Y' THEN DO ;

			OldWeight = In_wgt ;
			In_wgt = In_wgt * 2 ;

		END ; 

/*		ELSE IF ScaleSKA = 'Y' THEN DO ;*/
/**/
/*					OldWeight = In_wgt ;*/
/*			In_wgt = In_wgt * 0.75 ;*/

/*		END ; */

	%END ;

/* Also adjust weights manually to account for grandfathered payments */
	/* Partner Allowance */

	%IF 2020 > &BMYear > 2017 %THEN %DO ;

/*		IF ScalePTA = 'Y' THEN DO ;*/
/*			In_wgt = In_wgt * (&&y&BMYEAR._Partner_Pop / &&y&BMYEARL1._Partner_Pop) ;*/
/*		END ;*/

/*		IF ScaleWFP = 'Y' THEN DO ;*/
/*			In_wgt = In_wgt * (&&y&BMYEAR._WIF_Pop / &&y&BMYEARL1._WIF_Pop) ;*/
/*		END ;*/

		IF ScalePPP = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._PPP_Pop / &&y&BMYEARL1._PPP_Pop) ;
		END ;

		IF ScaleDSD = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._DvaServDis_Pop / &&y&BMYEARL1._DvaServDis_Pop) ;
		END ;

		IF ScaleSPL = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._SpecBft_Pop / &&y&BMYEARL1._SpecBft_Pop) ;
		END ;

		IF ScaleAUS = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._Austudy_Pop / &&y&BMYEARL1._Austudy_Pop) ;
		END ;

/*		IF ScaleWID = 'Y' THEN DO ;*/
/*			In_wgt = In_wgt * (&&y&BMYEAR._Wid_Pop / &&y&BMYEARL1._Wid_Pop) ;*/
/*		END ;*/


	%END ;

	%IF &BMYear >= 2022 %THEN %DO; 

		IF ScalePPP = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._PPP_Pop / &&y&BMYEARL1._PPP_Pop) ;
		END ;

		IF ScaleDSD = 'Y' THEN DO ;
			In_wgt = In_wgt * (&&y&BMYEAR._DvaServDis_Pop / &&y&BMYEARL1._DvaServDis_Pop) ;
		END ;

/*		IF ScaleWFP = 'Y' THEN DO; */
/*			In_wgt = 0 ; */
/*		END; */
/**/
/*		IF ScaleSKA = 'Y' THEN DO;*/
/*			In_wgt = 0;*/
/*		END;*/
	%END; 	

/*	%IF &BMYear = 2020 %THEN %DO ;*/
/**/
/*		IF ScalePTA = 'Y' THEN DO ;*/
/*			In_wgt = In_wgt * (&&y&BMYEAR._Partner_Pop / &&y&BMYEARL1._Partner_Pop) * 0.3;*/
/*		END ;*/
/**/
/*		IF ScaleWID = 'Y' THEN DO ;*/
/*			In_wgt = In_wgt * (&&y&BMYEAR._Wid_Pop / &&y&BMYEARL1._Wid_Pop) * 0.5;*/
/*		END ;*/
/**/
/*	%END ;*/

/*	%IF &BMYear > 2020 %THEN %DO ;*/
/**/
/*/* Also adjust weights manually to account for closing payments */*/
/*	/* Widow Allowance */*/
/*	/* Partner allowance */*/
/**/
/*		IF ScaleWID = 'Y' THEN DO ;*/
/*			In_wgt = 0 ;*/
/*		END ;*/
/**/
/*		IF ScalePTA = 'Y' THEN DO ;*/
/*			In_wgt = 0 ;*/
/*		END ;*/
/**/
/*	%END ;*/


	/*Set weights of observations to zero*/
	/*Wife Pensioners over age pension age - 2017-18 Budget Working Age Payment Reforms*/
	/*Sickness Allowance*/ 



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

    * Provide flexibility to specify different values of Tolerance and Bounds for weighting initial Survey Year;

	%IF &BMyear = &SurveyYear %THEN %DO ;

	    %LET GREGWTEnd =            ,MAXITER = 10
                ,UPPER   = 150%
                ,LOWER   = 70%
                ,EPSILON = 0.02
                ,OPTIONS = HMEAN
	                
	    ;
	%END ; 

	%ELSE %DO ;

	    %LET GREGWTEnd =            ,MAXITER = 10
                ,UPPER   = 150%
                ,LOWER   = 70%
                ,EPSILON = 0.02
                ,OPTIONS = HMEAN
	                
	    ;
	%END ; 

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