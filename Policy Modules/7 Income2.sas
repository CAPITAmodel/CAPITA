
**************************************************************************************
* Program:      7 Income2.sas                                                        *
* Description:  Constructs income defintions for use in the policy modules           *
*               additional to those constructed in the Income1 module. The income    *
*               definitions contained in Income2 are various income definitions      *
*               required for taxation purposes.                                      *
**************************************************************************************;

***********************************************************************************
*   Macro:   RunIncome2                                                           *
*   Purpose: Coordinate income calculation and dependency definition              *
**********************************************************************************;;

%MACRO RunIncome2 ;

    ***********************************************************************************
    *      1.        Calculate Taxable Transfer Income                                *
    *                                                                                 *
    **********************************************************************************;

    * Calculate taxable transfer income ;

    %TaxTranInc( r )

    IF Coupleu = 1 THEN DO ;

        %TaxTranInc( s )

    END ;

    ***********************************************************************************
    *      2.        Calculate Taxable Income                                         *
    *                                                                                 *
    **********************************************************************************;

    * Calculate taxable income ;

    %TaxInc( r )

    IF Coupleu = 1 THEN DO ;

        %TaxInc( s )

    END ;

    ***********************************************************************************
    *      3.        Calculate Rebate Income                                          *
    *                                                                                 *
    **********************************************************************************;

    * Calculate Rebate Income (for SAPTO) ;

    %RebInc( r )

    IF Coupleu = 1 THEN DO ;

        %RebInc( s )

    END ;

    ***********************************************************************************
    *      4.        Calculate Net Income from Working                                *
    *                                                                                 *
    **********************************************************************************;

    * Calculate Net Income from Working (for MAWTO) ;

    %NetIncWork( r )

    IF Coupleu = 1 THEN DO ;

        %NetIncWork( s )

    END ;

    ***********************************************************************************
    *      5.        Calculate Rebatable Benefit                                      *
    *                                                                                 *
    **********************************************************************************;

    * Calculate Rebatable Benefit (for BENTO) ;

    %RebBft( r )

    IF Coupleu = 1 THEN DO ;

        %RebBft( s )

    END ;

    ***********************************************************************************
    *      6.        Calculate Income for Surcharge Purposes                          *
    *                                                                                 *
    **********************************************************************************;

    * Calculate Income for Surcharge Purposes (for Medicare levy surcharge) ;

    %IncMedLevSur( r )

    IF Coupleu = 1 THEN DO ;

        %IncMedLevSur( s )

    END ;

    ***********************************************************************************
    *      7.        Calculate Adjusted Taxable Income                                *
    *                                                                                 *
    **********************************************************************************;

    * Calculate Adjusted Taxable Income (for FTB, DSTO, DICTO) ;

    %AdjustedTaxIncome( r )

    IF Coupleu = 1 THEN DO ;

        %AdjustedTaxIncome( s )

    END ;

    ***********************************************************************************
    *      8.        Calculate income definitions for dependants                      *
    *                                                                                 *
    **********************************************************************************;

    %DO i = 1 %TO 4 ;

        IF ActualAge&i > 0 THEN DO ; 

            %TaxTranInc( &i )

            %TaxInc( &i )

            %RebBft( &i ) 

            %IncMedLevSur( &i ) 

            %AdjustedTaxIncome( &i ) 

        END ;

    %END ;

%MEND RunIncome2 ;

**********************************************************************************
*   Macro:   TaxTranInc                                                          *
*   Purpose: Calculate taxable transfer income. This forms part of assessable    *
*            income.                                                             *
*********************************************************************************;;

