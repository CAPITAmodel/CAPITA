************************************************************************************
* Name of program:       CameoInitialisation                                       *
* Description:           This program initialises the variables for the cameo.     *                               
************************************************************************************;

************************************************************************************
*   Step 1 - Define variables from CAPITA basefile that need to be initialised for *    
*            use in Cameo basefile                                                 *    
************************************************************************************;
* Specify suffix for variables to be initialised ;

%LET SuffixListAll = r - s - 1 - 2 - 3 - 4 ;

%LET SuffixListCouple = r - s ;

%LET SuffixListKids  = 1 - 2 - 3 - 4 ;

*Define variables for all family members that need to be initialised to zero ;
%LET VarListAll  =  AdjFbA -
                    AdjFbF -
                    AdjFbPA -
                    AbstudyW -
                    AustudySW -
                    DeductionA -
                    DeductionF -
                    DeductionPA -
                    DeductionWrkA -
                    DspSW -
                    FrankCrImpA -
                    FrankCrImpPA -
                    FrankCrImpW -
                    FtPtStatS -
                    HighestSYearS -
                    IncBusA -
                    IncBusLExpSA -
                    IncBusLExpSPA -
                    IncBusLExpSW -
                    IncBusLExpF -
                    IncBusLExpW -
                    IncDivSA -
                    IncDivSPA -
                    IncIntA -
                    IncMaintSF -
                    IncNetRentA -
                    IncOthInvSA -
                    IncOSPenSA -
                    IncOSPenSPA -
                    IncRoyalSA -
                    IncRoyalSPA -
                    IncServiceA -
                    IncTaxCompGovtSupImpA -
                    IncTaxCompPrivSupImpA -
                    TotSSNonSSW -
                    IncWageSA -
                    IncWageSF -
                    IncWageSW -
                    IncWageSPA -
                    NonSSCCSW -
                    NonSSSharesSW -
                    NonSSSuperSW -
                    NonSSTotSW -
                    RepFbA -
                    IncSSCCSW -
                    IncSSSuperSW -
                    IncSSTotSW -
                    StudyTypeS -
                    YARand -
                       ;    

    *Define variables for couple that need to be initialised to zero ;      
    %LET VarListCouple =    CarerAllSW -
                            CarerPaySW -
                            DedChildMaint -
                            DeductionWrkA -
                            DvaDisPenSW -
                            DvaSPenSW -
                            DvaWWPenSW -
                            IncAccCompSA -
                            IncAccCompSPA -
                            IncAccCompSW -
                            IncAgePenSPA -
                            IncBenTrustSA -
                            IncTrustSPA -
                            IncTrustSW -
                            IncDvaSPenSPA -
                            IncIntBondSA -
                            IncIntBondSPA -
                            IncIntBondSW -
                            IncIntFinSA -
                            IncIntFinSPA -
                            IncIntFinSW -
                            IncIntLoanSA -
                            IncIntLoanSPA -
                            IncIntLoanSW -
                            IncIntPA -
                            MaintPaidSA -
                            MaintPaidSPA -
                            IncMaintSA -
                            IncMaintSF -
                            IncMaintSPA -
                            IncMaintSW -
                            IncRentNResSA -
                            IncRentNResSPA -
                            IncRentNResSW -
                            IncNetRentPA -
                            IncRentResSA -
                            IncRentResSPA -
                            IncRentResSW -
                            NonSSTotSA -
                            NonSSTotSF -
                            IncNsaSPA -
                            IncOthInvSPA -
                            IncOthRegSA -
                            IncOthRegSPA -
                            IncOthRegSW -
                            IncPartAllSPA -
                            IncNonHHSA -
                            IncNonHHSPA -
                            IncNonHHSW -
                            IncNonTaxSuperImpA -
                            IncParSPA -
                            IncPUTrustSA -
                            IncPUTrustSPA -
                            IncPUTrustSW -
                            IncWCompSA -
                            IncWCompSPA -
                            IncWCompSW -
                            IncSickAllSPA -
                            IncSickSPA -
                            IncSpBSPA -
                            IncSSTotSA -
                            IncSSTotSF -
                            IncSSFlagS -
                            IncSSSuperSA -
                            IncSSSuperSF -
                            IncTaxSuperA -
                            IncTaxSuperImpA -
							IncTaxSuperImpPA -
                            IncTaxSuperPA -
                            IncWidAllSPA -
                            IncWCompA -
                            IncWCompPA -
                            IncYaSPA -
                            NetInvLossA -
                            NetInvLossPA -
                            NetRentLossA -
                            NetShareLossA -
                            NetShareLossPA -
                            NumCareDeps -
							ParPaySW -
                            PartAllSW -
                            RAssSW -
                            RepEmpSupContA -
							RepFbPA -
                            RepSupContA -
                            RepSupContPA -
                            SickAllSW -
                            SpbSW -
						    SuperAcBal - 
                            WidAllSW -         
                            WifePenSW -
                            YearOfArrival - /*assume born in Australia*/
							/*IncTaxSuperImpPA */
							TotSSNonSSA -
							TotSSNonSSF -
							PPLSW -
							DaPPSW -
							AssDeemed - /*added to prevent note */
							AssTot -
							RandAgeEsGfth - 
					
                                ; 

