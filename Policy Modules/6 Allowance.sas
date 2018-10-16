
**************************************************************************************
* Program:      6 Allowance.sas                                                      *
* Description:  Calculates entitlements to the allowances administered by the        * 
*               Department of Social Services (DSS)                                  *
*************************************************************************************;

* Allows the use of the IN operator inside macros. ;
OPTIONS MINOPERATOR ; 

***********************************************************************************
*   Macro:   RunAllowance                                                         *
*   Purpose: Coordinate allowance calculation                                     *
**********************************************************************************;;
%MACRO RunAllowance ;

    ***********************************************************************************
    *      1.        Determine eligibility                                            *
    **********************************************************************************;

    * Determine eligibility for the allowances which are not modelled in CAPITA ;

    %AllowNotMod( r ) 

    IF Coupleu = 1 THEN DO ;

        %AllowNotMod ( s ) 

    END ;

    * Determine eligibility for the allowances which are modelled in CAPITA ;

    %AllowEligibility( r , s )

    %YaEligibility( r , Coupleu , DepsSec5 , TestReceiptSih )     

    IF Coupleu = 1 THEN DO ;   * Only check for eligibility for person s in couples ;

        %AllowEligibility( s , r )

        %YaEligibility( s , 1 , DepsSec5 , TestReceiptSih )

    END ;

    ***********************************************************************************
    *      2.        Assign parameters                                                *
    **********************************************************************************;

    %AllowParameters( r )

    IF Coupleu = 1 THEN DO ; * only assign spouse parameters if person r in a couple ;

        %AllowParameters( s )

    End ; 

    ***********************************************************************************
    *      3.        Calculate rent assistance maximum rates                          *
    **********************************************************************************;
    * This macro is in the DVA module as this is where it is called for all 
      observations in CAPITA. ;

    ***********************************************************************************
    *      4.        Assign rent assistance                                           *
    **********************************************************************************;
    IF Renteru = 1 THEN DO ;

        %AllowRentAssistAlloc

    END ;
    ***********************************************************************************
    *      5.        Parental Income Test and Maintenance Income Test                 *
    **********************************************************************************;

    * Collects family level information for YA parental income test purposes across all income units in a family. 
      Record that information against all income units. Information collected includes parental income excess,
      and the youth allowance pool. ;

    IF FIRST.FamID = 1 THEN DO ;
    
        %YaParIncTestFam

    END ;

    * Calculates parental income test result for dependants 1-4 or in own income unit ;
    IF FIRST.FamID = 1 THEN DO ;        /* Dependants 1-4 */

        %DO i = 1 %TO 4 ;

            %YaParIncTestRes( &i )

        %END ;

    END ;

    ELSE DO ;                           /* Own income unit dependants */

        %YaParIncTestRes( r )

    END ;

    * New maintenance income test introduced from 1 January 2017. Assume start from 1 July 2017 ;
    * Calculate maintenance income test result. ;
        
    %IF &Year >= 2017 %THEN %DO ;

        /* Calculates maintenance income test result for dependants 1 - 4 in parental income unit. */
        IF FIRST.FamID = 1 THEN DO ;

            %DO i = 1 %TO 4 ;

                %YaMaintIncTestRes( &i )

            %END ;

        END ;

        /* Calculates maintenance income test result for dependants in own income unit. */
        ELSE DO ;

            %YaMaintIncTestRes( r )

        END ;

        /* Calculate the maintenance income test (MIT) reducible amount for the parental test reduction. */
        MaintRedAmtA = FtbaMaxRateAge13_19Stud - FtbaBaseRateA ;

    %END ;

    * Calculate the reduction for parental income for dependants 1 - 4 in parental income unit, 
      or those in own income unit. Taking into account the parental income test result and 
      the maintenance income test result ;
    IF FIRST.FamID = 1 THEN DO ;

        %DO i = 1 %TO 4 ;

            %YaParTestRed( &i )

        %END ;

    END ;

    ELSE IF FIRST.FamID = 0 THEN DO ;

        %YaParTestRed( r )

    END ;

    ***********************************************************************************
    *      6.        Calculate allowance reduction amount for ref and sps             *
    **********************************************************************************;
    * Calculates the allowance reduction from the personal, partner and parental income tests where appropriate ;

    %AllowReduction 

    ***********************************************************************************
    *      7.        Calculate allowance components                                   *
    **********************************************************************************;

    * Calculate reference allowance ;
    IF AllowTyper = 'PPP' THEN DO ;

        %AllowCalc( Ppp , r )

    END ;

    ELSE IF AllowTyper = 'NSA' THEN DO ;

        %AllowCalc( Nsa , r )

    END ;

    ELSE IF AllowTyper = 'YAOTHER' THEN DO ;

        %AllowCalc( YaOther , r )

    END ;

    ELSE IF AllowTyper = 'YASTUD' THEN DO ;

        %AllowCalc( YaStud , r )

    END ;

    ELSE IF AllowTyper = 'AUSTUDY' THEN DO ;

        %AllowCalc( Austudy , r )

    END ;

    ELSE IF AllowTyper = 'WIDOW' THEN DO ;

        %AllowCalc( Widow , r )

    END ;

    * Calculate spouse allowance ;
    IF AllowTypes = 'PPP' THEN DO ;

        %AllowCalc( Ppp , s )

    END ;

	* Newstart Allowance will be known as JobSeeker Payment after 20 March 2020; 
    ELSE IF AllowTypes = 'NSA' THEN DO ;

        %AllowCalc( Nsa , s )

    END ;

    ELSE IF AllowTypes = 'YAOTHER' THEN DO ;

        %AllowCalc( YaOther , s )

    END ;

    ELSE IF AllowTypes = 'YASTUD' THEN DO ;

        %AllowCalc( YaStud , s )

    END ;

    ELSE IF AllowTypes = 'AUSTUDY' THEN DO ;

        %AllowCalc( Austudy , s )

    END ;

    ***********************************************************************************
    *      8.        Determine outcomes for students 1 to 4 (if they exist)           *
    **********************************************************************************;
    
    %DO i = 1 %TO 4 ;

        IF ActualAge&i > 0 THEN DO ; 

            %DepAllowCalc( &i )

        END ;

    %END ;

%MEND RunAllowance ;

**********************************************************************************
*   Macro:   AllowNotMod                                                         *
*   Purpose: Flag if the person is eligible for allowances which are not         *
             modelled in CAPITA but which are uprated                            *
*********************************************************************************;;

%MACRO AllowNotMod( Psn ) ;

    * Flag receipt on the SIH for the Special Benefit ;

    IF SpbSW&Psn > 0 THEN DO ;
        AllowType&Psn = 'SPB' ;

		*Use uprated payment from the SIH; 
        SpbAllNmF&psn = SpbSW&Psn * 2 ;
        SpbAllNmA&psn = SpbSW&Psn * 52 ;
		
		*Create allowance summary variable; 
		AllTotF&psn = SpbAllNmF&psn;
		AllTotA&psn = SpbAllNmA&psn;	

END ;

    * Flag receipt on the SIH for the Sickness Allowance ;
	* 2017-18 Budget - Working Age Payment Reforms - Sickness Allowance recipients will transition to Newstart Allowance/JobSeeker Payment on March 2020;

%IF (&Duration = A AND &Year < 2020) 
    OR (&Duration = Q AND &Year < 2020) 	
    OR (&Duration = Q AND &Year = 2020 AND (&Quarter = Mar) ) 
%THEN %DO ;

    IF SickAllSW&psn > 0 THEN DO ;
        AllowType&psn = 'SICK' ;

		*Use uprated payment from the SIH;
        SickAllNmF&psn = SickAllSW&psn * 2 ;
        SickAllNmA&psn = SickAllSW&psn * 52 ;

		*Create allowance summary variable; 
		AllTotF&psn = SickAllNmF&psn;
		AllTotA&psn = SickAllNmA&psn;	
    END ;

%END; 

    * Flag receipt on the SIH for the Partner Allowance ;
	* 2017-18 Budget - Working Age Payment Reforms - Partner Allowance will cease on 1 January 2022;

%IF (&Duration= A AND &Year < 2022) 
	OR (&Duration = Q AND &Year < 2022) 
