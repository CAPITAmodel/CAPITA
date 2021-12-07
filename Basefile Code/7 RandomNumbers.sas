**************************************************************************************
* Program:      RandomNumbers.sas                                                    *
* Description:  Creates the random numbers required for the basefile and policy      * 
*               modules.                                                             *                                                              
**************************************************************************************;

* Define macro which regenerates the random numbers if 'RegenRandNums' is set to Y, and overwrites
  the 'RandomNumbersPerson' and 'RandomNumbersIncome' datasets in the library defined above ;

%MACRO RegenerateRandomNumbers (NPDInclusion) ;

    %IF &RegenRandNums = Y %THEN %DO ;
		%LET RandNumSeed =777 ; *Specifies the random number seed;

        %* Random numbers required for person level variables ;
		%LET RandVarsPsn =  	RandAllAgeImpM85AndOverp	/* All age imputation - For males 85 years and over */ 
			                    RandAllAgeImpF85AndOverp	/* All age imputation - For females 85 years and over */
								RandFtbaEsGfthp			    /* ES Grandfathering test - For Family tax benefit A recipients*/			
								RandFtbbEsGfthp				/* ES Grandfathering test - For Family tax benefit B recipients*/
								RandCSHCEsGfthp 			/* ES Grandfathering test - For Commonwealth Senior Health Card holders*/
			                    RandWorkforceIndepImpp		/* Workforce Independence imputation */
			                    RandTaxDedImpp				/* Tax deductions imputation */
			                    YaRandp						/* Allowances module - to determine entitlement to away-
                                                            from-home rate of YA */
								;
		%LET NumRandVarsPsn = %SYSFUNC( COUNTW(&RandVarsPsn)) ;

        DATA RF&NPDInclusion..RandomNumbersPerson ;

            SET Person&SurveyYear ;

			CALL STREAMINIT(&RandNumSeed) ; *Sets the chosen seed for random number generation;

			%DO VarNum = 1 %TO &NumRandVarsPsn ;
				%LET RandVar = %SCAN( &RandVarsPsn, &VarNum) ;
				&RandVar = rand('uniform') ;
			%END;

            KEEP    SihHID
                    SihFID
                    SihIUID 
                    SihPIDp
				    &RandVarsPsn
                    ;

        RUN ;

        PROC SORT DATA = RF&NPDInclusion..RandomNumbersPerson OUT = RF&NPDInclusion..RandomNumbersPerson ;

            BY SihHID SihFID SihIUID SihPIDp ;

        RUN ;  

    %END ;

    * Merge the random numbers datasets onto the person and income unit level datasets ;

    PROC SORT DATA = Person&SurveyYear OUT = Person&SurveyYear ;

        BY SihHID SihFID SihIUID SihPIDp ;

    RUN ;  

    DATA Person&SurveyYear ;

        MERGE Person&SurveyYear RF&NPDInclusion..RandomNumbersPerson ;

        BY SihHID SihFID SihIUID SihPIDp ;

    RUN ;


%MEND RegenerateRandomNumbers ;

%MACRO RNCall ;

    %IF &NpdImpute = Y %THEN %DO ;

        %RegenerateRandomNumbers (NPD) ;

    %END ;

    %ELSE %DO ;

        %RegenerateRandomNumbers (NoNPD) ;

    %END ;

%MEND RNCall ;

%RNCall ;


