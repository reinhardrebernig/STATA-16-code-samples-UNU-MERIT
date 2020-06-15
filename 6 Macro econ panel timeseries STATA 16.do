*******************************************************************************
******************** Econometrics+ course  **************************
						*Overview*
*******************************************************************************

* Topics: Panel data, time-series analysis, GDP and Investment growth rates.   		
* Author: Reinhard Rebernig adapted from Prof. D. de Crombrugghe				        
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Revsion:  0007 Last change: 15/05/20 by Reinhard Rebernig



clear
cap log close
set more on
*** Stata do-file for use with the EMX+ project  ***
*** !!! Adapt the pathname in following line !!! ***
cd ""
log using EMXplus_class1.log, replace
*** !!! Adapt the filename in following line !!! ***
use "BEL_EMP_s13.dta"
desc
summ
more
tsset year, yearly 
more 

*** Time series plots (Ass. 1.2) ***
tsline YU YO IU IO CU CO 
more 
gen lnyu=log(YU) 
gen lnyo=log(YO) 
gen lniu=log(IU) 
gen lnio=log(IO) 
gen lncu=log(CU) 
gen lnco=log(CO) 
tsline lnyu lnyo lniu lnio lncu lnco 
more 
gen dlnyu=D.lnyu
gen dlnyo=D.lnyo
gen dlniu=D.lniu
gen dlnio=D.lnio 
gen dlncu=D.lncu
gen dlnco=D.lnco
tsline dlnyu dlnyo dlniu dlnio dlncu dlnco 
more

*** Scatter plots and simple regressions (Ass. 1.3-1.4) ***
scatter IO YO 
reg IO YO 
more
scatter lnio lnyo 
reg lnio lnyo 
more
scatter dlnio dlnyo
reg dlnio dlnyo
more

*** Time trends (Ass. 1.7) ***
reg lnyo year
predict lnyohat1, xb 
tsline lnyo lnyohat1  
more
ofrtplot    //  Will only work if you installed the ofrtplot command.
            //  Type -help ofrtplot- and follow instructions. 
more
gen yearsq=year^2
reg lnyo year yearsq 
more
predict lnyohat2, xb 
tsline lnyo lnyohat1 lnyohat2 
more
ofrtplot    //  Will only work if you installed the ofrtplot command.
            //  Type -help ofrtplot- and follow instructions. 
more
			
*** Autoregressions (Ass. 1.8) ***
scatter YO L.YO 
reg YO L.YO 
more
ofrtplot
more        //  Notice heteroskedasticity? Serial corr'n? 
scatter lnyo L.lnyo 
reg lnyo L.lnyo  
more
ofrtplot
more        //  What about that heteroskedasticity? Serial corr'n?   
scatter dlnyo L.dlnyo 
reg dlnyo L.dlnyo  
more
ofrtplot
more        //  What about that serial corr'n?    

*** Multiple regressions: lagged output effect (Ass. 2.1) ***
reg lnio lnyo 
reg lnio lnyo L.lnyo          //  Compare the standard errors!!??
more
test _b[L.lnyo]=0             //  Any new info?
test _b[L.lnyo]=-_b[lnyo]
test _b[L.lnyo]+_b[lnyo]=0    //  Any new info?
more
reg lnio lnyo L.lnyo          //  Try to interpret delayed adjustment
reg lnio D.lnyo L.lnyo        //  Coincidences? Any preference?
more
reg lnio lnyo D.lnyo          //  Coincidences? Any preference?
more

*** Multiple regressions: Price effects (Ass. 2.2) ***
gen lnpi=log(IU/IO) 
gen lnpy=log(YU/YO) 
gen lnpir=lnpi-lnpy 
more
*** 2.2(a) with slightly modified specification ***
reg lnio lnyo D.lnyo
more
*** 2.2(b) Introducing prices ***
reg lnio lnyo lnpi lnpy L.lnpi D.lnyo
more
*** 2.2(c) Testing the relevance of prices ***
test _b[lnpi]=_b[lnpy]=_b[L.lnpi]=0
test lnpi lnpy L.lnpi 
more 
*** 2.2(d) Testing price homogeneity ***
reg lnio lnyo lnpir D.lnyo
more
reg lnio lnyo lnpi lnpy L.lnpi D.lnyo             //  Test regression 
test (_b[lnpi]=-_b[lnpy]) (_b[L.lnpi]=0)
test (lnpi+lnpy=0) (L.lnpi=0) 
more 
*** 2.2(e) A weaker version of price homogeneity ***
reg lnio lnyo lnpir D.lnpi D.lnyo
more			
reg lnio lnyo lnpi lnpy L.lnpi D.lnyo             //  Test regression 
test _b[lnpi]+_b[lnpy]+_b[L.lnpi]=0
more
*** 2.2(f) Simple regression in nominal aggregates ***
reg lniu lnyu 
more	
reg lnio lnyo lnpi lnpy L.lnpi D.lnyo             //  Test regression 
test (_b[lnpi]=-1) (_b[lnpy]=_b[lnyo]) (_b[L.lnpi]=0) (_b[D.lnyo]=0)
more 
reg lnio lnyo lnpi lnpy L.lnpi L.lnyo             //  Test regression (alt.)
test (_b[lnpi]=-1) (_b[lnpy]=_b[lnyo]) (_b[L.lnpi]=0) (_b[L.lnyo]=0)
more                              // The original formulation is equivalent

