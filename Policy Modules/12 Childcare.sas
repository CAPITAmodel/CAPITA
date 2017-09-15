
************************************************************************************;
* Name of program:  12 Childcare.sas                                               *
* Description:      Calculates family entitlement to CCB and CCR and then CCS      *
					from 2018-19 onwards.     									   *
                    This cameo calculator only allows one type of child care per   *
					child.                  									   *  
************************************************************************************;
************************************************************************************
*   Macro:   RunChildcare                                                          *
*   Purpose: Coordinate childcare calculation                                      *
************************************************************************************;

	*************************************************************************************
	*  1. Define macros to run to calculate outcomes under the current childcare system *
	                 (in place up to 1 July 2018)                                       *
	*************************************************************************************;

	*************************************************************************************
	*  2. Define macros to run to calculate outcomes under the proposed childcare system*
	                    (to take effect on 1 July 2018)                                 *
	*************************************************************************************;

	%MACRO RunChildcare ;

	%IF ( &Duration = A AND &Year < 2018 ) 
	OR ( &Duration = Q AND &Year < 2018 )
	OR ( &Duration = Q AND &Year = 2018 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) )
	%THEN %DO ; 

	/*1. Define macros to run to calculate outcomes under the current childcare system (in place up to 1 July 2018)*/

	    %CcbElig            /*Calculate the maximum number of CCB eligible hours*/
	    %CcbHrElig          /*Calculate the number of CCB-eligible kids in each kind of care and the number CCB eligible hours per child*/
	    %CcbStandHrRate     /*Calculate the standard hourly rate applicable to the specific CCB care*/
	    %CcbPct( Otr )      /*Calculate the Maximum weekly benefit, MultipleChild%, TaxableInc% and CCB% for approved care ('Other')*/
	    %CcbPct( Occ )      /*Calculate the Maximum weekly benefit, MultipleChild%, TaxableInc% and CCB% for approved care ('OCC')*/
	    %CcbSchooling       /*Define schooling status and calculate Schooling %*/
	    %CcbLdcPct          /*Calculate LDC Part-time %*/
	    %CcbBenefit         /*Calculate CCB entitlement, actual childcare cost and out of pocket cost after CCB*/
	    %CcrRebate          /*Calculate CCR entitlement and out of pocket cost after CCR*/

	%END ;

	%ELSE %DO ;

	/*2. Define macros to run to calculate outcomes under the proposed childcare system (to take effect on 1 July 2018)*/

	    %CcsMaxHrElig       /*Calculate the maximum number of CCS eligible hours that can be claimed for each child*/
	    %CcsHrElig          /*Calculate the number of CCS eligible hours per child*/
	    %CcsHrFeeCap        /*Calculate the hourly fee cap applicable to the type of CCS care*/
	    %CcsRate            /*Calculate the subsidy assistance rate*/
	    %CcsSubsidy         /*Calculate CCS entitlement, actual childcare cost and out of pocket cost after CCS*/

	%END ;

%MEND RunChildcare ;

**********************************************************************************************************
* PART 1: Define macro to calculate outcomes under the Current Childcare System                          *
* (in place up to 1 July 2018)                                                                           *  
**********************************************************************************************************;

* Define worktest and calculate the maximum number of CCB eligible hours ;
    /* Note, CAPITA assumes that an individual has work related commitments */
    /* if he/she is in the labour force or is studying. */

