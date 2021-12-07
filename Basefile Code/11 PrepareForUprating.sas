
**************************************************************************************
* Program:      PrepareForUprating.sas                                               *
* Description:  Sets up the uprating datasets, calculates the uprating factors, and  *
*               defines the uprating series to be used for each of the variables.    *
*               The uprating is then performed in the 'Uprate.sas' module.           *                                                              
**************************************************************************************;

*******************************************************************************************************;
* Step 1: Define the list of uprating series to be used ;
*******************************************************************************************************;

%LET UpratingSeriesList = 

    CPI -
    AWE -
    CPILagged -
    AWELagged -

    ;

*******************************************************************************************************;
* Step 2: Import the uprating data from the 'Other Income Uprating' spreadsheet ;
*******************************************************************************************************;

* Quarterly data ;

PROC IMPORT OUT = UprDataQ
            DATAFILE = "&ImportLocation"
            DBMS = EXCELCS REPLACE;
            SHEET = "Quarterly" ;
RUN;

*******************************************************************************************************;
* Step 3: Create the dataset containing the uprating factors - 'UpratingData'                          ;
*******************************************************************************************************;

* Create a format for converting quarterly datasets to annual datasets ;

PROC FORMAT ;

    VALUE FinYear 

      	'1Jul2007'd - '30Jun2008'd = '2007' 
      	'1Jul2008'd - '30Jun2009'd = '2008' 
        '1Jul2009'd - '30Jun2010'd = '2009' 
        '1Jul2010'd - '30Jun2011'd = '2010' 
        '1Jul2011'd - '30Jun2012'd = '2011' 
        '1Jul2012'd - '30Jun2013'd = '2012' 
		'1Jul2013'd - '30Jun2014'd = '2013' 
        '1Jul2014'd - '30Jun2015'd = '2014' 
        '1Jul2015'd - '30Jun2016'd = '2015' 
        '1Jul2016'd - '30Jun2017'd = '2016' 
        '1Jul2017'd - '30Jun2018'd = '2017' 
        '1Jul2018'd - '30Jun2019'd = '2018' 
		'1Jul2019'd - '30Jun2020'd = '2019'
		'1Jul2020'd - '30Jun2021'd = '2020'
		'1Jul2021'd - '30Jun2022'd = '2021'
		'1Jul2022'd - '30Jun2023'd = '2022'
		'1Jul2023'd - '30Jun2024'd = '2023'
		'1Jul2024'd - '30Jun2025'd = '2024'
        ;

RUN ;

* Convert the quarterly uprating data to annual data using proc means ;

PROC MEANS DATA = UprDataQ NWAY NOPRINT ;

    CLASS Date ;

    FORMAT Date FinYear. ;    

    OUTPUT OUT = UpratingData MEAN = ;

RUN ;

* Adjust the 'Date' variable to a numerically formatted 'Year' variable ;

DATA UpratingData ;
            
    SET UpratingData ; 

        Year = INPUT ( PUT ( Date , FinYear. ) , 4. ) ;

    DROP _Type_ _Freq_ Date ;

RUN ;

* Define an 'UpratingFactors' macro to calculate the uprating factors using the uprating dataset ;

%MACRO UpratingFactors() ;

    %DO i = 1 %TO %SYSFUNC ( COUNTW ( &UpratingSeriesList ) ) ;

        %LET Series = %SCAN( &UpratingSeriesList , &i , - ) ;

        %* First create a macro variable equal to the base year index value for each of the series ;

        DATA _NULL_ ;

            SET UpratingData ;

                IF Year = &SurveyYear ;

                    CALL SYMPUT( 'Base' , &Series ) ;

        RUN ;

        %* Then divide each series by its base year index value to create the uprating factor series
          (retaining the Year variable so it appears in the first column for exporting purposes) ; 

        DATA UpratingData ;

            RETAIN Year ;

            SET UpratingData ;

                &Series = &Series / &Base ;

        RUN ;

    %END ;

%MEND UpratingFactors ;

%UpratingFactors ;
   
*******************************************************************************************************;
* Step 4: Define the uprating lists containing the variables to be uprated and the uprating series'    ;
*******************************************************************************************************;

* Define a global macro variable 'UpratingMethodsPerson' which lists variable names in the first column and 
  the series to be used to uprate the variables in the second column, for the person level dataset ;

