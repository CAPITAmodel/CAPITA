
**************************************************************************************
* Program:      4 DVA.sas                                                            *
* Description:  Calculates entitlements to the payments administered by the          * 
*               Department of Veterens' Affairs (DVA).                               *
**************************************************************************************;

* Allows the use of the IN operator inside macros. ;
OPTIONS MINOPERATOR ; 

***********************************************************************************
*   Macro:   RunDva                                                               *
*   Purpose: Coordinate DVA entitlement calculation                               *
**********************************************************************************;;
%MACRO RunDva ;

	***********************************************************************************
	*      1.        Determine eligibility                                            *
	**********************************************************************************;
    
	* Determine eligibility for the DVA payments which are not modelled in CAPITA ;

    %DvaNotMod( r ) 

    IF Coupleu = 1 THEN DO ;

        %DvaNotMod ( s ) 

    END ;

	* Determine eligibility for DVA Service Pension, and flag receipt of both the Service
	  Pension and the Disability Pension ; 

    %DvaServPenEligibility( r , s )

    IF Coupleu = 1 THEN DO ;   * Only check eligibility for person s in couples ;

        %DvaServPenEligibility( s , r )

    END ;

	***********************************************************************************
	*      2.        Assign parameters                                                *
	**********************************************************************************;
    %DvaParameters 

	***********************************************************************************
	*      3.        Calculate maximum rent assistance                                *
	**********************************************************************************;
    %RentAssistMaxRate 

	***********************************************************************************
	*      4.        Assign rent assistance                                           *
	**********************************************************************************;
	%DvaRentAssistAlloc

	***********************************************************************************
	*      5.        Calculate Pension reduction amount                               *
	**********************************************************************************;
	%PenReduction( IncDeemDvaTestF , Y )

	***********************************************************************************
	*      6.        Calculate DVA components                                         *
	**********************************************************************************;

    * Calculate reference DVA Service Pension outcome ;
    IF DvaTyper IN ('SERVICE', 'DVASERVDIS') THEN DO ;

        %HarmerPensionCalc( Service , Dva , r )

    END ;

    * Calculate spouse DVA Service Pension outcome ;
    IF DvaTypes IN ('SERVICE', 'DVASERVDIS') THEN DO ;

        %HarmerPensionCalc( Service , Dva , s )

    END ;

	***********************************************************************************
	* 		7. 		Aggregate DVA payments											  *
	**********************************************************************************; 
	%DVAAggregates (r)
	%DVAAggregates (s)

%MEND RunDva ;

**********************************************************************************
*   Macro:   DvaNotMod                                                           *
*   Purpose: Flag if the person is eligible for the DVA payments which are not   *
             modelled in CAPITA but which are uprated                            *
*********************************************************************************;;
%MACRO DvaNotMod( psn ) ;

    * Flag receipt on the SIH for the DVA Disability Pension;

    IF DvaDisPenSW&psn > 0 THEN DO ;
        DvaType&psn = 'DVADIS' ;
        DvaDisPenNmF&psn = DvaDisPenSW&psn * 2 ;
        DvaDisPenNmA&psn = DvaDisPenSW&psn * 52 ;
    END ;

    * Flag receipt on the SIH for the DVA War Widow Pension;

    IF DvaWwPenSW&psn > 0 THEN DO ;
        DvaType&psn = 'WARWID' ;
        DvaWwPenNmF&psn = DvaWwPenSW&psn * 2 ;
        DvaWwPenNmA&psn = DvaWwPenSW&psn * 52 ;
    END ;

%MEND DvaNotMod ;

**********************************************************************************
*   Macro:   DvaServPenEligibility                                               *
*   Purpose: Flag if the person is eligible for the DVA Service Pension          *
*********************************************************************************;;
%MACRO DvaServPenEligibility( psn , spouse ) ;

    *Determine if person is eligible for the DVA Service Pension;

    IF  DvaSPenSW&Psn > 0     OR   /* Receiving DVA Service Pension on SIH */
      ( DvaSPenSW&spouse > 0  AND  /* Partner receiving DVA Service Pension*/
        AgePenSW&Psn = 0 )         /* Does not receive Age Pension on SIH  */

        THEN DO ;

            IF DvaType&Psn = 'DVADIS' THEN DvaType&Psn = 'DVASERVDIS' ;

            ELSE DvaType&Psn = 'SERVICE' ;

        END ;

