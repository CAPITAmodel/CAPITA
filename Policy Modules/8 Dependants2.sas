
**************************************************************************************
* Program:      8 Dependants2.sas                                                    *
* Description:  Calculates the number of dependants for Medicare and SIFS purposes.  *
**************************************************************************************;

************************************************************************************
*   Macro:   RunDependants2                                                        *
*   Purpose: Coordinate dependants calculation                                     * 
************************************************************************************;;

%MACRO RunDependants2 ;

    ************************************************************************************
    *      1.        Count the number of dependants for Medicare levy and Medicare     *
    *                levy surcharge purposes                                           *
    ************************************************************************************;

    %MedicareDependants

    ************************************************************************************
    *      2.        Count the number of dependants for SIFS purposes                  *
    ************************************************************************************;

    %SifsDependants

%MEND RunDependants2 ;

************************************************************************************
*   Macro:   MedicareDependants                                                    *
*   Purpose: Count number of Medicare levy and Medicare levy surcharge dependants  * 
************************************************************************************;;

%MACRO MedicareDependants ;

    * Tally up dependants when a new family is first encountered ;
    * Note that only the first income unit in a family should have dependent children 
      (as the presence of children should trigger a new family) ;

    IF FIRST.FamID THEN DO ;

        * Check if students 1 to 4 are Medicare Levy dependants;

        %DO i = 1 %TO 4 ;
        
            %MLDepTest( &i )    *comes back with DepMLFlag&i = 1 or 2 if Medicare levy dependant;

            %MLSDepTest( &i )   *comes back with DepMLSFlag&i = 1 if Medicare levy surcharge dependant;

        %END ;
        
        * If the family is spread over multiple rows in the basefile, need to tally up any dependants that are described on later rows ;

        IF NumIUu > 1 THEN DO ;

            * Record current position in the basefile ;
            Pointer = _N_ ;

            * Read in turn each related income unit ;
            DO j = 1 TO ( NumIUu - 1 ) ;

                * Set the pointer to read the next observation ;
                Pointer = Pointer + 1 ;

                SET Basefile.&Basefile ( KEEP = ActualAger StudyTyper YouthAllSWr
                             
                                RENAME = ( ActualAger = ActualAger_ 
                                           StudyTyper = StudyTyper_
                                           YouthAllSWr = YouthAllSWr_ ) )
                
                POINT = pointer ;

                /* Copy IncPrivAr */
                IncPrivAr_ = IncPrivAr ; 

                /*need a proxy for ATI here as dependants in own income unit will not have ATI calculated yet
                (as ATI is policy not basefile variable, will only be calculated for those in first income unit
                use PrivIncome + YA income from the SIH - gets similar results*/
                AdjTaxIncAr_ = IncPrivAr + ( YouthAllSWr * 52 ) ;

                %MLDepTest( r_ ) ;  * comes back with DepMLFlagr_ = 1 or 2 if medicare levy dependant  ;
                IF DepsMLFlagr_ = 1 THEN DepsMLOwnIU1 = DepsMLOwnIU1 + 1 ;
                IF DepsMLFlagr_ = 2 THEN DepsMLOwnIU2 = DepsMLOwnIU2 + 1 ;

                %MLSDepTest( r_ ) ;  * comes back with DepMLSFlagr_ = 1 if medicare levy surcharge dependant ;
                IF DepsMLSFlagr_ = 1 THEN DepsMLSOwnIU = DepsMLSOwnIU + 1 ;         

            END ; * of DO ;

        END ; * Of there being multiple income units in the family ;

        ELSE IF NumIUu = 1 THEN DO ;

            ActualAger_ = . ; 

            StudyTyper_ = '' ; 

            IncPrivAr_ = . ; 

            YouthAllSWr_ = . ;

        END;

        * SUM UP ML deps for under 15 kids, students 1-4 and ownIUs ;
        DepsML = DepsUnder15        /* assume all kids under 15 are ML and MLS deps - note ATI test should apply for ML dependency but assume no income */
               + ( DepsMlFlag1 = 1 )
               + ( DepsMlFlag2 = 1 )
               + ( DepsMlFlag3 = 1 )
               + ( DepsMlFlag4 = 1 )
               + DepsMlOwnIU1 
               + MIN( 1 , ( DepsMlFlag1 = 2 )
                        + ( DepsMlFlag2 = 2 )
                        + ( DepsMlFlag3 = 2 )
                        + ( DepsMlFlag4 = 2 )
                        + DepsMlOwnIU2 ) ; * Remove dependants under MedLevDepAge1 after the first ;

        * SUM UP MLS deps for under 15 kids, students 1-4 and ownIUs ;
        DepsMls = DepsUnder15 
                + DepsMlsFlag1 
                + DepsMlsFlag2 
                + DepsMlsFlag3 
                + DepsMlsFlag4 
                + DepsMlsOwnIU ;

    END ;

