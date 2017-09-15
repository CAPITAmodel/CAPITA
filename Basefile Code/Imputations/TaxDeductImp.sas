
**************************************************************************************
* Program:      TaxDeductImp.sas                                                     *
* Description:  Imputes the value of tax deduction by mapping tax records from       *
*               2011-12 (16% sample) to the person records in SIH. See documentation *
*               on this imputation for more info.                                    *
**************************************************************************************;

* Specify the location of Excel workbook containing the tax deduction imputation parameters ;
%LET TDImpParamWkBk = &CapitaDirectory.Basefile Code\Imputations\TaxDeductParams.xlsx ;

* Import parameters for the survey year, for use in super imputation for survey year ;

%ImportParams( &SurveyYear ) 

    DATA Person&SurveyYear ;

        IF _n_ = 1 THEN SET BasefilesParm&SurveyYear ;

        SET Person&SurveyYear ;

    RUN ;    

* Perform super imputation for the survey year (Note: This imputation is performed for the policy years in
  VariableConstruct3. ) ;

    DATA Person&SurveyYear ;

        SET Person&SurveyYear ;

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

        * Apply minimum drawdown to account based pensions. Assume all Private superannuation benefits are account based pension ;
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

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

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


/*Import TaxDeduct percentages and dollars*/

PROC IMPORT OUT = TDParamsProbSal0 
    DATAFILE = "&TDImpParamWkBk"
    DBMS = EXCELCS REPLACE ;
    SHEET = "TDParamsProbSal0" ;
RUN;

PROC IMPORT OUT = TDParamsProbSal1 
    DATAFILE = "&TDImpParamWkBk"
    DBMS = EXCELCS REPLACE ;
    SHEET = "TDParamsProbSal1" ;
RUN;

PROC IMPORT OUT = TDParamsEtotalSal0 
    DATAFILE = "&TDImpParamWkBk"
    DBMS = EXCELCS REPLACE ;
    SHEET = "TDParamsEtotalSal0" ;
RUN;

PROC IMPORT OUT = TDParamsEtotalSal1 
    DATAFILE = "&TDImpParamWkBk"
    DBMS = EXCELCS REPLACE ;
    SHEET = "TDParamsEtotalSal1" ;
RUN;

/*Convert TaxDeduct percentages and dollars into macro variables*/

DATA _NULL_;
SET TDParamsProbSal0 ;
suffix = put(_N_,2.);
ARRAY Sal0ParamsProb{*} _NUMERIC_ ;
DO i = 1 to DIM(Sal0ParamsProb);
CALL SYMPUT (CATS(vname(Sal0ParamsProb[i]),suffix),Sal0ParamsProb[i]);
END;
RUN;

DATA _NULL_;
SET TDParamsProbSal1 ;
suffix = put(_N_,2.);
ARRAY Sal1ParamsProb{*} _NUMERIC_ ;
DO i = 1 to DIM(Sal1ParamsProb);
CALL SYMPUT (CATS(vname(Sal1ParamsProb[i]),suffix),Sal1ParamsProb[i]);
END;
RUN;

DATA _NULL_;
SET TDParamsEtotalSal0 ;
suffix = put(_N_,2.);
ARRAY Sal0ParamsEtotal{*} _NUMERIC_ ;
DO i = 1 to DIM(Sal0ParamsEtotal);
CALL SYMPUT (CATS(vname(Sal0ParamsEtotal[i]),suffix),Sal0ParamsEtotal[i]);
END;
RUN;

DATA _NULL_;
SET TDParamsEtotalSal1 ;
suffix = put(_N_,2.);
ARRAY Sal1ParamsEtotal{*} _NUMERIC_ ;
DO i = 1 to DIM(Sal1ParamsEtotal);
CALL SYMPUT (CATS(vname(Sal1ParamsEtotal[i]),suffix),Sal1ParamsEtotal[i]);
END;
RUN;