%MEND DvaServPenEligibility ;

**********************************************************************************
*   Macro:   DvaParameters                                                       *
*   Purpose: Assigns Pension payment rates (single/couple)                      *
*********************************************************************************;;
%MACRO DvaParameters ;

   * If either of the members of a couple get DVA Service Pension then both members
       will get the parameters ;
     
       IF DvaTyper IN ('SERVICE', 'DVASERVDIS') OR
          DvaTypes IN ('SERVICE', 'DVASERVDIS') THEN DO ;

	        IF Coupleu = 1 THEN DO ;

	            %PenParmAlloc( C )

	        END ;

	        ELSE DO ;

	            %PenParmAlloc( S )

	        END ; 

    END ;

%MEND DvaParameters ;

**********************************************************************************
*   Macro:   PenParmAlloc                                                        *
*   Purpose: Assigns Pension payment rates (single/couple)                      *
*********************************************************************************;;;

%MACRO PenParmAlloc( sc ) ;

    PenBasicMaxF     = PenBasicMax&sc.F ;
    PenSupBasicMaxF  = PenSupBasicMax&sc.F ;
    PenSupRemMaxF    = PenSupRemMax&sc.F ;
    PenSupMinMaxF    = PenSupMinMax&sc.F ;
    PenThrF          = PenThr&sc.F ;
    PenTpr           = HarmerPenTpr ;

*Cease Energy Supplement for new claimants from 20 September 2017*; 
*Social Services Legislation Amendment (Ending Carbon Tax Compensation) Bill 2017 - not yet legislated*; 
	%IF (&Duration = A AND &Year  >= 2017 
	    OR &Duration = Q AND &Year > 2017 	
	    OR(&Duration = Q AND &Year = 2017 AND &Quarter = Dec ) )
	%THEN %DO ;

	/*Assign Energy Supplement based on grandfathering test*/
		%IF &RunEs = G %THEN %DO; 

			IF	PenTyper IN ('AGE') OR DvaTyper IN ('SERVICE') THEN DO ;
				IF RandAgeEsGfthr < AgeEsGfthrProb THEN PenEsMaxFr = PenEsMax&sc.F ;
				ELSE PenEsMaxFr = 0; 
			END; 

			%IF &SC = C %THEN %DO; 

			IF	PenTypes IN ('AGE') OR DvaTypes IN ('SERVICE') THEN DO ;
				IF RandAgeEsGfths < AgeEsGfthrProb THEN PenEsMaxFs = PenEsMax&sc.F ;
				ELSE PenEsMaxFs = 0; 
			END; 

			%END; 

			IF PenTyper IN ('DSP') OR DvaTyper IN ('DVASERVDIS') THEN DO ;
				IF RandDspEsGfthr < DspEsGfthrProb THEN PenEsMaxFr = PenEsMax&sc.F ;
				ELSE PenEsMaxFr = 0; 
			END; 

			%IF &SC = C %THEN %DO; 

			IF PenTypes IN ('DSP') OR DvaTypes IN ('DVASERVDIS') THEN DO ;
				IF RandDspEsGfths < DspEsGfthrProb THEN PenEsMaxFs = PenEsMax&sc.F ;
				ELSE PenEsMaxFs = 0; 
			END; 

			%END; 

			IF PenTyper IN ('CARER') THEN DO ;
				IF RandCarerEsGfthr < CarerEsGfthrProb THEN PenEsMaxFr = PenEsMax&sc.F ;
				ELSE PenEsMaxFr = 0; 
			END; 
			
			%IF &SC = C %THEN %DO; 

			IF PenTypes IN ('CARER') THEN DO ;
				IF RandCarerEsGfths < CarerEsGfthrProb THEN PenEsMaxFs = PenEsMax&sc.F ;
				ELSE PenEsMaxFs = 0; 
			END; 

			%END; 
			
			%IF &SC = C %THEN %DO; 

			IF PenTypes IN ('WIFE') THEN DO ;
				IF RandWifeEsGfths < WifeEsGfthrProb THEN PenEsMaxFs = PenEsMax&sc.F ;
				ELSE PenEsMaxFs = 0; 
			END;

			%END; 

		%END; 

		%ELSE %IF &RunEs = Y %THEN %DO;

			PenEsMaxFr = PenEsMax&sc.F ;

				%IF &SC = C %THEN %DO; 

					PenEsMaxFs = PenEsMax&sc.F ;

				%END; 

		%END; 

	 	%ELSE %IF &RunEs = N %THEN %DO;

	 		PenEsMaxFr = 0;

				%IF &SC = C %THEN %DO; 

					PenEsMaxFs = 0;

				%END; 

		%END; 
	%END ;

	%ELSE %DO ;

  		PenEsMaxFr = PenEsMax&sc.F ;

		%IF &SC = C %THEN %DO; 
			PenEsMaxFs = PenEsMax&sc.F ;
		%END; 
	%END ;

