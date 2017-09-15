
**************************************************************************************
* Program:      AllAgeImp.sas                                                        *
* Description:  The SIH provides ages in the following ranges: 0-2, 3-4, 5-9, 10-14  *
*               (with each of these subject to topcoding, which was modified in 	 *
*               the kid age imputation module), 15, 16, 17, 18, 19, 20, 21, 22, 23,  *
*               24, 25-29, 30-34, 35-39, 40-44, 45-49, 50-54, 55, 56, 57, 58, 59, 60,*
*               61, 62, 63, 64, 65-69, 70-74, 75-79, and 80 and over. This module    *
*               imputes the actual ages (i.e. by single year) for the ages which have*
*               been collapsed into categories in the list above for people 15 years *
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


* Create a macro called 'FiveYearIntervals' which randomly allocates an age to individuals falling in the
    five-year wide age ranges under 80 years of age on the SIH. The arguments are:
      'LowerBound' - The lowest age in the five-year age category 
      'Category' - The value of the SIH variable (agebc) for the five-year age category ;

%MACRO FiveYearIntervals( LowerBound , Category , Random ) ;

    %* Initialise Count and Allocated to zero ;

    Count = 0 ;

    Allocated = 0 ;

    %* If the person is in the age category currently being imputed then do ;

    IF AgeSp = &Category THEN DO ;

        %* Loop through each of the years in the category until a year has been chosen for this person ;   

        DO UNTIL ( Allocated = 1 ) ;

            %* If the random number is less than one fifth, assign the person to the first year in the
               category. Otherwise, assign them to the second year if the random number is less than two
               fifths, and so on. ; 

            IF &Random < ( 1 + Count ) / 5 THEN DO ;

                ActualAgep = &LowerBound + Count ; 

                Allocated = 1 ;

            END ;

            ELSE DO ;

                Count = Count + 1 ;

            END ;

        END ;

    END ;

%MEND FiveYearIntervals ;

* Perform the imputation and append the new variables onto the person level dataset ;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        * Define an array containing the probabilities in the cumulative density funtion - for males 80 years
          and over ;

        ARRAY ProbArrayM80{21} ( 0.1259, 0.2434, 0.3570, 0.4622, 0.5561, 0.6400, 0.7129, 0.7763, 0.8285, 
                                 0.8715, 0.9057, 0.9336, 0.9546, 0.9699, 0.9794, 0.9862, 0.9909, 0.9944,
                                 0.9965, 0.9979, 1 ) ;

        * Define an array containing the outcomes to assign to the imputed variable based on the 
          sampling outcome - for males 80 years and over ;
            
        ARRAY OutcomeArrayM80{21} ( 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
                                    97, 98, 99, 100 ) ;

        * Define an array containing the probabilities in the cumulative density funtion - for females 80 years
          and over ;

        ARRAY ProbArrayF80{21} ( 0.1015, 0.1983, 0.2951, 0.3872, 0.4726, 0.5528, 0.6263, 0.6930, 0.7528,
                                 0.8050, 0.8496, 0.8873, 0.9181, 0.9413, 0.9571, 0.9696, 0.9792, 0.9863,
                                 0.9914, 0.9947, 1 ) ;

        * Define an array containing the outcomes to assign to the imputed variable based on the 
          sampling outcome - for females 80 years and over ;
            
        ARRAY OutcomeArrayF80{21} ( 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96,
                                    97, 98, 99, 100 ) ;

        * Perform the imputation for males 80 years and over by calling 'DistImpute' ;

        IF AgeSp = 30 AND Sexp = 'M' THEN DO ;

            %DistImpute( ActualAgep , RandAllAgeImpM80AndOverp , ProbArrayM80 , OutcomeArrayM80 ) 

        END ;

        * Perform the imputation for females 80 years and over by calling 'DistImpute' ;

        IF AgeSp = 30 AND Sexp = 'F' THEN DO ;

            %DistImpute( ActualAgep , RandAllAgeImpF80AndOverp , ProbArrayF80 , OutcomeArrayF80 ) 

        END ;

        * Perform the imputation for all people aged less than 80 years of age. First impute ages for
            people falling into the five-year wide age ranges by calling 'FiveYearIntervals' ;

        %FiveYearIntervals( 25 , 11 , RandAllAgeImp25to29p )
        %FiveYearIntervals( 30 , 12 , RandAllAgeImp30to34p )
        %FiveYearIntervals( 35 , 13 , RandAllAgeImp35to39p )
        %FiveYearIntervals( 40 , 14 , RandAllAgeImp40to44p )
        %FiveYearIntervals( 45 , 15 , RandAllAgeImp45to49p )
        %FiveYearIntervals( 50 , 16 , RandAllAgeImp50to54p )
        %FiveYearIntervals( 65 , 27 , RandAllAgeImp65to69p )
        %FiveYearIntervals( 70 , 28 , RandAllAgeImp70to74p )
        %FiveYearIntervals( 75 , 29 , RandAllAgeImp75to79p )

        * Next adjust the categories for single years of age to correspond to the actual age ;

            * First adjust ages 15 to 24 inclusive by adding 14 to the category
              (since age 15 is category 1, etc.);

            IF AgeSp < 11 THEN ActualAgep = AgeSp + 14 ;

            * Next adjust ages 55 to 64 inclusive by adding 38 to the category
              (since age 55 is category 17, etc.);
        
            IF 16 < AgeSp < 27 THEN ActualAgep = AgeSp + 38 ;  


RUN ;

* Drop variables not required elsewhere ;
        
DATA Person&SurveyYear ;
        
    SET Person&SurveyYear ;

        DROP ProbArray: OutcomeArray: Allocated i Count ;

RUN ;









