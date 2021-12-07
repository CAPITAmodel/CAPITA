************************************************************************************
* Name of program: CAPITACameoCode.sas                                             * 
* Purpose: Run CAMEO code.                                                         *
* Description: This program produces cameos which illustrate the                   *
*              impact of policy changes on hypothetical families.                  *
*              If the RunEMTR flag is set, it instead produces effective           *
*			   marginal tax rates for a hypothetical family                        * 
*																				   *
* The sequence of the program is as follows:                                       *
* 0. Specify date for cameo run, location of files, and list of selected           *
*    variables for the cameo output                                                *
* 1. Import family and income data from the cameo input spreadsheet                *
* 2. Create cameo basefile                                                         *
* 3. Run the Capita policy modules                                                 *
* 4. Export the cameo results to the cameo output spreadsheet                      *
************************************************************************************;
options nomprint ;
* Leave this as Y. To switch between cameo and EMTR runs, use the RunEMTR switch below ;
%LET RunCameo = Y ;

************************************************************************************
*     0.         Specify cameo folder and variables                                *              
*                                                                                  * 
************************************************************************************;

* Include the DefineCapitaDirectory code to set the main CAPITA drive ;
%INCLUDE "\\CAPITALocation\DefineCapitaDirectory.sas" ;

* Specify location of cameo code and spreadsheet used for creating cameo basefile;
%LET CameoFolder = \\CAPITALocation\Cameo\ ;
%LET CameoInput = &CameoFolder.Cameo input.xlsx ;
%LET CameoInitialise = &CameoFolder.CameoInitialisation.sas ;

* change location to point to where new RunCapita.sas file is in working folder ;
* Specify location of policy modules ;
%LET PolicyFolder = &CapitaDirectory. ;
%LET RunCapita = &CapitaDirectory.RunCAPITA.sas ;
%LET RunCapitaCompare = &CapitaDirectory.RunCapitaCompare.sas ;

* Specify year and quarter of interest ;
%LET CameoYear = 2022 ;    * Format 20XX = 20XX-YY ;  
%LET CameoQuarter = Mar ;  * Only used for quarterly runs, Valid quarters are Mar Jun Sep Dec ;
%LET CameoQYear = %EVAL(&CameoYear + 1) ; * DO NOT CHANGE. This is to ensure the correct parameters are imported for quarterly runs ;

* Specify the time duration of analysis ;
* A for Annual, the financial year. This options uses annualised parameters calculated using time weighted average of each quarter ;
* Q for Quarter. This option uses actual parameter values from the appropriate quarter ;
%LET CameoDuration = A ;

* Specify whether to model HELP repayments, default is set to N ; 
%LET CameoRunHelp = N ; 

* Use for switch: N if running baseworld, Y if running comparison (has no effect if RunEMTR is set to Y) ;
%LET RunCompare = N ;

* Use switch to: Excel if income is read in from cameo input sheet income list, SAS if income is defined using macro variables below ; 
%LET IncSource = SAS ; * Default is set to Excel ; 

* IF IncSource = SAS, then use macro variables below to set income and childcare weekly hours ;
	%LET Start = 0 ; 
	%LET Stop = 150020 ; * Set to one more increment than you need i.e if you want up to 100,000 and your increment is 5 then set to 105,000 ;
	%LET Increment = 20 ; 
	%LET SpsIncSplit = Fixed ; * Options are Fixed or Variable ; 
	%LET SpsInc = 0 ; * If SpsIncSplit = Fixed then put the $ amount, if SpsIncSplit = Variable then put the proportion of household income ;
	%LET CcUse = Fixed ; * Options are Fixed or Variable ; 
    %LET CcHrW = 0 ; * If CcUse = Fixed then set this to the number of weekly hours for each child at each income increment ; 

