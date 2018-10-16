
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
YaPrevFlagp = 0 ;       /* Indicator variable = 1 if person receives YA on the SIH (previous year) */

LogYAIncAp = 0 ;        /* Log of annualised YA amount on the SIH (current year) */
LogYaIncPrevAp = 0;     /* Log of annualised YA amount on the SIH (previous year) */

IncEarnedAp = 0 ;       /* Annualised earned income amount (employee income plus business income) on the SIH (current year) */
LogIncEarnedAp = 0 ;    /* Log of annualised earned income amount on the SIH (current year) */
IncEarnedPrevAp = 0 ;   /* Annualised earned income amount on the SIH (previous year) */
LogIncEarnedPrevAp = 0 ;/* Log of annualised earned income amount on the SIH (previous year) */

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
IF IncYASPAp > 0 THEN YaPrevFlagp = 1 ;

* Logged and annualised YA amount variables ;
IF YouthAllSWp > 0 THEN LogYAIncAp = LOG ( YouthAllSWp * 52 ) ;
IF IncYASPAp > 0 THEN LogYaIncPrevAp = LOG ( IncYASPAp ) ;

* Earned income amount variables ;
IncEarnedAp = 52 * SUM ( IncEmpTotSWp , IncBusLExpSWp ) ;
IF IncEarnedAp > 0 THEN LogIncEarnedAp = LOG ( IncEarnedAp ) ;
IncEarnedPrevAp = SUM ( IncTotEmpIncSPAp , IncBusLExpSPAp ) ;
IF IncEarnedPrevAp > 0 THEN LogIncEarnedPrevAp = LOG ( IncEarnedPrevAp ) ;

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


        WFIProbp = -6.8345
                 + Age17p * 1.9312
                 + Age18p * 2.4175
                 + Age19p * 2.6413
                 + Age20p * 3.2832
                 + Age21p * 4.3390
                 + Age22p * 3.7911
                 + SexIndp * -0.0197
                 + FTEmpp * 3.2314
                 + PTEmpp * 1.2743
                 + SecEdup * -0.4586
                 + TerEdup * -0.7526
                 + LogYaIncAp * 0.1293
                 + LogYaIncPrevAp * -0.2221
                 + LogIncEarnedAp * -0.0294
                 + LogIncEarnedPrevAp * 0.2488
                 + AFHp * 0.9687 ;

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

        DROP WFIProbp Age17p Age18p Age19p Age20p Age21p Age22p FTEmpp PTEmpp SecEdup TerEdup YaFlagp YaPrevFlagp
             LogYAIncAp LogYaIncPrevAp IncEarnedAp LogIncEarnedAp IncEarnedPrevAp LogIncEarnedPrevAp AFHp SexIndp ;

RUN ;