*** The world according to Piketty (Ass. 3.1) ***
reg lnio lnyo D.lnyo 
more
gen lnso=log(YO-CO) 	
reg lnso lnyo D.lnyo 		
more

*** Testing for structural breaks (Ass. 3.3) ***
reg lnio lnyo D.lnyo if year<1980 
reg lnio lnyo D.lnyo if year>=1980 
more
reg lnio lnyo D.lnyo                              //  Test regression 
estat sbknown, break(1980)                        //  Chi-square test 
more 
gen dum_80 = (year>=1980) 
gen lnyo_80 = lnyo*dum_80 
gen dlnyo_80 = D.lnyo*dum_80 
reg lnio lnyo D.lnyo dum_80 lnyo_80 dlnyo_80      //  Test regression 
test dum_80 lnyo_80 dlnyo_80                      //  Relate F to Chi-square? 
more 

*** Testing the distributional assumptions (Ass. 3.4) *** 
reg lnio lnyo D.lnyo 
ofrtplot 
more
estat imtest, white                               //  Bah
more
reg lnio lnyo D.lnyo, vce(robust)                 //  See? 
more
reg lnio lnyo D.lnyo, vce(hc2) 
reg lnio lnyo D.lnyo, vce(hc3)                    //  hc3 is the "safest"
more
predict resid_34, res 
hist resid_34 
more
hist resid_34, bin(20)
more

*** Testing linearity (Ass. 3.5) ***
reg lnio lnyo D.lnyo 
estat ovtest 
more

*** Testing for residual autocorrelation (Ass. 3.6) ***
tsline resid_34 
more
scatter resid_34 L.resid_34 
reg resid_34 L.resid_34 
more
reg lnio lnyo D.lnyo 
estat dwatson 
more
estat durbinalt 
more 
estat bgodfrey
more                          //  No ambiguity in the conclusion... 

*** Autocorrelation-robust standard errors (Ass. 3.7) ***
newey  lnio lnyo D.lnyo , lag(2) 
more

*** Modelling the residual autocorrelation (Ass. 3.8) ***
scatter resid_34 L.resid_34   //  (bis) 
reg resid_34 L.resid_34       //  (bis) 
more
prais  lnio lnyo D.lnyo       //  Notice the first iteration! 
more 

*** Autocorrelation: an extreme case (Ass. 3.9) ***
reg D.lnio D.lnyo D.(D.lnyo)  
more 
 
*** Testing for Unit Roots (UR) (Ass. 4.1) ***
reg lnio L.lnio 
reg lnyo L.lnyo
more 
dfuller lnio, reg          // No evidence AGAINST unit root...
more                       // Where is the crap? 
dfuller lnio, reg drift    // Unchanged estimates, different distribution
more                       // Unchanged estimates, different distribution
dfuller lnio, reg trend  
more
dfuller lnio, reg lag(1)    
more
dfuller lnio, lag(2)       // In the case of non-rejection,  
dfuller lnio, lag(3)       // lags hardly affect the test conclusion
more
dfuller dlnio, reg         // Clear evidence against 2nd unit root
more
dfuller dlnio, reg lag(1)  // The lag seems superfluous
more
dfuller dlnio, lag(2)      // In the case of rejection,  
dfuller dlnio, lag(3)      // lags gradually erode the power of the test
more
dfuller lnyo, reg          // Good evidence AGAINST unit root...  
dfuller lnyo, reg drift  
dfuller lnyo, reg trend    // A trend can break the power of the test!
more
dfuller lnyo, reg lag(1)  
dfuller lnyo, reg lag(2)   // Lags gradually erode the power of the test
more
dfuller dlnyo, reg         // Clear evidence against 2nd unit root 
more
dfuller dlnyo, reg lag(1)  // The lag seems superfluous  
dfuller dlnyo, lag(2) 
dfuller dlnyo, lag(3)      // Overspecification can also break the power!  
more
 