%LET UpratingMethodsPerson = 

    /* Variables from ReadSIH - current year - private income variables */

    IncBusLExpSWp - AWE -
    IncEmpTotSWp - AWE - 
    IncSuperSWp - CPI -
    IncDivSWp - CPI -
    IncTrustSWp - CPI -
    IncIntFinSWp - CPI -
    IncNonHHSWp - CPI -
    IncMaintSWp - AWE -
    IncPUTrustSWp - CPI -
    IncRentNResSWp - CPI -
    IncRentResSWp - CPI -
    IncOSPenSWp - CPI -
    IncWCompSWp - AWE -
    IncAccSWp - AWE -
    IncOthInvSWp - CPI - 
    IncIntBondSWp - CPI -
    IncRoyalSWp - CPI -
    IncOthRegSWp - CPI -
    IncIntLoanSWp - CPI -
    NonSSTotSWp - CPI -
    NonSSCCSWp - CPI -
    NonSSSharesSWp - CPI -
    NonSSSuperSWp - CPI -
    IncSSTotSWp - CPI -
    IncSSCCSWp - CPI -
    IncSSSuperSWp - CPI -
    MaintPaidSWp - AWE -
    DedIntSharesSWp - CPI -
    SuperAcBalp - AWE -
	

    /* Variables from ReadSIH - current year - transfer income variables not modelled */

    DvaDisPenSWp - CPI -
    DvaWWPenSWp - CPI -
    DspSWp - CPI -          
    SpBSWp - CPI -
    PartAllSWp - CPI -
    AustudySWp - CPI -   
	PPLSWp - CPI -
	DaPPSWp - CPI -  

    /* Variables from ReadSIH - previous year */
	/* All previous year income variables no longer exist in SIH 2017-18, except business*/
    IncBusLExpSPAp - AWELagged -

    /* Variables from ReadSIH - wealth */

	AssUnincorpSp - AWE -
	AssAcctSp - AWE -
	AssDebSp - AWE -
	AssOffSp - AWE -
	AssOthFinSp - AWE -
	AssSharSp - AWE -
	AssPrivTrustSp - AWE -
	AssPubTrustSp - AWE -
	AssLoanValSp - AWE -
	AssSupNoIncSp - AWE -
	AssSupIncSp - AWE -
	AssSilPtnrSp - AWE -
	AssIncorpSp - AWE -
	HelpDebtp - CPI -

    /* Variables from VariableConstruct1 - current year */

    IncWageSWp - AWE -
    NetShareLossAp - CPI -
    IncMaintSFp - AWE -
    IncMaintSAp - AWE -
    MaintPaidSAp - AWE -
    IncSSSuperSFp - CPI -
    IncSSSuperSAp - CPI - 
    NonSSTotSFp - CPI - 
    IncSSTotSFp - CPI - 
    NonSSTotSAp - CPI - 
    IncSSTotSAp - CPI - 
    IncBusLExpSAp - AWE - 
    IncDivSAp - CPI - 
    IncRoyalSAp - CPI - 
    IncOthInvSAp - CPI - 
    IncNonHHSAp - CPI - 
    IncOthRegSAp - CPI - 
    IncOSPenSAp - CPI -
    IncWageSAp - AWE - 
    IncWageSFp - AWE - 
    IncIntFinSAp - CPI - 
    IncIntBondSAp - CPI - 
    IncIntLoanSAp - CPI - 
    IncTrustSAp - CPI - 
    IncPUTrustSAp - CPI - 
    IncAccSAp - AWE - 
    IncWCompSAp - AWE - 
    IncRentResSAp - CPI - 
    IncRentNResSAp - CPI - 
    IncSuperSAp - CPI - 
    TotSSNonSSWp - CPI -
    TotSSNonSSFBWp - CPI -
    IncBusLExpWp - AWE -
    IncBusLExpFp - AWE -
    IncBusAp - AWE -
    IncIntAp - CPI -
    IncIntWp - CPI -
    IncWCompAp - AWE -
    IncNetRentAp - CPI -
    IncNetRentWp - CPI -
    NetRentLossAp - CPI -
    NetInvLossAp - CPI -
    DedChildMaintAp - AWE -
    IncServiceAp - AWE -

    /* Variables from VariableConstruct1 - previous year */
	/* Previous year income proxied by current year income */
		
    IncIntPAp - CPILagged -
    IncWCompPAp - AWELagged -
    IncNetRentPAp - CPILagged -
    NetRentLossPAp - CPILagged -
    NetShareLossPAp - CPILagged -
    NetInvLossPAp - CPILagged - 

	/* Wealth variables (aggregated) from VariableConstruct1 */
	
	AssPropBusp - AWE -
	AssDeemedp - AWE -
	AssOtherp - AWE -
	AssTotp - AWE -
	AssTrustCompp - AWE -

    /* Variables which are being imputed - current year */

    FrankCrImpWp - CPI -
    FrankCrImpAp - CPI -
    FrankCrImpFp - CPI -
    DeductionFp - CPI -
    DeductionAp - CPI -
    DeductionWrkAp - CPI -

    /* Variables which are being imputed - previous year */
	/* Previous year income proxied by current year income*/
	

    FrankCrImpPAp - CPILagged -
    DeductionPAp - CPILagged - 

    ;

* Define a global macro variable 'UpratingMethodsHousehold' which lists variable names in the first column and 
the series to be used to uprate the variables in the second column, for the household level dataset ;

%LET UpratingMethodsHousehold = 

    RentPaidFh - CPI -
    RentPaidWh - CPI -

	/* Variables from ReadSIH - wealth */

	AssResiPropOthSh - AWE -
	AssNonResiPropSh - AWE -
	AssRentPropLoanSh - AWE -
	AssOthPropLoanSh - AWE -
	AssInvLoanSh - AWE -
	AssHomeContSh - AWE -
	AssVehicSh - AWE -
	AssNECSh - AWE -
	AssOthLoanSh - AWE -
	AssVehicLoanSh - AWE -

    ;

*******************************************************************************************************;
* Step 5: Define the uprating macro ('Uprate Command') to perform the uprating                         ;
*******************************************************************************************************;

*   Define a macro called 'UprateCommand' (similar to the 'KeepVar' and 'Rename' macros from ReadSIH)
    which writes the code undertaking multiplication of each of the variables by their uprating factors
    for the appropriate year to create the uprated variables, for the person and household datasets.
    The macro argument is 'UpratingList', which defines the list containing the variable names and their
    uprating factors ;

%MACRO UprateCommand( UpratingList ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &UpratingList ) ) ;

    i = 0 ;

    %DO i = 1 %TO &NumVars %BY 2 ;

        %* Get variable name ;
        %LET Variable = %SCAN( &UpratingList , &i , - ) ;

        %* Get uprating series ;
        %LET Series = %SCAN( &UpratingList , %EVAL( &i + 1 ) , - ) ;

          &Variable = &Variable * &Series ; 

    %END ;

    DROP i ;

%MEND UprateCommand ;