* Use switch to: N if running cameos, Y if running effective marginal tax rate scenario (note that you can't run both in the same run). ;
%LET RunEMTR = Y ; 
	%LET CutRows = Y ; * Use switch to: Y if graphing EMTRs, N for graphing WDRs ; 

* Use for switch: N you want to keep all variables in CameoList or EMTRVarlist in the final output. Y if you want to drop all variables that are zero for all rows ;
%LET DropZeroVars =  N ;

*Specify character variables required for the cameo output results ; ;
%LET RateTypeList = 
					FtbaType
					AllowRateTyper
					PenRateTyper
					AllowRateTypes
					PenRateTypes
					;
*Specify numeric variables required for the cameo output results ; ; 
%LET CameoList = 

AllTotAr 
PenTotAr 
AllTotAs
PenTotAs
PenBasicFr
AllBasicFr
PenBasicFs
AllBasicFs
PenEsFr
AllEsFr 
PenEsFs
AllEsFs
                 FamilyID 
                 IncPrivAu 
                 IncPrivAr 
                 IncPrivAs 
                 IncDispAu 
                 IncDispAr
                 IncDispAs
                 PayOrRefAmntAu 
                 PayorRefAmntAr
                 PayorRefAmntAs
                 IncTranAu
                 IncTranAr
                 IncTaxTranFr
                 IncNonTaxTranFr

				   AllTotAu
				   PppTotAu
				   JspTotAu
				   YaOtherTotAu
				   YaStudTotAu
				   AgeTotAu
				   DspTotAu
				   CarerTotAu
				   DspU21TotAu
				   PpsTotAu
                   FtbaFinalA 
                   FtbbFinalA
                   LamitoAr 
				   LamitoAs

                 CareAllFr
                 CareAllAr
                 CareAllFlagr
                 CareSupAr
                 CareSupFr
                 PenTyper
                 CarerPenBasicFr
                 CarerPenSupBasicFr
                 CarerTotFr 
                 TaxIncAr 


                   FtbbFlag
                 AdjTaxIncAu 
                 AgePenBasicAr
                 AgePenBasicAs
                 CarerPenBasicAr
                 CarerPenBasicAs 
                 DSPPenBasicAr
                 DSPPenBasicAs
                 DSPU21PenBasicAr
                 DSPU21PenBasicAs
                 MedLevAu 
                 JspAllBasicAr 
                 JspAllBasicAs 
                 AgePenEsAr

                 CareAllAr              
                 CareSupAr
                 SenSupAr
                 SenSupEsAr
                 TelAllAr
                 UtilitiesAllAr
                 SifsAr 


                 PpsPenBasicAr 
                 PpsPenSupBasicAr
                   PpsTotAr
                 PpsPenEsAr
                 PpsRAssAr
                 PpsPharmAllAr
                 AllTotFr

                 PenRedF
                 IncPenTestF
                 IncOrdFr


                 PppAllBasicAr 
                 PppAllBasicAs 
                 PppAllBasicAr 
                 TotTaxOffsetAu 
                 RebIncAU 

/*              Previous childcare policy */

/*                CcTestInc*/
/*                ActivHrWr*/
/*                ActivHrWs*/
/*                CcbMaxHrW*/
/*                CcbInfElig*/
/*                CcrElig*/
/*                CcbAmtAu*/
/*                CcbCostAu*/
/*                CcrAmtAu*/
/*                CcrOutPocketAu*/
/*                CcWPerYr1*/
/*                CcWPerYr2*/
/*                CcbAmtW1*/
/*                CcbAmtW2*/
/*                CcrAmtA1*/
/*                CcrAmtA2*/

            /*  Current childcare policy */

                  CcTestInc
                  CcsRateA
                  CcsAmtAu
                  CcsAmtA1
                  CcsAmtA2
                CcsAmtA3
                CcsAmtA4
                  CcsCostAu
                  CcsCostA1
                  CcsCostA2
                CcsCostA3
                CcsCostA4
                  CcsOutPocketAu
                  CcsOutPocketA1
                  CcsOutPocketA2
                CcsOutPocketA3
                CcsOutPocketA4
                      
                ;

%LET RateTypeCount = %SYSFUNC( COUNTW( &RateTypeList ) ) ;
%LET NumVars = %SYSFUNC( COUNTW( &CameoList ) ) ;

*Specify name of list for cameo output comparison ;
%LET CameoBaseList = ;
%LET CameoSimList = ;
%LET CameoChangeList = ;

%LET RateTypeBaseList = ;
%LET RateTypeSimList = ;

%LET AgePenAge = 65 ;
%GLOBAL NumFams ;

%MACRO ValidateQuarter/MINOPERATOR ;
	%PUT &=CameoQuarter;                                               /*put the value of the macro variable to the log*/
	%IF NOT(%UPCASE(&CameoQuarter) IN MAR JUN SEP DEC) %THEN           /*check if macro variable is in the validated list*/
	    %DO ;                                                			/*if not*/
	        %PUT ERROR: Valid values for CameoQuarter are Mar, Jun, Sep or Dec. ; 
	        %ABORT ;                                         		   /*stop submitted code*/
	    %END ;
%MEND ValidateQuarter ;
%ValidateQuarter ;

************************************************************************************
*   Macro: CameoCompareList                                                        *
*   Purpose: Create 3 lists for comparing variables before and after changes, and  *
*            their differences                                                     *
************************************************************************************;
%MACRO CameoCompareList ;

    %DO i = 1 %TO &NumVars ;

	    %LET CameoName = %SCAN( &CameoList , &i ) ;
	    %LET CameoBaseList = &CameoBaseList &CameoName._Base ;
	    %LET CameoSimList = &CameoSimList &CameoName._Sim ;
	    %LET CameoChangeList = &CameoChangeList &CameoName._Change ;

    %END ;    

%MEND CameoCompareList ;
************************************************************************************
*   Macro: RateTypeList                                                            *
*   Purpose: Create 2 lists for comparing rate type before and after changes       *
************************************************************************************;
%MACRO RateTypeCompareList ;

    %DO i = 1 %TO &RateTypeCount ;

	    %LET RateType = %SCAN( &RateTypeList, &i ) ;
	    %LET RateTypeBaseList = &RateTypeBaseList &RateType._Base ;
	    %LET RateTypeSimList = &RateTypeSimList &RateType._Sim ;

    %END ;    

%MEND RateTypeCompareList ;

%LET EmtrVarList =  /* List income definitions */
                    IncPrivAr - NA - NA - Private income(r) -
                    TaxIncAr - NA - NA - Taxable income(r) -
                    IncAllTestFr - NA - NA - Allowance ordinary income(r) -
                    RebIncAr - NA - NA - Rebatable income(r) -
                    RebBftAr - NA - NA - Rebatable benefit(r) -
                    NetIncWorkAr - NA - NA - Net income from working(r) -
                    AdjTaxIncAr - NA - NA - Adjusted taxable income(r) -
                    IncPrivAs -  NA - NA - Private income(s) -
                    TaxIncAs - NA - NA - Taxable income(s) -
                    IncAllTestFs - NA - NA - Allowance ordinary income(s) -
                    RebIncAs - NA - NA - Rebatable income(s) -
					IncPrivAu - NA - NA - Private income(u) -
                    IncDispAu - NA - NA - Disposable income(u) - 
					IncDispLessCcAu - NA - NA - Disposable income after net childcare costs(u) - 

                    /* List components of EMTR */ 
                    EffTaxu - IncPrivAu - Pos - EMTR Effective tax(u) -
					EffTaxNetCcu - IncPrivAu - Pos - EMTR Effective tax including net childcare costs(u) -
                    PayOrRefAmntAu - IncPrivAu - Pos -  EMTR Total tax payable(u) -
                    IncTranAu - IncPrivAu - Neg - EMTR Total transfer payment(u) -

                    PenTotAu - IncPrivAu - Neg - EMTR Total pensions(u) -
/*                    AgeTotAu - IncPrivAu - Neg - EMTR Age Pension(u) -*/
/*                    DspTotAu - IncPrivAu - Neg - EMTR DSP Pension(u) -*/
/*                    CarerTotAu - IncPrivAu - Neg - EMTR Carer Pension(u) -*/
/*                    WifeTotAu - IncPrivAu - Neg - EMTR Wife Pension(u) -*/
/*                    DspU21TotAu - IncPrivAu - Neg - EMTR DSP Pension under 21(u) -*/
/*                    PpsTotAu - IncPrivAu - Neg - EMTR Parenting Payment Single(u) -*/

                    AllTotAu - IncPrivAu - Neg - EMTR Total Allowances(u) -
/*                    PppTotAu - IncPrivAu - Neg - EMTR Parenting Payment Partnered(u) -*/
/*                    JspTotAu - IncPrivAu - Neg - EMTR Jobseeker Payment(u) -*/
/*                    YaOtherTotAu - IncPrivAu - Neg - EMTR Youth Allowance Other(u) -*/
/*                    YaStudTotAu - IncPrivAu - Neg - EMTR Youth Allowance Student(u) -*/
/*                    AustudyTotAu - IncPrivAu - Neg - EMTR Austudy(u) -*/
/*                    WidowTotAu - IncPrivAu - Neg - EMTR Widow payment(u) -*/

					CcsAmtAu - IncPrivAu - Neg - EMTR Childcare Subsidy(u) - 
					CcsOutPocketAu - IncPrivAu - Pos - EMTR net cost of childcare(u) - 

/*                    DvaTotAu - IncPrivAu - Neg - EMTR DVA entitlements(u) -*/
/*                    ServiceTotAu - IncPrivAu - Neg - EMTR DVA Service Pension(u) -*/

                    FtbaFinalA - IncPrivAu - Neg - EMTR FTB A(u) -
                    FtbbFinalA - IncPrivAu - Neg - EMTR FTB B(u) -

                    SupTotAu - IncPrivAu - Neg - EMTR Total Supplements(u) -

                    GrossIncTaxAu - IncPrivAu - Pos - EMTR Gross income tax(u) - 
                    UsedSaptoAu - IncPrivAu - Neg - EMTR Used SAPTO(u) -
                    UsedBentoAu - IncPrivAu - Neg - EMTR Used BENTO(u) -
                    UsedLitoAu - IncPrivAu - Neg - EMTR Used LITO(u) -    
					UsedLamitoAu - IncPrivAu - Neg - EMTR Used LMITO(u) -   
/*                    UsedItem20Au - IncPrivAu - Neg - EMTR Used Item 20 offsets(u) -*/
/*                    XRefTaxOffsetAu - IncPrivAu - Neg - EMTR Unused refundable tax offset(u) -*/
                    MedLevAu - IncPrivAu - Pos - EMTR Medicare levy(u) -
                    MedLevSurAu - IncPrivAu - Pos - EMTR Medicare levy surcharge(u) - 

                    /* Variables not requiring EMTR calculation */
                    EffTaxu - NA - NoChange - Effective tax(u) -
					EffTaxNetCcu - NA - NoChange - Effective tax including net childcare costs(u) -
                    PayOrRefAmntAu - NA - NoChange - Tax liability or refund(u) -
                    IncTranAu - NA - NoChange - Transfer income(u) -
                    AllTotAu - NA - NoChange - Allowance total(u) -
                    JspTotAu - NA - NoChange - Jobseeker Payment(u) -
					PenTotAu - NA - NoChange - Pension total(u) -
                    AgeTotAu - NA - NoChange - Age pension(u) -
                    FtbaFinalA - NA - NoChange - Family tax benefit a(u) -
					FtbbFinalA - NA - NoChange - Family tax benefit b(u) -
					SupTotAu - NA - NoChange - Supplements total(u) -
					CcsOutPocketAu - NA - NoChange - Net cost of childcare(u) - 
                    GrossIncTaxAu - NA - NoChange - Gross income tax(u) -
                    GrossIncTaxAr - NA - NoChange - Gross income tax(r) -
                    GrossIncTaxAs - NA - NoChange - Gross income tax(s) -
                    UsedSaptoAu - NA - NoChange - Used Sapto(u) -
                    UsedBentoAu - NA - NoChange - Used Bento(u) -
                    UsedLitoAu - NA - NoChange - Used Lito(u) -
                    UsedLitoAr - NA - NoChange - Used Lito(r) -
				    UsedLitoAs - NA - NoChange - Used Lito(s) -
					UsedLamitoAu - NA - NoChange - Used Lamito(u) -
                    UsedLamitoAr - NA - NoChange - Used Lamito(r) -
					UsedLamitoAs - NA - NoChange - Used Lamito(s) -
                    MedLevAu - NA - NoChange - Medicare levy(u) -
                    MedLevSurAu - NA - NoChange - Medicare levy surcharge(u) - 
                    AllowTyper - NA - NoChange - Allowance type(r) -
                    PenTyper - NA - NoChange - Pension type(r) -
					AllowTypes - NA - NoChange - Allowance type(s) -
                    PenTypes - NA - NoChange - Pension type(s) -

                    ;

%LET NumEmtrVarList = %SYSFUNC( COUNTW( &EmtrVarList , - ) ) ; 

%LET RenameEmtrVarList = ;

************************************************************************************
*   Macro: RenameEmtrVarList                                                       *
*   Purpose:    Create variables required for EMTR run.                            * 
*               First element: name of variable for EMTR,                          *
*               Second element: analysis by what income,                           *
*      			Third element: does it increase or decrease with income change ,   *
*				Fourth element: label ;                                            *
************************************************************************************;

%MACRO RenameEmtrVarList ;

    %DO i = 1 %TO &NumEmtrVarList %BY 4 ;
        * Rename variable only if for EMTR purposes ;
        %LET EmtrVar3 = %SCAN( &EmtrVarList , &i + 2 , - ) ;      
        %IF &EmtrVar3 NE NoChange %THEN %DO ;
            %LET EmtrVar1 = %SCAN( &EmtrVarList , &i , - ) ; 
            %LET RenameEmtrVarList = &RenameEmtrVarList &EmtrVar1 = _&EmtrVar1 ;
        %END ;
    %END ;

 %MEND RenameEmtrVarList ;

 %RenameEmtrVarList 

************************************************************************************
*      1.         Import family and income data from cameo spreadsheet             * 
*                                                                                  *
************************************************************************************;
* Import family data ;
PROC IMPORT 
    DATAFILE="&CameoInput"
    OUT = CameoFamilies 
    ( WHERE = ( UPCASE( Selected ) = 'Y' ) ) 
    DBMS = EXCELCS REPLACE ;
    SHEET = "Family sheet" ;
RUN; 

* Determine number of hypothetical families and assign to NumFams ;
DATA _NULL_;
    SET CameoFamilies ( OBS = MAX ) ;
    CALL SYMPUTX( 'NumFams' , _N_ ) ; 
RUN;
************************************************************************************
*   Macro: IncomeLists                                                             *
*   Purpose: Import required income lists for each family                          *
************************************************************************************;
%MACRO IncomeLists ;

    %DO i = 1 %TO &NumFams ;       * for each family ;

        DATA _NULL_ ;                        
        
            SET CameoFamilies ( OBS = &i ) ; 
            *extract name of income list and assign to 'List' ;
            CALL SYMPUTX( 'List', IncomeList ) ;
        RUN;

        PROC IMPORT DATAFILE = "&CameoInput"  
            REPLACE OUT = Incomes&i
            DBMS = excelcs ;  
            SHEET = "&List" ;       *read in this income list;
			 
        RUN;

        DATA Incomes&i ;     *add on FamilyID to income list data set ;
            SET Incomes&i ;      
            FamilyID = &i ;
			IF MISSING( IncPrivCameor ) AND MISSING( IncPrivCameos ) THEN DELETE ;
			cheat = 'a' ; 
			DROP _character_ ;
        RUN;

    %END;

%MEND IncomeLists;

************************************************************************************
*   Macro: EmtrIncome                                                              *
*   Purpose: Import required income lists for each family                          *
*   Note: Because the EMTR charts are different from cameos in that they concern   *
*           marginal dollar by dollar impacts, this code differs the Cameo Code by *
*           assigning only a fixed income for spouse and recording each dollar of  *
*           income in a range of $0 to $200,000 for the reference person.          *
************************************************************************************;
%MACRO SASIncome ;

    * Add reference and spouse income onto family dataset imported above. ;
    * Incomes are not imported from the input spreadsheet ;
    * but are instead created in the below data step to produce small income increments ;

	DATA CameoBase ;   
 
        SET CameoFamilies ;

        DO j = &Start TO &Stop BY &Increment ;
            IncPrivCameor = j ;

            %IF &SpsIncSplit = Variable %THEN %DO ;
                IncPrivCameos = IncPrivCameor * &SpsInc / ( 1 - &SpsInc ) ;
            %END ;

            %IF &SpsIncSplit = Fixed %THEN %DO ;
                IncPrivCameos = &SpsInc ;
            %END ;

			* Set activity hours so it meets the Activity test for CCS to be paid ; 
			ActivHrWr = 35 ; 
			ActivHrWs = 35 ;

			%IF &CcUse = Variable %THEN %DO ; 

			* Set childcare weekly hours. If child does not exist, set to 0. If "variable" use the Stop income amount as full-time equivalent income to 
			assign weekly hours according to days worked. Current assumptions are 10 hours a day for LDC and FDC and 5 hours a day for OSHC.; 
				%DO i = 1 %TO 4 ; 
					IF NOT( MISSING( AgeofKid&i ) ) THEN DO ; 
						IF CcsType&i IN ( "LDC", "FDC" ) THEN DO ; 
							IF IncPrivCameor = 0                                      THEN CcHrW&i = 0 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 1/5 ) THEN CcHrW&i = 10 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 2/5 ) THEN CcHrW&i = 20 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 3/5 ) THEN CcHrW&i = 30 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 4/5 ) THEN CcHrW&i = 40 ; 
				            ELSE IF IncPrivCameor <=   ( &Stop - &Increment )         THEN CcHrW&i = 50 ; 
						END ; 
						ELSE IF CcsType&i = "OSHC" THEN DO ; 
							IF IncPrivCameor = 0                                      THEN CcHrW&i = 0 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 1/5 ) THEN CcHrW&i = 5 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 2/5 ) THEN CcHrW&i = 10 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 3/5 ) THEN CcHrW&i = 15 ; 
							ELSE IF IncPrivCameor <= ( ( &Stop - &Increment ) * 4/5 ) THEN CcHrW&i = 20 ; 
				            ELSE IF IncPrivCameor <=   ( &Stop - &Increment )         THEN CcHrW&i = 25 ;
						END ; 
					END ; 
					ELSE CcHrW&i = 0 ; 
				%END ; 
				
			%END ; 
			%ELSE %DO ; 
	        
				%DO i = 1 %TO 4 ; 
					IF NOT( MISSING( AgeOfKid&i ) ) THEN CcHrW&i = &CcHrW ; 
					ELSE CcHrW&i = 0 ; 
				%END ;

			%END ; 

		OUTPUT ; 

        END ;

		DROP j ;

    RUN ;

