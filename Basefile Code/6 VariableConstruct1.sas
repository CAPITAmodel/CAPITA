
**************************************************************************************
* Program:      VariableConstruct1.sas                                               *
* Description:  Create additional variables which are required for basefile and      *
*               policy modules, and which only require variables from one dataset    *
*               level (either person, income unit, or household).  					 *
**************************************************************************************;

**************************************************************************************************
*   Step 1 - Create additional variables that use the person level dataset and are required      *
*            for the policy and basefile modules                                                 *
**************************************************************************************************;

DATA Person&SurveyYear ;

    SET Person&SurveyYear ;

        * Identifier variables ;

            * The position of the person in the family - FamPos (used in policy modules - Allowances
              module), where REF = Reference person of the family, SPOUSE = Spouse of the reference
              person, DEPCHILD = Dependent child of the family, NONDEPCHILD = Non-dependent child of
              the family, OTHER = Other person in the family ;

            IF RelationHHSp = 1 THEN DO ; * Husband, wife or partner ;

                IF IUPosSp = 1 THEN FamPosp = "REF" ; * Reference person of income unit becomes reference
                                                        person of family ;

                ELSE IF IUPosSp = 2 THEN FamPosp = "SPOUSE" ; * Partner of reference person of income unit
                                                                becomes spouse in family ;

                ELSE PUT 'Error: The husband, wife or partner in the household cannot be a dependent
                          child of the reference person of the income unit. ' ;

            END ;

            ELSE IF RelationHHSp = 2 THEN FamPosp = "REF" ; * Lone parent in the household becomes reference
                                                              person of the family ;


            ELSE IF RelationHHSp = 3 THEN FamPosp = "DEPCHILD" ; * Dependent student in the household becomes
                                                                   dependent child in the family ;

            ELSE IF RelationHHSp = 4 THEN FamPosp = "NONDEPCHILD" ; * Non-dependent child in the household 
                                                                      becomes non-dependent child in the family ;

            ELSE FamPosp = "OTHER" ; * If relationship in household is either 'Other related individual',  
                                       'Non-family member' or 'Not applicable', they do not fall into any of
                                       the REF, SPOUSE, DEPCHILD or NONDEPCHILD categories. Also, these
                                       relationships are not required for use in the policy modules ;
                  

        * Demographic variables ;

            * Convert sex to a character variable ;

            IF SexSp = 1 THEN Sexp = "M" ;  

            ELSE Sexp = "F" ;

            * Labour force status in main and second jobs (for use in policy modules) - LFStatp ;

            IF LfStatSp = 1 THEN DO ;

				IF FtPtStatSp = 2 THEN LfStatp = "PT" ; * Employed part time ;

                ELSE LfStatp = "FT" ; * Employed full time ;

            END ;

            ELSE IF LfStatSp = 2 THEN LfStatp = "UNEMP" ; * Unemployed ;

            ELSE LfStatp = "NILF" ; * Not in the labour force ; 



            * Hours worked per week from first and second job. (Convert categorical values into numeric values) ;
			/*No longer required in 2015-16 SIH - numeric item */
			HrsPerWkp = HrsPerWkSp;

            * Duration of Unemployment (for use in Allowances module) ;

            IF DurUnempSp = 0 THEN DurUnempTypep = "NA" ;

            ELSE IF DurUnempSp = 4 THEN DurUnempTypep = "Lt4Wk" ;

            ELSE IF (DurUnempSp >= 4 AND DurUnempSp<= 12) THEN DurUnempTypep = "4To12Wk" ;

            ELSE IF (DurUnempSp >= 13 AND DurUnempSp<= 25) THEN DurUnempTypep = "13To25Wk" ;

            ELSE IF (DurUnempSp >= 26 AND DurUnempSp<= 51) THEN DurUnempTypep = "26To51Wk" ;

            ELSE DurUnempTypep = "Gt1Yr" ;
           
            * Type of educational institution attending ;

            IF EducInstSp = 1 THEN EducInstp = "UNI" ;

            ELSE IF EducInstSp = 2 THEN EducInstp = "TAFE" ;

            ELSE IF EducInstSp = 3 THEN DO ;
                
                * If the person is less than 20 years old and their highest year of school
                  completed is Year 11 or below, then assume they are in secondary school ;

                IF AgeSp < 21 AND HighestSYearSp > 1 THEN EducInstp = "SS" ;

                ELSE  EducInstp = "OTHER" ;

            END ;

            ELSE  EducInstp = "NA" ;


        * Study status, where SS = secondary school, FTNS = full-time non-secondary school,
          PTNS = part-time non-secondary school, NOSTUDY = not currently studying ;

            IF EducInstp = "SS" THEN StudyTypep = "SS" ;

            ELSE IF StudyTypeSp = 1 THEN StudyTypep = "FTNS" ;  

            ELSE IF StudyTypeSp = 2 THEN StudyTypep = "PTNS" ;

            ELSE StudyTypep = "NOSTUDY" ;


		* YearOfArrival, where 0 = born in Australia,  1 = not born in Australia but arrived in Australia 10 or more years before the survey was
  		taken, 2 = not born in Australia and arrived in Australia less than 10 years before the
  		survey was taken ;
				* ignores the change in residency requirement from 10 to 15 years as per the 2017-18 Budget. 
	 			 The impact of the change does not appear to be significant as per the DSS benchmarks. People are likely 
	 			 to be meeting the other criteria,ie 10 years continuous residence of which 5 years are during working life 
				  or of which 5 years are without having received activity tested income support payment. ; 

    		IF YearOfArrivalSp < 2 THEN YearOfArrivalp = 0 ; 	*SIH value of 1 = Born in Australia ; 

    		ELSE IF YearOfArrivalSp <4 THEN YearOfArrivalp = 1 ;	*SIH value of 2 = Arrived 1995 and before, 3= Arrived 1996-2005  ; 

   			ELSE IF YearOfArrivalSp = 4 THEN YearOfArrivalp = 2  ;	*SIH value of 4 = Arrived 2006 to year of collection (2015); 

    		ELSE IF AgePenSWp > 0 THEN YearOfArrivalp = 1 ; 	*If SIH value not specified, but receiving Age Pension on the SIH, then pass year of arrival test; 

	 		ELSE YearOfArrivalp = 2 ;


			* Income variables ;

            * Net share losses - calculate as the amount by which deductions against dividend income 
            exceed the amount of dividend income actually earned, or zero if deductions are less
            than or equal to dividend income. We use interest paid on money borrowed to purchase
            shares or units in trusts as a proxy for deductions against dividend income ;

            NetShareLossAp = MAX ( 0 , DedIntSharesSWp - IncDivSWp ) * 52 ;

            NetShareLossPAp = MAX ( 0 , DedIntSharesSPAp - IncDivSPAp ) ;

            * Correction for wage and salary income including salary sacrificed amounts ;

            IF IncSSFlagSp = 1 THEN IncWageSWp = MAX ( 0 , IncEmpTotSWp - IncSSTotSWp - NonSSTotSWp ) ;

            ELSE IncWageSWp = MAX ( 0 , IncEmpTotSWp - NonSSTotSWp ) ;

            * Changes of frequencies required for income definitions module ;

            IncMaintSFp = IncMaintSWp * 2 ;          /* Maintenance received - weekly to fortnighly */ 
            IncMaintSAp = IncMaintSWp * 52 ;         /* Maintenance received - weekly to annually */
            MaintPaidSAp = MaintPaidSWp * 52 ;       /* Maintenance paid - weekly to annually */
            IncSSSuperSFp = IncSSSuperSWp * 2 ;      /* Salary sacrificed super - weekly to fortnightly */
            IncSSSuperSAp = IncSSSuperSWp * 52 ;     /* Salary sacrificed super - weekly to annually */
            NonSSTotSFp = NonSSTotSWp * 2 ;          /* Fringe benefits (non salary sacrificed) - weekly to fortnightly */
            IncSSTotSFp = IncSSTotSWp * 2 ;          /* Fringe benefits (salary sacrificed) - weekly to fortnightly */
            NonSSTotSAp = NonSSTotSWp * 52 ;         /* Fringe benefits (non salary sacrificed) - weekly to annually */
            IncSSTotSAp = IncSSTotSWp * 52 ;         /* Fringe benefits (salary sacrificed) - weekly to annually */
            IncBusLExpSAp = IncBusLExpSWp * 52 ;     /* Business income less expenses - weekly to annually */
            IncDivSAp = IncDivSWp * 52 ;             /* Dividend income - weekly to annually */
            IncRoyalSAp = IncRoyalSWp * 52 ;         /* Income from royalties - weekly to annually */
            IncOthInvSAp = IncOthInvSWp * 52 ;       /* Income from other investments - weekly to annually */
            IncNonHHSAp = IncNonHHSWp * 52 ;         /* Income from family members not in household - weekly to annually */
            IncOthRegSAp = IncOthRegSWp * 52 ;       /* Income from other regular sources - weekly to annually */
            IncOSPenSAp = IncOSPenSWp * 52 ;         /* Income from overseas pensions and benefits - weekly to annually */
            IncWageSAp = IncWageSWp * 52 ;           /* Income from wage and salary - weekly to annually */
            IncWageSFp = IncWageSWp * 2 ;            /* Income from wage and salary - weekly to fortnightly */
            IncIntFinSAp = IncIntFinSWp * 52 ;       /* Income from financial institution account interest - weekly to annually */
            IncIntBondSAp = IncIntBondSWp * 52 ;     /* Income from interest on bonds - weekly to annually */
            IncIntLoanSAp = IncIntLoanSWp * 52 ;     /* Income from interest on loans - weekly to annually */
            IncTrustSAp = IncTrustSWp * 52 ;         /* Income as beneficiary of a trust - weekly to annually */
            IncPUTrustSAp = IncPUTrustSWp * 52 ;     /* Income from public unit trusts - weekly to annually */
            IncAccSAp = IncAccSWp * 52 ;             /* Income from accident comp and sickness insurance - weekly to annually */
            IncWCompSAp = IncWCompSWp * 52 ;         /* Income from regular workers' compensation - weekly to annually */
            IncRentResSAp = IncRentResSWp * 52 ;     /* Residential property rental income - weekly to annually */
            IncRentNResSAp = IncRentNResSWp * 52 ;   /* Non-residential property rental income - weekly to annually */
            IncSuperSAp = IncSuperSWp * 52 ;         /* Income from superannuation/annuity - weekly to annually */

            * Construction of additional variables required for income definitions module ;

                * TotSSNonSSWp - For the purposes of calculating ordinary income ;

                TotSSNonSSWp = IncSSTotSWp + NonSSTotSWp ;

                TotSSNonSSFp = TotSSNonSSWp * 2 ;

                TotSSNonSSAp = TotSSNonSSWp * 52 ;

                * TotSSNonSSFBWp - Incorporates fringe benefits only ;

                TotSSNonSSFBWp = TotSSNonSSWp - NonSSCCSWp - NonSSSharesSWp - NonSSSuperSWp
                                - IncSSCCSWp - IncSSSuperSWp ;

                * Flag indicating whether reported employee income included the amount salary sacrificed ;

                IF IncSSFlagSp = 1 THEN IncSSFlagp = 1 ;     /* Included */  

                ELSE IncSSFlagp = 0 ;                        /* Not included */  

                * Positive amount of business income less expenses ;

                IncBusLExpWp = MAX( 0 , IncBusLExpSWp ) ;    /* Positive amount of business income less expenses */ 

                IncBusLExpFp = IncBusLExpWp * 2 ;

                IncBusAp = IncBusLExpSAp ;                   /* Annual income from own business (proxied by business
                                                                income less expenses) */ 

                * Income from interest payments - sum of interest components ;

                IncIntAp = IncIntFinSAp              /* Income from financial institution account interest */
                         + IncIntBondSAp             /* Income from interest on debentures and bonds */
                         + IncIntLoanSAp             /* Income from interest on loans */
                         + IncTrustSAp               /* Income as beneficiary of a trust */
                         + IncPUTrustSAp ;           /* Income from public unit trusts */

                IncIntWp = IncIntAp / 52 ;

                * Income from interest payments for previous year ;

                IncIntPAp = IncIntFinSPAp            /* Previous year income from financial institution account interest */
                          + IncIntBondSPAp           /* Previous year income from interest on debentures and bonds */
                          + IncIntLoanSPAp           /* Previous year income from interest on loans */
                          + IncTrustSPAp             /* Previous year income as beneficiary of a trust */
                          + IncPUTrustSPAp ;         /* Previous year income from public unit trusts */

                * Workers compensation - sum of components (previous year) ;

                IncWCompPAp = IncAccSPAp             /* Previous year income from accident compensation and sickness insurance */
                            + IncWCompSPAp ;         /* Previous year income from regular workers compensation */

                * Workers compensation - sum of components (current year) ;

                IncWCompAp = IncAccSAp               /* Income from accident compensation and sickness insurance */
                           + IncWCompSAp ;           /* Income from regular workers compensation */

                * Total property rent (note this is net of expenses) ;

                IncNetRentAp = IncRentResSAp         /* Residential property */
                                + IncRentNResSAp ;   /* Non-residential property */

                IncNetRentWp = IncNetRentAp / 52 ;

                IncNetRentPAp = IncRentResSPAp       /* Residential property */
                                + IncRentNResSPAp ;  /* Non-residential property */

                * Net loss from renting (0 if net rent is positive, negative of loss if net rent is negative) ;

                NetRentLossAp = MAX( 0 , -IncNetRentAp ) ; 

                NetRentLossPAp = MAX( 0 , -IncNetRentPAp ) ; 

                * Net investment losses (sum of rental losses and share losses) ;

                NetInvLossAp = NetRentLossAp + NetShareLossAp ;

                NetInvLossPAp = NetRentLossPAp + NetShareLossPAp ;

                * Deductible child maintanence for ATI purposes (use maintanance paid as proxy) ; 

                DedChildMaintAp = MaintPaidSAp ;       

                * Service income (use wage and salary income as a proxy) ;
                    
                IncServiceAp = IncWageSAp ;     
      
        * Create additional flag for receipt of paid parental leave payment ;

                IF PPLSWp > 0 THEN PPLFlagSp = 1 ;

                ELSE PPLFlagSp = 0 ;
              
        * Create variable indicating whether the previous year income data is available for this person ;

                IF FinScopeSp = 2 THEN DataScopeTypep = "PrevYrAvail" ;

                ELSE DataScopeTypep = "PrevYrNA" ;

		* Wealth variables - aggregation ;

				* Real estate and business non-primary production assets ;

				AssPropBusp = AssUnincorpSp ;

				* Deemed financial assets ;
			
				AssDeemedp = AssAcctSp + AssDebSp + AssOffSp + AssOthFinSp + AssSharSp + AssPrivTrustSp + AssPubTrustSp + AssLoanValSp + AssSupNoIncSp + AssSupIncSp ;

				* Trusts and companies non-primary production assets ;

				AssTrustCompp = AssSilPtnrSp + AssIncorpSp ;

				* Other assets ;

				AssOtherp = 0 ;

				* Total person-level assets ;

				AssTotp = AssPropBusp + AssDeemedp + AssTrustCompp + AssOtherp ;

