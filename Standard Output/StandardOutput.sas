***********************************************************************************
* Name of program: Standard Output.sas                                            *
* Date:        18 December 2014                                                   *
* Status:      Completed first draft                                              *
* Description: Produces standard output of distirbutional and impact analysis for *
*               export either to html or to an Excel spreadsheet. RunCapitaCompare*
*               must be run before producing Standard Output.                     *
**********************************************************************************;

* The Master macro StandardOutput gives an overview of the code ;

%MACRO StandardOutput ;

    ********************************************************************************
    1. Define lists of variables analysed and helpful macros
    ********************************************************************************;

    ********************************************************************************
    2. Extract person and household level datasets 
    ********************************************************************************;

    * Create person and household unit level datasets ;

    %PersonLevelData 
    %HHConversion 

    ********************************************************************************
    3. Output individual and household summaries of chosen variables
    ********************************************************************************;

    * Create a summary dataset of all required payments at an individual and household 
      unit level ;

    %IndSummary  
    %HHSummary

    ********************************************************************************
    4. Output individual income distribution charts
    ********************************************************************************;

    * Create income distributions at the person and household levels ;

    %IncomeDistributions( Person )
    %IncomeDistributions( HH )

    ********************************************************************************
    5. Output FTBA detailed payment information
    ********************************************************************************;

    * Summary of FTBA at the income unit level ;

    %FTBASummary 

    ********************************************************************************
    6. Output household type information
    ********************************************************************************;

    * Create Equivalised Incomes for family type analysis ;

    %Equivalise 

    * Split into family types at different income levels and output data ;

    %FamType 
    %FamTables 

    ********************************************************************************
    7. Output Equivalised Quintile information
    ********************************************************************************;

    * Quintile analysis based on different income splits ;

    %Quintiles( Disp )
    %Quintiles( Priv )

    * Winner and Loser Analysis will be run only if Policy analyis is chosen ;

    %IF &comparetype = Policy %THEN %DO ;

        %WinLoss 

    %END ;

%MEND StandardOutput ;

* Variables used to identify units at various levels ;

%LET IdList =       HHID -
                    FAMID -
                    IUID -
                    Psn -
                    ;

* Income variables for distributions at household unit level ;

%LET VarListHInc =  IncPrivA -
                    IncDispA -
                    TaxIncA -
                    AdjTaxIncA -
                    ;

* Income variables for individuals at the individual level ;

%LET VarListInc =   &varlistHinc
                    ;

* Transfer income variables for individuals at the individual level ;
%LET VarListTranIncTest = IncAllTestF -
                          IncPenTestF -
                          IncDvaTestF -                      
                          ;

* Transfer income variables for individuals at the individual level ;
%LET VarListTranInc = AgeTotA - IncPenTestF -
                      DspTotA - IncPenTestF -
                      CarerTotA - IncPenTestF -
                      PpsTotA - IncPenTestF -
                      WifeTotA - IncPenTestF -
                      PppTotA - IncAllTestF -
                      NsaTotA - IncAllTestF -
                      YaOtherTotA - IncAllTestF -
                      YaStudTotA - IncAllTestF -
                      YaTotA - IncAllTestF -
                      AustudyTotA - IncAllTestF -
                      WidowTotA - IncAllTestF -
                      SpbAllNmA - IncAllTestF -
                      SickAllNmA - IncAllTestF -
                      PartnerAllNmA - IncAllTestF -
                      AbstudyNmA - IncAllTestF -
                      FtbaA - AdjTaxIncA - 
                      FtbbA - AdjTaxIncA - 
                      DvaDisPenNmA - IncDvaTestF - 
                      DvaWwPenNmA - IncDvaTestF - 
                      DvaTotA - IncDvaTestF - 
                      ;

* Variables of interest which are recorded for all members of the income unit ;

%LET VarListFam =   &varlistinc
                    PayOrRefAmntA -
                    GrossIncTaxA -
                    TotTaxOffsetA -
                    UsedTotTaxOffsetA - 
                    LitoA -
                    UsedLitoA -
                    BentoA -
                    UsedBentoA -
                    NetIncTaxA -
                    MedlevA -
                    MedlevsurA -
                    FrankCrImpA -
                    UsedFrankCrA -
                    YaTotA -
                    TempBudgRepLevA -
                    YaOtherTotA -
                    YaStudTotA -
                    IncAllTestF -
                    IncTranA -
                    ;

* Variables of interest which are recorded for reference and spouse for the income unit ;

%LET VarListCoup =  AgeTotA -
                    AbstudyNmA -
                    AustudyTotA -
                    DspTotA -
                    SickAllNmA -
                    CareAllA -
                    CarerTotA -
                    DspU21TotA -
                    DvaDisPenNmA - 
                    DvaWwPenNmA -
                    TelAllA -
                    UtilitiesAllA - 
                    SenSupTotA -
                    CareSupA -
                    PartnerAllNmA -
                    IncSupBonA -
                    SifsA -
                    FtbaA -
                    FtbbA -
                    SkBonusA -
                    DstoA -
                    DictoA -
                    MawtoA -
                    SaptoA -
                    NsaTotA -
                    PppTotA -
                    SpbAllNmA -
                    UsedSaptoA -
                    SuperToA -
                    DvaTotA -
                    ;

* Variables of interest which are recorded for the spouse only ;

%LET VarListSps =   WifeTotA - ;

* Variables of interest which are recorded for the reference person only ;

%LET VarListRef =   WidowTotA - 
                    PpsTotA -                    
                    ;

* Variables of interest which are recorded at an income unit level ;

%LET VarListHH =    FtbaMaxTotal -
                    FtbaBaseTotal -
                    FtbaMaxNet -
                    IncPenTestF -
                    IncDvaTestF - 
                    ;

* All variables of interest for summary comparison between base and sim ;

%LET VarListAll =   &varlistfam
                    &varlistHH
                    &varlistcoup 
                    &varlistsps
                    &varlistref 
                    ;

* Lists of suffixes that apply to different individuals within the unit ;

%LET Personsfam =   r -
                    s -
                    1 -
                    2 -
                    3 -
                    4 -
                    ;

%LET PersonsSps =   s ;

%LET PersonsRef =   r ;

%LET PersonsCoup =  r -
                    s -
                    ;

* Variable list for impact analysis ;

%LET varcomplist =  IncDispAu -
                    IncDispEquivAu - 
                    FtbaFinalA -
                    FtbbFinalA -
                    IncTranAu -
                    PayOrRefAmntAu -
                    ;

