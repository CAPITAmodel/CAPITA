
**************************************************************************************
* Program:      5 Pensions.sas                                                       *
* Description:  Calculates entitlements to the pensions administered by the          * 
*               Department of Social Services (DSS)                                  *
**************************************************************************************;

**************************************************************************************
*   Macro:   RunPension                                                              *
*   Purpose: Coordinate pension calculation                                          *
**************************************************************************************;;

%MACRO RunPension ;

    ***********************************************************************************
    *      1.        Determine eligibility                                            *
    **********************************************************************************;

    %PenEligibility( r )

    IF Coupleu = 1 THEN DO ;  

        %PenEligibility( s )

    END ;

    ***********************************************************************************
    *      2.        Assign parameters                                                *
    **********************************************************************************;

    %PenParameters 

    ***********************************************************************************
    *      3.        Assign rent assistance                                           *
    **********************************************************************************;

    %PenRentAssistAlloc

    ***********************************************************************************
    *      4.        Calculate pension reduction amount                               *
    **********************************************************************************;

    * This macro is defined in the DVA module, as the DVA module is called before
      the Pensions module ;

	* Apply assets test and deeming version of income test to pensioners ;

    %PenReduction( IncDeemPenTestF , Y )

    ***********************************************************************************
    *      5.        Calculate pension components                                     *
    **********************************************************************************;;

    * The HarmerPensionCalc macro is defined in the DVA module, as the DVA module
      is called before the Pensions module ;

    * Calculate reference persons pension ;

    IF PenTyper = 'AGE' THEN DO ;

        %HarmerPensionCalc( Age , Pen , r )

    END ;

    ELSE IF PenTyper = 'DSP' THEN DO ;

        %HarmerPensionCalc( DSP , Pen , r )

    END ;

    ELSE IF PenTyper = 'DSPU21' THEN DO ;

        %OldPensionCalc( DSPU21 , r )

    END ;

    ELSE IF PenTyper = 'CARER' THEN DO ;

        %HarmerPensionCalc( Carer , Pen , r )

    END ;

    ELSE IF PenTyper = 'PPS' THEN DO ;

		IF AssetsExcess > 0 THEN DO; 
		
		    PenTyper = '' ;

		END; 

		ELSE DO; 
			
	        %OldPensionCalc( PPS , r )

		END; 

    END ;

    * Calculate spouse pension ;

    IF PenTypes = 'AGE' THEN DO ;

        %HarmerPensionCalc( Age , Pen , s )

    END ;

    ELSE IF PenTypes = 'DSP' THEN DO ;

        %HarmerPensionCalc( DSP , Pen , s )

    END ;

    ELSE IF PenTypes = 'DSPU21' THEN DO ;

        %OldPensionCalc( DSPU21 , s )

    END ;

    ELSE IF PenTypes = 'CARER' THEN DO ;

        %HarmerPensionCalc( Carer , Pen , s )

    END ;

    ELSE IF PenTypes = 'WIFE' THEN DO ;

        %HarmerPensionCalc( Wife , Pen , s )

    END ;

%MEND RunPension ;

**********************************************************************************
*   Macro:   PenEligibility                                                      *
*   Purpose: Flag if the person is eligible for a pension                        *
*********************************************************************************;;

