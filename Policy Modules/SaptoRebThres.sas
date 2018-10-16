
PROC FCMP OUTLIB = Work.Functions.Tax ;

    * Define net income tax equation given SAPTO and LITO ;

    FUNCTION SaptoRebThr( TaxIncAr , CumTax1 , TaxRate1 , TaxThr1 , CumTax2 , TaxRate2 , TaxThr2 , 
                          LitoMax , LitoTpr1, LitoTpr2 , LitoThr1 , LitoThr2, SaptoMaxCr ) ;

        * Define gross income tax equation ;

        GrossIncTax = MAX( 0 , CumTax1 + TaxRate1 * ( TaxIncAr - TaxThr1 ) , CumTax2 + TaxRate2 * ( TaxIncAr - TaxThr2 ) ) ;

        * Define SAPTO equation ;

        SAPTO = SaptoMaxCr ;

        * Define LITO equation ;

  		LITO = MAX( 0 , LitoMax - MAX( 0 , MAX(0, LitoTpr2 * ( TaxIncAr - LitoThr2 ))+ LitoTpr1 * ((MIN( LitoThr2, TaxIncAr) - LitoThr1 ) ) )) ;

        NetIncTax = GrossIncTax - SAPTO - LITO  ;

        RETURN( NetIncTax ) ;

    ENDSUB ;

    * Define solve function to calculate the effective tax free threshold given SAPTO and LITO (that is the SAPTO Rebate Threshold) ;

    FUNCTION SolveSaptoRebThr( CumTax1 , TaxRate1 , TaxThr1 , CumTax2 , TaxRate2 , TaxThr2 , 
                          LitoMax , LitoTpr1, LitoTpr2 , LitoThr1 , LitoThr2, SaptoMaxCr  ) ;

        * Set net income tax to 0 and set initial guess value to a reasonable value ;
        * Setting the initial guess value helps with the convergence of the final result ;

        NetIncTax = 0 ;

        InitialGuess = TaxThr1 ;

        MaxIterations = 1000 ;
      
        * Define the solve function, which solves for TaxIncAr to get the effective tax free threshold;

        SolveSaptoRebThr = SOLVE( 'SaptoRebThr' , { InitialGuess, . , . , MaxIterations } , NetIncTax , . , 
                                  CumTax1 , TaxRate1 , TaxThr1 , CumTax2 , TaxRate2 , TaxThr2 , 
                                  LitoMax , LitoTpr1 , LitoTpr2 , LitoThr1 ,  LitoThr2, SaptoMaxCr   
								 ) ;

        RETURN( SolveSaptoRebThr ) ;

    ENDSUB ;

QUIT ;

OPTIONS CMPLIB = Work.Functions ;