%MEND MedicareDependants ;

************************************************************************************
* Macro:   MLDepTest                                                               *
* Purpose: Income test for Medicare levy dependants                                *
************************************************************************************;;

%MACRO MLDepTest( psn ) ;  * both for st1-4 and ownIU;

    * MEDICARE LEVY DEP;
    * Under MedLevDepAge1 ; 
    IF ( 0 < ActualAge&psn < MedLevDepAge1 ) 
    AND AdjTaxIncA&psn < MedLevDepIncThr2 
    THEN DO ; 
    
        IF AdjTaxIncA&psn < MedLevDepIncThr1 THEN DepsMlFlag&psn = 1 ;

        ELSE IF AdjTaxIncA&psn >= MedLevDepIncThr1 THEN DepsMlFlag&psn = 2 ;

    END ;

    * Above MedLevDepAge1 and under MedLevDepAge2 ; 
    IF MedLevDepAge1 <= ActualAge&psn < MedLevDepAge2          
       AND StudyType&psn IN ( 'SS' , 'FTNS' )
       AND AdjTaxIncA&psn < MedLevDepIncThr2  

        THEN DepsMlFlag&psn = 1 ;

%MEND MLDepTest ;

************************************************************************************
* Macro:   MLSDepTest                                                              *
* Purpose: Income test for Medicare levy surcharge dependants                      *
************************************************************************************;;

%MACRO MLSDepTest( psn ) ;  * both for st1-4 and ownIU;

    * MEDICARE LEVY SURCHARGE DEP ;
    IF 0 < ActualAge&psn < MedLevSurDepAge1 THEN DepsMLSFlag&psn = 1 ; * all dependents under 22 ;
            
    ELSE IF MedLevSurDepAge1 <= ActualAge&psn < MedLevSurDepAge2  
            AND StudyType&psn IN ( 'SS' , 'FTNS' )  

    THEN DepsMLSFlag&psn = 1 ; * FT students under 25;

%MEND MLSDepTest ;

************************************************************************************
* Macro:   SifsDependants                                                          *
* Purpose: Count number of single income family supplement dependants              *
************************************************************************************;;

%MACRO SifsDependants ;

    * Tally up dependants when a new family is first encountered ;
    * Note that only the first income unit in a family should have dependent children 
      (as the presence of children should trigger a new family) ;

    IF FIRST.FamID THEN DO ;

      * Check if students 1 to 4 are SIFS deps who are not eligible for FTBA as they receive a DSS
        Pension or Allowance and then make flags ;
        %DO i = 1 %TO 4 ;

            IF ActualAge&i > 0 THEN DO ;

                IF ActualAge&i IN ( 15 , 16 , 17 , 18 , 19 ) 
                AND StudyType&i = "SS"
                AND YouthAllSW&i > 0
                OR DspSW&i > 0
                OR AustudySW&i > 0
                THEN DepsSifs = DepsSifs + 1 ;
                            
            END ;

        %END ;

        * If the family is spread over multiple rows in the basefile, need to tally up any dependants that are described on later rows ;

        IF NumIUu > 1 THEN DO ;

            * Record current position in the basefile ;
            Pointer = _N_ ;

            * Read in turn each related income unit ;
            DO j = 1 TO ( NumIUu - 1 ) ;

                * Set the pointer to read the next observation ;
                Pointer = Pointer + 1 ;

                SET Basefile.&Basefile ( KEEP = ActualAger  YouthAllSWr DspSWr AustudySWr
                             
                                RENAME = ( ActualAger = ActualAger_ 
                                           YouthAllSWr = YouthAllSWr_
                                           DspSWr = DspSWr_ 
                                           AustudySWr = AustudySWr_ ) )
                
                POINT = Pointer ;

                IF ActualAger_ = 15 
                AND YouthAllSWr_ > 0
                OR DspSWr_ > 0 
                OR AustudySWr_ > 0
                THEN DepsSifs = DepsSifs + 1 ;

            END ; * of DO ;

        END ; * Multiple income units in the family ;

        ELSE IF NumIUu = 1 THEN DO ;

            ActualAger_ = . ;
            YouthAllSWr_ = . ;
            DspSWr_ = . ;
            AustudySWr_ = . ;

        END ; * End of only 1 income unit in family ;

        DepsSifs = DepsSifs + DepsFtba ; * Include FTBA deps into SIFS deps calculation ;

    END ;

%MEND SifsDependants  ;

* Call %RunDependants ;
%RunDependants2