PROC FORMAT ;

    * Format used for Income Distribution tables ;

    VALUE Income_fmt
       LOW -      0 =  '      $0 or less    '
        0< -  10000 =  '      $1 to $10,000 '
     10000< -  20000 = ' $10,001 to  $20,000'
     20000< -  30000 = ' $20,001 to  $30,000'
     30000< -  40000 = ' $30,001 to  $40,000'
     40000< -  50000 = ' $40,001 to  $50,000'
     50000< -  60000 = ' $50,001 to  $60,000'
     60000< -  70000 = ' $60,001 to  $70,000'
     70000< -  80000 = ' $70,001 to  $80,000'
     80000< -  90000 = ' $80,001 to  $90,000'
     90000< - 100000 = ' $90,001 to $100,000'
    100000< - 110000 = '$100,001 to $110,000'
    110000< - 120000 = '$110,001 to $120,000'
    120000< - 130000 = '$120,001 to $130,000'
    130000< - 140000 = '$130,001 to $140,000'
    140000< - 150000 = '$140,001 to $150,000'
    150000< - 160000 = '$150,001 to $160,000'
    160000< - 170000 = '$160,001 to $170,000'
    170000< - 180000 = '$170,001 to $180,000'
    180000< - 190000 = '$180,001 to $190,000'
    190000< - 200000 = '$190,001 to $200,000'
    200000< - 210000 = '$200,001 to $210,000'
    210000< - 220000 = '$210,001 to $220,000'
    220000< - 230000 = '$220,001 to $230,000'
    230000< - 240000 = '$230,001 to $240,000'
    240000< - 250000 = '$240,001 to $250,000'
    250000< - 260000 = '$250,001 to $260,000'
    260000< - 270000 = '$260,001 to $270,000'
    270000< - 280000 = '$270,001 to $280,000'
    280000< - 290000 = '$280,001 to $290,000'
    290000< - 300000 = '$290,001 to $300,000'
    300000< -   HIGH = '$300,000+           '
    ;

    * Format used for Transfer Payment charts ;

    VALUE TranInc_fmt
    LOW - 0         = '    $0 or less  '
    0<   - 100      = '    $1 to $100  '
    100< - 200      = '  $101 to $200  '
    200< - 300      = '  $201 to $300  '
    300< - 400      = '  $301 to $400  '
    400< - 500      = '  $401 to $500  '
    500< - 600      = '  $501 to $600  '
    600< - 700      = '  $601 to $700  '
    700< - 800      = '  $701 to $800  '
    800< - 900      = '  $801 to $900  '
    900< - 1000     = '  $901 to $1,000'
    1000< - 1100    = '$1,001 to $1,100'
    1100< - 1200    = '$1,101 to $1,200'
    1200< - 1300    = '$1,201 to $1,300'
    1300< - 1400    = '$1,301 to $1,400'
    1400< - 1500    = '$1,401 to $1,500'
    1500< - 1600    = '$1,501 to $1,600'
    1600< - 1700    = '$1,601 to $1,700'
    1700< - 1800    = '$1,701 to $1,800'
    1800< - 1900    = '$1,801 to $1,900'
    1900< - 2000    = '$1,901 to $2,000'
    2000< - 2100    = '$2,001 to $2,100'
    2100< - 2200    = '$2,101 to $2,200'
    2200< - 2300    = '$2,201 to $2,300'
    2300< - 2400    = '$2,301 to $2,400'
    2400< - 2500    = '$2,401 to $2,500'
    2500< - 2600    = '$2,501 to $2,600'
    2600< - 2700    = '$2,601 to $2,700'
    2700< - 2800    = '$2,701 to $2,800'
    2800< - 2900    = '$2,801 to $2,900'
    2900< - 3000    = '$2,901 to $3,000'
    3000< -  HIGH   = '$3,000+         '
    ;

    * Formats used for Family Type Analysis ;

    VALUE iutypeA 
    1-3        = 'Working age single          '
    4-6        = 'Working age sole parent'
    7-9        = 'Working age couple no deps'
    10-12      = 'Working age couple with deps'
    13         = 'Senior single'
    14         = 'Senior couple' 
    ;

    VALUE iutypeB 
    1  = 'Single  - Low inc          '
    2  = 'Single  - Med inc'
    3  = 'Single  - High inc'
    4  = 'Sole parent  - Low inc'
    5  = 'Sole parent  - Med inc'
    6  = 'Sole parent  - High inc'
    7  = 'couple no deps - Low inc'
    8  = 'couple no deps - Med inc'
    9  = 'couple no deps - High inc'
    10 = 'couple with deps - Low inc'
    11 = 'couple with deps - Med inc'
    12 = 'couple with deps - High inc'
    13 = 'Senior single'
    14 = 'Senior couple'
    ;

    VALUE incthr 
    1 = 'Low inc '
    2 = 'Med inc'
    3 = 'High inc'
    4 = 'Seniors'
    ;

    VALUE iupaymenttype
    0 = 'No Carer, DSP or Pensions        '
    1 = 'Disability Support Pension family'
    2 = 'Carer Payment family'
    3 = 'Max rate pensioner single'
    4 = 'Max rate pensioner couple'
    5 = 'Part rate pensioner single'
    6 = 'Part rate pensioner couple'
    ;

    * Format used in winner and loser analysis ;

    VALUE dispincchangePROP
    LOW     -< -0.5  = 'L More than 50 percent'
    -0.5    -< -0.2  = 'L 20 to 50 percent'
    -0.2    -< -0.1  = 'L 10 to 20 percent'
    -0.1    -< -0.05 = 'L 5 to 10 percent'
    -0.05   -< -0.03 = 'L 3 to 5 percent'   
    -0.03   -< -0.01 = 'L 1 to 3 percent'
    -0.01   -<  0    = 'L 1 percent or less' 
                0    = 'No change'
    0       <-  0.01 = 'G 1 percent or less'
    0.01    <-  0.03 = 'G 1 to 3 percent'
    0.03    <-  0.05 = 'G 3 to 5 percent'
    0.05    <-  0.1  = 'G 5 to 10 percent'
    0.1     <-  0.2  = 'G 10 to 20 percent'
    0.2     <-  0.5  = 'G 20 to 50 percent'
    0.5     <- HIGH  = 'G More than 50 percent'
    ;   

    * Formats used in winner and loser analysis ;

    VALUE dispincchangePROP
    LOW     -< -0.5  = 'L More than 50 percent'
    -0.5    -< -0.2  = 'L 20 to 50 percent'
    -0.2    -< -0.1  = 'L 10 to 20 percent'
    -0.1    -< -0.05 = 'L 5 to 10 percent'
    -0.05   -< -0.03 = 'L 3 to 5 percent'   
    -0.03   -< -0.01 = 'L 1 to 3 percent'
    -0.01   -<  0    = 'L 1 percent or less' 
                0    = 'No change'
    0       <-  0.01 = 'G 1 percent or less'
    0.01    <-  0.03 = 'G 1 to 3 percent'
    0.03    <-  0.05 = 'G 3 to 5 percent'
    0.05    <-  0.1  = 'G 5 to 10 percent'
    0.1     <-  0.2  = 'G 10 to 20 percent'
    0.2     <-  0.5  = 'G 20 to 50 percent'
    0.5     <- HIGH  = 'G More than 50 percent'
    ;   

    VALUE dispincchangeABS
    LOW    -< -5000  = 'L More than $5,000'
    -5000  -< -2500  = 'L $2,500 to $5,000'
    -2500  -< -1000  = 'L $1,000 to $2,500'
    -1000  -< -500   = 'L $500 to $1,000'
    -500   -< -200   = 'L $200 to $500'   
    -200   -< -50    = 'L $50 to $200'
    -50    -<  0     = 'L $50 or less' 
               0     = 'No change'
    0      <-  50    = 'G $50 or less'
    50     <-  200   = 'G $50 to $200'
    200    <-  500   = 'G $200 to $500'
    500    <-  1000  = 'G $500 to $1,000'
    1000   <-  2500  = 'G $1,000 to $2,500'
    2500   <-  5000  = 'G $2,500 to $5,000'
    5000   <- HIGH  =  'G More than $5,000'
    ;   