%MACRO CcbElig ;

    IF ActualAges > 0 THEN DO ;

        IF  (LfStatr IN ("LF") OR StudyTyper IN ("SS", "FTNS", "PTNS")) AND
            (LfStats IN ("LF") OR StudyTypes IN ("SS", "FTNS", "PTNS")) THEN DO ;

            IF ActivHrWr >= 15 AND ActivHrWs >= 15 THEN DO ;
                CcbMaxHrW = CcbMaxHrUprW ;
                CcbInfElig = "Y" ;
                CcrElig = "Y" ;
            END ;

            ELSE IF ActivHrWr > 0 AND ActivHrWs > 0 THEN DO ;
                CcbMaxHrW = CcbMaxHrLwrW ;
                CcbInfElig = "Y" ;
                CcrElig = "Y" ;
            END ;

            ELSE DO ;   /* A family will get up to 24 hours of CCB without having to meet the Work, Training, Study test */
                CcbMaxHrW = CcbMaxHrLwrW ;
                CcbInfElig = "N" ;
                CcrElig = "N" ;
            END ;

        END ; 

        ELSE DO ;   /* A family will get up to 24 hours of CCB without having to meet the Work, Training, Study test */
            CcbMaxHrW = CcbMaxHrLwrW ;
            CcbInfElig = "N" ;
            CcrElig = "N" ;
        END ;

    END ;
        
    ELSE DO ; 

        IF  (LfStatr in ("LF") OR StudyTyper in ("SS", "FTNS", "PTNS")) THEN DO ;

            IF ActivHrWr >= 15 THEN DO ;
                CcbMaxHrW = CcbMaxHrUprW ;
                CcbInfElig = "Y" ;
                CcrElig = "Y" ;
            END ;

            ELSE IF ActivHrWr > 0 THEN DO ;
                CcbMaxHrW = CcbMaxHrLwrW ;
                CcbInfElig = "Y" ;
                CcrElig = "Y" ;
            END ;

            ELSE DO ;   /* A family will get up to 24 hours of CCB without having to meet the Work, Training, Study test */
                CcbMaxHrW = CcbMaxHrLwrW ;
                CcbInfElig = "N" ;
                CcrElig = "N" ;
            END ;

        END ;

        ELSE DO ;   /* A family will get up to 24 hours of CCB without having to meet the Work, Training, Study test */
            CcbMaxHrW = CcbMaxHrLwrW ;
            CcbInfElig = "N" ;
            CcrElig = "N" ;
        END ;

    END ;

/*Calculate the family's adjustable taxable income by aggregating both parents' income*/
/* This will be used for the income test later */

    CcTestInc = SUM (AdjTaxIncAr, AdjTaxIncAs) ;

%MEND CcbElig ;

* Calculate the number of CCB-eligible kids in each kind of care and the number CCB eligible hours per child ;

%MACRO CcbHrElig ;

    /*NOTE: CcbNumKidOtr, CcbNumKidOcc and CcbNumKidInf have been initialised to zero in policy initialisation*/

    %DO j = 1 %TO 4 ;

        IF CcHrW&j > 0 THEN DO ; 

            IF CcbType&j IN ("LDC", "FDC/INC - SHr", "FDC/INC - NSHr", "OSHC") THEN DO ;
                CcbNumKidOtr = CcbNumKidOtr + 1 ;
                CcbEligHrW&j = MIN (CcHrW&j, CcbMaxHrW) ;
                END ;

            ELSE IF CcbType&j = "OCC" THEN DO ;
                CcbNumKidOcc = CcbNumKidOcc + 1 ;
                CcbEligHrW&j = MIN (CcHrW&j, CcbMaxHrW) ;
                END ;

            ELSE IF CcbType&j = "INF" THEN DO ;
                IF CcbInfElig = "Y" THEN CcbNumKidInf = CcbNumKidInf + 1 ;
                IF CcbInfElig = "Y" THEN CcbEligHrW&j = MIN (CcHrW&j, CcbMaxHrW) ;
                END ;

        END ;

        ELSE CcbEligHrW&j = 0 ;

    %END ; 

%MEND CcbHrElig ; 

* Calculate the standard hourly rate applicable to the specific CCB care ;

%MACRO CcbStandHrRate ;

    %DO i = 1 %TO 4 ;

        IF CcbType&i IN ("LDC", "OSHC", "OCC") 
            THEN CcbStdRate&i = CcbStdHrRateApp ;

        ELSE IF (CcbType&i = "FDC/INC - SHr" AND CcbEligHrW&i > 0) 
            THEN CcbStdRate&i = MIN ( CcbStdHrRateApp * 4/3 , 50 * CcbStdHrRateApp / CcbEligHrW&i ) ;

        ELSE IF CcbType&i = "FDC/INC - NSHr" 
            THEN CcbStdRate&i = CcbStdHrRateApp * 4/3;

        ELSE IF CcbType&i = "INF" 
            THEN CcbStdRate&i = CcbStdHrRateReg ;
        
        ELSE CcbStdRt&i = 0 ;

    %END ;

