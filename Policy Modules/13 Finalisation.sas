***********************************************************************************
* Name of program: 13 Finalisation.sas                                            *
* Description: Calculate summary variables.                                       * 
**********************************************************************************;

***********************************************************************************
*   Macro:   FinalisationMaster                                                   *
*   Purpose: Coordinate calculation of final summary variables                    *
**********************************************************************************;;

%MACRO RunFinalisation ;

    ***********************************************************************************
    *      1.        Calculate transfer income                                        *
    *                                                                                 *
    **********************************************************************************;

    %TranInc( r )

    IF Coupleu = 1 THEN DO ;

        %TranInc( s )

    END ;

    ***********************************************************************************
    *      2.        Calculate disposable income                                      *
    *                                                                                 *
    **********************************************************************************;

    %DispInc( r )

    IF Coupleu = 1 THEN DO ;

        %DispInc( s )

    END ;

    ***********************************************************************************
    *      3.        Calculate summary variables for dependants                       *
    *                                                                                 *
    **********************************************************************************;

    %DO i = 1 %TO 4 ;

        IF ActualAge&i > 0 THEN DO ; 

            %TranInc( &i )

            %DispInc( &i )

        END ;

    %END ;

    ***********************************************************************************
    *      4.        Calculate income unit level incomes                              *
    *                                                                                 *
    **********************************************************************************;

    %IncomeUnit

%MEND RunFinalisation ;

**********************************************************************************
*   Macro:   TranInc                                                             *
*   Purpose: Calculate income for income test                                    *
*********************************************************************************;;

