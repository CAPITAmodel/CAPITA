
**************************************************************************************
* Program:      9 FTB.sas                                                            *
* Description:  Calculates Family Tax Benefit (FTB) entitlements.                    *
**************************************************************************************;

OPTIONS MINOPERATOR ;
**************************************************************************************
*   Macro:   RunFtb                                                                  *
*   Purpose: Coordinate FTB calculation                                              * 
**************************************************************************************;;
%MACRO RunFtb ;

    ************************************************************************************
    *      1.        Determine eligibility                                             *
    ************************************************************************************;
    * Flag if the person is eligible for family tax benefit. The DepsFtbA and DepsFtbB 
      variables come from the Dependency module;

    IF DepsFtbA > 0 THEN FtbaFlag = 1 ;
  
    IF DepsFtbB > 0 THEN FtbbFlag = 1 ;

    ************************************************************************************
    *      2.    Calculate income for income test                                      *
    ************************************************************************************;
    IF FtbaFlag = 1 OR FtbbFlag = 1 THEN DO ;

        %FtbIncome

    ************************************************************************************
    *      3.        Assign parameters                                                 *
    ************************************************************************************;
        %FtbParameters 

    END ;
    ************************************************************************************
    *      4.        Assign rent assistance                                            *
    ************************************************************************************;
    IF Renteru = 1 AND FtbaFlag = 1 THEN DO ;

        %FtbaRentAssistAlloc	 /* This macro is in the Allowance module, because of
									2015-16 Budget measure adding FTB-A max rate 
									components to the parental pool for YA  */

        %RentAssistMaxRate        /* This macro is in the DVA module */

    END ;

    ************************************************************************************
    *      5.        Calculate FTB-A payment                                           *
    ************************************************************************************;
    IF FtbaFlag = 1 THEN DO ;

        %Ftbacalc ( _Nbs, NewBornSup1A , NewBornSup2A )

        %Ftbacalc ( _NoNbs, 0, 0 )

        %FtbaFinalPay

    END ;

    ************************************************************************************
    *      6.        Calculate FTB-B payment                                           *
    ************************************************************************************;
    IF FtbbFlag = 1 THEN DO ; 

        %Ftbbcalc 

    END ;

    ************************************************************************************
    *      7.        Calculate other payments                                          *
    ************************************************************************************;
    IF FtbaFlag = 1 and Kids0Su > 0 THEN DO ;

        %BabyUpfrontPayment

    END ;

    *  Schoolkids bonus payable to Ftba recipients with dependents who are primary 
       or secondary students. ;

    IF FtbaFinalA > 0 AND ( AdjTaxIncAr + AdjTaxIncAs ) <= SkBonusIncThr
        THEN SKBonusA = DepsFtbPr  * SkPrimaryRateA  
                      + DepsFtbSec * SkSecStudRateA ;
  
    ************************************************************************************
    *      8.        Calculate summary payments                                        *
    ************************************************************************************;

    * Allocate FTBA and FTBB final amounts to the lower earner ;

    IF AdjTaxIncAr < AdjTaxIncAs OR Coupleu = 0 THEN DO ;

        FtbaAr = FtbaFinalA ;
        FtbbAr = FtbbFinalA ;
        SKBonusAr = SKBonusA;
        BabyBonusAr = BabyBonusA;

    END ; 

    ELSE DO ;

        FtbaAs = FtbaFinalA ;
        FtbbAs = FtbbFinalA ;
        SKBonusAs = SKBonusA ;
        BabyBonusAs = BabyBonusA ;

    END ;

    FtbTotAu  = FtbaFinalA + FtbbFinalA ;

    * Create fortnightly rate;
    FtbaFr = FtbaAr / 26 ; 
    FtbbFr = FtbbAr / 26 ; 
    SKBonusFr = SKBonusAr / 26 ; 
    BabyBonusFr = BabyBonusAr / 26 ; 

    FtbaFs = FtbaAs / 26 ; 
    FtbbFs = FtbbAs / 26 ; 
    SKBonusFs = SKBonusAs / 26 ; 
    BabyBonusFs = BabyBonusAs / 26 ;

%MEND RunFtb ;

