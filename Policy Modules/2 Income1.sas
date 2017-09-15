
**************************************************************************************
* Program:      2 Income1.sas                                                        *
* Description:  Constructs various income definitions for use in the policy modules. *
*               Some income definitions require more information about transfer      *
*               policy outcomes before they can be constructed, hence such           *
*               definitions are contained in the Income2 module.                     *
**************************************************************************************;


***********************************************************************************
*   Macro:   RunIncome1                                                           *
*   Purpose: Coordinate income calculation                                        *
*                                                                                 *
**********************************************************************************;;

%MACRO RunIncome1 ;

    ***********************************************************************************
    *      1.        Calculate Private Income (Current)                               *
    *                                                                                 *
    **********************************************************************************;

    * Calculate private income current year ;

    %PrivIncome( r )

    IF Coupleu = 1 THEN DO ;

        %PrivIncome( s ) 

    END ;

    ***********************************************************************************
    *      2.        Calculate Ordinary Income and Assets for pension and allowance   *
    *                                                                                 *
    **********************************************************************************;

    * Calculate ordinary income for DSS and DVA Pension purposes ;
    * Nested Macro %WorkIncome used to calculate work income less Work Bonus ;
    * Nested Macro %OrdIncome used to calculate Ordinary Income ;

    %IncomeTest

	* Calculate assets for the pension assets test ;

	%AssetsTest
    
    ***********************************************************************************
    *      3.        Calculate Taxable Income (previous year) and combined parental   *
    *                income                                                           *
    *                                                                                 *
    **********************************************************************************;

    * Calculate previous year taxable income for parental income purposes ;

    %TaxIncPrevYr( r )

    IF Coupleu = 1 THEN DO ;

        %TaxIncPrevYr( s ) 

    END ;

    * Calculate combined parental income for Youth Allowance purposes ;

    %ParenIncTestAll

    * Calculate maintenance income for Maintenance income test. This amount is recorded against 
      the parental income unit. It is retained for own income unit calculations ;

    IncMaintAu = SUM ( IncMaintSFr , IncMaintSFs ) * 26 ;

    RETAIN IncMaintAu_ ;

    IF FIRST.FamID = 1 THEN IncMaintAu_ = IncMaintAu ;

    ***********************************************************************************
    *      4.        Calculate income definitions for dependants                      *
    *                                                                                 *
    **********************************************************************************;

    %DO i = 1 %TO 4 ;

        IF ActualAge&i > 0 THEN DO ; 

            %PrivIncome( &i )

            %OrdIncome( &i )            /* Run for dependants 1 to 4. This is used in Dependants1 and Allowance modules */

        END ;

    %END ;

%MEND RunIncome1 ;

**********************************************************************************
*   Macro:   PrivIncome                                                          *
*   Purpose: Calculates private income for each individual                       *
*********************************************************************************;; 

