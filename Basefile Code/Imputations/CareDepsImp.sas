
**************************************************************************************
* Program:      CareDepsImp.sas                                                      *
* Description:  The number of care dependants for Carer Allowance purposes is imputed*
*               based on the SIH value of weekly income from Carer Allowance received*
*               by the person. The SIH income values are divided by the weekly value *
*               of Carer Allowance in the survey year    							 *
*               to estimate the number of care dependants that the person received   *
*               allowances for. The imputation assumes that all recipients received  *
*               carer allowance for the full finanical year for either 0.5, 1, 2 or 3*
*               dependent children. The carer allowance distribution from SIH is     *
*               analysed and divided across the predetermined range of dependent     *
*               children by minimising the over/underestimation of actual carer      *
*               allowance when using the imputation approach.                        * 
**************************************************************************************;

* Imputation of number of care depedants for Carer Allowance purposes. The weekly income thresholds used 
  in this imputation were determined in a separate analysis based on the carer allowance distribution from
  the SIH ;

* Define income thresholds for 0.5, 1 and 2 dependents.  Data has been uprated by CPI using thresholds from the SIH.  Thresholds were 39, 76 and 140 in the SIH;

%let carerPmntThreshold1 = 42;
%let carerPmntThreshold2 = 81;
%let carerPmntThreshold3 = 149; 

    DATA Person&SurveyYear ;

        SET Person&SurveyYear ;

        IF CarerAllSWp > 0 THEN DO ;
            IF CarerAllSWp <= &carerPmntThreshold1 THEN NumCareDepsp = 0.5 ;
            ELSE IF CarerAllSWp <= &carerPmntThreshold2 THEN NumCareDepsp = 1 ;
            ELSE IF CarerAllSWp <= &carerPmntThreshold3 THEN NumCareDepsp = 2 ;
            ELSE NumCareDepsp = 3 ;
        END ;
        
    RUN ;

