
************************************************************************************
* Program:      3 Dependants1.sas                                                  *
* Description:  Calculates the number of dependants according to specified         * 
*               transfer policy definitions. Some dependants definitions require   *
*               more information about transfer policy outcomes before they can    *
*               be constructed, hence such definitions are contained in the        *
*               Dependants2 module.                                                *
************************************************************************************;

************************************************************************************
*   Macro:   RunDependants1                                                        *
*   Purpose: Coordinate dependants calculation                                     * 
***********************************************************************************;;

%MACRO RunDependants1 ;

    ************************************************************************************
    *      1.        Specify list of basefile variables to be used for look-ahead      *
    ************************************************************************************;
 
    * Create list of basefile variables needed for the look-ahead ;
    %LET KeepList = ActualAger StudyTyper YouthAllSWr AustudySWr DspSWr NsaSWr 
                    HighestSYearSr Coupleu
                    /* List of basefile variables needed to calculate Private Income */       
                    IncWageSAr IncBusLExpSAr IncTaxSuperImpAr IncIntAr IncDivSAr 
                    FrankCrImpAr IncOthInvSAr IncRoyalSAr IncWCompAr IncNonHHSAr 
                    IncOSPenSAr IncOthRegSAr IncNetRentAr IncMaintSAr 
                    IncNonTaxSuperImpAr TotSSNonSSAr
                    /* List of basefile variables needed to calculate Ordinary Income */
                    IncMaintSFr IncSSSuperSFr IncSSTotSFr NonSSTotSFr AdjFbFr 
                    DVADisPenSWr DVAWWPenSWr PPLSWr DaPPSWr

                    ;

    * Create lists used in the RENAME and DROP commands in Step 2 
      eg. ActualAger = ActualAger_ and so on for each variable in &KeepList ;
    %LET RenameList = ;
    %LET DropList = ;
    
    %RenameList 

    ************************************************************************************
    *      2.        Count the number of dependants for a parental income unit at the  *
    *                family unit level (the first income unit in a family unit)        *
    ************************************************************************************;

    %SocialSecDependants

%MEND RunDependants1 ;

************************************************************************************
* Macro:   RenameList                                                              *
* Purpose: Create lists for the RENAME and DROP command                            *
************************************************************************************;

%MACRO RenameList ;

    %LET NumKeepList = %SYSFUNC( COUNTW( &KeepList ) ) ; 

    %DO i = 1 %TO &NumKeepList ;

        %LET KeepVar = %SCAN( &KeepList , &i ) ;

        %LET RenameList = &RenameList &KeepVar = &KeepVar._ ;

        %LET DropList = &DropList &KeepVar._ ;

    %END ;

%MEND RenameList ;

************************************************************************************
* Macro:   SocialSecDependants                                                     *
* Purpose: Count the number of social security dependants                          *
************************************************************************************;