%MACRO PrivIncome( psn ) ;

    * Taxable private income ;
                      /* Income from wages, salaries and own unincorporated business */
    IncTaxPrivA&psn = IncWageSA&psn                     /* Total usual income from wages/salary of main and second job */
                    + IncBusLExpSA&psn                  /* Cash income from own unincorporated business. */

                      /* Income from super and annuities */                    
                    %IF &psn IN ( r , s , r_ ) %THEN
                    + IncTaxSuperImpA&psn ;             /* Annual income from taxable superannuation benefits. */

                      /* Investment income and dividends */
                    + IncIntA&psn                       /* Total current annual income from interest payments */
                    + IncDivSA&psn                      /* Reported annual income from dividends (incl. franking credits). */
                    + IncOthInvSA&psn                   /* Reported annual income from other financial investments. */
                    + IncRoyalSA&psn                    /* Reported annual income from royalties. */

                      /* Other non-government income */
                    %IF &psn IN ( r , s , r_ ) %THEN
                    + IncWCompA&psn ;                	/* Annual income from Workers compensation. */
                    %IF &psn IN ( r , s , r_ ) %THEN
                    + IncNonHHSA&psn ;                  /* Annual income from family members not living in the household. */
                    + IncOSPenSA&psn                    /* Annual income from overseas pensions and benefits. */
                    %IF &psn IN ( r , s , r_ ) %THEN
                    + IncOthRegSA&psn ;                 /* Annual income from other regular sources. */

                      /* Net rent for owner occupied dwellings and subsidised private rentals */
                    + IncNetRentA&psn ;                 /* Annual net rent income from rental property */
                      

    * Non-taxable private income ;
    IncNonTaxPrivA&psn = %IF &psn IN ( r , s , r_ ) %THEN %DO ;
                            TotSSNonSSA&psn             /* Total non cash benefits from employer */
                          + IncMaintSA&psn              /* Annual income received from child support/maintenance. */
                          + IncNonTaxSuperImpA&psn ;    /* Annual income from non-taxable superannuation benefit */
                         %END ;
                         %ELSE 0 ; ;

    * Private income ;
    IncPrivA&psn = IncTaxPrivA&psn                      /* Taxable component of private income */
                 + IncNonTaxPrivA&psn ;                 /* Non-taxable components of private income */
                     
    IncPrivF&psn = IncPrivA&psn / 26 ;

%MEND PrivIncome ;

**********************************************************************************
*   Macro:   DeemIncome                                                          *
*   Purpose: Calculates adjusted deemed income for the pension income test       *
*********************************************************************************;;

%MACRO DeemIncome ;

	* Calculate income deeming threshold, value of assets to which deeming applies and actual financial investment income ;

 	IF Coupleu = 0 THEN DO ;

		DeemedThr = PenDeemThrS ;
		AssessDeemedVal = AssDeemedr ;
		IncFinInvA = IncIntAr + IncDivSAr + IncOthInvSAr ;

	END ;

	ELSE IF Coupleu = 1 THEN DO ;

		DeemedThr = PenDeemThrPenC ;
		AssessDeemedVal = AssDeemedr + AssDeemeds ;
		IncFinInvA = IncIntAr + IncDivSAr + IncOthInvSAr + IncIntAs + IncDivSAs + IncOthInvSAs ;

	END ;

	* Calculate deemed income based on value of financial assets, deeming threshold and deeming rates ;

	IF AssessDeemedVal <= 0 THEN DeemedIncA = 0 ;
	ELSE IF AssessDeemedVal <= DeemedThr THEN DeemedIncA = AssessDeemedVal*PenDeemRateLwr ;
	ELSE IF AssessDeemedVal > DeemedThr THEN DeemedIncA = DeemedThr*PenDeemRateLwr + (AssessDeemedVal - DeemedThr)*PenDeemRateUpr ;

	* Calculate the income adjustment required for deeming - add deemed income and subtract actual financial investment income ;

	DeemedCalcA = DeemedIncA - IncFinInvA ;
	DeemedCalcF = DeemedCalcA / 26 ;

%MEND DeemIncome ;


**********************************************************************************
*   Macro:   WorkIncome                                                          *
*   Purpose: Calculates pensioner work bonus and work income after work bonus.   *
*            Work bonus is not calculated for allowees.                          *
*********************************************************************************;;

