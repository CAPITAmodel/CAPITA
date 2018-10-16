
**************************************************************************************
* Program:      BasefileMacros.sas                                                   *
* Description:  This program creates generic macros for use throughout the basefiles *
*               modules.                                                             * 
**************************************************************************************;

**************************************************************************************
*     Define macro 'KeepVar' used to keep required variables                         *  
**************************************************************************************;

*   Define the macro 'KeepVar' which serves the purpose of writing a list of variable names to be kept.
    The macro arguments are: 
    'VarList'  - This is the name of the variable list containing the variables to be kept 
    'SkipNum'  - This defines the number of variables to skip in the loop to account for other variables
                 or words (e.g. labels) contained in the list ;

%MACRO KeepVar( VarList , SkipNum ) ;

    %* Define number of variables in list ;
    %LET NumVars = %SYSFUNC( COUNTW( &VarList ) ) ;
    
    %* Select each variable that needs to be kept ; 
    %DO i = 1 %TO &NumVars %BY &SkipNum ;

        %SCAN( &VarList , &i , - ) 

    %END ;

%MEND KeepVar ;


**************************************************************************************
*     Define macro 'Rename' to write the renaming code in ReadSIH                    *  
**************************************************************************************;

*   Define the macro 'Rename' which serves the purpose of writing the text required in the data step to
    rename the variables from their old names to their new names. 
    The four macro arguments are: 
    'NameList' - Defines the input variable list that will be renamed
    'StartPos' - Defines the starting position of the list - for example, 1 will keep all the names in the
                 first column of a list
    'SkipNum'  - Defines the number of variables to skip in the loop to account for other variables or words
                 (e.g. labels) defined in the list
    'Suffix’   - Attaches a suffix to the end of the new variable name ;

%MACRO Rename( NameList , StartPos , SkipNum ) ;

    %LET NumVars = %SYSFUNC ( COUNTW ( &NameList ) ) ;

    %DO i = &StartPos %TO &NumVars %BY &SkipNum ;

        %* Select SIH name ;
        %LET SihName = %SCAN( &NameList , &i , - ) ;

        %* Select CAPITA name ;
        %LET CapitaName = %SCAN( &NameList , %EVAL( &i + 1 ) , - ) ;

        %* Remove blanks from CAPITA name ;
        %LET CapitaName = %SYSFUNC( STRIP( &CapitaName ) ) ;

        %* Write rename pair ;
        &SihName = &CapitaName 

    %END ;

%MEND Rename ;


**************************************************************************************
*     Define macro 'RenameSuffix' to replace the p suffix with r,s,1-5               *
**************************************************************************************;

%MACRO RenameSuffix( NameList , StartPos , SkipNum , Suffix ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &NameList ) ) ;

    %DO i = &StartPos %TO &NumVars %BY &SkipNum ;

        %* Select CAPITA name ;
        %LET CapitaName = %SCAN( &NameList , %EVAL( &i ) , - ) ;

        %* Remove the p suffix from the CAPITA name ;
        %LET CapitaNameNoSuff = %SUBSTR( &CapitaName , 1 , %LENGTH ( &CapitaName ) - 1 ) ; 

        %* Write rename pair to attach the r,s,1-5 suffix instead ;
        &CapitaName = &CapitaNameNoSuff.&Suffix 

    %END ;

%MEND RenameSuffix ;
