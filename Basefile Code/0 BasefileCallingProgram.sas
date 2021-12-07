PROC DATASETS LIBRARY=WORK KILL NOLIST ; QUIT ;
**************************************************************************************
* Program:      BasefileCallingProgram.sas                                           *
* Description:  Generates the CAPITA basefiles for the survey year and for each of   *
*               the policy years for which the model is being run, by sequentially   *
*               calling the basefile component modules.                              * 
**************************************************************************************;

* Activate the 'IN' operator ;
OPTIONS MINOPERATOR ;  

* Call the DefineCapitaDirectory.sas module to set the CAPITA drive directory ;
%INCLUDE "\\CAPITALocation\DefineCapitaDirectory.sas" ;  

**************************************************************************************
*      1.        Set the survey year, the first policy year, the random number       *
*                generator setting, and whether to include the NPDs imputation.      *
**************************************************************************************;

* Create a macro variable called 'SurveyYear' and set it equal to the year of the SIH
  being used. For example, currently the 2017-18 SIH is used, so the variable is set to
  2017 ;
%LET SurveyYear = 2017 ; 

* Create a macro variable called 'PolicyYear' and set it equal to the first year for which
  the policy code runs. For example, if the policy year is 2019-20 this variable is set to 2019 ;
%LET PolicyYear = 2018 ;

* Create a macro variable called 'EndYear' and set it equal to the last year for which
  the basefile & policy code runs. For example, if the last year to be run is 2023-24 this variable is set to 2023;
%LET EndYear = 2024 ;

* Set whether to impute NPD records to account for aged people in nursing homes (Y), or to
  let benchmarking make up for the discrepancies (N) ;
%LET NpdImpute = N ;

* Set whether or not the random numbers should be regenerated (Y = regenerate,
  N = maintain current values) ; 
%LET RegenRandNums = N ;

**************************************************************************************
*      2.        Set directories for basefile modules and input spreadsheets.        *
**************************************************************************************;

* Location of SIH and Census CURFs ;
LIBNAME Library "\\SIHLocation\" ;                              
LIBNAME Census  "\\CensusLocation\" ; 

* Location of all basefile modules ;
FILENAME BaseMods "&CapitaDirectory.Basefile Code" ;

* Location of Excel spreadsheet containing the basefiles parameters ;
%LET ParamWkBk = &CapitaDirectory.Basefile Code\Parameters\Basefiles Parameters.xlsx ; 

* Location of imputations modules ;
FILENAME ImpMods "&CapitaDirectory.Basefile Code\Imputations" ;

* Location of random numbers datasets ;
LIBNAME RFNPD "&CapitaDirectory.Basefile Code\Random Numbers" ;
LIBNAME RFNoNPD "&CapitaDirectory.Basefile Code\Random Numbers (excluding NPDs)" ;

* Location of Excel spreadsheet containing the uprating data ;
%LET ImportLocation = &CapitaDirectory.Basefile Code\Uprating Data\Income Uprating Data.xlsx ;

* Location of the Benchmarking module ;
%LET BenchFolder = &CapitaDirectory.Basefile Code\Benchmarking\ ;

* Location of RunCAPITA ;
%LET RunCapita = &CapitaDirectory.RunCAPITA.sas ; 

* Location to export the basefiles to ;
LIBNAME ExpNPD "&CapitaDirectory.Basefiles" ;
LIBNAME ExpNoNPD "&CapitaDirectory.Basefiles (excluding NPDs)" ;  

**************************************************************************************
*      3.        Call the basefiles modules sequentially to create the CAPITA        *
*                basefiles. 					                                     *
**************************************************************************************;

* Read-in parameters required for basefiles modules ;
%INCLUDE BaseMods('1 BasefilesParameters.sas') ;

* Define key macros required for use in the basefiles modules ;
%INCLUDE BaseMods('2 BasefileMacros.sas') ;

* Read in the SIH variables required for the CAPITA basefiles, and rename the variables
  in accordance with CAPITA naming conventions ;
%INCLUDE BaseMods('3 ReadSIH.sas') ;

* Conduct the Non-Private Dwellings (NPDs) imputation ;

%MACRO NPDImputation ;

    %IF &NpdImpute = Y %THEN %DO ;

        * Read in the NPD modules to replicate SIH records for NPD Aged ;
        %INCLUDE BaseMods('4 NPDAged.sas') ;

        * Attach NPD records to the SIH datasets ;
        DATA Person&SurveyYear ;
            SET Person&SurveyYear NpdAged ;
        RUN ;

        * Set NPD flag to zero for non NPD records, to remove missing values ;
        DATA Person&SurveyYear ;    
            SET Person&SurveyYear ;
            IF NpdFlag = . THEN NpdFlag = 0 ;
        RUN ;

    %END ;

    %ELSE %DO ;

        * If NPD records are not being imputed, the NpdFlag variable is set to 
          zero for all records. This is used when constructing the identifiers
          in VariableConstruct2 ;
        DATA Person&SurveyYear ;
            SET Person&SurveyYear ;
            NpdFlag = 0 ;
        RUN ;

    %END ;    