%MACRO WorkIncome( psn ) ;

    * Certain pensioners get Work Bonus adjustment ;

    IF ( ParPaySW&psn = 0 OR ParPaySW&psn > 0 AND Coupleu = 1 )        /* Not eligible for PPS */
    AND ( ( Sex&psn = 'F' AND ActualAge&psn >= FemaleAgePenAge ) 
       OR ( Sex&psn = 'M' AND ActualAge&psn >= MaleAgePenAge ) )                         
    OR ( DvaSPenSW&psn > 0 AND ActualAge&psn >= DVAPenAge )        /* Eligible for DVA Pension */
    THEN DO ;

        * work bonus eligible income is wage, salary and business income up to work bonus amount ;
        IncWBF&psn = IncWageSF&psn + IncBusLExpF&psn + TotSSNonSSF&psn ;          

        * Apply Work Bonus ceiling ;
        IncWBF&psn = MIN( IncWBF&psn , WorkBonF ) ;

        * Calculate work income less Work Bonus ;
        IncPrivLessWBF&psn = MAX( 0 , IncPrivF&psn - IncWBF&psn ) ;

    END;

    * Others, including allowees do not get Work Bonus adjustment ;

    ELSE DO ;

        IncWBF&psn = 0 ;

        IncPrivLessWBF&psn = IncPrivF&psn ;

    END ;

%MEND WorkIncome ;

**********************************************************************************
*   Macro:   OrdIncome                                                           *
*   Purpose: Calculates Ordinary income for each individual. This is used for    *
*            the DVA, Pension and Allowance modules. This MACRO is called later  *
*            in the DVA module and Pension module when required.                 *
*********************************************************************************;;

%MACRO OrdIncome( psn ) ;

    /* Ordinary income calculation for reference or spouse */
    %IF &psn IN ( r , s , r_ ) %THEN %DO ;
                                                
        IncOrdDvaF&psn = IncPrivLessWBF&psn        /* Work income less Work Bonus */
                       - IncMaintSF&psn            /* Maintenance income */
                       + IncSSTotSF&psn            /* Include salary sacrificed amounts (into super or fringe benefit), and non salary sacrificed amounts. */ 
                       + NonSSTotSF&psn            /* Fringe benefit included is the non-grossed up amount, reported or not. */ 

                    /* 2015-16 MYEFO measure to include PLP and DaPP in ordinary income definition from 1 October 2016 
					Structural policy change so reflect at 1 July 2016 for annual runs */
					/* Passed in Budget Savings (Omnibus) Bill 2016*/
					%IF ( &Duration = A AND &Year > 2015 ) 
					OR ( &Duration = Q AND &Year > 2016 ) 
					OR ( &Duration = Q AND &Year = 2016 AND &Quarter = Dec ) 
					%THEN %DO ; 
                    + ( PPLSW&psn * 2 )            /* Parental Leave Pay */
                    + ( DaPPSW&psn * 2 )           /* Dad and Partner Pay */
                    %END ;

                    ;
 
        IncOrdF&psn = IncPrivLessWBF&psn           /* Work income less Work Bonus */
                    - IncMaintSF&psn               /* Maintenance income */
                    + IncSSTotSF&psn               /* Include salary sacrificed amounts (into super or fringe benefit), and non salary sacrificed amounts. */
                    + NonSSTotSF&psn               /* Fringe benefit included is the non-grossed up amount, reported or not. */
 
                    /* DVA payments */
                    + ( DvaDisPenSW&psn * 2 )      /* DVA Disability Pension */
                    + ( DvaWwPenSW&psn * 2 )       /* DVA War Widow Pension */

                    /* 2015-16 MYEFO measure to include PLP and DaPP in ordinary income definition from 1 October 2016 
					Structural policy change so reflect at 1 July 2016 for annual runs */
					/* Passed in Budget Savings (Omnibus) Bill 2016*/
					%IF ( &Duration = A AND &Year > 2015 ) 
					OR ( &Duration = Q AND &Year > 2016 ) 
					OR ( &Duration = Q AND &Year = 2016 AND &Quarter = Dec ) 
					%THEN %DO ; 
                    + ( PPLSW&psn * 2 )            /* Parental Leave Pay */
                    + ( DaPPSW&psn * 2 )           /* Dad and Partner Pay */
                    %END ;

                    ;

    %END ;  

    /* Ordinary income calculation for students 1 to 4. This is because the components
    of ordinary income, except for private income are unknown for students 1 to 4 */
    %ELSE %IF &psn IN( 1 , 2 , 3 , 4 ) %THEN %DO ;

        IncOrdF&psn = IncPrivF&psn ;

    %END ;
     
    * Annualise Ordinary Income ;
    IncOrdA&psn = IncOrdF&psn * 26 ;

    /* Note DVA service pension is NOT counted as ordinary income - this is because  
    the DVA service pension of a partner is not counted as ordinary income, and 
    if a person receives DVA service pension they cannot receive any other social 
    security payment (and hence the ordinary income definition is moot) */

