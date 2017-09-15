
**************************************************************************************
* Program:      BasefilesParameters.sas                                              *
* Description:  Generates master parameter dataset for use in the basefiles modules. * 
**************************************************************************************;

* Define a list of parameter names to be read-in using the macro defined below. Note that
  when parameters are added or removed from the parameters spreadsheet, this list needs
  to be modified accordingly ;

    %LET ParamList =    NumTaxBrkt -
                        TaxRate1 -
                        TaxRate2 -
                        TaxRate3 -
                        TaxRate4 -
                        MedLevRate -
                        TBRLRate -
                        TBRLRateFBT -
                        AdjFBThr -
                        Drawdown5564 -
                        Drawdown6574 -
                        Drawdown7579 -
                        Drawdown8084 -
                        Drawdown8589 -
                        Drawdown9094 -
                        DrawdownGt95 -
                        IncSourceSplitAdjFactor -
                        PropTfCompGov -
                        PropTfCompPriv -                      
                        ;


* Define parameter read-in macro for reading in the Basefiles Parameters spreadsheet ;

%MACRO ImportParams( Year ) ;
    
    PROC IMPORT 
        OUT = BasefilesParm&Year
        ( WHERE = ( Year = &Year ) )        
        DATAFILE = "&ParamWkBk"
        DBMS = EXCELCS REPLACE ;
        SHEET = "Sheet1" ;
    RUN;

%MEND ImportParams ;