************************************************************************************
*   Macro:   FTBIncome                                                             *
*   Purpose: Assign income to be used for income test                              *
************************************************************************************;;
%MACRO FtbIncome ;

    * If receiving DSS/DVA income support payments, exempt from income test ;

    IF  ( ServiceTotFr 
        + ServiceTotFs 
		+ DvaDisPenNmFr
		+ DvaDisPenNmFs
        + PenTotFr 
        + PenTotFs
        + AllTotFr 
        + AllTotFs ) > 0 
    THEN DO ;

        FtbaTestExFlag = 1 ;      

        FtbbPrExFlag = 1 ;

    END ;

    * FTBA income test based on single/combined income ;

    ELSE FtbaTestInc = AdjTaxIncAr + AdjTaxIncAs ;      

    * For FTBB test, assign primary income earner and secondary income earner ; 

    IF AdjTaxIncAr >= AdjTaxIncAs THEN DO ;   

        FtbbTestPrInc = AdjTaxIncAr ;

        FtbbTestSecInc = AdjTaxIncAs ;
    END ;

    ELSE DO ;

        FtbbTestPrInc = AdjTaxIncAs ;

        FtbbTestSecInc = AdjTaxIncAr ;

    END ;

 * Check if receiving maintenance income ;
    IF IncMaintAu  > 0 AND DepsFtbaMaint > 0 THEN DO ;

	*Assume all children eligible for children support are receiving child support ;
						
		*Calculate maintenance income received per child ;
		IncMaintPerDep = IncMaintAu / DepsMaint ;

		*Assign maintenance income for Ftba dependents ;
		FtbaIncMaintAu = IncMaintPerDep * DepsFtbaMaint  ;

	END ;

%MEND FtbIncome ;
************************************************************************************
*   Macro:   FTBParameters                                                         *
*   Purpose: Assign FTBA amounts and supplements                                   *
************************************************************************************;;

%MACRO FtbParameters ;

    * Ftba parameters ;
    FtbaMaxStdA  = (  DepsUnder13 * FtbaMaxRateAgeUnder13 )
                 + (( Deps13_15u 
                 +    DepsFtbaOwnIU 
                 +    DepsFtbSec16_18 
                 +    DepsFtbSec19 ) 
                 *    FtbaMaxRateAge13_19Stud )
                 ;

	FtbaMaxEsA  = (  DepsUnder13 * FtbaMaxEsAgeUnder13 )
                 + (( Deps13_15u 
                 +    DepsFtbaOwnIU 
                 +    DepsFtbSec16_18 
                 +    DepsFtbSec19 ) 
                 *    FtbaMaxEsAge13_19Stud )
                 ;

	FtbaBaseEsA = DepsFtbA *  FtbaBaseEsRateA  ;

	*Assign Energy Supplement based on grandfathering test; 
	*Cease Energy Supplement for new FTB claimants from 20 March 2017, 
	Budget Savings Omnibus Bill 2016 legislated September 2016; 

	%IF (&Duration = A AND &Year >= 2017) 
	    OR (&Duration = Q AND &Year > 2017) 	
	    OR (&Duration = Q AND &Year = 2017 AND (&Quarter = Jun OR &Quarter = Sep OR &Quarter = Dec) ) 
	%THEN %DO ;

		%IF &RunEs = G %THEN %DO; 
	 
			IF FtbaEsGfthrProb < RandFtbaEsGfthr THEN DO ;
				FtbaMaxEsA = 0; 
				FtbaBaseEsA = 0;
			END ;
		
		%END; 

		%ELSE %IF &RunEs = Y %THEN %DO; 
			
			FtbaMaxEsA = FtbaMaxEsA ;
			FtbaBaseEsA = FtbaBaseEsA ;

		%END; 

		%ELSE %IF &RunEs = N %THEN %DO; 

			FtbaMaxEsA = 0 ; 
			FtbaBaseEsA = 0 ; 

		%END; 

	%END ;
	
	%ELSE %DO; 

			FtbaMaxEsA = FtbaMaxEsA ;
			FtbaBaseEsA = FtbaBaseEsA ;

	%END; 

	FtbaBaseStdA = DepsFtbA * FtbaBaseRateA ;
		

  	FtbaEndSupA = DepsFtbA * FtbaSupA;

	*6March2017, Budget Savings Omnibus Bill 2016,legislated in Sep 2016 , 
	 from 1 July 2016, FTBA supplement not payable to customers with ATI in excess of 80,000 ;
	%IF (&Duration = A AND &Year >= 2016) 
	    OR (&Duration = Q AND &Year > 2016)	
	    OR(&Duration = Q AND &Year = 2016 AND (&Quarter = Sep OR &Quarter = Dec) ) 
	%THEN %DO ;
		IF FtbaTestInc > FtbaSupAThr THEN FtbaEndSupA = 0 ;
	%END ;


	*7 July 2015, The large family supplement will cease from 1 July 2016 
	(Budget 2015-16)
    For each child including and after the LfsKidsMin child ;
    IF DepsFtbA >=  LfsKidsMin 
        THEN LargeFamSupA = LfsRateA * ( DepsFtbA - ( LfsKidsMin - 1 ) ) ;

   *If receiving maintenance income ;
	IF FtbaIncMaintAu > 0 THEN DO ;
	 
		IF IncMaintSFr > 0 AND IncMaintSFs > 0 
	       THEN FtbaMaintIncFree = MaintIncFreeCouple ;

	    * If only one recipient;

	    ELSE FtbaMaintIncFree = MaintIncFreeSingle ;

	    * Assume all FTBA dependents aged 18 and under are child support recipients. This is to avoid 
	      making imputations on SIH data (which lack information on children receiving 
	      support) ;

	    FtbaMaintIncThr = FtbaMaintIncFree + MAX ( 0 , ( DepsFtbaMaint - 1 )* MaintIncFreeKids ) ;

	END ;

	* Ftbb parameters. Maximum rate based on youngest child age ;
    
	    IF DepsUnder5 > 0 THEN DO ;

	        FtbbStdA = FtbbDepUnder5A ;

	        FtbbEsA = FtbbEsUnder5A ; 

	    END ;

	    ELSE DO ;

	        FtbbStdA = FtbbDepOver5A ;

	        FtbbEsA = FtbbEsOver5A ;

	    END ;

	*Assign Energy Supplement based on grandfathering test; 
	*Cease Energy Supplement for new FTB claimants from 20 March 2017, 
	Budget Savings Omnibus Bill 2016 legislated September 2016; 

	%IF (&Duration = A AND &Year >= 2017) 
	    OR (&Duration = Q AND &Year > 2017)	
	    OR(&Duration = Q AND &Year = 2017 AND (&Quarter = Jun OR &Quarter = Sep OR &Quarter = Dec) ) 
	%THEN %DO ;

		%IF &RunEs = G %THEN %DO; 

			IF Ftbbflag = 1 AND RandFtbbEsGfthr GE FtbbEsGfthrProb THEN FtbbEsA = 0; 

		%END; 
		
		%ELSE %IF &RunEs = Y %THEN %DO; 

			FtbbEsA = FtbbEsA ; 

		%END; 

		%ELSE %IF &RunEs = N %THEN %DO; 

			FtbbEsA = 0 ; 

		%END; 
	%END ;	

	%ELSE %DO; 

		FtbbEsA = FtbbEsA ; 

	%END; 

	/*End*/