RUN ;

* Specify the location of the workbook for standard output if exporting to Excel ;

%MACRO StandardOutputWorkBook ;

    * Macro sets the location of the Standard Output workbook depending on the type of run. ;

    * Specify the type of analysis to be undertaken (which will change the detail of 
        output produced) as part of RunCapitaCompare ;
    * Policy for a comparison between different paramters or policy settings. Will 
        include winner/loser analysis as well as distributional information ;
    * Version for a comparison between different basefiles. Will include only summaries 
        of payment statistics and distributional information ;

%IF &ExcelOut = Y %THEN %DO ;

    %GLOBAL StandOutE ;

    %LET timenow=%sysfunc(time(), B8601TM.) ;
    %LET datenow=%sysfunc(date(), YYMMDD.) ;

    * Point to time stamped copy of standard output ;
    %IF &CompareType = Policy %THEN %DO ;   
        %LET InSoFile = &SOFolder.Capita SO template.xlsx ;
        %LET standoutE = &SOFolder.&datenow &timenow Capita SO.xlsx ;
    %END ;

    %ELSE %IF &CompareType = Version %THEN %DO ;
        * Same template as Policy. Win/Loss table probably will not make sense when comparing basefiles ;
        %LET InSoFile = &SOFolder.Capita SO template.xlsx ; 
        %LET standoutE = &SOFolder.&datenow &timenow Capita SO Version.xlsx ;
    %END ;

    * recfm=N allows copying of binary files ;
    FILENAME InSO "&InSoFile" recfm=N ;
    FILENAME OutSO "&standoutE" recfm=N ;

    DATA _NULL_;
      RC= FCOPY('InSO', 'OutSO') ;
    RUN;
    
    * Clear file reference ;
    FILENAME InSO clear ;
    FILENAME OutSO clear ;

%END ;

%MEND StandardOutputWorkBook ;

%StandardOutputWorkBook 

%MACRO outputExcel( dataset , tab ) ;

    * Macro to output to Excel workbook ;

    %IF &ExcelOut = Y %THEN %DO ;

        PROC EXPORT DATA = &dataset
            OUTFILE = "&standoutE"  
            DBMS = EXCELCS REPLACE ;
            SHEET = "&tab" ;
        RUN ;

    %END ;

%MEND outputExcel ;

%MACRO UnitPersData ;

    * Create base and sim level data sets and initially fill with unit level data - 
        allocating income unit amounts nominally to the reference to avoid double counting;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        %LET idkeeplist = %SYSFUNC( COMPRESS( &idlist , '-' ) ) ;
        * Store the list of variables to keep without the - breaks ;
        %GLOBAL keeplist&world;
        %LET keeplist&world = weight_&world. &idkeeplist ;

        DATA &world ;
            SET Capita_Outfile_&world (RENAME = HHID_&world = HHID
                         RENAME = IUID_&world = IUID
                         ) ;

            LENGTH Psn $8 ;
            Psn = 'r' ;

            %DO j = 1 %TO %SYSFUNC( countw( &varlistHH , '-' ) ) ; 
                *loop through list of variables;  
                %LET var = %SCAN( &varlistHH , &j , '-' ) ; 
                * set var = variable name from varlist;
                %LET keeplist&world = &&keeplist&world &var._&world ; 
                *add variable name to keeplist;
            %END ;   

        RUN ;

        PROC SORT DATA = &world ;
            BY IUID psn ;
        RUN ;

    %END ;

%MEND UnitPersData ;

%MACRO IndPersData(pers) ;

    *Extract person level base and sim data and extract to individual data sets for
        each type of variable ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        %LET idkeeplist = %SYSFUNC( COMPRESS( &idlist , '-' ) ) ;
        %LET keeplist&world.&pers = &idkeeplist weight_&world ; 
        * Each record is assigned the weight from their income unit and retains 
            ID variables ;
        
        DATA &world.&pers ;
            SET &world ;

            %DO i = 1 %TO %SYSFUNC( countw( &&persons&pers , '-' ) ) ;  
            * loop through persons in the relevant perslist ;  
                %LET suffix = %SCAN( &&persons&pers , &i , '-' ) ;   
                * set suffix = person identfier e.g. 'r' ;
                IF ActualAge&suffix._&world > 0 THEN DO ;                   
                * check person exists ;
                    Psn = "&suffix" ;
        
                    %DO j = 1 %TO %SYSFUNC( countw( &&varlist&pers , '-' ) ) ; 
                    *loop through list of variables ;  
                        %LET var = %SCAN( &&varlist&pers , &j , '-' ) ; 
                        * set var = variable name from varlist ;
                        %IF &i = 1 %THEN %DO ; 
                            %LET keeplist&world.&pers = &&keeplist&world.&pers &var._&world ; 
                            *add variable name to keeplist ;
                        %END ;
                            
                        &var._&world = &var.&suffix._&world ;

                    %END ;
                    OUTPUT &world.&pers ;
                END ;
            %END ;

            * Only keep the variables we are interested in on this smaller data set ;
            KEEP &&keeplist&world.&pers ; 
        RUN ;

        %LET keeplist&world = &&keeplist&world &&keeplist&world.&pers ;

        PROC SORT DATA = &world.&pers ;
            BY IUID Psn ;
        RUN ;

    %END ;

%MEND IndPersData ;

%MACRO PersonLevelData ;

    * Run the macros above to create component datasets and then combine ;

    %UnitPersData 

    %IndPersData(ref) 
    %IndPersData(sps) 
    %IndPersData(coup) 
    %IndPersData(fam) 

    * Merge the individual datasets together to create base and sim person 
        level data sets;

    DATA Base ;
        MERGE Base BaseRef BaseSps BaseCoup BaseFam ;
        BY IUID Psn ;
    RUN;

    DATA Sim ; 
        MERGE Sim SimRef SimSps SimCoup SimFam ;
        BY IUID Psn ;
    RUN;

    * Combine base and sim data into a single dataset ;

    DATA Person ;
        MERGE Base ( KEEP = &keeplistbase ) Sim ( KEEP = &keeplistsim ) ;
        BY IUID Psn ;
        dummy = 1 ;
    RUN ;

%MEND PersonLevelData ;

