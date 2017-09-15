
**************************************************************************************
* Program:      RunParameters.sas                                                    *
* Description:  Generates the master parameter data set for all policies and all     *
*               periods. The parameters are read in from the Common Parameter        *
*               Spreadsheet (CPS).                                                   *
**************************************************************************************;

***********************************************************************************
*      1.         Specify Excel workbook                                          *
*                                                                                 *
**********************************************************************************;

* Include the DefineCapitaDirectory code to set the main CAPITA drive ;
%INCLUDE "\\CAPITAlocation\DefineCapitaDirectory.sas" ;

* Specify the location of Excel workbook containing the parameters ;
%LET ParamWkBk = \\CAPITAlocation\CPS v17-09-12.xlsb ;

* Specify common drive location ;
%LET AllParmDrive = &CapitaDirectory.Parameter\ ;

* Specify the location of parameters data sets are to be saved to ;
LIBNAME AllParmQ "&AllParmDrive.Quarter" ;

* Specify the location of annualised parameters data sets are to be saved to ;
LIBNAME AllParmA "&AllParmDrive.Annual" ;

* Specify list of work sheets to be read in ;
%LET WkShtListQ = Pensions 
                  PharmA 
                  RentA 
                  YouthDSP 
                  PPS 
                  Unemployment
                  YouthStudents 
                  YouthUnemployment 
                  DVA 
                  Carers 
                  PenEdSup 
                  SSDepIncLimit 
                  TelephoneUtility 
                  SeniorSup 
                  IncomeSupportBonus 
                  Childcare
                  SIFS 
                  TaxSchedule 
                  MedicareAndLevies 
                  RebatesOffsets
                  FTBA 
                  FTBB 
                  BabyBonus 
                  SchoolKidsBonus 
                  SuperBenefits ;

* Specify list of work sheets to be read in (annualised parameters) ;
%LET WkShtListA = Pensions_A 
                  PharmA_A 
                  RentA_A 
                  YouthDSP_A 
                  PPS_A 
                  Unemployment_A 
                  YouthStudents_A 
                  YouthUnemployment_A 
                  DVA_A 
                  Carers_A 
                  PenEdSup_A 
                  SSDepIncLimit_A 
                  TelephoneUtility_A 
                  SeniorSup_A 
                  IncomeSupportBonus_A 
                  Childcare_A
                  SIFS_A 
                  TaxSchedule 
                  MedicareAndLevies 
                  RebatesOffsets
                  FTBA_A 
                  FTBB_A 
                  BabyBonus_A 
                  SchoolKidsBonus_A 
                  SuperBenefits ;

* Specify start date from which point parameters are generated ;
* NOTE: Need to start from survey year ;
* Only parameters up to the end of the forward estimates period are generated ;
%LET ParamStartDate = '1JUL2013'd ;

***********************************************************************************
*      2.         Import parameters from Excel workbook                           *
*                                                                                 *
**********************************************************************************;

* Read in parameters from a spreadsheet. ;

%MACRO ImportXls( Period ) ;

    * Count number of work sheets ;
    %LET SheetNum = %SYSFUNC( COUNTW( &&WkShtList&Period ) ) ;

    * Loop through all work sheets ;
    %DO i = 1 %TO &SheetNum ;

        * Get work sheet name ;
        %LET SheetName = %SCAN( &&WkShtList&Period , &i ) ;
       
        * Import work sheet from Excel ;
        * Big enough to cover all cases - SAS does not actually use all this if there is no data ;
        PROC IMPORT 
            OUT = AllParm&Period..&SheetName
            ( WHERE = ( &ParamStartDate <= Date < INTNX( 'YEAR.7' , DATE() , 6 ) ) )       /* Read in the forward estimate period */
            DATAFILE = "&ParamWkBk"        
            DBMS = EXCELCS REPLACE ;
            SHEET = "&SheetName" ;
            RANGE = "A7:CC99" ;     
        RUN;

        * Build the combined parameters dataset ;
        %IF &i = 1 %THEN %DO ;

            DATA AllParm&Period..AllParams_&Period ;

                SET AllParm&Period..&SheetName ;

            RUN ;

        %END ;

        %ELSE %DO ;

        * Use PROC SQL rather than MERGE because some datasets have observations covering different periods. ;
        * For example, pensions has one observation per indexation quarter, while tax schedule has one observation 
          per financial year. We want the appropriate tax parameters read in for each quarter in this case, something 
          easy to arrange with SQL (note we assume the first table read in is quarterly) ;

            PROC SQL UNDO_POLICY = NONE ;   * The UNDO_POLICY option prevents warnings in the log about recursive referencing of AllParams ;
                * Renaming of date variables is done to avoid warnings in the log about multiple versions of these vars ;
                CREATE TABLE AllParm&Period..AllParams_&Period ( DROP = _date _enddate) AS
                SELECT * 
                FROM AllParm&Period..AllParams_&Period , AllParm&Period..&SheetName ( RENAME = ( date = _date enddate = _enddate ) )
                WHERE &SheetName.._date <= AllParams_&Period..date <= &SheetName.._enddate ;
            QUIT ;

        %END ;

    %END ;

    * Initialise all missing numeric parameter values to 0 to avoid messages in the log ;

    DATA AllParm&Period..AllParams_&Period ;

        SET AllParm&Period..AllParams_&Period ;
        DROP not_used: F1-F99 ;

        * Create array of all numeric variables ;
        ARRAY NumVars{ * } _NUMERIC_ ;

        * Initialise all missing numeric variables to 0 ;
        DO i = 1 TO HBOUND( NumVars ) ;

            IF NumVars{ i } = . THEN NumVars{ i } = 0 ;

        END ;

        DROP i ;

    RUN ;

%MEND ImportXls ;

* Generate quarterly parameters data sets ;
%ImportXls( Q )

* Generate annualised parameters data sets ;
%ImportXls( A )

*Import data containing probabibilities of being grandfathered to receive the ES for different payments - not available in this option; 

/*%MACRO ImportProbGrndfthr ( Period ) ; */
/**/
/*	 PROC IMPORT */
/*		 OUT = AllParm&Period..ProbGrndfthr_&Period*/
/*		 DATAFILE = "&AllParmDrive.Grandfathering ES\ProbGrndfth.xlsx"        */
/*		 DBMS = EXCELCS REPLACE ;*/
/*		 RANGE = "A1:O33" ;     */
/*		 SHEET = "&Period" ;*/
/*	 RUN;*/
/**/
/*%MEND ImportProbGrndfthr ; */
/**/
/*%ImportProbGrndfthr (Q); */
/*%ImportProbGrndfthr (A); */

