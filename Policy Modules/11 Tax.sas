
**************************************************************************************
* Program:      11 Tax.sas                                                           *
* Description:  Calculates tax payable or receivable, including levies, surcharges   *
*               and offsets components.                                              *
**************************************************************************************;

***********************************************************************************
*   Macro:   TaxMaster                                                            *
*   Purpose: Coordinate tax calculation                                           *
**********************************************************************************;;

%MACRO RunTax ;

    ***********************************************************************************
    *      1.        Calculate gross income tax                                       *
    *                                                                                 *
    **********************************************************************************;

    * Create 3 arrays: income thresholds, tax rates, and cumulative tax paid up to each income thresholds ;

    %TaxArray

    * Apply tax array parameters to calculate gross tax for reference and, if applicable, the spouse ;

    %GrossTax( r ) 

    IF Coupleu = 1 THEN DO ; 

        %GrossTax( s ) 

    END ;

    ***********************************************************************************
    *      2.        Calculate tax offsets                                            *
    **********************************************************************************;

    * Calculate amount of SAPTO, plus transfer of any unused SAPTO between the reference and spouse ;

    %SaptoElig( r )

    IF Coupleu = 0 THEN DO ;                   * Reference who is single ;

        %SaptoPsn( r , S )  

    END ;   

    ELSE IF Coupleu = 1 THEN DO ;

        %SaptoElig( s )

        %SaptoPsn( r , C )                     * Reference who is in a couple ;

        %SaptoPsn( s , C )                     * Spouse who is in a couple ;

        %SaptoCoupTran( r , s )                * Transfer of unused SAPTO from the spouse to the reference ;

        %SaptoCoupTran( s , r )                * Transfer of unused SAPTO from the reference to the spouse ;

    END ;

    * Calculate BENTO for the reference and, if applicable, the spouse ;

    %Bento( r )

    IF Coupleu = 1 THEN DO ; 

        %Bento( s )  

    END ;

    * Calculate LITO for the reference and, if applicable, the spouse ;

    %Lito( r )

    IF Coupleu = 1 THEN DO ; 

        %Lito( s ) 

    END ;

	*Calculate LAMITO for the reference and, if applicable, the spouse;

	%Lamito( r )

    IF Coupleu = 1 THEN DO ; 

        %Lamito( s ) 

    END ;

    * Calculate MAWTO for the reference and, if applicable, the spouse ;

    %Mawto( r ) 

    IF Coupleu = 1 THEN DO ; 

        %Mawto( s ) 

    END ;

    * Calculate DSTO and DICTO for the reference with the spouse as the dependant, or for the spouse with the reference as the dependant ;

    IF Coupleu = 1 THEN DO ;

        %Dsto( r , s )

        %Dsto( s , r )

    END ;

    * Calculate superannuation tax offset for the reference and, if applicable, the spouse ;

    %SuperTo( r ) 

    IF Coupleu = 1 THEN DO ; 

        %SuperTo( s ) 

    END ;

    ***********************************************************************************
    *      3.        Calculate Medicare levy                                          *
    **********************************************************************************;

    * Calculate Medicare levy at the person level for the reference and, if applicable, the spouse ;

    %MedLevPsn( r )

    IF Coupleu = 1 THEN DO ; 

        %MedLevPsn( s ) 

    END ;

    * Calculate Medicare levy family Reduction Amount and transfer of Reduction Amount ;

    %MedLevFamRed( r )

    IF Coupleu = 1 THEN DO ;

        %MedLevFamRed( s )

    END ;

    * Calculate final Medicare levy amount taking into account family Reduction Amount ;

    MedLevAr = MAX( 0 , MedLevAr - MedLevRedAr - XMedLevRedAs ) ;

    MedLevAs = MAX( 0 , MedLevAs - MedLevRedAs - XMedLevRedAr ) ;

    ***********************************************************************************
    *      4.        Calculate Medicare levy surcharge                                *
    **********************************************************************************;

    * Calculate Medicare levy surcharge liabilities for the reference and, if applicable, the spouse ;

    %MedLevSur( r )

    IF Coupleu = 1 THEN DO ; 

        %MedLevSur( s ) 

    END ;

    ***********************************************************************************
    *      5.        Calculate Temporary Budget Repair Levy                           *
    **********************************************************************************;

    * Calculate the Temporary Budget Repair Levy (Applicable for 2014, 2015, and 2016) ;

    %TempBudgRepLev( r )

    IF Coupleu = 1 THEN DO ; 

        %TempBudgRepLev( s ) 

    END ;


	***********************************************************************************
    *      5.a        Calculate HELP Repayment Amount                                 *
    **********************************************************************************;
	* Check to see if RunCameo is Y before calculation of HELP repayments
	is added to the run of CAPITA. Data currently does not exist on basefile
	to run for distributional analysis ;

	%IF &RunCameo = Y %THEN %DO ;

		* Create 2 arrays: income thresholds, and repayment rates;

	    %HelpArray

	    * Apply Helparray parameters to calculate repayment amount for reference person ;

	    %HelpPay( r )

		IF Coupleu = 1 THEN DO ; 

	        %HelpPay( s ) 

	    END ;

	%END ; 

    ***********************************************************************************
    *      6.        Calculate final tax liabilities                                  *
    **********************************************************************************;

    * Summarise final tax outcomes for the individual ;

    %FinalTaxLiab( r )

    IF Coupleu = 1 THEN DO ; 

        %FinalTaxLiab( s ) 

    END ;

    ***********************************************************************************
    *      7.        Calculate fortnightly amounts                                    *
    **********************************************************************************;

    * Convert annual amounts to fortnightly amounts for selected variables ;

    %Fortnightly( r )

    IF Coupleu = 1 THEN DO ; 

        %Fortnightly( s ) 

    END ;

    ***********************************************************************************
    *      8.        Calculate personal income tax liabilities for dependants         *
    **********************************************************************************;

    * Calculate outcomes for dependants 1 to 4 ;

    %DO i = 1 %TO 4 ;

        IF ActualAge&i > 0 THEN DO ; 

            %GrossTax( &i ) 

            %Bento( &i )

            %Lito( &i ) 

			%Lamito( &i )

            %MedLevPsn( &i ) 

            %MedLevSur( &i ) 

            %TempBudgRepLev( &i ) 

            %FinalTaxLiab( &i )

            %Fortnightly( &i )

        END ;

    %END ;

%MEND RunTax ;

**********************************************************************************
*   Macro:   TaxArray                                                            *
*   Purpose: Create 3 arrays. First array contains tax thresholds. Second array  *
*            contains marginal tax rates. Third array calculates cumulative tax  *
*            up to current tax threshold.                                        *
*********************************************************************************;;