%MEND FtbParameters ;
************************************************************************************
*   Macro:   Ftbacalc                                                              *
*   Purpose: Calculate FTB-A maximum and base rate amounts before and after        *
             reduction.                                                            *
************************************************************************************;;
%MACRO Ftbacalc ( suffix , nbs1, nbs2 ) ;
    
    * Calculate newborn supplement. Higher rate is payable for first child and all 
      multiple births. We assume that if there are two newborns, they are twins. 
      Assume also that nobody takes parental leave. ;
      
    IF Kids0Su > 0 THEN DO ;

            IF TotalKidsu = Kids0Su OR Kids0Su > 1 
                THEN NewBornSupA = Kids0Su * &Nbs1 ; 

            ELSE IF Kids0Su = 1 THEN NewBornSupA = Kids0Su * &Nbs2 ;

    END ;

    * Define a factor for annualising Newborn Supplement for the means test 
      calculation. Set factor to 1 if number of weeks is 0 (ie, NBS not paid 
      in this period) ;

    IF NbsNumw > 0 THEN NbsFactor = NbsNumw * 7 / 365 ;

    ELSE NbsFactor = 1 ;

    NbsAnnualised = NewBornSupA / NbsFactor ; 

 **********************************************************************************           
    * Calculate Ftba maximum payment by adding all components of the maximum rate. 
      Rent assistance is converted to annual amount consistent with DSS conversion 
      formula reflecting 365 days in a year;

    FtbaMaxTotal = FtbaMaxStdA
                 + FtbaMaxEsA
                 + FtbaEndSupA
                 + LargeFamSupA 
                 + ( RAssMaxPossF / 14 ) * 365  
                 + NbsAnnualised ;

    * Calculate reductions from maximum rate;

    IF FtbaTestExFlag = 1 THEN FtbaMaxIncRed = 0 ;

    ELSE DO; 

	*Budget 2017-18 - Align Method 1 taper rate to 30% for income over the HIFA from 1 July 2019; 

	%IF (&Duration = A AND &Year >= 2019) 
    OR (&Duration = Q AND &Year > 2019)	
    OR(&Duration = Q AND &Year = 2019 AND (&Quarter = Sep OR &Quarter = Dec) ) 
	%THEN %DO ;

		*After 1 July 2019 apply 20% taper rate to income over income free area but below high income free area
		and 30% taper rate to income over higher income free area; 
		
		IF FtbaTestInc < FtbaBaseBasicThr THEN 
			FtbaMaxIncRed = MAX ( 0 , ( FtbaTestInc - FtbaMaxThr ) * FtbaMaxTpr); 

		ELSE IF FtbaTestInc >= FtbaBaseBasicThr THEN
			FtbaMaxIncRed = MAX ( 0 , (( FtbaTestInc - FtbaBaseBasicThr ) * FtbaBaseTpr) + (( FtbaBaseBasicThr - FtbaMaxThr ) * FtbaMaxTpr)); 

	%END; 

	%ELSE %DO ;
		
		*Prior to 1 July 2019 apply 20% taper rate to income over income free area;  

		FtbaMaxIncRed 	= MAX ( 0 , ( FtbaTestInc - FtbaMaxThr ) * FtbaMaxTpr ) ;
  
	%END; 

	END; 

	FtbaMaintIncRed   = MAX ( 0, ( FtbaIncMaintAu - FtbaMaintIncThr ) * MaintTpr ) ;

  	FtbaMaxRed = FtbaMaxIncRed + FtbaMaintIncRed ;

    * Take away reductions;

    FtbaMaxNet = MAX ( 0, FtbaMaxTotal - FtbaMaxRed ) ;

    **********************************************************************************

    * Calculate base rate. (Rent assistance is not added to the base rate per 
      Centrelink guide);

    FtbaBaseTotal = FtbaBaseStdA
                  + FtbaBaseEsA
                  + FtbaEndSupA
                  + LargeFamSupA 
                  + NbsAnnualised ;

    * Calculate base threshold and reductions from base rate;

    FtbaBaseThr = FtbaBaseBasicThr + ( DepsFtbA - 1 ) * FtbaBaseAddThr ;

	FtbaBaseRed = MAX ( 0 , ( FtbaTestInc - FtbaBaseThr ) * FtbaBaseTpr ) ;

    FtbaBaseNet = MAX( 0, FtbaBaseTotal - FtbaBaseRed ) ;