%MEND OrdIncome ;

**********************************************************************************
*   Macro:   IncomeTest                                                          *
*   Purpose: Calculates income for pension purposes                              *
*********************************************************************************;;

%MACRO IncomeTest ;

    * Calculate Work Bonus ;
    %WorkIncome( r )

    * Calculate individual income ; 
    %OrdIncome( r )

    * Only calculate Work Bonus for person s in couples ;
    IF Coupleu = 1 THEN DO ;   

        %WorkIncome( s ) 

        %OrdIncome( s ) 

    END ;
	
	* Calculate adjustment to income necessary to apply deeming to the pension income test ;
	%DeemIncome

    IF Coupleu = 0 THEN DO ;

        * Calculate income for DVA income test ;
        * If person is in a couple then receive half the couples combined income for pension income test (Subsec 1064-E2 of the SSA 1991) ;
        IncDvaTestF = IncOrdDvaFr ;

        * Calculate income for Pension income test ;
        * If person is in a couple then receive half the couples combined income for pension income test (Subsec 1064-E2 of the SSA 1991) ;
        IncPenTestF = IncOrdFr ;

		* Calculate income for DVA and Pension income test (adjusted for deeming) ;
		IncDeemDvaTestF = MAX(0, IncDvaTestF + DeemedCalcF) ;
		IncDeemPenTestF = MAX(0, IncPenTestF + DeemedCalcF) ;

        * Calculate income for Allowance income test ; 
        IncAllTestFr = IncOrdFr ; 

    END ;

    IF Coupleu = 1 THEN DO ;

        * Calculate income for DVA income test ;
        * If person is in a couple then receive half the couples combined income for pension income test (Subsec 1064-E2 of the SSA 1991) ;
        IncDvaTestF = ( IncOrdDvaFr + IncOrdDvaFs ) / 2 ;

        * Calculate income for Pension income test ;
        * If person is in a couple then receive half the couples combined income for pension income test (Subsec 1064-E2 of the SSA 1991) ;
        IncPenTestF = ( IncOrdFr + IncOrdFs ) / 2 ;

		* Calculate income for DVA and pension income test (adjusted for deeming) ;
		IncDeemDvaTestF = MAX(0, IncDvaTestF + DeemedCalcF/2) ;
		IncDeemPenTestF = MAX(0, IncPenTestF + DeemedCalcF/2) ;

        * Calculate income for Allowance income test. This amount may be halved if the partner is receiving pensions and is calculated in Allowance module ; 
        IncAllTestFr = IncOrdFr ; 
        IncAllTestFs = IncOrdFs ; 

    END ;

    * Note DVA service pension is NOT counted as ordinary income - this is because the 
      DVA service pension of a partner is not counted as ordinary income, and if a 
      person receives DVA service pension they cannot receive any other social 
      security payment (and hence the ordinary income definition is moot);

%MEND IncomeTest ;

*********************************************************************************************
*   Macro:   TaxIncPrevYr                                                                   *
*   Purpose: Calculates taxable income for the previous financial year for each individual. *
*            This is used for parental income purposes.                                     *
********************************************************************************************;;