%MACRO PenEligibility( psn ) ;

    * Determine if person is eligible for the Age Pension;

    IF ( ( Sex&psn = 'F' AND ActualAge&psn >= FemaleAgePenAge )    /* Female of Age Pension age */      
       OR ( Sex&psn = 'M' AND ActualAge&psn >= MaleAgePenAge   ) )  /* Male of Age Pension age */                                                  
    AND YearOfArrival&psn <= 1          /* Resident for at least 10 years*/
    AND DvaType&psn = ''                /* Not receiving a DVA Entitlement   */
    AND PenType&psn = ''                /* Not receiving another DSS Pension */  
	AND WidAllSW&psn IN	(0, .)			/* Not receiving Widow Allowance on the SIH */  
	AND DspSW&psn IN	(0, .)			/* Not receiving DSP on the SIH */  
	AND CarerPaySW&psn IN	(0, .)		/* Not receiving Carer Payment on the SIH */  

        THEN PenType&psn = 'AGE' ;

    * Determine if person is eligible for the Disability Support Pension (DSP);

    ELSE IF DspSW&psn > 0              /* Receiving the DSP on the SIH       */   
    AND ( ActualAge&psn >= 21          /* 21 years of age or over            */ 
        OR DepsSec5 > 0 )              /* Has dependent children             */
    AND DvaType&psn = ''               /* Not receiving a DVA Entitlement    */
    AND PenType&psn = ''               /* Not receiving another DSS Pension  */                            

        THEN PenType&psn = 'DSP' ;

    * Determine if person is eligible for the Disability Support Pension Under 21 (DSPU21) ;

    ELSE IF DspSW&psn > 0               /* Receiving the DSP on the SIH       */    
    AND ActualAge&psn  < 21             /* Under 21 years of age              */
    AND DvaType&psn    = ''             /* Not receiving a DVA Entitlement    */
    AND PenType&psn    = ''             /* Not receiving another DSS Pension  */                            

        THEN PenType&psn  = 'DSPU21' ;

    * Determine if person is eligible for the Carer Payment ;

    ELSE IF (CarerPaySW&psn > 0          /* Receiving Carer Payment on the SIH */   

		/* 2017-18 Budget - Working Age Payment Reforms - transition Wife Pensioners receiving Carer Allowance onto Carer Payment on 20 March 2020 */ 
		/* Not yet legislated */
		%IF (&Duration = A AND &Year >= 2020) 
		    OR (&Duration = Q AND &Year > 2020) 	
		    OR (&Duration = Q AND &Year = 2020 AND (&Quarter = Jun OR &Quarter = Sep OR &Quarter = Dec) ) 
		%THEN %DO ;

			OR 	(WifePenSW&psn > 0 
				AND CarerAllSW&psn>0)   /*Receives Carer Allowance*/

		%END;
	)

	AND DvaType&psn        = ''         /* Not receiving a DVA Entitlement    */
    AND PenType&psn        = ''         /* Not receiving another DSS Pension  */                            
    
        THEN PenType&psn  = 'CARER' ;

    %IF &psn = r %THEN %DO ;

        * Determine if person is eligible for Parenting Payment (Single) (PPS);

        IF  ParPaySW&psn 	> 0 				 /* Receiving Parenting Payment on the SIH 		   */
        AND Coupleu         = 0                  /* Person is single                               */
        AND DepsSec5        > 0                  /* Person has a dependent child                   */
        AND DvaType&psn     = ''                 /* Not receiving a DVA Entitlement                */
        AND PenType&psn     = ''                 /* Not receiving another DSS Pension              */                            

        THEN DO ;

            IF AgeYoungDepu < PpsDepAge THEN PenType&psn  = 'PPS' ;        /* Age of youngest dep is under PPS age    */
            ELSE PpGrandfatherFlag&psn = 1 ;
           
        END ;

    %END ;

    %ELSE %IF &psn = s %THEN %DO ;

		* Determine if person is eligible for Wife Pension; 
		/* 2017-18 Budget - Working Age Payment Reforms - Wife Pension will cease on Mar 2020 */
		/* Not yet legislated */

	%IF (&Duration = A AND &Year < 2020) 
	    OR (&Duration = Q AND &Year < 2020) 	
	    OR (&Duration = Q AND &Year = 2020 AND (&Quarter = Mar) ) 
	%THEN %DO ;

		    IF  WifePenSW&psn     > 0            /* Receiving Wife Pension on the SIH         */
	        AND Coupleu           = 1            /* Person is married                         */
	        AND Sex&psn           = 'F'          /* Person is female                          */
	        AND PenTyper    IN ( 'AGE' , 'DSP' ) /* Spouse is on a pension                    */
	        AND DvaType&psn       = ''           /* Not receiving a DVA Entitlement           */
	        AND PenType&psn       = ''           /* Not receiving another DSS Pension         */                            

	            THEN PenType&psn  = 'WIFE' ;

		%END;

%END ;

%MEND PenEligibility ;

**********************************************************************************
*   Macro:   PenParameters                                                       *
*   Purpose: Assigns pension payment rates (single/couple)                       *
*********************************************************************************;;

