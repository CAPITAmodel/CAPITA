
**************************************************************************************
* Program:      BasefileInitialisation.sas                                           *
* Description:  Initialise variables to be created in subsequent basefiles modules.  * 
**************************************************************************************;

**************************************************************************************
*   Step 1 - Define variables to be created at the person level                      *
**************************************************************************************;

* Define person level character variables that need to be initialised ;

%LET PersonCharList = 

       DataScopeTypep -
       DurUnempTypep -
       EducInstp - 
       FamPosp - 
       FundTypep -
       LfStatp - 
       StudyTypep - 
       Sexp - 

; 

* Define person level numeric variables that need to be initialised ;

%LET PersonNumList = 

        ActualAgep -
        AdjFbAp - 
        AdjFbFp - 
        AdjFbPAp -
		AssDeemedp -
		AssOtherp -
		AssPropBusp -
		AssTotp - 
		AssTrustCompp -
        DedChildMaintAp -  
        DeductionAp -
        DeductionFp - 
        DeductionPAp -
        DeductionWrkAp -
        FrankCrImpAp -
        FrankCrImpFp -
        FrankCrImpPAp -
        FrankCrImpWp -
        HrsPerWkp -
        IncAccSAp - 
        IncBusAp - 
        IncBusLExpFp - 
        IncBusLExpSAp - 
        IncBusLExpWp - 
        IncDivSAp - 
        IncIntAp - 
        IncIntBondSAp - 
        IncIntFinSAp - 
        IncIntLoanSAp - 
        IncIntPAp - 
        IncIntWp - 
        IncMaintSAp - 
        IncMaintSFp - 
        IncNetRentAp - 
        IncNetRentPAp -
        IncNetRentWp - 
        IncNonHHSAp - 
        IncNonTaxSuperImpAp -
        IncOSPenSAp - 
        IncOthInvSAp - 
        IncOthRegSAp - 
        IncPUTrustSAp - 
        IncRentNResSAp - 
        IncRentResSAp - 
        IncRoyalSAp -
        IncServiceAp - 
        IncSSSuperSAp -
        IncSSSuperSFp -  
        IncSSFlagp - 
        IncSSTotSAp - 
        IncSSTotSFp - 
        IncSuperImpAp -
        IncSuperSAp - 
        IncSupGovtImpAp -
        IncSupPrivImpAp -
        IncTaxCompGovtSupImpAp -      
        IncTaxCompPrivSupImpAp -     
        IncTaxSuperImpAp -
        IncTaxSuperImpPAp -
        IncTfCompPrivSupImpAp -
        IncTfCompGovtSupImpAp -
        IncTrustSAp - 
        IncWageSAp - 
        IncWageSFp - 
        IncWageSWp -
        IncWCompAp -
        IncWCompPAp -
        IncWCompSAp -
        MaintPaidSAp - 
        NetRentLossAp - 
        NetRentLossPAp - 
        NetInvLossAp - 
        NetInvLossPAp - 
        NetShareLossAp -
        NetShareLossPAp -
        NonSSTotSAp -
        NonSSTotSFp - 
        NumCareDepsp -
        PersIDp - 
        PPLFlagSp - 
        PropPrivImpp -
        RandAllAgeImpM80AndOverp -
        RandAllAgeImpF80AndOverp -
        RandAllAgeImp25to29p -
        RandAllAgeImp30to34p -
        RandAllAgeImp35to39p -
        RandAllAgeImp40to44p -
        RandAllAgeImp45to49p -
        RandAllAgeImp50to54p -
        RandAllAgeImp65to69p -
        RandAllAgeImp70to74p -
        RandAllAgeImp75to79p -
        RandTaxDedImpp -  
        RandYearArrImpp -      
        RandWorkforceIndepImpp -
		RandAbstudyEsGfthp -
		RandAgeEsGfthp -
		RandAustudyEsGfthp -
		RandCarerEsGfthp -
		RandDspEsGfthp -
		RandNsaEsGfthp -
		RandPppEsGfthp -
		RandPpsEsGfthp -
		RandWidowEsGfthp -
		RandWifeEsGfthp -
		RandYastudyEsGfthp -
		RandYaotherEsGfthp -
		RandFtbaEsGfthp -
		RandFtbbEsGfthp -
        RepEmpSupContAp -
        RepFbAp - 
        RepSupContAp - 
        RepSupContPAp - 
        TotSSNonSSFBWp - 
        TotSSNonSSAp -
        TotSSNonSSFp -
        TotSSNonSSWp -
        WrkForceIndepp -
        YaRandp -    
        YearOfArrivalp -

    ; 

**************************************************************************************
*   Step 2 - Define variables to be created at the income unit level                 *
**************************************************************************************;

* Define income level numeric variables that need to be initialised ;

%LET IncomeNumList = 

       CCBFlagSu -
       CCRFlagSu -
       Coupleu -
       Kids0u -
       Kids1u -
       Kids2u -
       Kids3u -
       Kids4u -
       Kids5u -
       Kids6u -
       Kids7u -
       Kids8u -
       Kids9u -
       Kids10u -
       Kids11u -
       Kids12u -
       Kids13u -
       Kids14u -
       Occupancyu -
       Renteru -

    ;

**************************************************************************************
*   Step 3 - Define variables to be created at the household level                   *
**************************************************************************************;

*Define household level character variables that need to be initialised ;

%LET HhCharList = 

        Stateh -

       ;

*Define household level numeric variables that need to be initialised ;

%LET HhNumList = 

       RentPaidFh -

       ;

**************************************************************************************
*   Step 4 - Initialise variables                                                    *
**************************************************************************************;

*   Define macros 'InitialiseNum' and 'InitialiseChar' which will be used for initialising
    numeric variables and character variables respectively.
    The argument is: 
    'VarList' - This is the name of the variable list containing the variables to be initialised ;

%MACRO InitialiseNum( VarList ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &VarList ) ) ;

    %DO i = 1 %TO &NumVars ;

        %* Select variable that needs to be initialised to zero ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

        %* Set variable to zero ;
        &Variable = 0 ;

    %END ;

%MEND InitialiseNum ;

%MACRO InitialiseChar( VarList ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &VarList ) ) ;

    %DO i = 1 %TO &NumVars ;

        %* Select variable that needs to be initialised ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

        %* Set variable at a length of 15 characters ;
        LENGTH &Variable $15 ;

        %* Initialise variable by setting it to a blank value ;
        &Variable = "" ;

    %END ;

%MEND InitialiseChar ;


* Now call the macros defined above to initialise the variables to be created in the remaining CAPITA 
  basefiles modules. Note each list must contain at least one variable ;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        * Call macro InitialiseChar to initialise character variables and set lengths ;
        %InitialiseChar( &PersonCharList )

        * Call macro InitialiseNum to initialise numeric variables ;
        %InitialiseNum( &PersonNumList )

RUN ;

DATA Income&SurveyYear ;

    SET Income&SurveyYear ;

        * Call macro InitialiseNum to initialise numeric variables ;
        %InitialiseNum( &IncomeNumList )

RUN ;

DATA Household&SurveyYear ;

    SET Household&SurveyYear ;

        * Call macro InitialiseChar to initialise character variables and set lengths ;
        %InitialiseChar( &HhCharList )

        * Call macro InitialiseNum to initialise numeric variables ;
        %InitialiseNum( &HhNumList )

RUN ;

