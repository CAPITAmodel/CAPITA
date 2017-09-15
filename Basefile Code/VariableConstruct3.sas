
**************************************************************************************
* Program:      VariableConstruct3.sas                                               *
* Description:  Create additional variables which are required for basefiles and     *
*               policy modules, and which require parameters and/or variables from   *
*               across the policy year basefiles. Also, adjust the ages of           *
*               individuals aged 65 in the survey year up to 66, to ensure they      *
*               still receive the Age Pension                                        * 
**************************************************************************************;

%MACRO VariableConstruct3( BasefileYear ) ;

    DATA Basefile&BasefileYear ;

        SET Basefile&BasefileYear ;

        /* Calculate additional variables required for policy modules, but which require parameters 
           across the basefile years */

        ARRAY TaxRate{ * } TaxRate: ;

            %SuperVariables(r) 
            %AdjFbVariables(r)

            IF Coupleu = 1 THEN DO ;

                %SuperVariables(s) 
                %AdjFbVariables(s)

            END ;

            %DO i = 1 %TO 4 ;

                IF ActualAge&i > 0 THEN DO ; 

                    %SuperVariables( &i )
                    %AdjFbVariables( &i )

                END ;

            %END ;

        /* Adjust the ages of individuals aged 65 in the survey year up to 66, to ensure they 
           continue to receive the age pension in 2017-18 and 2018-19 */

        %IF &BasefileYear > 2016 %THEN %DO ;

            IF ActualAger = 65 THEN ActualAger = 66 ;
            IF ActualAges = 65 THEN ActualAges = 66 ;

        %END ; 



    * Calculate the rent paid by the income unit as the (uprated) household rent divided by the number
      of income units in the household ;

        RentPaidFu = RentPaidFh / NumIUh ;

    RUN ;

%MEND VariableConstruct3 ;



*******************************************************;
* Super Variables                                      ;
*******************************************************;