%MEND SASIncome ;

************************************************************************************
*   Macro: IncomeOption                                                            *
*   Purpose: If RunEMTR is selected generate EMTR income lists for each family,    *
*            otherwise use the Cameo incomes                                       *
************************************************************************************;
%MACRO IncomeOption ;

	%IF &IncSource = SAS %THEN %DO ;
		%SASIncome
	%END ;
	%ELSE %DO ;
		%IncomeLists
		DATA CameoBase ;                 
		    MERGE CameoFamilies Incomes1 - Incomes&NumFams ;
		    BY FamilyID ;
		RUN ;
	%END ;

%MEND IncomeOption ;

%IncomeOption

* Add cameo information onto income datasets ;
************************************************************************************
*     2.         Create Cameo basefile                                             *
*                                                                                  *
************************************************************************************;
DATA CAPITA_Inputfile ;
    SET CameoBase ;

 * Initialise variables ;
    %INCLUDE "&CameoInitialise" ;

******************************Family Characteristics********************************;
                                                 
    * Assign family ID to each family/income combination ;

    FamID = _N_ ;

    NumIUu = 1 ;

    * ActualAger, ActualAges are read straight from cameo input ;

    IF ActualAger > 0 AND ActualAges > 0 THEN DO ;
        Coupleu = 1 ;
        Famposr = "REF" ;
        Famposs = "SPOUSE" ;
    END ;
    
    ELSE DO ;
        Coupleu = 0 ;    
        Famposr = "REF" ;
    END ;
    
    * Age of youngest child ;

    IF NOT( MISSING( AgeOfKid1 ) AND
            MISSING( AgeOfKid2 ) AND 
            MISSING( AgeOfKid3 ) AND
            MISSING( AgeOfKid4 )) THEN AgeYoungDepu = MIN ( OF AgeOfKid1 - AgeOfKid4 ) ;

    ELSE AgeYoungDepu = 99 ;

    * Move kids under 15 to their relevant age category and kids over 15 to Dep 1 to 4 ;
    ************************************************************************************
    * Macro:   KidsAge                                                                 *
    * Purpose: Determine number of kids in kids0 to kids14 and move to their relevant  *
    *          age category;                                                           *
    * Input :  Age - age of kid                                                        *
    ************************************************************************************;
    %MACRO KidsAge( Age );

        %DO i = 0 %TO 14 ;

            IF &Age = %EVAL( &i ) THEN DO ;
                Kids&i.Su = Kids&i.Su + 1 ;
                TotalKidsu = TotalKidsu + 1 ;
            END ;

        %END ;

		* Create variable for number of children under 6 to be used in the childcare module for calculating higher rate ; 

            IF 0 < &Age < 6 THEN DO ;
                KidsU6u = KidsU6u + 1 ;
            END ;


    %MEND KidsAge ;
    ************************************************************************************
    * Macro:   KidAssign                                                               *
    * Purpose: Remove kids that are too young to be students from person 1 - 4;        *                                                   *
    ************************************************************************************;  
    %MACRO KidAssign;

        %DO j = 1 %TO 4 ;
            
            IF AgeOfKid&j < 15 THEN DO ;
                
                %KidsAge(AgeOfKid&j)
          
                ActualAge&j = 0 ;  
                StudyType&j = "NOSTUDY" ;

                ChildAge&j. = AgeOfKid&j. ;
            
            END ;

            ELSE DO ;
				ActualAge&j = AgeOfKid&j ;
				IF ActualAge&j > 15 AND StudyType&j NE 'SS' THEN DO ;
					YouthAllSW&j = 1 ;
					NsaSW&j = 1 ;
				END ;
			END ;

            /* Half the kids are female, the other half are male */
            IF MOD(&j,2) = 0 THEN  Sex&j = 'F' ; 
                ELSE Sex&j = 'M' ;

            FamPos&j = "DEPCHILD" ; 

        %END ;

    %MEND KidAssign;

    %KidAssign

    ******************************Income data*****************************************;
                                    
    *Assume all income for those below Age Pension age is derived from wages and salaries 
	 and children have no income. 
	 Assume all private income is from Superannuation for those over Age pension age unless
	 salary and wages is specified in the cameo input sheet.
     Assume no one eligible for DVA payments and no uprated payments;

    ************************************************************************************
    * Macro:   IncomeAssign                                                            *
    * Purpose: Assign income to meet assumptions above.                                *    
    ************************************************************************************; 
    %MACRO IncomeAssign( psn ) ;

        IF ActualAge&psn < &AgePenAge THEN DO ;

            IncWageSW&psn    = IncPrivCameo&psn./52 ;
            IncWageSF&psn    = IncPrivCameo&psn./26 ;
            IncWageSA&psn    = IncPrivCameo&psn ;
            IncWageSPA&psn   = IncPrivCameo&psn  ;
            IncServiceA&psn  = IncWageSA&psn ;

        END ;

        ELSE DO ;

		 	IF MISSING( IncWBCameo&psn ) THEN IncWBCameo&psn = 0 ;

            IncWageSW&psn    = IncWBCameo&psn./52 ;
            IncWageSF&psn    = IncWBCameo&psn./26 ;
            IncWageSA&psn    = IncWBCameo&psn ;
            IncWageSPA&psn   = IncWBCameo&psn  ;
            IncServiceA&psn  = IncWageSA&psn ;
			IncTaxSuperImpA&psn    = IncPrivCameo&psn ;
            IncTaxCompPrivSupImpA&psn = IncTaxSuperImpA&psn ;

        END ;

    %MEND IncomeAssign ;

    %IncomeAssign( r ) 

    IF ActualAges > 0 THEN DO ;
         %IncomeAssign( s )
    END ;

    *************************Private health insurance*********************************;
                            
    IF PrivHealthCameo = 1 THEN DO ;

        %InitNumOther (&VarPrivHlthIns , &SuffixListAll , 1 )

        PrivHlthInsu = 1 ;  
            
    END ;

    ELSE IF PrivHealthCameo = 0 THEN DO ;

        %InitNumZero (&VarPrivHlthIns , &SuffixListAll ) 

        PrivHlthInsu = 0 ;  

    END ;

    *************************************Rent****************************************;
    RentPaidFu = 2 * WeeklyRentCameo ; 

	************************Grandfathering of Energy Supplement***********************;
	
	* Grandfathering of energy supplement has no effect if the individual is not eligible for the payment ;

	IF FTBaGrndfthrESCameo = 1 THEN RandFtbaEsGfthr = 0 ;
 
	ELSE RandFtbaEsGfthr = 1 ;
	
	IF FTBbGrndfthrESCameo = 1 THEN RandFtbbEsGfthr = 0 ;

	ELSE RandFtbbEsGfthr = 1 ;

	IF CSHCGrndfthrESCameor = 1 THEN RandAgeEsGfthr = 0 ;

	ELSE RandAgeEsGfthr = 1 ;

	IF CSHCGrndfthrESCameos = 1 THEN RandAgeEsGfths = 0 ;

	ELSE RandAgeEsGfths = 1 ;
    
    ************************Specified pensions in spreadsheet************************;
                            
    IF Paymentr  = 'DSP' THEN DspSWr = 1 ;
    ELSE IF Paymentr  = 'CARE' THEN DO;
        CarerPaySWr = 1 ;
        CarerAllSWr = 1 ;
        NumCareDepsr = 1 ;
    END;
  
    IF Payments  = 'DSP' THEN DspSWs = 1 ;
    ELSE IF Payments  = 'CARE' THEN DO ;
        CarerPaySWs = 1 ;
        CarerAllSWs = 1 ;
        NumCareDepss = 1 ;
    END ;

    * If couple, assign parenting payment to the person who is not eligible for Youth Allowance, 
      as this is a higher payment for most of the distribution. If both not eligible for YA, 
      assign parenting payment to spouse.;

    %MACRO AssignParentPay ( psn ) ;

            %IF StudyType&psn = "FTNS" %THEN %DO ;

                /* Since full time students under 25 years of age are eligible for Youth Allowance (Student),
                   the person must be aged 25 years or over to be given PPP when studying full time */

                %IF ActualAge&psn >= 25 %THEN %DO; 
					ParPaySW&psn = 1 ;
				%END;

            %END ;

            %ELSE %DO ;

				/* Since individuals who are not studying full time and are aged below 22 are eligible
                   for Youth Allowance (Other), the person must be 22 years or over to be given PPP when not
			       studying full time. */

	                IF ActualAge&psn >= 22 THEN ParPaySW&psn = 1 ;

            %END ;

    %MEND AssignParentPay ;
    
	/* Only assign the ParPaySW flag to people with children */

	IF TotalKidsu > 0 THEN DO ;

    	%AssignParentPay ( r )

    	IF ActualAges > 0 THEN DO ;

        	%AssignParentPay ( s ) 

        	IF ParPaySWr = 1 AND ParPaySWs = 1 THEN ParPaySWr = 0 ;
    
   		END ;

	END ;