%MACRO HHConversion ;

    *Create summary base and simulation data at the household level using the means 
        procedure ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        %LET incomes&world = ;

        %DO j = 1 %TO %SYSFUNC( countw( &varlistHinc , '-' ) ) ;
            %LET var = %SCAN( &varlistHinc , &j , '-' ) ;
            %LET incomes&world = &&incomes&world &var._&world ;
        %END;

        * Sum of all the variables of interest across income units within a household to 
        get total value for each variable for each household (which by design will 
        be the same for each income unit in the household);
        
        PROC MEANS DATA = Person NOPRINT NWAY ;
            CLASS HHID ;
            VAR weight_&world &&incomes&world ;
            OUTPUT  OUT = HH&world
                    SUM ( &&incomes&world )=
                    MEAN (weight_&world ) = ;
        RUN ;

    %END ;

    * Combine base and simulation data into a single household level dataset ;

    DATA HH ;
        MERGE HHBase HHSim ;
        BY HHID ;
        dummy = 1 ;
    RUN ;

%MEND HHConversion ;

%MACRO IndSummary ;

    * Creates and outputs summary level statistics across a range of variables 
        on an individual unit level ;

    %GLOBAL datasets ;   
    %LET datasets = ;

    %DO k = 1 %TO 2;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        %DO j = 1 %TO %SYSFUNC( countw( &varlistall , '-' ) ) ;  
        * Loop through variables ;
            %LET var = %SCAN( &varlistall , &j , '-' ) ;
        * Select the next variable name ;

            %LET datasets = &datasets &var._&world ;   
            * generate a list of datasets to process ;

            * Get summary stats for each payment type which are output as individual datasets ;
            PROC MEANS DATA = Person NOPRINT ;       
                WHERE ( &j LE %SYSFUNC( countw( &varlistinc , '-' ) ) ) OR (&var._&world > 0) ; 
                * Exclude records where payment <= 0, except for income variables, first listed by construction ;
                VAR &var._&world ;
                WEIGHT weight_&world. ;
                OUTPUT  OUT = &var._&world MEAN = mean 
                                           MEDIAN = median 
                                           MIN = min 
                                           MAX = max 
                                           N = n
                                           SUMWGT = sumwgt ; 
            RUN ;

            DATA &var._&world ;
                SET &var._&world ;
                LENGTH Payment $24 ;
                Payment  = "&var._&world" ;
            RUN ;
        %END ;
    %END ;

    * Combine all the data into a single data set and remove the unnecasary variables ;
    DATA Summary ;                                  
        SET &datasets ;
        DROP _type_ _freq_ ;
    RUN ;

    %SYMDEL datasets keeplistbase keeplistsim ;
    * These macro variables are recursively defined, so must be cleared so they do not accumulate with multiple runs ;

    * Reorder the dataset so that the variable names are in the first column ;
    DATA Summary ;
        RETAIN Payment ;
        SET Summary ;
    RUN ;

    %OutputExcel( Summary , Summary_payments ) 

    %IF &ExcelOut = N %THEN %DO ;
        PROC PRINT 
            Data = Summary NOOBS ;
        RUN ;
    %END ;

%MEND IndSummary ;

%MACRO HHSummary ;

    * Creates and outputs summary of incomes on the household level ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        * Initialise as blank all of the macro variables relating to statistics we want to output ;
        %LET Hincomes&world = ;
        %LET MeanHincomes&world = ;
        %LET MedianHincomes&world = ;
        %LET MinHincomes&world = ;
        %LET MaxHincomes&world = ;
        %LET SumwgtHincomes&world = ;
        %LET RecsHincomes&world = ;

        %DO j = 1 %TO %SYSFUNC( countw( &varlistHinc , '-' ) ) ;
            %LET var = %SCAN( &varlistHinc , &j , '-' ) ;
            * Loop through the household income variables of interest and create the summary statistics ;
            %LET Hincomes&world = &&Hincomes&world &var._&world ;
            %LET MeanHincomes&world = &&MeanHincomes&world Mean&var._&world ;
            %LET MedianHincomes&world = &&MedianHincomes&world Median&var._&world ;
            %LET MinHincomes&world = &&MinHincomes&world Min&var._&world ;
            %LET MaxHincomes&world = &&MaxHincomes&world Max&var._&world ;
            %LET SumwgtHincomes&world = &&SumWgtHincomes&world SumWgt&var._&world ;
            %LET RecsHincomes&world = &&RecsHincomes&world Recs&var._&world ;
        %END;       

        * Use proc means to create the statistics we want ;
        PROC MEANS DATA = HH NWAY ;
            CLASS ;
            VAR &&Hincomes&world ;
            WEIGHT weight_&world ;
            OUTPUT OUT = SummHH&world    MEAN( &&Hincomes&world ) 
                                 = &&MeanHincomes&world
                                 MEDIAN( &&Hincomes&world ) 
                                 = &&MedianHincomes&world
                                 MIN( &&Hincomes&world ) 
                                 = &&MinHincomes&world
                                 MAX( &&Hincomes&world ) 
                                 = &&MaxHincomes&world
                                 SUMWGT( &&Hincomes&world ) 
                                 = &&SumWgtHincomes&world
                                 N( &&Hincomes&world ) 
                                 = &&RecsHincomes&world
                                 ;
        RUN ;

        %OutputExcel (SummHH&world , Summary_income_households_&world ) 

        %IF &ExcelOut = N %THEN %DO ;
            PROC PRINT 
                Data=SummHH&world NOOBS ;
            RUN ;
        %END ;

    %END ;

%MEND HHSummary ;