%MEND CcbStandHrRate ;

* Calculate the Maximum weekly benefit, MultipleChild%, TaxableInc% and CCB% for approved care 
* CcbTypes 'OCC' and 'Other' are done separately ;

%MACRO CcbPct( CcbType ) ;  

    /*Maximum weekly benefit (Clause 11, variables refer to items in the MWB Table)*/
    
    CcbMaxBenW1 = CcbStdHrRateApp * 50 ;
    CcbMaxBenW3 = CcbStdHrRateApp * 100 + CcbMultChdLd2 ;
    CcbMaxBenW5 = CcbStdHrRateApp * 150 + CcbMultChdLd3 ;

    IF CcTestInc > CcbIncThrUprA 
        THEN CcbMaxBenWSpcTapAmt = (CcbIncThrUprA - CcbIncThrLwrA) / 52 * CcbTprLwr2 ; 
            /*CcbMaxBenWSpcTapAmt is taper amount for scenario ATI = Upper Income Threshold*/
        ELSE CcbMaxBenWSpcTapAmt = 0 ;
    
    CcbAddMaxBenW = CcbMaxBenW1 ;
    CcbAddLd = CcbMultChdLd3 / 3 ;

    IF CcbNumKid&CcbType = 0 THEN CcbMaxBenW&CcbType = 0 ;
        ELSE IF CcbNumKid&CcbType = 1 THEN CcbMaxBenW&CcbType = CcbMaxBenW1 ;
        ELSE IF CcbNumKid&CcbType = 2 THEN CcbMaxBenW&CcbType = CcbMaxBenW3 - CcbMaxBenWSpcTapAmt ;
        ELSE IF CcbNumKid&CcbType = 3 THEN CcbMaxBenW&CcbType = CcbMaxBenW5 - CcbMaxBenWSpcTapAmt ;
        ELSE CcbMaxBenW&CcbType = CcbMaxBenW5 + ( MAX(CcbNumKid&CcbType - 3, 0) * (CcbAddMaxBenW + CcbAddLd) ) - CcbMaxBenWSpcTapAmt ;

    /*Multiple Child Percentage*/

    IF CcbNumKid&CcbType = 0 THEN CcbMultChdPct&CcbType = 0 ;
        ELSE CcbMultChdPct&CcbType = CcbMaxBenW&CcbType / ( CcbMaxBenW1 * CcbNumKid&CcbType ) ;

    /*Taxable Income Percentage*/

    IF CcbNumKid&CcbType > 1 AND CcTestInc > CcbIncThrUprA
        THEN CcbIncExcW&CcbType = ( CcTestInc - CcbIncThrUprA ) / 52 ;
        ELSE CcbIncExcW&CcbType = ( MAX ( CcTestInc - CcbIncThrLwrA , 0 ) ) / 52 ;

    IF CcbNumKid&CcbType = 0 THEN CcbTapPct&CcbType = 0 ;
        ELSE IF CcbNumKid&CcbType = 1 THEN CcbTapPct&CcbType = CcbTprLwr1 ;
        ELSE IF CcTestInc <= CcbIncThrUprA THEN CcbTapPct&CcbType = CcbTprLwr2 ;
        ELSE IF CcbNumKid&CcbType = 2 THEN CcbTapPct&CcbType = CcbTprUpr1 ;
        ELSE CcbTapPct&CcbType = CcbTprUpr2 ;

    CcbTapAmtW&CcbType = CcbIncExcW&CcbType * CcbTapPct&CcbType ;

    IF CcbNumKid&CcbType = 0 THEN CcbTaxIncPct&CcbType = 0 ;
        ELSE IF CcTestInc < CcbIncThrLwrA OR
                AllowTyper NOT IN (" ",".") OR PenTyper NOT IN (" ",".") OR DvaTyper NOT IN (" ",".") OR
                AllowTypes NOT IN (" ",".") OR PenTypes NOT IN (" ",".") OR DvaTypes NOT IN (" ",".")  
        THEN CcbTaxIncPct&CcbType = 1 ;
        ELSE CcbTaxIncPct&CcbType = ROUND ( MAX ( 1 - CcbTapAmtW&CcbType / CcbMaxBenW&CcbType , 0) , 0.0001) ;

    /*CCB%*/

    CcbPct&CcbType = CcbMultChdPct&CcbType * CcbTaxIncPct&CcbType ;