%MACRO TaxArray( ) ;

    * The size of these arrays are determined dynamically by the number of array elements read in 
      and there is no limit to the number of tax parameters allowed ;

    * This array holds all tax thresholds (that is all variables with a TaxThr prefix are assigned to this array) ;

    ARRAY TaxThr{ * } TaxThr: ;     * Eg TaxThr1 is the first tax threshold at $18,200 for 2013/14 ;     

    * This array holds all tax rates (that is all variables with a TaxRate prefix are assigned to this array);

    ARRAY TaxRate{ * } TaxRate: ;     

    * This array calculates cumulative tax up to current tax threshold. Eg, CumTax2  = CumTax1 + TaxRate1 * ( TaxThr2 - TaxThr1 ) ;

    * This array holds all cumulative tax amounts ;
    ARRAY CumTax{ 10 } ;    
 
    IF _N_ = 1 THEN DO ;

        * Counts the number of TaxRate parameters in the TaxRate array ;
        NumRates = DIM( TaxRate ) ;     
        
        * Check number of array variables assigned are consistent in case unwanted variables with the same prefixes are also read in ;
        IF NumRates NE DIM( TaxThr ) THEN PUT "ERROR: NUMBER OF TAX THRESHOLDS NOT EQUAL TO TAX RATES" ;

        * First cumulative tax amount is 0 ;
        CumTax{ 1 } = 0 ;       

        * Calculate remaining cumulative tax amounts ;
        DO i = 2 TO NumRates ;        

            CumTax{ i } = CumTax{ i - 1 } + TaxRate{ i - 1 } * ( TaxThr{ i } - TaxThr{ i - 1 } ) ;

        END ;

        * Initialise unused CumTax variables ;
        DO i = NumRates + 1 TO 10 ;        

            CumTax{ i } = 0 ;

        END ;

    END ;

    RETAIN CumTax: ;

    DROP i ;

%MEND TaxArray ;

**********************************************************************************
*   Macro:   GrossTax                                                            *
*   Purpose: Calculates gross tax by applying marginal tax rates to taxable      *
*            income.                                                             *
*********************************************************************************;;

%MACRO GrossTax( psn ) ;

    * If taxable income is less or equal to tax free threshold ;

    IF TaxIncA&psn <= TaxThr1 THEN DO ;

        GrossIncTaxA&psn = 0 ;

        MTR&psn = 0 ;

    END ;

    * Else if taxable income is less or equal to top income threshold ;

    ELSE IF TaxIncA&psn <= TaxThr{ NumTaxBrkt } THEN DO i = 1 TO NumTaxBrkt - 1 ;

        IF TaxThr{ i } < TaxIncA&psn <= TaxThr{ i + 1 } THEN DO ;

            GrossIncTaxA&psn = CumTax{ i } + TaxRate{ i } * ( TaxIncA&psn - TaxThr{ i } ) ;
        
            MTR&psn = TaxRate{ i } ;

        END ;

    END ;

    * Else if taxable income is greater than top income threshold ;

    ELSE IF TaxIncA&psn > TaxThr{ NumTaxBrkt } THEN DO ;
        
        GrossIncTaxA&psn = CumTax{ NumTaxBrkt } + TaxRate{ NumTaxBrkt } * ( TaxIncA&psn - TaxThr{ NumTaxBrkt } ) ;

        MTR&psn = TaxRate{ NumTaxBrkt } ;

    END ;

%MEND GrossTax ;

**********************************************************************************
*   Macro:   SaptoElig                                                           *
*   Purpose: Determine eligibility for the senior and pensioners tax offset      *
*            under Subsection 160AAAA(2) of the ITAA 1936.                       *
*********************************************************************************;;

%MACRO SaptoElig( psn ) ;

    * From 1 July 2012, when SAPTO commenced ;

    %IF &Year >= 2012 %THEN %DO ;
    
        * Determine eligibility and calculate SAPTO (Subsec 160AAAA(2), 160AAAA(3), and 160AAAA(4) of the ITAA 1936) ;

        IF 
        /* Eligible for pension, allowance or benefit under VEA 1986. Eligibility does not require receipt of the payments */
        ActualAge&psn >= DvaPenAge AND DvaType&psn NOT IN ( '' )          
     
        /* Qualify for Age Pension. Qualification does not require receipt of the payment */
        OR Sex&psn = 'M' AND ActualAge&psn >= MaleAgePenAge AND YearOfArrival&psn <= 1                     
        OR Sex&psn = 'F' AND ActualAge&psn >= FemaleAgePenAge AND YearOfArrival&psn <= 1 

        /* Receiving taxable pensions under SSA 1991 */
        OR AgePenSupBasicF&psn > 0                          /* Taxable regardless of age */
        %IF &psn = r %THEN OR PpsPenSupBasicF&psn > 0 ;
        OR ( ( DspPenSupBasicF&psn > 0                      /* Taxable if above Age Pension age */
           %IF &psn = s %THEN OR WifePenSupBasicFs > 0 ; 
           OR CarerPenSupBasicF&psn > 0 )
        AND ( Sex&psn = 'M' AND ActualAge&psn >= MaleAgePenAge 
            OR Sex&psn = 'F' AND ActualAge&psn >= FemaleAgePenAge ) )

        /* Receiving taxable pensions under VEA 1986 */
        OR ServicePenSupBasicF&psn > 0                      /* Taxable DVA Service Pension */
        THEN DO ;

            SaptoType&psn = 'ConditionalElig' ;

        END ;

    %END ;

%MEND SaptoElig ;


**********************************************************************************
*   Macro:   SaptoThrEnt                                                           *
*   Purpose: Calculate the SAPTO threshold and entitlement for a person.        *
*********************************************************************************;;

%MACRO SaptoThrEnt;
	* Part 5, Division 1, Income Tax Assessment (1936 Act) Regulation 2015 ;

	*Rebate threshold (if this amount is less than LITO threshold) - reg 9(5);
	SaptoRebThrPsn&psn = TaxThr1 + (LITOMax + SaptoMaxPsn&psn)/TaxRate1;

	*Rebate threshold (if the amount above exceeds LITO threshold) - reg 9(6) and 9(7);
	IF SaptoRebThrPsn&psn > LITOThr1 THEN DO;
		SaptoRebThrPsn&psn = (TaxRate1 * TaxThr1 + LITOMax + SaptoMaxPsn&psn + LITOThr1*(LITOTpr1 + TaxRate2 - TaxRate1))/(LITOTpr1 + TaxRate2);
	END;

	*Round up to the nearest whole dollar - reg 9(8);
	SaptoRebThrPsn&psn = CEIL(SaptoRebThrPsn&psn);

	*Calculate cut out threshold to determine 'eligbility' - Reg 10(1);
	SaptoCutOutPsn&psn = SaptoMaxPsn&psn/SaptoTpr + SaptoRebThrPsn&psn;

	*Round up to the nearest whole dollar - reg 10(2);
	SaptoCutOutPsn&psn = CEIL(SaptoCutOutPsn&psn);

	* Calculate SAPTO entitlement - Reg 11 ;
    IF RebIncA&psn <= SaptoRebThrPsn&psn THEN SaptoA&psn = SaptoMaxPsn&psn ;
    ELSE IF RebIncA&psn > SaptoRebThrPsn&psn THEN SaptoA&psn = MAX( 0 , SaptoMaxPsn&psn - SaptoTpr * ( RebIncA&psn - SaptoRebThrPsn&psn ) ) ;
%MEND;



**********************************************************************************
*   Macro:   SaptoPsn                                                            *
*   Purpose: Calculate the income tested senior and pensioners tax offset for    *
*            eligible taxpayers who are singles or members of couple. This does  *
*            not yet calculate transfer of unused SAPTO.                         *
*********************************************************************************;;