%MACRO PenParameters ;

    IF PenTyper IN ( 'AGE' , 'DSP' , 'CARER' ) 
    OR PenTypes IN ( 'AGE' , 'DSP' , 'CARER', 'WIFE' )  
    THEN DO ;  
        * Note that both members of a couple receive Harmer pension parameters
          if either of them do. If either member of a couple receives a DVA
          Service Pension then both members of the couple will have the Harmer
          Pension parameters already, as they are allocated in the DVA module. ;

        IF Coupleu = 1 THEN DO ;

            %PenParmAlloc( C ) 

        END ;   

        ELSE DO ;       

            %PenParmAlloc( S )

        END;  

    END ;

    * Code does not account for couplings between Harmer and DSPU21 pensioners ;

    ELSE IF (PenTyper = 'DSPU21' OR PenTypes = 'DSPU21') THEN DO ;   

        IF Coupleu = 1 THEN DO ; /* Allocate parameters for couples */

            %DSPU21ParmAlloc( C )

        END ;   

        ELSE DO ;   /* Allocate parameters for singles */

            %DSPU21ParmAlloc( S )

        END;    

    END ;

    ELSE IF PenTyper = 'PPS' THEN DO ;  

        %PPSParmAlloc

    END ;

%MEND PenParameters ;

**********************************************************************************
*   Macro:   DSPU21ParmAlloc                                                     *
*   Purpose: Assigns DSPU21 payment rates                                        *
*********************************************************************************;;

%MACRO DSPU21ParmAlloc( sc ) ;

    PenBasicMaxF      = DspU21PenBasicMaxSF ;
    PharmAllMaxF      = PharmAllMax&sc.F ;
    PenThrF           = DSPU21PenThr&sc.F ;
    PenTpr            = DSPU21PenTpr ;
    RAssMinRentFu     = RAssMinRent&sc.F ;
    RAssMaxFu         = RAssMax&sc.F ;

	*Cease Energy Supplement for new claimants from 20 September 2017*; 
	*Social Services Legislation Amendment (Ending Carbon Tax Compensation) Bill 2017 - not yet legislated*; 

	/*Assign Energy Supplement based on grandfathering test*/

	%IF (&Duration = A AND &Year  >= 2017 
	    OR &Duration = Q AND &Year > 2017 	
	    OR(&Duration = Q AND &Year = 2017 AND &Quarter = Dec ) )
	%THEN %DO ;

		%IF &RunEs = G %THEN %DO; 

			IF PenTyper IN ('DSPU21') THEN DO ;
				IF RandDspEsGfthr < DspEsGfthrProb THEN PenEsMaxFr = DSPU21PenEsMax&sc.F ;
				ELSE PenEsMaxFr = 0; 
			END; 

			%IF &SC = C %THEN %DO; 

				IF PenTypes IN ('DSPU21') THEN DO ;
					IF RandDspEsGfths < DspEsGfthrProb THEN PenEsMaxFs = DSPU21PenEsMax&sc.F ;
					ELSE PenEsMaxFs = 0; 
				END; 

			%END; 

		%END; 

	 	%ELSE %IF &RunEs = Y %THEN %DO; 

			PenEsMaxFr = DSPU21PenEsMax&sc.F;

				%IF &SC = C %THEN %DO; 

					PenEsMaxFs = DSPU21PenEsMax&sc.F;

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

  		PenEsMaxFr = DSPU21PenEsMax&sc.F;

			%IF &SC = C %THEN %DO; 

				PenEsMaxFs = DSPU21PenEsMax&sc.F;

			%END; 
	%END ;

	/*End*/


%MEND DSPU21ParmAlloc ;

**********************************************************************************
*   Macro:   PPSParmAlloc                                                        *
*   Purpose: Assigns Parenting Payment Single payment rates. No rent assistance  *
*            parameters are assigned here, as all PPS recipients will receive    *
*            their rent assistance through their Family Tax Benefit payments.    *
*********************************************************************************;;