%THEN %DO ;

    IF PartAllSW&Psn > 0 THEN DO ;
        AllowType&Psn = 'PARTNER' ;

		*Use uprated payment from the SIH;
        PartnerAllNmF&psn = PartAllSW&psn * 2 ;
        PartnerAllNmA&psn = PartAllSW&psn * 52 ;

		*Create allowance summary variable; 
		AllTotF&psn = PartnerAllNmF&psn;
		AllTotA&psn = PartnerAllNmA&psn;

    END ;

%END; 

    * Flag Austudy receipt on the SIH as Abstudy if the person is too young to 
     receive Austudy ;

    IF AustudySW&psn > 0 
    AND ActualAge&psn < YaStudAgeUpr
    THEN DO ; 
        AllowType&psn = 'ABSTUDY' ;

		*Use uprated payment from the SIH;
        AbstudyNmF&psn = AustudySW&psn * 2 ;
        AbstudyNmA&psn = AustudySW&psn * 52 ;
		
		*Create allowance summary variable; 
		AllTotF&psn = AbstudyNmF&psn;
		AllTotA&psn = AbstudyNmA&psn;
    END ;

%MEND AllowNotMod ;

**********************************************************************************
*   Macro:   AllowEligibility                                                    *
*   Purpose: Flag if the person is eligible for an Allowance other than Youth    *
*            Allowance                                                           *
*********************************************************************************;;

%MACRO AllowEligibility( psn , partner ) ;
    
    * Determine if person is eligible for AUSTUDY ;
    IF AustudySW&psn  > 0					/* Receiving Austudy or NSA on SIH */   
       AND YaStudAgeUpr    <= ActualAge&psn /* Person of right age              */
       AND StudyType&psn   IN ( 'FTNS' )    /* Full-time tertiary student       */ 
       AND DvaType&psn     = ''             /* Not receiving DVA Entitlement    */
       AND PenType&psn     = ''             /* Not receiving DSS Pension        */                            
       AND AllowType&psn   = ''             /* Not receiving other DSS allowance*/ 
    THEN DO ;

        AllowType&psn = 'AUSTUDY' ;
      * If an Austudy recipient is single, a broader definition for dependent 
        children is used which includes YA children. SSA 1991 1067-B2(1). ;
        IF Coupleu = 1 THEN DO;

            %YaAusType( &psn , Coupleu , DepsSec5 )

        END ;

        ELSE DO ;

            %YaAusType( &psn , Coupleu , DepsSSTotal )

        END ;

    END ;
    
    * Determine if person is eligible for Parenting Payment Partnered ;
    ELSE IF ( ParPaySW&psn > 0 OR NsaSW&psn > 0 )             	  /* Receiving Parenting Payment or NSA on SIH (accounts for transitions between NSA and PPP) */ 
        %IF &psn = r %THEN %DO ;                                /* PPP to lowest income earner in a couple   */            
            AND IncOrdFr < IncOrdFs            
        %END ; 
		%ELSE %IF &psn = s %THEN %DO ;            
            AND IncOrdFs <= IncOrdFr
		%END ;
        AND Coupleu         = 1                                   /* Person in a couple                        */
        AND DepsSec5        > 0                                   /* Person has a dependent child              */
        AND DvaType&psn     = ''                                  /* Not receiving DVA Entitlement             */
        AND PenType&psn     = ''                                  /* Not receiving DSS Pension                 */                            
        AND AllowType&psn   = ''                                  /* Not receiving other DSS allowance         */ 

    THEN DO ;
        IF AgeYoungDepu < PppDepAge THEN DO ;
            AllowType&psn = 'PPP' ;      /* Age of youngest dependant is under PPP age */
            AllowSubType&psn = 'COUP' ;
	    END ;
        ELSE DO ;
            AllowType&psn = 'NSA' ;
            AllowSubType&psn = 'COUP' ;
	    END ;
          
    END ;

    * Determine if person is eligible for the Newstart Allowance (or JobSeeker Payment after March 2020 - see 2017-18 Budget Working Age Payment Reforms);
    ELSE IF (( NsaSW&psn  > 0 OR ParPaySW&psn > 0 )    /* Receiving Newstart Allowance or Parenting Payment on SIH (accounts for transitions between NSA and PPP) */   
        OR YouthAllSW&psn > 0                          /* Receiving Youth Allowance on the SIH. To allow transferrability between NSA and YA(Oth) */
        OR PpGrandfatherFlag&psn = 1                   /* Sole parents who are not eligible for PPS                                               */
		OR (WidAllSW&psn > 0 AND ActualAge&psn < WidAllMinAge)	/*Receiving Widow Allowance on the SIH but below minimum age*/				   	

		/*2017-18 Budget - Working Age Payment Reforms - transition Wife Pensioners (not already transitioned onto Carer Payment) and Sickness Allowance recipients onto Newstart Allowance/JobSeeker Payment after March 2020*/	
				%IF (&Duration = A AND &Year >= 2020) 
				    OR (&Duration = Q AND &Year > 2020) 	
				    OR (&Duration = Q AND &Year = 2020 AND (&Quarter = Jun OR &Quarter = Sep OR &Quarter = Dec) ) 
				%THEN %DO ;

						OR WifePenSW&psn > 0  			/*Receiving Wife Pension on the SIH after March 2020 */	
						OR SickAllSW&psn > 0 			/*Receiving Sickness Allowance on the SIH after March 2020*/		
					
				%END; 
			)	
		/*End*/

        AND                                            /* Person of right age                                                                     */
      ( ( Sex&psn = 'F' AND UnempIndepAge <= ActualAge&psn < FemaleAgePenAge ) OR        
        ( Sex&psn = 'M' AND UnempIndepAge <= ActualAge&psn < MaleAgePenAge   ) ) 
        AND StudyType&psn NOT IN ( 'SS' , 'FTNS' )     /* Not full time student                                                                   */
        AND DvaType&psn     = ''                       /* Not receiving DVA Entitlement                                                           */
        AND PenType&psn     = ''                       /* Not receiving DSS Pension                                                               */                            
        AND AllowType&psn   = ''                       /* Not yet assigned a DSS allowance                                                        */ 
    THEN DO ;

        AllowType&psn = 'NSA' ;

        %NsaWidType( &psn )

    END ;

    * Determine if person is eligible for Widow Allowance ;
	* 2017-18 Budget - Working Age Payment Reforms - Widow Allowance will cease on 1 January 2022*; 

%IF (&Duration= A AND &Year < 2022) 
	OR (&Duration = Q AND &Year < 2022) 
%THEN %DO ;

    ELSE IF WidAllSW&psn       > 0              /* Receiving Widow Allowance on SIH  */   
        AND Sex&psn            = 'F'            /* Person is female                  */
        AND Coupleu            = 0              /* Person is single                  */
        AND ActualAge&psn     >= WidAllMinAge   /* Person is above minimum age       */
        AND DvaType&psn        = ''             /* Not receiving DVA Entitlement     */
		AND PenType&psn		   = '' 			/* Not receiving DSS Pension         */
        AND AllowType&psn      = ''             /* Not receiving other DSS allowance */ 
    THEN DO ;

		AllowType&psn = 'WIDOW' ;

        %NsaWidType( &psn )

    END ;

%END; 

%MEND AllowEligibility ;

**********************************************************************************
*   Macro:   YaEligibility                                                       *
*   Purpose: Flag if the person is eligible for Youth Allowance                  *
*********************************************************************************;;

