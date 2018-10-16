
**************************************************************************************
* Program:      1 Initialisation.sas                                                 *
* Description:  Initialises the variables which will be constructed in the policy    *
*               modules.                                                             *
**************************************************************************************;


**************************************************************************************
*   Macro:   RunInitialisation                                                       *
*   Purpose: Coordinate  calculation                                              * 
*************************************************************************************;;
%MACRO RunInitialisation ;

    ************************************************************************************
    *      1.        Create list of policy variables to be initialised                 *
    ************************************************************************************;

    * List of suffixes ;

    %LET SuffixListAll = r - s - 1 - 2 - 3 - 4 ;

    %LET SuffixListCouple = r - s ;

    %LET SuffixListRef = r ;

    %LET SuffixListSps = s ;

    %LET SuffixListKids  = 1 - 2 - 3 - 4 ;

    * Numeric variables that exist for persons [r,s,1-4] ;

    %LET VarNumListAll  =  AdjTaxIncA -
                           AdjTaxIncF -
                           AllBasicF -
                           AllBasicMaxF -
                           AllEsF -
                           AllEsMaxF -
                           AllPartTpr -
                           AllRedF -
                           AllRedPerIncF -
                           AllThr1F -
                           AllThr2F -
                           AllTotA -
                           AllTotF -
                           AllTpr1 -
                           AllTpr2 -
                           AssessableIncA -
                           AssessableIncF -
                           AtiFlag -
                           BentoA -
                           BentoFlag -
                           BentoF -
                           CumGrossIncTaxA -
                           TempBudgRepLevA -
                           TempBudgRepLevF -
                           GrossIncTaxA -
                           GrossIncTaxF -
						   IncAllTestF -
                           IncDispA -
                           IncDispF -
                           IncMLSA -
                           IncMLSF -
                           IncNonTaxPrivA -
                           IncNonTaxTranA -
                           IncNonTaxTranF -
                           IncOrdA -
                           IncOrdF -
                           IncOrdDvaF -
                           IncPrivA -
                           IncPrivF -
                           IncPrivLessWBF -
						   IncSuperSW -
                           IncTaxPrivA -
                           IncTaxTranA -
                           IncTaxTranF -
                           IncTranA -
                           IncTranF -
                           IncWBF -
                           LevyAndChargeA -
                           LevyAndChargeF -
						   LamitoBase -
						   LamitoMax - 
					       LamitoThr1 - 
						   LamitoThr2 -
						   LamitoTpr1 -
						   LamitoTpr2 -
                           LamitoA -
                           LamitoFlag -
                           LamitoF -
						   LITOMax - 
						   LITOThr1 - 
						   LITOThr2 - 
						   LITOTpr1 - 
						   LITOTpr2 - 
                           LitoA -
                           LitoFlag -
                           LitoF -
						   MedLevA -
                           MedLevSurA -
                           MedLevSurRatePsn -
                           MedLevSurTier1Psn -
                           MedLevSurTier2Psn -
                           MedLevSurTier3Psn -
                           MedLevSurF -
                           MedLevThr1Psn -
                           MedLevThr2Psn -
                           MedLevF -
                           MTR -
                           NetIncTaxA -
                           NetIncTaxF -
                           PayOrRefAmntA -
                           PayOrRefAmntF -
                           PenTotA -
                           PenTotF -
                           PharmAllF -
                           PharmAllMaxF -
                           RAssA -
                           RAssF -
                           RAssMaxPossF -
                           RebBftA -
                           RebBftF -
                           TaxIncA -
                           TaxIncF -
                           TotTaxOffsetA -
                           TotTaxOffsetF -
                           UsedBentoA -
                           UsedBentoF -
                           UsedFrankCrA -
                           UsedFrankCrF -
                           UsedLitoA -
                           UsedLitoF -
						   UsedLamitoA -
						   UsedLamitoF -
                           UsedTotTaxOffsetA -
                           UsedTotTaxOffsetF -
                           XRefTaxOffsetA -
                           XRefTaxOffsetF -
                           YaOtherAllBasicA -
                           YaOtherAllBasicF -
                           YaOtherAllEsA -
                           YaOtherAllEsF -
                           YaOtherPharmAllA -
                           YaOtherPharmAllF -
                           YaOtherRAssA -
                           YaOtherRAssF -
                           YaOtherTotA -
                           YaOtherTotF -
                           YaStudAllBasicA -
                           YaStudAllBasicF -
                           YaStudRAssA -
                           YaStudRAssF -
                           YaStudPharmAllA - 
                           YaStudPharmAllF - 
                           YaStudAllEsA - 
                           YaStudAllEsF - 
                           YaStudTotF -
                           YaStudTotA -
                           YaTotA -
                           YaTotF -
						       ;

    * Numeric variables that only exist for persons [r,s] ;      
    %LET VarNumListCouple = AbstudyNmA -
                            AbstudyNmF -
                            AgePenBasicA -
                            AgePenBasicF -
                            AgePenEsA -
                            AgePenEsF -
                            AgePenSupBasicA -
                            AgePenSupBasicF -
                            AgePenSupMinA -
                            AgePenSupMinF -
                            AgePenSupRemA -
                            AgePenSupRemF -
                            AgePharmAllA -
                            AgePharmAllF -
                            AgeRAssA -
                            AgeRAssF -
                            AgeTotF -
                            AgeTotA -
                            AllPartThrF -
                            AllRedPartIncF -
                            AustudyAllBasicA -
                            AustudyAllBasicF -
                            AustudyAllEsA -
                            AustudyAllEsF -
                            AustudyPharmAllA -
                            AustudyPharmAllF -
                            AustudyRAssA -
                            AustudyRAssF -
                            AustudyTotA -
                            AustudyTotF -
                            BabyBonusA -
                            BabyBonusF -
                            CareAllA -
                            CareAllF -
                            CareAllflag -
							CareAllIncThrA - 
							CarerPenBasicA -
                            CarerPenBasicF -
                            CarerPenEsA -
                            CarerPenEsF -
                            CarerPenSupBasicA -
                            CarerPenSupBasicF -
                            CarerPenSupMinA -
                            CarerPenSupMinF -
                            CarerPenSupRemA -
                            CarerPenSupRemF -
                            CarerPenTaxFlag -
                            CarerPharmAllF -
                            CarerRAssA -
                            CarerRAssF -
                            CarerTotF -
                            CarerTotA -
                            CareSupA -
                            CareSupF -
                            CshcFlag -
                            DedChildMaintA -
                            DictoA -
                            DictoFlag -
                            DictoF -
                            DspPenBasicA -
                            DspPenBasicF -
                            DspPenEsA -
                            DspPenEsF -
                            DspPenSupBasicA -
                            DspPenSupBasicF -
                            DspPenSupMinA -
                            DspPenSupMinF -
                            DspPenSupRemA -
                            DspPenSupRemF -
                            DspPharmAllF -
                            DspRAssA -
                            DspRAssF -
                            DspTotF -
                            DspTotA -
                            DSPU21PenBasicA -
                            DSPU21PenBasicF -
                            DspU21PenEsA -
                            DspU21PenEsF -
                            DspU21PenSupBasicA -
                            DspU21PenSupBasicF -
                            DspU21PenSupMinF -
                            DspU21PenSupRemF -
                            DspU21PharmAllA -
                            DspU21PharmAllF -
                            DspU21RAssA -
                            DspU21RAssF -
                            DspU21TotA -
                            DspU21TotF -
                            DstoA -
                            DstoFlag -
                            DstoF -
                            DvaDisPenNmA -
                            DvaDisPenNmF -
                            DvaWwPenNmA -
                            DvaWwPenNmF -
                            DvaTotA -
                            DvaTotF -
                            FtbaA -
                            FtbaF -
                            FtbbA -
                            FtbbF -
							HelpPayA - 
							IncSupBonA -
                            IncSupBonF -
                            IncSupBonFlag -
                            MawtoA -
                            MawtoFlag -
                            MawtoF -
                            MedLevFamThr -
                            MedLevRedA -
                            NetIncWorkA -
                            NetIncWorkF -
                            NsaAllBasicA -
                            NsaAllBasicF -
                            NsaAllEsA -
                            NsaAllEsF -
                            NsaPharmAllA -
                            NsaPharmAllF -
                            NsaRAssA -
                            NsaRAssF -
                            NsaTotA -
                            NsaTotF -
                            NumCareSup -
                            PartnerAllNmA -
                            PartnerAllNmF -
                            PenBasicF -
                            PenEsF -
                            PenEdSupA -
                            PenEdSupF -
                            PenEdSupFlag -
							PenEsMaxFr -
							PensEsMaxFs -
                            PenSupBasicF -
                            PenSupMinF -
                            PenSupRemF -
                            PpGrandfatherFlag -
                            PppAllBasicA -
                            PppAllBasicF -
                            PppAllEsA -
                            PppAllEsF -
                            PppPharmAllA -
                            PppPharmAllF -
                            PppRAssA -
                            PppRAssF -
                            PppTotA -
                            PppTotF -
                            RebIncA -
                            RebIncF -
                            SaptoA -
                            SaptoCutOutPsn -
                            SaptoMaxPsn -
                            SaptoRebThrPsn -
                            SaptoF -
                            SenSupA -
                            SenSupQ -
                            SenSupF -
                            SenSupFlag -
                            SenSupEsF -
                            SenSupEsA -
                            SenSupTotF -
                            SenSupTotA -
                            ServicePenBasicA -
                            ServicePenBasicF -
                            ServicePenEsA -
                            ServicePenEsF -
                            ServicePenSupBasicA -
                            ServicePenSupBasicF -
                            ServicePenSupMinA -
                            ServicePenSupMinF -
                            ServicePenSupRemA -
                            ServicePenSupRemF -
                            ServiceRAssA -
                            ServiceRAssF -
                            ServiceTotA -
                            ServiceTotF -
                            SickAllNmA -
                            SickAllNmF -
                            SifsA -
                            SifsF -
                            SifsPrimFlag -
                            SKBonusA -
                            SKBonusF -
                            SpbAllNmA -
                            SpbAllNmF -
                            SuperToA -
                            SupTotA -
                            SupTotF -
                            TakeXSaptoA -
                            TaxIncPA -
                            TelAllA -
                            TelAllF -
                            TelAllFlag -
                            TelAllHighFlag -
                            TelAllLowFlag -
                            UsedItem20A -
                            UsedItem20F -
                            UsedSaptoA -
                            UsedSaptoF -
                            UtilitiesAllA -
                            UtilitiesAllF -
                            UtilitiesAllFlag -
                            XMedLevRedA -
                            ;


    * Numeric variables that only exist for persons [r] ;   
    %LET VarNumListRef  =   AllNotionAmtA -
						    AllRedPareIncA -
							AllRedPareIncF -
							DepsMaintFlag -
						    DepsYaMaintFlag -
						    PpsPenBasicA -
                            PpsPenBasicF -
                            PpsPenEsA -
                            PpsPenEsF -
                            PpsPenSupBasicA -
                            PpsPenSupBasicF -
                            PpsPenSupMinF -
                            PpsPenSupRemF -
                            PpsPharmAllA -
                            PpsPharmAllF -
                            PpsRAssA -
                            PpsRAssF -
                            PpsTotA -
                            PpsTotF -
                            WidowAllBasicA -
                            WidowAllBasicF -
                            WidowAllEsA -
                            WidowAllEsF -
                            WidowPharmAllA -
                            WidowPharmAllF -
                            WidowRAssA -
                            WidowRAssF -
                            WidowTotF -
                            WidowTotA -
   						    YaMaintIncThrA -	

/*Jul 2015 Budget 2015 YA maintenance income test*/
   							AllMaintIncTestResA -
						    AllMaintIncTestResF -
						    AllPareIncTestResA -
						    AllPareIncTestResF -
                            IncMaintA -
                            ;

    * Numeric variables that only exist for persons [s] ;   
    %LET VarNumListSpouse = WifePenBasicA -
                            WifePenSupBasicA -
                            WifePenBasicF -
                            WifePenEsA -
                            WifePenEsF -
                            WifePenSupBasicF -
                            WifePenSupMinA -
                            WifePenSupMinF -
                            WifePenSupRemA -
                            WifePenSupRemF -
                            WifePharmAllF -
                            WifeRAssA -
                            WifeRAssF -
                            WifeTotA -
                            WifeTotF -
   				                ;

    * Numeric variables that only exist for persons [1-4] ;   
    %LET VarNumListKids   = AllNotionAmtA -
					    	AllRedPareIncA -
							AllRedPareIncF -
							DepsMLSFlag - 
                            DepsSec5Flag - 
                            DepsSSPlusFlag - 
                            DepsMLFlag -
					
							/* Youth allowance and FTB-A maintenance income test */
							DepsYaMaintFlag -
							DepsMaintFlag -
  							AllMaintIncTestResA -
						    AllMaintIncTestResF -
						    AllPareIncTestResA -
						    AllPareIncTestResF -
                            IncMaintA -
							YaMaintIncThrA -	

                            /* For childcare module */
                            /* Current childcare policy */
                            CcbSchPct -
                            CcbEligHrW -
                            CcbStdRate -
                            CcbLdcPct -
                            CcbAmtW -
                            CcbCostW -
                            CcbOutPocketW -
                            CcrAmtA -
                            CcrOutPocketA -

                            /*Proposed childcare policy */
                            CcsEligHrW -
                            CcsHrFeeCap - 
                            CcsAmtW -
                            CcsAmtA -  
                            CcsCostW - 
                            CcsCostA - 
                            CcsOutPocketW -
                            CcsOutPocketA -
                            ;

    * Numeric variables without a person suffix ; 
    %LET VarNumListNoSuffix =   AdjTaxIncAu -
                                AdjTaxIncFu -
                                AgeTotAu -
                                AgeTotFu -
                                AllPareTestIncA -
                                AllTotAu -
                                AllTotFu -
                                AssessableIncAu -
                                AssessableIncFu -
								AssessDeemedVal -
								AssetsExcess -
								AssetsPenTest -
                                AuStudyTotAu - 
                                AuStudyTotFu - 
                                BabyBonusA -
                                CarerTotAu -
                                CarerTotFu -
                                DeductionAu -
                                DeductionFu -
								DeemedCalcA -
								DeemedCalcF -
								DeemedIncA -
								DeemedThr -
                                Deps13_15u -
                                DepsFtbA -
								DepsFtbB -
                                DepsFtbaOwnIU -
                                DepsFtbbOwnIU -
                                DepsFtbPr -
                                DepsFtbSec -
								DepsFtbSec16 -
                                DepsFtbSec16_18 -
                                DepsFtbSec19 -
                                DepsML -
                                DepsMLOwnIU1 -
                                DepsMLOwnIU2 -
                                DepsMLS -
                                DepsMLSOwnIU -
                                DepsPrinCare -
                                DepsSec5 -
                                DepsSec5OwnIU -
                                DepsSifs -
                                DepsSSPlusOwnIU -
                                DepsSSTotal -
                                DepsUnder13 -
                                DepsUnder15 -
                                DepsUnder5 -
								DepsFtbaMaint -
                                DspTotAu -
                                DspTotFu -
                                DspU21TotAu -
                                DspU21TotFu -
                                DvaTotAU -
                                DvaTotFU -
                                FtbaBaseEsA -
                                FtbaBaseNet -
                                FtbaBaseRed -
                                FtbaBaseStdA -
                                FtbaBaseThr -
                                FtbaBaseTotal -
                                FtbaEs_NoNbs -
                                FtbaEs_Nbs -
                                FtbaEsA -
                                FtbaESup_NoNbs -
                                FtbaESup_Nbs -
                                FtbaEndSupA -
                                FtbaFinalA -
                                FtbaFlag -
								FtbaIncMaintAu -
                                FtbaLfs_Nbs -
                                FtbaLfs_NoNbs -
                                FtbaLfsA -
                                FtbaMaxEsA -
                                FtbaMaxIncRed -
                                FtbaMaxNet -
                                FtbaMaxRed -
                                FtbaMaxStdA -
                                FtbaMaxTotal -
                                FtbaMix -
                                FtbaNbs_Nbs -
                                FtbaNbs_NoNbs -
                                FtbaNewBornSupA -
                                FtbaRAss_Nbs -
                                FtbaRAss_NoNbs -
                                FtbaRAssA -
                                FtbaStd_Nbs -
                                FtbaStd_NoNbs -
                                FtbaStdA -
                                FtbaTestExFlag -
                                FtbaTestInc -
                                FtbbEsA -
                                FtbbEndSupA -
                                FtbbFinalA -
                                FtbbFlag -
                                FtbbMax -
                                FtbbPrExFlag -
                                FtbbRed -
                                FtbbStdA -
                                FtbbTestPrInc -
                                FtbbTestSecInc -
                                FtbTotAu -
                                GrossIncTaxAu -
                                GrossIncTaxFu -
								IncDeemDvaTestF -
								IncDeemPenTestF -
                                IncDispAu -
								IncFinInvA -
					            IncPenTestF -
                                IncDvaTestF -
                                IncPrivAu -
                                IncPrivFu -
                                IncTranAu -
                                IncTranFu -
                                LargeFamSupA -
                                IncMaintAu -
								FtbaIncMaintAu -
  							    FtbaMaintIncFree -
                                FtbaMaintIncRed -
                                FtbaMaintIncThr -
                                MaxFamYaF -
						        MedLevAu -
                                MedLevFu -
                                MedLevIncAU -
                                MedLevSurAu -
                                MedLevSurFu -
                                IncMLSAu -
                                NbsAnnualised -
                                NbsFactor -
                                NewBornSupA -
                                NewBornUpfrontA -
                                NsaTotAu - 
                                NsaTotFu - 
                                NumRates -
                                PayOrRefAmntAu -
                                PayOrRefAmntFu -
                                PenBasicMaxF -
                                PenRedF -
								PenRedAssetTest -
								PenRedIncTest -
                                PenSupBasicMaxF -
                                PenSupMinMaxF -
                                PenSupRemMaxF -
								PenAssThr - 
                                PenThrF -
                                PenTotAu -
                                PenTotFu -
                                PenTpr -
                                PharmAllMaxF -
                                PppTotAu -
                                PppTotFu -
                                PPSTotAu -
                                PPSTotFu -
                                PropFtbaEs  -
                                PropFtbaESup -
                                PropFtbaLfs -
                                PropFtbaNbs -
                                PropFtbaRAss -
                                PropFtbaStd -
                                RAssMaxFu -
                                RAssMaxPossF -
                                RAssMaxPossFr_ -
                                RAssMinRentFu -
                                RebIncAU -
                                ServiceTotAu -
                                ServiceTotFu -
                                SifsA -
                                SifsFlag -
                                SingPrinCareFlag -
                                SKBonusA -
                                SupTotAu -
                                SupTotFu -
                                TaxIncAu -
                                TaxIncFu -
                                TempBudgRepLevAu -
                                TempBudgRepLevFu -
                                TotTaxOffsetAu -
                                TotTaxOffsetFu -
                                UsedBentoAu -
                                UsedBentoFu -                                
                                UsedItem20Au -
                                UsedItem20Fu -
                                UsedLamitoAu -
                                UsedLamitoFu -
                                UsedLitoAu -
                                UsedLitoFu -
                                UsedSaptoAu -
                                UsedSaptoFu -
                                UsedTotTaxOffsetAu -
                                UsedTotTaxOffsetFu -
                                WidowTotAu - 
                                WidowTotFu -
                                WifeTotAu -
                                WifeTotFu -
                                XRefTaxOffsetAu -
                                XRefTaxOffsetFu -
                                YAOtherTotAu -
                                YAOtherTotFu -
                                YAStudTotAu - 
                                YAStudTotFu -

                                /*16 Jun 2015, Budget 2015-16, maintenance income test (unenacted) */

								DepsMaint -
								DepsMaintFlagr_ -
								DepsMaintOwnIU -
								DepsYaMaint -
								DepsYaMaintOwnIU -
								DepsYaMaintFlagr_ -
								IncMaintPerDep -
						
								/*  15 Jan 2015, Budget 2014, #15.2 */
                                /* Single Parent Supplement */

                                /* For childcare module */
                                /* Current childcare policy */
                                CcbMaxHrW -
                                CcTestInc -
                                CcbNumKidOtr -
                                CcbNumKidOcc -
                                CcbNumKidInf -
                                CcbMaxBenW1 -
                                CcbMaxBenW3 -
                                CcbMaxBenW5 -
                                CcbMaxBenWSpcTapAmt -
                                CcbAddMaxBenW -
                                CcbAddLd -
                                CcbMaxBenWOtr -
                                CcbMaxBenWOcc -
                                CcbMultChdPctOtr -
                                CcbMultChdPctOcc -
                                CcbIncExcWOtr -
                                CcbIncExcWOcc -
                                CcbTapPctOtr -
                                CcbTapPctOcc -
                                CcbTaxIncPctOtr -
                                CcbTaxIncPctOcc -
                                CcbPctOtr -
                                CcbPctOcc -
                                CcbAmtAu -
                                CcbCostAu -
                                CcbOutPocketAu -
                                CcrAmtAu -
                                CcrOutPocketAu -

                                /* Proposed childcare policy */

                                CcsEffTpr -
                                CcsMaxHrW - 
                                CcTestInc - 
                                CcsRateA - 
                                CcsAmtAu -
                                CcsCostAu - 
                                CcsOutPocketAu - 
                                ;

    *Character variables that exist for persons [r,s,1-4] ;
    %LET VarCharListAll  =  AllowSubType - 
							AllowRateType -
                            AllowType - 
                            MedLevSurType - 
                            MedLevType - 
                            PenType -
                            ;

    *Character variables that exist for persons [r,s] ;
    %LET VarCharListCoup  = DvaType - 
                            MedLevFamType - 
							PenRateType -
                            SaptoType -
                            ;

    *Character variables without a person suffix ; 
    %LET VarCharListNoSuffix  = AllowSubTyper_ - 
								AllowRateTyper_ -
                                AllowTyper_ - 
                                FtbaType - 
                                FtbaType_Nbs -
                                FtbaType_NoNbs -
								FtbbType -
								PenTestFlag -
                                PenTyper_ - 
                                RenterType -

                                /* For childcare module */
                                /* Current childcare policy */
                                CcbInfElig -
                                CcrElig -

                                /* Proposed childcare policy */

                                ;

    ************************************************************************************
    *      2.        Initialise numeric variables.                                     *
    ************************************************************************************;

    * Call macros to initialise numeric variables to zero ;
    %InitNumVar( &VarNumListAll , &SuffixListAll )
    %InitNumVar( &VarNumListCouple , &SuffixListCouple )
    %InitNumVar( &VarNumListRef , &SuffixListRef )
    %InitNumVar( &VarNumListSpouse , &SuffixListSps )
    %InitNumVar( &VarNumListKids , &SuffixListKids )
    %InitialiseNum( &VarNumListNoSuffix )

    ************************************************************************************
    *      3.        Initialise character variables.                                   *
    ************************************************************************************;

    * Call macros to initialise character variables ;
    %InitCharVar( &VarCharListAll , &SuffixListAll )
    %InitCharVar( &VarCharListCoup , &SuffixListCouple )
    %InitialiseChar( &VarCharListNoSuffix )

	************************************************************************************
    *      4.        Label variables.                                                  *
    ************************************************************************************;

    * Call macros to label variables ;
	%LabelVariables