%MACRO SaptoPsn( psn , SC ) ;

    * From 1 July 2012, when SAPTO commenced ;

    %IF &Year >= 2012 %THEN %DO ;

        * Person level Rebate Income (Sec 6 of the ITAA 1936) will be created as part of the income definition module ;
        
        %IF &psn = r AND &SC = C %THEN %DO ;                         * Calculate once for each couple ;

            RebIncAu = ( RebIncAr + RebIncAs ) / 2 ;

        %END ;

        IF SaptoType&psn = 'ConditionalElig' THEN DO ;
            * Calculate Rebate Amount, Rebate Threshold, Cut Out Threshold, and SAPTO entitlement;
            * Part 5, Division 1, Income Tax Assessment (1936 Act) Regulation 2015 ;
            
            SaptoMaxPsn&psn = SaptoMax&SC ;
			
			*Calculate threshold and entitlement;
			%SaptoThrEnt

            * Assign eligibility based on cut out threshold (s160AAAA (3) and (4), ITAA1936) 
				- used to assess eligibility for transferability;
            %IF &SC = S %THEN %DO ;
                IF RebIncA&psn < SaptoCutOutPsn&psn THEN SaptoType&psn = 'SINGLE' ;
                ELSE SaptoType&psn = '' ;
            %END ;
            %ELSE %IF &SC = C %THEN %DO ;
                IF RebIncAU < SaptoCutOutPsn&psn THEN SaptoType&psn = 'COUPLE' ;
                ELSE SaptoType&psn = '' ;
            %END ; 

        END ;    * Determine eligibility and calculate SAPTO ;

    %END ;

%MEND SaptoPsn ;

**********************************************************************************
*   Macro:   SaptoCoupTran                                                       *
*   Purpose: Calculates the income tested SAPTO after unused SAPTO has been      *
*            transferred between members of an eligible couple.                  *
*********************************************************************************;;

%MACRO SaptoCoupTran( psn , partner ) ;

    * From 1 July 2012, when SAPTO commenced ;
	* UPDATED 180926
    * Part 5, Division 1, Income Tax Assessment (1936 Act) Regulation 2015 ;
	* Regulation 12;

    %IF &Year >= 2012 %THEN %DO ;

        * Determine amount of excess SAPTO transferred from one taxpayer to their spouse for those eligible couples ;
        * (The amount of excess SAPTO &partner gives may not be the same as the amount &psn receives) ;

        IF SaptoType&psn = 'COUPLE' AND SaptoType&partner = 'COUPLE'    /* If both members of couple are eligible for SAPTO */
        AND SaptoA&partner > GrossIncTaxA&partner                       /* If &partner has excess SAPTO after offsetting gross income tax. &partner gives excess SAPTO */
        AND SaptoA&psn < SaptoMaxPsn&psn                                /* If &psn SAPTO is tapered (that is they have used up all their Lito and SAPTO) */
        THEN DO ;

            * Assign eligibility flags. By assigning these new flags also means that the opposite scenarios will not be run ;

            SaptoType&psn = 'TAKEXSAPTO' ;      

            SaptoType&partner = 'GIVEXSAPTO' ;    

            * Calculate amount of unused SAPTO transferred to &psn - Reg 12(3) ;
            IF TaxIncA&partner <= 6000 THEN DO ;                
                TakeXSaptoA&psn = SaptoA&partner - GrossIncTaxA&partner ;
            END ;
            ELSE IF TaxIncA&partner > 6000 THEN DO ;
                TakeXSaptoA&psn = MAX( 0 , SaptoA&partner - ( TaxIncA&partner - 6000 ) * 0.15 ) ;
			END ;

            * The amount of SAPTOA&partner after transferring unused SAPTO to &psn is equal to &partner gross income tax. ;
            * Set SaptoMaxPsn&partner to SaptoA&partner so that any unused SaptoA&psn is not transferred back to &partner when the reverse scenario is calculated. ;

            SaptoA&partner = GrossIncTaxA&partner ;
            SaptoMaxPsn&partner = SaptoA&partner ;

            * Transfer unused amount from partners to persons maximum SAPTO amount;
            SaptoMaxPsn&psn = SaptoMaxC + TakeXSaptoA&psn ;

			*Recalculate threshold and entitlement;
			%SaptoThrEnt  

        END ;

    %END ;

%MEND SaptoCoupTran ;

**********************************************************************************
*   Macro:   Bento                                                               *
*   Purpose: Calculates the income tested beneficiary tax offset for eligible    *
*            taxpayers, and then choose between BENTO and SAPTO                  *
*********************************************************************************;;

%MACRO Bento( psn ) ; 

     * Rebatable Benefit (Subsec 160AAA (1) of the ITAA 1936) is created in the Income Module ;
    * Rebatable Benefits included in CAPITA are: Widow Allowance, Youth Allowance, Austudy, Newstart Allowance, Sickness Allowance, Special Benefit, and Partner Allowance ;
    * Rebatable Benefits not included in CAPITA are: Mature Age Allowance (post 30 June 1996), Disaster Recovery Allowance, and Community Development Employment Project ;

    * Determine eligibility for BENTO. Eligible for BENTO if receiving a Rebatable Benefit ;

    IF RebBftA&psn > 0 THEN BentoFlag&psn = 1 ;   

    * Calculate BENTO for those eligible, rounded down to the nearest dollar ;

    IF BentoFlag&psn = 1 THEN DO ;

        * If Rebatable Benefit is less than or equal to the threshold at the upper conclusion of the lowest marginal tax rate ;
        IF RebBftA&psn <= TaxThr2 THEN BentoA&psn = CEIL( MAX( 0 , BentoRate * ( RebBftA&psn - BentoThr ) ) ) ;       

        * Else if Rebtable Benefit is more than the threshold at the upper conclusion of the lowest marginal tax rate ;
        ELSE IF RebBftA&psn > TaxThr2 THEN BentoA&psn = CEIL( BentoRate * ( RebBftA&psn - BentoThr ) + BentoRate * ( RebBftA&psn - TaxThr2 ) ) ;       

    END ;

    * Taxpayers may only get the higher of SAPTO and BENTO (Subsec 160AAA (4) of the ITAA 1936 ). 
    If the amounts are the same then the taxpayer is assigned SAPTO as it would be more 
    beneficial for the taxpayer to be a SAPTO recipient for Medicare levy purposes ;

    %IF &psn IN( r , s ) %THEN %DO ;

        IF BentoFlag&psn = 1 AND SaptoType&psn NOT IN ( '' ) THEN DO ;

            IF SaptoA&psn < BentoA&psn THEN DO ;

                SaptoA&psn = 0 ;

                SaptoType&psn = ( '' ) ;

            END ;

            ELSE IF SaptoA&psn >= BentoA&psn THEN DO ;

                BentoA&psn = 0 ;

                BentoFlag&psn = 0 ;

            END ;

        END ;

    %END ;

%MEND Bento ;

**********************************************************************************
*   Macro:   Lito                                                                *
*   Purpose: Calculates the income tested low income tax offset for eligible     *
*            taxpayers.                                                          *
*********************************************************************************;;


%MACRO Lito( psn ) ;