%MACRO YaEligibility( psn , couple , depchild , sihcondition ) ;

    * Determine if person is eligible for the Full-time Student Youth Allowance;
    IF ( YouthAllSW&psn > 0                  /* Receiving Youth Allowance on SIH */

        %IF &sihcondition = NoReceiptSih %THEN %DO ;
            
            OR ( YouthAllSW&psn = 0 AND ActualAge&psn >= YaAgeLwr )
            
        %END ; 
        )
        AND ActualAge&psn < YaStudAgeUpr         /* Person of right age         */
        AND StudyType&psn IN ( 'FTNS' , 'SS' )   /* Full-time student           */ 

        %IF &psn IN ( r , s ) %THEN %DO ;

            AND DvaType&psn = ''                 /* Not receiving DVA payments  */
            AND PenType&psn     = ''                 /* Not receiving a DSS Pension*/                            

        %END ;   

        AND AllowType&psn   = ''                 /* Not receiving other DSS allowance*/ 

    THEN DO ;

        AllowType&psn = 'YASTUD' ;

        %YaAusType( &psn , &couple , &depchild  )

    END ; * End of YA full-time student receipt ;

    * Determine if person is eligible for the Job-seeker Youth Allowance ;
    ELSE IF ( YouthAllSW&psn > 0            /* Receiving Youth Allowance on SIH */

        %IF &psn IN ( r , s ) %THEN %DO ;
           OR NsaSW&psn  > 0                /* Receiving NSA on the SIH. To allow transferrability with NSA */
        %END ;

        %IF &sihcondition = NoReceiptSih %THEN %DO ; 
    /* Waive receipt on the SIH condition to determine MaxFamYaF variable used  */
    /* in the YA parental income test. Also make sure only those at least as   */
    /* old as the min YA age are eligible for it.                              */ 
            OR ( YouthAllSW&psn = 0 AND ActualAge&psn >= YaAgeLwr )
            
        %END ; 
      )
        AND ActualAge&psn < YaOtherAgeUpr          /* Person of right age        */
        AND StudyType&psn NOT IN ( 'SS' , 'FTNS' ) /* Not full-time student      */

        %IF &psn IN ( r , s ) %THEN %DO ;
                                                 
            AND DvaType&psn = ''                /* Not receiving DVA payments  */
            AND PenType&psn = ''                 /* Not receiving a DSS Pension*/                            

        %END ;

        AND AllowType&psn   = ''           /* Not receiving other DSS allowance*/ 

    THEN DO ;

        AllowType&psn = 'YAOTHER' ;

        %YaAusType( &psn , &couple , &depchild )       /* Determine type of YA */   

    END ; * End of YA other receipt ;

%MEND YaEligibility ;

**********************************************************************************
*   Macro:   YaAusType                                                           *
*   Purpose: Assigns type of YA payment received based on age of the recipient,  *
*            their partner status, whether they live with their parent or        *
*            away-from-home (AFH) and whether or not they have children.         *
*********************************************************************************;;

%MACRO YaAusType( psn , couple , depchild ) ;
   
   IF &Couple = 0 THEN DO ; *Start Single ;
 
       IF &DepChild = 0 THEN DO ; *start no dependent children ; 
          * Start at-home in parental income unit dependents;
           IF FamPos&psn IN ( 'NONDEPCHILD' , 'DEPCHILD' ) THEN DO ; 
              * 16-17 year old at home ;
               IF ActualAge&psn < 18 THEN AllowSubType&psn = 'YNGAH' ; 
            
              * At least 18 years old at home ; 
               ELSE IF ActualAge&psn < YaOtherAgeUpr THEN AllowSubType&psn = 'OLDAH' ; 

			        * At-home / same family independents ; 
    				ELSE IF WrkForceIndep&psn = 1 THEN AllowSubType&psn = 'SINGNODEPS' ; 

           END ; * End at-home parental income unit dependents ;      
 
          * Away-from-home independents ; 
           ELSE IF WrkForceIndep&psn = 1 THEN AllowSubType&psn = 'SINGNODEPS' ; 

          * YaRand = random variable, 
            DepCauseProp = proportion AFH deps who have reason to be ;
          * Maximum single rate given to those deps who are away-from-home 
            with a cause ; 
           ELSE IF WrkForceIndep&psn = 0 
               AND YaRand&psn <= DepCauseProp 

               THEN AllowSubType&psn = 'SINGNODEPS' ; 

          * Lower single rate given to those deps who are away-from-home 
            without a cause ;
           ELSE IF WrkForceIndep&psn = 0 
                AND YaRand&psn > DepCauseProp 
           THEN DO ; 
              * 16-17 year old away-from-home ;
               IF ActualAge&psn < 18 THEN AllowSubType&psn = 'YNGAH' ; 
                
              * At least 18 years old away-from-home ;
               ELSE AllowSubType&psn = 'OLDAH' ; 

           END ;

       END ; *end no dependents ;

       ELSE IF &DepChild > 0 THEN AllowSubType&psn = 'SINGDEPS' ;  

    END ; * End Single ; 

    ELSE IF &Couple = 1 THEN DO ; * Start couple ;

      * No dependent children ; 
        IF &DepChild = 0 THEN AllowSubType&psn = 'COUPNODEPS' ;

      * With dependent children ; 
        ELSE IF &DepChild > 0 THEN AllowSubType&psn = 'COUPDEPS' ; 
   
    END ; * End Couple ;

%MEND YaAusType ;

**********************************************************************************
*   Macro:   NsaWidType                                                          *
*   Purpose: Assigns type of Nsa/Widow payment received based on partner status, *
*            parent status, age and whether or not the person is a long-term     *
*            social security payment recipient.                                  *
*********************************************************************************;;

%MACRO NsaWidType( psn ) ;

    IF Coupleu = 0 THEN DO ; * Start single ;

      * No dependent children ; 
        IF DepsSec5 = 0 THEN DO ;

          * We do not know how long a person has been on a social secuity payment
            for from the SIH. Assume unemployed for at least 1 year and not in 
            Labour Force as a proxy for long term unemployed. ;
          * Age 60+ and long-term (9+ months) social security payment recipient.;
            IF ActualAge&psn >= MaaAge 
            AND ( DurUnempType&psn = 'Gt1Yr' OR LfStat&psn = 'NILF' )
            THEN DO ;

                AllowSubType&psn = 'OLDLTR' ; 

            END ; 

          * Regular single rate of payment ;
            ELSE IF UnempIndepAge <= ActualAge&psn THEN AllowSubType&psn = 'SINGNODEPS' ; 

         END ; * End single no dependent children ;

       * With dependent children ; 
         ELSE IF DepsSec5 > 0 THEN AllowSubType&psn = 'SINGDEPS' ; 

    END ; * End single ;

  * Couple ; 
    ELSE IF Coupleu = 1 THEN AllowSubType&psn = 'COUP' ;  

%MEND NsaWidType ;

