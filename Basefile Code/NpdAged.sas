
**************************************************************************************
* Program:      NpdAged.sas                                                          *
* Description:  Creates NPD Aged dataset. This is then merged onto the person level  *
* 				dataset in the BasefileCallingProgram.                               *                                                              
**************************************************************************************;

OPTIONS NOFMTERR ;

* Scaling factor to account for aged people with no stated income ;
%GLOBAL ScaleFactor ;

* Growth factor used for uprating incomes - growth in Pension Maximum Basic rate from 2011-12 to 2013-14 ;
%Let GrwthPension = 4.6 ;

************************************************************************************
* 1.    Calculate ScaleFactor to account for NPD aged that do not have income data *                                    
************************************************************************************;
DATA NpdAgedIncome ;
    SET Census.csf11bp END = LastRecord ;   
    FORMAT _ALL_ ;  
    WHERE dwip = 2 and uaicp = 1 and agep >= 33 ; 
	RETAIN CountIncStated 0 ;
    CensusWeight = 100 ;

	*Count those with income data ;
    IF incp <= 12 THEN DO ;
		CountIncStated = CountIncStated + 1 ; 
	 END ;

	IF LastRecord THEN DO ;
		ScaleFactor = _N_ / CountIncStated ;
		CALL SYMPUTX ( 'ScaleFactor', Scalefactor ) ;
	END ;

    KEEP incp CountIncStated ScaleFactor ;
RUN;

***********************************************************************************
*      2.        Select aged people living in NPDs from Census                    *
***********************************************************************************;
DATA CensusAged ;                   
    SET Census.csf11bp;   
    FORMAT _ALL_ ;  
    *Resides in a CensusAged & enumerated at home & has income data;                  
    WHERE dwip = 2 and uaicp = 1 and agep >= 33 and incp <= 12 ;                   
    
    IF agep = 33 THEN age = '65' ;              
    ELSE IF agep=34 THEN age = '70' ;               
    ELSE IF agep=35 THEN age = '75' ;               
    ELSE IF agep in (36,37) THEN age = '80' ;                   
                        
    IF sexp = 1 THEN sex = 'M' ;                    
    ELSE IF sexp = 2 THEN sex = 'F' ;                   
        
         
    IF incp = 1 THEN inc = 'inc1' ;                 
    IF incp = 2 THEN inc = 'inc2' ;                 
    IF incp = 3 THEN inc = 'inc3' ;                 
    IF incp = 4 THEN inc = 'inc4' ;                 
    IF incp = 5 THEN inc = 'inc5' ;                 
    IF incp = 6 THEN inc = 'inc6' ;                 
    IF incp = 7 THEN inc = 'inc7' ;                 
    IF incp = 8 THEN inc = 'inc8' ;                 
    IF incp = 9 THEN inc = 'inc9' ;                 
    IF incp = 10 THEN inc = 'in10' ;                    
    IF incp = 11 THEN inc = 'in11' ;                    
    IF incp = 12 THEN inc = 'in12' ;                    
                                    
    MatchId = age!!inc!!sex ;           /* Both singles and members of a couple (but living separately) NPDs
                                           will be mapped to SIH records that are lone person income units   */
                        
    CensusWeight = 100 ;                    
                                    
    KEEP age sex incp MatchId CensusWeight;                    
                        
RUN ;   