%MACRO PPSParmAlloc ;

    PenBasicMaxF    = PPSPenBasicMaxF ;
    PenSupBasicMaxF = PPSSupBasicMaxF ;
    PharmAllMaxF    = PharmAllMaxSF ;               		   /* Hardcoded to take single person values */
    PenThrF         = PPSPenThrF + DepsSSTotal * PPSThrChild ; /*  Note threshold in parameter  */
                                                               /*  spreadsheet does not include */
                                                               /*  addition for first child     */
    PenTpr          = PPSPenTpr ;

	*Cease Energy Supplement for new claimants from 20 September 2017*; 
	*Social Services Legislation Amendment (Ending Carbon Tax Compensation) Bill 2017 - not yet legislated*; 

	/*Assign Energy Supplement based on grandfathering test*/
	%IF (&Duration = A AND &Year  >= 2017 
	    OR &Duration = Q AND &Year > 2017 	
	    OR(&Duration = Q AND &Year = 2017 AND &Quarter = Dec ) )
	%THEN %DO ;

		%IF &RunEs = G %THEN %DO; 

			IF PenTyper IN ('PPS') THEN DO ;
				IF RandPpsEsGfthr < PpsEsGfthrProb THEN PenEsMaxFr = PPSPenEsMaxF ;
				ELSE PenEsMaxFr = 0; 
			END; 

		%END; 

	 	%ELSE %IF &RunEs = Y %THEN %DO; 

			PenEsMaxFr = PPSPenEsMaxF ; 

		%END; 

		%ELSE %IF &RunEs = N %THEN %DO; 

			PenEsMaxFr = 0 ; 

		%END; 

	%END ;
	%ELSE %DO ;
		PenEsMaxFr = PPSPenEsMaxF ; 
	%END ;

	/*End*/

%MEND PPSParmAlloc ;

**********************************************************************************
*   Macro:   PenRentAssistAlloc                                                  *
*   Purpose: Assign Rent Assistance entitlement for income units with no children*
             (since income units with children will have rent assistance assigned*
             with Family Tax Benefit).                                           *
*********************************************************************************;;

%MACRO PenRentAssistAlloc ;
    
    IF DepsFtbA = 0 THEN DO ;  

        * Single people keep all rent assistance ;
        IF Coupleu = 0 THEN RAssMaxPossFr = RAssMaxPossF ;
          
        * Pensioner couples (including DVA recipients) share rent assistance equally ;
        ELSE IF ( PenTyper NE ('') OR DvaTyper NE ('') ) 
            AND ( PenTypes NE ('') OR DvaTypes NE ('') ) 
        THEN DO ;
            
            RAssMaxPossFr = RAssMaxPossF / 2 ;
            RAssMaxPossFs = RAssMaxPossF / 2 ;

        END ;

        * If only one member of a couple receives a pension, and the partner receives an allowance or 
          does not receive any transfers, then the pension recipient gets all the rent assistance ;
        ELSE IF PenTyper NE ('') 
            AND PenTypes = '' 
            AND DvaTypes = '' 
        THEN DO ;

            RAssMaxPossFr = RAssMaxPossF ;
            RAssMaxPossFs = 0 ;

        END ;

        ELSE IF PenTyper = '' 
            AND DvaTyper = '' 
            AND PenTypes NE ('') 
        THEN DO ;
    
            RAssMaxPossFr = 0 ;
            RAssMaxPossFs = RAssMaxPossF ;

        END ;

        ELSE IF PenTyper = '' AND DvaTyper = '' 
            AND PenTypes = '' AND DvaTypes = '' 
        THEN DO ;
    
            RAssMaxPossFr = 0 ;    
            RAssMaxPossFs = 0 ;     

        END ;
        
    END ; 

%MEND PenRentAssistAlloc ;

**********************************************************************************
*   Macro:   OldPensionCalc                                                      *
*   Purpose: Calculate Pension entitlements for DSPU21 and Parenting Payment     *
*            Single recipients.                                                  * 
*                                                                                *
*********************************************************************************;;

