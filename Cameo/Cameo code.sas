************************************************************************************
* Name of program: RunCAMEO.sas                                                    * 
* Purpose: Run CAMEO code.                                                         *
* Description: This program produces cameos which illustrate the                   *
*              impact of policy changes on hypothetical families.                  *
*              If the RunEMTR flag is set, it instead produces effective           *
*			   marginal tax rates for a hypothetical family                        * 
*																				   *
*                                                                                  *
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
%INCLUDE "\\sas\models$\TAD\Models\CAPITA\2. Master Version\CURRENT VERSION 2.3 (PUBLIC RELEASE)\DefineCapitaDirectory.sas" ;

*Specify location of cameo code and spreadsheet used for creating cameo basefile;
%LET CameoFolder = \\sas\models$\TAD\Models\CAPITA\2. Master Version\CURRENT VERSION 2.3 (PUBLIC RELEASE)\Cameo\ ;
%LET CameoInput = &CameoFolder.Cameo input.xlsx ;
%LET CameoInitialise = &CameoFolder.CameoInitialisation.sas ;

*Specify location of policy modules;
%LET PolicyFolder = &CapitaDirectory. ;
%LET RunCapita = &CapitaDirectory.RunCAPITA.sas ;
%LET RunCapitaCompare = &PolicyFolder.RunCapitaCompare.sas ;

* Specify year and quarter of interest ;
%LET CameoYear = 2017 ;    * Format 20XX = 20XX-YY ;  
%LET CameoQuarter = Sep ;  * Only used for quarterly runs, Valid quarters are Mar Jun Sep Dec;


* Specify the time duration of analysis ;
* A for Annual, the financial year. This options uses annualised parameters calculated using time weighted average of each quarter ;
* Q for Quarter. This option uses actual parameter values from the appropriate quarter ;
%LET CameoDuration = A ;

* Specify how to model the removal of the energy supplement;  
* Y = Choose to give everyone the ES; 
* N = Choose to give noone the ES; 
%LET CameoRunEs = Y ; 

*Use for switch: N if running baseworld, Y if running comparison (has no effect if RunEMTR is set to Y) ;
%LET RunCompare = Y ;