***********************************************************************************
*3.   Select aged people from the SIH with similar characteristics as the NPD aged*              
***********************************************************************************;
DATA SihAged;                   
    SET Library.sih13bp; 

    FORMAT _ALL_ ; 
	
	* Define income threholds to match SIH incomes with Census income threholds ;

	%LET Cenincthresh1 = 1 ; 			%LET Cenincthresh2 = 200 ;
	%LET Cenincthresh3 = 300 ;			%LET Cenincthresh4 = 400 ;
	%LET Cenincthresh5 = 600 ;			%LET Cenincthresh6 = 800 ;
	%LET Cenincthresh7 = 1000 ;			%LET Cenincthresh8 = 1250 ;
	%LET Cenincthresh9 = 1500 ; 		%LET Cenincthresh10 = 2000 ;

	* Use income thresholds to uprate the 2011-12 Census data  ;

	%LET uprCenincthresh1 = &Cenincthresh1 ; 		 						%LET uprCenincthresh2 = &Cenincthresh2*(1+&GrwthPension/100)**2 ;
	%LET uprCenincthresh3 = &Cenincthresh3*(1+&GrwthPension/100)**2 ; 		%LET uprCenincthresh4 = &Cenincthresh4*(1+&GrwthPension/100)**2 ;
	%LET uprCenincthresh5 = &Cenincthresh5*(1+&GrwthPension/100)**2 ;		%LET uprCenincthresh6 = &Cenincthresh6*(1+&GrwthPension/100)**2 ;
	%LET uprCenincthresh7 = &Cenincthresh7*(1+&GrwthPension/100)**2 ;		%LET uprCenincthresh8 = &Cenincthresh8*(1+&GrwthPension/100)**2 ;
	%LET uprCenincthresh9 = &Cenincthresh9*(1+&GrwthPension/100)**2 ;		%LET uprCenincthresh10 = &Cenincthresh10*(1+&GrwthPension/100)**2 ;

    * Select persons aged 65 and over, not receiving wage, salary, business income or rent assistance,
	  and who are the only person in their income unit (i.e. lone person income unit type) ;

    WHERE agebc >= 27 AND iwssucp8 = 0 AND iobtcp = 0 AND cwkcra = 0 AND iutypep = 4 ;    
                    
    IF inctscp8< 0 THEN inc = 'inc1' ;                     
    ELSE IF  inctscp8= 0 THEN inc = 'inc2' ; 
    ELSE IF  &uprCenincthresh1 <= inctscp8< &uprCenincthresh2 THEN inc = 'inc3' ;                      
    ELSE IF  inctscp8< &uprCenincthresh3 THEN inc = 'inc4' ;                  
    ELSE IF  inctscp8< &uprCenincthresh4 THEN inc = 'inc5' ;                  
    ELSE IF  inctscp8< &uprCenincthresh5 THEN inc = 'inc6' ;                  
    ELSE IF  inctscp8< &uprCenincthresh6 THEN inc = 'inc7' ;                  
    ELSE IF  inctscp8< &uprCenincthresh7 THEN inc = 'inc8' ;                      
    ELSE IF  inctscp8< &uprCenincthresh8 THEN inc = 'inc9' ;                  
    ELSE IF  inctscp8< &uprCenincthresh9 THEN inc = 'in10' ;                  
    ELSE IF  inctscp8< &uprCenincthresh10 THEN inc = 'in11' ;                  
    ELSE inc = 'in12' ;             
                            
    IF agebc = 27 THEN age = '65' ;                 
    ELSE IF agebc = 28 THEN age = '70' ;                    
    ELSE IF agebc = 29 THEN age = '75' ;                    
    ELSE IF agebc = 30 THEN age = '80' ;                    
                        
                        
    IF sexp = 1 THEN sex = 'M' ;                    
    ELSE IF sexp = 2 THEN sex = 'F' ;                   

    MatchId = age!!inc!!sex ;                    
                  
RUN;   
***********************************************************************************
*4.                     Match the NPD Aged with the SIH Aged                      *              
***********************************************************************************;
PROC TABULATE
    DATA = CensusAged 
    OUT =  CensusMatchIdSum (DROP = _TYPE_ _PAGE_ _TABLE_ ascend) ;
    VAR Censusweight ;
    CLASS MatchId ;
    TABLE MatchId , CensusWeight*(n sum) ;
RUN ;

PROC TABULATE
    DATA = SihAged 
    OUT =  SihMatchIdSum (DROP = _TYPE_ _PAGE_ _TABLE_ ascend) ;
    VAR sihpswt ;
    CLASS MatchId ;
    TABLE MatchId , sihpswt*(n sum) ;
RUN ;

DATA MatchIdMerge ;
    MERGE CensusMatchIdSum SihMatchIdSum ;
    BY MatchId ;
    IF CensusWeight_Sum = . THEN DELETE ;  
RUN ;

DATA CensusSihMatch;
    SET MatchIdMerge ;

	IF sihpswt_sum = . THEN DELETE ;
    IF MatchId = "65inc3F" THEN CensusWeight_Sum = 400 ;
    IF MatchId = "65inc3M" THEN CensusWeight_Sum = 500 ;
    IF MatchId = "70inc3M" THEN CensusWeight_Sum = 400 ;
    IF MatchId = "75in11F" THEN CensusWeight_Sum = 200 ;
    IF MatchId = "75inc3F" THEN CensusWeight_Sum = 400 ;
    IF MatchId = "75inc3M" THEN CensusWeight_Sum = 500 ;
    IF MatchId = "80in10M" THEN CensusWeight_Sum = 200 ;
    IF MatchId = "80inc3F" THEN CensusWeight_Sum = 4900 ;
    IF MatchId = "80inc3M" THEN CensusWeight_Sum = 2000 ;

    Scalar = CensusWeight_sum / sihpswt_sum ;
RUN ;

PROC SORT DATA = SihAged ;
    BY MatchId ;
RUN ;
PROC SORT DATA = CensusSihMatch ;
    BY MatchId ;
RUN ;
***********************************************************************************
*5.                     Create NPD Aged dataset                                   *              
***********************************************************************************;
DATA NpdAged ;
    MERGE SihAged CensusSihMatch ;
    BY MatchId ;

	IF Scalar = . THEN DELETE ;

	ELSE DO ;
	    sihpswt_temp = sihpswt ;
		RepWeight = sihpswt_temp * Scalar ;
        sihpswt = RepWeight * &ScaleFactor ;
	    NpdFlag = 1 ;
	END ;
    
    DROP CensusWeight_Sum sihpswt_sum Scalar sihpswt_temp RepWeight inc age sex MatchId  ;

RUN ;

DATA NpdAged ;

    SET NpdAged ( KEEP = &PersonSihNames NpdFlag ) ;

        %LET RenameList1 = %Rename( &PersonVarListSuff , 1 , 2 ) ;

        %LET RenameList2 = %Rename( &PersonVarListNoSuff , 1 , 2 ) ;
        
        RENAME &RenameList1 &RenameList2 ;

RUN ;