RUN ;

* Calculate proportions of person-level assets within households.
  Do this using PROC SQL - for each household, add up person-level assets and then for each person, divide their assets by this total.
  This will help with estimating the allocation of household-level SIH assets between people in each household. ;

PROC SQL ;
	CREATE TABLE Person&SurveyYear (DROP=AssHHTotp) AS 
			SELECT *, sum(AssTotp) AS AssHHTotp, AssTotp/calculated AssHHTotp AS HHPctAssetsp
			FROM Person&SurveyYear
			GROUP BY SihHID ;
QUIT ;

**************************************************************************************************
*   Step 2 - Create additional variables that use the income unit level dataset and are required *
*             for the policy and basefile modules                                                *
**************************************************************************************************;

DATA Income&SurveyYear ;

    SET Income&SurveyYear ;

        * Demographic variables ;

            * Occupancyu - the nature of the living situation of the income unit ;
            
            IF TenureSu =< 2 THEN Occupancyu = TenureSu ;

            ELSE IF TenureSu = 3 THEN DO ; * Renter or boarder ;

                IF LandlordSu = 2 THEN Occupancyu = 3 ; * Renting from the Government if living in 
                										  a housing authority ; 

                ELSE Occupancyu = 4 ; * Renting privately ;

            END ;

            ELSE Occupancyu = 5 ; * Other ; 

            * Renter - flags whether or not the income unit is renting privately ;

            IF Occupancyu = 4 THEN Renteru = 1 ; 

            ELSE Renteru = 0 ;

            * Couple - flags whether or not the income unit is a couple ;

            IF IUTypeSu IN ( 1 , 2 ) THEN Coupleu = 1 ;

            ELSE Coupleu = 0 ;

        * Income variables ;

            * Flag for receipt of child care benefit ;

            IF CCBSWu > 0 THEN CCBFlagSu = 1 ;

            ELSE CCBFlagSu = 0 ; 

            * Flag for receipt of child care rebate ;

            IF CCRSWu > 0 THEN CCRFlagSu = 1 ;

            ELSE CCRFlagSu = 0 ;
            
