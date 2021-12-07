
**************************************************************************************
* Program:      Merge.sas                                                            *
* Description:  Merge the person level variables onto the income unit level dataset, *
*               and also add the household level variables onto this dataset.        *                                                          
**************************************************************************************;

%MACRO Merge(BasefileYear) ;

* Sort the person, income unit and household level datasets using the SIH identifiers ;

    * Household level dataset ;

    PROC SORT DATA = Household&BasefileYear ;

        BY SihHID ;

    RUN ;    

    * Income unit level dataset ;

    PROC SORT DATA = Income&BasefileYear ;

        BY SihHID SihFID SihIUID ;

    RUN ;    

    * Person level dataset ;

    PROC SORT DATA = Person&BasefileYear ;

        BY SihHID SihFID SihIUID SihPIDp ;

    RUN ;    

* Attach the household level dataset to the income unit level dataset (note - this will
  assign equal values of the household variables to each income unit in the household) ;

    DATA Basefile&BasefileYear ;

        MERGE Household&BasefileYear Income&BasefileYear ;

        BY SihHID ;

    RUN ; 

* Sort the basefile ;

    PROC SORT DATA = Basefile&BasefileYear ;

        BY SihHID SihFID SihIUID ;

    RUN ;

* Create the variables for the reference person ;

    DATA Personr ;

        SET Person&BasefileYear ;

            WHERE IUPosSp = 1 ;   /* IUPos = Reference Person of Income Unit */

    RUN ;

* Create the variables for the spouse ;

    DATA Persons ;

        SET Person&BasefileYear ;

            WHERE IUPosSp = 2 ;   /* IUPos = Partner of Reference Person of Income Unit */

    RUN ;

* Create the variables for dependent 1 ;

    DATA Person1 ;

        SET Person&BasefileYear ;

            WHERE ( IUPosSp = 3 AND IUTypeSp = 3 AND INPUT ( SihPIDp , 2. ) = 2 )     /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Lone parent with dependent children,
                                                                  						 PersID = Second person in income unit */

               OR ( IUPosSp = 3 AND IUTypeSp = 1 AND INPUT ( SihPIDp , 2. ) = 3 ) ;   /* IUPos = Dependent child of reference person,
                                                                  						 IUType = Couple with dependent children,
                                                                  						 PersID = Third person in income unit */

    RUN ;

* Create the variables for dependent 2 ;

    DATA Person2 ;

        SET Person&BasefileYear ;
 
            WHERE ( IUPosSp = 3 AND IUTypeSp = 3 AND INPUT ( SihPIDp , 2. ) = 3 )     /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Lone parent with dependent children,
                                                                  						 PersID = Third person in income unit */


               OR ( IUPosSp = 3 AND IUTypeSp = 1 AND INPUT ( SihPIDp , 2. ) = 4 ) ;   /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Couple with dependent children,
                                                                  					     PersID = Fourth person in income unit */
    
    RUN ;

* Create the variables for dependent 3 ;

    DATA Person3 ;

        SET Person&BasefileYear ;
 
            WHERE ( IUPosSp = 3 AND IUTypeSp = 3 AND INPUT ( SihPIDp , 2. ) = 4 )     /* IUPos = Dependent child of reference person, 
                                                                  					     IUType = Lone parent with dependent children,
                                                                  						 PersID = Fourth person in income unit */


               OR ( IUPosSp = 3 AND IUTypeSp = 1 AND INPUT ( SihPIDp , 2. ) = 5 ) ;   /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Couple with dependent children,
                                                                  						 PersID = Fifth person in income unit */
    
    RUN ;

* Create the variables for dependent 4 ;

    DATA Person4 ;

        SET Person&BasefileYear ;
 
            WHERE ( IUPosSp = 3 AND IUTypeSp = 3 AND INPUT ( SihPIDp , 2. ) = 5 )     /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Lone parent with dependent children,
                                                                  						 PersID = Fifth person in income unit */


               OR ( IUPosSp = 3 AND IUTypeSp = 1 AND INPUT ( SihPIDp , 2. ) = 6 ) ;   /* IUPos = Dependent child of reference person, 
                                                                  						 IUType = Couple with dependent children,
                                                                  						 PersID = Sixth person in income unit */
    
    RUN ;