*Define variables for kids that need to be initialised to zero ;
%LET VarListKids =          WrkForceIndep -
							YouthAllSW -
							NsaSW -
                            /* For childcare module */
                            ChildAge -
		                    ;       
                    

*Define variables for all family members that need to be initialised to 1 ;
/*%LET VarUnivAll =   YouthAllSW -*/
/*                    NsaSW ;   */
                    
*Define variables for couple that need to be initialised to 1 ; 
%LET VarUnivCouple =    AgePenSW - 
                        NsaSW -
						YouthAllSW -
                        WrkForceIndep -
                        WrkForceExp ;  

*Define other variables for all family members that need to be initialised to 
 non-zero number ;  
%LET VarPrivHlthIns =  PrivHlthIns ;

* Define character variables that need to be initialised for all family members ;
%LET CharListAll = FamPos -
                    ;

************************************************************************************
*                   Step 2 - Define macros for initialising variables              *                                         *  
*                                                                                  *
************************************************************************************;
************************************************************************************
* Macro:   InitNumZero                                                             *
* Purpose: Initialise numeric variables to zero                                    *
* Inputs:  VarList  - name of the variable list containing the numeric variables   *
*          SuffixList  - name of the variable list containing the suffixes         *
************************************************************************************;

%MACRO InitNumZero( VarList , SuffixList ) ;

    %LET NumVar = %SYSFUNC( COUNTW( &VarList ) ) ;

    %LET NumSuff = %SYSFUNC( COUNTW( &SuffixList ) ) ;

    %DO i = 1 %TO &NumVar ;

        %* Get variable that needs to be initialised to zero ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

            %DO j = 1 %TO &NumSuff ;

                %* Get suffix of variable that needs to be initialised to zero ;
                %LET Suffix = %SCAN( &SuffixList , &j , - ) ;

                %* Set variable to zero ;
                &Variable.&Suffix = 0 ;

            %END ;

    %END ;

%MEND InitNumZero ;
************************************************************************************
* Macro:   InitNumOther                                                            *
* Purpose: Initialise numeric variables to 1 (this assumes everyone receives       *
*          universal pension)                                                      *
* Inputs:  VarList  - name of the variable list containing the numeric variables   *
*          SuffixList  - name of the variable list containing the suffixes         *
************************************************************************************;
%MACRO InitNumOther( VarList , SuffixList, InitValue ) ;

    %LET NumVar = %SYSFUNC( COUNTW( &VarList ) ) ;

    %LET NumSuff = %SYSFUNC( COUNTW( &SuffixList ) ) ;

    %DO i = 1 %TO &NumVar ;

        %* Get variable that needs to be initialised to zero ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

            %DO j = 1 %TO &NumSuff ;

                %* Get suffix of variable that needs to be initialised to 1 ;
                %LET Suffix = %SCAN( &SuffixList , &j , - ) ;

                %* Set variable to 1 ;
                &Variable.&Suffix = 1 ;

            %END ;

    %END ;

