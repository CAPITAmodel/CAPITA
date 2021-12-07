**************************************************************************************
* Program:      TopcodedKidAge.sas                                                        *
* Description:  The numbers of children in each age range in the SIH are topcoded to	  *
*				2 children. This program identifies households which have >2 			  *
*				children of any age.  													  *
*               																		  *
**************************************************************************************;
LIBNAME Library "\\olympus.treasury.gov\sas\models$\TAD\Data\ABS\SIH\Ids1718_64\IncomeHouse2017-18_SAS" ;    

data test;
	set Library.sih17bi (keep= ABSHID ABSIID AGODCIU AGYDCIU IUTYPE DEPKIDBC KID1524B IUFA: IUMA: PRSNSUBC );

	/* combine males and females of the same age */
	IUA0YB=IUFA0YB+IUMA0YB;
	IUA1YB=IUFA1YB+IUMA1YB;
	IUA2YB=IUFA2YB+IUMA2YB;
	IUA3YB=IUFA3YB+IUMA3YB;
	IUA4YB=IUFA4YB+IUMA4YB;
	IUA5YB=IUFA5YB+IUMA5YB;
	IUA6YB=IUFA6YB+IUMA6YB;
	IUA7YB=IUFA7YB+IUMA7YB;
	IUA8YB=IUFA8YB+IUMA8YB;
	IUA9YB=IUFA9YB+IUMA9YB;
	IUA10YB=IUFA10YB+IUMA10YB;
	IUA11YB=IUFA11YB+IUMA11YB;
	IUA12YB=IUFA12YB+IUMA12YB;
	IUA13YB=IUFA13YB+IUMA13YB;
	IUA14YB=IUFA14YB+IUMA14YB;

	/* create a unique household income unit idenfitier (occasionally there is >1 income unit within a household) */
	ABSIUID=left(trim(ABSHID)!!ABSIID);

	/* calculate total number of dependents aged 0 to 24 in income unit*/
	tnumdep=sum(IUA0YB,	IUA1YB,	IUA2YB,	IUA3YB,	IUA4YB,	IUA5YB,	IUA6YB,	IUA7YB,	IUA8YB,	IUA9YB,	IUA10YB,
		IUA11YB,	IUA12YB,	IUA13YB,	IUA14YB, KID1524B);

	/* only output where the calculated number of dependents (based on top coded age) does not match
	the number of dependents in the income unit - these should be the households with >2 children
	of the same age e.g. tripplets */
	IF tnumdep^=DEPKIDBC;

	IF AGODCIU=99 AND AGYDCIU=99 THEN
		DELETE;

proc sort;
	by ABSIUID;
run;

proc print data=test;
	var ABSHID ABSIID ABSIUID IUTYPE PRSNSUBC KID1524B DEPKIDBC tnumdep AGODCIU AGYDCIU  IUA:;
run;