RUN ;


* Sort the income unit level dataset to prepare for the PROC MEANS and for merging by family ID ;

PROC SORT DATA = Income&SurveyYear ;

    BY SihHID SihFID SihIUID ;

RUN ;

* Use a PROC MEANS to create a dataset containing the number of income units (NumIUu) for each family ID ;

PROC MEANS DATA = Income&SurveyYear NOPRINT NWAY ;

    CLASS SihHID SihFID ;

    OUTPUT OUT = IUCountu N = NumIUu ;

RUN;

* Merge this dataset onto the income unit level dataset by family ID to create the NumIU variable
  (the number of income units in the family to which the income unit belongs) ;

DATA Income&SurveyYear ;

    MERGE Income&SurveyYear IUCountu ;

        BY SihHID SihFID ;

        DROP _TYPE_ _FREQ_ ;

    LABEL NumIUu = "Number of income units in the family" ;

RUN ;

PROC SORT DATA = Income&SurveyYear ;

    BY SihHID SihFID SihIUID ;

RUN ;

* Number of income units in the household ;

PROC MEANS DATA = Income&SurveyYear NOPRINT NWAY ;
    CLASS SihHID ;
    OUTPUT OUT = IUinHH N = NumIUh ;
RUN;

DATA Income&SurveyYear ;
    MERGE Income&SurveyYear IUinHH ;
        BY SihHID ;
        DROP _TYPE_ _FREQ_ ;
    LABEL NumIUh = "Number of income units in the household" ;