%MACRO TaxTranInc( psn ) ;

    * Use AtiFlag for applicable pensions to indicate whether they are taxable or non-taxable. 
      If the recipient of the applicable pensions is below age pension age, the pension is
      non-taxable for tax purposes, but is included for ATI purposes ;

    %IF &psn = r %THEN %DO ;

        * Reference ;
        IF ( Sexr = 'F' AND 16 <= ActualAger < FemaleAgePenAge ) 
        OR ( Sexr = 'M' AND 16 <= ActualAger < MaleAgePenAge ) 

        THEN AtiFlagr = 1 ;      /* Flag for applicable pensions to indicate they are non-taxable */ 

        ELSE AtiFlagr = 0 ;      /* Flag for applicable pensions to indicate they are taxable */ 

        * Spouse ;
        IF ( Sexs = 'F' AND 16 <= ActualAges < FemaleAgePenAge ) 
        OR ( Sexs = 'M' AND 16 <= ActualAges < MaleAgePenAge ) 

        THEN AtiFlags = 1 ;      /* Flag for applicable pensions to indicate they are non-taxable */ 

        ELSE AtiFlags = 0 ;      /* Flag for applicable pensions to indicate they are taxable */ 

        * Carer Payment is taxable if recipient or care receiver is of Age Pension age. Assume only the spouse is the care receiver ;
        IF AtiFlagr = 0 OR ( AtiFlags = 0 AND Coupleu = 1 ) THEN DO ;
            CarerPenTaxFlagr = 1 ;                        
            CarerPenTaxFlags = 1 ; 
        END ;
 		ELSE DO; 
		    CarerPenTaxFlagr = 0 ;                        
            CarerPenTaxFlags = 0 ;
		END; 
    %END ;

    * Calculate taxable transfer income ;

                      /* Pensions */
    IncTaxTranF&psn = %IF &psn IN( r , s ) %THEN %DO ;
                      AgePenBasicF&psn                      /* Age Pension basic rate */
                    + AgePenSupBasicF&psn                   /* Age Pension Supplement Basic Amount */

                    + ( CarerPenBasicF&psn                  /* Carer Pension basic rate */
                    + CarerPenSupBasicF&psn )               /* Carer Pension Supplement Basic Amount */
                    * ( CarerPenTaxFlag&psn = 1 )           /* Taxable if recipient or care receiver is of Age Pension age. Assume only the spouse is the care receiver */

                    + ( DspPenBasicF&psn                    /* Disability Support Pension basic rate */
                    + DspPenSupBasicF&psn )                 /* DSP Supplement Basic Amount */
                    * ( AtiFlag&psn = 0 )                   /* Taxable if recipient or care receiver is of Age Pension age */

                    %IF &psn IN( r ) %THEN %DO ;
                    + PpsPenBasicF&psn                      /* Parenting Payment Single basic rate */
                    + PpsPenSupBasicF&psn                   /* Parenting Payment Single Pension Supplement Basic Amount */
                    %END ;

                    %IF &psn IN( s ) %THEN %DO ;
                    + ( WifePenBasicF&psn                   /* Wife Pension basic rate */
                    + WifePenSupBasicF&psn )                /* Wife Pension Supplement Basic Amount */
                    * ( AtiFlag&psn = 0 )                   /* Taxable if recipient or care receiver is of Age Pension age */
                    %END ;

                      /* Allowances */
                    + AbstudyNmF&psn                        /* Abstudy amount (equal to the Austudy amount on the SIH provided
                                                               they are less than the qualifying age for Austudy, added here
                                                               because they will not be captured in the modelled Austudy
                                                               amount below). Also note that the SIH amount is an estimate of
                                                               the basic amount, since the components are not separable on the
                                                               SIH. */
                    + AustudyAllBasicF&psn                  /* Austudy basic rate */
                    + JspAllBasicF&psn                      /* JobSeeker Payment basic rate */
                    + PartnerAllNmF&psn                     /* Partner Allowance on the SIH. The SIH amount is an estimate of
                                                               the basic amount, since the components are not separable on the
                                                               SIH. */
                    + PppAllBasicF&psn                      /* Parenting Payment Partnered basic rate */
                    + SickAllNmF&psn                        /* Sickness Allowance on the SIH. The SIH amount is an estimate of
                                                               the basic amount, since the components are not separable on the
                                                               SIH. */
                    + SpbAllNmF&psn                         /* Special Benefit on the SIH. The SIH amount is an estimate of
                                                               the basic amount, since the components are not separable on the
                                                               SIH. */
                    %IF &psn IN( r ) %THEN %DO ;
                    + WidowAllBasicF&psn                    /* Widow Allowance basic rate */
                    %END ;
                    +
                    %END ;
                      YaOtherAllBasicF&psn                  /* Youth Allowance (job seekers) */
                    + YaStudAllBasicF&psn                   /* Youth Allowance (students and Australian Apprentices) */

                    /* DVA payments */
                    %IF &psn IN( r , s ) %THEN %DO ;
                    + ServicePenBasicF&psn                  /* DVA Age Service Pension basic rate */
                    + ServicePenSupBasicF&psn               /* DVA Age Service Pension Supplement Basic Amount */
                    %END ;

                /* 2015-16 MYEFO measure to include PLP and DaPP in ordinary income definition from 1 October 2016 
				Structural policy change so reflect at 1 July 2016 for annual runs */
				
				%IF ( &Duration = A AND &Year > 2015 ) 
				OR ( &Duration = Q AND &Year > 2016 ) 
				OR ( &Duration = Q AND &Year = 2016 AND &Quarter = Dec ) 
				%THEN %DO ; 

                    /* Parental leave payments */
                    %IF &psn IN( r , s ) %THEN %DO ;
                    + ( PPLSW&psn * 2 )                     /* Parental Leave Pay */
                    + ( DaPPSW&psn * 2 )                    /* Dad and Partner Pay */
                    %END ;

				%END; 

					;

    IncTaxTranA&psn = IncTaxTranF&psn * 26 ;