* Use for switch: N if running cameos, Y if running effective marginal tax rate scenario (note that you can't run both in the same run). 
* If Y, make sure that all selected input rows in the CameoInput spreadsheet have values for the SpsIncSplit, SpsInc, Start, Stop and Increment columns ;
%LET RunEMTR = N ;

* Use for switch: N you want to keep all variables in CameoList or EMTRVarlist in the final output. Y if you want to drop all variables that are zero for all rows ;
%LET DropZeroVars =  Y;

*Specify character variables required for the cameo output results ; ;
%LET RateTypeList = 
					FtbaType
/*					AllowRateTyper*/
/*					PenRateTyper*/
/*					AllowRateTypes*/
/*					PenRateTypes*/
					;
*Specify numeric variables required for the cameo output results ;  ;
%LET CameoList = 
                 FamilyID 
                 IncPrivAu 
                 IncPrivAr 
                 IncPrivAs 
/*                 IncDispAu */
/*                 IncDispAr*/
/*                 IncDispAs*/
/*                 PayOrRefAmntAu */
/*                 PayorRefAmntAr*/
/*                 PayorRefAmntAs*/
/*                 IncTranAu*/
/*                 IncTranAr*/
/*                 IncTaxTranFr*/
/*                 IncNonTaxTranFr*/

				   AllTotAu
				   PppTotAu
/*				   NsaTotAu*/
/*				   YaOtherTotAu*/
/*				   YaStudTotAu*/
/*				   AgeTotAu*/
/*				   DspTotAu*/
/*				   CarerTotAu*/
/*				   DspU21TotAu*/
/*				   PpsTotAu*/
                   FtbaFinalA 
                   FtbbFinalA 


/*                 CareAllFr*/
/*                 CareAllAr*/
/*                 CareAllFlagr*/
/*                 CareSupAr*/
/*                 CareSupFr*/
/*                 PenTyper*/
/*                 CarerPenBasicFr*/
/*                 CarerPenSupBasicFr*/
/*                 CarerTotFr */
/*                 TaxIncAr */


/*                   FtbbFlag*/
/*                 SkBonusAr*/
/*                    SkBonusAs*/
/*                 AdjTaxIncAu */
/*                 AgePenBasicAr*/
/*                 AgePenBasicAs*/
/*                 CarerPenBasicAr*/
/*                 CarerPenBasicAs */
/*                 DSPPenBasicAr*/
/*                 DSPPenBasicAs*/
/*                 DSPU21PenBasicAr*/
/*                 DSPU21PenBasicAs*/
/*                 MedLevAu */
/*                 NsaAllBasicAr */
/*                 NsaAllBasicAs */
/*                 AgePenEsAr*/
/**/
/*                 CareAllAr              */
/*                 CareSupAr*/
/*                 IncSupBonAr*/
/*                 SenSupAr*/
/*                 SenSupEsAr*/
/*                 TelAllAr*/
/*                 UtilitiesAllAr*/
/*                 SifsAr */
/**/
/**/
/*                 PpsPenBasicAr */
/*                 PpsPenSupBasicAr*/
                   PpsTotAr
/*                 PpsPenEsAr*/
/*                 PpsRAssAr*/
/*                 PpsPharmAllAr*/
/*                 AllTotFr*/
/**/
/*                 PenRedF*/
/*                 IncPenTestF*/
/*                 IncOrdFr*/


/*                 PppAllBasicAr */
/*                 PppAllBasicAs */
/*                 PppAllBasicAr */
/*                 TotTaxOffsetAu */
/*                 RebIncAU */

/*              Current childcare policy */

/*                CcTestInc*/
/*                ActivHrWr*/
/*                ActivHrWs*/
/*                CcbMaxHrW*/
/*                CcbInfElig*/
/*                CcrElig*/
                CcbAmtAu
                CcbCostAu
                CcrAmtAu
/*                CcrOutPocketAu*/
/*                CcWPerYr1*/
/*                CcWPerYr2*/
/*                CcbAmtW1*/
/*                CcbAmtW2*/
/*                CcrAmtA1*/
/*                CcrAmtA2*/

/*              Proposed childcare policy */

                  CcTestInc
                  CcsRateA
                  CcsAmtAu
/*                  CcsAmtA1*/
/*                  CcsAmtA2*/
/*                CcsAmtA3*/
/*                CcsAmtA4*/
                  CcsCostAu
/*                  CcsCostA1*/
/*                  CcsCostA2*/
/*                CcsCostA3*/
/*                CcsCostA4*/
                  CcsOutPocketAu
/*                  CcsOutPocketA1*/
/*                  CcsOutPocketA2*/
/*                CcsOutPocketA3*/
/*                CcsOutPocketA4*/
                      
                ;

%LET RateTypeCount = %SYSFUNC( COUNTW( &RateTypeList ) ) ;
%LET NumVars = %SYSFUNC( COUNTW( &CameoList ) ) ;

*Specify name of list for cameo output comparison ;
%LET CameoBaseList = ;
%LET CameoSimList = ;
%LET CameoChangeList = ;

*Age Pension Age is 65.5 in 2017-18, 2018-19 and increases to 66 in 2019-20, 2020-21; 
*Note: if running Age Pensioner cameo in 2019-20 and 2020-21 then change AgePenAge to 66; 
%LET AgePenAge = 65.5 ;

%LET RateTypeBaseList = ;
%LET RateTypeSimList = ;

%GLOBAL NumFams ;

%MACRO ValidateQuarter/MINOPERATOR;
	%PUT &=CameoQuarter;                                               /*put the value of the macro variable to the log*/
	%IF NOT(%UPCASE(&CameoQuarter) IN MAR JUN SEP DEC) %THEN           /*check if macro variable is in the validated list*/
	    %DO;                                                			/*if not*/
	        %PUT ERROR: Valid values for CameoQuarter are Mar, Jun, Sep or Dec.; 
	        %ABORT;                                         		   /*stop submitted code*/
	    %END;
%MEND ValidateQuarter;
%ValidateQuarter;
************************************************************************************
*   Macro: CameoCompareList                                                        *
*   Purpose: Create 3 lists for comparing variables before and after changes, and  *
*            their differences                                                     *
************************************************************************************;
%MACRO CameoCompareList;

    %DO i = 1 %TO &NumVars ;

	    %LET CameoName = %SCAN( &CameoList , &i ) ;
	    %LET CameoBaseList = &CameoBaseList &CameoName._Base ;
	    %LET CameoSimList = &CameoSimList &CameoName._Sim ;
	    %LET CameoChangeList = &CameoChangeList &CameoName._Change ;

    %END ;    

%MEND CameoCompareList;
************************************************************************************
*   Macro: RateTypeList                                                            *
*   Purpose: Create 2 lists for comparing rate type before and after changes       *
************************************************************************************;
%MACRO RateTypeCompareList;

    %DO i = 1 %TO &RateTypeCount ;

	    %LET RateType = %SCAN( &RateTypeList, &i ) ;
	    %LET RateTypeBaseList = &RateTypeBaseList &RateType._Base ;
	    %LET RateTypeSimList = &RateTypeSimList &RateType._Sim ;

    %END ;    

%MEND RateTypeCompareList;

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

                    /* List components of EMTR */ 
                    EffTaxu - IncPrivAr - Pos - EMTR Effective tax(u) -
                    PayOrRefAmntAu - IncPrivAr - Pos -  EMTR Total tax payable(u) -
                    IncTranAu - IncPrivAr - Neg - EMTR Total transfer payment(u) -

                    PenTotAu - IncPrivAr - Neg - EMTR Total pensions (u) -
                    AgeTotAu - IncPrivAr - Neg - EMTR Age Pension (u) -
                    DspTotAu - IncPrivAr - Neg - EMTR DSP Pension (u) -
                    CarerTotAu - IncPrivAr - Neg - EMTR Carer Pension (u) -
                    WifeTotAu - IncPrivAr - Neg - EMTR Wife Pension (u) -
                    DspU21TotAu - IncPrivAr - Neg - EMTR DSP Pension under 21 (u) -
                    PpsTotAu - IncPrivAr - Neg - EMTR Parenting Payment Single (u) -

                    AllTotAu - IncPrivAr - Neg - EMTR Total Allowances(u) -
                    PppTotAu - IncPrivAr - Neg - EMTR Parenting Payment Partnered(u) -
                    NsaTotAu - IncPrivAr - Neg - EMTR Newstart Allowance(u) -
                    YaOtherTotAu - IncPrivAr - Neg - EMTR Youth Allowance Other (u) -
                    YaStudTotAu - IncPrivAr - Neg - EMTR Youth Allowance Student (u) -
                    AustudyTotAu - IncPrivAr - Neg - EMTR Austudy (u) -
                    WidowTotAu - IncPrivAr - Neg - EMTR Widow payment (u) -

                    DvaTotAu - IncPrivAr - Neg - EMTR DVA entitlements (u) -
                    ServiceTotAu - IncPrivAr - Neg - EMTR DVA Service Pension (u) -

                    FtbaFinalA - IncPrivAr - Neg - EMTR FTB A (u) -
                    FtbbFinalA - IncPrivAr - Neg - EMTR FTB B (u) -

                    SupTotAu - IncPrivAr - Neg - EMTR Total Supplements (u) -

                    GrossIncTaxAu - IncPrivAr - Pos - EMTR Gross income tax(u) - /*changed from TaxIncAr */ 
                    UsedSaptoAu - IncPrivAr - Neg - EMTR Used SAPTO (u) -
                    UsedBentoAu - IncPrivAr - Neg - EMTR Used BENTO (u) -
                    UsedLitoAu - IncPrivAr - Neg - EMTR Used LITO(u) -    /*changed from TaxIncAr */
                    UsedItem20Au - IncPrivAr - Neg - EMTR Used Item 20 offests (u) -
                    XRefTaxOffsetAu - IncPrivAr - Neg - EMTR Unused refundable tax offset (u) -
                    MedLevAu - IncPrivAr - Pos - EMTR Medicare levy (u) -
                    MedLevSurAu - IncPrivAr - Pos - EMTR Medicare levy surcharge (u) - 
                    TempBudgRepLevAu - IncPrivAr - Pos - EMTR Temporary Budget Repair levy (u) - /*changed from TaxIncAr */


                    /* Variables not requiring EMTR calculation */
                    EffTaxu - NA - NoChange - Effective tax(u) -
                    PayOrRefAmntAu - NA - NoChange - Tax liability or refund(u) -
                    IncTranAu - NA - NoChange - Transfer income(u) -
                    AllTotAu - NA - NoChange - Allowance total(u) -
                    NsaTotAu - NA - NoChange - Newstart allowance(u) -
                    AgeTotAu - NA - NoChange - Age pension(u) -
                    FtbaFinalA - NA - NoChange - Family tax benefit(u) -
                    GrossIncTaxAu - NA - NoChange - Gross income tax(u) -
                    GrossIncTaxAr - NA - NoChange - Gross income tax(r) -
                    GrossIncTaxAs - NA - NoChange - Gross income tax(s) -
                    UsedSaptoAu - NA - NoChange - Used Sapto(u) -
                    UsedBentoAu - NA - NoChange - Used Bento(u) -
                    UsedLitoAu - NA - NoChange - Used Lito(u) -
                    UsedLitoAr - NA - NoChange - Used Lito(r) -
                    MedLevAu - NA - NoChange - Medicare levy(u) -
                    MedLevSurAu - NA - NoChange - Medicare levy surcharge(u) - 
                    TempBudgRepLevAu - NA - NoChange - Temporary budget repair levy(u) -
                    AllowTyper - NA - NoChange - Allowance type(r) -
                    PenTyper - NA - NoChange - Pension type(r) -
                    DvaTyper - NA - NoChange - DVA type(r) -

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
        /* Rename variable only if for EMTR purposes */
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

*Determine number of hypothetical families and assign to NumFams ;
DATA _NULL_;
    SET CameoFamilies ( OBS = MAX );
    CALL SYMPUTX( 'NumFams' , _N_ ); 
RUN;
************************************************************************************
*   Macro: IncomeLists                                                             *
*   Purpose: Import required income lists for each family                          *
************************************************************************************;
%MACRO IncomeLists ;

    %DO i = 1 %TO &NumFams;       * for each family ;

        DATA _NULL_;                        
        
            SET CameoFamilies ( OBS = &i ); 
            *extract name of income list and assign to 'List' ;
            CALL SYMPUTX( 'List', IncomeList );
        RUN;

        PROC IMPORT DATAFILE = "&CameoInput"  
            REPLACE OUT = Incomes&i 
            DBMS = excelcs;  
            SHEET = "&List";       *read in this income list;
        RUN;

        DATA Incomes&i;     *add on FamilyID to income list data set ;
            SET Incomes&i;      
            FamilyID = &i;
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
%MACRO EmtrIncome ;

    * Add reference and spouse income onto family dataset imported above. ;
    * Unlike the cameo run, incomes are not imported from the input spreadsheet, ;
    * but are instead created in the below data step to produce small income increments ;
    DATA CameoBase ;   
 
        SET CameoFamilies ;

        DO j = Start TO Stop BY Increment ;
            IncPrivCameor = j ;

            IF SpsIncSplit = 'Variable' THEN DO ;
                IncPrivCameos = IncPrivCameor * SpsInc / ( 1 - SpsInc ) ;
            END ;

            IF SpsIncSplit = 'Fixed' THEN DO ;
                IncPrivCameos = SpsInc ;
            END ;

            OUTPUT ;
        END ;

        DROP j ;

    RUN ;

%MEND EmtrIncome ;

************************************************************************************
*   Macro: IncomeOption                                                            *
*   Purpose: If RunEMTR is selected generate EMTR income lists for each family,    *
*            otherwise use the Cameo incomes                                       *
************************************************************************************;
%MACRO IncomeOption ;

	%IF &RunEMTR = Y %THEN %DO ;
		%EmtrIncome
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
    %INCLUDE "&CameoInitialise";

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
                Kids&i.u = Kids&i.u + 1 ;
                TotalKidsu = TotalKidsu + 1 ;
            END ;

        %END ;

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
                                    
    *Assume all income is derived from wages and salaries and children have no income. 
     Assume noone is eligible for DVA payments and no uprated payments;

    ************************************************************************************
    * Macro:   IncomeAssign                                                            *
    * Purpose: Assign all income to wages and salaries                                 *    
    ************************************************************************************; 
    %MACRO IncomeAssign( psn ) ;

        %IF ActualAge&psn < &AgePenAge %THEN %DO ;

            IncWageSW&psn    = IncPrivCameo&psn./52 ;
            IncWageSF&psn    = IncPrivCameo&psn./26 ;
            IncWageSA&psn    = IncPrivCameo&psn ;
            IncWageSPA&psn   = IncPrivCameo&psn  ;
            IncServiceA&psn  = IncWageSA&psn ;

        %END ;

        %ELSE %DO ;

            IncTaxSuperImpA&psn    = IncPrivCameo&psn ;
            IncTaxCompPrivSupImpA&psn = IncTaxSuperImpA&psn ;

        %END ;

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

                %IF ActualAge&psn GE 25 %THEN %DO; 
					ParPaySW&psn = 1 ;
				%END;

            %END ;

            %ELSE %DO ;

				/* Since individuals who are not studying full time and are aged below 22 are eligible
                   for Youth Allowance (Other), the person must be 22 years or over to be given PPP when not
			       studying full time. */

	                IF ActualAge&psn GE 22 THEN ParPaySW&psn = 1 ;

            %END ;

    %MEND AssignParentPay ;

    %AssignParentPay ( r )

     IF ActualAges > 0 THEN DO ;

        %AssignParentPay ( s ) 

        IF ParPaySWr = 1 AND ParPaySWs = 1 THEN ParPaySWr = 0 ;
    
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
	        %INCLUDE "&RunCapita"; 
	    %END ;

	    %ELSE %DO ;
	        %CameoCompareList
			%RateTypeCompareList
	        %INCLUDE "&RunCapitaCompare"; 
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
		%LET OutCameoFile = &CameoFolder.&datenow &timenow EMTR Output.xlsb ;



	%END ;

	%ELSE %DO ;
		%LET InCameoFile = &CameoFolder.Cameo Output template.xlsx ;
		%LET OutCameoFile = &CameoFolder.&datenow &timenow Cameo Output.xlsx ;
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

	* Temporary Budget Repair levy ;
	IF IncPrivA&psn < TempBudgRepLevThr <= _IncPrivA&psn THEN turning_point_&psn = 'start of Temporary Budget Repair levy' ;

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

	* LITO ;
	IF TaxIncA&psn < LitoThr <= _TaxIncA&psn THEN turning_point_&psn = 'start of LITO tapering' ;
	IF TaxIncA&psn < 66667 <= _TaxIncA&psn THEN turning_point_&psn = 'end of LITO tapering' ;

	* Newstart and PPP ;
	IF IncPrivA&psn < UnempThr1F <= _IncPrivA&psn THEN turning_point_&psn = 'start of NSA and PPP tapering (couples and singles without deps)' ;
	IF IncPrivA&psn < UnempThr2F <= _IncPrivA&psn THEN turning_point_&psn = 'start of NSA and PPP tapering (singles with deps)' ;

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

	* SIFS ;
	IF IncPrivA&psn < SifsThrLwr <= _IncPrivA&psn THEN turning_point_&psn = 'start of SIFS phase in' ;
	IF IncPrivA&psn < SifsThrMid <= _IncPrivA&psn THEN turning_point_&psn = 'start of SIFS phase out' ;
	IF IncPrivA&psn < SifsThrUpr <= _IncPrivA&psn THEN turning_point_&psn = 'end of SIFS phase out' ;

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
		%DO i = 1 %TO &NumFams ;


	        DATA FamilyTemp&i ;
	            SET &Outfile ;
	            WHERE FamilyID = &i ;
	            EffTaxu = PayOrRefAmntAu - IncTranAu ;                 * Calculate effective Tax = tax paid less transfers received ;      
	            CALL SYMPUTX( "FamSheet&i" , FamilyLabel ) ;
	        RUN ;

	        * Extract each family into a dataset ;
	        DATA Family&i ;
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

	                /* If indicator is Pos, then divide current value by next value, eg tax, which increase with income */
	                %IF &EmtrVar3 = Pos %THEN %DO ;
	                    IF _&EmtrVar2 - &EmtrVar2 = 0 THEN EMTR_&EmtrVar1 = 0 ;
	                    ELSE EMTR_&EmtrVar1 = ( _&EmtrVar1 - &EmtrVar1 ) / ( _&EmtrVar2 - &EmtrVar2 ) ;
	                %END ;

	                /* If indicator is Neg, then divide current value by next value, eg transfer payment which decrease with income */
	                %ELSE %IF &EmtrVar3 = Neg %THEN %DO ;
	                    IF _&EmtrVar2 - &EmtrVar2 = 0 THEN EMTR_&EmtrVar1 = 0 ;
	                    ELSE EMTR_&EmtrVar1 = ( &EmtrVar1 - _&EmtrVar1 ) / ( _&EmtrVar2 - &EmtrVar2 ) ;
	                %END ;

	                /* Keep selected variables */
	                %LOCAL EmtrKeepList ;
	                %IF &EmtrVar3 = NA %THEN %DO ;
	                    /* Add non EMTR variable */
	                    %LET EmtrKeepList = &EmtrKeepList &EmtrVar1 ;  
	                %END ;
	                %ELSE %IF &EmtrVar3 = NoChange %THEN %DO ;
	                    /* Add non EMTR variable */
	                    %LET EmtrKeepList = &EmtrKeepList &EmtrVar1 ;  
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

	            KEEP &EmtrKeepList Turning_Point_r Turning_Point_s ;
	       	RUN ;  
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
