
**************************************************************************************
* Program:      VariableConstruct3.sas                                               *
* Description:  Create additional variables which are required for basefiles and     *
*               policy modules, and which require parameters and/or variables from   *
*               across the policy year basefiles. Also, adjust the ages of           *
*               individuals aged 65 in the survey year up to 67, to ensure they      *
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

        /* Adjust the ages of individuals aged 65 in the survey year up to 67, to ensure they 
           continue to receive the age pension in 2019-20 to 2022-23 */

        %IF &BasefileYear > 2018 %THEN %DO ;

            IF ActualAger = 65 THEN ActualAger = 67 ;
            IF ActualAges = 65 THEN ActualAges = 67 ;

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

    * Assume the proportion of income is equal to the proportion of their assets in that fund ;

    IF IncSuperSA&psn > 0 THEN DO ;

        * Calculate amount of income from super fund. All super funds are taken to be private funds ;
        IncSupPrivImpA&psn = IncSuperSA&psn ;
        IncSupGovtImpA&psn = 0 ;

    END ; 

        * Apply minimum drawdown to account based pension. Assume all Private superannuation benefits are account based pension ;
        * This ensures the superannuation benefits drawn down remain consistent with the prevailing drawdown rates after splitting out Private superannuation ;
            IF IncSupPrivImpA&psn > 0 THEN DO ;

                * The actual drawdown amount is increased to the statutory drawdown rate if the actual drawdown amount is less than the minimum drawdown amount required ;
                IF ActualAge&psn <= 64 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown5564 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 74 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown6574 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 79 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown7579 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 84 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown8084 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 89 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown8589 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IF ActualAge&psn <= 94 THEN IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , Drawdown9094 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;
                ELSE IncSupPrivImpA&psn = MAX( IncSupPrivImpA&psn , DrawdownGt95 * ( IncSupPrivImpA&psn + SuperAcBal&psn ) ) ;

                * Recalculate total super income taking into account any increase in Private superannuation benefits due to minimum drawdown requirements ;
                IncSuperImpA&psn = IncSupPrivImpA&psn ; 

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
                IncTaxSuperImpA&psn = IncTaxCompPrivSupImpA&psn ;   
                * Taxfree component is NANE income ;
                IncNonTaxSuperImpA&psn = IncTfCompPrivSupImpA&psn ;

            END ;

            * For people aged 60 or over, superannuation benefit that is from Taxable component untaxed element (Government funds)
            is assessable, and amounts from Taxfree component and from Taxable component taxed element (Private funds) are NANE. ;   
            ELSE IF ActualAge&psn >= 60 THEN DO ;

                * Taxable component taxed element is assessable income ;
                IncTaxSuperImpA&psn = 0 ;    
                * Taxfree component of Government and Private fund benefits and taxable component of Private fund benefits are NANE income ;
                IncNonTaxSuperImpA&psn = IncTaxCompPrivSupImpA&psn 
                                       + IncTfCompPrivSupImpA&psn ;     

            END ;

            * Proxy previous year taxable superannuation income using current year income ;
            IncTaxSuperImpPA&psn = IncTaxSuperImpA&psn ;

        * Reportable superannuation contributions (previous year proxied by current year) ; 

        RepSupContA&psn = IncSSSuperSA&psn ;      /* Include salary sacrifice super contribution but does not include personal deductible contributions */
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

    RepFbA&psn = AdjFbA&psn / ( 1 - TaxRate{ NumTaxBrkt } - MedLevRate ) ;

    * Previous year adjusted fringe benefit amount proxied by current year amount ;

    AdjFbPA&psn = AdjFbA&psn ;      

	* Previous year reportable fringe benefit amount ( proxied by current year amount ) ; 

    RepFbPA&psn = RepFbA&psn ;  

%MEND AdjFbVariables ;

