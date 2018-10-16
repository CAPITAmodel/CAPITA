
**************************************************************************************
* Program:      RandomNumbers.sas                                                    *
* Description:  Creates the random numbers required for the basefile and policy      * 
*               modules.                                                             *                                                              
**************************************************************************************;

* Define macro which regenerates the random numbers if 'RegenRandNums' is set to Y, and overwrites
  the 'RandomNumbersPerson' and 'RandomNumbersIncome' datasets in the library defined above ;

%MACRO RegenerateRandomNumbers (NPDInclusion) ;

    %IF &RegenRandNums = Y %THEN %DO ;

        %* Random numbers required for person level variables ;

        DATA RF&NPDInclusion..RandomNumbersPerson ;

            SET Person&SurveyYear ;

			RandAllAgeImpM85AndOverp = RANUNI(0) ;       /* All age imputation - For males 85 years and over */    
            RandAllAgeImpF85AndOverp = RANUNI(0) ;       /* All age imputation - For females 85 years and over */

			*Random numbers required for Energy Supplement Grandfathering code*; 
			RandAgeEsGfthp = RANUNI(0) ;           /* ES Grandfathering test - For Age pension recipients*/
			RandAustudyEsGfthp = RANUNI(0) ;       /* ES Grandfathering test - For Austudy recipients*/
			RandCarerEsGfthp = RANUNI(0) ;         /* ES Grandfathering test - For Carer payment recipients*/
			RandDspEsGfthp = RANUNI(0) ;           /* ES Grandfathering test - For Disability support pension recipients*/
			RandNsaEsGfthp = RANUNI(0) ;           /* ES Grandfathering test - For Newstart allowance recipients*/
			RandPppEsGfthp = RANUNI(0) ;           /* ES Grandfathering test - For Parenting payment partnered recipients*/
			RandPpsEsGfthp = RANUNI(0) ;           /* ES Grandfathering test - For Parenting payment single recipients*/
			RandWidowEsGfthp = RANUNI(0) ;         /* ES Grandfathering test - For Widow allowance recipients*/
			RandWifeEsGfthp = RANUNI(0) ;          /* ES Grandfathering test - For Wife pension recipients*/
			RandYastudyEsGfthp = RANUNI(0) ;       /* ES Grandfathering test - For Youth allowance study recipients*/
			RandYaotherEsGfthp = RANUNI(0) ;       /* ES Grandfathering test - For Youth allowance other recipients*/
			RandFtbaEsGfthp = RANUNI(0) ;          /* ES Grandfathering test - For Family tax benefit A recipients*/
			RandFtbbEsGfthp = RANUNI(0) ;          /* ES Grandfathering test - For Family tax benefit B recipients*/
			*End of random numbers required for ES*; 

            RandWorkforceIndepImpp = RANUNI(0) ;         /* Workforce Independence imputation */
            RandTaxDedImpp = RANUNI(0) ;                 /* Tax deductions imputation */
            YaRandp = RANUNI(0) ;                        /* Allowances module - to determine entitlement to away-
                                                            from-home rate of YA */

            KEEP    SihHID
                    SihFID
                    SihIUID 
                    SihPIDp
				    RandAllAgeImpM85AndOverp
                    RandAllAgeImpF85AndOverp
					RandAbstudyEsGfthp
					RandAgeEsGfthp
					RandAustudyEsGfthp
					RandCarerEsGfthp
					RandDspEsGfthp
					RandNsaEsGfthp
					RandPppEsGfthp
					RandPpsEsGfthp
					RandWidowEsGfthp
					RandWifeEsGfthp
					RandYastudyEsGfthp
					RandYaotherEsGfthp
					RandFtbaEsGfthp
					RandFtbbEsGfthp
                    RandYearArrImpp
                    RandWorkforceIndepImpp
                    RandTaxDedImpp
                    YaRandp

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