%MEND InitNumOther ;

************************************************************************************
* Macro:   InitCharVar                                                          *
* Purpose: Initialise character variables                                          *
* Inputs:  VarList  - name of the variable list containing the character variables *
*          SuffixList  - name of the variable list containing the suffixes         *
************************************************************************************;
%MACRO InitCharVar( VarList , SuffixList ) ;

    %LET NumVar = %SYSFUNC( COUNTW( &VarList ) ) ;

    %LET NumSuff = %SYSFUNC( COUNTW( &SuffixList ) ) ;

    %DO i = 1 %TO &NumVar ;

        * Get variable that needs to be initialised ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

            %DO j = 1 %TO &NumSuff ;

                * Get suffix of variable ;
                %LET Suffix = %SCAN( &SuffixList , &j , - ) ;

                * Set variable at a length of 15 characters. This creates a blank 
                   variable with 15 character spaces ;
                LENGTH &Variable&Suffix $15 ;

                &Variable&Suffix = "" ;

            %END ;

    %END ;

%MEND InitCharVar ;

************************************************************************************
* Macro:   InitKids                                                                *
* Purpose: Initialise kids0 to kids14                                              *
************************************************************************************;
%MACRO InitKids() ;

    %DO i = 0 %TO 14 ;

        Kids&i.Su = 0 ;

    %END ;

    AgeYoungDepu = 0 ;

    TotalKidsu = 0 ;

%MEND InitKids;
************************************************************************************
* Macro:   InitDurUnemp                                                            *
* Purpose: Initialise Duration of unemployment to 13-25 weeks which is middle of   *
*          range                                                                   *
************************************************************************************;
%MACRO InitDurUnemp ;

    DurUnempTyper = '13To25Wk' ;

    DurUnempTypes = '13To25Wk' ;

    %DO i = 1 %TO 4 ;

       DurUnempType&i = '13To25Wk' ;

    %END ;

%MEND InitDurUnemp;
************************************************************************************
*                               Step 3 - Initialise variables                      *                         
*                                                                                  *
************************************************************************************;
%InitKids()

%InitNumZero (&VarListAll , &SuffixListAll ) 
/**/
%InitNumZero (&VarListCouple , &SuffixListCouple ) 

%InitNumZero (&VarListKids , &SuffixListKids ) 
/**/
/*/*Assume everyone receives universal pensions / allowances on the Sih to remove */
/*receipt on Sih condition */
/*%InitNumOther (&VarUnivAll , &SuffixListAll, 1 ) */
%InitNumOther (&VarUnivCouple , &SuffixListCouple, 1 ) 
/**/
%InitCharVar (&CharListAll , &SuffixListAll )

/* Previous year income data derived from other sources not required if assuming all 
    income is from wages and salaries.  */
DataScopeTyper = "PrevYrNA" ;
DataScopeTypes = "PrevYrNA" ;

*Duration of unemployment. Set to 3 = 13-25 weeks, which is middle of the range.;
%InitDurUnemp

RentPaidFh = 0 ;

Occupancyu = 1 ; * 1 = owneroccupied housing, used in pension assets test ;

SihQh = 1 ;

* Used in DVA module but not modelled in Cameo ;
SharerFlagu = 0 ;

* Family toggles for grandfathering of FTB ES ;

RandFtbaEsGfthr = 0 ;

RandFtbbEsGfthr = 0 ;

* Family toggles for grandfathering of CSHC ES ; *EAH: Added variables to initialise ;

RandCSHCEsGfthr = 0 ;

RandCSHCEsGfths = 0 ;

* Variable for number of children under 6 ; 
KidsU6u = 0 ; 