%MEND PenParmAlloc ;

**********************************************************************************
*   Macro:   RentAssistMaxRate                                                   *
*   Purpose: Calculate Rent Assistance entitlement - non-families                *
*********************************************************************************;;
%MACRO RentAssistMaxRate ;

    * Assign Parameters for Rent Assistance ; 
    IF DepsFtba = 0 THEN DO ;  

        IF Coupleu = 1 THEN DO ; * Couples ;

            RAssMinRentFu     = RAssMinRentCF ;
            RAssMaxFu         = RAssMaxCF ;

        END ;

        ELSE DO ; * Singles ;

            RAssMinRentFu     = RAssMinRentSF ;
            RAssMaxFu         = RAssMaxSF ;

            * SSA 1991 s1070L(2), s1070M(2) and 1070Q(2) states that a single who  
              is sharing rental accommodation and is not receiving DSPU21 can only 
              receive two-thirds of the single maximum rent assistance amount. ;
            IF SharerFlagu = 1 THEN DO ;

                RAssMaxFu = RAssMaxFu * 2/3 ;

            END ;
        END ;

    END ;
   
    IF ( Renteru = 1 ) AND ( RentPaidFu > RAssMinRentFu ) THEN DO;
          
        RAssMaxPossF =  ( RentPaidFu - RAssMinRentFu ) * RAssCoPayProp ; 

        * Apply rent assistance limits ;
        RAssMaxPossF = MIN( RAssMaxPossF , RAssMaxFu ) ;

    END;

    ELSE RAssMaxPossF = 0 ;

%MEND RentAssistMaxRate ;

**********************************************************************************
*   Macro:   DvaRentAssistAlloc                                                  *
*   Purpose: Assign Rent Assistance entitlement - non-families                   *
*********************************************************************************;;
%MACRO DvaRentAssistAlloc ;

    * Only couples who have at least one member receiving DVA Service Pension get 
      Rent Assistance. ; 
    IF DvaTyper = 'SERVICE' OR DvaTypes = 'SERVICE' THEN DO ;

      * families with children have RA assigned with FTBA ;
        IF DepsFtbA = 0 THEN DO ;   
          * single people keep all RA ;
            IF Coupleu = 0 THEN DO ;

                RAssMaxPossFr = RAssMaxPossF ;

            END ;
          * Couples with at least one DVA entitlement recipient share RA equally ;
            ELSE IF Coupleu = 1 THEN DO ;
        
              * Assume that if at least one member of a couple is receiving a DVA 
                entitlement then both members of a couple are receiving either a
                DVA or DSS Pension. Hence we assign both members half the rent
                assistance allocation. ;  
                RAssMaxPossFr = RAssMaxPossF / 2 ;
                RAssMaxPossFs = RAssMaxPossF / 2 ;

            END ;

            ELSE PUT "ERROR: Check DVARentAssistAlloc macro for observation " _N_ ;
        
        END ; * no children income units ;

    END ; * someone receives DVA Service Pension ;

%MEND DvaRentAssistAlloc ;

**********************************************************************************
*   Macro:   PenReduction                                                        *
*   Purpose: Calculate reduction amount for Pension                              *
*           (Income and pension assets tests)                                    *
*********************************************************************************;;