%MEND RunInitialisation ;

************************************************************************************
* Macro:   InitNumVar                                                              *
* Purpose: Initialise numeric variables                                            *
************************************************************************************;;

%MACRO InitNumVar( VarList , SuffixList ) ;

    %LET NumVar = %SYSFUNC( COUNTW( &VarList ) ) ;               *count variables ;

    %LET NumSuff = %SYSFUNC( COUNTW( &SuffixList ) ) ;           *count suffixes ;

    %DO i = 1 %TO &NumVar ;                                 *loop through variables ;

        * Get variable that needs to be initialised to zero ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;        *loop through suffixes ;

            %DO j = 1 %TO &NumSuff ;

                * Get suffix of variable ;
                %LET Suffix = %SCAN( &SuffixList , &j , - ) ;

                * Set variable to zero ;
                &Variable.&Suffix = 0 ;

            %END ;

    %END ;

%MEND InitNumVar ;

************************************************************************************
* Macro:   InitCharVar                                                             *
* Purpose: Initialise character variables                                          *
************************************************************************************;;

%MACRO InitCharVar( VarList , SuffixList ) ;

    %LET NumVar = %SYSFUNC( COUNTW( &VarList ) ) ;

    %LET NumSuff = %SYSFUNC( COUNTW( &SuffixList ) ) ;

    %DO i = 1 %TO &NumVar ;

        * Get variable that needs to be initialised ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

        %DO j = 1 %TO &NumSuff ;

            * Get suffix of variable ;
            %LET Suffix = %SCAN( &SuffixList , &j , - ) ;

            * Set variable at a length of 15 characters. This creates a blank 
               variable with 15 character spaces ;
            LENGTH &Variable&Suffix $15 ;

            &Variable&Suffix = "" ;

        %END ;

    %END ;

%MEND InitCharVar ;

************************************************************************************
* Macro:   InitialiseNum                                                           *
* Purpose: Initialise numeric variables without suffix                             *
************************************************************************************;;
%MACRO InitialiseNum( VarList ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &VarList ) ) ;

    %DO i = 1%TO &NumVars ;

        * Get variable that needs to be initialised to zero ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

        * Set variable to zero ;
        &Variable = 0 ;

    %END ;

%MEND InitialiseNum ;

************************************************************************************
* Macro:   InitialiseChar                                                          *
* Purpose: Initialise character variables without suffix                           *
************************************************************************************;;
%MACRO InitialiseChar( VarList ) ;

    %LET NumVars = %SYSFUNC( COUNTW( &VarList ) ) ;

    %DO i = 1 %TO &NumVars ;

        * Get variable that needs to be initialised ;
        %LET Variable = %SCAN( &VarList , &i , - ) ;

        * Set variable at a length of 15 characters. This creates a blank variable 
          with 15 character spaces ;
        LENGTH &Variable $15 ;

        &Variable = "" ;

    %END ;

%MEND InitialiseChar ;