**********************************************************************************
  * Family gets higher of the two rates ;

    IF FtbaMaxNet >= FtbaBaseNet THEN DO ;

        Ftba&suffix = FtbaMaxNet ;

        IF Ftba&suffix = FtbaMaxTotal THEN FtbaType&suffix  = 'Maximum Rate' ;

        ELSE IF Ftba&suffix > 0 THEN FtbaType&suffix  = 'Part Rate' ;

        ELSE FtbaType&suffix  = '' ;

        * For usual case, where family with income below the higher income (base rate)
          threshold gets maximum rate, apportion reduction to components based on 
          the amount the maximum rate components are above the base rate components; 

        IF FtbaTestInc < FtbaBaseThr THEN DO ;
            
            PropFtbaStd     = ( FtbaMaxStdA - FtbaBaseStdA ) 
                            / ( FtbaMaxTotal - FtbaBaseTotal );

            PropFtbaEs     = ( FtbaMaxEsA - FtbaBaseEsA ) 
                            / ( FtbaMaxTotal - FtbaBaseTotal );

            PropFtbaRass = ( RAssMaxPossF / 14 * 365 )  
                            / ( FtbaMaxTotal - FtbaBaseTotal );

        * Remaining components are same in both Maximum and Base methods

        * Reduce components ;

            FtbaStd&suffix = MAX ( 0 , FtbaMaxStdA - PropFtbaStd * FtbaMaxRed ) ;
            FtbaEs&suffix = MAX ( 0 , FtbaMaxEsA - PropFtbaEs * FtbaMaxRed ) ;

            FtbaRAss&suffix = MAX ( 0 ,( RAssMaxPossF / 14 * 365 
                                          -  PropFtbaRass 
                                          * FtbaMaxRed ) ) ;

            FtbaESup&suffix = FtbaEndSupA ;
            FtbaLfs&suffix = LargeFamSupA ;
            FtbaNbs&suffix = NbsAnnualised ;
                    
        END ; * end of usual case ;

        * For special case (family gets maximum rate even if income is above the 
          higher income threshold), apply Method 2 (base rate) apportioning rules ;
    
        ELSE DO ;
        
            PropFtbaStd = FtbaMaxStdA / FtbaMaxTotal ;
            PropFtbaEs = FtbaMaxEsA / FtbaMaxTotal ;
            PropFtbaRass = ( RAssMaxPossF / 14 * 365 ) / FtbaMaxTotal ;
            PropFtbaESup = FtbaEndSupA / FtbaMaxTotal ;
            PropFtbaLfs = LargeFamSupA / FtbaMaxTotal ;
            PropFtbaNbs = NbsAnnualised / FtbaMaxTotal ;

        * Reduce components ;

            FtbaStd&suffix = MAX ( 0 , FtbaMaxStdA - PropFtbaStd * FtbaMaxRed ) ;
            FtbaEs&suffix = MAX ( 0 , FtbaMaxEsA - PropFtbaEs * FtbaMaxRed ) ;

            FtbaRAss&suffix = MAX ( 0 ,     ( RAssMaxPossF / 14 * 365 
                                            -  PropFtbaRass 
                                            * FtbaMaxRed ) ) ;

            FtbaESup&suffix = MAX ( 0 ,     ( FtbaEndSupA 
                                            -  PropFtbaESup 
                                            * FtbaMaxRed ) ) ; 
 
            FtbaLfs&suffix = MAX ( 0 ,  ( LargeFamSupA 
                                                -  PropFtbaLfs 
                                                * FtbaMaxRed ) ) ;   

            FtbaNbs&suffix  = MAX ( 0 ,     ( NbsAnnualised 
                                                - PropFtbaNbs 
                                                * FtbaMaxRed ) ) ;  
        END ; * end of special case ;

    END ;  * end of max rate higher than base rate;

       
    * Otherwise base rate paid to family ;

    ELSE DO ;

        Ftba&suffix = FtbaBaseNet ;

        IF Ftba&suffix = FtbaBaseTotal THEN FtbaType&suffix  = 'Base Rate';

        ELSE IF Ftba&suffix > 0 THEN FtbaType&suffix  = 'Taper Base Rate';

        ELSE FtbaType&suffix  = '';

        * Apportion base rate apportioning method;

        PropFtbaStd = FtbaBaseStdA / FtbaBaseTotal ;
        PropFtbaEs = FtbaBaseEsA / FtbaBaseTotal ;
        PropFtbaRass = 0 ;
        PropFtbaESup = FtbaEndSupA / FtbaBaseTotal ;
        PropFtbaLfs = LargeFamSupA / FtbaBaseTotal ;
        PropFtbaNbs = NbsAnnualised / FtbaBaseTotal ;

        * Reduce components ;

        FtbaStd&suffix = MAX ( 0 , FtbaBaseStdA - PropFtbaStd * FtbaBaseRed ) ;
        FtbaEs&suffix = MAX ( 0 , FtbaBaseEsA - PropFtbaEs * FtbaBaseRed ) ;
        FtbaRAss&suffix = 0 ;

        FtbaESup&suffix = MAX ( 0 ,  (  FtbaEndSupA 
                                      -  PropFtbaESup 
                                      * FtbaBaseRed ) ) ; 
 
        FtbaLfs&suffix  = MAX ( 0 , (  LargeFamSupA 
                                     -  PropFtbaLfs 
                                     * FtbaBaseRed ) ) ;  

        FtbaNbs&suffix  = MAX ( 0 ,  (  NbsAnnualised 
                                      - PropFtbaNbs 
                                      * FtbaBaseRed ) ) ; 
    END ;