*** A co-integration relationship for investments? (Ass. 4.2) ***
gen lnapio = lnio-lnyo
dfuller lnapio, reg           // Ambiguous: not a convincing rejection
more 
dfuller lnapio, reg drift     // Same estimates, very different impression!
more
dfuller lnapio, reg trend     // Trend seems superfluous 
more
dfuller lnapio, reg lag(1)    // Augmentation with lags offers no help
more
reg lnio lnyo                 // Co-integrating regression 
predict resid_42, res
dfuller resid_42, reg         // Not a convincing result, although...
more 
dfuller resid_42, reg nocons  // ... -nocons- saves power! 
more 
 
*** A co-integration relationship among price levels? (Ass. 4.4) ***
gen lnpx = log(XU/XO) 
gen lnpm = log(MU/MO) 
gen lnpxm = lnpx-lnpm
dfuller lnpx, lag(1)
dfuller lnpm, lag(1) 
more
dfuller lnpxm, lag(1)         // Marginal rejection of UR null 
more
dfuller D.lnpx, lag(1)
dfuller D.lnpm, lag(1)     
dfuller D.lnpxm, lag(1)   
more                          // Outright rejections of UR null!   
reg lnpx lnpm                 // Co-integrating regression 
predict resid_44, res
dfuller resid_44, reg
more                          // Marginal rejection of UR null, but...  
dfuller resid_44, reg nocons  // ... -nocons- saves power! 
more 

*** ARDL model for investments (Ass. 5.1) ***
reg lnio lnyo L.lnyo L.lnio 
more
reg dlnio lnyo L.lnyo L.lnio 
more
reg lnio lnyo L.lnyo L.lnio 
ofrtplot
more
reg dlnio lnyo L.lnyo L.lnio 
ofrtplot    
more

*** Error Correction Models and other simplifications (Ass. 5.2) ***
reg lnio lnyo L.lnyo          // ARDL(0,1) 
more
reg lnio D.lnyo L.lnyo        // ARDL(0,1) reformulated  
more
reg lnio lnyo D.lnyo          // ARDL(0,1) again reformulated  
more
reg lnio lnyo L.lnyo L.lnio   // Test regression
test L.lnio                   // Testing the ARDL(0,1) restriction 
more 

reg lnio lnyo L.lnio          // ARDL(1,0) or Partial Adjustment model (PAM)
more
reg dlnio lnyo L.lnio         // ARDL(1,0) reformulated
more
gen lnio_1 = L.lnio           // Preparing nonlinear estimation of PAM
nl(dlnio={gamma3=-0.5}*(lnio_1-{theta=1}*lnyo)+{gamma0}) if year>1950
                              // Estimate ARDL(1,0) nonlinearly
                              // Try to vary starting values!  
more                          // => Coincidences? Preference? 
	
*** Nonlinear estimation of ECM (Ass. 5.2c) ***
gen lnyo_1 = L.lnyo           // Preparing nonlinear estimation of ECM
nl(dlnio={alpha1=0}*dlnyo+{delta=-0.5}*(lnio_1-{beta=1}*lnyo_1)+{alpha0}) ///
                              if year>1950
test /beta=1                  // Test H0: Long-run elasticity = 1
more
*** Linear estimation of ECM for test (Ass. 5.2d) ***
reg lnio lnyo L.lnyo L.lnio   // Test regression
test lnyo+L.lnyo+L.lnio=1     // Test H0: Long-run elasticity = 1
more
nl(dlnio={alpha1=0}*dlnyo+{delta=-0.5}*(lnio_1-lnyo_1)+{alpha0}) ///
                              if year>1950
                              // Estimate restricted ECM nonlinearly
more                          // Try to vary starting values!
reg D.lnio D.lnyo L.lnapio    // Estimate restricted ECM linearly!
more                          // => Coincidences? Preference? 

*** Model in growth rates ***
reg D.lnio D.lnyo 
more 
reg lnio lnyo L.lnyo L.lnio   // Test regression
test (lnyo+L.lnyo=0) (L.lnio=1)
more
 
