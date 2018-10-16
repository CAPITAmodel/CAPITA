
**************************************************************************************
* Program:      FrankCrImp.sas                                                       *
* Description:  Imputes the value of franking credits received based on the value of *
*               dividend income received on the SIH and an estimation of the         *
*               proportion of these dividends which are franked, based on 2015-16    *
*               TaxStats data. See the documentation on this imputation for more     *
*               information.                                                         *
**************************************************************************************;


*Proportion of dividends which are franked.  Calculated using 2015-16 Tax-stats data in separate spreadsheet*;
*************************************************************************************************************;

%let PerCentFR = 0.9566;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        FrankCrImpWp = ( &PerCentFR * IncDivSWp * ( 0.3 / 0.7 ) ) / ( 1 + &PerCentFR * ( 0.3 / 0.7 ) ) ;

        FrankCrImpFp = FrankCrImpWp * 2 ;

        FrankCrImpAp = FrankCrImpWp * 52 ;

        FrankCrImpPAp = ( &PerCentFR * IncDivSPAp * ( 0.3 / 0.7 ) ) / ( 1 + &PerCentFR * ( 0.3 / 0.7 ) ) ;

RUN ;