%MACRO TranInc( psn ) ;

    * Non-taxable transfer income ;

                         /* Pensions */
    IncNonTaxTranF&psn = %IF &psn IN( r , s ) %THEN %DO ;
                         AgePenSupRemF&psn          /* Age Pension Supplement Remaining Amount */
                       + AgeRAssF&psn               /* Age Pension Rent Assistance */
                       + AgePharmAllF&psn           /* Age Pension Pharmaceutical Allowance */
                       + AgePenSupMinF&psn          /* Age Pension Supplement Minimum Amount */
                       + AgePenEsF&psn              /* Age Pension ES */

                       + ( CarerPenBasicF&psn       /* Carer Payment basic rate */
                       + CarerPenSupBasicF&psn )    /* Carer Payment Supplement Basic Amount */
                       * ( CarerPenTaxFlag&psn = 0 )/* Include if non-taxable */
                       + CarerPenSupRemF&psn        /* Carer Payment Supplement Remaining Amount */
                       + CarerRAssF&psn             /* Carer Payment Rent Assistance */
                       + CarerPharmAllF&psn         /* Carer Payment Pharmaceutical Allowance */
                       + CarerPenSupMinF&psn        /* Carer Payment Supplement Minimum Amount */
                       + CarerPenEsF&psn            /* Carer Payment ES */

                       + ( DspPenBasicF&psn         /* Disability Support Pension basic rate */
                       + DspPenSupBasicF&psn )      /* DSP Supplement Basic Amount */
                       * ( AtiFlag&psn = 1 )        /* Include if non-taxable */
                       + DspPenSupRemF&psn          /* Disability Support Pension Supplement Remaining Amount */
                       + DspRAssF&psn               /* Disability Support Pension Rent Assistance */
                       + DspPharmAllF&psn           /* Disability Support Pension Pharmaceutical Allowance */
                       + DspPenSupMinF&psn          /* Disability Support Pension Supplement Minimum Amount */
                       + DspPenEsF&psn              /* Disability Support Pension ES */

                       + ( DspU21PenBasicF&psn      /* Disability Support Pension U21 basic rate */
                       + DspU21PenSupBasicF&psn )   /* DSPU21 Supplement Basic Amount */
                       * (AtiFlag&psn = 1 )         /* Include if non-taxable */
                       + DspU21PenSupRemF&psn       /* Disability Support Pension U21 Supplement Remaining Amount */
                       + DspU21RAssF&psn            /* Disability Support Pension U21 Rent Assistance */
                       + DspU21PharmAllF&psn        /* Disability Support Pension U21 Pharmaceutical Allowance */
                       + DspU21PenSupMinF&psn       /* Disability Support Pension U21 Supplement Minimum Amount */
                       + DspU21PenEsF&psn           /* Disability Support Pension U21 ES */
      
                       %IF &psn IN( r ) %THEN %DO ;
                       + PpsRAssF&psn               /* Parenting Payment Single Pension Rent Assistance */
                       + PpsPharmAllF&psn           /* Parenting Payment Single Pension Pharmaceutical Allowance */
                       + PpsPenEsF&psn              /* Parenting Payment Single Pension ES */
                       %END ;

                       %IF &psn IN( s ) %THEN %DO ;
                       + ( WifePenBasicF&psn        /* Wife Pension basic rate */
                       + WifePenSupBasicF&psn )     /* Wife Pension Supplement Basic Amount */
                       * ( AtiFlag&psn = 1 )        /* Include if non-taxable */
                       + WifePenSupRemF&psn         /* Wife Pension Supplement Remaining Amount */
                       + WifeRAssF&psn              /* Wife Pension Rent Assistance */
                       + WifePharmAllF&psn          /* Wife Pension Pharmaceutical Allowance */
                       + WifePenSupMinF&psn         /* Wife Pension Supplement Minimum Amount */
                       + WifePenEsF&psn             /* Wife Pension ES */
                       %END ;
                                                
                         /* Allowances */
                       + AustudyRAssF&psn           /* Austudy Rent Assisstance */
                       + AustudyPharmAllF&psn       /* Austudy Pharmaceutical Allowance */
                       + AustudyAllEsF&psn          /* Austudy ES */

                       + JspRAssF&psn               /* JobSeeker Payment Rent Assistance */
                       + JspPharmAllF&psn           /* JobSeeker Payment Pharmaceutical Allowance */
                       + JspAllEsF&psn              /* JobSeeker Payment ES */

                       + PppRAssF&psn               /* Parenting Payment Partnered Rent Assistance */
                       + PppPharmAllF&psn           /* Parenting Payment Partnered Pharmaceutical Allowance */
                       + PppAllEsF&psn              /* Parenting Payment Partnered ES */

                       %IF &psn IN( r ) %THEN %DO ;
                       + WidowRAssF&psn             /* Widow Allowance Assistance */
                       + WidowPharmAllF&psn         /* Widow Allowance Pharmaceutical Allowance */
                       + WidowAllEsF&psn            /* Widow Allowance ES */
                       %END ;
                       +
                       %END ;

                         YaOtherRAssF&psn           /* Youth Allowance (Other) Rent Assistance */
                       + YaOtherPharmAllF&psn       /* Youth Allowance (Other) Pharmaceutical Allowance */
                       + YaOtherAllEsF&psn          /* Youth Allowance (Other) ES */

                       + YaStudRAssF&psn            /* Youth Allowance Student Rent Assistance */
                       + YaStudPharmAllF&psn        /* Youth Allowance Student Pharmaceutical Allowance */
                       + YaStudAllEsF&psn           /* Youth Allowance Student ES */

                         /* DVA */
                       %IF &psn IN( r , s ) %THEN %DO ;
                       + ServicePenSupRemF&psn      /* DVA Service Pension Supplement Remaining Amount */
                       + ServiceRAssF&psn           /* DVA Service Pension Rent Assistance */
                       + ServicePenSupMinF&psn      /* DVA Service Pension Supplement Minimum Amount */
                       + ServicePenEsF&psn          /* DVA Service Pension ES */

                       + DvaDisPenNmF&psn            /* DVA Disability Pension on the SIH. The SIH amount is an
                                                       estimate of the basic amount, since the components are not
                                                       separable on the SIH. */ 

                       + DvaWwPenNmF&psn            /* DVA War Widow Pension on the SIH. The SIH amount is an
                                                       estimate of the basic amount, since the components are not
                                                       separable on the SIH. */ 

                         /* Family Payment */
                       + FtbaF&psn                  /* Family Tax Benefit Part A */
                       + FtbbF&psn                  /* Family Tax Benefit Part B */
           
                         /* Supplements */
                       + CareAllF&psn               /* Carer Allowance */
                       + CareSupF&psn               /* Carer Supplment */
                       + PenEdSupF&psn              /* Pensioner Education Supplement */
                       + SenSupF&psn                /* Senior Supplement */
                       + SenSupEsF&psn              /* Senior Supplement Energy Supplement */
                       + TelAllF&psn                /* Telephone Allowance */
                       + UtilitiesAllF&psn          /* Utilities Allowance */
                       + SifsF&psn                  /* Single Income Family Supplement */
                       %END ;

                         /*Childcare */
                            /*This section makes TranInc and DispInc inclusive of any childcare payments from either the current or proposed childcare schemes*/
                            /*Payments are assigned to the reference person only which is done for simplicity*/

                        %IF &RunCameo = Y %THEN %DO ;

                            %IF &psn IN( r ) %THEN %DO ; 

								%IF ( &Duration = A AND &Year < 2018 ) 
								OR ( &Duration = Q AND &Year < 2018 )
								OR ( &Duration = Q AND &Year = 2018 AND ( ( &Quarter = Mar ) OR ( &Quarter = Jun ) ) )
								%THEN %DO ; 
   
                                    + ( CcbAmtAu / 26 )         /* Childcare Benefit divided by 26 to express in fortnightly terms */
                                    + ( CcrAmtAu / 26 ) ;       /* Childcare Rebate divided by 26 to express in fortnightly terms */

                                %END ;

                                %ELSE %DO ;

                                + ( CcsAmtAu / 26 ) ;          /* Childcare Subsidy */

                                %END ;

                            %END ;

                            %ELSE %DO ;

                                ;

                            %END ;

                        %END ;

                        %ELSE %DO ;

                        ;

                        %END ;

    IncNonTaxTranA&psn = IncNonTaxTranF&psn * 26 ;

    * Transfer income ;
    IncTranF&psn = IncTaxTranF&psn                  /* Taxable transfer income - created in Module 3 */
                 + IncNonTaxTranF&psn ;             /* Non-taxable transfer income */

    IncTranA&psn = IncTranF&psn * 26 ;

