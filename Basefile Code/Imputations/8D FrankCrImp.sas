
**************************************************************************************
* Program:      FrankCrImp.sas                                                       *
* Description:  Imputes the value of franking credits received based on the value of *
*               dividend income received on the SIH and an estimation of the         *
*               proportion of these dividends which are franked, based on 2017-18    *
*               TaxStats data. See the documentation on this imputation for more     *
*               information.                                                         *
**************************************************************************************;


*Proportion of dividends which are franked.  Calculated using 2017-18 Tax-stats data in separate spreadsheet*;
*************************************************************************************************************;

%let PerCentFR = 0.9565;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        FrankCrImpWp = ( &PerCentFR * IncDivSWp * ( 0.3 / 0.7 ) ) / ( 1 + &PerCentFR * ( 0.3 / 0.7 ) ) ;

        FrankCrImpFp = FrankCrImpWp * 2 ;

        FrankCrImpAp = FrankCrImpWp * 52 ;

        FrankCrImpPAp = ( &PerCentFR * IncDivSWp * ( 0.3 / 0.7 ) ) / ( 1 + &PerCentFR * ( 0.3 / 0.7 ) ) ; /* Using current year dividends as a proxy for previous year dividends. */

RUN ;