%MACRO OldPensionCalc( PenType , psn ) ;

    * Assign reduction amount between the different components. Person gets 
      assigned to one of the cases below, based on the total size of the reduction
      in their entitlement due to means tests. ;  
 
    *Pension components are tapered in the following order:                                     
     The basic pension, the pension supplement basic amount, Rent Assistance,     
     Energy Supplement. The Pharmaceutical Allowance is not tapered.;    

    * Person receives all components at full rate ;
    IF PenRedF = 0 THEN DO ;    

        PenBasicF&psn    = PenBasicMaxF ;
        PenSupBasicF&psn = PenSupBasicMaxF ; 
        RAssF&psn        = RAssMaxPossF&psn ;
        PenEsF&psn       = PenEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Maximum Rate' ;

    END ;

    * Basic pension only is reduced, all other components are at full rate ;
    ELSE IF PenRedF <= PenBasicMaxF THEN DO ;

        PenBasicF&psn    = PenBasicMaxF - PenRedF ;
        PenSupBasicF&psn = PenSupBasicMaxF ; 
        RAssF&psn        = RAssMaxPossF&psn ;
        PenEsF&psn       = PenEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Part Rate' ;

    END ;

    * Basic pension is zero, basic supplement is reduced, all other components are at full rate ;
    ELSE IF PenRedF <= ( PenBasicMaxF + PenSupBasicMaxF ) THEN DO ;

        PenBasicF&psn    = 0 ;
        PenSupBasicF&psn = PenBasicMaxF + PenSupBasicMaxF - PenRedF ; 
        RAssF&psn        = RAssMaxPossF&psn ;
        PenEsF&psn       = PenEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Part Rate' ;

    END ;

    * Basic pension and basic supplement are zero, rent assistance is reduced, ES and PA are at full rate ;
    ELSE IF PenRedF <= ( PenBasicMaxF    + 
                         PenSupBasicMaxF +
                         RAssMaxPossF&psn )
            THEN DO ;

        PenBasicF&psn    = 0 ;
        PenSupBasicF&psn = 0 ; 
        RAssF&psn        = PenBasicMaxF     +
                           PenSupBasicMaxF  +
                           RAssMaxPossF&psn -
                           PenRedF          ;
        PenEsF&psn       = PenEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Part Rate' ;
    END ;

    * Basic pension, basic supplement, and rent assistance are zero, ES is reduced, PA is at full rate ;
    ELSE IF PenRedF <= (  PenBasicMaxF     +
                          PenSupBasicMaxF  +
                          RAssMaxPossF&psn +
                          PenEsMaxF&psn ) 
    THEN DO ;

        PenBasicF&psn    = 0 ;
        PenSupBasicF&psn = 0 ; 
        RAssF&psn        = 0 ;
        PenEsF&psn       = PenBasicMaxF     +
                           PenSupBasicMaxF  +
                           RAssMaxPossF&psn +
                           PenEsMaxF&psn       -
                           PenRedF          ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Part Rate' ;

    END ;

    * Basic pension, basic supplement, rent assistance and ES are all zero, PA is at full rate ;
    ELSE IF PenRedF <= (  PenBasicMaxF     +
                          PenSupBasicMaxF  +
                          RAssMaxPossF&psn +
                          PenEsMaxF&psn        +
                          PharmAllMaxF ) 
    THEN DO ;

        PenBasicF&psn    = 0 ;
        PenSupBasicF&psn = 0 ; 
        RAssF&psn        = 0 ;
        PenEsF&psn       = 0 ;
        PharmAllF&psn    = PharmAllMaxF ;
        PenRateType&psn  = 'Part Rate' ;

    END ;

  * Initialisation of variables has already set components to zero if pension 
    reduction is larger ;
  * Remove PenType flag if person does not qualify for a positive amount ;

    ELSE PenType&psn = '' ;
    
  * This section identifies which pension is being paid and calculates some 
    summary variables ;

    PenTotF&psn = PenBasicF&psn    +
                  PenSupBasicF&psn +
                  RAssF&psn        + 
                  PharmAllF&psn    +
                  PenEsF&psn      ;

    PenTotA&psn = PenTotF&psn * 26 ;

    * Assign generic amounts to pension-specific variables ;

    &PenType.PenBasicF&psn    = PenBasicF&psn ;
    &PenType.PenSupBasicF&psn = PenSupBasicF&psn ;
    &PenType.RAssF&psn        = RAssF&psn ;
    &PenType.PharmAllF&psn    = PharmAllF&psn ;
    &PenType.PenEsF&psn       = PenEsF&psn ;
    &PenType.TotF&psn         = PenTotF&psn ;

    &PenType.PenBasicA&psn    = &PenType.PenBasicF&psn * 26 ;
    &PenType.PenSupBasicA&psn = &PenType.PenSupBasicF&psn * 26 ;
    &PenType.RAssA&psn        = &PenType.RAssF&psn * 26 ;
    &PenType.PharmAllA&psn    = &PenType.PharmAllF&psn * 26 ;
    &PenType.PenEsA&psn       = &PenType.PenEsF&psn * 26 ;
    &PenType.TotA&psn         = &PenType.TotF&psn * 26 ;

%MEND OldPensionCalc ;

* Call %RunPension ;
%RunPension