%MEND NPDImputation;
%NPDImputation    

* Initialise and format variables ;
%INCLUDE BaseMods('5 BasefileInitialisation.sas') ;

* Create variables which are simple functions of SIH variables ;
%INCLUDE BaseMods ('6 VariableConstruct1.sas') ;

* Create random numbers to be used in the basefile modules and policy modules ;
%INCLUDE BaseMods ('7 RandomNumbers.sas') ;

* Create imputations ;
%INCLUDE ImpMods ('8A AllAgeImp.sas') ; 
%INCLUDE ImpMods ('8B CareDepsImp.sas') ;
%INCLUDE ImpMods ('8C WorkforceIndependenceImp.sas') ;
%INCLUDE ImpMods ('8D FrankCrImp.sas') ;
%INCLUDE ImpMods ('8E TaxDeductImp.sas') ; 

* Merge person level dataset onto income unit level dataset, and add household variables ;
%INCLUDE BaseMods ('9 Merge.sas') ;
%Merge (&SurveyYear) ;

* Create additional variables required for basefile and policy modules, but which require the
  merged dataset, or imputations ;
%INCLUDE BaseMods ('10 VariableConstruct2.sas') ;
%VariableConstruct2 ;
PROC SORT DATA = Basefile&SurveyYear ;
    BY IUID ;
RUN ;


* Prepare the uprating data and variable lists, and read in the uprating macro ;
%INCLUDE BaseMods ('11 PrepareForUprating.sas') ;

%INCLUDE BaseMods ('12 Uprate.sas') ;

* Call the macro in VariableConstruct3, to create additional variables which are constructed
  from variables across the policy years ;
%INCLUDE BaseMods ('13 VariableConstruct3.sas') ;
%VariableConstruct3(&SurveyYear) ;

* Create the policy years basefiles ;

%MACRO CreateBasefilesOutyears() ;

    %DO k = &PolicyYear %TO &EndYear ;

        /* Uprate the survey year basefile variables to the year of the basefile being created */

		%Uprate ( &k ) 

        /* Merge the uprated person and household level datasets and the income unit level dataset
           onto the basefile for this year, as well as the variables kept in IUKeptVars */

        %Merge ( &k ) 

        /* Calculate additional variables required for policy modules, but which require parameters 
           across the basefile years. Also, adjust the ages of individuals aged 65 in the survey year
           up to 66 in some basefile years, to ensure they still receive the age pension (see
           documentation for more details) */

        %VariableConstruct3 (&k )

        /* Drop basefiles parameters to ensure any policy parameters with the same names are correctly assigned
           in the policy modules */

        DATA Basefile&k ;

            SET Basefile&k ;

                DROP %KeepVar( &ParamList , 1 ) ;

        RUN ;

    %END ;

%MEND CreateBasefilesOutyears ;

%CreateBasefilesOutyears ;


%GLOBAL BasefileCreate ;
%LET BasefileCreate = Y ;
%INCLUDE "&BenchFolder.14 Benchmarking.sas" ;

* Export the basefiles ;

%MACRO ExportBasefiles ;

    %IF &NpdImpute = Y %THEN %DO ;

        %LET BFYearsList = &SurveyYear ;

        %DO BFY = &PolicyYear %TO %SYSEVALF (&EndYear) ;
            %LET BFYearsList = &BFYearsList - &BFY ;                      
        %END ;

        %PUT Now Exporting Basefiles for years &BFYearsList ;

        %DO y = 1 %TO ( %SYSFUNC ( COUNTW ( &BFYearsList , '-' ) ) ) ; 
            %LET BFYear = %SCAN ( &BFYearsList , &y , '-' ) ;     
            
			%IF &BFYear = 2020 %THEN %DO ; /* Do not export Basefile2020 */ 
			%END ; 
			%ELSE %DO ; 
            DATA ExpNPD.Basefile&BFYear ;

                SET Basefile&BFYear ;
				FORMAT _ALL_ ;

            RUN ;
			%END ; 

        %END ;

    %END ;

    %ELSE %DO ;

        %LET BFYearsList = &SurveyYear ;

        %DO BFY = &PolicyYear %TO %SYSEVALF (&EndYear) ;
            %LET BFYearsList = &BFYearsList - &BFY ;                      
        %END ;

        %PUT Now Exporting Basefiles for years &BFYearsList ;

        %DO y = 1 %TO ( %SYSFUNC ( COUNTW ( &BFYearsList , '-' ) ) ) ; 
            %LET BFYear = %SCAN ( &BFYearsList , &y , '-' ) ;        

			%IF &BFYear = 2020 %THEN %DO ; /* Do not export Basefile2020 */ 
			%END ; 
			%ELSE %DO ; 
            DATA ExpNoNPD.Basefile&BFYear ;

                SET Basefile&BFYear ;
				FORMAT _ALL_ ;

            RUN ;
			%END ; 

        %END ;

    %END ;
    

%MEND ExportBasefiles ;

%ExportBasefiles ;