RUN ;



**************************************************************************************************
*   Step 3 - Create additional variables that use the household level dataset and are required   *
*            for the policy and basefile modules                                                 *
**************************************************************************************************;

DATA Household&SurveyYear ;

    SET Household&SurveyYear ;

        * State or Territory of usual residence ;

            IF StateSh = 1 THEN Stateh = "NSW" ;

            ELSE IF StateSh = 2 THEN Stateh = "VIC" ;

            ELSE IF StateSh = 3 THEN Stateh = "QLD" ;

            ELSE IF StateSh = 4 THEN Stateh = "SA" ;

            ELSE IF StateSh = 5 THEN Stateh = "WA" ;

            ELSE IF StateSh = 6 THEN Stateh = "TAS" ;

            ELSE IF StateSh = 7 THEN Stateh = "NT" ;

		    ELSE IF StateSh = 8 THEN Stateh = "ACT" ;

        * Convert weekly rent to fortnightly rent ;

            RentPaidFh = RentPaidWh * 2 ;

		* Wealth variables - aggregation at the household level ;

			* Real estate and business non-primary production assets ;

			AssPropBusHHh = AssResiPropOthSh + AssNonResiPropSh - AssRentPropLoanSh - AssOthPropLoanSh ;
			
			* Deemed financial assets ;

			AssDeemedHHh = -AssInvLoanSh ;

			* Other assets (multiply by a scaling factor) ;

			AssOtherHHh =  ( AssHomeContSh + AssVehicSh + AssNECSh - AssOthLoanSh - AssVehicLoanSh ) ;

