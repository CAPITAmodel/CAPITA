**************************************************************************************
* Program:      AdjustSIH.sas                                                        *
* Description:  Makes any required adjustments to the SIH datasets.                  *                                                            
**************************************************************************************;
DATA SihIncome;
	SET SihIncome;

	/* age of dependent child */
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

	ABSIUID=left(trim(ABSHID)!!ABSIID);

RUN;