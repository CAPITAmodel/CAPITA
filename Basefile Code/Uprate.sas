
**************************************************************************************
* Program:      Uprate.sas                                                           *
* Description:  Performs uprating on the necessary variables in the CAPITA basefiles.*                                                            
**************************************************************************************;

%MACRO Uprate ( BasefileYear ) ;

    * First extract the uprating factors from the uprating dataset for the required basefile year being
      created ;

    DATA UpratingFactors&BasefileYear ;

        SET UpratingData ;
                    
            WHERE Year = &BasefileYear ;

    RUN ;

    * Then merge the uprating factors onto each of the person and household level basefiles ;

    DATA Person&BasefileYear ;

        IF _N_ = 1 THEN SET UpratingFactors&BasefileYear ;

            SET Person&SurveyYear ;

    RUN ;

    DATA Income&BasefileYear ;

        IF _N_ = 1 THEN SET UpratingFactors&BasefileYear ;

            SET Income&SurveyYear ;

    RUN ;

    DATA Household&BasefileYear ;

        IF _N_ = 1 THEN SET UpratingFactors&BasefileYear ;

            SET Household&SurveyYear ;

    RUN ;

    * Then perform the uprating by calling the 'UprateCommand' macro defined in
	  the PrepareForUprating module ;

    DATA Person&BasefileYear ;

        SET Person&BasefileYear ;

            %UprateCommand( &UpratingMethodsPerson )

    RUN ;

    DATA Household&BasefileYear ;

        SET Household&BasefileYear ;

            %UprateCommand( &UpratingMethodsHousehold )

    RUN ;

    * Drop the uprating factors ;

    DATA Person&BasefileYear ;

        SET Person&BasefileYear ;

            %LET NumVars = %SYSFUNC( COUNTW( &UpratingSeriesList ) ) ;

                %DO m = 1 %TO &NumVars ;

                    %LET DropSeries = %SCAN( &UpratingSeriesList , %EVAL( &m ) , - ) ;

                    DROP Year &DropSeries ; 

                %END ; 

    RUN ;

    DATA Income&BasefileYear ;

        SET Income&BasefileYear ;

            %LET NumVars = %SYSFUNC( COUNTW( &UpratingSeriesList ) ) ;

                %DO p = 1 %TO &NumVars ;

                    %LET DropSeries = %SCAN( &UpratingSeriesList , %EVAL( &p ) , - ) ;

                    DROP Year &DropSeries ; 

                %END ; 

    RUN ;

    DATA Household&BasefileYear ;

        SET Household&BasefileYear ;

            %LET NumVars = %SYSFUNC( COUNTW( &UpratingSeriesList ) ) ;

                %DO q = 1 %TO &NumVars ;

                    %LET DropSeries = %SCAN( &UpratingSeriesList , %EVAL( &q ) , - ) ;

                    DROP Year &DropSeries ; 

                %END ; 

    RUN ;

%MEND Uprate ;