%MEND CcbPct ;


* Define schooling status and calculate Schooling % ;

    /*Note ChildAge&j is a cameo created variable ;*/

%MACRO CcbSchooling ;

    %DO j = 1 %TO 4 ; 

        IF ChildAge&j > 0 THEN DO ;

        IF ChildAge&j < CcbSchAge THEN CcbSchPct&j = 1 ;
            ELSE CcbSchPct&j = CcbSchKidPct ;

        END ;

        ELSE CcbSchPct&j = 0 ;

    %END ;

%MEND CcbSchooling ;

* Calculate LDC Part-time % ;

%MACRO CcbLdcPct ;

    %DO j = 1 %TO 4 ; 

        IF CcbSchPct&j = CcbSchKidPct OR CcbType&j NE "LDC" 
            THEN CcbLdcPct&j = CcbLdcLdPct1 ;
        ELSE IF CcHrW&j < CcbLdcLdHr1 
            THEN CcbLdcPct&j = CcbLdcLdPct6 ;
        ELSE IF CcHrW&j < CcbLdcLdHr2 
            THEN CcbLdcPct&j = CcbLdcLdPct5 ;
        ELSE IF CcHrW&j < CcbLdcLdHr3 
            THEN CcbLdcPct&j = CcbLdcLdPct4 ;
        ELSE IF CcHrW&j < CcbLdcLdHr4 
            THEN CcbLdcPct&j = CcbLdcLdPct3 ;
        ELSE IF CcHrW&j < CcbLdcLdHr5 
            THEN CcbLdcPct&j = CcbLdcLdPct2 ;
        ELSE CcbLdcPct&j = CcbLdcLdPct1 ;

    %END ;

%MEND CcbLdcPct ;

* Calculate CCB entitlement, actual childcare cost and out of pocket cost after CCB ;

%MACRO CcbBenefit ;

    /*CCB entitlement*/

    %DO j = 1 %TO 4 ; 

        IF CcbType&j IN ("LDC", "FDC/INC - SHr", "FDC/INC - NSHr", "OSHC")
            THEN CcbAmtW&j = ROUND (
                                MIN ( CcbEligHrW&j * CcbStdRate&j * CcbPctOtr * CcbSchPct&j * CcbLdcPct&j , 
                                      CcbEligHrW&j * CcHrCost&j ) , 0.01 ) ;

        ELSE IF CcbType&j = "OCC"
            THEN CcbAmtW&j = ROUND (
                                MIN ( CcbEligHrW&j * CcbStdRate&j * CcbPctOcc * CcbSchPct&j * CcbLdcPct&j , 
                                      CcbEligHrW&j * CcHrCost&j ) , 0.01 ) ;

        ELSE IF CcbType&j = "INF" AND CcbInfElig = "Y" 
            THEN CcbAmtW&j = ROUND (
                                MIN ( CcbEligHrW&j * CcbStdRate&j * CcbSchPct&j , 
                                      CcbEligHrW&j * CcHrCost&j ) , 0.01 ) ;

        ELSE CcbAmtW&j = 0 ;

    /*Actual childcare cost and out of pocket cost after CCB*/

        IF CcHrW&j > 0 THEN DO ;

            CcbCostW&j = ROUND ( CcHrW&j * CcHrCost&j , 0.01 ) ;

            CcbOutPocketW&j = ROUND ( CcbCostW&j - CcbAmtW&j , 0.01 ) ;

        END;

    %END ;

    CcbAmtAu = SUM (CcbAmtW1 * CcWPerYr1 , CcbAmtW2 * CcWPerYr2 , CcbAmtW3 * CcWPerYr3 , CcbAmtW4 * CcWPerYr4 ) ;

    IF CcHrW1 > 0 OR CcHrW2 > 0 OR CcHrW3 > 0 OR CcHrW4 > 0 THEN DO ;

        CcbCostAu = SUM ( CcbCostW1 * CcWPerYr1 , CcbCostW2 * CcWPerYr2 , CcbCostW3 * CcWPerYr3 , CcbCostW4 * CcWPerYr4 ) ;

    CcbOutPocketAu = SUM ( CcbOutPocketW1 * CcWPerYr1 , CcbOutPocketW2 * CcWPerYr2 , CcbOutPocketW3 * CcWPerYr3 , CcbOutPocketW4 * CcWPerYr4 ) ; 

    END;