RUN ;

* Merge household-level asset information onto person-level dataset ;

PROC SORT DATA = Person&SurveyYear ;
	BY SihHID ;
RUN ;

PROC SORT DATA = Household&SurveyYear ;
	BY SihHID ;
RUN ;

DATA Person&SurveyYear ;
	
	MERGE Person&SurveyYear Household&SurveyYear( KEEP = SihHID PersonsInHHh AssPropBusHHh AssDeemedHHh AssOtherHHh ) ;

	BY SihHID ;

	DROP PersonsinHHh AssPropBusHHh AssDeemedHHh AssOtherHHh HHPctAssetsp ;

	* Use proportion of person-level assets within each household calculated earlier to allocate household-level assets ;

	* If there are no person-level assets in a household, then allocate household-level assets evenly between members of the household ;
	IF HHPctAssetsp = . THEN HHPctAssetsp = 1/PersonsInHHh ;

	* Update person-level asset variables to include household-level assets ;

	AssPropBusp = AssPropBusp + AssPropBusHHh * HHPctAssetsp ;

	AssDeemedp = AssDeemedp + AssDeemedHHh * HHPctAssetsp ;
	
	AssOtherp = AssOtherp + AssOtherHHh * HHPctAssetsp ;

	AssTotp = AssPropBusp + AssDeemedp + AssTrustCompp + AssOtherp ;

RUN ;

* Drop household-level aggregated assets, which we no longer need ;

DATA Household&SurveyYear ;

	SET Household&SurveyYear ;

	DROP AssPropBusHHh AssDeemedHHh AssOtherHHh ;

RUN ;
