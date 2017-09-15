
**************************************************************************************
* Program:      KidAgeImp.sas                                                        *
* Description:  The numbers of children in each of the 0-2, 3-4, 5-9 and 10-14 age   *
*               ranges in the SIH are topcoded at 2 children. This module imputes the*
*               actual number of children in each of these age ranges. Next, the     *
*               module randomly allocates all of the children in each of the age     *
*               ranges to individual years of age, creating each of the individual   *
*               year of age kid age variables from Kids0 to Kids14.                  *
**************************************************************************************;

* First define a macro to be used in the data step below, for assigning kids to individual years of age ;

%MACRO IndivYears(n) ;

            * If there are kids in the category, then ;

            IF KidAgeRangesI{&n} > 0 THEN DO ;

                Years = 0 ;

                * Loop through each of the kids in the category ;

                DO l = 1 TO KidAgeRangesI{&n} ;

                    Count = 1 ;

                    Allocated = 0 ;

                    * Loop through each of the years in the current category until the kid has been allocated ;

                    DO UNTIL ( Allocated = 1 ) ; 
                                  
                        * Assign the kid randomly to one of the years ; 

                        IF RandIndivYrs{&n,l} < ( Years + 1 ) / ( UpperBound{&n} - UpperBound{&n-1} ) THEN DO ; 

                            KidIndYears{LowerBound{&n} + Count} = KidIndYears{LowerBound{&n} + Count} + 1 ;

                            Allocated = 1 ;

                            Years = 0 ;

                        END ;
                            
                        ELSE DO ; 

                            Count = Count + 1 ;

                            Years = Years + 1 ;

                        END ;

                    END ;

                END ;

            END ;

%MEND IndivYears ;

*******************************************************;
* Conduct the imputations                              ;
*******************************************************;

DATA Income&SurveyYear ;
        
    SET Income&SurveyYear ;

*******************************************************;
* First step - correct for topcoding issue             ;
*******************************************************;

        * Initially set the imputed age categories to be equal to the actual age categories ;

        Kids0to2Iu = Kids0to2Su ;
        Kids3to4Iu = Kids3to4Su ;
        Kids5to9Iu = Kids5to9Su ;
        Kids10to14Iu = Kids10to14Su ;

        * Initialise some new variables for the purposes of the imputation ;

        PotentialYears = 0 ;
        ExcessKids = 0 ;
        Blank1 = 0 ;
        Blank2 = 0 ;

        * Define an array containing the variable names for the number of kids in each age range ; 

        ARRAY KidAgeRanges{*} Blank1 Kids0to2Su Kids3to4Su Kids5to9Su Kids10to14Su ;

        * Define an array containing the variable names for the estimated number of kids in each age range ;

        ARRAY KidAgeRangesI{*} Blank2 Kids0to2Iu Kids3to4Iu Kids5to9Iu Kids10to14Iu ;

        * Define an array containing the variable names for the estimated number of kids by individual
          year of age ;

        ARRAY KidIndYears{*} Kids0u Kids1u Kids2u Kids3u Kids4u Kids5u Kids6u Kids7u Kids8u Kids9u Kids10u Kids11u 
                             Kids12u Kids13u Kids14u ;

        * Define an array containing the variable names of the random numbers to be used for allocating excess kids ;

        ARRAY RandExcessKid{*} RandKidAgeImp1 RandKidAgeImp2 RandKidAgeImp3 ;

        * Define an array containing the variable names of the random numbers to be used for allocating kids to
          individual years ;

        ARRAY RandIndivYrs{5,4}  Blank           Blank           Blank           Blank
                                 RandKidAgeImp21 RandKidAgeImp22 RandKidAgeImp23 RandKidAgeImp24
                                 RandKidAgeImp31 RandKidAgeImp32 RandKidAgeImp33 RandKidAgeImp34
                                 RandKidAgeImp41 RandKidAgeImp42 RandKidAgeImp43 RandKidAgeImp44
                                 RandKidAgeImp51 RandKidAgeImp52 RandKidAgeImp53 RandKidAgeImp54 ;                        

        * Define arrays containing the lower and upper bounds of each of the age ranges ;

        ARRAY LowerBound{5} ( 0 , 0 , 3 , 5 , 10 ) ; 

        ARRAY UpperBound{5} ( -1 , 2 , 4 , 9 , 14 ) ;

        * Create a variable containing the number of excess kids to be allocated to age ranges ;

        ExcessKids = PersonsInIUSu - SUM( Kids0to2Su , Kids3to4Su , Kids5to9Su , Kids10to14Su , Adults15to64Su , Adults65to99Su ) ;

        * Imputation is only required when there is a positive number of excess kids ;

        IF ExcessKids > 0 THEN DO ;

            * Construct PotentialYears variable to serve as the denominator in the probability statement
              below ;

            * Loop through each of the kid age categories ;

            DO k = 2 to 5 ;

                * Only for categories with potential topcoding ;

                * If the first category is 2 then PotentialYears starts from 2 - - 1 = 3. If other categories
                  are 2 then additional years are added according to the length of the category - for example,
                  the third category (which corresponds to k = 4) adds 9 - 4 = 5 years to PotentialYears ;

                IF KidAgeRanges{k} = 2 THEN PotentialYears = PotentialYears + UpperBound{k} - UpperBound{k-1} ;

            END ;

            * Loop through each of the excess kids ;

            DO l = 1 TO ExcessKids ;

                * Initialise the Count and the ActualYears variables to zero for each loop ;

                Count = 0 ;

                ActualYears = 0 ;

                * Loop through each of the potentially topcoded age categories ;

                DO m = 2 TO 5 UNTIL ( Count = 1 ) ;

                    IF KidAgeRanges{m} = 2 THEN DO ;

                        * Create ActualYears using the same method as for PotentialYears, except now it's an 
                          incremental amount ;

                        ActualYears = ActualYears + UpperBound{m} - UpperBound{m-1} ;

                        IF RandExcessKid{l} < ActualYears / PotentialYears THEN DO ;

                            * Add the child to this age range ; 

                            KidAgeRangesi{m} = KidAgeRangesi{m} + 1 ;

                            * Setting Count = 1 stops the category do loop, since the kid has been allocated ;

                            Count = 1 ;  

                        END ;

                    END ;
                
                END ;

            END ;

        END ;

*******************************************************;
* Second step - allocate to individual years           ;
*******************************************************;

        * Allocate the kids in each of the categories randomly to individual ages to create the individual
          kid age variables ;

        * Loop through each of the age categories ;

        DO n = 2 to 5 ;

            %IndivYears(n)

        END ;

RUN ;


*******************************************************;
* Final step - drop variables not required elsewhere   ;
*******************************************************;
        
DATA Income&SurveyYear ;
        
    SET Income&SurveyYear ;

        DROP PotentialYears ExcessKids Blank1 Blank2 LowerBound1 LowerBound2 LowerBound3 LowerBound4
             LowerBound5 UpperBound1 UpperBound2 UpperBound3 UpperBound4 UpperBound5 k l Count 
             ActualYears m n Years Allocated ;

RUN ;

