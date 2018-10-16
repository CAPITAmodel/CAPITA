
**************************************************************************************
* Program:      RunCAPITA.sas                                                        *
* Description:  Runs each of the policy modules of CAPITA sequentially, to produce   *
*               the CAPITA_Outfile dataset containing the tax and transfer policy    * 
*               outcomes.                                                            * 
**************************************************************************************;

OPTIONS NOFMTERR ;
***********************************************************************************
*      0.        Specify date of interest, and period of analysis                 *
*                                                                                 *
**********************************************************************************;

* Include the DefineCapitaDirectory code to set the main CAPITA drive ;
%INCLUDE "\\CAPITAlocation\Public\DefineCapitaDirectory.sas" ;

* Specify how to model the removal of the energy supplement; 
* Y = Choose to give everyone the ES; 
* N = Choose to give no-one the ES; 
%LET RunEs = Y; 

* Specify year and quarter of interest ;
%LET Year = 2015 ;     * Format 20XX = 20XX-YY ;  
%LET Quarter = Sep ;   * Valid quarters are Mar Jun Sep Dec ;

* Specify the time duration of analysis ;
* A for Annual, the financial year. This options uses annualised parameters calculated using time weighted average of each quarter ;
* Q for Quarter. This option uses actual parameter values from the appropriate quarter ;
%LET Duration = A ;

* Calculate relevant date flag, depending on Annual or Quarter run, and ES flag when specified in cameo code ;
%GLOBAL DateFlag RunCameo RunBenchmarkFlag ;
%MACRO DateFlagandEs ;
    /* Specify Year for Cameo run */
    %IF &RunCameo = Y %THEN %DO ;
        %LET Year = &CameoYear ;
        %LET Quarter = &CameoQuarter ;
        %LET Duration = &CameoDuration ;
		%LET RunEs = &CameoRunEs; 
    %END ;

    /* Specify Year for Basefile run */
    %IF &RunBenchmarkFlag = Y %THEN %DO ;
        %LET Year = &BmYear ;
        %LET Duration = A ;
    %END ;

    /* Calculate relevant date flag, depending on Annual or Quarter run */
    %IF &Duration = A %THEN %LET DateFlag = "1Jul&year."d ;
    %ELSE %IF &Duration = Q %THEN %LET DateFlag = "1&Quarter&Year."d ;
%MEND DateFlagandEs ;
%DateFlagandEs 

***********************************************************************************
*      1.         Specify basefile                                                *
*                                                                                 *
**********************************************************************************;

* Set Basefile directory. Sets the correct basefile used eg CAPITA basefile or Cameo basefile ;
%GLOBAL Basefile ;
%MACRO BasefileDir ;
    /* Specify Basefile for Cameo run */
    %IF &RunCameo = Y %THEN %DO ;
        %LET Work = %SYSFUNC( GETOPTION( Work ) ) ;
        LIBNAME Basefile "&Work" ;
        %LET Basefile = Capita_InputFile ;
    %END ;

    /* Specify Basefile for Create Basefile run */
    %ELSE %IF &RunBenchmarkFlag = Y %THEN %DO ;
        %LET Work = %SYSFUNC( GETOPTION( Work ) ) ;
        LIBNAME Basefile "&Work" ;
        %LET Basefile = Basefile&Year ;
    %END ;

    /* Specify name of Basefile for standard run */
    %ELSE %DO ;
        LIBNAME Basefile "&CapitaDirectory.Basefiles" ; 
        %LET Basefile = Basefile&Year ;
    %END ;
%MEND BasefileDir ;

%BasefileDir

* Specify name of Outfile ;
%LET Outfile = CAPITA_Outfile ;

***********************************************************************************
*      2.        Specify location of master parameters data set                   *
*                                                                                 *
**********************************************************************************;

* Specify location of master parameters data set. One for quarter and one for annual ;
* Parameters should be generated first using RunParameters ;
%LET ParmDrive = &CapitaDirectory.Parameter\ ;

LIBNAME AllParmQ "&ParmDrive.Quarter" ;

LIBNAME AllParmA "&ParmDrive.Annual" ;

***********************************************************************************
*      3.        Specify locations of policy modules                              *
*                                                                                 *
**********************************************************************************;

* Specify common directory for policy modules ;
%LET PolicyDrive = &CapitaDirectory.Policy Modules\ ;


* Specify name of policy modules ;
%LET Initialisation   = &PolicyDrive.1 Initialisation.sas ;           * Module 1 - Initialisation ;
%LET Income1          = &PolicyDrive.2 Income1.sas ;                  * Module 2 - Income 1 ;
%LET Dependants1      = &PolicyDrive.3 Dependants1.sas ;              * Module 3 - Dependants 1 ;
%LET DVA              = &PolicyDrive.4 DVA.sas ;                      * Module 4 - DVA payments ;
%LET Pension          = &PolicyDrive.5 Pensions.sas ;                 * Module 5 - Pension payments ;
%LET Allowance        = &PolicyDrive.6 Allowance.sas ;                * Module 6 - Allowance payments ;
%LET Income2          = &PolicyDrive.7 Income2.sas ;                  * Module 7 - Income 2 ;
%LET Dependants2      = &PolicyDrive.8 Dependants2.sas ;              * Module 8 - Dependants 2 ;
%LET FTB              = &PolicyDrive.9 FTB.sas ;                      * Module 9 - Family payments ;
%LET Supplement       = &PolicyDrive.10 Supplements.sas ;             * Module 10 - Supplements ;
%LET SaptoRebThres    = &PolicyDrive.SaptoRebThres.sas ;              * Additional code for Tax Module ;
%LET Tax              = &PolicyDrive.11 Tax.sas ;                     * Module 11 - Taxation ;
%LET Childcare        = &PolicyDrive.12 Childcare.sas ;               * Module 12 - Childcare ;
%LET Finalisation     = &PolicyDrive.13 Finalisation.sas ;            * Module 13 - Finalisation ;
 