%MACRO TaxIncPrevYr( psn ) ;

    * Calculate previous year taxable income. This is used for parental income for Youth Allowance purposes ;

    IF DataScopeType&psn = "PrevYrAvail" THEN DO ;    

                       /* Taxable previous year private income */
        TaxIncPA&psn = IncWageSPA&psn              /* Previous financial year income from employee from all jobs */
                     + IncBusLExpSPA&psn           /* Previous financial year income from own unincorporated business. */
                     + IncIntPA&psn                /* Previous financial year income from interest payments */
                     + IncDivSPA&psn               /* Previous financial year income from dividends. */
                     + FrankCrImpPA&psn            /* Previous financial year dividend franking credit. */
                     + IncNetRentPA&psn            /* Previous financial year income from rental property */
                     + IncRoyalSPA&psn             /* Previous financial year income from royalties. */
                     + IncOthInvSPA&psn            /* Previous financial year income from other financial investments. */
                     + IncTaxSuperImpPA&psn        /* Previous financial year income form supperannuation/annuity/private pension. */
                     + IncWCompPA&psn              /* Previous financial year income from Workers compensation. */
                     + IncNonHHSPA&psn             /* Previous financial year income from family members not living in the household. */
                     + IncOthRegSPA&psn            /* Previous financial year income from other regular sources. */
                     + IncOSPenSPA&psn             /* Previous financial year income from overseas pensions and benefits. */

                       /* Taxable previous year transfer income */
                     + IncNsaSPA&psn               /* Previous financial year income from Newstart Allowance. */
                     + IncDvaSPenSPA&psn           /* Previous financial year income from Service Pension (DVA). */
                     + IncParSPA&psn               /* Previous financial year income from parenting payment. */
                     + IncSickAllSPA&psn           /* Previous financial year income from sickness allowance. */
                     + IncWidAllSPA&psn            /* Previous financial year income from Widow allowance. */
                     + IncSpBSPA&psn               /* Previous financial year income from Special benedit. */
                     + IncPartAllSPA&psn           /* Previous financial year income from partner allowance. */
                     + IncYaSPA&psn                /* Previous financial year income from youth allowance. */
                     + IncAgePenSPA&psn            /* Previous financial year income from Age Pension. */

                     /* Previous year tax deductions (use current year imputation as proxy) */
                     - DeductionPA&psn ;

        * Only positive amount of previous year parental taxable income is used. Taxable loss is not included ;
        TaxIncPA&psn = TaxIncPA&psn * ( TaxIncPA&psn > 0 ) ;
 
    END ;  

    ELSE TaxIncPA&psn = IncPrivA&psn ;             /* Using current year private income as a proxy if data is not available */

%MEND TaxIncPrevYr ;

*******************************************************************************************
*   Macro:   ParenIncTestAll                                                              *
*   Purpose: Calculate the combined parental income for Youth Allowance purposes.         *
*            Consists of previous year taxable and non-taxable incomes.                   *
******************************************************************************************;;