/*Create identifiers*/

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        IF IncWageSAp > 0 then SalaryID = "S1";
        ELSE SalaryID = "S0";

        IF IncTaxTranWp > 0 then GovID = "G1";
        ELSE GovID = "G0";

        IF IIntDivFlagp = 1 then IDTID = "IDT1";
        ELSE IDTID = "IDT0";

        IF AgeSp <= 5 then AgeID = "A1";
        ELSE IF AgeSp <= 10 then AgeID = "A2";
        ELSE IF AgeSp <= 12 then AgeID = "A3";
        ELSE IF AgeSp <= 14 then AgeID = "A4";
        ELSE IF AgeSp <= 16 then AgeID = "A5";
        ELSE IF AgeSp <= 26 then AgeID = "A6";
        ELSE AgeID = "A7";

        IF AssessableIncAp <=0 then do; IncomeID = "I01"; IncomeID_ = 1; end;
        ELSE IF AssessableIncAp <= 20000 then do; IncomeID = "I02"; IncomeID_ = 2; end;
        ELSE IF AssessableIncAp <= 40000 then do; IncomeID = "I03"; IncomeID_ = 3; end;
        ELSE IF AssessableIncAp <= 60000 then do; IncomeID = "I04"; IncomeID_ = 4; end;
        ELSE IF AssessableIncAp <= 80000 then do; IncomeID = "I05"; IncomeID_ = 5; end;
        ELSE IF AssessableIncAp <= 100000 then do; IncomeID = "I06"; IncomeID_ = 6; end;
        ELSE IF AssessableIncAp <= 150000 then do; IncomeID = "I07"; IncomeID_ = 7; end;
        ELSE IF AssessableIncAp <= 200000 then do; IncomeID = "I08"; IncomeID_ = 8; end;
        ELSE IF AssessableIncAp <= 250000 then do; IncomeID = "I09"; IncomeID_ = 9; end;
        ELSE IF AssessableIncAp <= 300000 then do; IncomeID = "I10"; IncomeID_ = 10; end;
        ELSE IF AssessableIncAp <= 400000 then do; IncomeID = "I11"; IncomeID_ = 11; end;
        ELSE IF AssessableIncAp <= 500000 then do; IncomeID = "I12"; IncomeID_ = 12; end;
        ELSE IF AssessableIncAp <= 1000000 then do; IncomeID = "I13"; IncomeID_ = 13; end;
        ELSE DO IncomeID = "I14"; IncomeID_ = 14; end;

        TaxDeductID = cats(SalaryID, GovID, IDTID, AGEID, IncomeID);

RUN;

/*Allocate Tax Deduct probabilities*/

%MACRO Loop ;
    
    DATA Person&SurveyYear ;
    SET Person&SurveyYear ;

    %DO i = 0 %TO 1 ;
    %DO j = 0 %TO 1 ;
    %DO k = 0 %TO 1 ;
    %DO l = 1 %TO 7 ;
    %DO m = 1 %TO 14 ;

    IF SalaryID = "S&i" AND GovID = "G&j" AND IDTID = "IDT&k" AND AgeID = "A&l." AND IncomeID_ = &m THEN DO;
    WRE = &&WRESal&i.Gov&j.IDT&k.Age&l.&m.;
    SUPER = &&SUPERSal&i.Gov&j.IDT&k.Age&l.&m.;
    OTHER = &&OTHERSal&i.Gov&j.IDT&k.Age&l.&m.;
    NONE = 1 - SUM (WRE, SUPER, OTHER);
    END;

    %END;
    %END;
    %END;
    %END;
    %END;

    WREc = WRE ;
    SUPERc = WREc + SUPER ;
    OTHERc = SUPERc + OTHER ;
    NONEc = 1 ;

    RUN;

%MEND Loop ;

%Loop;

PROC SORT DATA = Person&SurveyYear ;

    BY TaxDeductID;