%IF ( &Duration = A AND ( &Year < 2022 ) )
	OR ( &Duration = Q AND &Year < 2022)
	OR ( &Duration = Q AND &Year = 2022 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) )
	%THEN %DO ;


    * Else if taxable income is less than or equal to the Lito threshold ;
    IF TaxIncA&psn <= LitoThr1 THEN LitoA&psn = LitoMax ;

    * Else if taxable income is greater than the Lito threshold ;
    ELSE IF TaxIncA&psn > LitoThr1 THEN LitoA&psn = MAX( 0 , LitoMax - LitoTpr1 * ( TaxIncA&psn - LitoThr1 ) ) ;

    * Eligibility flag for Lito (Subsec 159N (1) of the ITAA 1936) ;             
    IF LitoA&psn > 0 THEN LitoFlag&psn = 1 ;
%END;


%ELSE %DO;


    * Else if taxable income is less than or equal to the Lito threshold ;
    IF TaxIncA&psn <= LitoThr1 THEN LitoA&psn = LitoMax ;

    * Else if taxable income is greater tham the Lito threshold ;
    ELSE IF TaxIncA&psn <= LitoThr2 THEN LitoA&psn = MAX( 0 , LitoMax - LitoTpr1 * ( TaxIncA&psn - LitoThr1 ) ) ;

	* Else if taxable income is greater than the Lito threshold ;
    ELSE IF TaxIncA&psn > LitoThr2 THEN LitoA&psn = MAX( 0 , LitoMax - LitoTpr2 * ( TaxIncA&psn - LitoThr2 )- LitoTpr1 * ( LitoThr2 - LitoThr1 ) ) ;

    * Eligibility flag for Lito (Subsec 159N (1) of the ITAA 1936) ;             
    IF LitoA&psn > 0 THEN LitoFlag&psn = 1 ;

%END ; 

%MEND Lito ;


**********************************************************************************
*   Macro:   Lamito                                                                *
*   Purpose: Calculates the income tested low and middle income tax offset for
*			 eligible taxpayers.

*********************************************************************************;;

%MACRO Lamito( psn ) ;

 %IF ( &Duration = A AND ( &Year > 2017 AND &Year < 2022 ) )
	OR ( &Duration = Q AND &Year > 2018 AND &Year < 2022 )
	OR ( &Duration = Q AND &Year = 2018 AND ( ( &Quarter = Sep ) OR ( &Quarter = Dec ) ) )
	OR ( &Duration = Q AND &Year = 2022 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) )
	%THEN %DO ;

    * Else if taxable income is less than or equal to the second tax threshold threshold ;
    IF TaxIncA&psn <= LamitoThr1 THEN LamitoA&psn = LamitoBase ;

    * Else if taxable income is greater than the Lamito threshold ;
    ELSE IF TaxIncA&psn <= LamitoThr2 THEN LamitoA&psn = MIN( LamitoMax,  LamitoBase + LamitoTpr1 * ( TaxIncA&psn - LamitoThr1 ) ) ;

	* Else if taxable income is greater than the third tax threshold ;
    ELSE IF TaxIncA&psn > LamitoThr2 THEN LamitoA&psn = MAX( 0 , LamitoMax - LamitoTpr2 * ( TaxIncA&psn - LamitoThr2 ) ) ;

    * Eligibility flag for Lito (Subsec 159N (1) of the ITAA 1936) ;             
    IF LamitoA&psn > 0 THEN LamitoFlag&psn = 1;

%END ;


%MEND Lamito ;



**********************************************************************************
*   Macro:   Mawto                                                               *
*   Purpose: Calculates the income tested mature age workers tax offset for      *
*            eligible taxpayers.                                                 *
*********************************************************************************;;

%MACRO Mawto( psn ) ;

    * Determine eligibility and calculate MAWTO (Sec 61-560 and 61-565 of the ITAA 1997) ;
    * Net Income from Working (Sec 61-570 of the ITAA 1997) will be created as part of the income definition module ;   
    * NOTE: MAWTO is abolished from 1 July 2014, Tax and Superannuation Laws Amendment (2014 Measures No. 5) Act 2015 ;

    IF ActualAge&psn >= MawtoAge
    AND NetIncWorkA&psn > 0      
    AND NetIncWorkA&psn <= MawtoThr2
    THEN DO ;

        * Eligiblity flag for MAWTO ;
        MawtoFlag&psn = 1 ;

        * Phase-in of MAWTO ;
        IF NetIncWorkA&psn <= MawtoThr1 THEN MawtoA&psn = MIN( MawtoMax , MawtoPhsInRate * NetIncWorkA&psn ) ;      

        * Phase-out of MAWTO ;
        ELSE IF NetIncworkA&psn > MawtoThr1 THEN MawtoA&psn = MAX( 0 , MawtoMax - MawtoPhsOutRate * ( NetIncWorkA&psn - MawtoThr1 ) ) ;        

    END ;

%MEND Mawto ;

**********************************************************************************
*   Macro:   Dsto                                                                *
*   Purpose: Calculates the dependant spouse tax offset for the reference or the *
*            spouse. Also includes dependant (invalid and carer) tax offset, to  *
*            the extent it can be modelled. Modelling includes DSTO or DICTO     *
*            paid to the reference with respect to the spouse and vice versa.    *
*********************************************************************************;;

%MACRO Dsto( psn , partner ) ;

    * Calculate Dsto, then Dicto ;

    IF Coupleu = 1                              /* DSTO and DICTO are modelled for a couple */
    AND %IF &psn = r %THEN %DO ;                /* Primary income earner is assumed to receive the DSTO. Reference is assigned DSTO if ATIR are the same */
            AdjTaxIncAr >= AdjTaxIncAs          /* ATIR is used because the member with the higher ATIR is likely to extract the most benefit from a lower spouse ATIR */
        %END ;
        %ELSE %IF &psn = s %THEN %DO ;
            AdjTaxIncAs > AdjTaxIncAr
        %END ;
    THEN DO ;

        * Calculate DSTO ;
        * NOTE: DSTO abolished from 1 July 2014, Budget 2014. Not yet enacted ;

        IF ActualAge&partner >= &Year - 1 - 1952                /* &psn is born after 1 July 1952 from 1 July 2012 (Subsec 159J(1C) of the ITAA 1936) */
        AND AdjTaxIncA&psn <= DstoIncThr                                    /* &psn Adjusted Taxable Income for Rebates is more than the income limit for FTBB (Subsec 159J(1AB) of the ITAA 1936) */
        AND ( FtbbFinalA <= 0                                               /* Proxy for &psn is not member of a FTBB family (Subsec 159JA(1) of the ITAA 1936) */
           /*OR ( ParentLeavePayr <= 0 OR ParentLeavePays <= 0 ) */)        /* Paid Parental Leave is not payable to the family (Subsec 159JA(1) of the ITAA 1936 */
        THEN DO ;

            * Assign DSTO eligibility flag ;
            DstoFlag&psn = 1 ;

            * Calculate Dsto for eligible taxpayers ;
            IF AdjTaxIncA&partner <= DstoThr THEN DstoA&psn = DstoMax ;

            ELSE IF AdjTaxIncA&partner > DstoThr THEN DstoA&psn = MAX( 0 , DstoMax - DstoTpr * ( AdjTaxIncA&partner - DstoThr ) ) ;       /* The Adjusted Taxable Income is used as proxy for the Adjusted Taxable Income for Rebates (ATIR) for DSTO */

        END ;

        * Calculate DICTO (with respect to invalid spouse only) ;

        ELSE IF DstoA&psn = 0                                            /* DICTO is not paid to &psn who already receives DSTO */
        AND AdjTaxIncAr + AdjTaxIncAs <= DictoIncThr                     /* Family ATIR is more than the income limit for FTBB (Subsec 159J(1AB) of the ITAA 1936) */
        AND FtbbFinalA <= 0                                              /* Proxy for &psn is not member of a FTBB family (Subsec 159JA(1) of the ITAA 1936) */
        AND DspPenBasicF&psn > 0                                         /* Invalid dependant receives Disability Support Pension */
        /* Dicto with respect to dependent carers is not modelled */
        THEN DO ;

            * Assign Dicto eligibility flag ;
            DictoFlag&psn = 1 ;

            * Calculate Dicto for eligible taxpayers ;
            IF AdjTaxIncA&partner <= DictoThr THEN DictoA&psn = DictoMax ;

            ELSE IF AdjTaxIncA&partner > DictoThr THEN DictoA&psn = MAX( 0 , DictoMax - DictoTpr * ( AdjTaxIncA&partner - DictoThr ) ) ;

        END ;

    END ;