%MACRO PenReduction( OrdIncome, UseAssetTest ) ;

	* Assign assets test thresholds ;
	IF Coupleu = 0 AND Occupancyu <= 2 THEN PenAssThr = PenAssThrHoS ;
	ELSE IF Coupleu = 0 AND Occupancyu > 2 THEN PenAssThr = PenAssThrNhoS ;
	ELSE IF Coupleu = 1 AND Occupancyu <= 2 THEN PenAssThr = PenAssThrHoC ;
	ElSE IF Coupleu = 1 AND Occupancyu > 2 THEN PenAssThr = PenAssThrNhoC ;
	
	* Calculate assets in excess of the threshold, and apply rounding factor ;
	AssetsExcess = AssetsPenTest - PenAssThr ;
	AssetsExcess = FLOOR(AssetsExcess / PenAssRnding) * PenAssRnding ;

  * Calculate dollar amount pension is reduced by for each person under income and assets
    test. ;
	PenRedIncTest = ( &OrdIncome - PenThrF ) * PenTpr ;
	PenRedAssetTest = AssetsExcess * PenAssTpr ;

  * Apply assets test if specified in call (Y/N) ;
	%IF &UseAssetTest = Y %THEN %DO ;

    	PenRedF = MAX( 0 , PenRedIncTest , PenRedAssetTest ) ;
	
		* Flag representing whether income or assets test is used ;
		IF PenRedF = 0 THEN PenTestFlag = "None" ;
		ELSE IF PenRedF = PenRedIncTest THEN PenTestFlag = "Income" ;
		ELSE IF PenRedF = PenRedAssetTest THEN PenTestFlag = "Assets" ;

	%END ;

	%ELSE %IF &UseAssetTest = N %THEN %DO ;

		PenRedF = MAX( 0 , PenRedIncTest ) ;
		
		* Flag representing whether income or assets test is used ;
		IF PenRedF = 0 THEN PenTestFlag = "None" ;
		ELSE PenTestFlag = "Income" ;

	%END ;

%MEND PenReduction ;

**********************************************************************************
*   Macro:   HarmerPensionCalc                                                   *
*   Purpose: Calculate Pension entitlements for Harmer Pensions including        *
*            supplements for pensions.  This includes Age Pension, DSP, Wife     *
*            Pension and Carer Payment.                                          *
*********************************************************************************;;