RUN;

PROC RANK
    DATA = Person&SurveyYear 
    OUT = Person&SurveyYear
    FRACTION
    TIES = HIGH ;
    RANKS RankedRandNum ;
    VAR RandTaxDedImpp ;
    BY TaxDeductID ;
RUN;

PROC SORT DATA = Person&SurveyYear ;
    BY TaxDeductID RankedRandNum ;
RUN;

DATA Person&SurveyYear ;
SET Person&SurveyYear ;
BY TaxDeductID RankedRandNum ;

    RETAIN _RankedRandNum ;

    IF first.TaxDeductID THEN DO ;
    _RankedRandNum = RankedRandNum ;
    RankedRandNumAdj = _RankedRandNum / 2 ;
    END;

    ELSE DO ;
    RankedRandNumAdj = RankedRandNum - (_RankedRandNum / 2 ) ;
    END;

RUN;

/*Determine the type of tax deduction*/

PROC SORT DATA = Person&SurveyYear ;
    BY TaxDeductID ;
RUN;

DATA Person&SurveyYear ;
SET Person&SurveyYear ;
BY TaxDeductID ;

    IF first.TaxDeductID THEN CWght = 0 ;
    CWght + PersonWeightSp ;
    IF last.TaxDeductID THEN TotWght = CWght ;

RUN ;

PROC SORT DATA = Person&SurveyYear ;

    BY TaxDeductID DESCENDING TotWght ;

RUN;

DATA Person&SurveyYear ;
SET Person&SurveyYear ;
BY TaxDeductID ;

    RETAIN _TotWght ;

    IF first.TaxDeductID THEN DO ;
    _TotWght = TotWght ;
    WghtPct = PersonWeightSp / TotWght ;
    END ;

    ELSE DO ;
    TotWght = _TotWght ;
    WghtPct = PersonWeightSp / TotWght ;
    END ;

RUN ;

DATA Person&SurveyYear ;
SET Person&SurveyYear ;
BY TaxDeductID ;

    RETAIN _WRE _SUPER _OTHER _NONE _TDType _WghtPct ;

    IF first.TaxDeductID THEN DO ;

    _WRE = WRE ;
    _SUPER = SUPER ;
    _OTHER = OTHER ;
    _NONE = NONE ;
    _WghtPct = WghtPct ;

    IF RankedRandNumAdj < WREc THEN TDType = "WRE  " ;
    ELSE IF RankedRandNumAdj < SUPERc THEN TDType = "SUPER" ;
    ELSE IF RankedRandNumAdj < OTHERc THEN TDType = "OTHER" ;
    ELSE TDType = "NONE " ;

    _TDType = TDType ;

    END ;

    ELSE DO ;

    WRE = _WRE ;
    SUPER = _SUPER ;
    OTHER = _OTHER ;
    NONE = _NONE ;

    IF _TDType = "WRE  " THEN WRE = MAX (_WRE - _WghtPct , 0 ) ;
    ELSE IF _TDType = "SUPER" THEN SUPER = MAX (_SUPER - _WghtPct , 0 ) ;
    ELSE IF _TDType = "OTHER" THEN OTHER = MAX (_OTHER - _WghtPct , 0 ) ;
    ELSE IF _TDType = "NONE " THEN NONE = MAX (_NONE - _WghtPct , 0 ) ;

    _WRE = WRE ;
    _SUPER = SUPER ;
    _OTHER = OTHER ;
    _NONE = NONE ;

    WREc = WRE / SUM (WRE, SUPER, OTHER, NONE) ;
    SUPERc = WREc + SUPER / SUM (WRE, SUPER, OTHER, NONE) ;
    OTHERc = SUPERc + OTHER / SUM (WRE, SUPER, OTHER, NONE) ;
    NONEc = OTHERc + NONE / SUM (WRE, SUPER, OTHER, NONE) ;
    
    IF RankedRandNumAdj < WREc THEN TDType = "WRE  " ;
    ELSE IF RankedRandNumAdj < SUPERc THEN TDType = "SUPER" ;
    ELSE IF RankedRandNumAdj < OTHERc THEN TDType = "OTHER" ;
    ELSE TDType = "NONE " ;

    _TDType = TDType ;
    _WghtPct = WghtPct ;

    END ;
  