* Attach the person suffixes to the separate person level datasets created above ;

    %MACRO AttachSuffixes(psn) ;

        DATA Person&psn ;

            SET Person&psn ;

                %* Variables from the SIH, with suffixes ;
                %LET RenameList1 = %RenameSuffix( &PersonVarListSuff , 2 , 2 , &psn ) ;

                %* Created character variables ;
                %LET RenameList2 = %RenameSuffix( &PersonCharList , 1 , 1 , &psn ) ;

                %* Created numeric variables, with suffixes ;
                %LET RenameList3 = %RenameSuffix( &PersonNumList , 1 , 1 , &psn ) ;
              
                RENAME  &RenameList1
                        &RenameList2
                        &RenameList3 ;
         
        RUN ;

    %MEND AttachSuffixes ;

    %AttachSuffixes(r) ;
    %AttachSuffixes(s) ;
    %AttachSuffixes(1) ;
    %AttachSuffixes(2) ;
    %AttachSuffixes(3) ;
    %AttachSuffixes(4) ;

* Sort each of the separate person level datasets ;

    %MACRO SortPersonDatasets(psn) ;

        PROC SORT DATA = Person&psn ;

            BY SihHID SihFID SihIUID SihPID&psn ;

        RUN ; 

    %MEND SortPersonDatasets ;

    %SortPersonDatasets(r) ;
    %SortPersonDatasets(s) ;
    %SortPersonDatasets(1) ;
    %SortPersonDatasets(2) ;
    %SortPersonDatasets(3) ;
    %SortPersonDatasets(4) ;

* Combine each person together within income units ;

    DATA PersonsCombined&BasefileYear ;

        MERGE Personr Persons Person1 Person2 Person3 Person4 ;

        BY SihHID SihFID SihIUID ;

    RUN ;

* Sort the combined person data ;

    PROC SORT DATA = PersonsCombined&BasefileYear ;

        BY SihHID SihFID SihIUID ;

    RUN ;

* Merge the combined person level data onto the basefile. When merging the policy year basefiles,
  a set of variables in the dataset IUKeptVars is also merged on (created in VariableConstruct2) ;

    %IF &BasefileYear = &SurveyYear %THEN %DO ;

        DATA Basefile&BasefileYear ;

            MERGE Basefile&BasefileYear PersonsCombined&BasefileYear ;

            BY SihHID SihFID SihIUID ;

        RUN ;
		
    %END ;

    %ELSE %DO ;

        PROC SORT DATA = Basefile&BasefileYear ;

            BY SihHID SihFID SihIUID ;

        RUN ;

        DATA Basefile&BasefileYear ;

            MERGE Basefile&BasefileYear PersonsCombined&BasefileYear IUKeptVars ;

            BY SihHID SihFID SihIUID ;

        RUN ;

        PROC SORT DATA = Basefile&BasefileYear ;

            BY HHID FamID IUID ; 

        RUN ;

    %END ;

* If NPD records have been imputed, set the SIH Income Unit weight equal to the reference person weight 
  (ie PersonWeightSr) for these NPD records ; 

    %IF &NpdImpute = Y %THEN %DO ;

    DATA Basefile&BasefileYear ;

        SET Basefile&BasefileYear ;

        IF NpdFlag = 1 THEN
            IUWeightSu = PersonWeightSr ;
        
    RUN ;

    %END ;

* Append the parameters for the corresponding year to the basefiles (for use in VariableConstruct2 and
  VariableConstruct3) - NOTE: This data step will not overwrite variables if they are already on the dataset.
  This is why the parameters need to be dropped at the end of the tax deductions imputation, as well as at
  the end of the basefiles creation process ;

    %ImportParams( &BasefileYear ) 

        DATA Basefile&BasefileYear ;

            IF _n_ = 1 THEN SET BasefilesParm&BasefileYear ;

            SET Basefile&BasefileYear ;

        RUN ;     

%MEND Merge ;