%MEND Ftbacalc ;
**********************************************************************************
*   Macro:   FtbaFinalPay                                                        *
*   Purpose: Calculate FTB-A final payment (aggregate and component amounts)     *                               *
*********************************************************************************;;
%MACRO FtbaFinalPay ;

    FtbaFinalA = Ftba_Nbs * NbsFactor + Ftba_NoNbs * ( 1 - NbsFactor ) ;

    * Amounts by Components;

    FtbaStdA = FtbaStd_Nbs * NbsFactor + FtbaStd_NoNbs * ( 1 - NbsFactor ) ;
    FtbaEsA = FtbaEs_Nbs * NbsFactor + FtbaEs_NoNbs * ( 1 - NbsFactor ) ;

    FtbaRAssA = FtbaRAss_Nbs   *  NbsFactor 
              + FtbaRAss_NoNbs * ( 1 - NbsFactor ) ;

    FtbaEndSupA = FtbaESup_Nbs * NbsFactor + FtbaESup_NoNbs * ( 1 - NbsFactor ) ;

    FtbaLfsA    = FtbaLfs_Nbs * NbsFactor 
                + FtbaLfs_NoNbs * ( 1 - NbsFactor ) ;

    FtbaNewBornSupA = FtbaNbs_Nbs   * NbsFactor 
                    + FtbaNbs_NoNbs * ( 1 - NbsFactor ) ;

    FtbaType = FtbaType_Nbs ;
    IF FtbaType_Nbs NE FtbaType_NoNbs THEN FtbaMix = 1 ;
    