**********************************************************************************
*   Macro:   AllowParameters                                                     *
*   Purpose: Assigns Allowance payment rates (single/coupled)                    *
*********************************************************************************;;
%MACRO AllowParameters( psn ) ;

  * Start those receiving Parenting Payment Partnered ;
    IF AllowType&psn = 'PPP' THEN DO ; 

        %AllParmAlloc( &psn , Unemp , Coup , C )

    END ; * End those receiving Parenting Payment Partnered ;

  * Start those receiving Newstart Allowance (JobSeeker Payment after March 2020) ;
    ELSE IF AllowType&psn = 'NSA' THEN DO ; 

        IF AllowSubType&psn = 'SINGNODEPS' THEN DO ;

            %AllParmAlloc( &psn , Unemp , SingNoDeps , S )

        END ; 

        ELSE IF AllowSubType&psn = 'OLDLTR' THEN DO ;

            %AllParmAlloc( &psn , Unemp , OldLtr , S )

        END ; 

        ELSE IF AllowSubType&psn = 'SINGDEPS' THEN DO ;

            %AllParmAlloc( &psn , Unemp , SingDeps , S )

        END ; 

        ELSE IF AllowSubType&psn = 'COUP' THEN DO ;

            %AllParmAlloc( &psn , Unemp , Coup , C )

        END ; 

    END ; * End those receiving Newstart Allowance (JobSeeker Payment after March 2020) ; 

  * Start those receiving non full-time student Youth Allowance ;
    ELSE IF AllowType&psn = 'YAOTHER' THEN DO ;

        IF AllowSubType&psn = 'YNGAH' THEN DO ;

            %AllParmAlloc( &psn , YngUnemp , YngAH , S )

        END ; 

        IF AllowSubType&psn = 'OLDAH' THEN DO ;

            %AllParmAlloc( &psn , YngUnemp , OldAH , S )

        END ;  

        IF AllowSubType&psn = 'SINGNODEPS' THEN DO ; 

            %AllParmAlloc( &psn , YngUnemp , SingNoDeps , S )

        END ; 

        IF AllowSubType&psn = 'SINGDEPS' THEN DO ;

            %AllParmAlloc( &psn , YngUnemp , SingDeps , S )

        END ; 

        IF AllowSubType&psn = 'COUPNODEPS' THEN DO ;

            %AllParmAlloc( &psn , YngUnemp , CoupNoDeps , C )

        END ; 

        IF AllowSubType&psn = 'COUPDEPS' THEN DO ;

            %AllParmAlloc( &psn , YngUnemp , CoupDeps , C )

        END ; 

    END ; * End those receiving non full-time student Youth Allowance ;

  * Start those receiving non full-time student Youth Allowance ;
    ELSE IF AllowType&psn = 'YASTUD' THEN DO ;

        IF AllowSubType&psn = 'YNGAH' THEN DO ;

            %AllParmAlloc( &psn , Stud , YngAH , S )

        END ; 

        IF AllowSubType&psn = 'OLDAH' THEN DO ;

            %AllParmAlloc( &psn , Stud , OldAH , S )

        END ;  

        IF AllowSubType&psn = 'SINGNODEPS' THEN DO ; 

            %AllParmAlloc( &psn , Stud , SingNoDeps , S )

        END ; 

        IF AllowSubType&psn = 'SINGDEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , SingDeps , S )

        END ; 

        IF AllowSubType&psn = 'COUPNODEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , CoupNoDeps , C )

        END ; 

        IF AllowSubType&psn = 'COUPDEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , CoupDeps , C )

        END ; 

    END ; * End those receiving non full-time student Youth Allowance ;

  * Start those receiving Austudy ;
    ELSE IF AllowType&psn = 'AUSTUDY' THEN DO ; 

        IF AllowSubType&psn = 'SINGNODEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , SingNoDeps , S )

        END ; 

        IF AllowSubType&psn = 'SINGDEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , SingDeps , S )

        END ; 

        IF AllowSubType&psn = 'COUPNODEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , CoupNoDeps , C )

        END ; 

        IF AllowSubType&psn = 'COUPDEPS' THEN DO ;

            %AllParmAlloc( &psn , Stud , CoupDeps , C )

        END ; 

    END ; * End those receiving Austudy ;

  * Start those receiving Widow Allowance ;
    ELSE IF AllowType&psn = 'WIDOW' THEN DO ; 

        IF AllowSubType&psn = 'SINGNODEPS' THEN DO ;

            %AllParmAlloc( &psn , Unemp , SingNoDeps , S )

        END ; 

        ELSE IF AllowSubType&psn = 'OLDLTR' THEN DO ;

            %AllParmAlloc( &psn , Unemp , OldLtr , S )

        END ; 

        ELSE IF AllowSubType&psn = 'SINGDEPS' THEN DO ;

            %AllParmAlloc( &psn , Unemp , SingDeps , S )

        END ; 

        ELSE IF AllowSubType&psn = 'COUP' THEN DO ;

            %AllParmAlloc( &psn , Unemp , Coup , C )

        END ;

    END ; * End those receiving Widow Allowance ; 

%MEND AllowParameters ;

**********************************************************************************
*   Macro:   AllParmAlloc                                                        *
*   Purpose: Assigns Allowance payment rates (single/coupled)                    *
*********************************************************************************;;

%MACRO AllParmAlloc( psn , alltype , AllowSubType , sc ) ;

    AllBasicMaxF&psn = &alltype.&AllowSubType.BasicMaxF ;

  * Allowance recipients only receive Pharmaceutical Allowance if they are   
    temporarily incapacitated, have a partial capacity to work, are a single 
    principle carer (only NSA and YA Other) or are 60 years old or more and 
    have been in receipt of an income support payment for at least 9 months. 
    CAPITA only models the last 2 categories. ;
    IF AllowSubType&psn = 'OLDLTR' 
    %IF &psn IN ( r , s ) %THEN %DO ;
        OR ( AllowType&psn IN ( 'NSA' , 'YAOTHER' ) 
        AND SingPrinCareFlag = 1 )
    %END ;   
        THEN PharmAllMaxF&psn = PharmAllMax&sc.F ;

	/*Assign Energy Supplement based on grandfathering test*/
	%IF (&Duration = A AND &Year  >= 2017 
	    OR &Duration = Q AND &Year > 2017 	
	    OR(&Duration = Q AND &Year = 2017 AND &Quarter = Dec ) )
	%THEN %DO ;

	 %IF &RunEs = Y %THEN %DO; 

			AllEsMaxF&psn = &alltype.&AllowSubType.EsMaxF ; 

		%END; 

		%ELSE %IF &RunEs = N %THEN %DO; 

			AllEsMaxF&psn = 0; 

		%END; 
	%END ;
	%ELSE %DO ;

		AllEsMaxF&psn = &alltype.&AllowSubType.EsMaxF ; 

	%END ;

	/*End*/

    AllThr1F&psn         = &alltype.Thr1F ;
    AllThr2F&psn         = &alltype.Thr2F ;
    AllTpr1&psn          = &alltype.Tpr1 ;
    AllTpr2&psn          = &alltype.Tpr2 ;
    AllPartTpr&psn       = AllPartTpr ;

  * Single principal carers who receive an Allowance which is determined by
    Benefit Rate Calculator B get a 40 per cent taper rate.
    SSA 1991 s1068-G17. ;
    IF AllowType&psn IN ( 'NSA' , 'WIDOW' ) 
    AND SingPrinCareFlag = 1 
    THEN DO ;

       AllTpr1&psn      = UnempSingDepsTpr1 ;
       AllTpr2&psn      = UnempSingDepsTpr2 ;

    END ;

%MEND AllParmAlloc ;

**********************************************************************************
*   Macro:   AllowRentAssistAlloc                                                *
*   Purpose: Assign Rent Assistance entitlement for allowance recipients         *
*            - non-families                                                      *
*********************************************************************************;;

%MACRO AllowRentAssistAlloc ;

  * Families with children have RA assigned with FTBA ;
    IF DepsFtbA = 0 THEN DO ;   * Start no children income units ;

      * Single ;
        IF Coupleu = 0 THEN RAssMaxPossFr = RAssMaxPossF ;

      * If only one member of a couple receives an allowance and their partner 
        is not receiving a pension or DVA entitlement, they get all RA ;
        ELSE IF AllowTyper NOT IN ( '' )  /* Reference receives an allowance    */
            AND AllowTypes    =     ''    /* Spouse receives nothing            */
            AND PenTypes      =     ''   
            AND DvaTypes      =     ''   
        THEN DO ;

            RAssMaxPossFr = RAssMaxPossF ;
            RAssMaxPossFs = 0 ;

        END ;

        ELSE IF AllowTypes NOT IN ( '' )   /* Spouse receives an allowance      */
            AND AllowTyper    =     ''     /*        Reference receives nothing */
            AND PenTyper      =     '' 
            AND DvaTyper      =     ''  
        THEN DO ;                           

            RAssMaxPossFr = 0 ;
            RAssMaxPossFs = RAssMaxPossF ;

        END ;

      * If both members of a couple receive an allowance, the RA is shared
        equally between them ;
        ELSE IF AllowTyper NOT IN ( '' )  
            AND AllowTypes NOT IN ( '' ) 
        THEN DO ;
    
            RAssMaxPossFr = RAssMaxPossF / 2 ;  
            RAssMaxPossFs = RAssMaxPossF / 2 ;

        END ;
  
    END ; * End no children income units ;

%MEND AllowRentAssistAlloc ;

**********************************************************************************
*   Macro:   AllowReduction                                                      *
*   Purpose: Calculate reduction amount for Allowance                            *
*            Currently personal, partner and parental income tests only          *
*********************************************************************************;;

