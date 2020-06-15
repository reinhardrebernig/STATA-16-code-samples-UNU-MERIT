*******************************************************************************
******************** Supervised learning *********************
*******************************************************************************

 		
* Author: Reinhard Rebernig				        
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Revsion:  0002 Last change: 15/05/20 by Reinhard Rebernigclear all 
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Thesis\Methods Track\Quan\Microsimulation\Supervised learning"

use "HSNP_overview"

*Split sample into test and training data. 
set seed 1001 // set seed allows us to replicate our results even though it contains quasi random elements
gen random=runiform() // generates uniform random variable [0;1]
drop test
gen test=0
replace test=1 if random>0.1

*Part 2: OLS with consumption per adult equavalent as response variabl
*OLS works as long as there is no overfitting, to 
***********Model1***********
regress hh_kcal_ae VCI_last30days if test==0 //R-sq 0.0026
predict cons1 if test==1 
br hh_kcal_ae test cons1 //shows that it does not really make sense 


**to assess the quality of the prediction**
twoway ///
scatter hh_kcal_ae VCI_last30days || scatter cons1 VCI_last30days

**compute the residual sum of squares**
gen rs1=(hh_kcal_ae -cons1)^2     // true consumption – predicted consumption
egen rss1=total(rs1)

**compute the total sum of squares**
sum hh_kcal_ae
gen ssq=(hh_kcal_ae-r(mean))^2 if test==1   // true consumption – true mean of consumption
egen tss=total(ssq)
**compute R2**
gen rsq1=1-(rss1/tss1)
di rsq

******Model2*********
regress hh_kcal_ae VCI* i.month i.year i.county last_season penultimate_season asset* last2season_average year_average dependency_ratio land_owned land_farmed hh_TLU hhh_male hhh_age hhh_literacy HHNumAdeq com_shops com_distance_district com* floor_material rooms lighting_source wall_material own_toilet cooking_source market_distance water_source livestock nomadic religion shock* first_shock* employed_member budget_decider_male if test==0 [pw=hh_wt], r  //Adj rsq 0.45 

predict cons2 if test==1 
br hh_kcal_ae test cons2 //shows that it does not really make sense 


**to assess the quality of the prediction**
twoway ///
scatter hh_kcal_ae VCI_last30days || scatter cons2 VCI_last30days

**compute the residual sum of squares**
gen rs2=(hh_kcal_ae -cons2)^2     // true consumption – predicted consumption
egen rss2=total(rs2)

**compute the total sum of squares**
sum hh_kcal_ae
gen ssq=(hh_kcal_ae-r(mean))^2 if test==1   // true consumption – true mean of consumption
egen tss=total(ssq)
**compute R2**
gen rsq2=1-(rss2/tss2)
sum rsq2
di rsq2

*rsq2= 0.95

//imputation of price information and county information valid because correlated 

*******Model 3******
reg hh_kcal_ae c.VCI_lastmonth##(i.month i.period i.county) com* if test==0, r


******************* LASSO ********************************
findit lasso
help lasso
*lasso increases bias but decreases variance of our predictions. 


*****LASSO 1*****
lasso linear hh_kcal_ae VCI_last30days if test==0, folds(10) rseed(1001)
eststo  a //estimate store command store in a 

predict cons_lasso_a if test==1 // uses parameters of the last model estimated

*predict R2 in test data
gen rsl_a=(hh_kcal_ae -cons_lasso_a)^2     // true consumption – predicted consumption
egen rssl_a=total(rsl_a)
gen rsql_a=1-(rssl_a/tss)
sum rsql_a //0.00586


lasso linear hh_kcal_ae (VCI_last30days) period if test==0 , folds(10) rseed(1001) //parenthesis for fixed non deletable variable
eststo  b 

predict cons_lasso_b if test==1 // uses parameters of the last model estimated