%MEND CcbBenefit ;

* Calculate CCR entitlement and out of pocket cost after CCR ;

%MACRO CcrRebate ;

    /*CCR entitlement*/

    %DO j = 1 %TO 4 ; 

        IF CcrElig = "Y" AND CcbType&j IN ("LDC", "FDC/INC - SHr", "FDC/INC - NSHr", "OSHC", "OCC") AND CcbOutPocketW&j > 0 
            THEN CcrAmtA&j = ROUND (
                            MIN ( CcrPct * CcbOutPocketW&j * CcWPerYr&j , CcrMaxRebA ) , 0.01 ) ;

        ELSE CcrAmtA&j = 0 ;

        IF CcbOutPocketW&j > 0 
            THEN CcrOutPocketA&j = ROUND (( CcbOutPocketW&j  * CcWPerYr&j ) - CcrAmtA&j , 0.01 ) ;

    %END ;

    CcrAmtAu = SUM ( CcrAmtA1 , CcrAmtA2 , CcrAmtA3 , CcrAmtA4 ) ;

    /*out of pocket cost after CCR*/
 
    IF CcHrW1 > 0 OR CcHrW2 > 0 OR CcHrW3 > 0 OR CcHrW4 > 0 THEN DO ;

        CcrOutPocketAu = SUM ( CcrOutPocketA1 , CcrOutPocketA2 , CcrOutPocketA3 , CcrOutPocketA4 ) ;

    END ;

%MEND CcrRebate ;