%MACRO AllowReduction ;

    * Re-estimate income for the allowance personal income test for those allowance
    recipients whose partner receives a DVA Service Pension or DSS Pension. This 
    is in accordance with s1068-G2 of the SSA 1991. ;
    IF Coupleu = 1 THEN DO ;

        * Check if reference receives a pension to change spouses income amount ;
        IF Pentyper NOT IN ('') 
        OR DvaTyper = 'SERVICE' 
        THEN DO ;

           IncAllTestFs = ( IncOrdFr + IncOrdFs ) / 2 ;

        END ;

        * Check if spouse receives a pension to change references income amount ;
        IF Pentypes NOT IN ('') 
        OR DvaTypes = 'SERVICE' 
        THEN DO ;

           IncAllTestFr = ( IncOrdFr + IncOrdFs ) / 2 ;

        END ;

    END ;
 
    * Calculate allowance reduction under individual income test ;
    %IndivIncTest( r )

    IF Coupleu = 1 THEN DO ;   
 
        %IndivIncTest( s )

    END ; 

    * Partner income test
    * Also, do not do partner test where reference is work force dependent as it will not be applied ; 
    %PartIncTest          

    * Final reduction amount is the maximum of the personal and 
    parental income test plus the partner income test reduction. We do not 
    include the parental income test for the spouse as the spouse will always 
    be non-dependent ;
    AllRedFr = MAX( AllRedPerIncFr , AllRedPareIncFr ) + AllRedPartIncFr ;
    AllRedFs = AllRedPerIncFs + AllRedPartIncFs ;

%MEND AllowReduction ;

**********************************************************************************
*   Macro:   IndivIncTest                                                        *
*   Purpose: Calculates the reduction amount from the personal income test for   *
*            allowance recipients.                                               *
*********************************************************************************;;

%MACRO IndivIncTest( psn ) ;

  * If income under 1st threshold then no personal reduction ;    
    IF IncAllTestF&psn     < AllThr1F&psn THEN AllRedPerIncF&psn = 0 ; 

  * Person who has income above income Free area but under 2nd threshold ;
    ELSE IF AllThr1F&psn  <= IncAllTestF&psn < AllThr2F&psn 
    THEN AllRedPerIncF&psn = ( IncAllTestF&psn - AllThr1F&psn ) * AllTpr1&psn ;

  * Person who has income above the 2nd income threshold ;
    ELSE IF AllThr2F&psn  <= IncAllTestF&psn 
    THEN AllRedPerIncF&psn = ( IncAllTestF&psn - AllThr2F&psn ) * AllTpr2&psn  
                           + ( AllThr2F&psn - AllThr1F&psn ) * AllTpr1&psn ;

%MEND IndivIncTest ;

**********************************************************************************
*   Macro:   PartIncTest                                                         *
*   Purpose: Calculates the reduction amount from the partner income test for    *
*            allowance recipients in couples.                                    *
*********************************************************************************;;

%MACRO PartIncTest ;

  * Scenario 1 : Neither r or s have their payment reduced completely by the individual test ;
    IF ( AllRedPerIncFr < AllBasicMaxFr  
                        + PharmAllMaxFr 
                        + RAssMaxPossFr  
                        + AllEsMaxFr ) 
    AND ( AllRedPerIncFs < AllBasicMaxFs  
                         + PharmAllMaxFs 
                         + RAssMaxPossFs  
                         + AllEsMaxFs ) 
    THEN DO ;

        * Set partner income test reduction to zero ;
        AllRedPartIncFr = 0 ;
        AllRedPartIncFs = 0 ;

    END ; * End of scenario 1 ;

  * Scenario 2 : Reference has allowance amount reduced to zero and the spouse still receives some payment ;
    ELSE IF ( AllRedPerIncFr > AllBasicMaxFr  
                             + PharmAllMaxFr 
                             + RAssMaxPossFr  
                             + AllEsMaxFr OR
                  AllowTyper = '' ) 
    AND ( AllRedPerIncFs < AllBasicMaxFs 
                         + PharmAllMaxFs
                         + RAssMaxPossFs 
                         + AllEsMaxFs )
    THEN DO ;

        AllowTyper = '' ;        * Remove allowance type flag from reference ;
        AllowSubTyper = '' ;
        %AllowRentAssistAlloc      * Re-allocate rent assistance to r from s ;
        %PartIncTestThresh( r )    * Determine partner income test threshold ;

      * Determine the spouses income reduction stemming from the references 
        personal income ;
        AllRedPartIncFs = MAX( 0 , ( IncAllTestFr -  AllPartThrFr ) * AllPartTprs ) ; 
            
    END ; * End of Scenario 2 ;

  * Scenario 3 : Spouse has allowance amount reduced to zero and the reference still receives some payment ;
    ELSE IF ( AllRedPerIncFs > AllBasicMaxFs  
                             + PharmAllMaxFs 
                             + RAssMaxPossFs  
                             + AllEsMaxFs    
              OR AllowTypes = '' ) 
        AND ( AllRedPerIncFr < AllBasicMaxFr  
                             + PharmAllMaxFr 
                             + RAssMaxPossFr  
                             + AllEsMaxFr ) 
    THEN DO ;

        AllowTypes = '' ; * Remove allowance type from spouse ; 
        AllowSubTypes = '' ; * Remove allowance sub-type from spouse ; 
        %AllowRentAssistAlloc * Re-allocate rent assistance to s from r ;
        %PartIncTestThresh( s )* Determine partner income test threshold ;

      * Determine the references income reduction stemming from the spouses 
        personal income ;
        AllRedPartIncFr = MAX( 0 , ( IncAllTestFs - AllPartThrFs ) * AllPartTprr ) ; 
            
    END ; * End of Scenario 3 ;

  * Scenario 4 : If neither partner is receiving a payment then partner income test is redundant ;

%MEND PartIncTest ;

**********************************************************************************
*   Macro:   PartIncTestThresh                                                   *
*   Purpose: Determines income threshold for partner income test when partner    *
*            is not receiving a pension                                          *
*********************************************************************************;;

%MACRO PartIncTestThresh( psn ) ;

		/*Remove notional amount of Energy Supplement from partner income test 
		threshold if person is not receiving it. This is part of the policy to 
		remove(grandfather)the Energy Supplement for income support 
		payments - it applies from 20 September 2017*/ 

		/*Assign flag for receipt of ES and use the flag in the calculation 
		of income thresholds below*/		

		%IF (&Duration = A AND &Year  >= 2017 
	    OR &Duration = Q AND &Year > 2017 	
	    OR(&Duration = Q AND &Year = 2017 AND &Quarter = Dec ) )
		%THEN %DO ;

			IF AllEsMaxF&psn > 0 THEN DO; 

				AllEsFlag&psn = 1;

			END; 

			ELSE DO; 

				AllEsFlag&psn = 0; 

			END; 

		%END; 

		%ELSE %DO;  
			
			AllEsFlag&psn = 1;

		%END;
	
		/*End of assigning ES flags*/

		* Where the partner receives an Allowance ;
	    IF AllowType&psn IN ( 'PPP' 'NSA' 'YASTUD' 'YAOTHER' 'AUSTUDY' 'WIDOW' ) THEN 

		/* The Partner income test includes all payment components */
        AllPartThrF&psn = ( AllBasicMaxF&psn + RAssMaxPossF&psn + (AllEsMaxF&psn * AllEsFlag&psn)
                        - ( AllThr2F&psn - AllThr1F&psn ) * AllTpr1&psn ) 
                          / AllTpr2&psn
                          + AllThr2F&psn ;

    * Partner does not receive allowance. Treatment dependent on partners age ; 
 
    * Partner is under the age of independence ; 
    * Section 1068-G9 of the SSA 1991 states that the partners age has to be less 
    than 22 which is the age of independence. Which is why the code used the 
    UnempIndepAge parameter. ;
    ELSE IF ActualAge&psn < UnempIndepAge THEN DO ;

      * Use basic rates and thresholds for Job-seeker Youth Allowance rate ;
        IF DepsSec5 > 0 THEN  

            AllPartThrF&psn = ( YngUnempCoupDepsBasicMaxF + (YngUnempCoupDepsEsMaxF * AllEsFlag&psn)
                              - ( YngUnempThr2F - YngUnempThr1F ) * YngUnempTpr1 ) 
                              / YngUnempTpr2
                              + YngUnempThr2F ; 

      * No Dependent Children ;
        ELSE AllPartThrF&psn = ( YngUnempCoupNoDepsBasicMaxF + (YngUnempCoupNoDepsEsMaxF * AllEsFlag&psn)
                              - ( YngUnempThr2F - YngUnempThr1F ) * YngUnempTpr1 )
                              / YngUnempTpr2
                              + YngUnempThr2F ; 
                  
    END ; * End partners age under age of independence ;

  * Partner older than age of independence but under age pension age ;
    ELSE IF ( ( Sex&psn = 'F' 
            AND UnempIndepAge <= ActualAge&psn < FemaleAgePenAge ) 
           OR ( Sex&psn = 'M' 
            AND UnempIndepAge <= ActualAge&psn < MaleAgePenAge ) ) 
    THEN DO ;


    * Use basic rates and thresholds for couple NSA ;
	
			AllPartThrF&psn = ( UnempCoupBasicMaxF + (UnempCoupEsMaxF * AllEsFlag&psn)
		                          - ( UnempThr2F - UnempThr1F ) * UnempTpr1 )
		                          / UnempTpr2
		                          + UnempThr2F ;

	END ; * End of partner is over age of independence but under Age Pension age ;

  * Older than age pension age ;
    ELSE IF ( ( Sex&psn = 'F' AND ActualAge&psn >= FemaleAgePenAge )
           OR ( Sex&psn = 'M' AND ActualAge&psn >= MaleAgePenAge ) ) 
    THEN DO ;                

      * Use the basic couple Newstart Allowance rate (JobSeeker Payment after March 2020) and the full Pension 
        Supplement. ;
        AllPartThrF&psn = ( ( UnempCoupBasicMaxF + (UnempCoupEsMaxF * AllEsFlag&psn) + PenSupBasicMaxcF 
                            + PenSupRemMaxcF + PenSupMinMaxcF ) 
                          - ( UnempThr2F - UnempThr1F ) * UnempTpr1 )
                          / UnempTpr2
                          + UnempThr2F ;

    END ;

  * Section 1068-G9 of the SSAct 1991 states that the Partner Income Test
    Threshold is rounded up to the nearest dollar ;
    AllPartThrF&psn = CEIL( AllPartThrF&psn ) ;