***********************************************************************************
*      4.        Specify setup for macro-free version of policy modules           *
*                For a more comprehensive log output to aid debugging             *
**********************************************************************************;

* Specify whether to generate macro-free version of policy modules. Do not use quotation mark ;
%LET GenMacroFree = N ;

* Specify whether to run macro-free version of policy modules. Do not use quotation mark ;
%LET RunMacroFree = N ;

* Specify the location where the macro-free version of the code will be saved ;
* NOTE: new macro-free files will append to existing ones rather than overwrite them ;
%LET FileMacroFree = &CapitaDirectory.macrofree.sas ;

***********************************************************************************
*      5.        Read in parameters for the specified date and period             *
*                                                                                 *
**********************************************************************************;

* Parameters are read in for the specified date and period ;
%MACRO Param ;

    DATA Param ;

        /* Read in quarterly parameters */
        %IF %UPCASE( &Duration ) = Q %THEN %DO ;
            MERGE AllParmQ.AllParams_Q ; 
        %END ;

        /* Read in annualised parameters */
        %ELSE %IF %UPCASE( &Duration ) = A %THEN %DO ;
            MERGE AllParmA.AllParams_A ; 
        %END ;

        /* Read in parameters from the chosen period */
        WHERE Date <= &DateFlag < Enddate ;

    RUN ;

%MEND Param ;

%Param

***********************************************************************************
*      6.        Run policy modules                                               *
*                                                                                 *
**********************************************************************************;

* If GenMacroFree option is selected, SAS stores the resolved executable code produced by policy modules in a separate SAS file ;

%MACRO PrintLog ;
    %IF %UPCASE( &GenMacroFree ) = Y %THEN %DO ;
        FILENAME MPRINT "&FileMacroFree" ;
        OPTIONS MFILE MPRINT ;
    %END ;
%MEND PrintLog ;

* Create macro for running the childcare module if the cameo code is being run ;

%MACRO CallChildcare ;
    %IF &RunCameo = Y %THEN %DO ;
        %INCLUDE "&Childcare" ;
    %END ;
%MEND CallChildcare ;

* Include SAPTO function - additional code for module 11; 

/*

%MACRO DefineSaptoFunction ;

%IF %SYMEXIST(SaptoFuncDefined) %THEN %DO ;
	%LET SaptoFuncDefined = 1 ;
%END ;

%ELSE %DO ;
	%INCLUDE "&SaptoRebThres" ;              
	%GLOBAL SaptoFuncDefined ;
%END ;

%MEND DefineSaptoFunction ;

%DefineSaptoFunction ; 

*/

* Run policy modules in a data step ;

DATA &Outfile ;

    * Options settings ;
    OPTIONS MINOPERATOR NOMFILE NOMPRINT NOSOURCE2 ;

    %PrintLog 
    
    * Set parameters and basefile ;
    IF _n_ = 1 THEN SET Param ;

    %LET BasefileLib = Basefile ;
    SET &BasefileLib..&Basefile ;

    BY FamId ;

    * Include code for each policy modules ;
    %INCLUDE "&Initialisation" ;                
    %INCLUDE "&Income1" ;                       
    %INCLUDE "&Dependants1" ;                   
    %INCLUDE "&Dva" ;                          
    %INCLUDE "&Pension" ;                       
    %INCLUDE "&Allowance" ;                    
    %INCLUDE "&Income2" ;                        
    %INCLUDE "&Dependants2" ;                    
    %INCLUDE "&FTB" ;                           
    %INCLUDE "&Supplement" ;                     
    %INCLUDE "&Tax" ; 
    %CallChildcare
    %INCLUDE "&Finalisation" ; 

RUN ;

* Switch off print log options to return log options back to default ;
OPTIONS NOMFILE NOMPRINT NOSOURCE2 ;

***********************************************************************************
*      7.        (Optional) Run macro-free version of policy modules              *
*                                                                                 *
**********************************************************************************;

* If the RunMacroFree option is selected then run the macro-free version of policy modules in order to produce a comprehensive runtime log ;

%MACRO RunMacroFree ;

    %IF %UPCASE( &RunMacroFree ) = Y %THEN %DO ;

        DATA &Outfile ;

            IF _n_ = 1 THEN SET Param ;

            SET Basefile.&Basefile ;

            BY FamId ;    

            OPTIONS SOURCE2 ;

            %INCLUDE "&FileMacroFree" ;

        RUN ;

    %END ;

%MEND RunMacroFree ;

%RunMacroFree 

%SYMDEL RunCameo RunBenchmarkFlag Basefile ;