RUN ;
************************************************************************************
*      3.         Run CAPITA Policy Code                                           *
*                                                                                  *
************************************************************************************;
************************************************************************************
*   Macro:   RunPolicy                                                             *
*   Purpose: Run Policy Modules either baseworld or with comparison                *    
************************************************************************************;
%MACRO RunPolicy ;
    %GLOBAL Outfile ;
	%IF &RunEMTR = Y %THEN %DO ;
		%INCLUDE "&RunCapita" ; 
	%END ;

	%ELSE %DO ;

	    %IF &RunCompare = N %THEN %DO ;
	        %INCLUDE "&RunCapita" ; 
	    %END ;

	    %ELSE %DO ;
	        %CameoCompareList
			%RateTypeCompareList
	        %INCLUDE "&RunCapitaCompare" ; 
	        %LET Outfile = CAPITA_Compare ;
	    %END ;
	%END ;

%MEND RunPolicy ;
%RunPolicy 

************************************************************************************
*      4.         Export Cameo output to Excel spreadsheet                         *               
*                                                                                  *
************************************************************************************;

************************************************************************************
* Macro:   CreateOutfile                                                           *
* Purpose: Create a time stamped output file  									   *
************************************************************************************;

%MACRO CreateOutfile ;
	%GLOBAL OutCameoFile ;

	%LET timenow=%sysfunc(time(), B8601TM.) ;
	%LET datenow=%sysfunc(date(), YYMMDD.) ;

	%IF &RunEMTR = Y %THEN %DO ;
		%LET InCameoFile = &CameoFolder.EMTR Output template.xlsb ;
		%LET OutCameoFile = &CameoFolder.&datenow &timenow &CameoYear EMTR Output.xlsb ;



	%END ;

	%ELSE %DO ;
		%LET InCameoFile = &CameoFolder.Cameo Output template.xlsx ;
		%LET OutCameoFile = &CameoFolder.&datenow &timenow &CameoYear Cameo Output.xlsx ;
	%END ;

	* recfm=N allows copying of binary files ;
	FILENAME InCF "&InCameoFile" recfm=N ;
	FILENAME OutCF "&OutCameoFile" recfm=N ;
	
	* Create a copy of the template ;

	DATA _null_ ;
		 rc= FCOPY('InCF', 'OutCF') ;
	RUN ;


	* Clear file reference ;
	FILENAME InCF clear ;
	FILENAME OutCF clear ;