%MEND PartIncTestThresh ;

**********************************************************************************
*   Macro:   AllowCalc                                                           *
*   Purpose: Calculate Allowance entitlement including supplements for allowances*
*********************************************************************************;;

%MACRO AllowCalc ( alltype , psn ) ;
 
  * Assign reduction amount between the different components. ;

  * Person receives everything at full rate ;
    IF AllRedF&psn = 0 THEN DO ;    

        AllBasicF&psn    = AllBasicMaxF&psn ;
        RAssF&psn        = RAssMaxPossF&psn ;
        AllEsF&psn       = AllEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF&psn ;
        AllowRateType&psn   = 'Maximum Rate' ;

    END ;

  * Basic allowance only is reduced ;
    ELSE IF AllRedF&psn <= AllBasicMaxF&psn THEN DO ;

        AllBasicF&psn    = AllBasicMaxF&psn - AllRedF&psn ;
        RAssF&psn        = RAssMaxPossF&psn ;
        AllEsF&psn       = AllEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF&psn ;
        AllowRateType&psn  = 'Part Rate' ;

    END ;

  * Basic allowance 0, rent assistance reduced ;
    ELSE IF AllRedF&psn <= ( AllBasicMaxF&psn + RAssMaxPossF&psn ) THEN DO ;

        AllBasicF&psn    = 0 ;
        RAssF&psn        = AllBasicMaxF&psn + RAssMaxPossF&psn - AllRedF&psn ;
        AllEsF&psn       = AllEsMaxF&psn ;
        PharmAllF&psn    = PharmAllMaxF&psn ;
        AllowRateType&psn  = 'Part Rate' ;

    END ;

  * Basic allowance and rent assistance 0, energy supplement reduced;
    ELSE IF AllRedF&psn <= ( AllBasicMaxF&psn 
                           + RAssMaxPossF&psn 
                           + AllEsMaxF&psn ) THEN DO ;

        AllBasicF&psn    = 0 ;
        RAssF&psn        = 0 ;
        AllEsF&psn       = AllBasicMaxF&psn  
                         + RAssMaxPossF&psn 
                         + AllEsMaxF&psn
                         - AllRedF&psn ;
        PharmAllF&psn    = PharmAllMaxF&psn ;
        AllowRateType&psn  = 'Part Rate' ;

    END ;

  * Basic allowance, rent assistance and energy supplement are 0,
    Pharmaceutical Allowance not fully reduced so get full amount. ; 
    ELSE IF AllRedF&psn <= ( AllBasicMaxF&psn 
                           + RAssMaxPossF&psn 
                           + AllEsMaxF&psn 
                           + PharmAllMaxF&psn) THEN DO ;

        AllBasicF&psn    = 0 ;
        RAssF&psn        = 0 ;
        AllEsF&psn       = 0 ;
        PharmAllF&psn    = PharmAllMaxF&psn ;
        AllowRateType&psn  = 'Part Rate' ;

    END ;

    ELSE DO ;

      * Remove AllowType flag if person does not qualify for a positive amount ;
        AllowType&psn = '' ;
        AllowSubType&psn = '' ;

    END ;

  * Calculate summary variables ;
    AllTotF&psn = AllBasicF&psn    
                + RAssF&psn        
                + PharmAllF&psn    
                + AllEsF&psn ; 

    AllTotA&psn = AllTotF&psn * 26 ;

  * Assign generic amounts to payment-specific variables ;  
    &alltype.AllBasicF&psn = AllBasicF&psn ;
    &alltype.RAssF&psn     = RAssF&psn     ;  
    &alltype.PharmAllF&psn = PharmAllF&psn ;
    &alltype.AllEsF&psn    = AllEsF&psn   ;
    &alltype.TotF&psn      = AllTotF&psn ; 
    %IF &alltype IN( YaStud , YaOther ) %THEN %DO ;
        YaTotF&psn = AllTotF&psn ;
        YaTotA&psn = AllTotF&psn * 26 ;
    %END ;

    &alltype.AllBasicA&psn = &alltype.AllBasicF&psn * 26 ;
    &alltype.RAssA&psn     = &alltype.RAssF&psn * 26 ;  
    &alltype.PharmAllA&psn = &alltype.PharmAllF&psn * 26 ;
    &alltype.AllEsA&psn    = &alltype.AllEsF&psn * 26 ;
    &alltype.TotA&psn      = &alltype.TotF&psn * 26 ;

%MEND AllowCalc ;

**********************************************************************************
*   Macro:   YaParIncTestFam                                                     *
*   Purpose: Calculates familiy level information for students 1 - 4 and those   *
*            in separate income units for calculating YA parental income test    *
*            reduction amounts. Retains family level level information of        *
*            MaxFamYaF and AllPareIncTestExF for own units.                      *
*********************************************************************************;;

