
**************************************************************************************
* Program:      YearOfArrivalImp.sas                                                 *
* Description:  Impute the year the person arrived in Australia, for the purposes of *
*               assessing eligibility for the Age Pension.                           *
**************************************************************************************;

* This module imputes the variable YearOfArrival, which takes the value 0 if the person is born in Australia,
  1 if the person was not born in Australia but arrived in Australia 10 or more years before the survey was
  taken, and 2 if the person was not born in Australia and arrived in Australia less than 10 years before the
  survey was taken. ;

	* This module ignores the change in residency requirement from 10 to 15 years as per the 2017-18 Budget. 
	  The impact of the change does not appear to be significant as per the DSS benchmarks. People are likely 
	  to be meeting the other criteria,ie 10 years continuous residence of which 5 years are during working life 
	  or of which 5 years are without having received activity tested income support payment. ; 

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

	*SIH value of 1 = Born in Australia, 2 ; 
    IF YearOfArrivalSp < 2 THEN YearOfArrivalp = 0 ;

	*SIH value of 2 = Arrived 1985 and before, 3= Arrived 1986-1995 ; 
    ELSE IF YearOfArrivalSp < 4 THEN YearOfArrivalp = 1 ;

	*SIH value of 4 = Arrived 1996 to year of collection (2014); 
    ELSE IF YearOfArrivalSp = 4 THEN DO ;
		
		*Random assignment based on probability of 8 of 18 - arrived in the first 8 years of a possible 18 years (2014-1996); 	
        IF RandYearArrImpp < 8/18 THEN YearOfArrivalp = 1 ;

        ELSE YearOfArrivalp = 2 ;

    END ;

	*If SIH value not specified, but receiving Age Pension on the SIH, then pass year of arrival test; 
    ELSE IF AgePenSWp > 0 THEN YearOfArrivalp = 1 ;

    ELSE YearOfArrivalp = 2 ;

RUN ;