%MEND Dsto ;

**********************************************************************************
*   Macro:   SuperTo                                                             *
*   Purpose: Calculates the amount of tax offset on the amount of taxed and      *
*            untaxed superannuation benefits.                                    *
*********************************************************************************;;

%MACRO SuperTo( psn ) ;

    * Calculate amount of superannuation tax offset a person is eligible for. 
      Assume all benefits are income streams ;

    IF ActualAge&psn >= SuperTfAge THEN DO ;

        * For those over superannuation taxfree age, only benefits from taxable component untaxed elements attract a tax offset
          (Assume superannuation income stream) ;
        SuperToA&psn = IncTaxCompGovtSupImpA&psn * UntaxIncStrToRate ; 
 
    END ;

    ELSE IF ActualAge&psn >= SuperPresAge THEN DO ;

        * For those under superannuation taxfree age and above preservation age, 
          only benefits from taxable component taxed elements attract a tax offset
          (Assume superannuation income stream) ;
        SuperToA&psn = IncTaxCompPrivSupImpA&psn * TaxIncStrToRate ;

    END ;

    ELSE IF ActualAge&psn < SuperPresAge THEN DO ;

        * For those under preservation age no tax offset (assume superannuation income stream) ;
        SuperToA&psn = 0 ;

    END ;

%MEND SuperTo ;

**********************************************************************************
*   Macro:   MedLevPsn                                                           *
*   Purpose: Determine Medicare Levy liability and assign relevant parameters at *
*            the person level for the reference, spouse, and dependants.         *
*********************************************************************************;;

%MACRO MedLevPsn( psn ) ;

    * Assign person level flag and relevant parameters - for non-SAPTO or SAPTO person (Sec 7 of the MLA 1986) ;

    %IF &psn IN ( r , s ) %THEN %DO ;       * For reference or spouse ;

        * Non-SAPTO person ;

        IF SaptoA&psn <= 0 THEN DO ;

            * Assign Threshold Amount is the effective tax free threshold ;
            MedLevThr1Psn&psn = MedLevSingThr ;

            * Assign Phase-In Limit. It is derived from the Threshold Amount (Medicare levy is levied at the full rate after this point) ;
            MedLevThr2Psn&psn = MedLevShdInRate * MedLevThr1Psn&psn / ( MedLevShdInRate - MedLevRate ) ;

            * Assign person level Medicare levy liability flag. Person level liability may be modified by family level reduction ;
            IF TaxIncA&psn > MedLevThr1Psn&psn THEN MedLevType&psn = 'STANDARD' ;         

        END ;

        * SAPTO person ;

        ELSE IF SaptoA&psn > 0 THEN DO ;

            * Assign Threshold Amount ;
            MedLevThr1Psn&psn = MedLevSaptoThr ;

            * Assign Phase-In Limit. It is derived from the Threshold Amount (Medicare levy is levied at the full rate after this point) ;
            MedLevThr2Psn&psn = MedLevShdInRate * MedLevThr1Psn&psn / ( MedLevShdInRate - MedLevRate ) ;

            * Assign person level Medicare levy liability flag. Person level liability may be modified by family level reduction ;
            IF TaxIncA&psn > MedLevThr1Psn&psn THEN MedLevType&psn = 'SENIOR' ;         

        END ;

    %END ;

    %ELSE %IF &psn IN ( 1 , 2 , 3 , 4 ) %THEN %DO ;       * For dependants ;

        * Assign Threshold Amount is the effective tax free threshold ;
        MedLevThr1Psn&psn = MedLevSingThr ;

        * Assign Phase-In Limit. It is derived from the Threshold Amount (Medicare levy is levied at the full rate after this point) ;
        MedLevThr2Psn&psn = MedLevShdInRate * MedLevThr1Psn&psn / ( MedLevShdInRate - MedLevRate ) ;

        * Assign person level Medicare levy liability flag. Person level liability may be modified by family level reduction ;
        IF TaxIncA&psn > MedLevThr1Psn&psn THEN MedLevType&psn = 'STANDARD' ;         

    %END ;

    * Calculate the Medicare levy amount at the person level ;
    IF MedLevType&psn IN ( 'STANDARD' , 'SENIOR' ) THEN DO ;
       
        IF TaxIncA&psn <= MedLevThr2Psn&psn THEN MedLevA&psn = MedLevShdInRate * ( TaxIncA&psn - MedLevThr1Psn&psn ) ;

        ELSE IF TaxIncA&psn > MedLevThr2Psn&psn THEN MedLevA&psn = MedLevRate * TaxIncA&psn ;

    END ;

%MEND MedLevPsn ;

**********************************************************************************
*   Macro:   MedLevFamRed                                                        *
*   Purpose: Calculates the Medicare Levy family reduction amount for the        *
*            reference and spouse. This is the reduction in Medicare Levy for a  *
*            Medicare Levy family over the phase-in interval at the family level *
*            of income.                                                          *
*********************************************************************************;;