*predict R2 in test data
drop rssl_b rsl_b rsql_b
gen rsl_b=(hh_kcal_ae -cons_lasso_b)^2     // true consumption – predicted consumption
egen rssl_b=total(rsl_b)
gen rsql_b=1-(rssl_b/tss)
sum rsql_b // 0.0244092



*******Lasso 2********

lasso linear hh_kcal_ae VCI* i.month i.year i.county last_season penultimate_season asset* last2season_average year_average dependency_ratio land_owned land_farmed hh_TLU hhh_male hhh_age hhh_literacy HHNumAdeq com_shops com_distance_district com* floor_material rooms lighting_source wall_material own_toilet cooking_source market_distance water_source livestock nomadic religion shock* first_shock* employed_member budget_decider_male if test==0, folds(10) rseed(1001)
eststo c

predict cons_lasso_c if test==1 // uses parameters of the last model estimated

*predict R2 in test data
gen rsl_c=(hh_kcal_ae -cons_lasso_c)^2     // true consumption – predicted consumption
egen rssl_c=total(rsl_c)
gen rsql_c=1-(rssl_c/tss)
sum rsql_c // 0.35 268 observations


lasso linear hh_kcal_ae (VCI*) i.period i.month i.year i.county last_season penultimate_season asset* last2season_average year_average dependency_ratio land_owned land_farmed hh_TLU hhh_male hhh_age hhh_literacy HHNumAdeq com_shops com_distance_district com* floor_material rooms lighting_source wall_material own_toilet cooking_source market_distance water_source livestock nomadic religion shock* first_shock* employed_member budget_decider_male if test==0, folds(10) rseed(1001)
eststo d

predict cons_lasso_d if test==1 // uses parameters of the last model estimated

*predict R2 in test data
gen rsl_d=(hh_kcal_ae -cons_lasso_d)^2     // true consumption – predicted consumption
egen rssl_d=total(rsl_d)
gen rsql_d=1-(rssl_d/tss)
sum rsql_d // 0.38 268 observations


*****Lasso 3***********
lasso linear hh_kcal_ae (VCI_last30day) c.VCI_lastmonth##(i.month i.period i.county) livestock nomadic com* if test==0, folds(10) rseed(1001)
eststo e

predict cons_lasso_e if test==1 // uses parameters of the last model estimated

*predict R2 in test data
gen rsl_e=(hh_kcal_ae -cons_lasso_e)^2     // true consumption – predicted consumption
egen rssl_e=total(rsl_e)
gen rsql_e=1-(rssl_e/tss)
sum rsql_e // 0.56 1842 observations


*****Lasso 3***********
lasso linear hh_kcal_ae (VCI_last30days) c.VCI_lastmonth##(i.month i.period i.county) hh_age hh_male livestock nomadic com* if test==0, folds(10) rseed(1001)
eststo f

predict cons_lasso_f if test==1 // uses parameters of the last model estimated

*predict R2 in test data
gen rsl_f=(hh_kcal_ae -cons_lasso_f)^2     // true consumption – predicted consumption
egen rssl_f=total(rsl_f)
gen rsql_f=1-(rssl_e/tss)
sum rsql_f // 0.56 1842 observations

*************************************************
lassocoef a b c d e, sort(coef, standardized) //shows selected predictors and sorts them by relevance 
lassogof a b c d e 



*****************************************************
*Non-parametric regression*

*no linear relationship
* 

**Kernel regression**
npregress kernel hh_kcal_ae VCI_last30days if test==0, vce(bootstrap) //use vce(bootstrap) if you want to estimate standard errors
//bootstrapped standard error allow for significant correlation. 
npgraph //only possible if you have one predictor
*estimation of mean and estimation of effect. 
predict cons_np
gen rsnp=(hh_kcal_ae -cons_np)^2   // true consumption – predicted consumption
egen rssnp=total(rsnp) if test==0  
gen rsqnp=1-(rssnp/tss)
sum rsqnp

// very flexible, a lot of small bins 
// takes forever. 