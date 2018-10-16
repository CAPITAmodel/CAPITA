
**************************************************************************************
* Program:      VariableConstruct2.sas                                               *
* Description:  Create additional variables which are required for basefiles and     *
*               policy modules, and which require variables from multiple dataset    *
*               levels at once or imputed variables.                                 *
**************************************************************************************;

%MACRO VariableConstruct2 ;

DATA Basefile&SurveyYear ;
    SET Basefile&SurveyYear ;

    * Identifier variables for the household, family, income unit and person ;

		%IF &NpdImpute = Y %THEN %DO ;
        HHID = ( INPUT ( SUBSTR ( SihHID , 7 , 7 ) , 7. ) ) * 10 + NPDFlag ;
		%END ;
		%ELSE %DO ;
        HHID = ( INPUT ( SUBSTR ( SihHID , 7 , 7 ) , 7. ) ) * 10 ;		
		%END ;

        FamID = ( HHID * 100 ) + INPUT ( SihFID , 2. ) ;

        IUID = ( FamID * 10 ) + INPUT ( SihIUID , 1. ) ;

        IF ActualAger NE . THEN PersIDr = ( IUID * 10 ) + INPUT ( SihPIDr , 2. ) ;   
        IF ActualAges NE . THEN PersIDs = ( IUID * 10 ) + INPUT ( SihPIDs , 2. ) ;   
        IF ActualAge1 NE . THEN PersID1 = ( IUID * 10 ) + INPUT ( SihPID1 , 2. ) ;   
        IF ActualAge2 NE . THEN PersID2 = ( IUID * 10 ) + INPUT ( SihPID2 , 2. ) ;  
        IF ActualAge3 NE . THEN PersID3 = ( IUID * 10 ) + INPUT ( SihPID3 , 2. ) ;  
        IF ActualAge4 NE . THEN PersID4 = ( IUID * 10 ) + INPUT ( SihPID4 , 2. ) ;     

    * Age of the youngest dependant in the income unit (AgeYoungDepu) ;

        i = 0 ;

        AgeYoungDepu = 99 ;        /* Initialise to 99. If no dependants, this will remain at 99. */

        ARRAY KidAges{15}     Kids0Su Kids1Su Kids2Su Kids3Su Kids4Su Kids5Su Kids6Su Kids7Su Kids8Su Kids9Su Kids10Su Kids11Su
                              Kids12Su Kids13Su Kids14Su ;

        Kids0to14u = Kids0Su + Kids1Su + Kids2Su + Kids3Su + Kids4Su + Kids5Su + Kids6Su + Kids7Su + Kids8Su + Kids9Su
                  + Kids10Su + Kids11Su + Kids12Su + Kids13Su + Kids14Su ;

        IF Kids0to14u > 0 THEN DO i = 1 to 15 ;

            IF KidAges{i} > 0 THEN DO ;

                AgeYoungDepu = i - 1 ;

                i = 15 ;

            END ;

        END ;

        ELSE IF ( ( ActualAge1 NE . ) OR ( ActualAge2 NE . ) OR ( ActualAge3 NE . ) OR ( ActualAge4 NE . ) ) THEN DO ; 

            AgeYoungDepu = MIN ( ActualAge1 , ActualAge2 , ActualAge3 , ActualAge4 ) ;

        END ; 

        AgeYoungDepf = AgeYoungDepu ;

        * Total kids in the income unit aged between 0 and 15 inclusive ;

        Kids0to15u = Kids0Su + Kids1Su + Kids2Su + Kids3Su + Kids4Su + Kids5Su + Kids6Su + Kids7Su + Kids8Su + Kids9Su
                  + Kids10Su + Kids11Su + Kids12Su + Kids13Su + Kids14Su + (ActualAge1 = 15) + (ActualAge2 = 15) 
                  + (ActualAge3 = 15) + (ActualAge4 = 15) ;

        * Total dependants in the income unit (i.e. including all kids and all dependents) ;

        TotalKidsu = Kids0to15u + (ActualAge1 > 15) + (ActualAge2 > 15) + (ActualAge3 > 15) + (ActualAge4 > 15) ;

        * SharerFlag to indicate whether the person is living in a share house ;

        SharerFlagu = 0 ;

        IF IUTypeSu = 4                /* The income unit consists of one person */

            AND Occupancyu = 4        /* The income unit is renting privately */

            AND FamilyComph = 33      /* The person lives in a group household */

            AND (DspSWr = 0 OR (DspSWr > 0 AND ActualAger > 21)) 

                                     /* Either the person is not receiving any DSP, or they are
                                        but they're over 21 */

        THEN DO ;

            SharerFlagu = 1 ;

        END ;

        * Private health insurance coverage for the income unit. The income unit only has cover if 
          all members of the income unit have cover ;

        PrivHlthInsu = 0 ;

        IF PrivHlthInsr = 1 THEN PrivHlthInsu = 1 ;
        IF ActualAges NE . AND PrivHlthInss = 0 THEN PrivHlthInsu = 0 ;
        IF ActualAge1 NE . AND PrivHlthIns1 = 0 THEN PrivHlthInsu = 0 ;
        IF ActualAge2 NE . AND PrivHlthIns2 = 0 THEN PrivHlthInsu = 0 ;
        IF ActualAge3 NE . AND PrivHlthIns3 = 0 THEN PrivHlthInsu = 0 ;
        IF ActualAge4 NE . AND PrivHlthIns4 = 0 THEN PrivHlthInsu = 0 ;

        * Drop variables created in the above constructions which are no longer required ; 

        DROP i ;

RUN ; 


* Age of the youngest dependant in the family (AgeYoungDepf) ;

    * First sort by FamID as the look-ahead method used below requires this ;

    PROC SORT DATA = Basefile&SurveyYear ;

        BY FamID IUID ;

    RUN ;    

    * Use the look-ahead method to include own income unit dependants in AgeYoungDepf ;

    DATA Basefile&SurveyYear ;

        SET Basefile&SurveyYear ;

        BY FamID ;

        * Include own income unit dependants in AgeYoungDepf ;

        IF FIRST.FamID AND NumIUu > 1 THEN DO ;
       
          * Record current position in the dataset ;
            Pointer = _N_ ;

          * Read in each related income unit ;
            DO j = 1 TO ( NumIUu - 1 ) ;

              * Set the pointer to read the next observation ;
                Pointer = Pointer + 1 ;

               * For speed, only keep variables of interest ;
                SET Basefile&SurveyYear 
                    ( KEEP = ActualAger RENAME = ( ActualAger = ActualAger_ ) )                   
     
                POINT = Pointer ;

                IF ( ActualAger_ < 25 ) AND ( ActualAger_ < AgeYoungDepu ) THEN DO ;
                    AgeYoungDepf = ActualAger_ ;
                END ;
            END ;

        END ; * Of there being multiple income units in the family ;

    RUN ;


* Create a dataset called IUKeptVars for use in the merging step, to merge the variables created
  above onto the basefile for each of the outyears ;

DATA IUKeptVars ;

    SET Basefile&SurveyYear ;

        KEEP SihHID SihFID SihIUID SihPIDr SihPIDs SihPID1 SihPID2 SihPID3 SihPID4
             HHID FamID IUID PersIDr PersIDs PersID1 PersID2 PersID3 PersID4
             AgeYoungDepu AgeYoungDepf Kids0to14u Kids0to15u TotalKidsu SharerFlagu PrivHlthInsu ;

RUN ;

PROC SORT DATA = IUKeptVars ;

    BY SihHID SihFID SihIUID ;

    RUN ;

%MEND VariableConstruct2 ;