%MACRO IncomeDistributions(Dataset) ;

    * Create income distributions on different income unit levels ;

    DATA &Dataset ;
        SET &Dataset ;

        * add on format groups as a new label ;
        
        %DO j = 1 %TO %SYSFUNC( COUNTW( &VarListInc , '-' ) ) ;
            %LET var = %SCAN( &VarListInc , &j , '-' ) ;
            %DO k = 1 %TO 2 ;
                %IF &k = 1 %THEN %LET world = base ;
                %ELSE %IF &k = 2 %THEN %LET world = sim ;
                &var.&world.G = PUT(&var._&world , Income_fmt.) ;
            %END ;
        %END ;

        %IF &Dataset = Person %THEN %DO ;
            %DO j = 1 %TO %SYSFUNC( countw( &VarListTranIncTest , '-' ) ) ;
                %LET var = %SCAN( &VarListTranIncTest , &j , '-' ) ;
                %DO k = 1 %TO 2 ;
                    %IF &k = 1 %THEN %LET world = base ;
                    %ELSE %IF &k = 2 %THEN %LET world = sim ;
                    &var.&world.G = PUT(&var._&world , TranInc_fmt.) ;
                %END ;
            %END ;
        %END ;
    RUN ;

    * Output distribution by income for all ;

    %DO j = 1 %TO %SYSFUNC( COUNTW( &VarListInc , '-' ) ) ; 
    * For each variable in the individuals income list ;
        %LET var = %SCAN( &VarListInc , &j , '-' ) ;
        * Select the variable ;
        %DO k = 1 %TO 2 ;
            %IF &k = 1 %THEN %LET world = base ;             
            %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        * Output the number of people in each income group and the number of records, using the summary procedure ;

            PROC SUMMARY DATA = &Dataset nway ;             
                CLASS &var.&world.G ;
                VAR Dummy ;
                WEIGHT weight_&world ;
                OUTPUT OUT = &Dataset.&var.&world   SUMWGT(Dummy) = Num&Dataset
                                                    N(Dummy) = NumRecs ;
            RUN;

            %OutputExcel(&Dataset.&var.&world , &Dataset._&var._&world ) ;

            %IF ExcelOut = N %THEN %DO ;
                PROC PRINT Data=&Dataset.&var.&world NOOBS ;
                RUN ;
            %END ;

        %END ;   

    %END ;

    * Output distribution by income for each transfer payment ;

    %IF &Dataset = Person %THEN %DO ;

        %DO j = 1 %TO %SYSFUNC( COUNTW( &VarListTranInc , '-' ) ) %BY 2 ; 
        * For each variable in the individuals income list ;
            %LET TranPay = %SCAN( &VarListTranInc , &j , '-' ) ;
            * Select the variable ;
            %DO k = 1 %TO 2 ;
                %IF &k = 1 %THEN %LET world = base ;             
                %ELSE %IF &k = 2 %THEN %LET world = sim ;    

                %LET TranIncTest = %SCAN( &VarListTranInc , &j + 1 , '-' ) ;

                * Output the number of people in each income group and the number of records, using the summary procedure ;

                PROC SUMMARY DATA = &Dataset nway ;             
                    CLASS &TranIncTest&world.G ;
                    VAR Dummy ;
                    WEIGHT weight_&world ;
                    WHERE &TranPay._&world > 0 ;
                    OUTPUT OUT = &Dataset&TranPay&world   SUMWGT(Dummy) = Num&Dataset
                                                        N(Dummy) = NumRecs ;
                RUN;

                %OutputExcel( &Dataset.&TranPay.&world , &Dataset._&TranPay._&world ) ;

                %IF ExcelOut = N %THEN %DO ;
                    PROC PRINT Data=&Dataset.&TranPay.&world NOOBS ;
                    RUN ;
                %END ;

            %END ;   

        %END ;

    %END ;

%MEND IncomeDistributions ;

%MACRO FTBASummary ; 

    * Summarises and outputs FTBA information using the tabulate procedure ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        PROC TABULATE DATA = Capita_Outfile_&world OUT = FTBASummary&world ;
            CLASS FtbaType_&world ;
            VAR IUID_&world ;
            WEIGHT weight_&world ;
            TABLES FtbaType_&world , IUID_&world='' *
                (SUMWGT='Number of income units' N='Number of records') ;
        RUN ; 

        * Clean up the outputted data set and remove the summary stats ;

        DATA FTBASummary&world ;
            SET FTBASummary&world ;
            DROP _TYPE_ _PAGE_ _TABLE_ ;
            RENAME  FtbaType_&world = FtbaType
                    IUID_&world._SumWgt = No_Fam_&world
                    IUID_&world._N = No_Rec_&world ;
        RUN ;

    %END ;

    * Put into a single dataset ;
    DATA FTBASummary ;
        MERGE FTBASummaryBase FTBASummarySim;
        BY FtbaType;
    RUN ;

    %OutputExcel (FTBASummary , FTBA_details ) 

%MEND FTBASummary ;

%MACRO Equivalise ;

    * Generates equivalised incomes and place on the income unit level data set ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

    * Data step to assign equivalisation factors ;

        DATA Capita_Outfile_&world.EQ ;
            SET Capita_Outfile_&world (RENAME = HHID_&world = HHID
                             RENAME = IUID_&world = IUID
                             ) ;

                 * calculate number of persons 15 and over for equivalence factor calculation ;

            IF coupleu_&world = 1 THEN adult = 2 ; 

            ELSE adult = 1;
            
            IF AgeS1_&world NOT IN ( 0 , . ) THEN DO ;
                adult + 1 ;
                IF AgeS2_&world NOT IN ( 0 , . ) THEN DO ;
                    adult + 1 ;
                    IF AgeS3_&world NOT IN ( 0 , . ) THEN DO ;
                        adult + 1 ;
                        IF AgeS4_&world NOT IN ( 0 , . ) THEN DO ;
                            adult + 1 ;
                        END ;
                    END ;
                END ;
            END ;

            *Calculating the equivalisation factor, according to Modified OECD Equivalised Scale ;

            factor = 1 + ( adult - 1 ) * 0.5 + 0.3 * kids0to15u_&world ;
            
            *Use Factor to assign equivalised income amount for disposable and private incomes;

            IncDispEquivAu_&world = IncDispAu_&world / factor ;
            IncPrivEquivAu_&world = IncPrivAu_&world / factor ;
        RUN ;

    %END ;

%MEND Equivalise;