%MEND FtbaFinalPay ;
************************************************************************************
*   Macro:   Ftbbcalc                                                              *
*   Purpose: Calculate FTBB payment                                                *
************************************************************************************;;
%MACRO Ftbbcalc ;

	
    FtbbMax = FtbbStdA + FtbbEsA + FtbbSupA ;

    IF ( FtbbTestPrInc > FtbbPrimaryThr ) AND FtbbPrExFlag = 0 
       THEN FtbbRed = FtbbMax ;

    *if income is below threshold or exempt from test ;

    ELSE DO ;

        IF Coupleu = 0 THEN FtbbRed = 0 ;

        ELSE FtbbRed = MAX ( 0, ( FtbbTestSecInc - FtbbSecThr ) * FtbbSecTpr ) ;

    END;

    FtbbFinalA = MAX ( 0 , FtbbMax - FtbbRed );

    * Apportion reduction across components;

    IF FtbbRed < FtbbStdA THEN DO ;

        FtbbStdA = FtbbStdA - FtbbRed ;

        FtbbEndSupA = FtbbSupA ;

    END ;

    ELSE IF FtbbRed < ( FtbbStdA + FtbbEsA ) THEN DO ;

        FtbbEsA = ( FtbbStdA + FtbbEsA - FtbbRed ) ;

        FtbbStdA = 0 ;

        FtbbEndSupA = FtbbSupA ;

    END ;

    ELSE DO ;

        FtbbEndSupA = MAX ( 0 , FtbbStdA + FtbbEsA + FtbbSupA - FtbbRed ) ;

        FtbbEsA = 0 ;

        FtbbStdA = 0 ;

    END ;

	IF FtbbFinalA = FtbbMax THEN FtbbType = 'Maximum Rate' ;

	ELSE IF FtbbFinalA > 0 THEN FtbbType = 'Part Rate' ;

	ELSE FtbbType = '' ;

%MEND Ftbbcalc ;
************************************************************************************
*   Macro:   Baby Bonus and Newborn upfront payment                                *
*   Purpose: Calculate baby bonus or newborn upfront payment payable to Ftba       *
*            recipient.                                                            *
************************************************************************************;;
%MACRO BabyUpfrontPayment ;

    * From 1 July 2013 to 1 March 2014, higher baby bonus rate applied to first 
      child and each child in all multiple births, lower rate to subsequent 
      (non-multiple birth) children;

    %IF ( ( &Duration = A AND &Year < 2014 ) OR ( &Duration = Q AND &Year < 2014 ) 
	OR ( &Duration = Q AND &Year = 2014 AND ( &Quarter = Mar ) ) ) %THEN %DO ;	

	    IF ( AdjTaxIncAr + AdjTaxIncAs ) <= BabyBonThr THEN DO ;

	            IF TotalKidsu = Kids0Su OR Kids0Su > 1 
	                THEN BabyBonusA = BabyBon1A * Kids0Su ; 

	            ELSE IF Kids0Su = 1 THEN BabyBonusA = BabyBon2A * Kids0Su ;
	    
	    END ;

	%END ;

    /* From 1 March 2014, baby bonus replaced by NBS and newborn upfront payment, 
      which is payable if entitled to NBS */

	%ELSE %DO ;

	    IF FtbaFinalA > 0 THEN DO ;

	         NewBornUpfrontA = NewBornUpfrontRateA * Kids0Su ;

	         FtbaFinalA = FtbaFinalA + NewBornUpfrontA ; 

	    END ;

	%END ;
    
%MEND BabyUpfrontPayment ;

%RunFtb