%MACRO SocialSecDependants ;

   * Tally up dependants when a new family is first encountered 
     Note that only the first income unit in a family should have dependent children 
     (as the presence of children should trigger a new family) ;

    IF FIRST.FamID THEN DO ;

      * Check if students 1 to 4 are sec5deps, ssplusdeps or senior sec students and 
        make flags ;
        %DO i = 1 %TO 4 ;
            
            IF ActualAge&i > 0 THEN DO ;

                %Sec5DepTest( &i )  /* comes back with DepsSec5Flag&i = 1 if sec5dep */

                %SSPlusDepTest( &i ) /* comes back with DepSSPlusFlag&i = 1 if ssplusdep */

                IF IncMaintAu > 0 THEN DO ;
                    %MaintDepTest( &i )   /* comes back with DepsMaint = 1 if dependent */ 
                END ;                     /*of child support age and DepsYaMaint = 1 if */
                                          /* also YA recipient */

                *MYEFO 2015-16 FTBB age eligibility up to age16 for student only;                       
                IF ActualAge&i = 16
                AND StudyType&i = "SS"  
                /* can't be FTB dep if receiving pension or allowance */
                AND ( YouthAllSW&i + AustudySW&i + DspSW&i + NsaSW&i ) <= 0      
                    THEN DepsFtbSec16 = DepsFtbSec16 + 1 ;

                IF ActualAge&i IN ( 16 , 17 , 18 ) 
                AND StudyType&i = "SS"  
                /* can't be FTB dep if receiving pension or allowance */
                AND ( YouthAllSW&i + AustudySW&i + DspSW&i + NsaSW&i ) <= 0      
                    THEN DepsFtbSec16_18 = DepsFtbSec16_18 + 1 ;

                IF ActualAge&i = 19 
                AND StudyType&i = "SS" 
                /* can't be FTB dep if receiving pension or allowance */
                AND ( YouthAllSW&i + AustudySW&i + DspSW&i + NsaSW&i ) <= 0       
                    THEN DepsFtbSec19 = DepsFtbSec19 + 1 ;
                   
            END ;

        %END ;
        
       * If the family is spread over multiple rows in the basefile, need to tally up
         any dependants that are described in later rows ;
        IF NumIUu > 1 THEN DO ;

          * Record current position in the basefile ;
            Pointer = _N_ ;

          * Read in turn each related income unit ;
            DO j = 1 TO ( NumIUu - 1 ) ;

              * Set the pointer to read the next observation ;
                Pointer = Pointer + 1 ;

               * For speed, only keep variables of interest 
                 Rename the variables of interest so the variables on the actual 
                 observation being processed are not overwritten by values from the 
                 additional observations being read at the same time ; 
                SET &BasefileLib..&Basefile ( KEEP = &KeepList RENAME = ( &RenameList ) )                   
     
                POINT = Pointer ;

              * Calculate Ordinary Income for look ahead Income Unit ;
                
                %PrivIncome( r_ )
                * Work Bonus is not applicable to dependants in own income unit ;
                IncPrivLessWBFr_ = IncPrivFr_ ;     
                %OrdIncome( r_ )

              * Count how many FTB dependants in their own income units the family has ;
                IF &Year < 2014 THEN DO ;   /* Old FTB child definition tests income */
                                            /* of non-student children */

                    IF ActualAger_ = 15 
                    /* can't be FTB dep if receiving pension or allowance */
                    AND ( YouthAllSWr_ + AustudySWr_ + DspSWr_ + NsaSWr_ ) <= 0      
                    /* Assume ATI=private income as have already checked no allowance/pension */
                    AND IncOrdFr_ < FtbaChldIncLim    
                    THEN DO ;

                        DepsFtbaOwnIU = DepsFtbaOwnIU + 1 ;   

                        DepsFtbbOwnIU = DepsFtbbOwnIU + 1 ;  

                    END ;

                    IF ActualAger_ in ( 16 , 17 )
                    AND HighestSYearSr_ = 1     /* has completed year 12 or equivalent*/
                    /* can't be FTB dep if receiving pension or allowance */
                    AND ( YouthAllSWr_ + AustudySWr_ + DspSWr_ + NsaSWr_ ) <= 0       
                    /* Assume ATI=private income as have already checked no allowance/pension*/
                    AND IncOrdFr_ < FtbaChldIncLim                                                
                    THEN DO ;

                        DepsFtbaOwnIU = DepsFtbaOwnIU + 1 ;

                    END ;

                END ;  

              * FTB dep rules from May 2014 onwards - only 15 year olds in own income unit ;
                ELSE IF ActualAger_ = 15 
                /*can't be FTB dep if receiving pension or allowance*/
                AND ( YouthAllSWr_ + AustudySWr_ + DspSWr_ + NsaSWr_ ) <= 0   
                THEN DO ;

                    DepsFtbaOwnIU = DepsFtbaOwnIU + 1 ;
                    DepsFtbbOwnIU = DepsFtbbOwnIU + 1 ;  

                END ; * of enddate > Jun 2014 ;

              * check if sec5dep - note only 15 year olds can be sec5 dep in own IU ;
                IF ActualAger_ = 15 THEN DO ;

                    %Sec5DepTest( r_ ) 

                    IF DepsSec5Flagr_ = 1 THEN DepsSec5OwnIU = DepsSec5OwnIU + 1 ; 

                END ;
                
              * check if ssplusdep - can be 15, 16 or 17 ; 
                %SSPlusDepTest( r_ )
     
                IF DepsSSPlusFlagr_ = 1 THEN DepsSSPlusOwnIU = DepsSSPlusOwnIU + 1 ;

              * Count number of YA recipients of child support age in own income unit; 
                IF IncMaintAu > 0 THEN DO ;

                    %MaintDepTest( r_ )
                 
                    IF DepsYaMaintFlagr_ = 1 THEN DepsYaMaintOwnIU = DepsYaMaintOwnIU + 1 ;
                
                    IF DepsMaintFlagr_ = 1 THEN DepsMaintOwnIU = DepsMaintOwnIU + 1 ;
                END ;

            END ; * of DO ;

          * Drop variables created used for look ahead ;
            DROP j &DropList ;

        END ; * Of there being multiple income units in the family ;
    
      * add up how many st1-4 are aged 15 ;
        Kids15u = ( ActualAge1 = 15 ) 
                + ( ActualAge2 = 15 ) 
                + ( ActualAge3 = 15 )  
                + ( ActualAge4 = 15 )
                ; 

      * for FTBB rate ; 
        DepsUnder5 = Kids0u 
                   + Kids1u 
                   + Kids2u 
                   + Kids3u 
                   + Kids4u ;    

      * for FTBA max rate ; 
        DepsUnder13 = Kids0u 
                    + Kids1u
                    + Kids2u
                    + Kids3u
                    + Kids4u
                    + Kids5u
                    + Kids6u
                    + Kids7u
                    + Kids8u
                    + Kids9u
                    + Kids10u
                    + Kids11u
                    + Kids12u ;    

      * for FTBA max rate - not including 15ownIUs in this, but included in the rate sum ; 
        Deps13_15u = Kids13u 
                   + Kids14u 
                   + Kids15u ;         

        DepsUnder15 = DepsUnder13 
                    + Kids13u 
                    + Kids14u ;

     * Used to assign single principal carer taper rates for NSA & Widow Allowance ; 
       DepsPrinCare = DepsUnder15 /* Dependents under 15 */
                    + Kids15u ;   /* Student dependents aged 15 years */

     * Flag used to assign single principal carer taper rates for NSA & Widow Allowance ; 
       IF DepsPrinCare > 0 AND Coupleu = 0 THEN DO ;

            SingPrinCareFlag = 1 ;

       END ;

      * Used for SchoolKids Bonus ;        
      * note children in own income unit are not students by definition ; 
       DepsFtbPr = Kids5u 
                 + Kids6u
                 + Kids7u
                 + Kids8u
                 + Kids9u
                 + Kids10u
                 + Kids11u ;  

       DepsFtbSec = Kids12u 
                  + Kids13u 
                  + Kids14u 
                  + Kids15u  
                  + DepsFtbSec16_18  
                  + DepsFtbSec19 ;
     
    * Assume primary = 5-11 years, high school=12 and over 
        
      * sum up sec 5 deps ;
        DepsSec5 = DepsUnder15 
                 + DepsSec5Flag1 
                 + DepsSec5Flag2
                 + DepsSec5Flag3
                 + DepsSec5Flag4
                 + DepsSec5OwnIU ; /* other own IUs cant be sec5 as not students */

        DepsSSTotal = DepsSec5 
                    + DepsSSPlusFlag1 
                    + DepsSSPlusFlag2
                    + DepsSSPlusFlag3
                    + DepsSSPlusFlag4
                    + DepsSSPlusOwnIU ; /* only st1-4 or dep15ownIU people can be SSplus; */

        * define FTB deps ; 
        DepsFtbA = DepsUnder13 
                 + Deps13_15u 
                 + DepsFtbaOwnIU 
                 /* all 15 year olds are FTB deps, older ones only if sec students; */
                 + DepsFtbSec16_18 
                 + DepsFtbSec19 ;   
      

        %IF ( ( &Duration = A AND &Year < 2016 ) OR ( &Duration = Q AND &Year < 2016 )
			OR ( &Duration = Q AND &Year = 2016 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) ) ) %THEN %DO ;

            DepsFtbB = DepsUnder13 
                     + Deps13_15u 
                     + DepsFtbbOwnIU 
                     + DepsFtbSec16_18 ;

        %END ;

        /* Change in child age for FTBB eligibility, also depending on family type from 1 July 2016*/  
		/* Legislated 11 Dec 2015 - see Social Services Legislation Amendment (Family Payments Structural Reform and Participation Measures)Bill 2015*/

		%ELSE %DO ;
            IF Coupleu = 0 OR ActualAges >= 60 THEN DO ;      /*single parent or grandparent*/
	                DepsFtbB = DepsUnder13 
		                     + Deps13_15u 
		                     + DepsFtbbOwnIU 
		                     + DepsFtbSec16_18 ;
			END ;
		    ELSE DepsFtbB = DepsUnder13 ;
        %END ;
	
        IF IncMaintAu > 0 THEN DO ; 
        *Budget 2015-16, passed 12 Nov 2015 - From 1 January 2017, maintenance income test will apply to YA;
            %IF &Year >= 2017 %THEN %DO ;
          * Adds up how many YA dependents of child support age ;
                DepsYaMaint = DepsYaMaintFlag1 
                            + DepsYaMaintFlag2
                            + DepsYaMaintFlag3
                            + DepsYaMaintFlag4
                            + DepsYaMaintOwnIU ;
            %END ;

          * Adds up how many children are eligible to receive child support ;
            DepsMaint = DepsUnder13 
                      + Deps13_15u 
                      + DepsFtbaOwnIU 
                      + DepsMaintFlag1 
                      + DepsMaintFlag2
                      + DepsMaintFlag3
                      + DepsMaintFlag4
                      + DepsMaintOwnIU ;

         * Adds up FTB children eligible to receive child support ; 
           DepsFtbaMaint   = DepsUnder13 
                           + Deps13_15u 
                           + DepsFtbaOwnIU 
                           + DepsFtbSec16_18 ;
        END ;
        
    END ;   /* Of processing the first income unit in the family ; */
    
    * Retain MaintIncTest and YaMaintIncTest for own income units within the family. ;
    
    RETAIN DepsMaint_ DepsYaMaint_ ;

    IF FIRST.FamID = 1 THEN DO ;

        DepsMaint_ = DepsMaint ;
        DepsYaMaint_ = DepsYaMaint ;

    END ;

    * Call MaintDepTest again to identify who in own income unit is eligible for maintenance income ;

    IF FIRST.FamID = 0 THEN DO ;

        %MaintDepTest( r )

    END ;