%MACRO FamType;

    * Assign individuals to a family type ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;    

        * Determine Three-Tiered Working Age Private Income Levels in thirds of the overall distribution ;

        PROC UNIVARIATE DATA = Capita_Outfile_&world.EQ NOPRINT ;
            * Working age - Assumes that the reference person is under APA ;
            WHERE (sexr_&world='M' AND ActualAger_&world LT maleagepenage_&world) OR
                    (sexr_&world='F' AND ActualAger_&world LT FemaleAgePenAge_&world) ;
            VAR IncDispEquivAu_&world ;
            WEIGHT weight_&world ;
            OUTPUT out=&world.WADispIncTerc pctlpts=0 33 67 100 pctlpre=pct ;
        RUN;

        * Assign these limits to Macro Variables ; 

        DATA _Null_ ;
            SET &world.WADispIncTerc;
            CALL SYMPUT('LowIncThr', pct33) ;
            CALL SYMPUT('MedIncThr', pct67) ;
        RUN;

        DATA Capita_outfile_&world.EQ ;
            SET Capita_outfile_&world.EQ ;
            FORMAT iu_type_&world iutypeB. iupaytype_&world iupaymenttype. incthrtype_&world incthr. ;
            
        * Flag where individuals are taxpayers and flag where they are transfer recipients ;

            IF PayOrRefAmntAU_&world > 0 THEN taxflag_&world = 1 ;
            ELSE taxflag_&world = 0 ;

            IF IncTranAU_&world > 0 THEN transferflag_&world = 1 ;
            ELSE transferflag_&world = 0 ;

        * Assign to Low, Medium or High Income categories according to disposable income ;

            IF IncDispEquivAu_&world LT &LowIncThr THEN incthrtype_&world = 1 ;
            ELSE IF IncDispEquivAu_&world LT &MedIncThr THEN incthrtype_&world = 2 ;
            ELSE incthrtype_&world = 3 ;

            IF coupleu_&world in (0,.) THEN DO ;   
            * singles ;
                IF (sexr_&world='M' AND ActualAger_&world LT maleagepenage_&world) OR
                    (sexr_&world='F' AND ActualAger_&world LT FemaleAgePenAge_&world) THEN DO ;  
                    * working age ;
                    IF (DepsUnder15_&world in (0,.) AND DepsFtbA_&world IN (0,.)) THEN DO ;      
                    * single no deps ;
                        IF IncDispEquivAu_&world LT &LowIncThr THEN iu_type_&world=1 ;
                        ELSE IF IncDispEquivAu_&world LT &MedIncThr THEN iu_type_&world=2 ;
                        ELSE iu_type_&world=3 ;
                    END ;

                    ELSE DO ;                                      
                    * sole parent ;
                        IF IncDispEquivAu_&world LT &LowIncThr THEN iu_type_&world=4 ;
                        ELSE IF IncDispEquivAu_&world LT &MedIncThr THEN iu_type_&world=5 ;
                        ELSE iu_type_&world=6 ;
                    END ;
                END ;

                ELSE DO ;
                    iu_type_&world=13 ;                          
                    * senior single ;
                    incthrtype_&world=4 ;
                END ;
            END ;

            ELSE DO ;    
            * couples ;
                IF ( ( sexr_&world='M' ) AND (ActualAger_&world lt MaleAgePenAge_&world) ) OR 
                   ( ( sexr_&world='F' ) AND (ActualAger_&world lt FemaleAgePenAge_&world) ) 
                THEN DO ; 
                * working age - Assumes that the reference person is under APA ;
                    IF (DepsUnder15_&world IN (0,.) AND DepsFtbA_&world in (0,.)) THEN DO;  
                    * couple without deps ;
                        IF IncDispEquivAu_&world LT &LowIncThr THEN iu_type_&world=7 ;
                        ELSE IF IncDispEquivAu_&world LT &MedIncThr THEN iu_type_&world=8 ;
                        ELSE iu_type_&world=9;
                    END;
                    ELSE DO;                                      
                    * couple with deps;
                        IF (IncDispAu_&world / factor) LT &LowIncThr THEN iu_type_&world=10 ;
                        ELSE IF (IncDispAu_&world / factor) LT &MedIncThr THEN iu_type_&world=11 ;
                        ELSE iu_type_&world=12;
                    END;    
                END;
                ELSE DO;
                    iu_type_&world=14 ;      
                    * senior couples ;
                    incthrtype_&world=4 ;
                END;
             END;

            * no carer payment, age pension or dsp in income unit ;
            iupaytype_&world = 0 ;
            IF pentyper_&world = "CARER" OR pentypes_&world = "CARER" THEN  iupaytype_&world=2 ;             
            * someone in iu receives carer payment ;
            ELSE IF pentyper_&world = "DSP" OR pentypes_&world = "DSP" THEN iupaytype_&world=1 ;             
            * someone in iu receives DSP ;
            ELSE IF pentyper_&world = "AGE" OR pentypes_&world = "AGE" THEN do ;
                IF coupleu_&world = 1 THEN do;
                    IF  PenRateTyper_&world = "Maximum Rate" OR  PenRateTypes_&world = "Maximum Rate" THEN iupaytype_&world=4 ;     
                    * someone in iu receives Max-rate Aged Pension ;
                    ELSE if PenRateTyper_&world = "Part Rate" OR PenRateTypes_&world = "Part Rate" THEN iupaytype_&world=6 ; 
                    * someone in iu receives Part-rate Aged Pension ;
                END ;

                ELSE DO ;
                    IF PenRateTyper_&world = "Maximum Rate" THEN iupaytype_&world=3 ;                              
                    * reference receives Max-rate Aged Pension ;
                    ELSE if PenRateTyper_&world = "Part Rate" THEN iupaytype_&world=5 ;                        
                    * reference receives Part-rate Aged Pension ;
                END ;
            END ;
        RUN ;

    %END ;

%MEND FamType ;  

%MACRO FamTables ;

    * Output analysis of the different family types and payment amounts for base and sim levels using the tabulate procedure ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;
        
        * Family types ;

        PROC TABULATE DATA = Capita_outfile_&world.EQ OUT=FamTable&world ;
            CLASS iu_type_&world ; 
            VAR IncDispAu_&world IncPrivAu_&world taxflag_&world transferflag_&world ;
            WEIGHT weight_&world ;
            TABLE iu_type_&world='' all='Total', IncDispAu_&world=''*SUMWGT='Number'
                                                IncPrivAu_&world=''*MEAN='Average Private Income'
                                                taxflag_&world=''*MEAN='Proportion of Taxpayers' 
                                                transferflag_&world=''*MEAN='Proportion receiving transfers' ;
        RUN ;
        
        * Payment types ;

        PROC TABULATE DATA = Capita_outfile_&world.EQ OUT=PymntTable&world ;
            CLASS iupaytype_&world ; 
            VAR IncDispAu_&world IncPrivAu_&world taxflag_&world IncTranAU_&world ;
            WEIGHT weight_&world ;
            TABLE iupaytype_&world='' all='Total', IncDispAu_&world=''*sumwgt='Number' 
                                                    IncPrivAu_&world=''*MEAN='Average Private Income'
                                                    taxflag_&world=''*MEAN='Proportion of Taxpayers' 
                                                    IncTranAU_&world=''*MEAN='Average transfers received' ;
        RUN ;

        %OutputExcel (FamTable&world , FamTable_&world ) 
        %OutputExcel (PymntTable&world , PymntTable_&world ) 

    %END ;

%MEND FamTables ;

%MACRO Quintiles(unit) ;

    * Breaks data down into quintiles based on equivalised income and outputs analysis ;

    * Determine quintiles and assign individual units to a quintile based on their 
    equivalised income in the base world using the univariate procedure ;

    PROC UNIVARIATE     
        DATA = Capita_outfile_BaseEQ NOPRINT ;
        VAR Inc&Unit.EquivAu_Base ;
        WEIGHT weight_Base ;
        OUTPUT out=&Unit.INCQUINTILESBase pctlpts=0 20 40 60 80 100 
            pctlpre=pct ;
    RUN ;

    * Label quintile points according to macro variables ;
    DATA _Null_ ;
        SET &Unit.INCQUINTILESBase ;
        CALL SYMPUT('q1', pct20) ;
        CALL SYMPUT('q2', pct40) ;
        CALL SYMPUT('q3', pct60) ;
        CALL SYMPUT('q4', pct80) ;
    RUN ;

    %DO k = 1 %TO 2 ;
        %IF &k = 1 %THEN %LET world = base ;
        %ELSE %IF &k = 2 %THEN %LET world = sim ;


        * Assign to quintiles based on income level ;
        DATA Capita_outfile_&world.EQ ;
            SET Capita_outfile_&world.EQ ;
            IF Inc&Unit.EquivAu_&world < &q1 THEN Eq&Unit.IncAuQuint_&world = 'Lowest ' ;
            ELSE IF Inc&Unit.EquivAu_&world < &q2 THEN Eq&Unit.IncAuQuint_&world = 'Second' ;
            ELSE IF Inc&Unit.EquivAu_&world < &q3 THEN Eq&Unit.IncAuQuint_&world = 'Third' ;
            ELSE IF Inc&Unit.EquivAu_&world < &q4 THEN Eq&Unit.IncAuQuint_&world = 'Fourth' ;
            ELSE                                       Eq&Unit.IncAuQuint_&world = 'Highest' ;
        RUN ;

        * Output data on income unit by their income quintile ;

        PROC TABULATE 
            DATA = Capita_outfile_&world.EQ 
            OUT = &Unit.IncQuint&world ;
            CLASS Eq&Unit.IncAuQuint_&world ;
            VAR IncTranAu_&world PayOrRefAmntAu_&world Inc&Unit.Au_&world ;
            WEIGHT weight_&world ;
            TABLES Eq&Unit.IncAuQuint_&world='Quintile' ALL , 
                    ( IncTranAu_&world PayOrRefAmntAu_&world Inc&Unit.Au_&world ) * 
                    MEAN ; 
        RUN ;
        
        %OutputExcel( &Unit.IncQuint&world , &Unit.Inc_Quintiles_&world ) 
        %OutputExcel( &Unit.INCQUINTILESBase , &Unit.QuinThreshBase )
    
    %END ;