%MACRO YaParIncTestFam ;

  * Collect information from all the related income units when the first of the 
    family is encountered. ;
  * Variables used in the parental income test are initialised here rather than 
    in Initialisation.sas module. This is so they are not overwritten for 
    subsequent income units in the family but are overwritten when the next 
    family unit is processed. ;
    
    MaxFamYaF = 0 ;
    
  * Parental income test is only performed in families who have a student 
    dependent or have more than one income unit in the family. ;  
    IF ActualAge1 > 0 OR NumIUu > 1 THEN DO ; 

      * Work out YA outcome for students 1 to 4 in the parents income unit ;
      * Only work out outcomes for student dependents 1 to 4 if they exist ;
        %DO i = 1 %TO 4 ;

            IF ActualAge&i > 0 THEN DO ;
          
                %DepAllowElig( &i ) /* Determine eligibility and payment */
                                    /* rates for dependants. Calculates MaxFamYaF */
                                    /* for dependants 1 - 4. */
            END ;

        %END ;
      
      * Retain variables that will hold family level outcomes ; 
        RETAIN MaxFamYaF AllPareIncTestExF AllPareIncTestExA ;

      * Check to see if there are multiple income units in the family ;
      * This is so we can include dependents in their own income unit (both 
        at-home and away-from-home) in the calculation of the parental 
        income test reduction. ;
        IF NumIUu > 1 THEN DO ;

          * Record current position in the basefile ;
            Pointer = _N_ ;

          * Read in turn each related income unit ;
            DO i = 1 TO ( NumIUu - 1 ) ;

              * Set the pointer to read the next observation ;
                Pointer = Pointer + 1 ;

              * For speed, only keep variables of interest ;
              * Rename the variables of interest so the variables on the actual
                observation being processed are not overwritten by values from 
                the additional observations being read at the same time ;
                SET &BasefileLib..&Basefile ( KEEP = YouthAllSWr ActualAger StudyTyper 
                                                Famposr WrkForceIndepr YaRandr 
												%IF &RunCameo = Y %THEN %DO; %END; %ELSE %DO; 
												RandAustudyEsGfthr RandNsaEsGfthr RandPppEsGfthr
                								RandWidowEsGfthr RandYastudyEsGfthr RandYaotherEsGfthr
												%END; 
	
										RENAME = ( YouthAllSWr = YouthAllSWr_
                                                    ActualAger = ActualAger_ 
                                                    StudyTyper = StudyTyper_
                                                    Famposr = Famposr_ 
                                                    WrkForceIndepr = WrkForceIndepr_ 
                                                    YaRandr = YaRandr_ 
													%IF &RunCameo = Y %THEN %DO;%END; %ELSE %DO;  
													RandAustudyEsGfthr = RandAustudyEsGfthr_
													RandNsaEsGfthr = RandNsaEsGfthr_
													RandPppEsGfthr = RandPppEsGfthr_
													RandWidowEsGfthr = RandWidowEsGfthr_
													RandYastudyEsGfthr = RandYastudyEsGfthr_
													RandYaotherEsGfthr = RandYaotherEsGfthr_
													%END; )) 
                POINT = Pointer ;

              * Only work out YA outcomes for dependents as independent young 
                people are not included in the parental income test ;
                IF WrkForceIndepr_ = 0 THEN DO ;

                  * Initialise PenType, AllowType and AllowSubType variables for 
                    dependents in their own income unit each time a new dependent
                    is read in. This is so the dependents do not get assigned the 
                    AllowType or PenType variable of the dependent before them. 
                    ( Noting that they have not passed through the Pension 
                    eligibility macro. ;
                    PenTyper_ = '' ;
                    AllowTyper_ = '' ;
                    AllowSubTyper_ = '' ;

                  * Dependants in their own income unit do not have dependants or 
                    spouse of their own, which would put them in their own family;
                    %YaEligibility( r_ , 0 , 0 , NoReceiptSih ) 
                        
                    IF AllowTyper_ = 'YAOTHER' THEN DO ; 

                      * At-home dependents will be either YNGAH or OLDAH ;
                        IF AllowSubTyper_ = 'YNGAH' THEN DO ;

                            %AllParmAlloc( r_ , YngUnemp , YngAH , S )

                        END ; 

                        IF AllowSubTyper_ = 'OLDAH' THEN DO ;

                            %AllParmAlloc( r_ , YngUnemp , OldAH , S )

                        END ;  

                    END ; 

                    ELSE IF AllowTyper_ = 'YASTUD' THEN DO ;

                        IF AllowSubTyper_ = 'YNGAH' THEN DO ;

                            %AllParmAlloc( r_ , Stud , YngAH , S )

                        END ; 

                        IF AllowSubTyper_ = 'OLDAH' THEN DO ;

                            %AllParmAlloc( r_ , Stud , OldAH , S )

                        END ;  

                    END ;

                  * If person receives an allowance add their maximum rates of YA
                    to the families pool. ;
                    IF AllowTyper_ IN( 'YASTUD' , 'YAOTHER' ) 
                    AND AllowSubTyper_ IN( 'YNGAH' , 'OLDAH' )
                    THEN DO ;

                        MaxFamYaF = MaxFamYaF + AllBasicMaxFr_ + AllEsMaxFr_ ; 
                                       
                    END ; * End of receiving an allowance ;

                END ; * End of dependence check ;

            END ;   * End of processing related income unit records in family ;
       
        END ;   * End of reading in all the related observations ;
      
    END ;   * End of processing first observation for each family ;

    * Calculate the parental income excess amount for each family ;
    AllPareIncTestExA = MAX ( 0 , AllPareTestIncA - AllPareThrA ) ;

    * Convert to fortnightly excess amount from annual amount ;
    AllPareIncTestExF = ( AllPareIncTestExA / 26 ) ;

    * Add family level FTBA amounts to parental pool. Retain MaxFamYaF to record its value 
      against own income units within the family. ; 

    RETAIN MaxFamYaF_ ;

    IF FIRST.FamID = 1 THEN DO ;

        * 2015-16 Budget measure p156 (passed on 12 November 2015)
        * Include all FTB-A max rate payments in the family into the YA parental pool.
          (Large family supplement not included because Gov policy is to abolish it 
          from 2016). This is calculated after MaxFamYaF has been calculated for all 
          dependants within an income unit, and all income units within the family.  ;

        IF &Year >= 2016 AND DepsFtba > 0 THEN DO ;

            IF Kids0Su > 0 THEN DO ;

                IF TotalKidsu = Kids0Su OR Kids0Su > 1 THEN NewBornSupA = Kids0Su * NewBornSup1A ; 

                ELSE IF Kids0Su = 1 THEN NewBornSupA = Kids0Su * NewBornSup2A ;

            END ;

            IF Renteru = 1 THEN DO ;

                %FtbaRentAssistAlloc 
                %RentAssistMaxRate    

            END ;
                            
            MaxFamYaF  = MaxFamYaF 
                       + RAssMaxPossF 
                       + ( DepsUnder13 * ( FtbaMaxRateAgeUnder13 + FtbaMaxEsAgeUnder13 )
                       + ( Deps13_15u + DepsFtbaOwnIU )
                       * ( FtbaMaxRateAge13_19Stud + FtbaMaxEsAge13_19Stud ) 
                       + ( DepsFtba * FtbaSupA  )
                       +  NewBornSupA ) 
                       * 14 / 365 ;     *convert annual FTBA max omponents to fortnightly ;
                              
        END ; 

        MaxFamYaF_ = MaxFamYaF ;

    END ;

%MEND YaParIncTestFam ;

************************************************************************************
*   Macro:   FtbaRentAssistAlloc                                                   *
*   Purpose: Classify type of renter based on relationship status and number of    *
*            rent assistance children                                              *
***********************************************************************************;;

%MACRO FtbaRentAssistAlloc ;

    IF Coupleu = 0 THEN DO ;

        IF DepsFtba = 1 OR DepsFtba = 2 THEN DO ;

            RenterType = 'SDeps1_2' ;

            %AllocFtbaRentParam ( SDeps1_2 )

        END ;
        
        ELSE IF DepsFtba > 2 THEN DO ; 

            RenterType = 'SDepsMany';

            %AllocFtbaRentParam ( SDepsMany )

        END ;

    END ;

    ELSE IF Coupleu = 1 THEN DO ;

        IF DepsFtba = 1 or DepsFtba = 2 THEN DO ;

            RenterType = 'CDeps1_2' ;

            %AllocFtbaRentParam ( CDeps1_2 )

        END;

        ELSE IF DepsFtba > 2 THEN DO ; 

            RenterType = 'CDepsMany' ;

            %AllocFtbaRentParam ( CDepsMany )

        END ;

    END ;

%MEND FtbaRentAssistAlloc ;

************************************************************************************
*   Macro:   AllocateFtbaRentParam                                                 *
*   Purpose: Allocate rent parameters based on renter type                         *
***********************************************************************************;;

%MACRO AllocFtbaRentParam ( RenterType );

    RAssMinRentFu = RentMin&RenterType ;
    RAssMaxFu = RentMax&RenterType ;
    
%MEND AllocFtbaRentParam ;

**********************************************************************************
*   Macro:   YaParIncTestRes                                                     *
*   Purpose: Determines the parental income test result for each dependant YA    *
*            recipient in a family.                                              *
*********************************************************************************;;

%MACRO YaParIncTestRes( psn ) ;

    * If a parent is receiving a social security pension or benefit or a DVA
    entitlement their dependent is exempted from the parental income test ;
    IF FIRST.FamID = 1
    AND ( PenTyper NOT IN ('') OR PenTypes NOT IN ('') 
    OR    AllowTyper NOT IN ('') OR AllowTypes NOT IN ('') 
    OR    DvaTyper NOT IN ('') OR DvaTypes NOT IN ('') )
    THEN DO ;

       AllPareIncTestResF&psn = 0 ;

    END ;

    ELSE DO ;

        * Calculate the parental income test reduction for dependants 1 - 4 and the reference person
          of own income units. ;

        * Check workforce dependence status ;
        IF WrkForceIndep&psn = 0 THEN DO ;

            IF MaxFamYaF_ = 0 THEN AllPareIncTestResF&psn = 0 ;

            ELSE DO ;

                AllPareIncTestResF&psn = ROUND( AllPareIncTestExF
                                        * ( ( AllBasicMaxF&psn + AllEsMaxF&psn ) / MaxFamYaF_ )
                                        * AllRedPareTpr , 0.1 ) ;

            END ; 

        END ; /* End of dependence check */

    END ; /* End of exemption check */

    * Convert parental income test result to an annual amount. ;
    AllPareIncTestResA&psn = AllPareIncTestResF&psn * 26 ;
        
%MEND YaParIncTestRes ;

**********************************************************************************
*   Macro:   YaMaintIncTestRes                                                   *
*   Purpose: Determines the maintenance income test result applying              *
*            to the dependents YA based on their parents' child support amounts. *   
*            2015-16 Budget measure p 156 (passed 12 November 2015),             *
*            New maintenance income test from 1 January 2017                     *
*********************************************************************************;;

%MACRO YaMaintIncTestRes( psn ) ;

    * Calculates maintenance income for each eligible person in the family unit ;

    IF ActualAge&psn > 0                /* Check if person exists */
    AND DepsMaintFlag&psn = 1        /* Check if dependant is eligible for maintenance income */
        THEN IncMaintA&psn = IncMaintAu_ / DepsMaint_ ; 
                               
    * If the person is eligible for youth allowance and receives maintenance income, 
      calculate the maintenance income test result. ;
    IF IncMaintA&psn > 0 AND DepsYaMaintFlag&psn = 1 THEN DO ; 

        * Assign annual maintenance income free area depending on the number of
          maintenance income recipients and calculate maintenance income
          threshold. ;

        * If there are no FTB-A children in the family, the maintenance free area includes the base amount
          plus the number of YA recipients who receive maintenance income in the family multiplied by the
          additional child add-on. ;
        IF DepsFtba = 0 THEN YaMaintIncThrA&psn = ( MaintIncFreeSingle + ( ( DepsYaMaint_ - 1)
                                                   * MaintIncFreeKids ) ) / DepsYaMaint_ ;

        * If there are FTB-A children in the family, the maintenance free area is only the additional
        child add-on per child, and the base maintenance income free area is not included. ;
        ELSE IF DepsFtba > 0 THEN YaMaintIncThrA&psn = MaintIncFreeKids ;

      * Calculate maintenance income test result. ;
        AllMaintIncTestResA&psn = MAX( 0 , ( IncMaintA&psn - YaMaintIncThrA&psn ) * MaintTpr ) ;

      * Convert to fortnightly amount from annual amount ;
        AllMaintIncTestResF&psn = AllMaintIncTestResA&psn / 26 ;
    
    END ;

%MEND YaMaintIncTestRes ;

**********************************************************************************
*   Macro:   YaParTestRed                                                        *
*   Purpose: Determines the parental test reduction applying to                  *
*            to the dependents YA based on their parents' maintenance income.    *   
*            2015-16 Budget measure p 156 (passed 12 November 2015)              *
*            New maintenance income test from 1 January 2017                     *
*********************************************************************************;;

%MACRO YaParTestRed( psn ) ;

    %IF &Year < 2017 %THEN %DO ;
        
        AllRedPareIncA&psn = AllPareIncTestResA&psn ;

    %END ;

    %ELSE %IF &Year >= 2017 %THEN %DO ;

        * If the parental income test result is equal to or more than the MIT reducible
        amount, the reduction for parental income is the parental income test result. ; 
        IF AllPareIncTestResA&psn >= MaintRedAmtA THEN AllRedPareIncA&psn = AllPareIncTestResA&psn ;
  
        * If the parental income test result is less than the MIT reducible amount,
        the maintenance income test applies. ; 
        ELSE IF AllPareIncTestResA&psn < MaintRedAmtA THEN DO ;

            * Add the parental income test result to the maintenance income test result
            to calculate the notional amount. ; 
            AllNotionAmtA&psn = AllPareIncTestResA&psn + AllMaintIncTestResA&psn ;

            * If the notional reduction is less than or equal to the MIT reducible amount, the
             reduction for parental income is the notional amount. ; 
            IF AllNotionAmtA&psn <= MaintRedAmtA THEN AllRedPareIncA&psn = AllNotionAmtA&psn ;

            * If the notional reduction is more than the MIT reducible amount, the reduction
             for parental income is the MIT reducible amount. ; 
            ELSE IF AllNotionAmtA&psn > MaintRedAmtA THEN AllRedPareIncA&psn = MaintRedAmtA ;

        END ;       

    %END ;

    *Calculate fortnightly parental test reduction amount. ;
    AllRedPareIncF&psn = AllRedPareIncA&psn / 26 ;
  
%MEND YaParTestRed ;

**********************************************************************************
*   Macro:   DepAllowElig                                                        *
*   Purpose: Determines eligibility and assigns parameters for student dependants*
*            1 to 4 within the parental income unit                              *
*********************************************************************************;;

%MACRO DepAllowElig( psn ) ;

   * Check eligibility for dependents. Dependents in their parents income unit are 
     only eligible for student Youth Allowance.  This is because non full-time 
     students 16 years and older (minimum age for YA) form their own income unit 
     according to the ABS definition ;

   * Determine if person is eligible for the Youth Allowance.  As these people are
     students 1 to 4 in their parents income unit, they must be single (Couple) and 
     must have no dependent children (DepChild).  As these variables are determined
     at an income unit level, the values for these variables are hard-coded to zero
     for students 1 to 4. ;
    %YaEligibility( &psn , 0 , 0 , NoReceiptSih )

    IncAllTestF&psn = IncOrdF&psn ;

  * Assign parameters ;
    %AllowParameters( &psn )

  * Check if student i is workforce dependent. If they are then ;
    IF WrkForceIndep&psn = 0 THEN DO ;
      * Add that students max YA values to the total family max YA amount;
        MaxFamYaF = MaxFamYaF + AllBasicMaxF&psn + AllEsMaxF&psn ;

    END; 

  * Recall the YaEligibility macro to calculate actual YA eligibility (we needed 
    their notional amount of YA to determine the familys maximum YA pool for the 
    parental income test.) ;
    AllowType&psn = '' ;
    AllowSubType&psn = '' ;

    %YaEligibility( &psn , 0 , 0 , TestReceiptSih )

%MEND DepAllowElig ;

**********************************************************************************
*   Macro:   DepAllowCalc                                                        *
*   Purpose: Calculates means test reductions and final outcomes for dependents  *
*            1 to 4 in the parental income unit                                  *
;********************************************************************************;;

%MACRO DepAllowCalc( psn ) ;

  * Calculate the personal income test reduction ;
    %IndivIncTest( &psn )

  * There is no partner income test as dependents cannot have a partner for 
    social security test purposes ;

  * The final reduction amount is the reduction amount stemming from the test that
    reduces the allowance payment by the most. If the student is independent, 
    the reduction from the parental income test will be zero so the personal 
    income test will always be used. ;
    AllRedF&psn = MAX( 0 , AllRedPerIncF&psn , AllRedPareIncF&psn ) ;

  * Calculate Allowance components ;
    IF AllowType&psn IN ('YASTUD') THEN DO ;

        %AllowCalc( YaStud , &psn )

    END ;

    * NOTE: YA Other recipients according to SIH should be in own income unit. ;
    ELSE IF AllowType&psn IN ('YAOTHER') THEN DO ;

        %AllowCalc( YaOther , &psn )

    END ;

%MEND DepAllowCalc ;

* Now call all the code ;
%RunAllowance