%MACRO MedLevFamRed( psn ) ;

    * Assign family level flag and relevant parameters - family or SAPTO family (Sec 8 of the MLA 1986) ;

    IF Coupleu = 1             /* Proxy for married (Sec 8 of MLA 1986) */
    /* &psn is entitled to a child house keeper rebate (Class 2 of table in Subsec 159J(2) of ITAA 1936). Not modelled */
    /* &psn is entitled to a sole parent rebate (Sec 159K of ITAA 1936). Not modelled */
    /* &psn is entitled to a house keeper rebate (Sec 159L of ITAA 1936). Not modelled */
    OR DepsML > 0         /* Sole parents are included by this condition. Number of Medicare Levy dependants also affect family Threshold Amount */
    THEN DO ; 

        * Calculate Family Income (Subsec 8(5) of MLA 1986) ;

        %IF &psn = r %THEN %DO ;

            MedLevIncAU = TaxIncAr + TaxIncAs ;                           

        %END ;

        * Flag for standard family and calculate family Income Threshold (Sec 8 of MLA 1986) ;    

        IF SaptoA&psn <= 0 THEN DO ;              

            * Flag for a standard Medicare Levy family (Subsec 8(1) of MLA 1986) ;
            MedLevFamType&psn = 'FAMILY' ;       

            * Calculate Family Income Threshold (Subsec 8(5) of MLA 1986) ;                
            MedLevFamThr&psn = MedLevFamIncThr + DepsML * MedLevThrDep ;            

        END ;

        * Flag for SAPTO family and calculate Family Income Threshold (Subsec 8(7) of MLA 1986) ; 

        ELSE IF SaptoA&psn > 0 THEN DO ;

            * Flag for a SAPTO Medicare levy family (Subsec 8(1) of MLA 1986) ;
            MedLevFamType&psn = 'FAMILYSENIOR' ; 

            * Calculate SAPTO Family Income Threshold (Subsec 8(5) and 8(7) of MLA 1986) ;                
            MedLevFamThr&psn = MedLevSaptoFamIncThr + DepsML * MedLevThrDep ;         

        END ;

                * Calculate the Medicare levy family Reduction Amount (Sec 8 of the MLA 1986) ;

        * If Family Income is less than the Family Income Threshold, the reference or spouse do not pay the Medicare levy (Subsec 8(1) of the MLA 1986) ;

        IF MedLevIncAU <= MedLevFamThr&psn THEN DO ;

            MedLevType&psn = ( '' ) ;       

            MedLevA&psn = 0 ;

        END ;

        * If Family Income is greater than the Family Income Threshold, a Reduction Amount may apply for the reference or spouse (Subsec 8(2) and 8(3) of the MLA 1986) ;

        ELSE IF MedLevIncAU > MedLevFamThr&psn THEN DO ;

            * Calculate the family Reduction Amount ;

            MedLevRedA&psn = MAX( 0 , MedLevRate * MedLevFamThr&psn - ( MedLevShdInRate - MedLevRate ) * ( MedLevIncAU - MedLevFamThr&psn) ) ; 

            * Transfer of family Reduction Amount between reference and spouse may or may not apply ;
            * No transfer if single with dependants, or one member of the couple does not have Medicare levy liability (Subsec 8(2) of MLA 1986) ;
            * If a couple, calculate apportionment of family Reduction Amount between the reference and spouse (Subsec 8(3) of MLA 1986) ;
            * and calculate the transfer of any excess between the reference and spouse (Subsec 8(4) the of MLA 1986) ;

            IF MedLevAr > 0              /* Reference is liable for Medicare levy */
            AND MedLevRedA&psn > 0       /* Family has a Reduction Amount */
            AND Coupleu = 1              /* Proxy for married. That is there is a spouse to share the Reduction Amount with */
            AND MedLevAs > 0             /* Spouse is liable for Medicare levy */
            THEN DO ;

                * Family Reduction Amount attributed to the reference and spouse ;

                MedLevRedA&psn = MedLevRedA&psn * ( TaxIncA&psn / MedLevIncAU ) ;

                * Reference or spouse has excess family Reduction Amount if it is more than their Medicare levy liability ;

                IF MedLevRedA&psn > MedLevA&psn THEN XMedLevRedA&psn = MedLevRedA&psn - MedLevA&psn ;
                    
            END ;       * Calculate apportionment of family Reduction Amount between members of an eligible couple ;

        END ;       * Calculate family Reduction Amount ;

    END ;       * Calculate modification to person level Medicare Levy liability for a Medicare levy family ;

%MEND MedLevFamRed ;

**********************************************************************************
*   Macro:   MedLevSur                                                           *
*   Purpose: Calculates the Medicare levy surcharge for the reference, spouse,   *
*            and dependants.                                                     *
*********************************************************************************;;

%MACRO MedLevSur( psn ) ;

    * Income for surcharge purposes (Sec 995-1 of the ITAA 1997) will be created as part of the income definition module ; 

    %IF &psn = r %THEN %DO ;        * Calculate family income once for each couple ;

        IF Coupleu = 1 THEN DO ;             

            IncMlsAu = IncMlsAr + IncMlsAs ;

        END ;

    %END ;

    * Where person is married, or person has dependants and is not married (Sec 8C and 8D of the MLA 1986) ;

    %IF &psn IN ( r , s ) %THEN %DO ;                * For the reference or spouse only, evaluate the following ;

        IF ( Coupleu = 1 OR DepsMls > 0 )  /* Is a Medicare levy family (married or single with dependants) */
        AND PrivHlthInsu = 0               /* The Medicare levy family does not have adequate PHI cover */
        THEN DO ;
     
            * Assign Tier thresholds ;
            MedLevSurTier1Psn&psn = MedLevSurTier1ThrC + MAX( 0 , DepsMLS - 1 ) * MedLevSurThrDep ;

            MedLevSurTier2Psn&psn = MedLevSurTier2ThrC + MAX( 0 , DepsMLS - 1 ) * MedLevSurThrDep ;

            MedLevSurTier3Psn&psn = MedLevSurTier3ThrC + MAX( 0 , DepsMLS - 1 ) * MedLevSurThrDep ;

            * Assign liability flag for &psn who is single with dependants, and assign Medicare levy surcharge rates ;
            IF Coupleu = 0 
            AND IncMlsA&psn > MedLevSurTier1Psn&psn 
            THEN DO ;

                MedLevSurType&psn = 'SINGDEP' ;

                IF IncMlsA&psn <= MedLevSurTier2Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate1 ;

                ELSE IF IncMlsA&psn <= MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate2 ;

                ELSE IF IncMlsA&psn > MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate3 ;

            END ;

            * Assign liability flag for &psn who is married, and assign Medicare levy surcharge rates ;
            ELSE IF Coupleu = 1 
            AND IncMlsAu > MedLevSurTier1Psn&psn      /* &psn couple income for MLS is above Tier 1 threshold */
            AND IncMlsA&psn > MedLevSingThr           /* &psn individual income for MLS is above Medicare levy single person Threshold Amount */
            THEN DO ;

                MedLevSurType&psn = 'MARRIED' ;

                IF IncMlsAu <= MedLevSurTier2Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate1 ;

                ELSE IF IncMlsAu <= MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate2 ;

                ELSE IF IncMlsAu > MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate3 ;

            END ;

        END ;

    %END ;

    * Where person is single and do not have dependants (Sec 8B of the MLA 1986) ;

    %IF &psn IN ( r , 1 , 2 , 3 , 4 ) %THEN %DO ;        * Evaluate for the reference or dependants only ;

        %IF &psn = r %THEN %DO ;                            /* Evaluate for reference who is single without dependants */
            IF Coupleu = 0 AND DepsMLS = 0 AND PrivHlthIns&psn = 0 THEN DO ;
        %END ;
        %ELSE %IF &psn IN( 1 , 2 , 3 , 4 ) %THEN %DO ;  /* Evaluate for dependants */
            IF PrivHlthIns&psn = 0 THEN DO ;                
        %END ;

            * Assign Tier thresholds ;
            MedLevSurTier1Psn&psn = MedLevSurTier1ThrS ;

            MedLevSurTier2Psn&psn = MedLevSurTier2ThrS ;

            MedLevSurTier3Psn&psn = MedLevSurTier3ThrS ;

            * Assign liability flag for &psn who is single without dependants, and assign Medicare levy surcharge rates ;
            IF IncMLSA&psn > MedLevSurTier1Psn&psn THEN DO ;

                MedLevSurType&psn = 'SINGNODEP' ;

                IF IncMLSA&psn <= MedLevSurTier2Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate1 ;

                ELSE IF IncMLSA&psn <= MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate2 ;

                ELSE IF IncMLSA&psn > MedLevSurTier3Psn&psn THEN MedLevSurRatePsn&psn = MedLevSurRate3 ;

            END ;

        END ;

    %END ;

    * Calculate Medicare levy surcharge liability. Levied on taxable income plus reportable fringe benefit ;

    IF MedLevSurType&psn NOT IN ( '' ) THEN 
    MedLevSurA&psn = MedLevSurRatePsn&psn * ( TaxIncA&psn 
                    %IF &psn IN ( r , s ) %THEN %DO ;
                   + RepFbA&psn 
                    %END ;
                    ) ;