%MEND Quintiles ;

/*%MACRO Quintiles(unit) ;*/
/**/
/*    * Breaks data down into quintiles based on equivalised income and outputs analysis ;*/
/**/
/*    %DO k = 1 %TO 2 ;*/
/*        %IF &k = 1 %THEN %LET world = base ;*/
/*        %ELSE %IF &k = 2 %THEN %LET world = sim ;*/
/**/
/*        * Determine quintiles and assign individual units to a quintile based on their */
/*        equivalised income in the base world using the univariate procedure ;*/
/**/
/*        PROC UNIVARIATE     */
/*            DATA = Capita_outfile_&world.EQ NOPRINT ;*/
/*            VAR Inc&Unit.EquivAu_&world ;*/
/*            WEIGHT weight_&world ;*/
/*            OUTPUT out=&Unit.INCQUINTILES&world pctlpts=0 20 40 60 80 100 */
/*                pctlpre=pct ;*/
/*        RUN ;*/
/**/
/*        * Label quintile points according to macro variables ;*/
/*        DATA _Null_ ;*/
/*            SET &Unit.INCQUINTILES&world ;*/
/*            CALL SYMPUT('q1', pct20) ;*/
/*            CALL SYMPUT('q2', pct40) ;*/
/*            CALL SYMPUT('q3', pct60) ;*/
/*            CALL SYMPUT('q4', pct80) ;*/
/*        RUN;*/
/**/
/*        * Assign to quintiles based on income level ;*/
/*        DATA Capita_outfile_&world.EQ ;*/
/*            SET Capita_outfile_&world.EQ ;*/
/*            IF Inc&Unit.EquivAu_&world < &q1 THEN Eq&Unit.IncAuQuint_&world = 'Lowest ' ;*/
/*            ELSE IF Inc&Unit.EquivAu_&world < &q2 THEN Eq&Unit.IncAuQuint_&world = 'Second' ;*/
/*            ELSE IF Inc&Unit.EquivAu_&world < &q3 THEN Eq&Unit.IncAuQuint_&world = 'Third' ;*/
/*            ELSE IF Inc&Unit.EquivAu_&world < &q4 THEN Eq&Unit.IncAuQuint_&world = 'Fourth' ;*/
/*            ELSE                                       Eq&Unit.IncAuQuint_&world = 'Highest' ;*/
/*        RUN ;*/
/**/
/*        * Output data on income unit by their income quintile ;*/
/**/
/*        PROC TABULATE DATA = Capita_outfile_&world.EQ OUT=&Unit.IncQuint&world ;*/
/*            CLASS Eq&Unit.IncAuQuint_&world ;*/
/*            VAR IncTranAu_&world PayOrRefAmntAu_&world Inc&Unit.Au_&world ;*/
/*            WEIGHT weight_&world ;*/
/*            TABLES Eq&Unit.IncAuQuint_&world='Quintile' ALL , */
/*                    ( IncTranAu_&world PayOrRefAmntAu_&world Inc&Unit.Au_&world ) * */
/*                    MEAN ; */
/*        RUN ;*/
/*        */
/*        %OutputExcel( &Unit.IncQuint&world , &Unit.Inc_Quintiles_&world ) */
/*        %OutputExcel( &Unit.INCQUINTILESBase , &Unit.QuinThreshBase )*/
/*    */
/*    %END ;*/
/**/
/*%MEND Quintiles ;*/

********************************************************************************
10. Winners and Losers Analysis (for comparing runs on same basefile only)
********************************************************************************;

%MACRO diff(varlist) ;

    * A Macro tool to determine differences, called below ;

    %DO j = 1 %TO %SYSFUNC( countw( &varlist , '-' ) ) ; 

        * loop through list of variables;  
        %LET var = %SCAN( &varlist , &j , '-' ) ;   

        * set var = variable name from varlist;
        &var._compare = &var._sim - &var._base ;

    %END ;

%MEND diff ;

