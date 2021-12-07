
**************************************************************************************
* Program:      WorkforceIndependenceImp.sas                                         *
* Description:  Imputes workforce independence status, which will be used to         *
*               determine whether recipients of Youth Allowance should be subject to *
*               the parental income test.                                            *
**************************************************************************************;

**************************************************************************************************
* Name of program:       Workforce Independence Imputation                                       *
* Description:           Performs the workforce independence imputation in the CAPITA basefile.  *
*                        Creates the variable WrkForceIndepp.                                    * 
*************************************************************************************************;

DATA Person&SurveyYear ;
        
    SET Person&SurveyYear ;

**************************************************************************************************
*   Step 1 - Initialise variables for use in the module.                                         * 
*************************************************************************************************;

* Variables created only for this imputation (will be dropped at the end) ;

WFIProbp = 0 ;          /* Predicted probability of being workforce independent */        
 
Age17p = 0 ;            /* Indicator variable = 1 if person is 17 years old */      
Age18p = 0 ;            /* Indicator variable = 1 if person is 18 years old */   
Age19p = 0 ;            /* Indicator variable = 1 if person is 19 years old */  
Age20p = 0 ;            /* Indicator variable = 1 if person is 20 years old */
Age21p = 0 ;            /* Indicator variable = 1 if person is 21 years old */
Age22p = 0 ;            /* Indicator variable = 1 if person is 22 years old */

FTEmpp = 0 ;            /* Indicator variable = 1 if person is working full time */
PTEmpp = 0 ;            /* Indicator variable = 1 if person is working part time */

SecEdup = 0 ;           /* Indicator variable = 1 if person is undertaking secondary school study */
TerEdup = 0 ;           /* Indicator variable = 1 if person is undertaking tertiary study */

YaFlagp = 0 ;           /* Indicator variable = 1 if person receives YA on the SIH (current year) */

LogYAIncAp = 0 ;        /* Log of annualised YA amount on the SIH (current year) */

IncEarnedAp = 0 ;       /* Annualised earned income amount (employee income plus business income) on the SIH (current year) */
LogIncEarnedAp = 0 ;    /* Log of annualised earned income amount on the SIH (current year) */

AFHp = 0 ;              /* Indicator variable = 1 if person is living away from home */

**************************************************************************************************
*   Step 2 - Create the variables needed for calculating the predicted value from the regression * 
**************************************************************************************************;

* Age indicator variables ;
IF ActualAgep = 17 THEN Age17p = 1 ;
ELSE IF ActualAgep = 18 THEN Age18p = 1 ;
ELSE IF ActualAgep = 19 THEN Age19p = 1 ;
ELSE IF ActualAgep = 20 THEN Age20p = 1 ;
ELSE IF ActualAgep = 21 THEN Age21p = 1 ;
ELSE IF ActualAgep = 22 THEN Age22p = 1 ;

* Male gender indicator variable ;
IF Sexp = 'M' THEN SexIndp = 1 ;
ELSE SexIndp = 0 ;

* Employment indicator variables ;
IF LFStatp = 'PT' THEN PTEmpp= 1 ;
IF LFStatp = 'FT' THEN FTEmpp = 1 ;

* Education indicator variables ;
IF StudyTypep = 'SS' THEN SecEdup = 1 ;
IF StudyTypep IN ( 'FTNS' , 'PTNS' ) THEN TerEdup = 1 ; 

* YA receipt indicator variables ;
IF YouthAllSWp > 0 THEN YaFlagp = 1 ;

* Logged and annualised YA amount variables ;
IF YouthAllSWp > 0 THEN LogYAIncAp = LOG ( YouthAllSWp * 52 ) ;

* Earned income amount variables ;
IncEarnedAp = 52 * SUM ( IncEmpTotSWp , IncBusLExpSWp ) ;
IF IncEarnedAp > 0 THEN LogIncEarnedAp = LOG ( IncEarnedAp ) ;

* Away from home indicator variable ;
IF IUTypeSp = 4 AND Famposp = 'REF' THEN AFHp = 1 ;

**************************************************************************************************
*   Step 3 - Assign workforce independence status to those who we can based on information       *
*            contained in the SIH.                                                               * 
*************************************************************************************************;

* All people in a couple or who have dependent children are workforce independent ;
IF IUPosSp = 2 THEN WrkForceIndepp = 1 ;
IF IUPosSp = 1 AND IUTypeSp IN ( 1 , 2 , 3 ) THEN WrkForceIndepp = 1 ;

* All people 22 years old or more are workforce independent;
IF ActualAgep >= 22 THEN WrkForceIndepp = 1 ;

**************************************************************************************************
*   Step 4 - Determine probability of 15 to 21 year olds being workforce independent based on the*
*            regression coefficents from the HILDA.                                              * 
**************************************************************************************************;

* Perform imputation for those left ;

    IF WrkForceIndepp = 0 THEN DO ;

        WFIProbp = -4.0026
                 + Age18p * 0.2011
                 + Age19p * 1.7279
                 + Age20p * 1.9348
                 + Age21p * 2.3542
                 + Age22p * 2.7236
                 + SexIndp * -0.3620
                 + FTEmpp * 2.7710
                 + PTEmpp * 1.0259
                 + SecEdup * -1.5687
                 + TerEdup * -0.3911
                 + LogIncEarnedAp * 0.0792
                 + AFHp * -0.0531 ;

        * Transform to get predicted probability. ;
        WFIProbp = 1 / ( 1 + exp( -WFIProbp ) ) ;

    END ;

* If probability of being workforce independent is greater than a uniform random number 
  then the person is classified as workforce independent.;

    IF WFIProbp > RandWorkforceIndepImpp THEN WrkForceIndepp = 1 ;

RUN ;

* Drop variables no longer required in the basefiles ;

DATA Person&SurveyYear ;
        
    SET Person&SurveyYear ;

        DROP WFIProbp Age17p Age18p Age19p Age20p Age21p Age22p FTEmpp PTEmpp SecEdup TerEdup YaFlagp 
             LogYAIncAp IncEarnedAp LogIncEarnedAp AFHp SexIndp ;

RUN ;