%MEND TaxTranInc ;

**********************************************************************************
*   Macro:   TaxInc                                                              *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO TaxInc( psn ) ;
    
    * Calculate assessable income ;
    AssessableIncA&psn = IncTaxPrivA&psn            /* Taxable private income */
                       + IncTaxTranA&psn ;          /* Taxable transfer income */

    AssessableIncF&psn = AssessableIncA&psn / 26 ;

    * Calculate taxable income ;
    TaxIncA&psn = AssessableIncA&psn - DeductionA&psn ;

    TaxIncF&psn = TaxIncA&psn / 26 ;

%MEND TaxInc ;

**********************************************************************************
*   Macro:   RebInc                                                              *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO RebInc( psn ) ;
	*MYEFO 2016-17 Modify meaning of adjusted fringe benefits from 1 July 2017
	 so that the gross rather than the adjusted net value of reportable fringe 
	 benefits is used for tax offset purposes;
	%IF (&Duration = A AND &Year >= 2017) 
	    OR (&Duration = Q AND &Year > 2017)	
	    OR(&Duration = Q AND &Year = 2017 AND (&Quarter = Sep OR &Quarter = Dec) ) 
	%THEN %DO ;
		AdjFbA&psn = RepFbA&psn ;
	%END ;

    * Rebate Income for SAPTO ;
    * Sec 6 of the ITAA 1936 ;

    RebIncA&psn = TaxIncA&psn                    /* Taxable income */
                + RepSupContA&psn                /* Reportable superannuation contributions */
                + NetInvLossA&psn                /* Net investment loss */
                + AdjFbA&psn ;                   /* Adjusted fringe benefits */

    RebIncF&psn = RebIncA&psn / 26 ;

%MEND RebInc ;

**********************************************************************************
*   Macro:   NetIncWork                                                          *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO NetIncWork( psn ) ;

    * Net Income from Working for MAWTO ;
    * Sec 61-570 of the ITAA 1997 ;   

    NetIncWorkA&psn = IncServiceA&psn                /* Personal services income */
                    + IncBusA&psn                    /* Business income */
                    + RepFbA&psn                     /* Reportable fringe benefits */
                    + RepEmpSupContA&psn             /* Reportable employer superannuation contributions */
                    - DeductionWrkA&psn ;            /* Work related deductions */

    NetIncWorkF&psn = NetIncWorkA&psn / 26 ;

%MEND NetIncWork ;

**********************************************************************************
*   Macro:   RebBft                                                              *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO RebBft( psn ) ;

    * Rebatable Benefit for BENTO ;
    * Subsec 160AAA (1) of the ITAA 1936 ;
    * Benefits included in CAPITA are: Widow Allowance, Youth Allowance, Austudy, JobSeeker Payment, Sickness Allowance, Special Benefit, and Partner Allowance ;
    * Benefits not included in CAPITA are: Mature Age Allowance (post 30 June 1996), Disaster Recovery Allowance, and Community Development Employment Project ;

    RebBftA&psn = YaOtherAllBasicA&psn                /* Youth Allowance (job seekers) */
                + YaStudAllBasicA&psn                 /* Youth Allowance (students and Australian Apprentices) */
                %IF &psn IN( r , s ) %THEN %DO ;
                + AustudyAllBasicA&psn                /* Austudy basic rate */
                + JspAllBasicA&psn                    /* JobSeeker Payment basic rate */
                + SickAllNmA&psn                      /* Sickness Allowance on the SIH. The SIH amount is an estimate of
                                                         the basic amount, since the components are not separable on the
                                                         SIH. */
                + SpbAllNmA&psn                       /* Special Benefit on the SIH. The SIH amount is an estimate of
                                                         the basic amount, since the components are not separable on the
                                                         SIH. */
                + PartnerAllNmA&psn                   /* Partner Allowance on the SIH. The SIH amount is an estimate of
                                                         the basic amount, since the components are not separable on the
                                                         SIH. */
                + PppAllBasicA&psn                    /* Parenting Payment Partnered basic rate */
                %END ;
                %IF &psn IN( r ) %THEN %DO ;
                + WidowAllBasicA&psn                  /* Widow Allowance basic rate */
                %END ; 
                ;

    RebBftA&psn = FLOOR( RebBftA&psn ) ;              /* Subsection 13(4) of the ITA(1936 Act) Regulation 2015 the rebatable benefit amount is rounded down to the nearest whole dollar */

    RebBftF&psn = RebBftA&psn / 26 ;           