************************************************************************************
* Macro:   LabelVariables                                                          *
* Purpose: Initialise character variables without suffix                           *
************************************************************************************;;
%MACRO LabelVariables ;

	LABEL
    %IF &RunCameo = Y %THEN %DO ;
		/* Variables that are only used for Cameos */
		
		LfStatr = "Labour force status ref"
		LfStats = "Labour force status sps"
		StudyTyper = "Study status ref"
		StudyTypes = "Study status sps"
		StudyType1 = "Study status dep 1"
		StudyType2 = "Study status dep 2"
		StudyType3 = "Study status dep 3"
		StudyType4 = "Study status dep 4"
		CCSType1 = "Type of CCS child care dep 1"
		CCSType2 = "Type of CCS child care dep 2"
		CCSType3 = "Type of CCS child care dep 3"
		CCSType4 = "Type of CCS child care dep 4"
		ActivHrWr = "Child care activity test hours ref"
		ActivHrWs = "Child care activity test hours sps"
		CCHrCost1 = "Actual hourly child care cost per child dep 1"
		CCHrCost2 = "Actual hourly child care cost per child dep 2"
		CCHrCost3 = "Actual hourly child care cost per child dep 3"
		CCHrCost4 = "Actual hourly child care cost per child dep 4"
		CCHrW1 = "Hours in child care per child dep 1"
		CCHrW2 = "Hours in child care per child dep 2"
		CCHrW3 = "Hours in child care per child dep 3"
		CCHrW4 = "Hours in child care per child dep 4"
		CCWPerYr1 = "Weeks in child care per child dep 1"
		CCWPerYr2 = "Weeks in child care per child dep 2"
		CCWPerYr3 = "Weeks in child care per child dep 3"
		CCWPerYr4 = "Weeks in child care per child dep 4" 
    %END ;

    %IF &RunCameo NE Y %THEN %DO ;

		/* Variables that are not initialised for Cameos */
		Adults15to64Su = "Number of persons 15-64 in IU (SIH)"
		Adults65to99Su = "Number of persons 65+ in IU (SIH)"
		AgeSr = "Age in categories ref"
		AgeSs = "Age in categories sps"
		AgeS1 = "Age in categories dep 1"
		AgeS2 = "Age in categories dep 2"
		AgeS3 = "Age in categories dep 3"
		AgeS4 = "Age in categories dep 4"
		CCBFlagSu = "CCB Flag (SIH)"
		CCBSWu = "Child care benefit on the SIH (weekly)"
		CCRFlagSu = "CCR Flag (SIH)"
		CCRSWu = "Child care rebate on the SIH (weekly)"
		FundTyper = "Super Fund Type ref"
		FundTypes = "Super Fund Type sps"
		FundType1 = "Super Fund Type dep 1"
		FundType2 = "Super Fund Type dep 2"
		FundType3 = "Super Fund Type dep 3"
		FundType4 = "Super Fund Type dep 4"
		HHID = "Household identifier"
		IncAccSAr = "Income from accident comp (annually) ref"
		IncAccSAs = "Income from accident comp (annually) sps"
		IncAccSA1 = "Income from accident comp (annually) dep 1"
		IncAccSA2 = "Income from accident comp (annually) dep 2"
		IncAccSA3 = "Income from accident comp (annually) dep 3"
		IncAccSA4 = "Income from accident comp (annually) dep 4"
		IncAccSPAr = "Income from accident comp (previous year) ref"
		IncAccSPAs = "Income from accident comp (previous year) sps"
		IncAccSPA1 = "Income from accident comp (previous year) dep 1"
		IncAccSPA2 = "Income from accident comp (previous year) dep 2"
		IncAccSPA3 = "Income from accident comp (previous year) dep 3"
		IncAccSPA4 = "Income from accident comp (previous year) dep 4"
		IncAccSWr = "Income from accident comp (weekly) ref"
		IncAccSWs = "Income from accident comp (weekly) sps"
		IncAccSW1 = "Income from accident comp (weekly) dep 1"
		IncAccSW2 = "Income from accident comp (weekly) dep 2"
		IncAccSW3 = "Income from accident comp (weekly) dep 3"
		IncAccSW4 = "Income from accident comp (weekly) dep 4"
		IncDivSWr = "Income from dividends (weekly) ref"
		IncDivSWs = "Income from dividends (weekly) sps"
		IncDivSW1 = "Income from dividends (weekly) dep 1"
		IncDivSW2 = "Income from dividends (weekly) dep 2"
		IncDivSW3 = "Income from dividends (weekly) dep 3"
		IncDivSW4 = "Income from dividends (weekly) dep 4"
		IncIntWr = "Total interest income (weekly) ref"
		IncIntWs = "Total interest income (weekly) sps"
		IncIntW1 = "Total interest income (weekly) dep 1"
		IncIntW2 = "Total interest income (weekly) dep 2"
		IncIntW3 = "Total interest income (weekly) dep 3"
		IncIntW4 = "Total interest income (weekly) dep 4"
		IncNetRentWr = "Income from total property rent (weekly) ref"
		IncNetRentWs = "Income from total property rent (weekly) sps"
		IncNetRentW1 = "Income from total property rent (weekly) dep 1"
		IncNetRentW2 = "Income from total property rent (weekly) dep 2"
		IncNetRentW3 = "Income from total property rent (weekly) dep 3"
		IncNetRentW4 = "Income from total property rent (weekly) dep 4"
		IncOSPenSWr = "Income from overseas pensions (weekly) ref"
		IncOSPenSWs = "Income from overseas pensions (weekly) sps"
		IncOSPenSW1 = "Income from overseas pensions (weekly) dep 1"
		IncOSPenSW2 = "Income from overseas pensions (weekly) dep 2"
		IncOSPenSW3 = "Income from overseas pensions (weekly) dep 3"
		IncOSPenSW4 = "Income from overseas pensions (weekly) dep 4"
		IncOthInvSWr = "Income from other financial investments (weekly) ref"
		IncOthInvSWs = "Income from other financial investments (weekly) sps"
		IncOthInvSW1 = "Income from other financial investments (weekly) dep 1"
		IncOthInvSW2 = "Income from other financial investments (weekly) dep 2"
		IncOthInvSW3 = "Income from other financial investments (weekly) dep 3"
		IncOthInvSW4 = "Income from other financial investments (weekly) dep 4"
		IncRoyalSWr = "Income from royalties (weekly) ref"
		IncRoyalSWs = "Income from royalties (weekly) sps"
		IncRoyalSW1 = "Income from royalties (weekly) dep 1"
		IncRoyalSW2 = "Income from royalties (weekly) dep 2"
		IncRoyalSW3 = "Income from royalties (weekly) dep 3"
		IncRoyalSW4 = "Income from royalties (weekly) dep 4"
		IncSuperImpAr = "Income from super (imputed) (annual) ref"
		IncSuperImpAs = "Income from super (imputed) (annual) sps"
		IncSuperImpA1 = "Income from super (imputed) (annual) dep 1"
		IncSuperImpA2 = "Income from super (imputed) (annual) dep 2"
		IncSuperImpA3 = "Income from super (imputed) (annual) dep 3"
		IncSuperImpA4 = "Income from super (imputed) (annual) dep 4"
		IncSuperSAr = "Income from super (annually) ref"
		IncSuperSAs = "Income from super (annually) sps"
		IncSuperSA1 = "Income from super (annually) dep 1"
		IncSuperSA2 = "Income from super (annually) dep 2"
		IncSuperSA3 = "Income from super (annually) dep 3"
		IncSuperSA4 = "Income from super (annually) dep 4"
		IncSuperSWr = "Income from super (weekly) ref"
		IncSuperSWs = "Income from super (weekly) sps"
		IncSuperSW1 = "Income from super (weekly) dep 1"
		IncSuperSW2 = "Income from super (weekly) dep 2"
		IncSuperSW3 = "Income from super (weekly) dep 3"
		IncSuperSW4 = "Income from super (weekly) dep 4"
		IncSupGovtImpAr = "Income from public sector super sources (annual) ref"
		IncSupGovtImpAs = "Income from public sector super sources (annual) sps"
		IncSupGovtImpA1 = "Income from public sector super sources (annual) dep 1"
		IncSupGovtImpA2 = "Income from public sector super sources (annual) dep 2"
		IncSupGovtImpA3 = "Income from public sector super sources (annual) dep 3"
		IncSupGovtImpA4 = "Income from public sector super sources (annual) dep 4"
		IncSupPrivImpAr = "Income from private sector super sources (annual) ref"
		IncSupPrivImpAs = "Income from private sector super sources (annual) sps"
		IncSupPrivImpA1 = "Income from private sector super sources (annual) dep 1"
		IncSupPrivImpA2 = "Income from private sector super sources (annual) dep 2"
		IncSupPrivImpA3 = "Income from private sector super sources (annual) dep 3"
		IncSupPrivImpA4 = "Income from private sector super sources (annual) dep 4"
		IncTrustSAr = "Income from trusts (annually) ref"
		IncTrustSAs = "Income from trusts (annually) sps"
		IncTrustSA1 = "Income from trusts (annually) dep 1"
		IncTrustSA2 = "Income from trusts (annually) dep 2"
		IncTrustSA3 = "Income from trusts (annually) dep 3"
		IncTrustSA4 = "Income from trusts (annually) dep 4"
		IUID = "Income unit identifier"
		IUWeightSu = "IU weight (SIH)"
		Kids0to14u = "Number of kids aged 0-14 in IU"
		Kids0to15u = "Number of kids aged 0-15 in IU"
		LfStatr = "Labour force status ref"
		LfStats = "Labour force status sps"
		LfStat1 = "Labour force status dep 1"
		LfStat2 = "Labour force status dep 2"
		LfStat3 = "Labour force status dep 3"
		LfStat4 = "Labour force status dep 4"
		MaintPaidSWr = "Maintenance paid (weekly) ref"
		MaintPaidSWs = "Maintenance paid (weekly) sps"
		PersIDr = "Person identifier ref"
		PersIDs = "Person identifier sps"
		PersID1 = "Person identifier dep 1"
		PersID2 = "Person identifier dep 2"
		PersID3 = "Person identifier dep 3"
		PersID4 = "Person identifier dep 4"
		PersonsInIUSu = "Number of persons in IU (SIH)"
		PersonWeightSr = "Person weight (SIH) ref"
		PersonWeightSs = "Person weight (SIH) sps"
		PersonWeightS1 = "Person weight (SIH) dep 1"
		PersonWeightS2 = "Person weight (SIH) dep 2"
		PersonWeightS3 = "Person weight (SIH) dep 3"
		PersonWeightS4 = "Person weight (SIH) dep 4"
		PPLFlagSr = "PPL Flag ref"
		PPLFlagSs = "PPL Flag sps"
		PPLFlagS1 = "PPL Flag dep 1"
		PPLFlagS2 = "PPL Flag dep 2"
		PPLFlagS3 = "PPL Flag dep 3"
		PPLFlagS4 = "PPL Flag dep 4"
		RelationHHSr = "Relationship in household ref"
		RelationHHSs = "Relationship in household sps"
		RelationHHS1 = "Relationship in household dep 1"
		RelationHHS2 = "Relationship in household dep 2"
		RelationHHS3 = "Relationship in household dep 3"
		RelationHHS4 = "Relationship in household dep 4"
		RentPaidWh = "Rent paid (weekly)"
		Stateh = "State"
		StateSh = "State (SIH)"
		StudyTyper = "Study status ref"
		StudyTypes = "Study status sps"
		StudyType1 = "Study status dep 1"
		StudyType2 = "Study status dep 2"
		StudyType3 = "Study status dep 3"
		StudyType4 = "Study status dep 4"

		LfStat1 = "Labour force status dep 1"
		LfStat2 = "Labour force status dep 2"
		LfStat3 = "Labour force status dep 3"
		LfStat4 = "Labour force status dep 4"

	  /* ### The following are not in the cameo capita_outfile, but the corresponding reference/spouse variables are */
		AgePenSW1 = "Income from age pension on the SIH (weekly) dep 1"
		AgePenSW2 = "Income from age pension on the SIH (weekly) dep 2"
		AgePenSW3 = "Income from age pension on the SIH (weekly) dep 3"
		AgePenSW4 = "Income from age pension on the SIH (weekly) dep 4"
		CarerAllSW1 = "Income from carer allowance on the SIH (weekly) dep 1"
		CarerAllSW2 = "Income from carer allowance on the SIH (weekly) dep 2"
		CarerAllSW3 = "Income from carer allowance on the SIH (weekly) dep 3"
		CarerAllSW4 = "Income from carer allowance on the SIH (weekly) dep 4"
		CarerPaySW1 = "Income from carer payment on the SIH (weekly) dep 1"
		CarerPaySW2 = "Income from carer payment on the SIH (weekly) dep 2"
		CarerPaySW3 = "Income from carer payment on the SIH (weekly) dep 3"
		CarerPaySW4 = "Income from carer payment on the SIH (weekly) dep 4"
		DvaDisPenSW1 = "Income from DVA disability pension on the SIH (weekly) dep 1"
		DvaDisPenSW2 = "Income from DVA disability pension on the SIH (weekly) dep 2"
		DvaDisPenSW3 = "Income from DVA disability pension on the SIH (weekly) dep 3"
		DvaDisPenSW4 = "Income from DVA disability pension on the SIH (weekly) dep 4"
		DvaSPenSW1 = "Income from DVA service pension on the SIH (weekly) dep 1"
		DvaSPenSW2 = "Income from DVA service pension on the SIH (weekly) dep 2"
		DvaSPenSW3 = "Income from DVA service pension on the SIH (weekly) dep 3"
		DvaSPenSW4 = "Income from DVA service pension on the SIH (weekly) dep 4"
		IncIntBondSA1 = "Interest from bonds (annually) dep 1"
		IncIntBondSA2 = "Interest from bonds (annually) dep 2"
		IncIntBondSA3 = "Interest from bonds (annually) dep 3"
		IncIntBondSA4 = "Interest from bonds (annually) dep 4"
		IncIntBondSPA1 = "Interest from bonds (previous year) dep 1"
		IncIntBondSPA2 = "Interest from bonds (previous year) dep 2"
		IncIntBondSPA3 = "Interest from bonds (previous year) dep 3"
		IncIntBondSPA4 = "Interest from bonds (previous year) dep 4"
		IncIntBondSW1 = "Interest from bonds (weekly) dep 1"
		IncIntBondSW2 = "Interest from bonds (weekly) dep 2"
		IncIntBondSW3 = "Interest from bonds (weekly) dep 3"
		IncIntBondSW4 = "Interest from bonds (weekly) dep 4"
		IncIntFinSA1 = "Interest from financial accounts (annually) dep 1"
		IncIntFinSA2 = "Interest from financial accounts (annually) dep 2"
		IncIntFinSA3 = "Interest from financial accounts (annually) dep 3"
		IncIntFinSA4 = "Interest from financial accounts (annually) dep 4"
		IncIntFinSPA1 = "Interest from financial accounts (previous year) dep 1"
		IncIntFinSPA2 = "Interest from financial accounts (previous year) dep 2"
		IncIntFinSPA3 = "Interest from financial accounts (previous year) dep 3"
		IncIntFinSPA4 = "Interest from financial accounts (previous year) dep 4"
		IncIntFinSW1 = "Interest from financial accounts (weekly) dep 1"
		IncIntFinSW2 = "Interest from financial accounts (weekly) dep 2"
		IncIntFinSW3 = "Interest from financial accounts (weekly) dep 3"
		IncIntFinSW4 = "Interest from financial accounts (weekly) dep 4"
		IncIntLoanSA1 = "Interest from loans (annually) dep 1"
		IncIntLoanSA2 = "Interest from loans (annually) dep 2"
		IncIntLoanSA3 = "Interest from loans (annually) dep 3"
		IncIntLoanSA4 = "Interest from loans (annually) dep 4"
		IncIntLoanSPA1 = "Interest from loans (previous year) dep 1"
		IncIntLoanSPA2 = "Interest from loans (previous year) dep 2"
		IncIntLoanSPA3 = "Interest from loans (previous year) dep 3"
		IncIntLoanSPA4 = "Interest from loans (previous year) dep 4"
		IncIntLoanSW1 = "Interest from loans (weekly) dep 1"
		IncIntLoanSW2 = "Interest from loans (weekly) dep 2"
		IncIntLoanSW3 = "Interest from loans (weekly) dep 3"
		IncIntLoanSW4 = "Interest from loans (weekly) dep 4"
		IncIntPA1 = "Total interest income (previous year) dep 1"
		IncIntPA2 = "Total interest income (previous year) dep 2"
		IncIntPA3 = "Total interest income (previous year) dep 3"
		IncIntPA4 = "Total interest income (previous year) dep 4"
		IncMaintSA1 = "Income from maintenance (annually) dep 1"
		IncMaintSA2 = "Income from maintenance (annually) dep 2"
		IncMaintSA3 = "Income from maintenance (annually) dep 3"
		IncMaintSA4 = "Income from maintenance (annually) dep 4"
		IncNetRentPA1 = "Income from total property rent (previous year) dep 1"
		IncNetRentPA2 = "Income from total property rent (previous year) dep 2"
		IncNetRentPA3 = "Income from total property rent (previous year) dep 3"
		IncNetRentPA4 = "Income from total property rent (previous year) dep 4"
		IncNonHHSA1 = "Income from non HH family members (annually) dep 1"
		IncNonHHSA2 = "Income from non HH family members (annually) dep 2"
		IncNonHHSA3 = "Income from non HH family members (annually) dep 3"
		IncNonHHSA4 = "Income from non HH family members (annually) dep 4"
		IncNonHHSPA1 = "Income from non HH family members (previous year) dep 1"
		IncNonHHSPA2 = "Income from non HH family members (previous year) dep 2"
		IncNonHHSPA3 = "Income from non HH family members (previous year) dep 3"
		IncNonHHSPA4 = "Income from non HH family members (previous year) dep 4"
		IncNonHHSW1 = "Income from non HH family members (weekly) dep 1"
		IncNonHHSW2 = "Income from non HH family members (weekly) dep 2"
		IncNonHHSW3 = "Income from non HH family members (weekly) dep 3"
		IncNonHHSW4 = "Income from non HH family members (weekly) dep 4"
		IncNonTaxSuperImpA1 = "Non-taxable super income (annual) dep 1"
		IncNonTaxSuperImpA2 = "Non-taxable super income (annual) dep 2"
		IncNonTaxSuperImpA3 = "Non-taxable super income (annual) dep 3"
		IncNonTaxSuperImpA4 = "Non-taxable super income (annual) dep 4"
		IncOthInvSPA1 = "Income from other financial investments (previous year) dep 1"
		IncOthInvSPA2 = "Income from other financial investments (previous year) dep 2"
		IncOthInvSPA3 = "Income from other financial investments (previous year) dep 3"
		IncOthInvSPA4 = "Income from other financial investments (previous year) dep 4"
		IncOthRegSA1 = "Income n.e.c. (annually) dep 1"
		IncOthRegSA2 = "Income n.e.c. (annually) dep 2"
		IncOthRegSA3 = "Income n.e.c. (annually) dep 3"
		IncOthRegSA4 = "Income n.e.c. (annually) dep 4"
		IncOthRegSPA1 = "Income n.e.c. (previous year) dep 1"
		IncOthRegSPA2 = "Income n.e.c. (previous year) dep 2"
		IncOthRegSPA3 = "Income n.e.c. (previous year) dep 3"
		IncOthRegSPA4 = "Income n.e.c. (previous year) dep 4"
		IncOthRegSW1 = "Income n.e.c. (weekly) dep 1"
		IncOthRegSW2 = "Income n.e.c. (weekly) dep 2"
		IncOthRegSW3 = "Income n.e.c. (weekly) dep 3"
		IncOthRegSW4 = "Income n.e.c. (weekly) dep 4"
		IncPUTrustSA1 = "Income from public unit trusts (annually) dep 1"
		IncPUTrustSA2 = "Income from public unit trusts (annually) dep 2"
		IncPUTrustSA3 = "Income from public unit trusts (annually) dep 3"
		IncPUTrustSA4 = "Income from public unit trusts (annually) dep 4"
		IncPUTrustSPA1 = "Income from public unit trusts (previous year) dep 1"
		IncPUTrustSPA2 = "Income from public unit trusts (previous year) dep 2"
		IncPUTrustSPA3 = "Income from public unit trusts (previous year) dep 3"
		IncPUTrustSPA4 = "Income from public unit trusts (previous year) dep 4"
		IncPUTrustSW1 = "Income from public unit trusts (weekly) dep 1"
		IncPUTrustSW2 = "Income from public unit trusts (weekly) dep 2"
		IncPUTrustSW3 = "Income from public unit trusts (weekly) dep 3"
		IncPUTrustSW4 = "Income from public unit trusts (weekly) dep 4"
		IncRentNResSA1 = "Income from non-res property (annually) dep 1"
		IncRentNResSA2 = "Income from non-res property (annually) dep 2"
		IncRentNResSA3 = "Income from non-res property (annually) dep 3"
		IncRentNResSA4 = "Income from non-res property (annually) dep 4"
		IncRentNResSPA1 = "Income from non-res property (previous year) dep 1"
		IncRentNResSPA2 = "Income from non-res property (previous year) dep 2"
		IncRentNResSPA3 = "Income from non-res property (previous year) dep 3"
		IncRentNResSPA4 = "Income from non-res property (previous year) dep 4"
		IncRentNResSW1 = "Income from non-res property (weekly) dep 1"
		IncRentNResSW2 = "Income from non-res property (weekly) dep 2"
		IncRentNResSW3 = "Income from non-res property (weekly) dep 3"
		IncRentNResSW4 = "Income from non-res property (weekly) dep 4"
		IncRentResSA1 = "Income from res property (annually) dep 1"
		IncRentResSA2 = "Income from res property (annually) dep 2"
		IncRentResSA3 = "Income from res property (annually) dep 3"
		IncRentResSA4 = "Income from res property (annually) dep 4"
		IncRentResSPA1 = "Income from res property (previous year) dep 1"
		IncRentResSPA2 = "Income from res property (previous year) dep 2"
		IncRentResSPA3 = "Income from res property (previous year) dep 3"
		IncRentResSPA4 = "Income from res property (previous year) dep 4"
		IncRentResSW1 = "Income from res property (weekly) dep 1"
		IncRentResSW2 = "Income from res property (weekly) dep 2"
		IncRentResSW3 = "Income from res property (weekly) dep 3"
		IncRentResSW4 = "Income from res property (weekly) dep 4"
		IncSSSuperSA1 = "SS super (annual) dep 1"
		IncSSSuperSA2 = "SS super (annual) dep 2"
		IncSSSuperSA3 = "SS super (annual) dep 3"
		IncSSSuperSA4 = "SS super (annual) dep 4"
		IncSSSuperSF1 = "SS super (fortnightly) dep 1"
		IncSSSuperSF2 = "SS super (fortnightly) dep 2"
		IncSSSuperSF3 = "SS super (fortnightly) dep 3"
		IncSSSuperSF4 = "SS super (fortnightly) dep 4"
		IncSSTotSA1 = "Total SS benefits (annual) dep 1"
		IncSSTotSA2 = "Total SS benefits (annual) dep 2"
		IncSSTotSA3 = "Total SS benefits (annual) dep 3"
		IncSSTotSA4 = "Total SS benefits (annual) dep 4"
		IncSSTotSF1 = "Total SS benefits (fortnightly) dep 1"
		IncSSTotSF2 = "Total SS benefits (fortnightly) dep 2"
		IncSSTotSF3 = "Total SS benefits (fortnightly) dep 3"
		IncSSTotSF4 = "Total SS benefits (fortnightly) dep 4"
		IncTaxSuperImpA1 = "Taxable super income (annual) dep 1"
		IncTaxSuperImpA2 = "Taxable super income (annual) dep 2"
		IncTaxSuperImpA3 = "Taxable super income (annual) dep 3"
		IncTaxSuperImpA4 = "Taxable super income (annual) dep 4"
		IncTaxSuperImpPA1 = "Taxable super income (previous year) dep 1"
		IncTaxSuperImpPA2 = "Taxable super income (previous year) dep 2"
		IncTaxSuperImpPA3 = "Taxable super income (previous year) dep 3"
		IncTaxSuperImpPA4 = "Taxable super income (previous year) dep 4"
		IncTrustSPA1 = "Income from trusts (previous year) dep 1"
		IncTrustSPA2 = "Income from trusts (previous year) dep 2"
		IncTrustSPA3 = "Income from trusts (previous year) dep 3"
		IncTrustSPA4 = "Income from trusts (previous year) dep 4"
		IncTrustSW1 = "Income from trusts (weekly) dep 1"
		IncTrustSW2 = "Income from trusts (weekly) dep 2"
		IncTrustSW3 = "Income from trusts (weekly) dep 3"
		IncTrustSW4 = "Income from trusts (weekly) dep 4"
		IncWCompA1 = "Income from total workers comp (annually) dep 1"
		IncWCompA2 = "Income from total workers comp (annually) dep 2"
		IncWCompA3 = "Income from total workers comp (annually) dep 3"
		IncWCompA4 = "Income from total workers comp (annually) dep 4"
		IncWCompPA1 = "Income from total workers comp (previous year) dep 1"
		IncWCompPA2 = "Income from total workers comp (previous year) dep 2"
		IncWCompPA3 = "Income from total workers comp (previous year) dep 3"
		IncWCompPA4 = "Income from total workers comp (previous year) dep 4"
		IncWCompSA1 = "Income from regular workers comp (annually) dep 1"
		IncWCompSA2 = "Income from regular workers comp (annually) dep 2"
		IncWCompSA3 = "Income from regular workers comp (annually) dep 3"
		IncWCompSA4 = "Income from regular workers comp (annually) dep 4"
		IncWCompSPA1 = "Income from regular workers comp (previous year) dep 1"
		IncWCompSPA2 = "Income from regular workers comp (previous year) dep 2"
		IncWCompSPA3 = "Income from regular workers comp (previous year) dep 3"
		IncWCompSPA4 = "Income from regular workers comp (previous year) dep 4"
		IncWCompSW1 = "Income from regular workers comp (weekly) dep 1"
		IncWCompSW2 = "Income from regular workers comp (weekly) dep 2"
		IncWCompSW3 = "Income from regular workers comp (weekly) dep 3"
		IncWCompSW4 = "Income from regular workers comp (weekly) dep 4"
		MaintPaidSA1 = "Maintenance paid (annual) dep 1"
		MaintPaidSA2 = "Maintenance paid (annual) dep 2"
		MaintPaidSA3 = "Maintenance paid (annual) dep 3"
		MaintPaidSA4 = "Maintenance paid (annual) dep 4"
		NetInvLossA1 = "Net investment losses (annual) dep 1"
		NetInvLossA2 = "Net investment losses (annual) dep 2"
		NetInvLossA3 = "Net investment losses (annual) dep 3"
		NetInvLossA4 = "Net investment losses (annual) dep 4"
		NetInvLossPA1 = "Net investment losses (previous year) dep 1"
		NetInvLossPA2 = "Net investment losses (previous year) dep 2"
		NetInvLossPA3 = "Net investment losses (previous year) dep 3"
		NetInvLossPA4 = "Net investment losses (previous year) dep 4"
		NonSSTotSA1 = "Total non-SS benefits (fortnightly) dep 1"
		NonSSTotSA2 = "Total non-SS benefits (fortnightly) dep 2"
		NonSSTotSA3 = "Total non-SS benefits (fortnightly) dep 3"
		NonSSTotSA4 = "Total non-SS benefits (fortnightly) dep 4"
		NonSSTotSF1 = "Total non-SS benefits (fortnightly) dep 1"
		NonSSTotSF2 = "Total non-SS benefits (fortnightly) dep 2"
		NonSSTotSF3 = "Total non-SS benefits (fortnightly) dep 3"
		NonSSTotSF4 = "Total non-SS benefits (fortnightly) dep 4"
		NumCareDeps1 = "Number of dependents for Carer Allowance dep 1"
		NumCareDeps2 = "Number of dependents for Carer Allowance dep 2"
		NumCareDeps3 = "Number of dependents for Carer Allowance dep 3"
		NumCareDeps4 = "Number of dependents for Carer Allowance dep 4"
		ParPaySW1 = "Income from parenting payment on the SIH (weekly) dep 1"
		ParPaySW2 = "Income from parenting payment on the SIH (weekly) dep 2"
		ParPaySW3 = "Income from parenting payment on the SIH (weekly) dep 3"
		ParPaySW4 = "Income from parenting payment on the SIH (weekly) dep 4"
		PartAllSW1 = "Income from partner allowance on the SIH (weekly) dep 1"
		PartAllSW2 = "Income from partner allowance on the SIH (weekly) dep 2"
		PartAllSW3 = "Income from partner allowance on the SIH (weekly) dep 3"
		PartAllSW4 = "Income from partner allowance on the SIH (weekly) dep 4"
		RepEmpSupContA1 = "Reportable employer super contributions (annual) dep 1"
		RepEmpSupContA2 = "Reportable employer super contributions (annual) dep 2"
		RepEmpSupContA3 = "Reportable employer super contributions (annual) dep 3"
		RepEmpSupContA4 = "Reportable employer super contributions (annual) dep 4"
		RepSupContA1 = "Reportable super contributions (annual) dep 1"
		RepSupContA2 = "Reportable super contributions (annual) dep 2"
		RepSupContA3 = "Reportable super contributions (annual) dep 3"
		RepSupContA4 = "Reportable super contributions (annual) dep 4"
		RepSupContPA1 = "Reportable super contributions (previous year) dep 1"
		RepSupContPA2 = "Reportable super contributions (previous year) dep 2"
		RepSupContPA3 = "Reportable super contributions (previous year) dep 3"
		RepSupContPA4 = "Reportable super contributions (previous year) dep 4"
		SickAllSW1 = "Income from sickness allowance on the SIH (weekly) dep 1"
		SickAllSW2 = "Income from sickness allowance on the SIH (weekly) dep 2"
		SickAllSW3 = "Income from sickness allowance on the SIH (weekly) dep 3"
		SickAllSW4 = "Income from sickness allowance on the SIH (weekly) dep 4"
		SpBSW1 = "Income from special benefit on the SIH (weekly) dep 1"
		SpBSW2 = "Income from special benefit on the SIH (weekly) dep 2"
		SpBSW3 = "Income from special benefit on the SIH (weekly) dep 3"
		SpBSW4 = "Income from special benefit on the SIH (weekly) dep 4"
		WifePenSW1 = "Income from wife pension on the SIH (weekly) dep 1"
		WifePenSW2 = "Income from wife pension on the SIH (weekly) dep 2"
		WifePenSW3 = "Income from wife pension on the SIH (weekly) dep 3"
		WifePenSW4 = "Income from wife pension on the SIH (weekly) dep 4"
		
    %END ;


	/* Variables used for both Basefile runs and Cameo runs */
	AbstudyNmAr = "Abstudy received (annual) ref"
	AbstudyNmAs = "Abstudy received (annual) sps"
	AbstudyNmFr = "Abstudy received (fortnight) ref"
	AbstudyNmFs = "Abstudy received (fortnight) sps"
	AdjTaxIncAr = "Adjusted taxable income (annual) ref"
	AdjTaxIncAs = "Adjusted taxable income (annual) sps"
	AdjTaxIncA1 = "Adjusted taxable income (annual) dep 1"
	AdjTaxIncA2 = "Adjusted taxable income (annual) dep 2"
	AdjTaxIncA3 = "Adjusted taxable income (annual) dep 3"
	AdjTaxIncA4 = "Adjusted taxable income (annual) dep 4"
	AdjTaxIncAu = "Adjusted taxable income annual"
	AdjTaxIncFr = "Adjusted taxable income (fortnightly) ref"
	AdjTaxIncFs = "Adjusted taxable income (fortnightly) sps"
	AdjTaxIncF1 = "Adjusted taxable income (fortnightly) dep 1"
	AdjTaxIncF2 = "Adjusted taxable income (fortnightly) dep 2"
	AdjTaxIncF3 = "Adjusted taxable income (fortnightly) dep 3"
	AdjTaxIncF4 = "Adjusted taxable income (fortnightly) dep 4"
	AdjTaxIncFu = "Adjusted taxable income fortnight"
	AgePenBasicAr = "Basic annual age pension ref"
	AgePenBasicAs = "Basic annual age pension sps"
	AgePenBasicFr = "Basic fortnightly age pension ref"
	AgePenBasicFs = "Basic fortnightly age pension sps"
	AgePenEsAr = "Energy supplement paid annually with Age Pension ref"
	AgePenEsAs = "Energy supplement paid annually with Age Pension sps"
	AgePenEsFr = "Energy supplement paid fortnightly with Age Pension ref"
	AgePenEsFs = "Energy supplement paid fortnightly with Age Pension sps"
	AgePenSupBasicAr = "Final pension supplement paid annually with Age Pension ref"
	AgePenSupBasicAs = "Final pension supplement paid annually with Age Pension sps"
	AgePenSupBasicFr = "Final pension supplement paid fortnightly with Age Pension ref"
	AgePenSupBasicFs = "Final pension supplement paid fortnightly with Age Pension sps"
	AgePenSupMinAr = "Annual minimum pension supplement for Age Pension ref"
	AgePenSupMinAs = "Annual minimum pension supplement for Age Pension sps"
	AgePenSupMinFr = "Fortnightly minimum pension supplement for Age Pension ref"
	AgePenSupMinFs = "Fortnightly minimum pension supplement for Age Pension sps"
	AgePenSupRemAr = "Annual remaining pension supplement for Age Pension ref"
	AgePenSupRemAs = "Annual remaining pension supplement for Age Pension sps"
	AgePenSupRemFr = "Fortnightly remaining pension supplement for Age Pension ref"
	AgePenSupRemFs = "Fortnightly remaining pension supplement for Age Pension sps"
	AgePharmAllAr = "Pharm Allowance annual for Age Pension ref"
	AgePharmAllAs = "Pharm Allowance annual for Age Pension sps"
	AgePharmAllFr = "Pharm Allowance fortnightly for Age Pension ref"
	AgePharmAllFs = "Pharm Allowance fortnightly for Age Pension sps"
	AgeRAssAr = "Rent Assistance fortnightly for Age Pension ref"
	AgeRAssAs = "Rent Assistance fortnightly for Age Pension sps"
	AgeRAssFr = "Rent Assistance annual for Age Pension ref"
	AgeRAssFs = "Rent Assistance annual for Age Pension sps"
	AgeTotAr = "Total annual age pension ref"
	AgeTotAs = "Total annual age pension sps"
	AgeTotAu = "EMTR for Age Pension"
	AgeTotAu = "Age Pension annual"
	AgeTotFr = "Total fortnightly age pension ref"
	AgeTotFs = "Total fortnightly age pension sps"
	AgeTotFu = "Age Pension fortnight"
	AllowTyper = "Type of allowance received ref"
	AllowTypes = "Type of allowance received sps"
	AllowType1 = "Type of allowance received dep 1"
	AllowType2 = "Type of allowance received dep 2"
	AllowType3 = "Type of allowance received dep 3"
	AllowType4 = "Type of allowance received dep 4"
	AllPareTestIncA = "Combined parents income"
	AssessableIncAr = "Individual's assessable income (annual) ref"
	AssessableIncAs = "Individual's assessable income (annual) sps"
	AssessableIncA1 = "Individual's assessable income (annual) dep 1"
	AssessableIncA2 = "Individual's assessable income (annual) dep 2"
	AssessableIncA3 = "Individual's assessable income (annual) dep 3"
	AssessableIncA4 = "Individual's assessable income (annual) dep 4"
	AssessableIncAu = "Assessable income annual"
	AssessableIncFr = "Individual's assessable income (fortnightly) ref"
	AssessableIncFs = "Individual's assessable income (fortnightly) sps"
	AssessableIncF1 = "Individual's assessable income (fortnightly) dep 1"
	AssessableIncF2 = "Individual's assessable income (fortnightly) dep 2"
	AssessableIncF3 = "Individual's assessable income (fortnightly) dep 3"
	AssessableIncF4 = "Individual's assessable income (fortnightly) dep 4"
	AssessableIncFu = "Assessable income fortnight"
	AtiFlagr = "Flag pension as taxable or non-taxable ref"
	AtiFlags = "Flag pension as taxable or non-taxable sps"
	AtiFlag1 = "Flag pension as taxable or non-taxable dep 1"
	AtiFlag2 = "Flag pension as taxable or non-taxable dep 2"
	AtiFlag3 = "Flag pension as taxable or non-taxable dep 3"
	AtiFlag4 = "Flag pension as taxable or non-taxable dep 4"
	AustudyTotAu = "EMTR for Austudy"
	AustudyTotAu = "Total Austudy annual"
	AustudyTotFu = "Total Austudy fortnight"
	BentoAr = "Beneficiaries tax offset - annual ref"
	BentoAs = "Beneficiaries tax offset - annual sps"
	BentoA1 = "Beneficiaries tax offset - annual dep 1"
	BentoA2 = "Beneficiaries tax offset - annual dep 2"
	BentoA3 = "Beneficiaries tax offset - annual dep 3"
	BentoA4 = "Beneficiaries tax offset - annual dep 4"
	BentoFr = "Beneficiaries tax offset - fortnight ref"
	BentoFs = "Beneficiaries tax offset - fortnight sps"
	BentoF1 = "Beneficiaries tax offset - fortnight dep 1"
	BentoF2 = "Beneficiaries tax offset - fortnight dep 2"
	BentoF3 = "Beneficiaries tax offset - fortnight dep 3"
	BentoF4 = "Beneficiaries tax offset - fortnight dep 4"
	BentoFlagr = "BENTO eligibility ref"
	BentoFlags = "BENTO eligibility sps"
	BentoFlag1 = "BENTO eligibility dep 1"
	BentoFlag2 = "BENTO eligibility dep 2"
	BentoFlag3 = "BENTO eligibility dep 3"
	BentoFlag4 = "BENTO eligibility dep 4"
	CareAllAr = "Carer Allowance annual rate ref"
	CareAllAs = "Carer Allowance annual rate sps"
	CareAllFr = "Carer Allowance fortnightly rate ref"
	CareAllFs = "Carer Allowance fortnightly rate sps"
	CareAllflagr = "Carer Allowance eligibility ref"
	CareAllflags = "Carer Allowance eligibility sps"
	CarerPenBasicAr = "Basic annual Carer Pension ref"
	CarerPenBasicAs = "Basic annual Carer Pension sps"
	CarerPenBasicFr = "Basic fortnightly Carer Pension ref"
	CarerPenBasicFs = "Basic fortnightly Carer Pension sps"
	CarerPenEsAr = "Energy supplement paid annually with Carer Pension ref"
	CarerPenEsAs = "Energy supplement paid annually with Carer Pension sps"
	CarerPenEsFr = "Energy supplement paid fortnightly with Carer Pension ref"
	CarerPenEsFs = "Energy supplement paid fortnightly with Carer Pension sps"
	CarerPenSupBasicAr = "Final pension basic supplement paid annually with Carer Pension ref"
	CarerPenSupBasicAs = "FInal pension basic supplement paid annually with Carer Pension sps"
	CarerPenSupBasicFr = "Final pension basic supplement paid fortnightly with Carer Pension ref"
	CarerPenSupBasicFs = "Final pension basic supplement paid fortnightly with Carer Pension sps"
	CarerPenSupMinAr = "Annual minimum pension supplement for Carer pension ref"
	CarerPenSupMinAs = "Annual minimum pension supplement for Carer pension sps"
	CarerPenSupMinFr = "Fortnightly minimum pension supplement for Carer pension ref"
	CarerPenSupMinFs = "Fortnightly minimum pension supplement for Carer pension sps"
	CarerPenSupRemAr = "Annual remaining pension supplement for Carer pension ref"
	CarerPenSupRemAs = "Annual remaining pension supplement for Carer pension sps"
	CarerPenSupRemFr = "Fortnightly remaining pension supplement for Carer pension ref"
	CarerPenSupRemFs = "Fortnightly remaining pension supplement for Carer pension sps"
	CarerPenTaxFlagr = "Carer payment taxable flag ref"
	CarerPenTaxFlags = "Carer payment taxable flag sps"
	CarerPharmAllFr = "Pharm Allowance fortnightly for Carer Pension ref"
	CarerPharmAllFs = "Pharm Allowance fortnightly for Carer Pension sps"
	CarerRAssAr = "Rent Assistance annual for Carer Pension ref"
	CarerRAssAs = "Rent Assistance annual for Carer Pension sps"
	CarerRAssFr = "Rent Assistance fortnightly for Carer Pension ref"
	CarerRAssFs = "Rent Assistance fortnightly for Carer Pension sps"
	CarerTotAr = "Total Carer Pension annual ref"
	CarerTotAs = "Total Carer Pension annual sps"
	CarerTotAu = "EMTR for Carer Pension"
	CarerTotAu = "Total Carer Pension annual"
	CarerTotFr = "Total Carer Pension fortnight ref"
	CarerTotFs = "Total Carer Pension fortnight sps"
	CarerTotFu = "Total Carer Pension fortnight"
	CareSupAr = "Carer Supplement annual amount ref"
	CareSupAs = "Carer Supplement annual amount sps"
	CareSupFr = "Carer Supplement fortnightly amount ref"
	CareSupFs = "Carer Supplement fortnightly amount sps"
	CcbAddLd = "Additional MWB loading"
	CcbAddMaxBenW = "Additional MWB"
	CcbAmtAu = "Annual family CCB"
	CcbAmtW1 = "Weekly CCB per child dep 1"
	CcbAmtW2 = "Weekly CCB per child dep 2"
	CcbAmtW3 = "Weekly CCB per child dep 3"
	CcbAmtW4 = "Weekly CCB per child dep 4"
	CcbCostW1 = "Actual weekly child care cost per child dep 1"
	CcbCostW2 = "Actual weekly child care cost per child dep 2"
	CcbCostW3 = "Actual weekly child care cost per child dep 3"
	CcbCostW4 = "Actual weekly child care cost per child dep 4"
	CcbEligHrW1 = "Eligible per child CCB hours dep 1"
	CcbEligHrW2 = "Eligible per child CCB hours dep 2"
	CcbEligHrW3 = "Eligible per child CCB hours dep 3"
	CcbEligHrW4 = "Eligible per child CCB hours dep 4"
	CcbIncExcWOcc = "Weekly income excess - OCC"
	CcbIncExcWOtr = "Weekly income excess - care other than OCC"
	CcbInfElig = "CCB (registered care) eligibility flag"
	CcbLdcPct1 = "LDC part-time percentage dep 1"
	CcbLdcPct2 = "LDC part-time percentage dep 2"
	CcbLdcPct3 = "LDC part-time percentage dep 3"
	CcbLdcPct4 = "LDC part-time percentage dep 4"
	CcbMaxBenW1 = "Maximum weekly benefit table - item 1"
	CcbMaxBenW3 = "Maximum weekly benefit table - item 3"
	CcbMaxBenW5 = "Maximum weekly benefit table - item 5"
	CcbMaxBenWOcc = "Maximum weekly benefit - OCC"
	CcbMaxBenWOtr = "Maximum weekly benefit - care other than OCC"
	CcbMaxBenWSpcTapAmt = "Maximum weekly benefit - specific taper amount"
	CcbMaxHrW = "Max CCB hours "
	CcbMultChdPctOcc = "Multiple child % - OCC"
	CcbMultChdPctOtr = "Multiple child % - care other than OCC"
	CcbNumKidInf = "Number of children in CCB (registered care)"
	CcbNumKidOcc = "Number of children in CCB (approved care - OCC)"
	CcbNumKidOtr = "Number of children in CCB (approved care - other than OCC)"
	CcbOutPocketAu = "Annual family CCB out of pocket costs"
	CcbOutPocketW1 = "Weekly per child CCB out of pocket costs dep 1"
	CcbOutPocketW2 = "Weekly per child CCB out of pocket costs dep 2"
	CcbOutPocketW3 = "Weekly per child CCB out of pocket costs dep 3"
	CcbOutPocketW4 = "Weekly per child CCB out of pocket costs dep 4"
	CcbPctOcc = "CCB % - OCC"
	CcbPctOtr = "CCB % - care other than OCC"
	CcbSchPct1 = "CCB schooling percentage dep 1"
	CcbSchPct2 = "CCB schooling percentage dep 2"
	CcbSchPct3 = "CCB schooling percentage dep 3"
	CcbSchPct4 = "CCB schooling percentage dep 4"
	CcbStdRate1 = "CCB per child standard hourly rate dep 1"
	CcbStdRate2 = "CCB per child standard hourly rate dep 2"
	CcbStdRate3 = "CCB per child standard hourly rate dep 3"
	CcbStdRate4 = "CCB per child standard hourly rate dep 4"
	CcbTapPctOcc = "Taper % - OCC"
	CcbTapPctOtr = "Taper % - care other than OCC"
	CcbTaxIncPctOcc = "Taxable Income % - OCC"
	CcbTaxIncPctOtr = "Taxable Income % - care other than OCC"
	CcrAmtA1 = "Annual CCR per child dep 1"
	CcrAmtA2 = "Annual CCR per child dep 2"
	CcrAmtA3 = "Annual CCR per child dep 3"
	CcrAmtA4 = "Annual CCR per child dep 4"
	CcrAmtAu = "Annual CCR per family"
	CcrElig = "CCR eligibility flag"
	CcrOutPocketA1 = "Annual per child CCR out of pocket costs dep 1"
	CcrOutPocketA2 = "Annual per child CCR out of pocket costs dep 2"
	CcrOutPocketA3 = "Annual per child CCR out of pocket costs dep 3"
	CcrOutPocketA4 = "Annual per child CCR out of pocket costs dep 4"
	CcrOutPocketAu = "Annual per family CCR out of pocket costs"
	CcsAmtA1 = "Annual CCS amount for each child dep 1"
	CcsAmtA2 = "Annual CCS amount for each child dep 2"
	CcsAmtA3 = "Annual CCS amount for each child dep 3"
	CcsAmtA4 = "Annual CCS amount for each child dep 4"
	CcsAmtAu = "Annual CCS amount for each family"
	CcsAmtW1 = "Weekly CCS amount per child dep 1"
	CcsAmtW2 = "Weekly CCS amount per child dep 2"
	CcsAmtW3 = "Weekly CCS amount per child dep 3"
	CcsAmtW4 = "Weekly CCS amount per child dep 4"
	CcsCostA1 = "Actual annual child care cost per child dep 1"
	CcsCostA2 = "Actual annual child care cost per child dep 2"
	CcsCostA3 = "Actual annual child care cost per child dep 3"
	CcsCostA4 = "Actual annual child care cost per child dep 4"
	CcsCostAu = "Actual annual child care cost per family"
	CcsEffTpr = "Childcare subsidy taper"
	CcsEligHrW1 = "Eligible weekly CCS hours per child dep 1"
	CcsEligHrW2 = "Eligible weekly CCS hours per child dep 2"
	CcsEligHrW3 = "Eligible weekly CCS hours per child dep 3"
	CcsEligHrW4 = "Eligible weekly CCS hours per child dep 4"
	CcsHrFeeCap1 = "Hourly CCS fee cap dep 1"
	CcsHrFeeCap2 = "Hourly CCS fee cap dep 2"
	CcsHrFeeCap3 = "Hourly CCS fee cap dep 3"
	CcsHrFeeCap4 = "Hourly CCS fee cap dep 4"
	CcsMaxHrW = "Maximum hours of CCS assistance per child"
	CcsOutPocketA1 = "Annual out of pocket child care cost per child dep 1"
	CcsOutPocketA2 = "Annual out of pocket child care cost per child dep 2"
	CcsOutPocketA3 = "Annual out of pocket child care cost per child dep 3"
	CcsOutPocketA4 = "Annual out of pocket child care cost per child dep 4"
	CcsOutPocketAu = "Annual out of pocket child care cost per family"
	CcsOutPocketW1 = "Weekly out of pocket child care cost per child dep 1"
	CcsOutPocketW2 = "Weekly out of pocket child care cost per child dep 2"
	CcsOutPocketW3 = "Weekly out of pocket child care cost per child dep 3"
	CcsOutPocketW4 = "Weekly out of pocket child care cost per child dep 4"
	CcsRateA = "CCS subsidy rate"
	CcTestInc = "Adjusted family taxable income"
	CshcFlagr = "Commonwealth Seniors Health Card eligibility ref"
	CshcFlags = "Commonwealth Seniors Health Card eligibility sps"
	CumTax1 = "First cumulative marginal tax"
	CumTax2 = "Second cumulative marginal tax"
	CumTax3 = "Third cumulative marginal tax"
	CumTax4 = "Fourth cumulative marginal tax"
	CumTax5-CumTax10 = "Cumulative marginal tax (spare)"
	DeductionAu = "Total deductions (income unit) (annually)"
	DeductionFu = "Total deductions (income unit) (fortnightly)"
	DepsFtbA = "Dependants for FTBA"
	DepsFtbB = "Dependants for FTBB"
	DepsML = "Dependants for Medicare levy"
	DepsMls = "Dependants for Medicare levy surcharge"
	DepsSec5Flag1 = "Section 5 dependant dep 1"
	DepsSec5Flag2 = "Section 5 dependant dep 2"
	DepsSec5Flag3 = "Section 5 dependant dep 3"
	DepsSec5Flag4 = "Section 5 dependant dep 4"
	DictoAr = "Dependant and invalid tax offset - annual ref"
	DictoAs = "Dependant and invalid tax offset - annual sps"
	DictoFr = "Dependant and invalid tax offset - fortnight ref"
	DictoFs = "Dependant and invalid tax offset - fortnight sps"
	DictoFlagr = "DICTO eligibilty ref"
	DictoFlags = "DICTO eligibilty sps"
	DspPenBasicAr = "Basic annual DSP ref"
	DspPenBasicAs = "Basic annual DSP sps"
	DspPenBasicFr = "Basic fortnightly DSP ref"
	DspPenBasicFs = "Basic fortnightly DSP sps"
	DspPenEsAr = "Energy supplement paid annually with DSP ref"
	DspPenEsAs = "Energy supplement paid annually with DSP sps"
	DspPenEsFr = "Energy supplement paid fortnightly with DSP ref"
	DspPenEsFs = "Energy supplement paid fortnightly with DSP sps"
	DspPenSupBasicAr = "Final pension supplement paid annually with DSP ref"
	DspPenSupBasicAs = "Final pension supplement paid annually with DSP sps"
	DspPenSupBasicFr = "Final pension supplement paid fortnightly with DSP ref"
	DspPenSupBasicFs = "Final pension supplement paid fortnightly with DSP sps"
	DspPenSupMinAr = "Annual minimum pension supplement for DSP ref"
	DspPenSupMinAs = "Annual minimum pension supplement for DSP sps"
	DspPenSupMinFr = "Fortnightly minimum pension supplement for DSP ref"
	DspPenSupMinFs = "Fortnightly minimum pension supplement for DSP sps"
	DspPenSupRemAr = "Annual remaining pension supplement for DSP ref"
	DspPenSupRemAs = "Annual remaining pension supplement for DSP sps"
	DspPenSupRemFr = "Fortnightly remaining pension supplement for DSP ref"
	DspPenSupRemFs = "Fortnightly remaining pension supplement for DSP sps"
	DspPharmAllFr = "Pharm Allowance fortnightly for DSP ref"
	DspPharmAllFs = "Pharm Allowance fortnightly for DSP sps"
	DspRAssAr = "Rent Assistance annual for DSP ref"
	DspRAssAs = "Rent Assistance annual for DSP sps"
	DspRAssFr = "Rent Assistance fortnightly for DSP ref"
	DspRAssFs = "Rent Assistance fortnightly for DSP sps"
	DspTotAr = "Total annual DSP ref"
	DspTotAs = "Total annual DSP sps"
	DspTotAu = "EMTR for DSP"
	DspTotAu = "Total DSP annual"
	DspTotFr = "Total fortnightly DSP ref"
	DspTotFs = "Total fortnightly DSP sps"
	DspTotFu = "Total DSP fortnight"
	DSPU21PenBasicAr = "Basic annual DSPU21 ref"
	DSPU21PenBasicAs = "Basic annual DSPU21 sps"
	DSPU21PenBasicFr = "Basic fortnightly DSPU21 ref"
	DSPU21PenBasicFs = "Basic fortnightly DSPU21 sps"
	DspU21PenEsAr = "Energy supplement paid annually with DSPU21 ref"
	DspU21PenEsAs = "Energy supplement paid annually with DSPU21 sps"
	DspU21PenEsFr = "Energy supplement paid fortnightly with DSPU21 ref"
	DspU21PenEsFs = "Energy supplement paid fortnightly with DSPU21 sps"
	DspU21PenSupBasicAr = "Final pension supplement paid annually with DSPU21 ref"
	DspU21PenSupBasicAs = "Final pension supplement paid annually with DSPU21 sps"
	DspU21PenSupBasicFr = "Final pension supplement paid fortnightly with DSPU21 ref"
	DspU21PenSupBasicFs = "Final pension supplement paid fortnightly with DSPU21 sps"
	DspU21PenSupMinFr = "Fortnightly minimum pension supplement for DSPU21 ref"
	DspU21PenSupMinFs = "Fortnightly minimum pension supplement for DSPU21 sps"
	DspU21PenSupRemFr = "Fortnightly remaining pension supplement for DSPU21 ref"
	DspU21PenSupRemFs = "Fortnightly remaining pension supplement for DSPU21 sps"
	DspU21PharmAllAr = "Pharm Allowance annual for DSPU21 ref"
	DspU21PharmAllAs = "Pharm Allowance annual for DSPU21 sps"
	DspU21PharmAllFr = "Pharm Allowance fortnightly for DSPU21 ref"
	DspU21PharmAllFs = "Pharm Allowance fortnightly for DSPU21 sps"
	DspU21RAssAr = "Rent Assistance annual for DSPU21 ref"
	DspU21RAssAs = "Rent Assistance annual for DSPU21 sps"
	DspU21RAssFr = "Rent Assistance fortnightly for DSPU21 ref"
	DspU21RAssFs = "Rent Assistance fortnightly for DSPU21 sps"
	DspU21TotAr = "Total annual DSPU21 ref"
	DspU21TotAs = "Total annual DSPU21 sps"
	DspU21TotAu = "EMTR for DSP for under 21"
	DspU21TotAu = "Total DSP for under 21 annual"
	DspU21TotFr = "Total fortnightly DSPU21 ref"
	DspU21TotFs = "Total fortnightly DSPU21 sps"
	DspU21TotFu = "Total DSP for under 21 fortnight"
	DstoAr = "Dependant spouse tax offset annual ref"
	DstoAs = "Dependant spouse tax offset annual sps"
	DstoFr = "Dependant spouse tax offset fortnight ref"
	DstoFs = "Dependant spouse tax offset fortnight sps"
	DstoFlagr = "DSTO eligibility ref"
	DstoFlags = "DSTO eligibility sps"
	DvaDisPenNmAr = "DVA Disability Pension received (annual) ref"
	DvaDisPenNmAs = "DVA Disability Pension received (annual) sps"
	DvaDisPenNmFr = "DVA Disability Pension received (fortnightly) ref"
	DvaDisPenNmFs = "DVA Disability Pension received (fortnightly) sps"
	DvaTotAr = "Total annual DVA  ref"
	DvaTotAs = "Total annual DVA  sps"
	DvaTotAu = "Total DVA annual"
	DvaTotFr = "Total fortnightly DVA ref"
	DvaTotFs = "Total fortnightly DVA sps"
	DvaTotFu = "Total DVA fortnight"
	DvaTyper = "Type of DVA entitlement received ref"
	DvaTypes = "Type of DVA entitlement received sps"
	DvaWwPenNmAr = "DVA War Widow Pension received (annual) ref"
	DvaWwPenNmAs = "DVA War Widow Pension received (annual) sps"
	DvaWwPenNmFr = "DVA War Widow Pension received (fortnightly) ref"
	DvaWwPenNmFs = "DVA War Widow Pension received (fortnightly) sps"
	FtbaAr = "FTBA annual ref"
	FtbaAs = "FTBA annual sps"
	FtbaEndSupA = "FTBA end year supplement annual"
	FtbaEsA = "FTBA energy supplement annual"
	FtbaFr = "FTBA fortnight ref"
	FtbaFs = "FTBA fortnight sps"
	FtbaFlag = "FTBA eligibility"
	FtbaLfsA = "FTBA large family supplement annual"
	FtbaNewbornSupA = "FTBA newborn supplement annual"
	FtbaRAssA = "FTBA rent assistance annual"
	FtbbAr = "FTBB annual ref"
	FtbbAs = "FTBB annual sps"
	FtbbEndSupA = "FTBB end year supplement annual"
	FtbbEsA = "FTBB energy supplement annual"
	FtbbFr = "FTBB fortnight ref"
	FtbbFs = "FTBB fortnight sps"
	FtbbFlag = "FTBB eligibility"
	FtbTotAu = "FTB total amount annual"
	GrossIncTaxAr = "Gross income tax annual ref"
	GrossIncTaxAs = "Gross income tax annual sps"
	GrossIncTaxA1 = "Gross income tax annual dep 1"
	GrossIncTaxA2 = "Gross income tax annual dep 2"
	GrossIncTaxA3 = "Gross income tax annual dep 3"
	GrossIncTaxA4 = "Gross income tax annual dep 4"
	GrossIncTaxAu = "Gross income tax annual"
	GrossIncTaxFr = "Gross income tax fortnight ref"
	GrossIncTaxFs = "Gross income tax fortnight sps"
	GrossIncTaxF1 = "Gross income tax fortnight dep 1"
	GrossIncTaxF2 = "Gross income tax fortnight dep 2"
	GrossIncTaxF3 = "Gross income tax fortnight dep 3"
	GrossIncTaxF4 = "Gross income tax fortnight dep 4"
	GrossIncTaxFu = "Gross income tax fortnight"
	IncAllTestFr = "Allowance income test ordinary income ref"
	IncAllTestFs = "Allowance income test ordinary income sps"
	IncAllTestF1 = "Allowance income test ordinary income dep 1"
	IncAllTestF2 = "Allowance income test ordinary income dep 2"
	IncAllTestF3 = "Allowance income test ordinary income dep 3"
	IncAllTestF4 = "Allowance income test ordinary income dep 4"
	IncDispAr = "Disposable income annual ref"
	IncDispAs = "Disposable income annual sps"
	IncDispA1 = "Disposable income annual dep 1"
	IncDispA2 = "Disposable income annual dep 2"
	IncDispA3 = "Disposable income annual dep 3"
	IncDispA4 = "Disposable income annual dep 4"
	IncDispAu = "Disposable income annual"
	IncDispFr = "Disposable income fortnight ref"
	IncDispFs = "Disposable income fortnight sps"
	IncDispF1 = "Disposable income fortnight dep 1"
	IncDispF2 = "Disposable income fortnight dep 2"
	IncDispF3 = "Disposable income fortnight dep 3"
	IncDispF4 = "Disposable income fortnight dep 4"
	IncDispFu = "Disposable income fortnight"
	IncDvaTestF = "DVA income test assessable income"
	IncMLSAr = "Income for Medicare levy surcharge purposes annual ref"
	IncMLSAs = "Income for Medicare levy surcharge purposes annual sps"
	IncMLSA1 = "Income for Medicare levy surcharge purposes annual dep 1"
	IncMLSA2 = "Income for Medicare levy surcharge purposes annual dep 2"
	IncMLSA3 = "Income for Medicare levy surcharge purposes annual dep 3"
	IncMLSA4 = "Income for Medicare levy surcharge purposes annual dep 4"
	IncMLSAu = "Income for Medicare levy surcharge purposes annual"
	IncMLSFr = "Income for Medicare levy surcharge purposes fortnight ref"
	IncMLSFs = "Income for Medicare levy surcharge purposes fortnight sps"
	IncMLSF1 = "Income for Medicare levy surcharge purposes fortnight dep 1"
	IncMLSF2 = "Income for Medicare levy surcharge purposes fortnight dep 2"
	IncMLSF3 = "Income for Medicare levy surcharge purposes fortnight dep 3"
	IncMLSF4 = "Income for Medicare levy surcharge purposes fortnight dep 4"
	IncNonTaxPrivAr = "Non-taxable component of private income (annual) ref"
	IncNonTaxPrivAs = "Non-taxable component of private income (annual) sps"
	IncNonTaxPrivA1 = "Non-taxable component of private income (annual) dep 1"
	IncNonTaxPrivA2 = "Non-taxable component of private income (annual) dep 2"
	IncNonTaxPrivA3 = "Non-taxable component of private income (annual) dep 3"
	IncNonTaxPrivA4 = "Non-taxable component of private income (annual) dep 4"
	IncNonTaxTranAr = "Non taxable transfer income annual ref"
	IncNonTaxTranAs = "Non taxable transfer income annual sps"
	IncNonTaxTranA1 = "Non taxable transfer income annual dep 1"
	IncNonTaxTranA2 = "Non taxable transfer income annual dep 2"
	IncNonTaxTranA3 = "Non taxable transfer income annual dep 3"
	IncNonTaxTranA4 = "Non taxable transfer income annual dep 4"
	IncOrdAr = "Ordinary income annual ref"
	IncOrdAs = "Ordinary income annual sps"
	IncOrdA1 = "Ordinary income annual dep 1"
	IncOrdA2 = "Ordinary income annual dep 2"
	IncOrdA3 = "Ordinary income annual dep 3"
	IncOrdA4 = "Ordinary income annual dep 4"
	IncOrdDvaFr = "Ordinary DVA income fortnightly ref"
	IncOrdDvaFs = "Ordinary DVA income fortnightly sps"
	IncOrdDvaF1 = "Ordinary DVA income fortnightly dep 1"
	IncOrdDvaF2 = "Ordinary DVA income fortnightly dep 2"
	IncOrdDvaF3 = "Ordinary DVA income fortnightly dep 3"
	IncOrdDvaF4 = "Ordinary DVA income fortnightly dep 4"
	IncOrdFr = "Ordinary income fortnightly ref"
	IncOrdFs = "Ordinary income fortnightly sps"
	IncOrdF1 = "Ordinary income fortnightly dep 1"
	IncOrdF2 = "Ordinary income fortnightly dep 2"
	IncOrdF3 = "Ordinary income fortnightly dep 3"
	IncOrdF4 = "Ordinary income fortnightly dep 4"
	IncPenTestF = "Pension test income"
	IncPrivAr = "Private income annual ref"
	IncPrivAs = "Private income annual sps"
	IncPrivA1 = "Private income annual dep 1"
	IncPrivA2 = "Private income annual dep 2"
	IncPrivA3 = "Private income annual dep 3"
	IncPrivA4 = "Private income annual dep 4"
	IncPrivAu = "Private income annual"
	IncPrivFr = "Private income fortnightly ref"
	IncPrivFs = "Private income fortnightly sps"
	IncPrivF1 = "Private income fortnightly dep 1"
	IncPrivF2 = "Private income fortnightly dep 2"
	IncPrivF3 = "Private income fortnightly dep 3"
	IncPrivF4 = "Private income fortnightly dep 4"
	IncPrivFu = "Private income fortnightly inu"
	IncPrivFu = "Private income fortnightly"
	IncPrivLessWBFr = "Private income adjusted for work bonus ref"
	IncPrivLessWBFs = "Private income adjusted for work bonus sps"
	IncPrivLessWBF1 = "Private income adjusted for work bonus dep 1"
	IncPrivLessWBF2 = "Private income adjusted for work bonus dep 2"
	IncPrivLessWBF3 = "Private income adjusted for work bonus dep 3"
	IncPrivLessWBF4 = "Private income adjusted for work bonus dep 4"
	IncSupBonAr = "Income Support Bonus annual amount ref"
	IncSupBonAs = "Income Support Bonus annual amount sps"
	IncSupBonFr = "Income Support Bonus fortnightly amount ref"
	IncSupBonFs = "Income Support Bonus fortnightly amount sps"
	IncSupBonFlagr = "Income Support Bonus eligibility ref"
	IncSupBonFlags = "Income Support Bonus eligibility sps"
	IncTaxPrivAr = "Taxable component of private income (annual) ref"
	IncTaxPrivAs = "Taxable component of private income (annual) sps"
	IncTaxPrivA1 = "Taxable component of private income (annual) dep 1"
	IncTaxPrivA2 = "Taxable component of private income (annual) dep 2"
	IncTaxPrivA3 = "Taxable component of private income (annual) dep 3"
	IncTaxPrivA4 = "Taxable component of private income (annual) dep 4"
	IncTaxTranAr = "Taxable transfer payments annual ref"
	IncTaxTranAs = "Taxable transfer payments annual sps"
	IncTaxTranA1 = "Taxable transfer payments annual dep 1"
	IncTaxTranA2 = "Taxable transfer payments annual dep 2"
	IncTaxTranA3 = "Taxable transfer payments annual dep 3"
	IncTaxTranA4 = "Taxable transfer payments annual dep 4"
	IncTaxTranFr = "Total fortnightly taxable transfer payments  ref"
	IncTaxTranFs = "Total fortnightly taxable transfer payments  sps"
	IncTaxTranF1 = "Total fortnightly taxable transfer payments  dep 1"
	IncTaxTranF2 = "Total fortnightly taxable transfer payments  dep 2"
	IncTaxTranF3 = "Total fortnightly taxable transfer payments  dep 3"
	IncTaxTranF4 = "Total fortnightly taxable transfer payments  dep 4"
	IncTranAr = "Transfer income annual ref"
	IncTranAs = "Transfer income annual sps"
	IncTranA1 = "Transfer income annual dep 1"
	IncTranA2 = "Transfer income annual dep 2"
	IncTranA3 = "Transfer income annual dep 3"
	IncTranA4 = "Transfer income annual dep 4"
	IncTranAu = "Transfer income annual"
	IncTranFr = "Transfer income fortnight ref"
	IncTranFs = "Transfer income fortnight sps"
	IncTranF1 = "Transfer income fortnight dep 1"
	IncTranF2 = "Transfer income fortnight dep 2"
	IncTranF3 = "Transfer income fortnight dep 3"
	IncTranF4 = "Transfer income fortnight dep 4"
	IncTranFu = "Transfer income fortnight"
	IncWBFr = "Income test work bonus ref"
	IncWBFs = "Income test work bonus sps"
	IncWBF1 = "Income test work bonus dep 1"
	IncWBF2 = "Income test work bonus dep 2"
	IncWBF3 = "Income test work bonus dep 3"
	IncWBF4 = "Income test work bonus dep 4"
	Kids15u = "Number of dependents aged 15 in IU"
	LevyAndChargeAr = "Levies and charges annual ref"
	LevyAndChargeAs = "Levies and charges annual sps"
	LevyAndChargeA1 = "Levies and charges annual dep 1"
	LevyAndChargeA2 = "Levies and charges annual dep 2"
	LevyAndChargeA3 = "Levies and charges annual dep 3"
	LevyAndChargeA4 = "Levies and charges annual dep 4"
	LevyAndChargeFr = "Levies and charges fortnight ref"
	LevyAndChargeFs = "Levies and charges fortnight sps"
	LevyAndChargeF1 = "Levies and charges fortnight dep 1"
	LevyAndChargeF2 = "Levies and charges fortnight dep 2"
	LevyAndChargeF3 = "Levies and charges fortnight dep 3"
	LevyAndChargeF4 = "Levies and charges fortnight dep 4"
	LitoAr = "Low income tax offset annual ref"
	LitoAs = "Low income tax offset annual sps"
	LitoA1 = "Low income tax offset annual dep 1"
	LitoA2 = "Low income tax offset annual dep 2"
	LitoA3 = "Low income tax offset annual dep 3"
	LitoA4 = "Low income tax offset annual dep 4"
	LitoFr = "Low income tax offset fortnight ref"
	LitoFs = "Low income tax offset fortnight sps"
	LitoF1 = "Low income tax offset fortnight dep 1"
	LitoF2 = "Low income tax offset fortnight dep 2"
	LitoF3 = "Low income tax offset fortnight dep 3"
	LitoF4 = "Low income tax offset fortnight dep 4"
	LitoFlagr = "LITO eligibility ref"
	LitoFlags = "LITO eligibility sps"
	LitoFlag1 = "LITO eligibility dep 1"
	LitoFlag2 = "LITO eligibility dep 2"
	LitoFlag3 = "LITO eligibility dep 3"
	LitoFlag4 = "LITO eligibility dep 4"
	MawtoAr = "Mature age worker tax offset annual ref"
	MawtoAs = "Mature age worker tax offset annual sps"
	MawtoFr = "Mature age worker tax offset fortnight ref"
	MawtoFs = "Mature age worker tax offset fortnight sps"
	MawtoFlagr = "MAWTO eligibility ref"
	MawtoFlags = "MAWTO eligibility sps"
	MedLevAr = "Medicare levy annual ref"
	MedLevAs = "Medicare levy annual sps"
	MedLevA1 = "Medicare levy annual dep 1"
	MedLevA2 = "Medicare levy annual dep 2"
	MedLevA3 = "Medicare levy annual dep 3"
	MedLevA4 = "Medicare levy annual dep 4"
	MedLevAu = "Medicare levy annual"
	MedLevFr = "Medicare levy fortnight ref"
	MedLevFs = "Medicare levy fortnight sps"
	MedLevF1 = "Medicare levy fortnight dep 1"
	MedLevF2 = "Medicare levy fortnight dep 2"
	MedLevF3 = "Medicare levy fortnight dep 3"
	MedLevF4 = "Medicare levy fortnight dep 4"
	MedLevFamThrr = "Medciare levy family income threshold ref"
	MedLevFamThrs = "Medciare levy family income threshold sps"
	MedLevFamTyper = "Medicare levy family type ref"
	MedLevFamTypes = "Medicare levy family type sps"
	MedLevFu = "Medicare levy fortnight"
	MedLevIncAu = "Medicare levy family income annual"
	MedLevRedAr = "Medicare levy family reduction amount ref"
	MedLevRedAs = "Medicare levy family reduction amount sps"
	MedLevSurAr = "Medicare levy surcharge annual ref"
	MedLevSurAs = "Medicare levy surcharge annual sps"
	MedLevSurA1 = "Medicare levy surcharge annual dep 1"
	MedLevSurA2 = "Medicare levy surcharge annual dep 2"
	MedLevSurA3 = "Medicare levy surcharge annual dep 3"
	MedLevSurA4 = "Medicare levy surcharge annual dep 4"
	MedLevSurAu = "Medicare levy surcharge annual"
	MedLevSurFr = "Medicare levy surcharge fortnight ref"
	MedLevSurFs = "Medicare levy surcharge fortnight sps"
	MedLevSurF1 = "Medicare levy surcharge fortnight dep 1"
	MedLevSurF2 = "Medicare levy surcharge fortnight dep 2"
	MedLevSurF3 = "Medicare levy surcharge fortnight dep 3"
	MedLevSurF4 = "Medicare levy surcharge fortnight dep 4"
	MedLevSurRatePsnr = "Medicare levy surcharge rate ref"
	MedLevSurRatePsns = "Medicare levy surcharge rate sps"
	MedLevSurRatePsn1 = "Medicare levy surcharge rate dep 1"
	MedLevSurRatePsn2 = "Medicare levy surcharge rate dep 2"
	MedLevSurRatePsn3 = "Medicare levy surcharge rate dep 3"
	MedLevSurRatePsn4 = "Medicare levy surcharge rate dep 4"
	MedLevSurTier1Psnr = "Medicare levy surcharge Tier 1 ref"
	MedLevSurTier1Psns = "Medicare levy surcharge Tier 1 sps"
	MedLevSurTier1Psn1 = "Medicare levy surcharge Tier 1 dep 1"
	MedLevSurTier1Psn2 = "Medicare levy surcharge Tier 1 dep 2"
	MedLevSurTier1Psn3 = "Medicare levy surcharge Tier 1 dep 3"
	MedLevSurTier1Psn4 = "Medicare levy surcharge Tier 1 dep 4"
	MedLevSurTier2Psnr = "Medicare levy surcharge Tier 2 ref"
	MedLevSurTier2Psns = "Medicare levy surcharge Tier 2 sps"
	MedLevSurTier2Psn1 = "Medicare levy surcharge Tier 2 dep 1"
	MedLevSurTier2Psn2 = "Medicare levy surcharge Tier 2 dep 2"
	MedLevSurTier2Psn3 = "Medicare levy surcharge Tier 2 dep 3"
	MedLevSurTier2Psn4 = "Medicare levy surcharge Tier 2 dep 4"
	MedLevSurTier3Psnr = "Medicare levy surcharge Tier 3 ref"
	MedLevSurTier3Psns = "Medicare levy surcharge Tier 3 sps"
	MedLevSurTier3Psn1 = "Medicare levy surcharge Tier 3 dep 1"
	MedLevSurTier3Psn2 = "Medicare levy surcharge Tier 3 dep 2"
	MedLevSurTier3Psn3 = "Medicare levy surcharge Tier 3 dep 3"
	MedLevSurTier3Psn4 = "Medicare levy surcharge Tier 3 dep 4"
	MedLevSurTyper = "Medicare levy surcharge type ref"
	MedLevSurTypes = "Medicare levy surcharge type sps"
	MedLevSurType1 = "Medicare levy surcharge type dep 1"
	MedLevSurType2 = "Medicare levy surcharge type dep 2"
	MedLevSurType3 = "Medicare levy surcharge type dep 3"
	MedLevSurType4 = "Medicare levy surcharge type dep 4"
	MedLevThr1Psnr = "Medicare levy singles Threshold Amount ref"
	MedLevThr1Psns = "Medicare levy singles Threshold Amount sps"
	MedLevThr1Psn1 = "Medicare levy singles Threshold Amount dep 1"
	MedLevThr1Psn2 = "Medicare levy singles Threshold Amount dep 2"
	MedLevThr1Psn3 = "Medicare levy singles Threshold Amount dep 3"
	MedLevThr1Psn4 = "Medicare levy singles Threshold Amount dep 4"
	MedLevThr2Psnr = "Medicare levy singles Phase-In Limit ref"
	MedLevThr2Psns = "Medicare levy singles Phase-In Limit sps"
	MedLevThr2Psn1 = "Medicare levy singles Phase-In Limit dep 1"
	MedLevThr2Psn2 = "Medicare levy singles Phase-In Limit dep 2"
	MedLevThr2Psn3 = "Medicare levy singles Phase-In Limit dep 3"
	MedLevThr2Psn4 = "Medicare levy singles Phase-In Limit dep 4"
	MedLevTyper = "Medicare levy singles type ref"
	MedLevTypes = "Medicare levy singles type sps"
	MedLevType1 = "Medicare levy singles type dep 1"
	MedLevType2 = "Medicare levy singles type dep 2"
	MedLevType3 = "Medicare levy singles type dep 3"
	MedLevType4 = "Medicare levy singles type dep 4"
	MTRr = "Marginal tax rate ref"
	MTRs = "Marginal tax rate sps"
	MTR1 = "Marginal tax rate dep 1"
	MTR2 = "Marginal tax rate dep 2"
	MTR3 = "Marginal tax rate dep 3"
	MTR4 = "Marginal tax rate dep 4"
	NetIncTaxAr = "Net income tax annual ref"
	NetIncTaxAs = "Net income tax annual sps"
	NetIncTaxA1 = "Net income tax annual dep 1"
	NetIncTaxA2 = "Net income tax annual dep 2"
	NetIncTaxA3 = "Net income tax annual dep 3"
	NetIncTaxA4 = "Net income tax annual dep 4"
	NetIncTaxFr = "Net income tax fortnight ref"
	NetIncTaxFs = "Net income tax fortnight sps"
	NetIncTaxF1 = "Net income tax fortnight dep 1"
	NetIncTaxF2 = "Net income tax fortnight dep 2"
	NetIncTaxF3 = "Net income tax fortnight dep 3"
	NetIncTaxF4 = "Net income tax fortnight dep 4"
	NetIncWorkAr = "Net income from working (annual) ref"
	NetIncWorkAs = "Net income from working (annual) sps"
	NetIncWorkFr = "Net income from working (fortnightly) ref"
	NetIncWorkFs = "Net income from working (fortnightly) sps"
	NewBornUpfrontA = "Newborn upfront payment"
	NsaTotAu = "EMTR for NSA"
	NsaTotAu = "Total NSA annual"
	NsaTotFu = "Total NSA fortnight"
	NumCareSupr = "Number of Carer Supplements eligible ref"
	NumCareSups = "Number of Carer Supplements eligible sps"
	NumRates = "Number of tax rates"
	PartnerAllNmAr = "Partner Allowance received (annual) ref"
	PartnerAllNmAs = "Partner Allowance received (annual) sps"
	PartnerAllNmFr = "Partner Allowance received (fortnight) ref"
	PartnerAllNmFs = "Partner Allowance received (fortnight) sps"
	PayOrRefAmntAr = "Pay or refundable amount annual ref"
	PayOrRefAmntAs = "Pay or refundable amount annual sps"
	PayOrRefAmntA1 = "Pay or refundable amount annual dep 1"
	PayOrRefAmntA2 = "Pay or refundable amount annual dep 2"
	PayOrRefAmntA3 = "Pay or refundable amount annual dep 3"
	PayOrRefAmntA4 = "Pay or refundable amount annual dep 4"
	PayOrRefAmntAu = "Pay or refundable amount annual"
	PayOrRefAmntFr = "Pay or refundable amount fortnight ref"
	PayOrRefAmntFs = "Pay or refundable amount fortnight sps"
	PayOrRefAmntF1 = "Pay or refundable amount fortnight dep 1"
	PayOrRefAmntF2 = "Pay or refundable amount fortnight dep 2"
	PayOrRefAmntF3 = "Pay or refundable amount fortnight dep 3"
	PayOrRefAmntF4 = "Pay or refundable amount fortnight dep 4"
	PayOrRefAmntFu = "Pay or refundable amount fortnight"
	PenBasicFr = "Final basic pension amount ref"
	PenBasicFs = "Final basic pension amount sps"
	PenBasicMaxF = "Maximum basic pension rate"
	PenEdSupAr = "Pensioner Education Supplement annual amount ref"
	PenEdSupAs = "Pensioner Education Supplement annual amount sps"
	PenEdSupFr = "Pensioner Education Supplement fortnightly amount ref"
	PenEdSupFs = "Pensioner Education Supplement fortnightly amount sps"
	PenEdSupFlagr = "Pensioner Education Supplement eligibility ref"
	PenEdSupFlags = "Pensioner Education Supplement eligibility sps"
	PenEsFr = "Energy Supplement final amount ref"
	PenEsFs = "Energy Supplement final amount sps"
	PenEsMaxFr = "Energy Supplement pension parameter ref"
	PenEsMaxFs = "Energy Supplement pension parameter sps"
	PenRateTyper = "Pension rate type ref"
	PenRateTypes = "Pension rate type  sps"
	PenRedF = "Pension reduction for means test"
	PenSupBasicFr = "Pension supplement basic amount ref"
	PenSupBasicFs = "Pension supplement basic amount sps"
	PenSupBasicMaxF = "Pension supplement basic amount"
	PenSupMinFr = "Pension supplement minimum fortnightly ref"
	PenSupMinFs = "Pension supplement minimum fortnightly sps"
	PenSupMinMaxF = "Pension supplement minimum for income unit fortnightly"
	PenSupRemFr = "Pension supplement remaining fortnightly ref"
	PenSupRemFs = "Pension supplement remaining fortnightly sps"
	PenSupRemMaxF = "Pension supplement remaining for income unit fortnightly"
	PenThrF = "Pension income test threshold for income unit"
	PenTotAr = "Total pension annual ref"
	PenTotAs = "Total pension annual sps"
	PenTotA1 = "Total pension annual dep 1"
	PenTotA2 = "Total pension annual dep 2"
	PenTotA3 = "Total pension annual dep 3"
	PenTotA4 = "Total pension annual dep 4"
	PenTotAu = "Total annual pension EMTR"
	PenTotAu = "Total Pensions annual"
	PenTotFr = "Total pension fortnight ref"
	PenTotFs = "Total pension fortnight sps"
	PenTotF1 = "Total pension fortnight dep 1"
	PenTotF2 = "Total pension fortnight dep 2"
	PenTotF3 = "Total pension fortnight dep 3"
	PenTotF4 = "Total pension fortnight dep 4"
	PenTotFu = "Total fortnightly pension EMTR"
	PenTotFu = "Total Pensions fortnight"
	PenTpr = "Pension taper for income unit"
	PenTyper = "Type of pension received ref"
	PenTypes = "Type of pension received sps"
	PenType1 = "Type of pension received dep 1"
	PenType2 = "Type of pension received dep 2"
	PenType3 = "Type of pension received dep 3"
	PenType4 = "Type of pension received dep 4"
	PharmAllFr = "Pharm Allowance final amount ref"
	PharmAllFs = "Pharm Allowance final amount sps"
	PharmAllF1 = "Pharm Allowance final amount dep 1"
	PharmAllF2 = "Pharm Allowance final amount dep 2"
	PharmAllF3 = "Pharm Allowance final amount dep 3"
	PharmAllF4 = "Pharm Allowance final amount dep 4"
	PharmAllMaxF = "Pharmaceutical allowance parameter"
	PharmAllMaxFr = "Pharmaceutical allowance parameter ref"
	PharmAllMaxFs = "Pharmaceutical allowance parameter sps"
	PharmAllMaxF1 = "Pharmaceutical allowance parameter dep 1"
	PharmAllMaxF2 = "Pharmaceutical allowance parameter dep 2"
	PharmAllMaxF3 = "Pharmaceutical allowance parameter dep 3"
	PharmAllMaxF4 = "Pharmaceutical allowance parameter dep 4"
	PppTotAu = "EMTR for PPP"
	PppTotAu = "Total PPP annual"
	PppTotFu = "Total PPP fortnight"
	PpsPenBasicAr = "Basic annual PPS ref"
	PpsPenBasicFr = "Basic fortnightly PPS ref"
	PpsPenEsAr = "Energy supplement paid annually with PPS ref"
	PpsPenEsFr = "Energy supplement paid fortnightly with PPS ref"
	PpsPenSupBasicAr = "Final pension supplement paid annually with PPS ref"
	PpsPenSupBasicFr = "Final pension supplement paid fortnightly with PPS ref"
	PpsPenSupMinFr = "Fortnightly minimum pension supplement for PPS ref"
	PpsPenSupRemFr = "Fortnightly minimum pension supplement for PPS ref"
	PpsPharmAllAr = "Pharm Allowance annual for PPS ref"
	PpsPharmAllFr = "Pharm Allowance fortnightly for PPS ref"
	PpsRAssAr = "Rent Assistance annual for PPS ref"
	PpsRAssFr = "Rent Assistance fortnightly for PPS ref"
	PpsTotAr = "Total annual PPS ref"
	PpsTotAu = "Total annual PPS"
	PpsTotFr = "Total fortnightly PPS ref"
	PpsTotFu = "Total fortnightly PPS"
	RAssAr = "Final Rent Assistance amount per annum ref"
	RAssAs = "Final Rent Assistance amount per annum sps"
	RAssA1 = "Final Rent Assistance amount per annum dep 1"
	RAssA2 = "Final Rent Assistance amount per annum dep 2"
	RAssA3 = "Final Rent Assistance amount per annum dep 3"
	RAssA4 = "Final Rent Assistance amount per annum dep 4"
	RAssFr = "Final Rent Assistance amount per fortnight ref"
	RAssFs = "Final Rent Assistance amount per fortnight sps"
	RAssF1 = "Final Rent Assistance amount per fortnight dep 1"
	RAssF2 = "Final Rent Assistance amount per fortnight dep 2"
	RAssF3 = "Final Rent Assistance amount per fortnight dep 3"
	RAssF4 = "Final Rent Assistance amount per fortnight dep 4"
	RAssMaxFu = "Maximum Rent Assistance amount for income unit"
	RAssMaxPossFr = "Maximum possible Rent Assistance for person ref"
	RAssMaxPossFs = "Maximum possible Rent Assistance for person sps"
	RAssMaxPossF1 = "Maximum possible Rent Assistance for person dep 1"
	RAssMaxPossF2 = "Maximum possible Rent Assistance for person dep 2"
	RAssMaxPossF3 = "Maximum possible Rent Assistance for person dep 3"
	RAssMaxPossF4 = "Maximum possible Rent Assistance for person dep 4"
	RAssMaxPossFr_ = "Maximum Rent Assistance amount for person"
	RAssMinRentFu = "Minimum rent eligibility for Rent Assistance"
	RebBftAr = "Rebatable benefit (annual) ref"
	RebBftAs = "Rebatable benefit (annual) sps"
	RebBftA1 = "Rebatable benefit (annual) dep 1"
	RebBftA2 = "Rebatable benefit (annual) dep 2"
	RebBftA3 = "Rebatable benefit (annual) dep 3"
	RebBftA4 = "Rebatable benefit (annual) dep 4"
	RebBftFr = "Rebatable benefit (fortnightly) ref"
	RebBftFs = "Rebatable benefit (fortnightly) sps"
	RebBftF1 = "Rebatable benefit (fortnightly) dep 1"
	RebBftF2 = "Rebatable benefit (fortnightly) dep 2"
	RebBftF3 = "Rebatable benefit (fortnightly) dep 3"
	RebBftF4 = "Rebatable benefit (fortnightly) dep 4"
	RebIncAr = "Annual rebate income ref"
	RebIncAs = "Annual rebate income sps"
	RebIncAu = "Rebate Income for couple"
	RebIncFr = "Fortnightly rebate income ref"
	RebIncFs = "Fortnightly rebate income sps"
	SaptoAr = "Seniors and Australian Pensioners Tax Offset annual ref"
	SaptoAs = "Seniors and Australian Pensioners Tax Offset annual sps"
	SaptoCutOutPsnr = "SAPTO cut out threshold ref"
	SaptoCutOutPsns = "SAPTO cut out threshold sps"
	SaptoFr = "Seniors and Australian Pensioners Tax Offset fortnight ref"
	SaptoFs = "Seniors and Australian Pensioners Tax Offset fortnight sps"
	SaptoMaxPsnr = "SAPTO Rebate Amount ref"
	SaptoMaxPsns = "SAPTO Rebate Amount sps"
	SaptoRebThrPsnr = "SAPTO Rebate Threshold ref"
	SaptoRebThrPsns = "SAPTO Rebate Threshold sps"
	SaptoTyper = "SAPTO eligibility ref"
	SaptoTypes = "SAPTO eligibility sps"
	SenSupAr = "Seniors Supplement annual amount ref"
	SenSupAs = "Seniors Supplement annual amount sps"
	SenSupEsAr = "Seniors Supplement Energy Supplement annual amount ref"
	SenSupEsAs = "Seniors Supplement Energy Supplement annual amount sps"
	SenSupEsFr = "Seniors Supplement Energy Supplement fortnightly amount ref"
	SenSupEsFs = "Seniors Supplement Energy Supplement fortnightly amount sps"
	SenSupFr = "Seniors Supplement fortnightly amount ref"
	SenSupFs = "Seniors Supplement fortnightly amount sps"
	SenSupFlagr = "Seniors Supplement eligibility ref"
	SenSupFlags = "Seniors Supplement eligibility sps"
	SenSupQr = "Seniors Supplement quarterly amount ref"
	SenSupQs = "Seniors Supplement quarterly amount sps"
	SenSupTotAr = "Total Seniors Supplement (including Energy Supplement) annual amount ref"
	SenSupTotAs = "Total Seniors Supplement (including Energy Supplement) annual amount sps"
	SenSupTotFr = "Total Seniors Supplement (including Energy Supplement) fortnightly amount 
	ref"
	SenSupTotFs = "Total Seniors Supplement (including Energy Supplement) fortnightly amount 
	sps"
	ServicePenBasicAr = "Basic annual DVA Service Pension ref"
	ServicePenBasicAs = "Basic annual DVA Service Pension sps"
	ServicePenBasicFr = "Basic fortnightly DVA Service Pension ref"
	ServicePenBasicFs = "Basic fortnightly DVA Service Pension sps"
	ServicePenEsAr = "Energy supplement paid annually with DVA Service Pension ref"
	ServicePenEsAs = "Energy supplement paid annually with DVA Service Pension sps"
	ServicePenEsFr = "Energy supplement paid fortnightly with DVA Service Pension ref"
	ServicePenEsFs = "Energy supplement paid fortnightly with DVA Service Pension sps"
	ServicePenSupBasicAr = "Final pension supplement paid annually with DVA Service Pension 
	ref"
	ServicePenSupBasicAs = "Final pension supplement paid annually with DVA Service Pension 
	sps"
	ServicePenSupBasicFr = "Final pension supplement paid fortnightly with DVA Service Pension 
	ref"
	ServicePenSupBasicFs = "Final pension supplement paid fortnightly with DVA Service Pension 
	sps"
	ServicePenSupMinAr = "Annual minimum pension supplement for DVA Service pension ref"
	ServicePenSupMinAs = "Annual minimum pension supplement for DVA Service pension sps"
	ServicePenSupMinFr = "Fortnightly minimum pension supplement for DVA Service pension ref"
	ServicePenSupMinFs = "Fortnightly minimum pension supplement for DVA Service pension sps"
	ServicePenSupRemAr = "Annual remaining pension supplement for DVA Service pension ref"
	ServicePenSupRemAs = "Annual remaining pension supplement for DVA Service pension sps"
	ServicePenSupRemFr = "Fortnightly remaining pension supplement for DVA Service pension 
	ref"
	ServicePenSupRemFs = "Fortnightly remaining pension supplement for DVA Service pension 
	sps"
	ServiceRAssAr = "Rent Assistance annual for DVA Service Pension ref"
	ServiceRAssAs = "Rent Assistance annual for DVA Service Pension sps"
	ServiceRAssFr = "Rent Assistance fortnightly for DVA Service Pension ref"
	ServiceRAssFs = "Rent Assistance fortnightly for DVA Service Pension sps"
	ServiceTotAr = "Total annual DVA Service Pension ref"
	ServiceTotAs = "Total annual DVA Service Pension sps"
	ServiceTotAu = "Total annual DVA Service Pension"
	ServiceTotFr = "Total fortnightly DVA Service Pension ref"
	ServiceTotFs = "Total fortnightly DVA Service Pension sps"
	ServiceTotFu = "Total fortnightly DVA Service Pension"
	SickAllNmAr = "Sickness Allowance received (annual) ref"
	SickAllNmAs = "Sickness Allowance received (annual) sps"
	SickAllNmFr = "Sickness Allowance received (fortnight) ref"
	SickAllNmFs = "Sickness Allowance received (fortnight) sps"
	SifsA = "Single Income Family Supplement amount for income unit"
	SifsAr = "Single Income Family Supplement annual amount ref"
	SifsAs = "Single Income Family Supplement annual amount sps"
	SifsFr = "Single Income Family Supplement fortnightly amount ref"
	SifsFs = "Single Income Family Supplement fortnightly amount sps"
	SifsFlag = "Single Income Family Supplement eligibility of income unit"
	SifsPrimFlagr = "Single Income Family Supplement eligibility of primary carer ref"
	SifsPrimFlags = "Single Income Family Supplement eligibility of primary carer sps"
	SingPrinCareFlag = "Single principle carer"
	SKBonusAr = "Schoolkids bonus annual ref"
	SKBonusAs = "Schoolkids bonus annual sps"
	SKBonusFr = "Schoolkids bonus fortnightly ref"
	SKBonusFs = "Schoolkids bonus fortnightly sps"
	SpbAllNmAr = "Special Benefit received (annual) ref"
	SpbAllNmAs = "Special Benefit received (annual) sps"
	SpbAllNmFr = "Special Benefit received (fortnight) ref"
	SpbAllNmFs = "Special Benefit received (fortnight) sps"
	SuperToAr = "Superannuation tax offset annual ref"
	SuperToAs = "Superannuation tax offset annual sps"
	SuperToFr = "Superannuation tax offset fortnight ref"
	SuperToFs = "Superannuation tax offset fortnight sps"
	SupTotAr = "Total annual supplements ref"
	SupTotAs = "Total annual supplements sps"
	SupTotAu = "Total Supplements annual"
	SupTotFr = "Total fortnightly supplements ref"
	SupTotFs = "Total fortnightly supplements sps"
	SupTotFu = "Total fortnightly supplements"
	TakeXSaptoAr = "Transferred SAPTO ref"
	TakeXSaptoAs = "Transferred SAPTO sps"
	TaxIncAr = "Annual taxable income ref"
	TaxIncAs = "Annual taxable income sps"
	TaxIncA1 = "Annual taxable income dep 1"
	TaxIncA2 = "Annual taxable income dep 2"
	TaxIncA3 = "Annual taxable income dep 3"
	TaxIncA4 = "Annual taxable income dep 4"
	TaxIncAu = "Taxable income annual"
	TaxIncFr = "Fortnightly taxable income ref"
	TaxIncFs = "Fortnightly taxable income sps"
	TaxIncF1 = "Fortnightly taxable income dep 1"
	TaxIncF2 = "Fortnightly taxable income dep 2"
	TaxIncF3 = "Fortnightly taxable income dep 3"
	TaxIncF4 = "Fortnightly taxable income dep 4"
	TaxIncFu = "Taxable income fortnight"
	TaxIncPAr = "Previous year taxable income ref"
	TaxIncPAs = "Previous year taxable income sps"
	TelAllAr = "Telephone allowance annual ref"
	TelAllAs = "Telephone allowance annual sps"
	TelAllFr = "Telephone Allowance fortnightly amount ref"
	TelAllFs = "Telephone Allowance fortnightly amount sps"
	TelAllFlagr = "Telephone Allowance eligibility ref"
	TelAllFlags = "Telephone Allowance eligibility sps"
	TelAllHighFlagr = "Telephone Allowance (high rate) eligibility ref"
	TelAllHighFlags = "Telephone Allowance (high rate) eligibility sps"
	TelAllLowFlagr = "Telephone Allowance (low rate) eligibility ref"
	TelAllLowFlags = "Telephone Allowance (low rate) eligibility sps"
	TempBudgRepLevAr = "Temporary Budget Repair Levy annual ref"
	TempBudgRepLevAs = "Temporary Budget Repair Levy annual sps"
	TempBudgRepLevA1 = "Temporary Budget Repair Levy annual dep 1"
	TempBudgRepLevA2 = "Temporary Budget Repair Levy annual dep 2"
	TempBudgRepLevA3 = "Temporary Budget Repair Levy annual dep 3"
	TempBudgRepLevA4 = "Temporary Budget Repair Levy annual dep 4"
	TempBudgRepLevAu = "Temporary Budget Repair Levy annual"
	TempBudgRepLevFr = "Temporary Budget Repair Levy fortnight ref"
	TempBudgRepLevFs = "Temporary Budget Repair Levy fortnight sps"
	TempBudgRepLevF1 = "Temporary Budget Repair Levy fortnight dep 1"
	TempBudgRepLevF2 = "Temporary Budget Repair Levy fortnight dep 2"
	TempBudgRepLevF3 = "Temporary Budget Repair Levy fortnight dep 3"
	TempBudgRepLevF4 = "Temporary Budget Repair Levy fortnight dep 4"
	TempBudgRepLevFu = "Temporary Budget Repair Levy fortnight"
	TotTaxOffsetAr = "Total tax offset entitlement annual ref"
	TotTaxOffsetAs = "Total tax offset entitlement annual sps"
	TotTaxOffsetA1 = "Total tax offset entitlement annual dep 1"
	TotTaxOffsetA2 = "Total tax offset entitlement annual dep 2"
	TotTaxOffsetA3 = "Total tax offset entitlement annual dep 3"
	TotTaxOffsetA4 = "Total tax offset entitlement annual dep 4"
	TotTaxOffsetAu = "Total tax offset annual"
	TotTaxOffsetFr = "Total tax offset entitlement fortnight ref"
	TotTaxOffsetFs = "Total tax offset entitlement fortnight sps"
	TotTaxOffsetF1 = "Total tax offset entitlement fortnight dep 1"
	TotTaxOffsetF2 = "Total tax offset entitlement fortnight dep 2"
	TotTaxOffsetF3 = "Total tax offset entitlement fortnight dep 3"
	TotTaxOffsetF4 = "Total tax offset entitlement fortnight dep 4"
	TotTaxOffsetFu = "Total tax offset fortnight"
	UsedBentoAr = "Used BENTO annual ref"
	UsedBentoAs = "Used BENTO annual sps"
	UsedBentoA1 = "Used BENTO annual dep 1"
	UsedBentoA2 = "Used BENTO annual dep 2"
	UsedBentoA3 = "Used BENTO annual dep 3"
	UsedBentoA4 = "Used BENTO annual dep 4"
	UsedBentoAu = "Used BENTO annual"
	UsedBentoFr = "Used BENTO fortnight ref"
	UsedBentoFs = "Used BENTO fortnight sps"
	UsedBentoF1 = "Used BENTO fortnight dep 1"
	UsedBentoF2 = "Used BENTO fortnight dep 2"
	UsedBentoF3 = "Used BENTO fortnight dep 3"
	UsedBentoF4 = "Used BENTO fortnight dep 4"
	UsedBentoFu = "Used BENTO fortnight"
	UsedFrankCrAr = "Used Franking credit annual ref"
	UsedFrankCrAs = "Used Franking credit annual sps"
	UsedFrankCrA1 = "Used Franking credit annual dep 1"
	UsedFrankCrA2 = "Used Franking credit annual dep 2"
	UsedFrankCrA3 = "Used Franking credit annual dep 3"
	UsedFrankCrA4 = "Used Franking credit annual dep 4"
	UsedFrankCrFr = "Used Franking credit fortnight ref"
	UsedFrankCrFs = "Used Franking credit fortnight sps"
	UsedFrankCrF1 = "Used Franking credit fortnight dep 1"
	UsedFrankCrF2 = "Used Franking credit fortnight dep 2"
	UsedFrankCrF3 = "Used Franking credit fortnight dep 3"
	UsedFrankCrF4 = "Used Franking credit fortnight dep 4"
	UsedItem20Ar = "Used Item 20 tax offsets annual ref"
	UsedItem20As = "Used Item 20 tax offsets annual sps"
	UsedItem20Au = "Used Item 20 tax offsets annual"
	UsedItem20Fr = "Used Item 20 tax offsets fortnight ref"
	UsedItem20Fs = "Used Item 20 tax offsets fortnight sps"
	UsedItem20Fu = "Used Item 20 tax offsets fortnight"
	UsedLitoAr = "Used LITO annual ref"
	UsedLitoAs = "Used LITO annual sps"
	UsedLitoA1 = "Used LITO annual dep 1"
	UsedLitoA2 = "Used LITO annual dep 2"
	UsedLitoA3 = "Used LITO annual dep 3"
	UsedLitoA4 = "Used LITO annual dep 4"
	UsedLitoAu = "Used LITO annual"
	UsedLitoFr = "Used LITO fortnight ref"
	UsedLitoFs = "Used LITO fortnight sps"
	UsedLitoF1 = "Used LITO fortnight dep 1"
	UsedLitoF2 = "Used LITO fortnight dep 2"
	UsedLitoF3 = "Used LITO fortnight dep 3"
	UsedLitoF4 = "Used LITO fortnight dep 4"
	UsedLitoFu = "Used LITO fortnight"
	UsedSaptoAr = "Used SAPTO annual ref"
	UsedSaptoAs = "Used SAPTO annual sps"
	UsedSaptoAu = "Used SAPTO annual"
	UsedSaptoFr = "Used SAPTO fortnight ref"
	UsedSaptoFs = "Used SAPTO fortnight sps"
	UsedSaptoFu = "Used SAPTO annual"
	UsedTotTaxOffsetAr = "Used total tax offsets annual ref"
	UsedTotTaxOffsetAs = "Used total tax offsets annual sps"
	UsedTotTaxOffsetA1 = "Used total tax offsets annual dep 1"
	UsedTotTaxOffsetA2 = "Used total tax offsets annual dep 2"
	UsedTotTaxOffsetA3 = "Used total tax offsets annual dep 3"
	UsedTotTaxOffsetA4 = "Used total tax offsets annual dep 4"
	UsedTotTaxOffsetAu = "Used total tax offsets annual"
	UsedTotTaxOffsetFr = "Used total tax offsets fortnight ref"
	UsedTotTaxOffsetFs = "Used total tax offsets fortnight sps"
	UsedTotTaxOffsetF1 = "Used total tax offsets fortnight dep 1"
	UsedTotTaxOffsetF2 = "Used total tax offsets fortnight dep 2"
	UsedTotTaxOffsetF3 = "Used total tax offsets fortnight dep 3"
	UsedTotTaxOffsetF4 = "Used total tax offsets fortnight dep 4"
	UsedTotTaxOffsetFu = "Used total tax offsets fortnight"
	UtilitiesAllAr = "Utilities Allowance annual ref"
	UtilitiesAllAs = "Utilities Allowance annual sps"
	UtilitiesAllFr = "Utilities Allowance fortnightly ref"
	UtilitiesAllFs = "Utilities Allowance fortnightly sps"
	UtilitiesAllFlagr = "Utilities Allowance eligibility ref"
	UtilitiesAllFlags = "Utilities Allowance eligibility sps"
	WidowTotAu = "EMTR for Widow payment"
	WidowTotAu = "Total Widow pension annual"
	WidowTotFu = "Total Widow pension fortnight"
	WifePenBasicAs = "Basic annual Wife Pension sps"
	WifePenBasicFs = "Basic fortnightly Wife Pension sps"
	WifePenEsAs = "Energy supplement paid annually with Wife Pension sps"
	WifePenEsFs = "Energy supplement paid fortnightly with Wife Pension sps"
	WifePenSupBasicAs = "Final pension supplement paid annually with Wife Pension sps"
	WifePenSupBasicFs = "Final pension supplement paid fortnightly with Wife Pension sps"
	WifePenSupMinAs = "Annual minimum pension supplement for Wife pension sps"
	WifePenSupMinFs = "Fortnightly minimum pension supplement for Wife pension sps"
	WifePenSupRemAs = "Annual remaining pension supplement for Wife pension sps"
	WifePenSupRemFs = "Fortnightly remaining pension supplement for Wife pension sps"
	WifePharmAllFs = "Pharm Allowance fortnightly for Wife Pension sps"
	WifeRAssAs = "Rent Assistance annual for Wife Pension sps"
	WifeRAssFs = "Rent Assistance fortnightly for Wife Pension sps"
	WifeTotAs = "Total annual Wife Pension sps"
	WifeTotAu = "Total annual Wife Pension"
	WifeTotFs = "Total fortnightly Wife Pension sps"
	WifeTotFu = "Total fortnightly Wife Pension"
	XMedLevRedAr = "Excess Medicare levy family reduction annual ref"
	XMedLevRedAs = "Excess Medicare levy family reduction annual sps"
	XRefTaxOffsetAr = "Total refundable tax offset annual ref"
	XRefTaxOffsetAs = "Total refundable tax offset annual sps"
	XRefTaxOffsetA1 = "Total refundable tax offset annual dep 1"
	XRefTaxOffsetA2 = "Total refundable tax offset annual dep 2"
	XRefTaxOffsetA3 = "Total refundable tax offset annual dep 3"
	XRefTaxOffsetA4 = "Total refundable tax offset annual dep 4"
	XRefTaxOffsetAu = "Total refundable tax offset annual"
	XRefTaxOffsetFr = "Total refundable tax offset fortnight ref"
	XRefTaxOffsetFs = "Total refundable tax offset fortnight sps"
	XRefTaxOffsetF1 = "Total refundable tax offset fortnight dep 1"
	XRefTaxOffsetF2 = "Total refundable tax offset fortnight dep 2"
	XRefTaxOffsetF3 = "Total refundable tax offset fortnight dep 3"
	XRefTaxOffsetF4 = "Total refundable tax offset fortnight dep 4"
	XRefTaxOffsetFu = "Total refundable tax offset fortnight"
	YaOtherTotAu = "EMTR for Youth Allowance (other)"
	YaOtherTotAu = "Total YA Other annual"
	YaOtherTotFu = "Total YA Other fortnight"
	YaStudTotAu = "EMTR for Youth Allowance (student)"
	YaStudTotAu = "Total YA Student annual"
	YaStudTotFu = "Total YA Student fortnight"
	IncNonTaxTranFr = "Non taxable transfer income fortnight ref"
	IncNonTaxTranFs = "Non taxable transfer income fortnight sps"
	IncNonTaxTranF1 = "Non taxable transfer income fortnight dep 1"
	IncNonTaxTranF2 = "Non taxable transfer income fortnight dep 2"
	IncNonTaxTranF3 = "Non taxable transfer income fortnight dep 3"
	IncNonTaxTranF4 = "Non taxable transfer income fortnight dep 4"
	MedLevSurFu = "Medicare levy surcharge fortnight"