%MEND CreateOutfile ;

%CreateOutfile



************************************************************************************
* Macro:   Turning_Point                                                           *
* Purpose: Include a text description if a threshold is hit within an income       *  
*			band for EMTR scenarios.											   *
************************************************************************************;

%MACRO Turning_Point(psn) ;
	LENGTH turning_point_&psn $70 ;

	* Income tax ;
	IF TaxIncA&psn < TaxThr1 <= _TaxIncA&psn THEN turning_point_&psn = 'start of first income tax bracket' ;
	IF TaxIncA&psn < TaxThr2 <= _TaxIncA&psn THEN turning_point_&psn = 'start of second income tax bracket' ;
	IF TaxIncA&psn < TaxThr3 <= _TaxIncA&psn THEN turning_point_&psn = 'start of third income tax bracket' ;
	IF TaxIncA&psn < TaxThr4 <= _TaxIncA&psn THEN turning_point_&psn = 'start of fourth income tax bracket' ;

	* Medicare levy ;
	IF IncPrivA&psn < MedLevSingThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy (singles, standard)' ;
	IF IncPrivA&psn < MedLevSAPTOThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy (single, SAPTO)' ;
	IF IncPrivA&psn < MedLevFamIncThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy (families, standard)' ;
	IF IncPrivA&psn < MedLevSaptoFamIncThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy (families, SAPTO)' ;

	* Medicare levy surcharge ;
	IF IncPrivA&psn < MedLevSurTier1ThrS <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 1, singles)' ;
	IF IncPrivA&psn < MedLevSurTier2ThrS <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 2, singles)' ;
	IF IncPrivA&psn < MedLevSurTier3ThrS <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 3, singles)' ;
	IF IncPrivA&psn < MedLevSurTier1ThrC <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 1, families)' ;
	IF IncPrivA&psn < MedLevSurTier2ThrC <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 2, families)' ;
	IF IncPrivA&psn < MedLevSurTier3ThrC <= _IncPrivA&psn THEN turning_point_&psn = 'start of Medicare levy surcharge (tier 3, families)' ;

	* LITO EAH: update to new thresholds ;
	IF TaxIncA&psn < LitoThr1 <= _TaxIncA&psn THEN turning_point_&psn = 'start of LITO tapering' ; * Updated threshold ; 
	IF TaxIncA&psn < LitoThr2 <= _TaxIncA&psn THEN turning_point_&psn = 'start of second LITO taper' ; *Include second taper ; 
	IF TaxIncA&psn < 66667 <= _TaxIncA&psn THEN turning_point_&psn = 'end of LITO tapering' ;

    * EAH: LAMITO ;
	IF TaxIncA&psn < LamitoThr1 <= _TaxIncA&psn THEN turning_point_&psn = 'start of LAMITO increase taper rate' ; * Include increase taper ; 
    IF TaxIncA&psn < LamitoThr2 <= _TaxIncA&psn THEN turning_point_&psn = 'start of LAMITO decrease taper rate' ; *Include decrease taper ; 
	IF TaxIncA&psn < 120000 <= _TaxIncA&psn THEN turning_point_&psn = 'end of LAMITO tapering' ;

	* Newstart and PPP ;
	IF IncPrivA&psn < UnempThr1F <= _IncPrivA&psn THEN turning_point_&psn = 'start of JSP and PPP tapering (couples and singles without deps)' ;
	IF IncPrivA&psn < UnempThr2F <= _IncPrivA&psn THEN turning_point_&psn = 'start of JSP and PPP tapering (singles with deps)' ;

	* Pensions ;
	IF IncPrivA&psn < PenThrSF <= _IncPrivA&psn THEN turning_point_&psn = 'start of pension tapering (singles)' ;
	IF IncPrivA&psn < PenThrCF <= _IncPrivA&psn THEN turning_point_&psn = 'start of pension tapering (couples)' ;

	* PPS ;
	IF IncPrivA&psn < PPSPenThrF <= _IncPrivA&psn THEN turning_point_&psn = 'start of PPS tapering' ;

	* DSP under 21 ;
	IF IncPrivA&psn < DSPU21PenThrSF <= _IncPrivA&psn THEN turning_point_&psn = 'start of DSP under 21 tapering (singles)' ;
	IF IncPrivA&psn < DSPU21PenThrCF <= _IncPrivA&psn THEN turning_point_&psn = 'start of DSP under 21 tapering (couples)' ;

	* Youth Allowance (student) ;
	IF IncPrivA&psn < StudThr1F <= _IncPrivA&psn THEN turning_point_&psn = 'start of DSP under 21 tapering (singles)' ;
	IF IncPrivA&psn < StudThr2F <= _IncPrivA&psn THEN turning_point_&psn = 'start of DSP under 21 tapering (couples)' ;

	* Youth Allowance (other) ;
	IF IncPrivA&psn < YngUnempThr1F <= _IncPrivA&psn THEN turning_point_&psn = 'start of Youth Allowance (other) lower tapering' ;
	IF IncPrivA&psn < YngUnempThr2F <= _IncPrivA&psn THEN turning_point_&psn = 'start of Youth Allowance (other) upper tapering' ;

	* FTB-A ;
	IF IncPrivA&psn < FtbaBaseBasicThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of FTBA (method 2) tapering' ;
	IF IncPrivA&psn < FtbaMaxThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of FTBA (method 1) tapering' ;

	* FTB-B ;
	IF IncPrivA&psn < FtbbSecThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of FTBB tapering' ;