%MACRO ParenIncTestAll ;

    * Determine parents combined income for Youth Allowance Parental Income Test.
      The value of parental income used in the test is previous year taxable 
      income with this years maintenance income removed and this years fringe
      benefits included as previous years information is not available. ;

    * Only calculate for those who MAY be dependants. Will still calculate for single grandparents in same family. ;
    IF ActualAge1 > 0                   /* Dependants in parental income unit */
    OR FIRST.FamID AND NumIUu > 1       /* Dependants in own income units */
    THEN DO ;

        IF Coupleu = 0 THEN DO ;

                              /* Reference income */
            AllPareTestIncA = TaxIncPAr                 /* Previous year taxable income of reference */
                            %IF &Year > 2016 %THEN %DO ;
                            + RepFbPAr                  /* 2015-16 MYEFO - Previous year reportable fringe benefit of reference (proxied by current year)
														   to be included in the parental income test from 1 January 2017 */
                            %END ;
                            %ELSE %DO ;
                            + AdjFbPAr                  /* Previous year adjusted fringe benefit of reference (proxied by current year) */
                            %END ;
                            + NetInvLossPAr             /* Previous year Net Investment Loss of reference */  
                            + RepSupContPAr             /* Previous year Reportable Superannuation Contributions of reference (proxied by current year) */
                            + IncMaintSPAr              /* Previous year maintenance income received by the reference */
                            - MaintPaidSPAr             /* Previous year maintenance income paid by the reference*/
                            
                            /* 2015-16 Budget - from 1 January 2016, parental income will not be increased by any maintenance received by the parent.
                               However parental income will continue to be reduced by any maintenance paid by the parent */
                                %IF &Year >= 2016 %THEN %DO ;
                                    - IncMaintSPAr              /* Previous year maintenance income received by the reference */
                                %END ;  
                            ;

        END ;

        ELSE IF Coupleu = 1 THEN DO ;

                              /* Reference income */
            AllPareTestIncA = TaxIncPAr                 /* Previous year taxable income of reference */
                            %IF &Year > 2016 %THEN %DO ;
                            + RepFbPAr                  /* 2015-16 MYEFO - Previous year reportable fringe benefit of reference (proxied by current year)
														   to be included in the parental income test from 1 January 2017 */
                            %END ;
                            %ELSE %DO ;
                            + AdjFbPAr                  /* Previous year adjusted fringe benefit of reference (proxied by current year) */
                            %END ;
                            + NetInvLossPAr             /* Previous year Net Investment Loss of reference */  
                            + RepSupContPAr             /* Previous year Reportable Superannuation Contributions of reference (proxied by current year) */
                            + IncMaintSPAr              /* Previous year maintenance income received by the reference */
                            - MaintPaidSPAr             /* Previous year maintenance income paid by the reference*/

                           /* 2015-16 Budget - from 1 January 2016, parental income will not be increased by any maintenance received by the parent.
                              However parental income will continue to be reduced by any maintenance paid by the parent */
                                %IF &Year >= 2016 %THEN %DO ;
                                    - IncMaintSPAr              /* Previous year maintenance income received by the reference */
                                %END ;  

                              /* Spouse income */
                            + TaxIncPAs                 /* Previous year taxable income of spouse */
                            %IF &Year > 2016 %THEN %DO ;
                            + RepFbPAs                  /* 2015-16 MYEFO - Previous year reportable fringe benefit of spouse (proxied by current year)
														   to be included in the parental income test from 1 January 2017 */
                            %END ;
                            %ELSE %DO ;
                            + AdjFbPAs                  /* Previous year adjusted fringe benefit of reference (proxied by current year) */
                            %END ;
                            + NetInvLossPAs             /* Previous year Net Investment Loss of spouse */  
                            + RepSupContPAs             /* Previous year Reportable Superannuation Contributions of spouse (proxied by current year) */
                            + IncMaintSPAs              /* Previous year maintenance income received by the spouse */
                            - MaintPaidSPAs             /* Previous year maintenance income paid by the spouse */

                           /* 2015-16 Budget - from 1 January 2016, parental income will not be increased by any maintenance received by the parent.
                              However parental income will continue to be reduced by any maintenance paid by the parent */
								%IF &Year >= 2016 %THEN %DO ;
                                    - IncMaintSPAs              /* Previous year maintenance income received by the reference */
                                %END ;
                            ; 

        END ;

    END ;

%MEND ParenIncTestAll ; 

**********************************************************************************
*   Macro:   AssetsTest                                                          *
*   Purpose: Calculates assets for pension purposes                              *
*********************************************************************************;;

%MACRO AssetsTest ;

	* Calculate assets for pension assets test.
      If person is in a couple then combine assets ;
	
    IF Coupleu = 0 THEN AssetsPenTest = AssTotr ;
    ELSE IF Coupleu = 1 THEN AssetsPenTest = AssTotr + AssTots ;

%MEND AssetsTest ;

* Call %RunIncome1 ;
%RunIncome1
