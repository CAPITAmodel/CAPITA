
**************************************************************************************
* Program:      AllAgeImp.sas                                                        *
* Description:  The SIH provides ages for children in single years, with each of 	 *
*				these subject to topcoding.  This is corrected for in the kid age 	 *
*               imputation module													 *
*               Ages for adults 15+ are provided in single years, topcoded to 85  	 *
*				and over 															 *	
*               This module imputes the actual ages (i.e. by single year) for the  	 *
*				ages which have been collapsed into categories for people 15 years 	 *
*               and over. Note that the individual years for the kid age categories  *
*               were imputed in the kidage imputation module).                       * 
**************************************************************************************;

* Create a distribution imputation macro called 'DistImpute' which takes a random outcome from a standard
  uniform distribution and uses this to sample a random outcome from the distribution defined by the
  cumulative density function specified in 'ProbArray'. The arguments are:
    'ImputeVariable' - this is the name of the variable which is to be created from the imputation
    'Random' - random outcome sampled from a standard uniform distribution
    'ProbArray' - an array containing the ordered cumulative density function probabilities which define
                  the distribution from which we want to generate outcomes
    'OutcomeArray' - an array containing the ordered outcomes corresponding to the cumulative density 
                     function probabilities in 'ProbArray' ;

%MACRO DistImpute( ImputeVariable , Random , ProbArray , OutcomeArray ) ;

    %* Initialise indicator variable for whether person has been allocated, and the variable being imputed ;

    Allocated = 0 ;

    &ImputeVariable = 0 ;

    %* Loop through each of the distribution outcomes until the person has been allocated an outcome ;

    DO i = 1 TO DIM( &ProbArray ) UNTIL ( Allocated = 1 ) ;

        %* If the uniform outcome is less than the first CDF value, assign the person to the first category. 
            Otherwise, keep looping through the categories until the person is allocated. ;

        IF &Random < &ProbArray.{i} THEN DO ;

            &ImputeVariable = &OutcomeArray.{i} ;

            Allocated = 1 ;

        END ;

    END ;

%MEND DistImpute ;


* Perform the imputation and append the new variables onto the 2011 person level dataset ;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        * Define an array containing the probabilities in the cumulative density function - for males 85 years
          and over ;

        ARRAY ProbArrayM85{16} (  0.1823, 0.3417, 0.4806, 0.5977, 0.6961,  0.7746, 0.8371, 0.8848, 0.9222,
									0.9489, 0.9679,	0.9788, 0.9863, 0.9911, 0.9947, 1 	) ;

        * Define an array containing the outcomes to assign to the imputed variable based on the 
          sampling outcome - for males 85 years and over ;
            
        ARRAY OutcomeArrayM85{16} ( 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
                                    97, 98, 99, 100 ) ;

        * Define an array containing the probabilities in the cumulative density funtion - for females 85 years
          and over ;

        ARRAY ProbArrayF85{16} ( 0.147, 0.281, 0.405, 0.516, 0.614, 0.699, 0.771, 0.829, 0.877, 0.915, 
									0.942, 0.960, 0.972, 0.982, 0.989, 1 ) ;

        * Define an array containing the outcomes to assign to the imputed variable based on the 
          sampling outcome - for females 85 years and over ;
            
        ARRAY OutcomeArrayF85{16} ( 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
                                    97, 98, 99, 100 ) ;

        * Perform the imputation for males 85 years and over by calling 'DistImpute' ;

        IF AgeSp = 85 AND Sexp = 'M' THEN DO ;

            %DistImpute( ActualAgep , RandAllAgeImpM85AndOverp , ProbArrayM85 , OutcomeArrayM85 ) 

        END ;

        * Perform the imputation for females 85 years and over by calling 'DistImpute' ;

        IF AgeSp = 85 AND Sexp = 'F' THEN DO ;

            %DistImpute( ActualAgep , RandAllAgeImpF85AndOverp , ProbArrayF85 , OutcomeArrayF85 ) 

        END ;


        * Next adjust the categories for single years of age to correspond to the actual age ;
		IF AgeSp<85 THEN ActualAgep = AgeSp ;


RUN ;

* Drop variables not required elsewhere ;
        
DATA Person&SurveyYear ;
        
    SET Person&SurveyYear ;

        DROP ProbArray: OutcomeArray: Allocated i ;

RUN ;