%MEND MedLevSur ;

**********************************************************************************
*   Macro:   TempBudgRepLev                                                      *
*   Purpose: Calculates the Temporary Budget Repair levy for the reference,      *
*            spouse, and dependants. The levy is payable only for the 2014-15,   *
*            2015-16, and 2016-17 Financial Year.                                *
*********************************************************************************;;

%MACRO TempBudgRepLev( psn ) ;

    * For 2014-15, 2015-16, and 2016-17 Financial Years only ;

    %IF ( &Duration = A AND ( &Year > 2013 AND &Year < 2017 ) )
	OR ( &Duration = Q AND &Year > 2014 AND &Year < 2017 )
	OR ( &Duration = Q AND &Year = 2014 AND ( ( &Quarter = Sep ) OR ( &Quarter = Dec ) ) )
	OR ( &Duration = Q AND &Year = 2017 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) )
	%THEN %DO ;

        IF TaxIncA&psn <= TempBudgRepLevThr THEN TempBudgRepLevA&psn = 0 ;

        ELSE /* IF TaxIncA&psn > TempBudgRepLevThr */ TempBudgRepLevA&psn = TempBudgRepLevRate * ( TaxIncA&psn - TempBudgRepLevThr ) ;

	%END ;

%MEND TempBudgRepLev ;

**********************************************************************************
*   Macro:   HelpArray                                                           *
*   Purpose: Create 2 arrays. First array contains tier thresholds. Second array *
*            contains tier repayment rates.                                      *
*********************************************************************************;;

%MACRO HelpArray( ) ;

    * The size of these arrays are determined dynamically by the number of array elements read in 
      and there is no limit to the number of tier parameters allowed ;

    * This array holds all repayment tier thresholds (that is all variables with a txHelpThr prefix are assigned to this array) ;

    ARRAY txHelpThr{ * } txHelpThr: ;     * Eg txHelpThr1 is the first repayment tier threshold at $45,000 for 2018/19 ;

    * This array holds all tier repayment rates (that is all variables with a txHelpRate prefix are assigned to this array);

    ARRAY txHelpRate{ * } txHelpRate: ;   * Eg txHelpRate1 is the first repayment tier rate at 1.0% for 2018/19 ;      

    IF _N_ = 1 THEN DO ;

        * Counts the number of txHelpRate parameters in the txHelpRate array ;
        NumHelpRates = DIM( txHelpRate ) ;     
        
        * Check number of array variables assigned are consistent in case unwanted variables with the same prefixes are also read in ;
        IF NumHelpRates NE DIM( txHelpThr ) THEN PUT "ERROR: NUMBER OF TIER THRESHOLDS NOT EQUAL TO TIER RATES" ;

    END ;

%MEND HelpArray ;

*********************************************************************************
*   Macro:   HelpPay                                                            *
*   Purpose: Calculates repayment amount by applying tier repayment rates to	*
*			 rebate income.                                                     *
*********************************************************************************;;

%MACRO HelpPay( psn ) ;

NumHelpTier = DIM( txHelpRate ); 			/* Specify number of tiers */


	*	HELP repayments are only made if individual has positive HELP debt, and are liable for positive Medicare levy
		amount or are not eligible for a reduction in the Medicare levy ;



	IF HelpDebt&psn > 0 THEN DO ; 			/* If HELP debt is positive then check Medicare levy status */

		IF MedLevRedA&psn > 0				/* Eligible for Medicare levy reduction */
		OR MedLevA&psn = 0 THEN DO ;		/* Not liable for positive Medicare levy amount */					

			HelpPayA&psn = 0 ; 				/* Individual not liable for HELP repayments */

		END ;								/* End not liable condition */

		ELSE IF MedLevRedA&psn = 0			/* Not eligible for Medicare levy reduction */
		OR MedLevA&psn > 0	THEN DO ;		/* Liable for positive Medicare levy amount */
		
			* Repayment Calculator ;

			IF RebIncA&psn <= txHelpThr1 THEN DO ;	/* If repayment (rebate) income is less or equal to first tier threshold */

        		HelpPayA&psn = 0 ;					/* Repayment amount is equal to zero */	

    		END ;									/* End income below lowest threshold condition */
	
		    ELSE IF RebIncA&psn > txHelpThr1				/* If repayment (rebate) income is above first threshold */
			AND RebIncA&psn <= MAX(OF txHelpThr { * } )		/* If repayment (rebate) income is below the highest threshold */
			THEN DO i = 2 TO NumHelpTier ;					/* Then run through all of the tiers to find which tier they belong to */	
				
		        IF RebIncA&psn > txHelpThr{ i - 1 }
				AND RebIncA&psn <= txHelpThr{ i } THEN DO ; 					/*  Assign individual to appropriate tier */

		            HelpPayA&psn = txHelpRate{ i - 1 } * RebIncA&psn ;			/*  Repayment amount is equal to repayment (rebate) income multiplied by the tier rate */

		        END ;								/* End repayment calculation for individuals above first threshold and below the highest threshold */

	    	END ;									/* End income above first threshold and below highest threshold condition */

			ELSE DO ;								/* If repayment (rebate) income is above the highest threshold */

				HelpPayA&psn = MAX(OF txHelpRate { * } ) * RebIncA&psn ;							/* Repayment amount is equal to repayment (rebate) income multiplied by the highest tier rate */

			END ;									/* End income above highest threshold condition */


		END ;										/* End repayment calculator */

	END ;											/* End positive HELP debt condition */

	ELSE IF HelpDebt&psn = 0 THEN DO ;				/* Individual has no HELP debt */
		
		HelpPayA&psn = 0 ;							/* Repayment amount is equal to zero */

	END ;											/* End no HELP debt condition */													


%MEND HelpPay ;

**********************************************************************************
*   Macro:   FinalTaxLiab                                                        *
*   Purpose: Calculates the summary tax variables, including total tax offsets,  *
*            net income tax, tax offsets used, amounts of refundable tax offset, *
*            total levies and charges, and the final amount payable or           *
*            refundable. Note that some code is run for the reference and spouse *
*            only.                                                               *
*********************************************************************************;;

