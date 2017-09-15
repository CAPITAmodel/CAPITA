
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

            RandAllAgeImpM80AndOverp = RANUNI(0) ;       /* All age imputation - For males 80 years and over */    
            RandAllAgeImpF80AndOverp = RANUNI(0) ;       /* All age imputation - For females 80 years and over */   
            RandAllAgeImp25to29p = RANUNI(0) ;           /* All age imputation - For people aged 25 to 29 years */
            RandAllAgeImp30to34p = RANUNI(0) ;           /* All age imputation - For people aged 30 to 34 years */
            RandAllAgeImp35to39p = RANUNI(0) ;           /* All age imputation - For people aged 35 to 39 years */
            RandAllAgeImp40to44p = RANUNI(0) ;           /* All age imputation - For people aged 40 to 44 years */
            RandAllAgeImp45to49p = RANUNI(0) ;           /* All age imputation - For people aged 45 to 49 years */
            RandAllAgeImp50to54p = RANUNI(0) ;           /* All age imputation - For people aged 50 to 54 years */
            RandAllAgeImp65to69p = RANUNI(0) ;           /* All age imputation - For people aged 65 to 69 years */
            RandAllAgeImp70to74p = RANUNI(0) ;           /* All age imputation - For people aged 70 to 74 years */    
            RandAllAgeImp75to79p = RANUNI(0) ;           /* All age imputation - For people aged 75 to 79 years */

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

            RandYearArrImpp = RANUNI(0) ;                /* Year of Arrival imputation */
            RandWorkforceIndepImpp = RANUNI(0) ;         /* Workforce Independence imputation */
            RandTaxDedImpp = RANUNI(0) ;                 /* Tax deductions imputation */
            YaRandp = RANUNI(0) ;                        /* Allowances module - to determine entitlement to away-
                                                            from-home rate of YA */

            KEEP    SihHID
                    SihFID
                    SihIUID 
                    SihPIDp
                    RandAllAgeImpM80AndOverp
                    RandAllAgeImpF80AndOverp
                    RandAllAgeImp25to29p
                    RandAllAgeImp30to34p
                    RandAllAgeImp35to39p
                    RandAllAgeImp40to44p
                    RandAllAgeImp45to49p
                    RandAllAgeImp50to54p
                    RandAllAgeImp65to69p
                    RandAllAgeImp70to74p
                    RandAllAgeImp75to79p
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

        %* Random numbers required for income unit level variables ;

        DATA RF&NPDInclusion..RandomNumbersIncome ;

            SET Income&SurveyYear ;

            RandKidAgeImp1 = RANUNI(0) ;    /* Kid age imputation - For first excess kid */    
            RandKidAgeImp2 = RANUNI(0) ;    /* Kid age imputation - For second excess kid */    
            RandKidAgeImp3 = RANUNI(0) ;    /* Kid age imputation - For third excess kid [Note: There are no
                                               income units on the 2013-14 SIH with three excess kids. If there
                                               are ever three or more excess kids, more random numbers can be
                                               added here]. */ 

            RandKidAgeImp21 = RANUNI(0) ;   /* Kid age imputation - For first kid in 0 to 2 imputed age range */ 
            RandKidAgeImp22 = RANUNI(0) ;   /* Kid age imputation - For second kid in 0 to 2 imputed age range */ 
            RandKidAgeImp23 = RANUNI(0) ;   /* Kid age imputation - For third kid in 0 to 2 imputed age range */ 
            RandKidAgeImp24 = RANUNI(0) ;   /* Kid age imputation - For fourth kid in 0 to 2 imputed age range */
            RandKidAgeImp31 = RANUNI(0) ;   /* Kid age imputation - For first kid in 3 to 4 imputed age range */ 
            RandKidAgeImp32 = RANUNI(0) ;   /* Kid age imputation - For second kid in 3 to 4 imputed age range */ 
            RandKidAgeImp33 = RANUNI(0) ;   /* Kid age imputation - For third kid in 3 to 4 imputed age range */ 
            RandKidAgeImp34 = RANUNI(0) ;   /* Kid age imputation - For fourth kid in 3 to 4 imputed age range */  
            RandKidAgeImp41 = RANUNI(0) ;   /* Kid age imputation - For first kid in 5 to 9 imputed age range */ 
            RandKidAgeImp42 = RANUNI(0) ;   /* Kid age imputation - For second kid in 5 to 9 imputed age range */ 
            RandKidAgeImp43 = RANUNI(0) ;   /* Kid age imputation - For third kid in 5 to 9 imputed age range */ 
            RandKidAgeImp44 = RANUNI(0) ;   /* Kid age imputation - For fourth kid in 5 to 9 imputed age range */ 
            RandKidAgeImp51 = RANUNI(0) ;   /* Kid age imputation - For first kid in 10 to 14 imputed age range */ 
            RandKidAgeImp52 = RANUNI(0) ;   /* Kid age imputation - For second kid in 10 to 14 imputed age range */ 
            RandKidAgeImp53 = RANUNI(0) ;   /* Kid age imputation - For third kid in 10 to 14 imputed age range */ 
            RandKidAgeImp54 = RANUNI(0) ;   /* Kid age imputation - For fourth kid in 10 to 14 imputed age range  
                                               [Note: There are no income units on the 2013-14 SIH which have
                                               more than four kids in any particular imputed age range. If there
                                               are ever more than four excess kids, more random numbers can be
                                               added here]. */ 

            KEEP    SihHID
                    SihFID
                    SihIUID
                    RandKidAgeImp1
                    RandKidAgeImp2
                    RandKidAgeImp3
                    RandKidAgeImp21
                    RandKidAgeImp22
                    RandKidAgeImp23
                    RandKidAgeImp24
                    RandKidAgeImp31
                    RandKidAgeImp32
                    RandKidAgeImp33
                    RandKidAgeImp34
                    RandKidAgeImp41
                    RandKidAgeImp42
                    RandKidAgeImp43
                    RandKidAgeImp44
                    RandKidAgeImp51
                    RandKidAgeImp52
                    RandKidAgeImp53
                    RandKidAgeImp54

                    ;

        RUN ;

        PROC SORT DATA = RF&NPDInclusion..RandomNumbersIncome OUT = RF&NPDInclusion..RandomNumbersIncome ;

            BY SihHID SihFID SihIUID ;

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

    PROC SORT DATA = Income&SurveyYear OUT = Income&SurveyYear ;

        BY SihHID SihFID SihIUID ;

    RUN ;  

    DATA Income&SurveyYear ;

        MERGE Income&SurveyYear RF&NPDInclusion..RandomNumbersIncome ;

        BY SihHID SihFID SihIUID ;

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