%MEND TranInc ;

**********************************************************************************
*   Macro:   DispInc                                                             *
*   Purpose: Calculate disposable income.                                        *
*********************************************************************************;;

%MACRO DispInc( psn ) ;

    * Calculate disposable income ;
    IncDispA&psn = IncTranA&psn             /* Transfer income */
                 + IncPrivA&psn             /* Private income */
                 - PayOrRefAmntA&psn ;      /* Tax payable or refundable */

    IncDispF&psn = IncDispA&psn / 26 ;

%MEND DispInc ;

**********************************************************************************
*   Macro:   IncomeUnit                                                          *
*   Purpose: Calculate income unit total income                                  *
*********************************************************************************;;

%MACRO IncomeUnit( ) ;

    * Disposable income ;
    IncDispAu = IncDispAr + IncDispAs + IncDispA1 + IncDispA2 + IncDispA3 + IncDispA4 ;

    IncDispFu = IncDispAu / 26 ;

	* Disposable income less Childcare costs (for use in EMTRs that include the impact of net childcare costs);
	%IF &RunCameo = Y %THEN %DO ; 
		
		IncDispLessCcAu = IncDispAu - CcsCostAu ; 

		IncDispLessCcFu = IncDispLessCcAu / 26 ; 

    %END ; 

    * Transfer income ;
    IncTranFu = IncTranFr + IncTranFs + IncTranF1 + IncTranF2 + IncTranF3 + IncTranF4 ;   

    IncTranAu = IncTranFu * 26 ;

    * Private income ;
    IncPrivAu = IncPrivAr + IncPrivAs + IncPrivA1 + IncPrivA2 + IncPrivA3 + IncPrivA4 ;

    IncPrivFu = IncPrivAu / 26 ;

    * Adjusted taxable income ;
    AdjTaxIncAu = AdjTaxIncAr + AdjTaxIncAs + AdjTaxIncA1 + AdjTaxIncA2 + AdjTaxIncA3 + AdjTaxIncA4 ;

    AdjTaxIncFu = AdjTaxIncAu / 26 ;

    * Amount of tax payable or refundable ;
    PayOrRefAmntAu = PayOrRefAmntAr + PayOrRefAmntAs + PayOrRefAmntA1 + PayOrRefAmntA2 + PayOrRefAmntA3 + PayOrRefAmntA4 ;

    PayOrRefAmntFu = PayOrRefAmntAu / 26 ;

    * Allowance income ;
    AllTotFu = AllTotFr + AllTotFs + AllTotF1 + AllTotF2 + AllTotF3 + AllTotF4 ;

    AllTotAu = AllTotFu * 26 ;

    PppTotFu = PppTotFr + PppTotFs ;

    PppTotAu = PppTotFu * 26 ;

    JspTotFu = JspTotFr + JspTotFs ;

    JspTotAu = JspTotFu * 26 ;

    YaOtherTotFu = YaOtherTotFr + YaOtherTotFs ;

    YaOtherTotAu = YaOtherTotFu * 26 ;

    YaStudTotFu = YaStudTotFr + YaStudTotFs + YaStudTotF1 + YaStudTotF2 + YaStudTotF3 + YaStudTotF4 ;

    YaStudTotAu = YaStudTotFu * 26 ;

    AustudyTotFu = AustudyTotFr + AustudyTotFs ;

    AustudyTotAu = AustudyTotFu * 26 ;

    WidowTotFu = WidowTotFr ;  *Widow allowance is received by reference person only* ;

    WidowTotAu = WidowTotFu * 26 ;

    * Pension income ;
    PenTotFu = PenTotFr + PenTotFs + PenTotF1 + PenTotF2 + PenTotF3 + PenTotF4 ;

    PenTotAu = PenTotFu * 26 ;

    AgeTotFu = AgeTotFr + AgeTotFs ;

    AgeTotAu = AgeTotFu * 26 ;

    DspTotFu = DspTotFr + DspTotFs ;

    DspTotAu = DspTotFu * 26 ;

    CarerTotFu = CarerTotFr + CarerTotFs ;

    CarerTotAu = CarerTotFu * 26 ;

    WifeTotFu = WifeTotFs ;  *Wife pension is received by spouse only* ;

    WifeTotAu = WifeTotFu * 26 ;

    DspU21TotFu = DspU21TotFr + DspU21TotFs ;

    DspU21TotAu = DspU21TotFu * 26 ;

    PpsTotFu = PpsTotFr ;

    PpsTotAu = PpsTotFu * 26 ;

	* Additional variables required in PRISMOD.DIST ; /*EAH: remove summary variables used for PRISMOD.DIST*/