/* ### The following are in the variable register as basefile but also used in cameo capita_outfile */

	ActualAger = "Age ref"
	ActualAges = "Age sps"
	ActualAge1 = "Age dep 1"
	ActualAge2 = "Age dep 2"
	ActualAge3 = "Age dep 3"
	ActualAge4 = "Age dep 4"			
	AdjFbAr = "Adjusted fringe benefits (annual) ref"
	AdjFbAs = "Adjusted fringe benefits (annual) sps"
	AdjFbA1 = "Adjusted fringe benefits (annual) dep 1"
	AdjFbA2 = "Adjusted fringe benefits (annual) dep 2"
	AdjFbA3 = "Adjusted fringe benefits (annual) dep 3"
	AdjFbA4 = "Adjusted fringe benefits (annual) dep 4"
	AdjFbFr = "Adjusted fringe benefits (fortnightly) ref"
	AdjFbFs = "Adjusted fringe benefits (fortnightly) sps"
	AdjFbF1 = "Adjusted fringe benefits (fortnightly) dep 1"
	AdjFbF2 = "Adjusted fringe benefits (fortnightly) dep 2"
	AdjFbF3 = "Adjusted fringe benefits (fortnightly) dep 3"
	AdjFbF4 = "Adjusted fringe benefits (fortnightly) dep 4"
	AdjFbPAr = "Adjusted fringe benefits (previous year) ref"
	AdjFbPAs = "Adjusted fringe benefits (previous year) sps"
	AdjFbPA1 = "Adjusted fringe benefits (previous year) dep 1"
	AdjFbPA2 = "Adjusted fringe benefits (previous year) dep 2"
	AdjFbPA3 = "Adjusted fringe benefits (previous year) dep 3"
	AdjFbPA4 = "Adjusted fringe benefits (previous year) dep 4"
	AgePenSWr = "Income from age pension on the SIH (weekly) ref"
	AgePenSWs = "Income from age pension on the SIH (weekly) sps"
	AgeYoungDepu = "Age of youngest dependant"
	AustudySWr = "Income from austudy on the SIH (weekly) ref"
	AustudySWs = "Income from austudy on the SIH (weekly) sps"
	AustudySW1 = "Income from austudy on the SIH (weekly) dep 1"
	AustudySW2 = "Income from austudy on the SIH (weekly) dep 2"
	AustudySW3 = "Income from austudy on the SIH (weekly) dep 3"
	AustudySW4 = "Income from austudy on the SIH (weekly) dep 4"
	CarerAllSWr = "Income from carer allowance on the SIH (weekly) ref"
	CarerAllSWs = "Income from carer allowance on the SIH (weekly) sps"
	CarerPaySWr = "Income from carer payment on the SIH (weekly) ref"
	CarerPaySWs = "Income from carer payment on the SIH (weekly) sps"
	Coupleu = "Couple Flag"
	DeductionAr = "Deductions (annually) ref"
	DeductionAs = "Deductions (annually) sps"
	DeductionA1 = "Deductions (annually) dep 1"
	DeductionA2 = "Deductions (annually) dep 2"
	DeductionA3 = "Deductions (annually) dep 3"
	DeductionA4 = "Deductions (annually) dep 4"
	DeductionFr = "Deductions (fortnightly) ref"
	DeductionFs = "Deductions (fortnightly) sps"
	DeductionF1 = "Deductions (fortnightly) dep 1"
	DeductionF2 = "Deductions (fortnightly) dep 2"
	DeductionF3 = "Deductions (fortnightly) dep 3"
	DeductionF4 = "Deductions (fortnightly) dep 4"
	DeductionPAr = "Deductions (previous year) ref"
	DeductionPAs = "Deductions (previous year) sps"
	DeductionPA1 = "Deductions (previous year) dep 1"
	DeductionPA2 = "Deductions (previous year) dep 2"
	DeductionPA3 = "Deductions (previous year) dep 3"
	DeductionPA4 = "Deductions (previous year) dep 4"
	DeductionWrkAr = "Work related deductions (annually) ref"
	DeductionWrkAs = "Work related deductions (annually) sps"
	DeductionWrkA1 = "Work related deductions (annually) dep 1"
	DeductionWrkA2 = "Work related deductions (annually) dep 2"
	DeductionWrkA3 = "Work related deductions (annually) dep 3"
	DeductionWrkA4 = "Work related deductions (annually) dep 4"
	DspSWr = "Income from disability support pension on the SIH (weekly) ref"
	DspSWs = "Income from disability support pension on the SIH (weekly) sps"
	DspSW1 = "Income from disability support pension on the SIH (weekly) dep 1"
	DspSW2 = "Income from disability support pension on the SIH (weekly) dep 2"
	DspSW3 = "Income from disability support pension on the SIH (weekly) dep 3"
	DspSW4 = "Income from disability support pension on the SIH (weekly) dep 4"
	DvaDisPenSWr = "Income from DVA disability pension on the SIH (weekly) ref"
	DvaDisPenSWs = "Income from DVA disability pension on the SIH (weekly) sps"
	DvaSPenSWr = "Income from DVA service pension on the SIH (weekly) ref"
	DvaSPenSWs = "Income from DVA service pension on the SIH (weekly) sps"
	DvaWWPenSWr = "Income from DVA war widow pension on the SIH (weekly) ref"
	DvaWWPenSWs = "Income from DVA war widow pension on the SIH (weekly) sps"
	FamID = "Family identifier"
	FrankCrImpAr = "Franking credits (annual) ref"
	FrankCrImpAs = "Franking credits (annual) sps"
	FrankCrImpA1 = "Franking credits (annual) dep 1"
	FrankCrImpA2 = "Franking credits (annual) dep 2"
	FrankCrImpA3 = "Franking credits (annual) dep 3"
	FrankCrImpA4 = "Franking credits (annual) dep 4"
	FrankCrImpFr = "Franking credits (fortnightly) ref"
	FrankCrImpFs = "Franking credits (fortnightly) sps"
	FrankCrImpF1 = "Franking credits (fortnightly) dep 1"
	FrankCrImpF2 = "Franking credits (fortnightly) dep 2"
	FrankCrImpF3 = "Franking credits (fortnightly) dep 3"
	FrankCrImpF4 = "Franking credits (fortnightly) dep 4"
	FrankCrImpPAr = "Franking credits (previous year) ref"
	FrankCrImpPAs = "Franking credits (previous year) sps"
	FrankCrImpPA1 = "Franking credits (previous year) dep 1"
	FrankCrImpPA2 = "Franking credits (previous year) dep 2"
	FrankCrImpPA3 = "Franking credits (previous year) dep 3"
	FrankCrImpPA4 = "Franking credits (previous year) dep 4"
	FrankCrImpWr = "Franking credits (weekly) ref"
	FrankCrImpWs = "Franking credits (weekly) sps"
	FrankCrImpW1 = "Franking credits (weekly) dep 1"
	FrankCrImpW2 = "Franking credits (weekly) dep 2"
	FrankCrImpW3 = "Franking credits (weekly) dep 3"
	FrankCrImpW4 = "Franking credits (weekly) dep 4"
	IncBusLExpSAr = "Business income (annual) ref"
	IncBusLExpSAs = "Business income (annual) sps"
	IncBusLExpSA1 = "Business income (annual) dep 1"
	IncBusLExpSA2 = "Business income (annual) dep 2"
	IncBusLExpSA3 = "Business income (annual) dep 3"
	IncBusLExpSA4 = "Business income (annual) dep 4"
	IncBusLExpSPAr = "Business income (previous year) ref"
	IncBusLExpSPAs = "Business income (previous year) sps"
	IncBusLExpSPA1 = "Business income (previous year) dep 1"
	IncBusLExpSPA2 = "Business income (previous year) dep 2"
	IncBusLExpSPA3 = "Business income (previous year) dep 3"
	IncBusLExpSPA4 = "Business income (previous year) dep 4"
	IncBusLExpSWr = "Business income (weekly) ref"
	IncBusLExpSWs = "Business income (weekly) sps"
	IncBusLExpSW1 = "Business income (weekly) dep 1"
	IncBusLExpSW2 = "Business income (weekly) dep 2"
	IncBusLExpSW3 = "Business income (weekly) dep 3"
	IncBusLExpSW4 = "Business income (weekly) dep 4"
	IncDivSAr = "Income from dividends (annually) ref"
	IncDivSAs = "Income from dividends (annually) sps"
	IncDivSA1 = "Income from dividends (annually) dep 1"
	IncDivSA2 = "Income from dividends (annually) dep 2"
	IncDivSA3 = "Income from dividends (annually) dep 3"
	IncDivSA4 = "Income from dividends (annually) dep 4"
	IncDivSPAr = "Income from dividends (previous year) ref"
	IncDivSPAs = "Income from dividends (previous year) sps"
	IncDivSPA1 = "Income from dividends (previous year) dep 1"
	IncDivSPA2 = "Income from dividends (previous year) dep 2"
	IncDivSPA3 = "Income from dividends (previous year) dep 3"
	IncDivSPA4 = "Income from dividends (previous year) dep 4"
	IncIntAr = "Total interest income (annually) ref"
	IncIntAs = "Total interest income (annually) sps"
	IncIntA1 = "Total interest income (annually) dep 1"
	IncIntA2 = "Total interest income (annually) dep 2"
	IncIntA3 = "Total interest income (annually) dep 3"
	IncIntA4 = "Total interest income (annually) dep 4"
	IncIntBondSAr = "Interest from bonds (annually) ref"
	IncIntBondSAs = "Interest from bonds (annually) sps"
	IncIntBondSPAr = "Interest from bonds (previous year) ref"
	IncIntBondSPAs = "Interest from bonds (previous year) sps"
	IncIntBondSWr = "Interest from bonds (weekly) ref"
	IncIntBondSWs = "Interest from bonds (weekly) sps"
	IncIntFinSAr = "Interest from financial accounts (annually) ref"
	IncIntFinSAs = "Interest from financial accounts (annually) sps"
	IncIntFinSPAr = "Interest from financial accounts (previous year) ref"
	IncIntFinSPAs = "Interest from financial accounts (previous year) sps"
	IncIntFinSWr = "Interest from financial accounts (weekly) ref"
	IncIntFinSWs = "Interest from financial accounts (weekly) sps"
	IncIntLoanSAr = "Interest from loans (annually) ref"
	IncIntLoanSAs = "Interest from loans (annually) sps"
	IncIntLoanSPAr = "Interest from loans (previous year) ref"
	IncIntLoanSPAs = "Interest from loans (previous year) sps"
	IncIntLoanSWr = "Interest from loans (weekly) ref"
	IncIntLoanSWs = "Interest from loans (weekly) sps"
	IncIntPAr = "Total interest income (previous year) ref"
	IncIntPAs = "Total interest income (previous year) sps"
	IncMaintSAr = "Income from maintenance (annually) ref"
	IncMaintSAs = "Income from maintenance (annually) sps"
	IncMaintSFr = "Income from maintenance (fortnightly) ref"
	IncMaintSFs = "Income from maintenance (fortnightly) sps"
	IncMaintSF1 = "Income from maintenance (fortnightly) dep 1"
	IncMaintSF2 = "Income from maintenance (fortnightly) dep 2"
	IncMaintSF3 = "Income from maintenance (fortnightly) dep 3"
	IncMaintSF4 = "Income from maintenance (fortnightly) dep 4"
	IncMaintSPAr = "Income from maintenance (previous year) ref"
	IncMaintSPAs = "Income from maintenance (previous year) sps"
	IncMaintSWr = "Income from maintenance (weekly) ref"
	IncMaintSWs = "Income from maintenance (weekly) sps"
	IncNetRentAr = "Income from total property rent (annually) ref"
	IncNetRentAs = "Income from total property rent (annually) sps"
	IncNetRentA1 = "Income from total property rent (annually) dep 1"
	IncNetRentA2 = "Income from total property rent (annually) dep 2"
	IncNetRentA3 = "Income from total property rent (annually) dep 3"
	IncNetRentA4 = "Income from total property rent (annually) dep 4"
	IncNetRentPAr = "Income from total property rent (previous year) ref"
	IncNetRentPAs = "Income from total property rent (previous year) sps"
	IncNonHHSAr = "Income from non HH family members (annually) ref"
	IncNonHHSAs = "Income from non HH family members (annually) sps"
	IncNonHHSPAr = "Income from non HH family members (previous year) ref"
	IncNonHHSPAs = "Income from non HH family members (previous year) sps"
	IncNonHHSWr = "Income from non HH family members (weekly) ref"
	IncNonHHSWs = "Income from non HH family members (weekly) sps"
	IncNonTaxSuperImpAr = "Non-taxable super income (annual) ref"
	IncNonTaxSuperImpAs = "Non-taxable super income (annual) sps"
	IncOSPenSAr = "Income from overseas pensions (annually) ref"
	IncOSPenSAs = "Income from overseas pensions (annually) sps"
	IncOSPenSA1 = "Income from overseas pensions (annually) dep 1"
	IncOSPenSA2 = "Income from overseas pensions (annually) dep 2"
	IncOSPenSA3 = "Income from overseas pensions (annually) dep 3"
	IncOSPenSA4 = "Income from overseas pensions (annually) dep 4"
	IncOSPenSPAr = "Income from overseas pensions (previous year) ref"
	IncOSPenSPAs = "Income from overseas pensions (previous year) sps"
	IncOSPenSPA1 = "Income from overseas pensions (previous year) dep 1"
	IncOSPenSPA2 = "Income from overseas pensions (previous year) dep 2"
	IncOSPenSPA3 = "Income from overseas pensions (previous year) dep 3"
	IncOSPenSPA4 = "Income from overseas pensions (previous year) dep 4"
	IncOthInvSAr = "Income from other financial investments (annually) ref"
	IncOthInvSAs = "Income from other financial investments (annually) sps"
	IncOthInvSA1 = "Income from other financial investments (annually) dep 1"
	IncOthInvSA2 = "Income from other financial investments (annually) dep 2"
	IncOthInvSA3 = "Income from other financial investments (annually) dep 3"
	IncOthInvSA4 = "Income from other financial investments (annually) dep 4"
	IncOthInvSPAr = "Income from other financial investments (previous year) ref"
	IncOthInvSPAs = "Income from other financial investments (previous year) sps"
	IncOthRegSAr = "Income n.e.c. (annually) ref"
	IncOthRegSAs = "Income n.e.c. (annually) sps"
	IncOthRegSPAr = "Income n.e.c. (previous year) ref"
	IncOthRegSPAs = "Income n.e.c. (previous year) sps"
	IncOthRegSWr = "Income n.e.c. (weekly) ref"
	IncOthRegSWs = "Income n.e.c. (weekly) sps"
	IncPUTrustSAr = "Income from public unit trusts (annually) ref"
	IncPUTrustSAs = "Income from public unit trusts (annually) sps"
	IncPUTrustSPAr = "Income from public unit trusts (previous year) ref"
	IncPUTrustSPAs = "Income from public unit trusts (previous year) sps"
	IncPUTrustSWr = "Income from public unit trusts (weekly) ref"
	IncPUTrustSWs = "Income from public unit trusts (weekly) sps"
	IncRentNResSAr = "Income from non-res property (annually) ref"
	IncRentNResSAs = "Income from non-res property (annually) sps"
	IncRentNResSPAr = "Income from non-res property (previous year) ref"
	IncRentNResSPAs = "Income from non-res property (previous year) sps"
	IncRentNResSWr = "Income from non-res property (weekly) ref"
	IncRentNResSWs = "Income from non-res property (weekly) sps"
	IncRentResSAr = "Income from res property (annually) ref"
	IncRentResSAs = "Income from res property (annually) sps"
	IncRentResSPAr = "Income from res property (previous year) ref"
	IncRentResSPAs = "Income from res property (previous year) sps"
	IncRentResSWr = "Income from res property (weekly) ref"
	IncRentResSWs = "Income from res property (weekly) sps"
	IncRoyalSAr = "Income from royalties (annually) ref"
	IncRoyalSAs = "Income from royalties (annually) sps"
	IncRoyalSA1 = "Income from royalties (annually) dep 1"
	IncRoyalSA2 = "Income from royalties (annually) dep 2"
	IncRoyalSA3 = "Income from royalties (annually) dep 3"
	IncRoyalSA4 = "Income from royalties (annually) dep 4"
	IncRoyalSPAr = "Income from royalties (previous year) ref"
	IncRoyalSPAs = "Income from royalties (previous year) sps"
	IncRoyalSPA1 = "Income from royalties (previous year) dep 1"
	IncRoyalSPA2 = "Income from royalties (previous year) dep 2"
	IncRoyalSPA3 = "Income from royalties (previous year) dep 3"
	IncRoyalSPA4 = "Income from royalties (previous year) dep 4"
	IncServiceAr = "Personal services income (annual) ref"
	IncServiceAs = "Personal services income (annual) sps"
	IncServiceA1 = "Personal services income (annual) dep 1"
	IncServiceA2 = "Personal services income (annual) dep 2"
	IncServiceA3 = "Personal services income (annual) dep 3"
	IncServiceA4 = "Personal services income (annual) dep 4"
	IncSSCCSWr = "SS childcare (weekly) ref"
	IncSSCCSWs = "SS childcare (weekly) sps"
	IncSSCCSW1 = "SS childcare (weekly) dep 1"
	IncSSCCSW2 = "SS childcare (weekly) dep 2"
	IncSSCCSW3 = "SS childcare (weekly) dep 3"
	IncSSCCSW4 = "SS childcare (weekly) dep 4"
	IncSSSuperSAr = "SS super (annual) ref"
	IncSSSuperSAs = "SS super (annual) sps"
	IncSSSuperSFr = "SS super (fortnightly) ref"
	IncSSSuperSFs = "SS super (fortnightly) sps"
	IncSSSuperSWr = "SS super (weekly) ref"
	IncSSSuperSWs = "SS super (weekly) sps"
	IncSSSuperSW1 = "SS super (weekly) dep 1"
	IncSSSuperSW2 = "SS super (weekly) dep 2"
	IncSSSuperSW3 = "SS super (weekly) dep 3"
	IncSSSuperSW4 = "SS super (weekly) dep 4"
	IncSSTotSAr = "Total SS benefits (annual) ref"
	IncSSTotSAs = "Total SS benefits (annual) sps"
	IncSSTotSFr = "Total SS benefits (fortnightly) ref"
	IncSSTotSFs = "Total SS benefits (fortnightly) sps"
	IncSSTotSWr = "Total SS benefits (weekly) ref"
	IncSSTotSWs = "Total SS benefits (weekly) sps"
	IncSSTotSW1 = "Total SS benefits (weekly) dep 1"
	IncSSTotSW2 = "Total SS benefits (weekly) dep 2"
	IncSSTotSW3 = "Total SS benefits (weekly) dep 3"
	IncSSTotSW4 = "Total SS benefits (weekly) dep 4"
	IncTaxSuperImpAr = "Taxable super income (annual) ref"
	IncTaxSuperImpAs = "Taxable super income (annual) sps"
	IncTaxSuperImpPAr = "Taxable super income (previous year) ref"
	IncTaxSuperImpPAs = "Taxable super income (previous year) sps" 
	IncTrustSPAr = "Income from trusts (previous year) ref"
	IncTrustSPAs = "Income from trusts (previous year) sps"
	IncTrustSWr = "Income from trusts (weekly) ref"
	IncTrustSWs = "Income from trusts (weekly) sps"
	IncWageSAr = "Income from wage and salary (annually) ref"
	IncWageSAs = "Income from wage and salary (annually) sps"
	IncWageSA1 = "Income from wage and salary (annually) dep 1"
	IncWageSA2 = "Income from wage and salary (annually) dep 2"
	IncWageSA3 = "Income from wage and salary (annually) dep 3"
	IncWageSA4 = "Income from wage and salary (annually) dep 4"
	IncWageSFr = "Income from wage and salary (fortnightly) ref"
	IncWageSFs = "Income from wage and salary (fortnightly) sps"
	IncWageSF1 = "Income from wage and salary (fortnightly) dep 1"
	IncWageSF2 = "Income from wage and salary (fortnightly) dep 2"
	IncWageSF3 = "Income from wage and salary (fortnightly) dep 3"
	IncWageSF4 = "Income from wage and salary (fortnightly) dep 4"
	IncWageSPAr = "Income from wage and salary (previous year) ref"
	IncWageSPAs = "Income from wage and salary (previous year) sps"
	IncWageSPA1 = "Income from wage and salary (previous year) dep 1"
	IncWageSPA2 = "Income from wage and salary (previous year) dep 2"
	IncWageSPA3 = "Income from wage and salary (previous year) dep 3"
	IncWageSPA4 = "Income from wage and salary (previous year) dep 4"
	IncWageSWr = "Income from wage and salary (weekly) ref"
	IncWageSWs = "Income from wage and salary (weekly) sps"
	IncWageSW1 = "Income from wage and salary (weekly) dep 1"
	IncWageSW2 = "Income from wage and salary (weekly) dep 2"
	IncWageSW3 = "Income from wage and salary (weekly) dep 3"
	IncWageSW4 = "Income from wage and salary (weekly) dep 4"
	IncWCompAr = "Income from total workers comp (annually) ref"
	IncWCompAs = "Income from total workers comp (annually) sps"
	IncWCompPAr = "Income from total workers comp (previous year) ref"
	IncWCompPAs = "Income from total workers comp (previous year) sps"
	IncWCompSAr = "Income from regular workers comp (annually) ref"
	IncWCompSAs = "Income from regular workers comp (annually) sps"
	IncWCompSPAr = "Income from regular workers comp (previous year) ref"
	IncWCompSPAs = "Income from regular workers comp (previous year) sps"
	IncWCompSWr = "Income from regular workers comp (weekly) ref"
	IncWCompSWs = "Income from regular workers comp (weekly) sps"
	Kids0Su = "Number of kids aged 0 in IU"
	Kids10Su = "Number of kids aged 10 in IU"
	Kids11Su = "Number of kids aged 11 in IU"
	Kids12Su = "Number of kids aged 12 in IU"
	Kids13Su = "Number of kids aged 13 in IU"
	Kids14Su = "Number of kids aged 14 in IU"
	Kids1Su = "Number of kids aged 1 in IU"
	Kids2Su = "Number of kids aged 2 in IU"
	Kids3Su = "Number of kids aged 3 in IU"
	Kids4Su = "Number of kids aged 4 in IU"
	Kids5Su = "Number of kids aged 5 in IU"
	Kids6Su = "Number of kids aged 6 in IU"
	Kids7Su = "Number of kids aged 7 in IU"
	Kids8Su = "Number of kids aged 8 in IU"
	Kids9Su = "Number of kids aged 9 in IU"
	MaintPaidSAr = "Maintenance paid (annual) ref"
	MaintPaidSAs = "Maintenance paid (annual) sps"
	MaintPaidSPAr = "Maintenance paid (previous year) ref"
	MaintPaidSPAs = "Maintenance paid (previous year) sps"
	NetInvLossAr = "Net investment losses (annual) ref"
	NetInvLossAs = "Net investment losses (annual) sps"
	NetInvLossPAr = "Net investment losses (previous year) ref"
	NetInvLossPAs = "Net investment losses (previous year) sps"
	NonSSCCSWr = "Non-SS childcare (weekly) ref"
	NonSSCCSWs = "Non-SS childcare (weekly) sps"
	NonSSCCSW1 = "Non-SS childcare (weekly) dep 1"
	NonSSCCSW2 = "Non-SS childcare (weekly) dep 2"
	NonSSCCSW3 = "Non-SS childcare (weekly) dep 3"
	NonSSCCSW4 = "Non-SS childcare (weekly) dep 4"
	NonSSSharesSWr = "Non-SS shares (weekly) ref"
	NonSSSharesSWs = "Non-SS shares (weekly) sps"
	NonSSSharesSW1 = "Non-SS shares (weekly) dep 1"
	NonSSSharesSW2 = "Non-SS shares (weekly) dep 2"
	NonSSSharesSW3 = "Non-SS shares (weekly) dep 3"
	NonSSSharesSW4 = "Non-SS shares (weekly) dep 4"
	NonSSSuperSWr = "Non-SS super (weekly) ref"
	NonSSSuperSWs = "Non-SS super (weekly) sps"
	NonSSSuperSW1 = "Non-SS super (weekly) dep 1"
	NonSSSuperSW2 = "Non-SS super (weekly) dep 2"
	NonSSSuperSW3 = "Non-SS super (weekly) dep 3"
	NonSSSuperSW4 = "Non-SS super (weekly) dep 4"
	NonSSTotSAr = "Total non-SS benefits (fortnightly) ref"
	NonSSTotSAs = "Total non-SS benefits (fortnightly) sps"
	NonSSTotSFr = "Total non-SS benefits (fortnightly) ref"
	NonSSTotSFs = "Total non-SS benefits (fortnightly) sps"
	NonSSTotSWr = "Total non-SS benefits (weekly) ref"
	NonSSTotSWs = "Total non-SS benefits (weekly) sps"
	NonSSTotSW1 = "Total non-SS benefits (weekly) dep 1"
	NonSSTotSW2 = "Total non-SS benefits (weekly) dep 2"
	NonSSTotSW3 = "Total non-SS benefits (weekly) dep 3"
	NonSSTotSW4 = "Total non-SS benefits (weekly) dep 4"
	NsaSWr = "Income from newstart allowance on the SIH (weekly) ref"
	NsaSWs = "Income from newstart allowance on the SIH (weekly) sps"
	NsaSW1 = "Income from newstart allowance on the SIH (weekly) dep 1"
	NsaSW2 = "Income from newstart allowance on the SIH (weekly) dep 2"
	NsaSW3 = "Income from newstart allowance on the SIH (weekly) dep 3"
	NsaSW4 = "Income from newstart allowance on the SIH (weekly) dep 4"
	NumCareDepsr = "Number of dependents for Carer Allowance ref"
	NumCareDepss = "Number of dependents for Carer Allowance sps"
	NumIUu = "Number of income units in the family"
	ParPaySWr = "Income from parenting payment on the SIH (weekly) ref"
	ParPaySWs = "Income from parenting payment on the SIH (weekly) sps"
	PartAllSWr = "Income from partner allowance on the SIH (weekly) ref"
	PartAllSWs = "Income from partner allowance on the SIH (weekly) sps"
	PrivHlthInsr = "PHI flag (person) ref"
	PrivHlthInss = "PHI flag (person) sps"
	PrivHlthIns1 = "PHI flag (person) dep 1"
	PrivHlthIns2 = "PHI flag (person) dep 2"
	PrivHlthIns3 = "PHI flag (person) dep 3"
	PrivHlthIns4 = "PHI flag (person) dep 4"
	PrivHlthInsu = "PHI flag (income unit)"
	Renteru = "Renter Flag"
	RentPaidFh = "Rent paid (fortnightly) - household"		
	RentPaidFu = "Rent paid (fortnightly) - income unit"		
	RepEmpSupContAr = "Reportable employer super contributions (annual) ref"
	RepEmpSupContAs = "Reportable employer super contributions (annual) sps"
	RepFbAr = "Reportable fringe benefits (annual) ref"
	RepFbAs = "Reportable fringe benefits (annual) sps"
	RepFbA1 = "Reportable fringe benefits (annual) dep 1"
	RepFbA2 = "Reportable fringe benefits (annual) dep 2"
	RepFbA3 = "Reportable fringe benefits (annual) dep 3"
	RepFbA4 = "Reportable fringe benefits (annual) dep 4"
	RepSupContAr = "Reportable super contributions (annual) ref"
	RepSupContAs = "Reportable super contributions (annual) sps"
	RepSupContPAr = "Reportable super contributions (previous year) ref"
	RepSupContPAs = "Reportable super contributions (previous year) sps"
	Sexr = "Gender ref"
	Sexs = "Gender sps"
	Sex1 = "Gender dep 1"
	Sex2 = "Gender dep 2"
	Sex3 = "Gender dep 3"
	Sex4 = "Gender dep 4"
	SickAllSWr = "Income from sickness allowance on the SIH (weekly) ref"
	SickAllSWs = "Income from sickness allowance on the SIH (weekly) sps"
	SihQh = "Quarter of interview"
	SpBSWr = "Income from special benefit on the SIH (weekly) ref"
	SpBSWs = "Income from special benefit on the SIH (weekly) sps"
	TotalKidsu = "Total number of dependents"
	WidAllSWr = "Income from widow allowance on the SIH (weekly) ref"
	WidAllSWs = "Income from widow allowance on the SIH (weekly) sps"
	WifePenSWr = "Income from wife pension on the SIH (weekly) ref"
	WifePenSWs = "Income from wife pension on the SIH (weekly) sps"
	WrkForceIndepr = "Flag for Workforce Independence for YA ref"
	WrkForceIndeps = "Flag for Workforce Independence for YA sps"
	WrkForceIndep1 = "Flag for Workforce Independence for YA dep 1"
	WrkForceIndep2 = "Flag for Workforce Independence for YA dep 2"
	WrkForceIndep3 = "Flag for Workforce Independence for YA dep 3"
	WrkForceIndep4 = "Flag for Workforce Independence for YA dep 4"
	YouthAllSWr = "Income from youth allowance (weekly) ref"
	YouthAllSWs = "Income from youth allowance (weekly) sps"
	YouthAllSW1 = "Income from youth allowance (weekly) dep 1"
	YouthAllSW2 = "Income from youth allowance (weekly) dep 2"
	YouthAllSW3 = "Income from youth allowance (weekly) dep 3"
	YouthAllSW4 = "Income from youth allowance (weekly) dep 4"

	;

%MEND LabelVariables ;

* Call RunInitialisation ;
%RunInitialisation