%MEND RebBft ;

**********************************************************************************
*   Macro:   AdjustedTaxIncome                                                   *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO AdjustedTaxIncome( psn ) ;

    * Based on FAA guide 3.2.3, only reportable benefits are assessable for the 
    purposes of the FTB, CCB, and baby bonus income tests. The reportable fringe 
    benefit amount is the grossed-up value of fringe benefits that appears on the 
    payment summary. Fringe benefits are recorded in the payment summary if their 
    (pre-gross-up) value exceeds $2000 in an FBT year. Assume that the fringe 
    benefits reported in SIH (IncSSFb and IncNonSSFb)are pre-gross-up value. 
    Add reportable fringe benefit amount. ;

    AdjTaxIncA&psn = TaxIncA&psn                          /* Taxable income */
                   %IF &psn IN ( r , s ) %THEN %DO ;
				   		%IF &Year > 2016 %THEN %DO ;
	                    + RepFbA&psn                      /* 2015-16 MYEFO measure - from 1 January 2017 use the reportable ('grossed-up') fringe benefit amount */
						%END ;
						%ELSE %DO ;
						+ AdjFbA&psn					  /* Adjusted fringe benefit amount */	
						%END ;

                   + NetInvLossA&psn                      /* Total Net Investment Loss */

                   /* Tax free pension or benefit */
                   + ( DspPenBasicA&psn                   /* Disability Support Pension basic rate */
                   + DspPenSupBasicA&psn )                /* DSP Supplement Basic Amount */
                   * ( AtiFlag&psn = 1 )                  /* Include in ATI if pension was non-taxable */

 				   + ( DspU21PenBasicA&psn      		  /* Disability Support Pension U21 basic rate */
                   + DspU21PenSupBasicA&psn )   		  /* DSPU21 Supplement Basic Amount */
                   * (AtiFlag&psn = 1 )         		  /* Include if non-taxable */

                   %IF &psn IN ( s ) %THEN %DO ;                   
                   + ( WifePenBasicA&psn                  /* Wife Pension basic rate */
                   + WifePenSupBasicA&psn )               /* Wife Pension Supplement Basic Amount */
                   * ( AtiFlag&psn = 1 )                  /* Include in ATI if pension was non-taxable */
                   %END ;

                   + ( CarerPenBasicA&psn                 /* Carer Pension basic rate */
                   + CarerPenSupBasicA&psn )              /* Carer Pension Supplement Basic Amount */
                   * ( CarerPenTaxFlag&psn = 0 )          /* Include in ATI if pension was non-taxable */


                   + DvaDisPenNmA&psn                       /* DVA Disability Pension on the SIH. The SIH amount is an
                                                               estimate of the basic amount, since the components are not
                                                               separable on the SIH. */ 
                   + DvaWwPenNmA&psn                        /* DVA War Widow Pension on the SIH. The SIH amount is an
                                                               estimate of the basic amount, since the components are not
                                                               separable on the SIH. */ 
                   + RepSupContA&psn                        /* Reportable superannuation contribution */   
                   - DedChildMaintA&psn                     /* Deductible child maintenance expenditure */
                   %END ;
                   ;

    AdjTaxIncF&psn = AdjTaxIncA&psn / 26 ;

%MEND AdjustedTaxIncome ;

**********************************************************************************
*   Macro:   IncMedLevSur                                                        *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO IncMedLevSur( psn ) ;

    * Income for Surcharge purposes for Medicare levy surcharge ;
    * Calculate income for Medicare levy surcharge purposes (Sec 995-1 of the ITAA 1997). For each taxpayer and each married couple ;

    IncMlsA&psn = TaxIncA&psn               /* Taxable Income */
                %IF &psn IN( r , s ) %THEN %DO ;
                + RepFbA&psn                /* Reportable Fringe Benefit */
                + RepSupContA&psn           /* Reportable Superannuation Contributions */
                + NetInvLossA&psn           /* Net Investment Loss */  
                %END ;
                ;
                
    IncMlsF&psn = IncMlsA&psn / 26 ;
 
%MEND IncMedLevSur ;

* Call %RunIncome2 ;
%RunIncome2