%MACRO SuperVariables(psn) ;

    * Calculate amount of private and government superannuation benefit, before applying drawdown for 
      calculating taxable and non-taxable superannuation benefits in uprating module ;

    * First calculate fund types ;

        IF IncSuperSA&psn > 0 THEN DO ;

            * Where person only has non-Government superannuation ;
            IF GovSuperAcBal&psn = 0 
            AND PrivSuperAcBal&psn > 0 
                THEN FundType&psn = 'PRIV' ; 

            * Where person only has Government superannuation ;
            ELSE IF GovSuperAcBal&psn > 0 
            AND PrivSuperAcBal&psn = 0 
                THEN FundType&psn = 'GOVT' ; 

            * Where person has a mix of both Government and non-Government superannuation ;
            ELSE IF GovSuperAcBal&psn > 0 
            AND PrivSuperAcBal&psn > 0 
                THEN FundType&psn = 'MIXED' ; 

            * Where person has zero account balance, the fund type is imputed using the proportions of those
              people who have account balances ;
            ELSE IF GovSuperAcBal&psn = 0 
            AND PrivSuperAcBal&psn = 0 
            THEN FundType&psn = 'GOVT' ;

        END ;

    * Calculate the proportion of super income from Government or Private funds ;
    * For people with Mixed funds, assume the proportion of income is equal to the proportion of their assets in that fund ;

    IF IncSuperSA&psn > 0 THEN DO ;

        * Assign proportions of income from Government or Private funds ;
        IF FundType&psn = 'GOVT' THEN PropPrivImp&psn = 0 ;
        ELSE IF FundType&psn = 'PRIV' THEN PropPrivImp&psn = 1 ;
        ELSE IF FundType&psn = 'MIXED' 
            THEN PropPrivImp&psn = PrivSuperAcBal&psn / ( PrivSuperAcBal&psn + GovSuperAcBal&psn ) * IncSourceSplitAdjFactor ;

        * Calculate amount of income from Government or Private funds ;
        IncSupPrivImpA&psn = PropPrivImp&psn * IncSuperSA&psn ;
        IncSupGovtImpA&psn = ( 1 - PropPrivImp&psn ) * IncSuperSA&psn ;

    END ; 

        * Apply minimum drawdown to account based pension. Assume all Private superannuation benefits are account based pension ;
        * This ensures the superannuation benefits drawn down remain consistent with the prevailing drawdown rates after splitting out Private superannuation ;
            IF IncSupPrivImpA&psn > 0 THEN DO ;

                * The actual drawdown amount is increased to the statutory drawdown rate if the actual drawdown amount is less than the minimum drawdown amount required ;
                IF ActualAge&psn <= 64 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown5564 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 74 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown6574 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 79 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown7579 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 84 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown8589 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 89 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown8589 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 94 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown9094 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;
                ELSE IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , DrawdownGt95 * ( IncSupPrivImpA&psn + PrivSuperAcBal&psn ) ) ;

                * Recalculate total super income taking into account any increase in Private superannuation benefits due to minimum drawdown requirements ;
                IncSuperImpA&psn = IncSupPrivImpA&psn + IncSupGovtImpA&psn ; 

            END ;

            * Split super benefit into Taxable component and Taxfree component ;

            IncTfCompGovtSupImpA&psn = IncSupGovtImpA&psn * PropTfCompGov ;             * Taxfree component of Government fund ;
            IncTfCompPrivSupImpA&psn = IncSupPrivImpA&psn * PropTfCompPriv ;            * Taxfree component of Private fund ;
            IncTaxCompGovtSupImpA&psn = IncSupGovtImpA&psn * ( 1 - PropTfCompGov ) ;    * Taxable component of Government fund (untaxed element) ;
            IncTaxCompPrivSupImpA&psn = IncSupPrivImpA&psn * ( 1 - PropTfCompPriv ) ;   * Taxable componenet of Private fund (taxed element) ;

            * Split super benefit into assessable income, or non-assessable non-exempt income (NANE).                                  

            * For people aged less than 60, superannuation benefit that is from Taxable component is assessable, 
            and amounts from Taxfree component is NANE. ;
            IF ActualAge&psn < 60 THEN DO ;

                * Taxable component is assessable income ;
                IncTaxSuperImpA&psn = IncTaxCompGovtSupImpA&psn + IncTaxCompPrivSupImpA&psn ;   
                * Taxfree component is NANE income ;
                IncNonTaxSuperImpA&psn = IncTfCompGovtSupImpA&psn + IncTfCompPrivSupImpA&psn ;

            END ;

            * For people aged 60 or over, superannuation benefit that is from Taxable component untaxed element (Government funds)
            is assessable, and amounts from Taxfree component and from Taxable component taxed element (Private funds) are NANE. ;   
            ELSE IF ActualAge&psn >= 60 THEN DO ;

                * Taxable component taxed element is assessable income ;
                IncTaxSuperImpA&psn = IncTaxCompGovtSupImpA&psn ;    
                * Taxfree component of Government and Private fund benefits and taxable component of Private fund benefits are NANE income ;
                IncNonTaxSuperImpA&psn = IncTfCompGovtSupImpA&psn       
                                       + IncTaxCompPrivSupImpA&psn 
                                       + IncTfCompPrivSupImpA&psn ;     

            END ;

            * Proxy previous year taxable superannuation income using current year income ;
            IncTaxSuperImpPA&psn = IncTaxSuperImpA&psn ;

        * Reportable superannuation contributions (previous year proxied by current year) ; 

        RepSupContA&psn = IncSSSuperSA&psn ;      /* Includes salary sacrifice super contribution but does not include personal deductible contributions */
        RepSupContPA&psn = RepSupContA&psn ;      /* Proxied by current value */
        RepEmpSupContA&psn = IncSSSuperSA&psn ;   /* Proxied by salary sacrifice super contribution */   

%MEND SuperVariables ;

*******************************************************;
* Adjusted Fringe Benefits                             ;
*******************************************************;

%MACRO AdjFbVariables(psn) ;

    * Adjusted fringe benefits ;

    AdjFbA&psn = ( TotSSNonSSFBW&psn * 52 )                    /* Salary sacrificed and non-salary sacrificed fringe benefits */
            * ( ( TotSSNonSSFBW&psn * 52 ) > AdjFBThr ) ;      /* Adjusted fringe benefit is only reportable if it is more than $2,000 */

    AdjFbF&psn = AdjFbA&psn / 26 ;

    * Reportable fringe benefits (i.e. grossed up adjusted amount ;

    RepFbA&psn = AdjFbA&psn / ( 1 - TaxRate{ NumTaxBrkt } - MedLevRate - TBRLRateFBT ) ;

    * Previous year adjusted fringe benefit amount proxied by current year amount ;

    AdjFbPA&psn = AdjFbA&psn ;      

	* Previous year reportable fringe benefit amount ( proxied by current year amount ) ; 

    RepFbPA&psn = RepFbA&psn ;  

%MEND AdjFbVariables ;