/*	pensionu = sum(DspPenBasicFr, AgePenBasicFr, CarerPenBasicFr, ServiceRAssFr,DvaDisPenNmFr, ServicePenBasicFr, DvaWwPenNmFr,*/
/*				   DspPenBasicFs, AgePenBasicFs, CarerPenBasicFs, ServiceRAssFs,DvaDisPenNmFs, ServicePenBasicFs, DvaWwPenNmFs,*/
/*				   DspPenEsFr, DspPenEsFs, AgePenEsFr,  AgePenEsFs,  CarerPenEsFr,  CarerPenEsFs,ServicePenEsFr,ServicePenEsFs,*/
/*				   DspPharmAllFr, DspRAssFr, AgePharmAllFr, AgeRAssFr,CarerPharmAllFr, CarerRAssFr,*/
/* 				   DspPharmAllFs, DspRAssFs, AgePharmAllFs, AgeRAssFs,CarerPharmAllFs, CarerRAssFs,*/
/*				   SifsFr, SifsFs) / 2 ; */
/*	solepenu = sum(PpsPenBasicFr, SifsFr, PpsPharmAllFr, PpsRAssFr, PpsPenEsFr) / 2 ;  */
/* 	dssallwu = sum(IncTranFu/2, -pensionu, -solepenu) ;*/
/**/
/*    if FtbaTestInc = 0 then FtbaTestInc = sum(AdjTaxIncAr, AdjTaxIncAs);*/
/**/
/*    if IncSuperSWs = . then IncSuperSWs = 0;*/
/*    if IncTaxSuperImpAs = . then IncTaxSuperImpAs = 0;*/
/**/
/*    adjtaxip_with_tfsuper = sum(AdjTaxIncAr, AdjTaxIncAs, (IncSuperSWr * 52 - IncTaxSuperImpAr), (IncSuperSWs * 52 - IncTaxSuperImpAs));*/

    * DVA income ;

    DvaTotFu = DvaTotFr + DvaTotFs ;
    DvaTotAu = DvaTotFu * 26 ;

    ServiceTotFu =  ServiceTotFr + ServiceTotFs ;

    ServiceTotAu = ServiceTotFu * 26 ;

    * Supplements income ;
    SupTotFu = SupTotFr + SupTotFs ;

    SupTotAu = SupTotFu * 26 ;

    * Assessable income ;
    AssessableIncAu = AssessableIncAr + AssessableIncAs + AssessableIncA1 + AssessableIncA2 + AssessableIncA3 + AssessableIncA4 ;

    AssessableIncFu = AssessableIncAu / 26 ;

    * Taxable income ;
    TaxIncAu = TaxIncAr + TaxIncAs + TaxIncA1 + TaxIncA2 + TaxIncA3 + TaxIncA4 ;

    TaxIncFu = TaxIncAu / 26 ;

    * Deductions ;
    DeductionAu = DeductionAr ;
    IF ActualAges > 0 THEN DeductionAu = DeductionAu + DeductionAs ;
    IF ActualAge1 > 0 THEN DeductionAu = DeductionAu + DeductionA1 ;
    IF ActualAge2 > 0 THEN DeductionAu = DeductionAu + DeductionA2 ;
    IF ActualAge3 > 0 THEN DeductionAu = DeductionAu + DeductionA3 ; 
    IF ActualAge4 > 0 THEN DeductionAu = DeductionAu + DeductionA4 ;

    DeductionFu = DeductionAu / 26 ;

    * Amount of gross income tax payable ;
    GrossIncTaxAu = GrossIncTaxAr + GrossIncTaxAs + GrossIncTaxA1 + GrossIncTaxA2 + GrossIncTaxA3 + GrossIncTaxA4 ;

    GrossIncTaxFu = GrossIncTaxAu / 26 ;

    * Amount of used SAPTO ;
    UsedSaptoAu = UsedSaptoAr + UsedSaptoAs ;

    UsedSaptoFu = UsedSaptoAu / 26 ;

    * Amount of used BENTO ;
    UsedBentoAu = UsedBentoAr + UsedBentoAs + UsedBentoA1 + UsedBentoA2 + UsedBentoA3 + UsedBentoA4 ;

    UsedBentoFu = UsedBentoAu / 26 ;

    * Amount of used LITO ;
    UsedLitoAu = UsedLitoAr + UsedLitoAs + UsedLitoA1 + UsedLitoA2 + UsedLitoA3 + UsedLitoA4 ;

    UsedLitoFu = UsedLitoAu / 26 ;

	* Amount of used LAMITO ;
    UsedLamitoAu = UsedLamitoAr + UsedLamitoAs + UsedLamitoA1 + UsedLamitoA2 + UsedLamitoA3 + UsedLamitoA4 ;

    UsedLamitoFu = UsedLamitoAu / 26 ;

    * Amount of used Item 20 tax offsets ;
    UsedItem20Au = UsedItem20Ar + UsedItem20As ;

    UsedItem20Fu = UsedItem20Au / 26 ;

    * Amount of refundable tax offset ;
    XRefTaxOffsetAu = XRefTaxOffsetAr + XRefTaxOffsetAs + XRefTaxOffsetA1 + XRefTaxOffsetA2 + XRefTaxOffsetA3 + XRefTaxOffsetA4 ;

    XRefTaxOffsetFu = XRefTaxOffsetAu / 26 ;

    * Total tax offset entitlement ;
    TotTaxOffsetAu = TotTaxOffsetAr + TotTaxOffsetAs + TotTaxOffsetA1 + TotTaxOffsetA2 + TotTaxOffsetA3 + TotTaxOffsetA4 ;

    TotTaxOffsetFu = TotTaxOffsetAu / 26 ; 

    * Total tax offset used ;
    UsedTotTaxOffsetAu = UsedTotTaxOffsetAr + UsedTotTaxOffsetAs + UsedTotTaxOffsetA1 + UsedTotTaxOffsetA2 + UsedTotTaxOffsetA3 + UsedTotTaxOffsetA4 ;

    UsedTotTaxOffsetFu = UsedTotTaxOffsetAu / 26 ;

    * Medicare levy ;
    MedLevAu = MedLevAr + MedLevAs + MedLevA1 + MedLevA2 + MedLevA3 + MedLevA4 ;

    MedLevFu = MedLevAu / 26 ; 

    * Medicare levy surcharge ;
    MedLevSurAu = MedLevSurAr + MedLevSurAs + MedLevSurA1 + MedLevSurA2 + MedLevSurA3 + MedLevSurA4 ;

    MedLevSurFu = MedLevSurAu / 26 ;


%MEND IncomeUnit ;

* Call %FinalisationMaster ;
%RunFinalisation