%MEND SocialSecDependants ;

************************************************************************************
* Macro:   Sec5DepTest                                                             *
* Purpose: Count number of Section 5 dependants                                    *
***********************************************************************************;

* Define a macro that checks whether a person qualifies as a sec5 dependant and sets 
  DepsSec5Flag&psn=1 if so ;
%MACRO Sec5DepTest( psn ) ;  * both for st1-4 and ownIU ;

    IF ActualAge&psn = 15 THEN DO ;  

        IF StudyType&psn IN ( 'FTNS' , 'SS' ) 
        OR ( IncOrdF&psn < ( DepChildIncLimUnder16 * 2 ) 
             AND YouthAllSW&psn 
                 %IF &psn IN ( r , s , r_ ) %THEN %DO ;
                 + AustudySW&psn 
                 + DspSW&psn 
                 + NsaSW&psn
                 %END ;
                 <= 0 )   /*if receiving pension or benefit can't be sec5dep - proxy */
                          /* by SIH receipt as pension/allowance result not yet known*/
        THEN DepsSec5Flag&psn = 1 ;

    END ; /*of 15 year olds;*/

    ELSE IF 15 < ActualAge&psn < 22 THEN DO ;

        IF StudyType&psn IN ( 'FTNS', 'SS' ) 
        AND IncOrdA&psn < DepChildIncLimOver16
        AND YouthAllSW&psn 
            %IF &psn IN ( r , s , r_ ) %THEN %DO ;
            + AustudySW&psn 
            + DspSW&psn 
            + NsaSW&psn
            %END ;
            <= 0       /*if receiving pension or benefit can't be sec5dep - proxy */
                       /* by SIH receipt as pension/allowance result not yet known*/  
            THEN DepsSec5Flag&psn = 1 ;

    END ; * of over 15s ;

