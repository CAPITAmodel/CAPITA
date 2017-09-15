
**************************************************************************************
* Program:      ReadSIH.sas                                                          *
* Description:  Reads in variables from the SIH CURF datasets which are required for *
*               use in the CAPITA basefile and policy modules.                       *                                                            
**************************************************************************************;

* Define macro 'CallSih' which reads in the raw SIH data. The two macro arguments are:
  'InDataset'  - This is the name of the raw SIH dataset to be read in
  'OutDataset' - This is the name of the SAS dataset which will be created ;

%MACRO CallSih( InDataset , OutDataset ) ;

    DATA work.&OutDataset ;

        SET library.&InDataset ;

        FORMAT _ALL_ ;

    RUN ;

%MEND ;

* Read in SIH Person level dataset ;
%CallSih( sih13bp , SIHperson )

* Read in SIH Income unit level dataset ;
%CallSih( sih13bi , SIHincome )

* Read in SIH Household level dataset ;
%CallSih( sih13bh , SIHhousehold )

* Make any required adjustments to the SIH datasets ;
%INCLUDE BaseMods(AdjustSIH) ;

**************************************************************************************************
*   Step 2 - Create list of old and new variable names from the person level dataset             *                                    
**************************************************************************************************;

*   Define global macro variable 'PersonVarList' to be used later to specify which variables to keep
    and to create rename lists ;

%LET PersonVarListSuff = 

    /* Identifier variables */

    abspid - SihPIDp -
    sihpswt - PersonWeightSp -
    iutypep - IUTypeSp -
    iupos - IUPosSp -
    relathcf - RelationHHSp -
    yoabc - YearOfArrivalSp -
    finscope - FinScopeSp -
           
    /* Demographic variables */

    agebc - AgeSp -
    sexp - SexSp -
    durunbc - DurUnempSp -
    lfscp - LfStatSp -
    ftptstat - FtPtStatSp -
    studstcp - StudyTypeSp -
    edinbc - EducInstSp -
    secedql - HighestSYearSp -
    hrswkabc - HrsPerWkSp -

    /* Private Income variables - Previous Year (Annual) */

    iobtpp - IncBusLExpSPAp - 
    iwstpp8 - IncTotEmpIncSPAp -
    infinpp - IncIntFinSPAp - 
    indebpp - IncIntBondSPAp - 
    inplnpp - IncIntLoanSPAp - 
    pfyitrus - IncTrustSPAp - 
    inputpp - IncPUTrustSPAp - 
    idivtpp - IncDivSPAp - 
    iroyalpp - IncRoyalSPAp - 
    iinvotpp - IncOthInvSPAp - 
    pfyifam - IncNonHHSPAp - 
    ioregupp - IncOthRegSPAp - 
    ioseaspp - IncOSPenSPAp - 
    iacsipp - IncAccSPAp - 
    irwcpp - IncWCompSPAp - 
    irntrpp - IncRentResSPAp - 
    irntcpp - IncRentNResSPAp - 
    iwstpp - IncWageSPAp - 
    ichldspp - IncMaintSPAp - 
    pfypcs - MaintPaidSPAp - 
    linvpp - DedIntSharesSPAp -

    /* Private Income variables - Current Year (Weekly) */

    iobtcp - IncBusLExpSWp -
    iwssucp8 - IncEmpTotSWp -               
    infinrcp - IncIntFinSWp - 
    indebrcp - IncIntBondSWp - 
    inplnrcp - IncIntLoanSWp - 
    cwibtr - IncTrustSWp - 
    inputcp - IncPUTrustSWp - 
    idivtrcp - IncDivSWp - 
    iroyarcp - IncRoyalSWp - 
    iinvorcp - IncOthInvSWp - 
    cwifnih -  IncNonHHSWp - 
    ioregucp - IncOthRegSWp - 
    ioseascp - IncOSPenSWp - 
    iacsicp - IncAccSWp - 
    irwccp - IncWCompSWp - 
    irntrrcp - IncRentResSWp - 
    irntcrcp - IncRentNResSWp - 
    ichldscp - IncMaintSWp -
    cwkncbe - NonSSTotSWp -
    inscccp - NonSSCCSWp - 
    insshcp - NonSSSharesSWp - 
    insscp - NonSSSuperSWp -
    cwksscp - IncSSTotSWp -
    isscccp - IncSSCCSWp -
    issscp - IncSSSuperSWp -
    wssricp - IncSSFlagSp -
    ksuppcp - MaintPaidSWp -
    linvcp - DedIntSharesSWp -
    isupercp - IncSuperSWp -

    /* Transfer Income variables - Previous Year (Annual) */

    iagepp - IncAgePenSPAp - 
    inewstpp - IncNSASPAp - 
    iservpp - IncDvaSPenSPAp - 
    iparenpp - IncParSPAp - 
    isickpp - IncSickAllSPAp - 
    iwidowpp - IncWidAllSPAp - 
    ispecpp - IncSpBSPAp - 
    ipartnpp - IncPartAllSPAp - 
    iyouthpp - IncYASPAp - 

    /* Transfer Income variables - Current Year (Weekly) */       

    iagecp - AgePenSWp -
    inewlscp - NsaSWp -
    iservcp - DvaSPenSWp -
    idisbcp - DvaDisPenSWp -
    iwarwcp - DvaWWPenSWp -
    iparencp - ParPaySWp - 
    isickcp - SickAllSWp -
    iwidowcp - WidAllSWp -
    ispeccp - SpBSWp - 
    iaustcp - AustudySWp -
    iwifecp - WifePenSWp -
    icarepcp - CarerPaySWp -
    icareacp - CarerAllSWp -
    idsuppcp - DspSWp -    
    ipartncp - PartAllSWp -
    iyouthcp - YouthAllSWp -
    ipplcp - PPLSWp -
    idpplcp - DaPPSWp -
    cwkcra - RAssSWp -

	/* Wealth variables */

	vfincp - AssAcctSp -
	vdebcp - AssDebSp -
	voftcp - AssOffSp -
	vinvotcp - AssOthFinSp -
	vsharcp - AssSharSp -
	vprtcp - AssPrivTrustSp -
	vputtcp - AssPubTrustSp -
	vplncp - AssLoanValSp -
	supbalnp - AssSupNoIncSp -
	vubuscp - AssUnincorpSp -
	vsipcp - AssSilPtnrSp -
	vibuscp - AssIncorpSp -
	supbalp - AssSupIncSp -

    /* Other variables for the policy modules */

    cfyphhc - PrivHlthInsp -
    vsupgcp - GovSuperAcBalp -
    vsupncp - PrivSuperAcBalp -

    ;