RUN;

/*Allocate Tax Deduction Amount*/

%MACRO Loop1 ;
    
    DATA Person&SurveyYear;
    SET Person&SurveyYear ;

    %DO i = 0 %TO 1 ;
    %DO j = 0 %TO 1 ;
    %DO k = 0 %TO 1 ;
    %DO l = 1 %TO 7 ;
    %DO m = 1 %TO 14 ;

    IF TDType = "WRE  " AND SalaryID = "S&i." AND GovID = "G&j" AND IDTID = "IDT&k" AND AgeID = "A&l." AND IncomeID_ = &m THEN 
    DeductionAp = &&ETOTAL_WRESal&i.Gov&j.IDT&k.Age&l.&m. ;
    ELSE IF TDType = "SUPER" AND SalaryID = "S&i." AND GovID = "G&j" AND IDTID = "IDT&k" AND AgeID = "A&l." AND IncomeID_ = &m THEN 
    DeductionAp = &&ETOTAL_SUPERSal&i.Gov&j.IDT&k.Age&l.&m. ;
    ELSE IF TDType = "OTHER" AND SalaryID = "S&i." AND GovID = "G&j" AND IDTID = "IDT&k" AND AgeID = "A&l." AND IncomeID_ = &m THEN 
    DeductionAp = &&ETOTAL_OTHERSal&i.Gov&j.IDT&k.Age&l.&m. ;
    ELSE IF TDType = "NONE " AND SalaryID = "S&i." AND GovID = "G&j" AND IDTID = "IDT&k" AND AgeID = "A&l." AND IncomeID_ = &m THEN 
    DeductionAp = 0 ;

    %END;
    %END;
    %END;
    %END;
    %END;

    DeductionFp = DeductionAp /26 ;

    DeductionPAp = DeductionAp ;

    TaxableIncAp = AssessableIncAp - DeductionAp ;

    DeductionWrkAp = DeductionAp * 0.29 ;    * 29% reflects the ratio of EWRE to ETOTAL for individuals aged 55+. 
                                              This variable is used for MAWTO income defn only. ;

    RUN;

%MEND Loop1 ;

%Loop1;

*Drop supplementary variables created by this imputation module ;

    DATA Person&SurveyYear ;
    SET Person&SurveyYear ;

        DROP    IncTaxPrivAp AtiFlagp IncTaxTranWp IncTaxTranAp AssessableIncAp IncWagePctSAp IIntDivFlagp
                SalaryID GovID IDTID AgeID IncomeID IncomeID_ TaxDeductID
                WRE SUPER OTHER NONE
                WREc SUPERc OTHERc NONEc
                RankedRandNum _RankedRandNum RankedRandNumAdj CWght TotWght _TotWght WghtPct
                _WRE _SUPER _OTHER _NONE TDType _TDType _WghtPct TaxableIncAp 

                %KeepVar( &ParamList , 1 ) ;

        * Reinitialise super variables to zero ;
        FundTypep = 0 ; PropPrivImpp = 0 ; IncSupPrivImpAp = 0 ; IncSupGovtImpAp = 0 ; IncSuperImpAp = 0 ;
        IncTfCompGovtSupImpAp = 0 ; IncTfCompPrivSupImpAp = 0 ; IncTaxCompGovtSupImpAp = 0 ; IncTaxCompPrivSupImpAp = 0 ;
        IncTaxSuperImpAp = 0 ; IncNonTaxSuperImpAp = 0 ;
        
    RUN;