%MEND Sec5DepTest ;

************************************************************************************
* Macro:   SSPlusDepTest                                                           *
* Purpose: Count the additional number of Section 5 dependants under the expanded  *
*          definition                                                              *
***********************************************************************************;

* Define a macro that checks whether a person qualifies as an ssplus dep and sets 
  DepSSPlusFlag&psn=1 if so ;
%MACRO SSPlusDepTest( psn ) ;  /*both for st1-4 and ownIU;*/

    IF ActualAge&psn IN ( 15 , 16 , 17 ) 
    /* use receipt on SIH as proxy for receiving YA as YA result not available yet*/
    AND YouthAllSW&psn > 0 
        THEN DepsSSPlusFlag&psn = 1 ;   

%MEND SSPlusDepTest ;

************************************************************************************
* Macro:   MaintDepTest                                                            *
* Purpose: Creates a flag for YA recipients up to child support age (16 to 18).    *
*          Children aged 18 may only receive child support if they are in          *
*          full-time study.                                                        *
*          Used to calculate maintenance income income free area for YA dependant  *
*          where there other siblings but no FTB children in the family.           *
*          2015-16 Budget Measure p 158 passed 12 Nov 2015                         *
***********************************************************************************;
%MACRO MaintDepTest( psn ) ;

    * If family receives maintenance income, flag those who are eligible for it ;
    IF IncMaintAu_ > 0 THEN DO ;

        IF ActualAge&psn IN ( 16 , 17 ) THEN DO ;
            * Flag to indicate whether person is eligible for maintenence income ; 
            DepsMaintFlag&psn = 1 ;

            * Flag to indicate whether person is eligible for maintenence income and is receiving YA ;
            IF YouthAllSW&psn > 0 THEN DepsYaMaintFlag&psn = 1 ;

        END ;

        ELSE IF ActualAge&psn = 18 AND StudyType&psn = "SS" THEN DO ;
            * Flag to indicate whether person is eligible for maintenence income ; 
            DepsMaintFlag&psn = 1 ;

            * Flag to indicate whether person is eligible for maintenence income and is receiving YA ;
            IF YouthAllSW&psn > 0 THEN DepsYaMaintFlag&psn = 1 ;

        END ;

    END ;
        
%MEND MaintDepTest ;
        
* Call %RunDependants1 ;
%RunDependants1