%MACRO HarmerPensionCalc( Name , Type , Psn ) ;
 
  * Assign reduction amount between the different components. Person gets assigned 
	to one of the cases below, based on the total size of the reduction in their 
	entitlement due to means tests. ;    	
  * Pension components are withdrawn in the following order:                 
    the basic pension, the pension supplement basic amount, the remaining        
    amount, Rent Assistance, the minimum amount, and the energy supplement.      
    The minimum amount and energy supplement are not tapered. ;  

  * Person receives everything at full rate ;
    IF PenRedF = 0 THEN DO ;    

        PenBasicF&Psn    = PenBasicMaxF ;
        PenSupBasicF&Psn = PenSupBasicMaxF ; 
        PenSupRemF&Psn   = PenSupRemMaxF ;
        RAssF&Psn        = RAssMaxPossF&Psn ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn      = PenEsMaxF&Psn ;
        PenRateType&Psn   = 'Maximum Rate' ;

    END ;

  * Basic pension only is reduced ;
    ELSE IF PenRedF <= PenBasicMaxF THEN DO ;

        PenBasicF&Psn    = PenBasicMaxF - PenRedF ;
        PenSupBasicF&Psn = PenSupBasicMaxF ; 
        PenSupRemF&Psn   = PenSupRemMaxF ;
        RAssF&Psn        = RAssMaxPossF&Psn ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn      = PenEsMaxF&Psn ;
        PenRateType&Psn   = 'Part Rate' ;

    END ;

  * Basic pension 0, basic supplement reduced ;
    ELSE IF PenRedF <= ( PenBasicMaxF + PenSupBasicMaxF ) THEN DO ;

        PenBasicF&Psn    = 0 ;
        PenSupBasicF&Psn = PenBasicMaxF + PenSupBasicMaxF - PenRedF ; 
        PenSupRemF&Psn   = PenSupRemMaxF ;
        RAssF&Psn        = RAssMaxPossF&Psn ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn      = PenEsMaxF&Psn ;
        PenRateType&Psn   = 'Part Rate' ;

    END ;

  * Basic pension and basic supplement 0, remaining supplement reduced ;
    ELSE IF PenRedF <=  ( PenBasicMaxF    + 
                          PenSupBasicMaxF + 
                          PenSupRemMaxF ) 
            THEN DO ;

        PenBasicF&Psn    = 0 ;
        PenSupBasicF&Psn = 0 ; 
        PenSupRemF&Psn   = PenBasicMaxF    + 
                           PenSupBasicMaxF + 
                           PenSupRemMaxF   - 
                           PenRedF   ;
        RAssF&Psn        = RAssMaxPossF&Psn ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn       = PenEsMaxF&Psn ;
        PenRateType&Psn  = 'Part Rate' ;

    END ;

  * Basic pension, basic and remaining supplement 0, rent assistance reduced ;
    ELSE IF PenRedF <= ( PenBasicMaxF    + 
                         PenSupBasicMaxF +
                         PenSupRemMaxF   +
                         RAssMaxPossF&Psn )
            THEN DO ;

        PenBasicF&Psn    = 0 ;
        PenSupBasicF&Psn = 0 ; 
        PenSupRemF&Psn   = 0 ;
        RAssF&Psn        = PenBasicMaxF     +
                           PenSupBasicMaxF  +
                           PenSupRemMaxF    +
                           RAssMaxPossF&Psn -
                           PenRedF          ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn      = PenEsMaxF&Psn ;
        PenRateType&Psn   = 'Part Rate' ;

    END ;

  * Basic pension, basic and remaining supplement, and rent assistance 0, minimum
    supplement and ES paid ;
    ELSE IF PenRedF <= (  PenBasicMaxF     +
                          PenSupBasicMaxF  +
                          PenSupRemMaxF    +
                          RAssMaxPossF&Psn +
                          PenSupMinMaxF    +
                          PenEsMaxF&Psn ) 
            THEN DO ;

        PenBasicF&Psn    = 0 ;
        PenSupBasicF&Psn = 0 ; 
        PenSupRemF&Psn   = 0 ;
        RAssF&Psn        = 0 ;
        PenSupMinF&Psn   = PenSupMinMaxF ;
        PenEsF&Psn      = PenEsMaxF&Psn ;
        PenRateType&Psn   = 'Part Rate' ;

    END ;

    * Initialisation of variables has already set components to zero if pension 
      reduction is larger. Remove PenType or DvaType flag if person does not qualify 
      for a positive amount ;
    ELSE &Type.Type&Psn = '' ; 

    * This section identifies which pension is being paid and calculates some 
      summary variables ;
    &Type.TotF&Psn = PenBasicF&Psn    
                   + PenSupBasicF&Psn 
                   + PenSupRemF&Psn   
                   + RAssF&Psn        
                   + PenSupMinF&Psn   
                   + PenEsF&Psn ;

    &Type.TotA&Psn = &Type.TotF&Psn * 26 ;

    * Assign generic amounts to payment-specific variables ;

    &Name.PenBasicF&Psn    = PenBasicF&Psn ;
    &Name.PenSupBasicF&Psn = PenSupBasicF&Psn ;
    &Name.PenSupRemF&Psn   = PenSupRemF&Psn ;
    &Name.RAssF&Psn        = RAssF&Psn ;
    &Name.PenSupMinF&Psn   = PenSupMinF&Psn ;
    &Name.PenEsF&Psn       = PenEsF&Psn ;
    &Name.TotF&Psn         = &Type.TotF&Psn ;

    &Name.PenBasicA&Psn    = &Name.PenBasicF&Psn * 26 ;
    &Name.PenSupBasicA&Psn = &Name.PenSupBasicF&Psn * 26 ;
    &Name.PenSupRemA&Psn   = &Name.PenSupRemF&Psn * 26 ;
    &Name.RAssA&Psn        = &Name.RAssF&Psn * 26 ;
    &Name.PenSupMinA&Psn   = &Name.PenSupMinF&Psn * 26 ;
    &Name.PenEsA&Psn       = &Name.PenEsF&Psn * 26 ;
    &Name.TotA&Psn         = &Name.TotF&Psn * 26 ;

%MEND HarmerPensionCalc ;

**********************************************************************************
*   Macro:   DVAAggregates                                              		 *
*   Purpose: Determine the aggregate amount of DVA that each individual  		 *
*            receives, including payments uprated but not modelled.              *
*********************************************************************************;
%MACRO DVAAggregates( psn ) ;

    DVATotF&psn = DVATotF&psn      
                + DvaDisPenNmF&psn      
                + DvaWwPenNmF&psn    
               	;

    DVATotA&psn = DVATotF&psn * 26 ;

%MEND DVAAggregates ;


* Now call all the code ;

%RunDva