%LET PersonVarListNoSuff = 

    /* Identifier variables */

    abshid - SihHID -
    absfid - SihFID -
    absiid - SihIUID -

    ;

**************************************************************************************************
*   Step 3 - Create list of old and new variable names from the income unit level dataset        *                                    
*                                                                                                *
**************************************************************************************************;

*   Define global macro variable 'IncomeVarList' to be used later to specify which variables to keep
    and to create rename lists ;

%LET IncomeVarListSuff = 

    /* Identifier variables*/

    iutype - IUTypeSu -
    sihiuwt - IUWeightSu -

    /* Demographic variables */

    tenrepcf - TenureSu -
    lndldiuc - LandlordSu -
    a1564ubc - Adults15to64Su -
    a6599ucf - Adults65to99Su -
    kid0t2bc - Kids0to2Su -
    kid3t4bc - Kids3to4Su -
    kid5t9bc - Kids5to9Su -
    kd1014bc - Kids10to14Su -
    kid1524b - Kids15to24Su -
    prsnsubc - PersonsInIUSu -

    /* Income variables */

    wklyccbu - CCBSWu -
    wklyccru - CCRSWu - 

    ;

%LET IncomeVarListNoSuff = 

    /* Identifier variables*/

    abshid - SihHID -
    absfid - SihFID -
    absiid - SihIUID -

    ;


**************************************************************************************************
*   Step 4 - Create list of old and new variable names from the household level dataset          *
*                                                                                                *
**************************************************************************************************;

*   Define global macro variable 'HHVarList' to be used later to specify which variables to keep
    and to create rename lists ;

%LET HHVarListSuff = 

    /* Identifier variables */
   
    quarterh - SihQh -
    famlycom - FamilyComph -
    sihhhwt - HHWeightSh -
    statehbc - StateSh - 

    /* Demographic variables */

    wkrentch - RentPaidWh -
	nomemhbc - PersonsInHHh -

	/* Wealth variables */
	
	liainvch - AssInvLoanSh -
	vrprch - AssResiPropOthSh -
	vnrprch - AssNonResiPropSh -
	liarpch - AssRentPropLoanSh -
	liaopch - AssOthPropLoanSh -
	vcontch - AssHomeContSh -
	vvehich - AssVehicSh -
	votassch - AssNECSh -
	liaotch - AssOthLoanSh -
	liavech - AssVehicLoanSh -

    ;


%LET HHVarListNoSuff = 

    /* Identifier variables */

    abshid - SihHID -

    ;


**************************************************************************************************
*   Step 5 - Call the 'KeepVar' macro from the Basefile Macros module to create lists of         *
*   old variable names                                                                           *
**************************************************************************************************;

%LET PersonSihNames = %KeepVar( &PersonVarListSuff , 2 ) %KeepVar( &PersonVarListNoSuff , 2 ) ;

%LET IncomeSihNames = %KeepVar( &IncomeVarListSuff , 2 ) %KeepVar( &IncomeVarListNoSuff , 2 ) ;

%LET HHSihNames = %KeepVar( &HHVarListSuff , 2 ) %KeepVar( &HHVarListNoSuff , 2 ) ;


**************************************************************************************************
*   Step 6 - Form the initial datasets using the 'Rename' macro from the Basefile Macros module  *
**************************************************************************************************;

DATA Person&SurveyYear ;

    SET SihPerson (KEEP = &PersonSihNames);

        %LET RenameList1 = %Rename( &PersonVarListSuff , 1 , 2 ) ;

        %LET RenameList2 = %Rename( &PersonVarListNoSuff , 1 , 2 ) ;
        
        RENAME &RenameList1 &RenameList2 ;

RUN ;

DATA Income&SurveyYear ;

    SET SihIncome (KEEP = &IncomeSihNames);

        %LET RenameList1 = %Rename( &IncomeVarListSuff , 1 , 2 ) ;

        %LET RenameList2 = %Rename( &IncomeVarListNoSuff , 1 , 2 ) ;
        
        RENAME &RenameList1 &RenameList2 ;
 
RUN ;

DATA Household&SurveyYear ;

    SET SihHousehold (KEEP = &HHSihNames);

        %LET RenameList1 = %Rename( &HHVarListSuff , 1 , 2 ) ;

        %LET RenameList2 = %Rename( &HHVarListNoSuff , 1 , 2 ) ;
        
        RENAME &RenameList1 &RenameList2 ;
 
RUN ;