**********************************************************************************************************
* PART 2: Define macro to calculate outcomes under the proposed childcare system                         *
* (to take effect on 1 July 2018 by replacing CCB and CCR with a Child Care Subsidy (CCS)                *  
**********************************************************************************************************;

%MACRO CcsActivTest( AboveThrs ) ;

/*This macro defines the activity test and calculates the maximum number of CCS eligible hours that can be claimed for each child*/
/*Both parents have to be in the same category to claim the relevant hours, otherwise the family drops down to the lower category*/
/*Provisional policy details set out the activity test in fortnightly parameters, but these have been converted to weekly parameters to be consistent with coding for the current childcare scheme*/

/*If a family's combined income is less than the lower income threshold and they do not meet the activity test, then they are still eligible for up to 12 hours of assitance per week, per child*/ 
/*This section factors in the income level to determine if the family is eligible for this low income activity test exemption*/

    IF Coupleu = 1 THEN DO ;

/*If there are two parents*/

        IF  ((LfStatr IN ("LF") OR StudyTyper IN ("SS", "FTNS", "PTNS")) AND
            (LfStats IN ("LF") OR StudyTypes IN ("SS", "FTNS", "PTNS"))) THEN DO ;

                IF ( ( ActivHrWr < CcsActivHrThrW1 ) OR ( ActivHrWs < CcsActivHrThrW1 ) )

                        /*  If the family's income is above the low income threshold assign them no assistance (CcsMaxHrAssistW1)
                            otherwise they meet the low income activity test exemption so assign them CcsMaxHrAssistWSpc*/

                    %IF &AboveThrs = Y %THEN %DO ; 
                        THEN CcsMaxHrW = CcsMaxHrAssistW1 ;
                    %END ;
                    %ELSE %DO ;
                        THEN CcsMaxHrW = CcsMaxHrAssistWSpc ;
                    %END ;

                ELSE IF ( ( ActivHrWr < CcsActivHrThrW2 ) OR ( ActivHrWs < CcsActivHrThrW2 ) ) 
                    THEN CcsMaxHrW = CcsMaxHrAssistW2;

                ELSE IF ( ( ActivHrWr < CcsActivHrThrW3 ) OR ( ActivHrWs < CcsActivHrThrW3 ) ) 
                    THEN CcsMaxHrW = CcsMaxHrAssistW3 ;

                ELSE CcsMaxHrW = CcsMaxHrAssistW4 ;

            END ;

            ELSE DO; 
                        /*  If the family's income is above the low income threshold assign them no assistance (CcsMaxHrAssistW1) 
                            otherwise they meet the low income activity test exemption so assign them CcsMaxHrAssistWSpc*/

                %IF &AboveThrs = Y %THEN %DO ; 
                    CcsMaxHrW = CcsMaxHrAssistW1 ;
                %END ;
                %ELSE %DO ;
                    CcsMaxHrW = CcsMaxHrAssistWSpc ;
                %END ;

            END ;

    END ;

    ELSE DO ; 

/*If there is just one parent*/

            IF  (LfStatr in ("LF") OR StudyTyper in ("SS", "FTNS", "PTNS")) THEN DO ;

                IF ActivHrWr < CcsActivHrThrW1 

                    /*  If the parent's income is above the low income threshold assign them no assistance (CcsMaxHrAssistW1)
                        otherwise they meet the low income activity test exemption so assign them CcsMaxHrAssistWSpc*/

                    %IF &AboveThrs = Y %THEN %DO ;
                        THEN CcsMaxHrW = CcsMaxHrAssistW1 ;
                    %END ;
                    %ELSE %DO ;
                        THEN CcsMaxHrW = CcsMaxHrAssistWSpc ;
                    %END ;

                ELSE IF ActivHrWr < CcsActivHrThrW2 
                    THEN CcsMaxHrW = CcsMaxHrAssistW2 ;

                ELSE IF ActivHrWr < CcsActivHrThrW3 
                    THEN CcsMaxHrW = CcsMaxHrAssistW3 ;

                ELSE CcsMaxHrW = CcsMaxHrAssistW4 ;

            END ;

            ELSE DO; 
                        /*  If the parent's income is above the low income threshold assign them no assistance (CcsMaxHrAssistW1)
                            otherwise they meet the low income activity test exemption so assign them CcsMaxHrAssistWSpc*/

                %IF &AboveThrs = Y %THEN %DO ; 
                    CcsMaxHrW = CcsMaxHrAssistW1 ;
                %END ;
                %ELSE %DO ;
                    CcsMaxHrW = CcsMaxHrAssistWSpc ;
                %END ;

            END ;

    END ;

%MEND CcsActivTest ;

%MACRO CcsMaxHrElig ;

/*Calculate the family's adjustable taxable income by aggregating both parents' income*/
/*This will be used to determine which activity test should be applied and also later on for the income test in %CcsRate and %CcsSubsidy*/

CcTestInc = SUM ( AdjTaxIncAr , AdjTaxIncAs ) ;

/*Call the relevant macro from above (CcsActivTest( AboveThrs )), depending on the family's adjustable taxable income, to define the activity test and calculate the maximum number of CCS eligible hours that can be claimed for each child*/

IF CcTestInc => CcsIncThrA1 THEN DO ;

    %CcsActivTest(Y)

END ;

ELSE DO ;

    %CcsActivTest(N)

END ;

%MEND CcsMaxHrElig ;


/*Calculate the number of CCS eligible hours per child*/ 
/*This is the lesser of the actual number of hours spent in childcare or the maximum eligible hours calculated above*/

%MACRO CcsHrElig ;

    %DO j = 1 %TO 4 ;

        IF CcHrW&j > 0 THEN DO ; 

            IF CcsType&j IN ("LDC", "FDC", "OSHC") THEN CcsEligHrW&j = MIN (CcHrW&j , CcsMaxHrW) ;

            ELSE CcsEligHrW&j = 0 ;

        END ;

    %END ; 

%MEND CcsHrElig ; 

/*Calculate the hourly fee cap applicable to the type of CCS care*/

%MACRO CcsHrFeeCap ;

    %DO j = 1 %TO 4 ;

        IF CcsType&j = "LDC" THEN CcsHrFeeCap&j = CcsLdcHrFeeCap ;

        ELSE IF CcsType&j = "FDC" THEN CcsHrFeeCap&j = CcsFdcHrFeeCap ;

        ELSE IF CcsType&j = "OSHC" THEN CcsHrFeeCap&j = CcsOshcHrFeeCap ;

        ELSE CcsHrFeeCap&j = 0 ;

    %END ;

%MEND CcsHrFeeCap ;

/*Calculate the subsidy assistance rate*/

%MACRO CcsRate ;

    /*  Determine the subsidy rate based on the family's adjustable taxable income (rounded to 4 decimal places)*/

        IF CcTestInc <= CcsIncThrA1 THEN CcsRateA = CcsRateUprA ;  

        ELSE IF CcTestInc < CcsIncThrA2 THEN CcsRateA = ROUND( MAX ( CcsRateUprA - (( CcTestInc - CcsIncThrA1 ) / (CcsRateTpr * 100)) , CcsRateMidA ), 0.0001 ) ;  

		ELSE IF CcTestInc < CcsIncThrA3 THEN CcsRateA = CcsRateMidA ;

		ELSE IF CcTestInc < CcsIncThrA4 THEN CcsRateA = ROUND( MAX ( CcsRateMidA - (( CcTestInc - CcsIncThrA3 ) / (CcsRateTpr * 100)) , CcsRateLwrA ), 0.0001) ; 

		ELSE IF CcTestInc < CcsIncThrA6 THEN CcsRateA = CcsRateLwrA ; 

        ELSE CcsRateA = 0;  

%MEND CcsRate ;

/*Calculate CCS entitlement, actual childcare cost and out of pocket cost after CCS*/

%MACRO CcsSubsidy ;

    %DO j = 1 %TO 4 ; 

    /*Determine weekly CCS entitlement per child*/ 

        IF CcsType&j IN ("LDC", "FDC", "OSHC") THEN DO ;
        	
			/*CCS amount per hour is rounded to the nearest 2 decimal places*/
            CcsAmtW&j =   CcsEligHrW&j *  ROUND( MIN (CcsHrFeeCap&j * CcsRateA , CcHrCost&j * CcsRateA), 0.01) ;
                                 
    /*Calculate annual CCS amount per child. If family's income is above the highest income threshold then the maximum subsidy cap will apply*/

        IF CcTestInc >= CcsIncThrA5 THEN CcsAmtA&j = MIN ( CcsCappedSubsidyA , CcsAmtW&j * CcWPerYr&j ) ;

        ELSE CcsAmtA&j = CcsAmtW&j * CcWPerYr&j ;
                               
        END ;

        ELSE DO ;
        
            CcsAmtW&j = 0 ;
            CcsAmtA&j = 0 ;

        END ;

    /*Calculate actual childcare costs and out of pocket costs after CCS per child, on both a weekly and annual basis*/

        IF CcHrW&j > 0 THEN DO ;

            CcsCostW&j = CcHrW&j * CcHrCost&j ;

            CcsCostA&j = CcsCostW&j * CcWPerYr&j ;

            CcsOutPocketW&j = CcsCostW&j - CcsAmtW&j ;

            CcsOutPocketA&j = CcsCostA&j - CcsAmtA&j ;

        END;

    %END ;

    /*Calculate a family's total CCS entitlement, child care costs and out of pocket costs on an annual basis*/

    CcsAmtAu = SUM (CcsAmtA1 , CcsAmtA2 , CcsAmtA3 , CcsAmtA4) ;

    IF CcHrW1 > 0 OR CcHrW2 > 0 OR CcHrW3 > 0 OR CcHrW4 > 0 THEN DO ;

        CcsCostAu = SUM (CcsCostA1 , CcsCostA2 , CcsCostA3 , CcsCostA4) ;

        CcsOutPocketAu = SUM (CcsOutPocketA1 , CcsOutPocketA2 , CcsOutPocketA3 , CcsOutPocketA4) ;

    END;

%MEND CcsSubsidy ;

/*Call %RunChildcare to run the relevant macros and output results*/

%RunChildcare

