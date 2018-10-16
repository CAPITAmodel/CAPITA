**************************************************************************************
* Program:      TaxDeductImp.sas                                                     *
* Description:  Imputes the value of tax deduction by mapping tax records from       *
*               2015-16 (16% sample) to the person records in SIH. See documentation *
*               on this imputation for more info.                                    *
**************************************************************************************;

* Specify the location of Excel workbook containing the tax deduction imputation parameters ;
%LET TDImpParamWkBk = &CapitaDirectory.Basefile Code\Imputations\TaxDeductParams.xlsx ;
libname TDnonpd "&CapitaDirectory.Basefile Code\Imputations\NoNPD";
libname TDnpd "&CapitaDirectory.Basefile Code\Imputations\NPD";

* Import parameters for the survey year, for use in super imputation for survey year ;
%ImportParams( &SurveyYear) 

    DATA Person&SurveyYear;

        IF _n_ = 1 THEN SET BasefilesParm&SurveyYear;

        SET Person&SurveyYear;

    RUN ;    

* Perform super imputation for the survey year (Note: This imputation is performed for the policy years in
  VariableConstruct3. ) ;

    DATA Person&SurveyYear;

        SET Person&SurveyYear;

    * Calculate amount of private and government superannuation benefit, before applying drawdown for 
      calculating taxable and non-taxable superannuation benefits in uprating module ;

    * First calculate fund types ;

        IF IncSuperSAp > 0 THEN DO ;

            * Where person only has non-Government superannuation ;
            IF GovSuperAcBalp = 0 
            AND PrivSuperAcBalp > 0 
                THEN FundTypep = 'PRIV' ; 

            * Where person only has Government superannuation ;
            ELSE IF GovSuperAcBalp > 0 
            AND PrivSuperAcBalp = 0 
                THEN FundTypep = 'GOVT' ; 

            * Where person has a mix of both Government and non-Government superannuation ;
            ELSE IF GovSuperAcBalp > 0 
            AND PrivSuperAcBalp > 0 
                THEN FundTypep = 'MIXED' ; 

            * Where person has zero account balance, the fund type is imputed using the proportions of those
              people who have account balances ;
            ELSE IF GovSuperAcBalp = 0 
            AND PrivSuperAcBalp = 0 
            THEN FundTypep = 'GOVT' ;

        END ;

    * Calculate the proportion of super income from Government or Private funds ;
    * For people with Mixed funds, assume the proportion of income is equal to the proportion of their assets in that fund ;

    IF IncSuperSAp > 0 THEN DO ;

        * Assign proportions of income from Government or Private funds ;
        IF FundTypep = 'GOVT' THEN PropPrivImpp = 0 ;
        ELSE IF FundTypep = 'PRIV' THEN PropPrivImpp = 1 ;
        ELSE IF FundTypep = 'MIXED' 
            THEN PropPrivImpp = PrivSuperAcBalp / ( PrivSuperAcBalp + GovSuperAcBalp ) * IncSourceSplitAdjFactor ;

        * Calculate amount of income from Government or Private funds ;
        IncSupPrivImpAp = PropPrivImpp * IncSuperSAp ;
        IncSupGovtImpAp = ( 1 - PropPrivImpp ) * IncSuperSAp ;

    END ; 

        * Apply minimum drawdown to account based pension. Assume all Private superannuation benefits are account based pension ;
        * This ensures the superannuation benefits drawn down remain consistent with the prevailing drawdown rates after splitting out Private superannuation ;
            IF IncSupPrivImpAp > 0 THEN DO ;

                * The actual drawdown amount is increased to the statutory drawdown rate if the actual drawdown amount is less than the minimum drawdown amount required ;
                IF ActualAgep <= 64 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown5564 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IF ActualAgep <= 74 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown6574 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IF ActualAgep <= 79 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown7579 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IF ActualAgep <= 84 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown8589 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IF ActualAgep <= 89 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown8589 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IF ActualAgep <= 94 THEN IncSupPrivImpAp = MAX( IncSupPrivImpAp , Drawdown9094 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;
                ELSE IncSupPrivImpAp = MAX( IncSupPrivImpAp , DrawdownGt95 * ( IncSupPrivImpAp + PrivSuperAcBalp ) ) ;

                * Recalculate total super income taking into account any increase in Private superannuation benefits due to minimum drawdown requirements ;
                IncSuperImpAp = IncSupPrivImpAp + IncSupGovtImpAp ; 

            END ;

            * Split super benefit into Taxable component and Taxfree component ;

            IncTfCompGovtSupImpAp = IncSupGovtImpAp * PropTfCompGov ;             * Taxfree component of Government fund ;
            IncTfCompPrivSupImpAp = IncSupPrivImpAp * PropTfCompPriv ;            * Taxfree component of Private fund ;
            IncTaxCompGovtSupImpAp = IncSupGovtImpAp * ( 1 - PropTfCompGov ) ;    * Taxable component of Government fund (untaxed element) ;
            IncTaxCompPrivSupImpAp = IncSupPrivImpAp * ( 1 - PropTfCompPriv ) ;   * Taxable component of Private fund (taxed element) ;

            * Split super benefit into assessable income, or non-assessable non-exempt income (NANE).                                  

            * For people aged less than 60, superannuation benefit that is from Taxable component is assessable, 
            and amounts from Taxfree component is NANE. ;
            IF ActualAgep < 60 THEN DO ;

                * Taxable component is assessable income ;
                IncTaxSuperImpAp = IncTaxCompGovtSupImpAp + IncTaxCompPrivSupImpAp ;   
                * Taxfree component is NANE income ;
                IncNonTaxSuperImpAp = IncTfCompGovtSupImpAp + IncTfCompPrivSupImpAp ;

            END ;

            * For people aged 60 or over, superannuation benefit that is from Taxable component untaxed element (Government funds)
            is assessable, and amounts from Taxfree component and from Taxable component taxed element (Private funds) are NANE. ;   
            ELSE IF ActualAgep >= 60 THEN DO ;

                * Taxable component taxed element is assessable income ;
                IncTaxSuperImpAp = IncTaxCompGovtSupImpAp ;    
                * Taxfree component of Government and Private fund benefits and taxable component of Private fund benefits are NANE income ;
                IncNonTaxSuperImpAp = IncTfCompGovtSupImpAp       
                                       + IncTaxCompPrivSupImpAp 
                                       + IncTfCompPrivSupImpAp ;     

            END ;

    RUN ;

* Calculate taxable private income and taxable transfer income. These calculations are similar to the
  corresponding income defintions used in the policy modules, however, the definitions below only use
  basefile variables. ;

DATA Person&SurveyYear;

    SET Person&SurveyYear;

    * Taxable private income ;

                      /* Income from wages, salaries and own unincorporated business */
    IncTaxPrivAp = SUM( IncWageSAp,               /* Total usual income from wages/salary of main and second job */
                     IncBusLExpSAp,                  /* Cash income from own unincorporated business. */

                      /* Income from super and annuities */                    
                     IncTaxSuperImpAp,               /* Annual income from taxable superannuation benefits. Created in the Super Module */

                      /* Investment income and dividends */
                     IncIntAp,                       /* Total current annual income from interest payments */
                     IncDivSAp,                      /* Reported annual income from dividends (incl. franking credits). */
                     IncOthInvSAp,                   /* Reported annual income from other financial investments. */
                     IncRoyalSAp,                    /* Reported annual income from royalties. */

                      /* Other non-government income */
                     IncWCompAp,                     /* Annual income from Workers compensation. */
                     IncNonHHSAp,                    /* Annual income from family members not living in the household. */
                     IncOSPenSAp,                    /* Annual income from overseas pensions and benefits. */
                     IncOthRegSAp,                   /* Annual income from other regular sources. */

                      /* Net rent for owner occupied dwellings and subsidised private rentals */
                     IncNetRentAp ) ;                 /* Annual net rent income from rental property */

    * Use AtiFlag for applicable pensions to indicate whether they are taxable or non-taxable. 
    If the recipient of the applicable pensions is below age pension age, the pension is
    non-taxable for tax purposes, but is included for ATI purposes ;

    IF ( Sexp = 'F' AND 16 <= ActualAgep < 64.5 ) 
    OR ( Sexp = 'M' AND 16 <= ActualAgep < 65   ) 

        THEN AtiFlagp = 1 ;      /* Flag for applicable pensions to indicate they are non-taxable */ 
        ELSE AtiFlagp = 0 ;      /* Flag for applicable pensions to indicate they are taxable */ 

    * Taxable transfer income ;

    IncTaxTranWp =     /* Pensions */
                        SUM (AgePenSWp,                      /* Age Pension */
                         CarerPaySWp                         /* Carer Pension */
                        * ( AtiFlagp = 0 ),                  /* Taxable if recipient or care receiver is of Age Pension age */
                         DvaDisPenSWp                        /* Disability Support Pension */
                        * ( AtiFlagp = 0 ),                  /* Taxable if recipient or care receiver is of Age Pension age */
                         ParPaySWp,                          /* Parenting Payment */
                         WifePenSWp                          /* Wife Pension */
                        * ( AtiFlagp = 0 ),                  /* Taxable if recipient or care receiver is of Age Pension age */

                          /* Allowances */
                         AustudySWp,                         /* Abstudy / Austudy */
                         NsaSWp,                             /* Newstart Allowance */
                         PartAllSWp,                         /* Partner Allowance */
                         SickAllSWp,                         /* Sickness Allowance */
                         SpBSWp,                             /* Special Benefit */
                         DvaWWPenSWp, WidAllSWp,          /* Widow Allowance */
                         YouthAllSWp,                        /* Youth Allowance */

                      /* DVA payments */
                         DvaSPenSWp);                        /* DVA Age Service Pension */

    IncTaxTranAp = IncTaxTranWp * 52 ;

    * Assessable income ;

    AssessableIncAp = SUM (IncTaxPrivAp,     /* Taxable private income */
                        IncTaxTranAp) ;         /* Taxable transfer income */

    IF AssessableIncAp = 0
        THEN IncWagePctSAp = 0 ;
        ELSE IncWagePctSAp = ( IncWageSAp * 52 ) / ABS ( AssessableIncAp ) ;

    IF IncIntAp > 0 OR IncDivSAp > 0
        THEN IIntDivFlagp = 1 ;
        ELSE IIntDivFlagp = 0 ;

    RUN ;

Proc sort data=Person&SurveyYear;
 BY SihHID SihFID SihIUID iuposSp;
run;

Proc sort data=TDnpd.taxded2015;
 BY SihHID SihFID SihIUID iuposSp;
run;
Proc sort data=TDnonpd.taxded2015;
 BY SihHID SihFID SihIUID iuposSp;
run;

DATA Person&SurveyYear ;
	if &NpdImpute = Y then do;
     	MERGE Person&SurveyYear TDnpd.taxded2015 ;
     	BY SihHID SihFID SihIUID iuposSp;
	 end;
	 else do;
		MERGE Person&SurveyYear TDnonpd.taxded2015 ;
     	BY SihHID SihFID SihIUID iuposSp;
	end;

RUN ;

DATA Person&SurveyYear ;
set Person&SurveyYear ;
	
	DeductionFp = DeductionAp /26 ;

    DeductionPAp = DeductionAp ;

    TaxableIncAp = AssessableIncAp - DeductionAp ;

    DeductionWrkAp = DeductionAp * 0.29 ;    * 29% reflects the ratio of EWRE to ETOTAL for individuals aged 55+. 
                                              This variable is used for MAWTO income defn only. ;

    RUN;

run;           