%MACRO FinalTaxLiab( psn ) ;

    * Calculate total tax offset entitlement ;

    TotTaxOffsetA&psn = BentoA&psn
                      + LitoA&psn
					  + LamitoA&psn
                      + FrankCrImpA&psn       /* Refundable tax offset */
                      %IF &psn IN ( r , s ) %THEN %DO ;
                      + SuperToA&psn
                      + SaptoA&psn            /* Transferrable tax offset. Amount is post-transfer */
                      + MawtoA&psn 
                      + DstoA&psn 
                      %END ; 
                      ;
                                    
    * Calculate net income tax ;

    NetIncTaxA&psn = MAX( 0 , GrossIncTaxA&psn - TotTaxOffsetA&psn ) ;

    * Calculate amount of unused refundable tax offset. It is equal to the amount of excess total tax offset, but not more than the amount of refundable tax offset ;

    XRefTaxOffsetA&psn = MIN( FrankCrImpA&psn , MAX( 0 , TotTaxOffsetA&psn - GrossIncTaxA&psn ) ) ;

    * Calculate amount of levies and charges ;

	*As HELP payments are only calculated for recipient and spouse, we need to 
	adjust the calculation of LevyAndChargeA accordingly;

	%IF &psn = r OR &psn = s %THEN %DO ;  

	    LevyAndChargeA&psn = MedLevA&psn           /* Medicare levy */
	                       + MedLevSurA&psn        /* Medicare levy surcharge */
	                       + TempBudgRepLevA&psn  /* Temporary Budget Repair levy */
						   + HelpPayA&psn	;	   /* HELP debt repayment */
	%END ; 

	%ELSE %DO ; 

    LevyAndChargeA&psn = MedLevA&psn           /* Medicare levy */
                       + MedLevSurA&psn        /* Medicare levy surcharge */
                       + TempBudgRepLevA&psn ; /* Temporary Budget Repair levy */

	%END ; 

    * Calculate amount payable or refundable. Positive amount is amount payable, negative amount is amount refundable ;

    PayOrRefAmntA&psn = NetIncTaxA&psn         /* Net income tax */
                      - XRefTaxOffsetA&psn     /* Unused refundable tax offset */
                      + LevyAndChargeA&psn ;   /* Levies and charges */

    * Calculate the amount of each tax offset used, applied in accordance with priority rules (Sec 63-10 of the ITAA 1997) ;

    UsedTotTaxOffsetA&psn = MIN( GrossIncTaxA&psn , TotTaxOffsetA&psn ) ;   * Total tax offset used ;

    CumGrossIncTaxA&psn = GrossIncTaxA&psn ;                                * Initialise cumulative gross income tax to gross income tax. Temporary variable ;

    %IF &psn IN ( r , s ) %THEN %DO ;                                       * SAPTO used by reference and spouse ;

        UsedSaptoA&psn = MIN( SaptoA&psn , CumGrossIncTaxA&psn ) ;

        CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - SaptoA&psn ) ;

    %END ;

    UsedBentoA&psn = MIN( BentoA&psn , CumGrossIncTaxA&psn ) ;              * BENTO used ;

    CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - BentoA&psn ) ;

    UsedLitoA&psn = MIN( LitoA&psn , CumGrossIncTaxA&psn ) ;                * LITO used ;

    CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - LitoA&psn ) ;

	UsedLamitoA&psn = MIN( LamitoA&psn , CumGrossIncTaxA&psn ) ;                * LAMITO used ;

    CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - LamitoA&psn ) ;

    %IF &psn IN ( r , s ) %THEN %DO ;                                       * MAWTO, Super tax offset, DSTO and DICTO used by reference and spouse ;
                                                                            * They are aggregated under Item 20, Subsec 63-10(1) of the ITAA 1997 so ordering does not matter ;
        UsedItem20A&psn = MIN( DstoA&psn + DictoA&psn + MawtoA&psn + SuperToA&psn , CumGrossIncTaxA&psn ) ;

        CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - DstoA&psn - DictoA&psn - MawtoA&psn - SuperToA&psn ) ;

    %END ;

    UsedFrankCrA&psn = MIN( FrankCrImpA&psn , CumGrossIncTaxA&psn ) ;       * Franking credit used ;

    CumGrossIncTaxA&psn = MAX( 0 , CumGrossIncTaxA&psn - FrankCrImpA&psn ) ;

    DROP CumGrossIncTaxA&psn ;     

%MEND FinalTaxLiab ;

**********************************************************************************
*   Macro:   Fortnightly                                                         *
*   Purpose: Convert key variables created in this module to fortnightly rates.  *
*********************************************************************************;;

%MACRO Fortnightly( psn ) ;

    * Declare array that holds key variables in annual rates ;

    ARRAY KeyVarAnnual&psn{ * }

        /* Tax offsets */
        %IF &psn IN ( r , s ) %THEN %DO ;

            SaptoA&psn MawtoA&psn DstoA&psn DictoA&psn SuperToA&psn

        %END ;

        BentoA&psn LitoA&psn LamitoA&psn FrankCrImpA&psn                        

        /* Levies and charges */
        MedLevA&psn MedLevSurA&psn TempBudgRepLevA&psn                

        /* Aggregates */
        GrossIncTaxA&psn NetIncTaxA&psn TotTaxOffsetA&psn LevyAndChargeA&psn PayOrRefAmntA&psn 
        UsedTotTaxOffsetA&psn XRefTaxOffsetA&psn    

        /* Tax offsets used */
        %IF &psn IN ( r , s ) %THEN %DO ;

            UsedSaptoA&psn UsedItem20A&psn

        %END ;

        UsedBentoA&psn UsedLitoA&psn UsedLamitoA&psn UsedFrankCrA&psn ;        

    * Declare array that will hold key variables in fortnightly rates ;

    ARRAY KeyVarFortnightly&psn{ * }

        /* Tax offsets */
        %IF &psn IN ( r , s ) %THEN %DO ;

            SaptoF&psn MawtoF&psn DstoF&psn DictoF&psn SuperToF&psn 

        %END ;

        BentoF&psn LitoF&psn LamitoF&psn FrankCrImpF&psn                     

        /* Levies and charges */
        MedLevF&psn MedLevSurF&psn TempBudgRepLevF&psn                

        /* Aggregates */
        GrossIncTaxF&psn NetIncTaxF&psn TotTaxOffsetF&psn LevyAndChargeF&psn PayOrRefAmntF&psn 
        UsedTotTaxOffsetF&psn XRefTaxOffsetF&psn    

        /* Tax offsets used */
        %IF &psn IN ( r , s ) %THEN %DO ;

            UsedSaptoF&psn UsedItem20F&psn

        %END ;

        UsedBentoF&psn UsedLitoF&psn UsedLamitoF&psn UsedFrankCrF&psn ;        

    * Convert annual rates into fortnightly rates ;

    DO i = 1 TO DIM( KeyVarAnnual&psn ) ;

        KeyVarFortnightly&psn{ i } = KeyVarAnnual&psn{ i } / 26 ;
        
    END ;

    DROP i ;

%MEND Fortnightly ;

%RunTax