%MACRO WinLoss ;

    * First create a combined file to find the change in outcomes ;

    PROC SORT DATA = Capita_Outfile_BaseEQ ;
        BY IUID ;
    RUN ;

    PROC SORT DATA = Capita_Outfile_SimEQ ;
        BY IUID ;
    RUN ;

    DATA compareIU ;
        MERGE Capita_Outfile_BaseEQ Capita_Outfile_SimEQ ;
        BY IUID ;

        %diff(&varcomplist) 

        * Determine the proportional change in disposable income from the base world ;

        IF      IncDispAu_base > 0 THEN IncDispAu_comp_prop = IncDispAu_compare / IncDispAu_base ;  
        ELSE IF IncDispAu_base < 0 THEN IncDispAu_comp_prop = IncDispAu_compare / - IncDispAu_base ;
        ELSE IF IncDispAu_compare = 0 THEN IncDispAu_comp_prop = 0 ;
        ELSE    IncDispAu_comp_prop = 99 ;

        * Flag those individuals who experience any change, and also flag winners and 
            losers from change ;

        impactflag = 0 ;
        IF IncDispAu_compare not in (0,.) then impactflag=1 ;

        impactcat = "No Change" ;
        IF IncDispAu_compare > 0.5 THEN impactcat = "Net Win" ;
        ELSE IF IncDispAu_compare < -0.5 THEN impactcat = "Net Lose" ;

    RUN ;

    * Compare income units based on their quintile in the base word case ;

    PROC TABULATE DATA = CompareIU OUT=DispQuintilesWinLose ;
        CLASS EqDispIncAuQuint_base impactcat ;
        VAR IncDispEquivAu_compare ;
        WEIGHT weight_base ;
        TABLES EqDispIncAuQuint_base='Quintile' ALL , (impactcat='Impact Type' ALL) * 
                                            IncDispEquivAu_compare='Change in disposable income' * 
                                            (SUMWGT='Number' 
                                             MEAN='Average impact' 
                                             N='Number of records' )
                                            / printmiss ;
    RUN ;

    PROC TABULATE DATA = CompareIU OUT=PrivQuintilesWinLose ;
        CLASS EqPrivIncAuQuint_base impactcat ;
        VAR IncDispEquivAu_compare ;
        WEIGHT weight_base ;
        TABLES EqPrivIncAuQuint_base='Quintile' ALL , (impactcat='Impact Type' ALL) * 
                                            IncDispEquivAu_compare='Change in disposable income' * 
                                            (Sumwgt='Number' 
                                             MEAN='Average impact' 
                                             N='Number of records' )
                                            / printmiss ;
    RUN ;

    * Show different family types by the level of impact from the policy change, 
        overall and on taxes and transfers ; 

    PROC TABULATE DATA = CompareIU OUT=CompareWA ;
        CLASS iu_type_base ; 
        VAR IncDispAu_compare impactflag IncTranAU_compare PayOrRefAmntAu_compare ;
        WEIGHT weight_base ;
        TABLE iu_type_base all='Total', impactflag=''*SUM='Number Impacted' 
                                IncDispAU_Compare=''*(N='Number of Records' 
                                                        Sumwgt='Number of income units' 
                                                        MEAN='Average change in disposable income' 
                                                        P50='Median change in disposable income' 
                                                        MAX='Largest observed gain in disposable income' 
                                                        MIN='Largest observed loss in disposable income' ) 
                                IncTranAU_compare='' * MEAN='Average change in transfer income' 
                                PayOrRefAmntAU_compare='' * MEAN='Average change in tax liabbility'  
                                / printmiss ;
     RUN ;

    * Show different payment recipient types by the level of impact on their disposable
        income from policy change, overall and on taxes and transfers ;

    PROC TABULATE DATA= CompareIU OUT=ComparePayments ;
        CLASS iupaytype_base ; 
        VAR IncDispAu_compare impactflag IncTranAU_compare PayOrRefAmntAu_compare ;
        WEIGHT weight_base ;
        WHERE iupaytype_base NE 0 ;
        TABLE iupaytype_base='' ,  impactflag=''*SUM='Number Impacted' 
                                IncDispAU_Compare=''*(N='Number of Records' 
                                                        Sumwgt='Number of income units' 
                                                        MEAN='Average change in disposable income' 
                                                        P50='Median change in disposable income' 
                                                        MAX='Largest observed gain in disposable income' 
                                                        MIN='Largest observed loss in disposable income' ) 
                                IncTranAU_compare='' * MEAN='Average change in transfer income' 
                                PayOrRefAmntAU_compare='' * MEAN='Average change in tax liabbility' 
                                / printmiss ;
    RUN ;

    * Show the different family types by the percentage change to their disposable 
        income from the policy ;

    PROC TABULATE DATA= CompareIU OUT=AllPctChange ;
        FORMAT IncDispAu_comp_prop dispincchangePROP. iu_type_base iutypeB. ;
        CLASS IncDispAu_comp_prop iu_type_base /preloadfmt ;
        VAR weight_base ;
        TABLE IncDispAu_comp_prop='' , iu_type_base='' * weight_base='' * COLPCTSUM=''
            / printmiss ;
    RUN ;

    * Clean up the output data set for output ;

    DATA AllPctChange ;
        RETAIN Proportion_Category Family_Type ;
        SET AllPctChange ;
            Family_Type = PUT ( iu_type_base , iutypeB. ) ;
            Proportion_Category = PUT ( IncDispAu_comp_prop , dispincchangePROP. ) ;
        DROP IncDispAu_comp_prop iu_type_base _TYPE_ _PAGE_ _TABLE_ ;
    RUN ;

    * Show the different payment types by the percentage change to their disposable 
        income from the policy ;

    PROC TABULATE DATA = CompareIU OUT=PmntPctChange ;
        FORMAT IncDispAu_comp_prop dispincchangePROP. iupaytype_base iupaymenttype. ;
        CLASS IncDispAu_comp_prop iupaytype_base /preloadfmt ;
        WHERE iupaytype_base NE 0 ;
        VAR weight_base ;
        TABLE IncDispAu_comp_prop='' , iupaytype_base='' * weight_base='' * COLPCTSUM='' 
            / printmiss ;
    RUN; 

    * Clean up the output data set for output ;

    DATA PmntPctChange ;
        RETAIN Proportion_Category Payment_Type ;
        SET PmntPctChange ;
            Payment_Type = PUT ( iupaytype_base , iupaymenttype. ) ;
            Proportion_Category = PUT ( IncDispAu_comp_prop , dispincchangePROP. ) ;
        DROP IncDispAu_comp_prop iupaytype_base _TYPE_ _PAGE_ _TABLE_ ;
    RUN ;

    * Show the different family types by the absolute change to their disposable income
        from the policy ;

    PROC TABULATE DATA= CompareIU OUT=AllAbsChange;
        FORMAT IncDispAu_compare dispincchangeABS. iu_type_base iutypeB.;
        CLASS IncDispAu_compare iu_type_base /preloadfmt ;
        VAR weight_base ;
        TABLE IncDispAu_compare='' , iu_type_base='' * weight_base='' * COLPCTSUM='' 
            / printmiss;
    RUN;

    * Clean up the output data set for output ;

    DATA AllAbsChange;
        RETAIN Change_Category Family_Type ;
        SET AllAbsChange;
            Family_Type = PUT ( iu_type_base , iutypeB. ) ;
            Change_Category = PUT ( IncDispAu_compare , dispincchangeABS. ) ;
        DROP IncDispAu_compare iu_type_base _TYPE_ _PAGE_ _TABLE_;
    RUN ;

    * Show the different payment types by the absolute change to their disposable 
        income from the policy ;

    PROC TABULATE DATA = CompareIU OUT=PmntAbsChange;
        FORMAT IncDispAu_compare dispincchangeABS. iupaytype_base iupaymenttype.;
        CLASS IncDispAu_compare iupaytype_base /preloadfmt ;
        WHERE iupaytype_base NE 0;
        VAR weight_base ;
        TABLE IncDispAu_compare='' , iupaytype_base='' * weight_base='' * COLPCTSUM='' 
            / printmiss;
    RUN; 

    * Clean up the output data set for output ;

    DATA PmntAbsChange;
        RETAIN Change_Category Payment_Type;
        SET PmntAbsChange;
            Payment_Type = PUT ( iupaytype_base , iupaymenttype. );
            Change_Category = PUT ( IncDispAu_compare , dispincchangeABS. ) ;
        DROP IncDispAu_compare iupaytype_base _TYPE_ _PAGE_ _TABLE_;
    RUN;

    %OutputExcel(DispQuintilesWinLose , DispInc_Quint_WinLose ) 
    %OutputExcel(PrivQuintilesWinLose , PrivInc_Quint_WinLose ) 
    %OutputExcel(CompareWA , WA_Comparison ) 
    %OutputExcel(ComparePayments , Payment_Comparison ) 
    %OutputExcel(AllPctChange , Pct_Chng_All ) 
    %OutputExcel(PmntPctChange , Pct_chng_Payment ) 
    %OutputExcel(AllAbsChange , Abs_Chng_All ) 
    %OutputExcel(PmntAbsChange , Abs_chng_Payment ) 

%MEND WinLoss ;

%StandardOutput ;