%MEND Turning_Point ;

************************************************************************************
* Macro:   RemoveZeroVar                                                           *
* Purpose: Drop variables that only contain zeros.								   *
************************************************************************************;
%MACRO RemoveZeroVar(SetName) ;

	* Calculate number of numeric variables that need to be reviewed for zero values ;
	DATA _NULL_ ;
	    SET &SetName ;
	    ARRAY NumericVar{ * } _NUMERIC_ ;
	    CALL SYMPUT( 'NumNumericVar' , DIM( NumericVar ) ) ;
	RUN ;

	* Create list of variables with only zero values and should be dropped ;
	%DO j = 1 %TO &NumNumericVar ;
	    DATA _NULL_ ;
	        SET &SetName END = EOF ;
	        LENGTH VarName $30 ;

	        * Declare arrays to collect numeric variables ;
	        ARRAY NumericVar{ * } _NUMERIC_ ;
	        ARRAY Total{ &NumNumericVar } ;

	        * Find sum of absolute value of each numeric variable ;
	        IF _N_ = 1 THEN Total{ &j } = 0 ;
	        Total{ &j } = Total{ &j } + ABS( NumericVar{ &j } ) ;
	        RETAIN Total: ; 

	        * If sum at the last record is zero then include it in the drop list ;
	        %LET Zero = ;

			IF EOF AND Total{ &j } = 0 THEN DO ;
	            CALL VNAME( NumericVar{ &j } , VarName ) ;
	            CALL SYMPUT( 'Zero' , VarName ) ;
	        END ;
	    RUN ;

	    %LOCAL ZeroVarList ;
	    %LET ZeroVarList = &ZeroVarList &Zero ;
	%END ;

	* Drop zero value variables ;
	DATA &SetName ;
	    SET &SetName ;
	    DROP &ZeroVarList ;
	RUN ;

%MEND RemoveZeroVar ;

************************************************************************************
    * Macro:   ExportCameos                                                        *
    * Purpose: Export cameo results from SAS to Cameo output spreadsheet           *    
************************************************************************************;
%MACRO ExportCameos ;
    %IF &RunEMTR = Y %THEN %DO ;
		%DO i = 1 %to &NumFams  ;

            DATA FamilyTemp&i ; 
				SET &Outfile ; 
				WHERE FamilyID = &i ; 

				EffTaxu = PayOrRefAmntAu - IncTranAu ; 
			    EffTaxNetCCu = PayOrRefAmntAu - IncTranAu + CcsCostAu ; * Create a variable which takes into account net cost of childcare. IncTranAu includes the CCSAmtAu ; 

				CALL SYMPUTX( "FamSheet&i" , FamilyLabel ) ; 

			RUN ;

	        * Extract each family into a dataset ;
	        DATA FamilyEMTR&i ;
	            * Look ahead to next record, then used to calculate change from current record ;
	            SET FamilyTemp&i ;
				SET FamilyTemp&i ( FIRSTOBS = 2 RENAME = ( &RenameEmtrVarList ) ) ;

	            * Calculate change in EMTR from each component of the disposable income equation ;
	            %LET NumEmtrVarList = %SYSFUNC( COUNTW( &EmtrVarList , - ) ) ;

				
	            %DO j = 1 %TO &NumEmtrVarList %BY 4 ;
	                %LET EmtrVar1 = %SCAN( &EmtrVarList , &j , - ) ;       /* Variable */
	                %LET EmtrVar2 = %SCAN( &EmtrVarList , &j + 1 , - ) ;   /* Income */
	                %LET EmtrVar3 = %SCAN( &EmtrVarList , &j + 2 , - ) ;   /* Gain or loss or No Change */
	                %LET EmtrVar4 = %SCAN( &EmtrVarList , &j + 3 , - ) ;   /* Label */

	                /* If indicator is Pos, then subtract next value by current value, eg tax, which increase with income */
				    %IF &EmtrVar3 = Pos %THEN %DO ;
						IF _&EmtrVar2 - &EmtrVar2 = 0 THEN EMTR_&EmtrVar1 = 0 ;
	                    ELSE EMTR_&EmtrVar1 = ( _&EmtrVar1 - &EmtrVar1 ) / ( _&EmtrVar2 - &EmtrVar2 ) ;
	                %END ;

	                /* If indicator is Neg, then subtract current value by next value, eg transfer payment which decrease with income */
	                %ELSE %IF &EmtrVar3 = Neg %THEN %DO ;
					    IF _&EmtrVar2 - &EmtrVar2 = 0 THEN EMTR_&EmtrVar1 = 0 ;
	                    ELSE EMTR_&EmtrVar1 = ( &EmtrVar1 - _&EmtrVar1 ) / ( _&EmtrVar2 - &EmtrVar2 ) ;
	                %END ;

	                /* Create lists of variables to keep */
	                %LOCAL EmtrKeepList ;
					%LOCAL EmtrIncKeepList ; 
					%LOCAL EmtrVarKeepList ;

	                %IF &EmtrVar3 = NA %THEN %DO ;
	                    /* Add non EMTR variable */
	                    %LET EmtrIncKeepList = &EmtrIncKeepList &EmtrVar1 ;  
	                %END ;
	                %ELSE %IF &EmtrVar3 = NoChange %THEN %DO ;
	                    /* Add non EMTR variable */
	                    %LET EmtrVarKeepList = &EmtrVarKeepList &EmtrVar1 ;  
	                %END ;
	                %ELSE %DO ;
	                    /* Add EMTR variable */
	                    %LET EmtrKeepList = &EmtrKeepList EMTR_&EmtrVar1 ;  
	                %END ;

	                * Label variables for EMTR presentation ;
	                %LOCAL EmtrLabelList ;
	                %IF &EmtrVar2 NE NA %THEN %DO ;
	                    %LET EmtrLabelList = &EmtrLabelList EMTR_&EmtrVar1 = "&EmtrVar4" ;
	                %END ;
	                %ELSE %DO ;
	                    %LET EmtrLabelList = &EmtrLabelList &EmtrVar1 = "&EmtrVar4" ;
	                %END ;
	            %END ;

				LABEL &EmtrLabelList ;

	            * Mark known EMTR jumps ;
	            %Turning_Point(r)
	            IF Coupleu = 1 THEN do ;
	                %Turning_Point(s) ;
	            END ;

	            KEEP FamilyID FamilyLabel &EmtrKeepList &EmtrIncKeepList &EmtrVarKeepList Turning_Point_r Turning_Point_s ;
	       	RUN ;  
			
			%IF &CutRows = Y %THEN %DO ; 
				* For exporting and charting. Only keep points necessary for charting, i.e. where there are changes to EMTRs ; 
				DATA FamilyCutRows&i ;
				    FORMAT FamilyID FamilyLabel IncPrivAr IncPrivAs &EMTRKeepList ; 
					SET FamilyEMTR&i ( KEEP = FamilyID FamilyLabel IncPrivAr IncPrivAs &EMTRKeepList PenType: AllowType: Turning_Point_r Turning_Point_s ); 
					BY FamilyID ; 

					IF First.FamilyID OR Last.FamilyID THEN OUTPUT ;

					ELSE IF 
		               ABS ( EMTR_EffTaxu - LAG( EMTR_EffTaxu ))                >= 0.0001  
				    OR ABS ( EMTR_EffTaxNetCcu - LAG( EMTR_EffTaxNetCcu ))      >= 0.0001  
					OR ABS ( EMTR_PayOrRefAmntAu - LAG( EMTR_PayOrRefAmntAu ) ) >= 0.0001 
					OR ABS ( EMTR_IncTranAu - LAG( EMTR_IncTranAu ) )           >= 0.0001 
					OR ABS ( EMTR_CcsOutPocketAu - LAG( EMTR_CcsOutPocketAu ) ) >= 0.0001 


					THEN OUTPUT ; 

				RUN ; 
					
				* Double the rows and change the private income for the reference person for charting ; 
				DATA Family&i ;
					SET FamilyCutRows&i ;
					    BY FamilyID ;
		                IF LAST.FamilyID = 0 THEN OUTPUT ;

					SET FamilyCutRows&i ( FIRSTOBS = 2 KEEP = FamilyID IncPrivAr ) ; 
					    BY FamilyID ;

						IF FamilyID = &i THEN OUTPUT ;
					    ELSE IF FIRST.FamilyID = 0 THEN OUTPUT ;
				RUN ; 
			%END ; 
			%ELSE %DO ; 
				DATA Family&i ; 
                    RETAIN FamilyID FamilyLabel IncPrivAu ; 
					SET FamilyEMTR&i ; 
				RUN ; 
			%END ;

		%END ;
	%END ;

	%ELSE %IF &RunCompare = N %THEN %DO ;
        
        %DO i = 1 %to &NumFams  ;
            DATA Family&i ;
                SET &Outfile (KEEP = &RateTypeList &CameoList FamilyLabel);
                WHERE FamilyID = &i ;
                CALL SYMPUTX( "FamSheet&i" , FamilyLabel );
            RUN ;
        %END ;
    %END ;

    %ELSE %DO ;

        %DO i = 1 %to &NumFams  ;
            DATA Family&i ;
                SET CAPITA_Compare ;
                WHERE FamilyID_Base = &i ;
                CALL SYMPUTX( "FamSheet&i" , FamilyLabel_Base ); 
                 %LET NumChangeVars = %SYSFUNC( COUNTW( &CameoBaseList ) ) ;
                 %DO j = 1 %TO &NumChangeVars ;

                    %LET CameoName_Base = %SCAN( &CameoBaseList , &j ) ;

                    %LET CameoName_Sim = %SCAN( &CameoSimList , &j ) ;

                    %LET CameoName_Change= %SCAN( &CameoChangeList , &j ) ;

                    &CameoName_Change = &CameoName_Sim - &CameoName_Base ;
                                                        
                %END ;      

				 %LET RateTypeChangeCount= %SYSFUNC( COUNTW( &RateTypeBaseList ) ) ;
                 %DO j = 1 %TO &RateTypeChangeCount;

                    %LET RateType_Base = %SCAN( &RateTypeBaseList , &j ) ;

                    %LET RateType_Sim = %SCAN( &RateTypeSimList , &j ) ;
                                                        
                %END ;      

            KEEP FamilyLabel_Base FamilyID_Base &RateTypeBaseList &RateTypeSimList &CameoBaseList &CameoSimList &CameoChangeList ;
            RUN ;
        %END ;
    %END ;

    %DO i = 1 %to &NumFams  ;
		%IF &DropZeroVars = Y %THEN %DO ;
			OPTIONS NONOTES ;
		      %RemoveZeroVar(Family&i)
		      OPTIONS NOTES ;
		%END ;

		PROC EXPORT DATA = Family&i 
        OUTFILE = "&OutCameoFile"
                  %IF &RunEMTR = Y %THEN %DO ;
                        LABEL 
                  %END ;
                  DBMS = EXCELCS REPLACE ;
			SHEET = "&&Famsheet&i"; 
        RUN ;


	%END ;

%MEND ExportCameos ;
%ExportCameos 


