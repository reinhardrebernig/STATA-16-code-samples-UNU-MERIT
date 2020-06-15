******************************************************
*Quantitative Track: Tutorial 1 
******************************************************


**************************************************

*1) 
clear
set more off 

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Thesis\Methods Track\Quan\Tutorial 2"

capture log close
log using "5 Logs\quan1.log", replace

use "1 Input\quan1rawdata"


***************************************************
*2) 

*a) Missing data
describe
sum
codebook // no missing variables 
br
findit mdesc
ssc install dm91.pkg
findit mvpatterns



*b Recoding
help encode
help destring

encode iso3c, gen(iso3c_code)
encode indicatorID, gen(indicatorID_code)
encode country, gen(country_code)
destring date, gen(year)


*c. Check for outliers
*graphically
graph box value, over(indicatorID_code) // not valid as the graph is compressed
*numerically
sum value if indicatorID_code==3, d
return list 
count if indicatorID_code==3 & value>(3*r(sd)) | value<(3*r(sd)) // all obs are counted as outliers 
sum value if indicatorID_code==3, d
scatter value country_code if indicatorID_code==3 &  //


ssc install extremes //code for outliers
extremes value if indicatorID_code==3 //for all countries 5 lower and 5 upper outliers in GDP



*3 Drop unecessary variables 
preserve //preserve and restores data (look up help file)
keep if indicatorID_code==3 & iso2c=="EU"  // dropping all observations 
drop 
restore 

*alternatively
drop if year<2000
keep if country=="Countryname" //drops the rest




*4) Creating variables
*1 define for each variable a colum 

preserve
gen GDP=value if indicatorID_code==3
drop if GDP==.
order iso3c_code date 
save "datasetGDP.dta", replace
restore 

preserve 
gen POP=value if indicatorID_code==5
drop if POP==.
order iso3c_code date 
save "datasetPOP.dta", replace
restore 

preserve 
gen XPD=value if indicatorID_code==1
drop if XPD==.
order iso3c_code date 
save "datasetXPD.dta", replace
restore 

preserve
gen CPA=value if indicatorID_code==2
drop if CPA==.
order iso3c_code date 
save "datasetCPA.dta", replace
restore 

preserve
gen POV=value if indicatorID_code==4
drop if POV==.
order iso3c_code date
save "datasetPOV.dta", replace
restore 

order iso3c_code date

*Ordering the data in ascending or decreasing order 
sort
gsort - varname 
gsort + varname 

*5) Merging the data set

help merge 
merge m:m iso3c using "datasetXPD.dta" 
drop _merge 
merge m:m iso3c using "datasetPOP.dta" 
drop _merge
merge m:m iso3c using "datasetPOV.dta" 
drop _merge
merge m:m iso3c using "datasetCPA.dta" 
drop _merge 
merge m:m iso3c using "datasetGDP.dta"
drop _merge 



*6) Categorical income variable for low and high income
gen y_high=. 
replace y_high=1 if value>150*10^9
replace y_high=0 if value<=150*10^9
label var y_high "High income country"
label define y 1"High income country" 0"Low income country" 
label values y y_high
codebook y_high

*7 GDP per capita
gen gdp_cap=GDP/POP




******************************************
*Lecture 2
******************************************


sysuse auto

tab rep78 foreign
tab1 rep78 foreign //separate tabulations
tab2 rep78 foreign
tab1 rep78 foreign, plot
tab1 rep78 foreign, m //shows the missing values
histogram rep78, frequency

graph box mpg, over(foreign)
graph box mpg, over(foreign) noout

help graph box

sysuse nlsw88.dta, clear 
describe 
graph box wage
graph box wage, over (married) over(race) over (collgrad)
inspect tenure



******************************************
*Quan Tutorial 2
******************************************

clear
set more off 

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Thesis\Methods Track\Quan\Tutorial 2"

capture log close
log using "5 Logs\quan2.log", replace

use "1 Input\Tutorial2"



*2)	Present the descriptive statistics of the main variables
describe
codebook year
summarize

*a.	Use tabulation for the categorical variables
by year, sort: 
tab country, m 
tab year, m 
tab region, m //to see the missing values 
tab country year, m 
tab region year, m
tab mh year,m //no values for 2016
sort region year
br
codebook region  //6 missing observations. 


*b.	Use summary for continuous variables (you can also use tabstat code)
global contvar happiness mh HDI GDP Free unempl
sum contvar
help tabstat


*c.	Check the summary of statistic between, different countries, regions and years. 
by country, sort: tabstat HDI GDP, statistics(mean median p50) 
by year, sort: tabstat HDI GDP, statistics(mean median sd range count)
by year, sort: tabstat mh, statistics(mean median sd range count)
by region, sort: tabstat happiness mh HDI GDP Free unempl, statistics(mean median sd range count) by(year)

ttest happiness, by(year) //no sig increase
ttest mh, by(year)



*3)	Use histogram, bar graph and box plot explain different variables 
*a.	In general 
*b.	Try to add kdensity to the histogram as well
hist happiness, kdensity
hist GDP, normal
hist HDI, normal by(year)
hist unempl, normal by(region)

kdensity unempl, normal
hist HDI, kdensity

*c.	Within different categories: region, year, or even country
graph box happiness, over(region) over(year)
graph bar unempl, over(region) over(year)
graph bar happiness, over(region) over(year) title(happiness)


*4)	Use scatter diagram to look at the relationship between different variables: this part we look at mainly the relationship between the dependant variables and Independent variables or control variables.

help scatter

scatter happiness FreeChoice, mlab(region) mlabcolor(region) by(year) title(Happiness Index and Free Choice) ytitle(Happiness Index) || qfit happiness Free //marker label

graph twoway /// 
(scatter happiness unempl if year==2016, col(green)) ///
(qfit happiness unempl if year==2016, col(green)) ///
(scatter happiness unempl if year==2011, col(blue)) ///
 (qfit happiness unempl if year==2011, col(blue)), ///
title(Happiness index)

graph twoway /// 
(scatter happiness unempl if regionname==2, col(green)) ///
(qfit happiness unempl if regionname==2, col(green)) ///
(scatter happiness unempl if regionname==3, col(blue)) ///
 (qfit happiness unempl if regionname==3, col(blue))  ///
 (scatter happiness unempl if regionname==4, col(red)) ///
 (qfit happiness unempl if regionname==4, col(red)),  ///
title(Happiness index) legend(label(1 "Americas") label(3 "Asia") label(5 "Europe"))

*a.	Try to add label
*b.	Add the fitting line
*c.	Compare the scatter diagram between the regions and years

graph twoway /// 
(scatter happiness unempl if regionname==2, col(green)) ///
(qfit happiness unempl if regionname==2, col(green)) ///
(scatter happiness unempl if regionname==3, col(blue)) ///
 (qfit happiness unempl if regionname==3, col(blue))  ///
 (scatter happiness unempl if regionname==4, col(red)) ///
 (qfit happiness unempl if regionname==4, col(red)),  ///
title(Happiness index) note("SOURCE") legend(label(1 "Americas") label(3 "Asia") label(5 "Europe")) by(year)

graph twoway /// 
(scatter happiness unempl if regionname==2, col(green)) ///
(qfit happiness unempl if regionname==2, col(green)) ///
(scatter happiness unempl if regionname==3, col(blue)) ///
 (qfit happiness unempl if regionname==3, col(blue))  ///
 (scatter happiness unempl if regionname==4, col(red)) ///
 (qfit happiness unempl if regionname==4, col(red)),  ///
 legend(label(1 "Americas") label(3 "Asia") label(5 "Europe")) by(region year, note("SOURCE") title(Happiness index)) 

help scatter

twoway (scatter happiness GDP) ///
(lfit happiness GDP), ///
by(year, col(1) style(compact) title("TITLE", size(*10)) noiy note(source:ölkajsdfö)) xtitle("blabla") ytitle("ölkasjdf")

twoway (scatter happiness GDP) ///
(lfit happiness GDP), ///
by(year region, col(1) style(compact) noiy  title("TITLE", size(*1)) note(source:ölkajsdfö)) xtitle("blabla") ytitle("ölkasjdf")

help noiy


*Extra: Graph matrix is also very good tool to show the relationship between all variables

graph matrix happiness mh HDI GDP Free unempl

pwcorr , sig 

 
********************************************************************************
*Thesis track Tutorial 3: GLM and Multinomial logit model (Mlogit)
********************************************************************************
* Stata 16
* Last updated on 16 Jan 2020
********************************************************************************


********************************************************************************
*1)	Set your working directory and open a new log file and your data
********************************************************************************
clear
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Thesis\Methods Track\Quan\Tutorial 3"

capture log close

log using "5 Logs\quan3log.log", replace

set more off



********************************************************************************
*2)	Comparing OLS with GLM (gaussioan family)
********************************************************************************
/*2)	Here we would like study the factors affect the income level:
a.	Use normal OLS and analyse the results
b.	Analyze the results using a glm model with  Gaussian family (normal distribution) and identity link
c.	Is there any difference? Discuss!*/

/*In OLS it is assumed that the residuals are normally distributed. 
In GLM the residuals are not assumed to be normally distributed. 
Dependent variable: OLS normally distributed but in LPM 0 and 1. Probit assumes normal distribution. Logit assumes sigmoid or other distribution.*/

use "Tutorial3_1.dta", clear
regress income educ jobexp i.black
// On average, an increase of one unit of education increases the income by 1.84 units, keeping other factors constant. This result is statistically different from zero at the 1% significance level.
ssc install fitstat
findit fitstat
fitstat //Has to be executed after the regression to determine its fit statistics. AIC is the same as in GLM. Model fits!  


glm income educ jobexp i.black, family(gaussian) link(identity)
//The coefficients are the same. We conclude that the residuals are normally distributed. 
//If all assumption are satisified (GMT), nothing is better than OLS. Problem is when one of the assumption is violated. 
//AIC & BIC are quality comparison measures for GLM models. The lower the values better the better the model. 
//General: It is important to show that results are similar across models (robustness). If results improve you can argue that GLM better fit but have to present same. 



********************************************************************************
*3)	Comparing Logit with GLM (binomial family)
********************************************************************************
/*3)	Here we would like study the factors affect the grades:

a.	Use a logit model and analyse the results
b.	Analyze the results using a glm model with  binomial family (0 and one) and  the link is logit
c.	Is there any difference? Discuss!
*/
use "Tutorial3_2.dta", clear
logit grade gpa tuce i.psi
margins psi //margins of psi, comparing the prob of improving the grade for students who join the modern school is 53%. 
margins, dydx(psi) //average marginal effect - similar to mfx command. 

//Logit model: You can interpret without margins, but does not make sense. Direction and significance can be interpreted without margins. For interpretation of the coefficients you have to determine odds, margins, or marginal effects.
//If students attendent the module, there is a 53.74% higher chance for a higher grade. Whereas with the traditional module there is only a 17.99% chance for a higher grade. 
fitstat

logit grade gpa tuce i.psi, or //to calculate the odds ratio
//On average, for one unit increase in gpa the probability of improving grade increases by 16.88 odds, ctp.

help mfx
xi: logit grade gpa tuce i.psi //xi: needed for marginal effects. 
mfx //calculating marginal effects as percentage points. 
 

glm grade gpa tuce i.psi, family(binomial) link(logit)
margins psi
//Binomial only used if dependent variable is binary. Logit link function transforms into normal distribution. 
//Interpretation: same results.
//AIC and BIC test values are better in the GLM (lower).

//GLM model gives you flexibility. You can apply it even for normal distributions. OLS can be applied only for normal distrubtion of error and only in the form of LPM for binary (problem: linearity assumption is violated). For GLM no linearity is assumed. 





********************************************************************************
* 4)	Multinomial Logit model (an extension of GLM)
********************************************************************************
use "Tutorial3_3.dta", clear //make sure to download newest dataset! 
/*
Lets study the factors affects the decision of young men to choose between school and employment or no working at all. 
The current data contain information on employment and schooling for young men over year 2017

a.	Use mlogit and analyse the results 
b.	Change the base for the comparison and analyse the results
c.	Analyse the results based on the relative probability of mlogit
d.	Calculate the margins for being migrant and make a plot and analyse the results
e.	Calculate the margins for income level between 8000 and 20000 (income level changing over 4000) and analyse the results*/

help mlogit // mlogit is a model for categorical outcome/dependent variables. The actual values, which are nominal nor numerical, of the dependent variables are irrelevant (not ordered or ranked of categories - "just labels"). 
mlogit status income educ exper expersq i.migrant

/*
Here being migrant is associated with a 0.407 decrease in the relative log odds of going to school vs. work.
being migrant is associated with .501 increase in the relative log odds of staying at home vs. work.

Relative log odds: for probit increase in x increases by some number, but here comparing one with the base category. 
*/

*here we can also change the base for the categorical variable in the dependent variable
mlogit status income educ exper expersq i.migrant, base(1)


*****relative probabilities**********
** we can explain the effect better when using the relative probilities: this is the probability of choosing one outcome category over the probability of choosing the baseline category and it is calculated using exponetial from the output of the first mlogit command above i.e for migrants in outcome 1 (exp (-0.407)=0.665085)
mlogit, rrr
di exp(.312264) //checking for education between odds (0.3122) and relative probabilities (1.366515)
//Interpretation: 

/*
The relative probability of working rather than being in school is 50% (1-1.50=0.50=50% but wacky interpretation, therefore interpreation as is makes more sense) higher for migrants 
than for non-migrants with the same education and work experience. (Relative probabilities are also called relative odds.)

The relative risk ratio for a one unit increase in education is 0.512 for being in home vs. being in school, holding other factor constant.

Relative risk ratio refers to the not interpretable coefficient (relative log odds), wheras after margins you can interpret as %. 

A common mistake is to interpret this coefficient as meaning that the probability of working is higher for migrants. 
It is only the relative probability of work over school that is higher.
similarly

*/

******* predicted probabilities using margins
/*
You can also use predicted probabilities to help you understand the model. 
You can calculate predicted probabilities using the margins command. Below we use the margins command to calculate 
the predicted probability of choosing each decision comparing migrants and non migrants , holding all other variables in the model at their means. 
Since there are three possible outcomes, we will need to use the margins command three times, one for each outcome value.
*/

//margins give you incremental but absolut value to compare within categories, as opposed to the relative comparison of the GLM regression output. 
//margins, dydx is different (OLS model see above at logit model)

margins migrant, atmeans pr(out(1)) //1=school  
//percentage interpretation of incremental values: On average, the probability of being in school increases when you are a migrant by 2.27%.
marginsplot, name(School)  
margins migrant, atmeans pr(out(2))
//Prob of being at home when you are a migrant is 19.10%. The prob of not staying at home is 100-19.10%. The prob of staying at home for a non-migrant is 11.84%. Migrants are more prone to stay at home. 
marginsplot, name(home) 
margins migrant, atmeans pr(out(3))
marginsplot, name(work)   
graph combine School home work, ycommon

* lets see the effect of family income
mlogit status income educ exper expersq i.migrant, base(1) rrr
margins, at(income = (8000(4000) 20000)) predict(outcome(1)) vsquish
//At income level 1 8000 currency the probability for going to school is 5.70%. 

*****testing IIA
/* The Independence of Irrelevant Alternatives (IIA) assumption: roughly, the IIA assumption means that adding or deleting alternative outcome categories does not affect the odds among the remaining outcomes. 
Test of the IIA assumption can be performed by using the Stata command mlogtest, iia. However, as of April 23, 2010, mlogtest, iia does not work with factor variables. 
There are alternative modeling methods that relax the IIA assumption, such as alternative-specific multinomial probit models or nested logit models.
 */

 **search for Mlogtest and install the package
findit mlogtest //install spost_13
mlogit status income educ exper expersq migrant
mlogtest, iia 

//Fail to reject H0, that odds are indipendent = GOOD! Satisfies the IIA assumption! 
*Probit glm better for larger datasets. as no logit IIA assumption. 
*If the assumption is not satisfied refer to nested models with subcategories. 

estat ic //command estat was not covered in class. 
estat vce
estat sum

/*
Independence of Irrelevant Alternatives (IIA) Tests.
A stringent assumption of multinomial and conditional logit models is that outcome categories for the
model have the property of independence of irrelevant alternatives (IIA). Stated simply, this assumption
requires that the inclusion or exclusion of categories does not affect the relative risks associated with the
regressors in the remaining categories. One classic example of a situation in which this assumption would
be violated involves the choice of transportation mode; see McFadden (1974). For simplicity, postulate a
transportation model with the four possible outcomes: rides a train to work, takes a bus to work, drives
the Ford to work, and drives the Chevrolet to work. Clearly, “drives the Ford” is a closer substitute to
“drives the Chevrolet” than it is to “rides a train” (at least for most people). This means that excluding
“drives the Ford” from the model could be expected to affect the relative risks of the remaining options
and that the model would not obey the IIA assumption.
*/



/*
However
some studies show that  these tests often provide conflicting results (e.g. some
tests reject the null while others do not) and that various simulation studies have shown that these
tests are not useful for assessing violations of the IIA assumption. 
http://www.statisticalhorizons.com/iia. 
*/
********************************************************************************
use "C:\Users\Rajabzadeh\Dropbox\Iman\Projects UNU\Thesis track\GLM models\Tutorial\Tutorial3_4.dta", clear
***** Save your modified data set
save "Output/tutorial2_V1.dta", replace

********************************************************************************

***** Close log file	
log close

********************************************************************************
**************Extra information
****
/* 
In statistics, maximum likelihood estimation (MLE) is a method of estimating the parameters of a probability distribution
by maximizing a likelihood function, so that under the assumed statistical model the observed data is most probable. 
The point in the parameter space that maximizes the likelihood function is called the maximum likelihood estimate.
The logic of maximum likelihood is both intuitive and flexible, and as such the method has become a dominant means of statistical inference.

If the likelihood function is differentiable, the derivative test for determining maxima can be applied. In some cases, 
the first-order conditions of the likelihood function can be solved explicitly; for instance, the ordinary least squares estimator maximizes
 the likelihood of the linear regression model.[5] Under most circumstances, however, numerical methods will be necessary to find the maximum 
 of the likelihood function.
source: Wikipedia

*/

******Logit model
/*
Odds ratios in logistic regression can be
interpreted as the effect of a one unit of
change in X in the predicted odds ratio
with the other variables in the model held
constant.
*/


*********Mlogit model
/*
Multinomial probit regression: similar to multinomial logistic regression but with
independent normal error terms

*/
help estat
***some useful links
/*
https://www.slideshare.net/richardchandler/introduction-to-generalized-linear-models
https://stats.idre.ucla.edu/other/mult-pkg/introduction-to-generalized-linear-mixed-models/
https://stats.idre.ucla.edu/stata/dae/multinomiallogistic-regression/
https://stats.idre.ucla.edu/stata/output/multinomial-logistic-regression/
https://stats.idre.ucla.edu/stata/dae/ordered-logistic-regression/
https://www.stata.com/manuals13/rmlogit.pdf
*/


****************************************
***Lecture & Tutorial 4: Time series****
****************************************

clear all
set more off
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Thesis\Methods Track\Quan\Tutorial 4"
use "1 Input\tutorial_4"

capture log close
log using "5 Logs\quan4.log", replace

***********************************
***lecture 4 notes****
***********************************

*why: to predict the future + compare situation over time. 
*stationary & nonstationary mean and variance
*deterministic: non-random function of time
*stochastic: random, random walk
*random walk with a drift has a constant (does not go below the constant): called unit root beta0.
*autocorrelation: correlation with the past time
*co-integration: independently non stationary but together stationary. want this: bc we want to see the long run relationship between dependent and independent variable. 

*1
generate time=_n //time variable for time trend in value 1-n
generate time=q(1990q1)+n-1 //quarterly data
generate time=y(1990)+n-1 //yearly data 

*tell stata what variable represents time: 
tsset time

*2
*Lag values (past)
L.temp=temp t-1; 
generate tempL1=L1.temp
L2.temp=temp t-2

*Lead values:
F.temp=temp t+1

*Differences:
D.temp=temp t- temp t-1
D2.temp= temp t - temp t-1 -(temp t-1 - tempt-2)= temp t - 2temp t-1 + temp t-2 

*Explore visually
*when creating operators list your observations to make sure the variables are correct 
list temp D.2temp in 1/10
*limit the values listed to for example 10 first observations. 
*Stata also have several ways of creating plots and raphs to investigate your data. 
line temp year
line D.temp year if tin(1998, 2008)
*Tin (1998, 2008) = using only observations between 1998 and 2008 inclusively
tsline 

reg dinf L(1/4) .dinf if tin(1962q1, 2004q4), r 
*Dinf=delta inf
*L(1/4).dinf= use lags 1-4 

*DF tests for autocorrelations
dfuller dinf
dfuller dinf, lag(3) trend 

*co-integration tests
*before: testing unit root for var 1 and var 2 seperately. 
dfuller var1
dfuller var2
reg var1 var 2 //run reg with two variables you think are co-integrated
predict e, reside //predict residuals for your estimation
dfuller e //perform a unit root test (using DF) on the residuals from the regression 




***********************************
***Tutorial 4****
***********************************
*Here we would like to study the factors affect the total consumption of the economy using a time series data.

*1)	Set your working directory and open a new log file



*2)	Declare your data as time series: 
*a.	Identify or set your time variable
tsset year //variable needs to have the same distance in time. 

*b.	What would you do if the time variable is not continuous (missing year, month or quarter ….)
//you have to deconstruct the data, gen new time variable to have a continous variable to be able to apply the ts analysis. Use a new time indicator e.g. 1,2,3,4,... 

*c.	Set your model as time series
//see a.

*3)	work with operators in time series analysis
*a.	make lag variables for one- and two-years lags and list them
//LAG= year before = t-1(L)
// lead=following year = t+1(F)
// diff: t - (t_-1)
gen consump1=L1.consump
gen consump2=L2.consump
gen totinc1=L1.totinc
gen totinc2=L2.totinc
list year consump* totinc* in 1/5


*b.	make lead variables for one- and two-years and list them
gen consumpF1=F1.consump
gen consumpF2=F2.consump
gen totincF1=F1.totinc
gen totincF2=F2.totinc
list year consump consumpF* totinc totincF*
*c.	make difference variables for one- and two-years and list them
gen consumpD1=D1.consump
gen consumpD2=D2.consump
list year consump* 

*4)	Check the variables for trends and test for nonstationary assumption
*a.	Use line graph to look at the trends in different variables
line consump year
line D1.consump year //same as using consumpD1 = shows the first difference
line D2.consump year //D2 is more stationary around the mean (here:0). (D2 is the difference between differences) 
reg consump govt if tin(1920,1929)
reg consump govt if tin(1930,1939) //no sig correlation as lag between gov exp and consumption. 
//as the graphical analysis showed an economic downturn we decide to do two regressions.

*i.	Is there any trend in the variables?
//unit root of around 40 (constant)
//random walk with a drift
//trend? vaguely increasing? 
//depression of the 30's visible?
// whole economy consumption: huge growth as demand from military-industrial complex during ww2
//non-stationary on the mean and variance. 

*b.	Test for unit root using Dickey-Fuller test
dfuller consump //compare critical values with test statistics. 
//critical t value for 5% = 3 
//H0: There is an unit root. We fail to reject H0. |-0.442|< Z(t)|-3| (absolute values ||)
//In general no unit root and stationarity is preferred. 

dfuller consumpD1
dfuller consumpD2
//stationarity in differences increases. 
//if it is not stationarity at level, then try first, second, third difference ... 
//here we would decide to work with the second difference. 

*i.	Also look at 3 years lags for this test
dfuller consump, lags(3) trend reg //to control for trend (Augmented DF test) to adress autocorrelation. 
//trend sig at 10% = increase of consumption over time regardless of other variables. 

*Limitations of Dickey in autocorrelation (how last years consumption affects this years consumption: error term between t-1 and t is correlated)



*5)	Explore autocorrelation and the relationship between consumption (consump) and other variables
*a.	test autocorrelation for consumption using 4 years lag: use corrgram function
corrgram consump, lag(4)
//Box-Spears Q. H0, all variables are independent. Corr between lagged vars=0. If we fail to reject H0, that means there is correlation between the different lags. 
//length of line shows correlation between different years. 1st autocorr is about 0.7=high autcorrelation. Compare AC. The more time difference between observations the less autocorrelation. Partial autocorr: immediate lag of that variable eg. xt and xt-1. Significant correlation (check p-value)
ac consump
//x asis lags
//y autocorr of consump. 
//any line outside of grey area=autcorrelation 
//There is a autocorrelation with the first lag. 
ac D1.consump
// still autocorrelation 
ac D2.consump
// no autocorrelation. D2 solved all our problems so far. 


*b.	check the relationship between consumption and other variables using xcorr function
xcorr govt consump, lag(4) table
 
*i.	use the graph or table to explain the relationship
//lag zero = the immediate effect of govt exp on consumption. positive and high correlation (about 70%). Lag 1 would be last years govt exp with this years consumption level. Immediate and next immediate impact are high. Correlation of govt and consump before 4 years is rather low. 

*6)	Test for co-integration between the consumption (consump) and government expenditures (govt)

reg consump govt //run reg with two variables you think are co-integrated
predict e, resid //predict residuals for your estimation
dfuller e //perform a unit root test (using DF) on the residuals from the regression 
//H0:No co-integration. Fail to reject H0. They are not co-integrated.
dfuller e, lag(4) 
//If we account for lags, reject H0, there exists co-integration. 
dfuller e, lag(10)
//large number of lags leads to missing a lot of our observations.  


*7)	Regress your model, check the effect of the trend in the model and check how is it different when you check the effect of the variables after being detrended 
*a.	Regress your model without trend and look at R2
reg consump govt
//R-squared       =    0.4687
//We reject the H0, that gov exp has no effect on consumption. 

*b.	Regress your model with trend and look at R2 
// first process:
//second process: detrending
reg consump L.consump govt
//R-squared       =    0.8348
//govt becomes insignificant when accounted for consump lag. 
*c.	Regress consumption(consump) on government expenditures(govt) with trend
*d.	Now detrend the variable consumption and government expenditures
*i.	Regress each variables on time and calculate the residuals using predict function
*ii.	Regress the residuals of consumption on the one of government expenditures
*e.	Compare the results of the detrended regression with previous model (including the trend)
reg consump year
predict consumpdt, resid
reg govt year
predict govtdt, resid
reg consumpdt govtdt //using detrended variables. 
//now only significant at 10%.

reg consump L.consump capital totinc taxnetx govt //Including the lagged consumption seriously affects the significance of the other variables. 



/*General STEPS in Time Series Analysis
1) Check unit root /Stationarity
If unit root: adress problem 
If not unit root: adress co-integration
dfuller on every variable
2) Autocorrelation
use D1 D2 Dx as solution. 
3) Co-integration
4) Regression. 
*/


********************************************************************************
*Thesis track Tutorial 5: Panel data
********************************************************************************
* Stata 16
* Last updated on 27 Jan 2020
********************************************************************************

********************************************************************************
*1)	1)	Set your working directory and open a new log file
********************************************************************************
clear all
set more off
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\MPP Thesis\Methods Track\Quan\Tutorial 5"
use "1 Input\Tutorial_5(1).dta"

capture log close
log using "5 Logs\quan5.log", replace

********************************************************************************
*1)	use OLS to check for the effect of and compare it with  fixed effect in OLS system
********************************************************************************

*a.	OLS model without country variable
*b.	OLS model with country variable to control for the effect of differences between the countries
*c.	Is there any difference?

reg GDP_Gr   conflict Pol_open Corruption voice autocracy military_role 
estimates store OLS //saving estimates for later.
fitstat //information about the model fit 
//On average in case there is a conflict, GDP growth reduces by -0.18, ctp. This result is statistically different from zero at the 1% significance level. The model explains 58% of the variance in data. 

reg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.ccode
estimates store OLS_dummy1
fitstat

xi: reg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.ccode
estimates store OLS_dummy2
fitstat

estimates tab OLS_1 OLS_2 OLS_3, star stats(N r2 aic bic r2_a) //comparing estimates, many different options for stats


//R2 raises, country effects are insignificance but ok to include as controls as it makes sense. 
//comparing two models with R2 is insufficient -> use adjusted R2 (the higher the biggger) to compare or AIC BIC (the smaller the better).
//Bayesin Information Criteria: Baysian prob dependent events are happening. Chess move thinking. If this model is applied to a different dataset would it be a true model? 
// 
********************************************************************************
* 3)	Use Panel Data fixed effect analysis and compare it with normal OLS fixed effect model
******************************************************************************** 

xtset ccode year //setting the panel with automatic delta(1)
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, fe
estimates store OLS_fe

xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.ccode, fe vce(cluster ccode)
estimates store OLS_fe_vce_ccode

*comparing all models. 
estimates tab OLS OLS_dummy1 OLS_dummy2 OLS_fe OLS_fe_vce_ccode, star stats(N r2 aic bic r2_a)
//magnitutes of coefficients and significance level do not change when using panel data
//aic decreases in panal data so it is better to use panel. 
//fixed effects model would drop time invariant effects. 
********************************************************************************
*4) Use graphs to check the variables and check for the differences between the years and countries
********************************************************************************
/*a.	Summarize your data in a panel system (xtsum command)
b.	Use line graph for the panel data for different variables (Xline command)
c.	Generate the mean of your dependent variable for different countries and the use scatter and connected graphs to compare the means 
d.	Generate the mean of your dependent variable for different years and then use scatter and connected graphs to compare the means*/ 

xtsum 
//year between country no difference
// but difference within years (=between years)
xtline GDP_Gr
xtline GDP_Gr, overlay
xtline GDP_Gr if Corruption==0, overlay
xtline GDP_Gr if Corruption==1, overlay 
xtline autocracy, overlay
pwcorr GDP_Gr autocracy if ccode==7, sig //Tutor hints at negative correlation but none visible. 

*c
drop y_mean*
bysort ccode: egen y_mean_c=mean(GDP_Gr)
twoway scatter GDP_Gr ccode, msymbol(circle_hollow) || connected y_mean_c ccode, ///
msymbol(diamond) || , xlabel(1981(1)1990)
// did not work till the end? 

bysort year: egen y_mean_y=mean(GDP_Gr)
twoway scatter GDP_Gr year, msymbol(circle_hollow) || connected y_mean_y year, ///
msymbol(diamond) || , xlabel(1981(1)1990)
//works. just three countries pull the mean GDP_Gr up in 1984 than compared to 1981

*me being extra: Testing this hypothesis. 
graph box GDP_Gr, over(year)
gen tyear=.
replace tyear=0 if year==1981
replace tyear=1 if year==1984
ttest GDP_Gr, by(tyear)





*******************************************************************
*5) Test if you have to use a fixed effect in your model and also test for time fixed effect
********************************************************************************
****Fixed effect test using "hausman" 
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, fe 
estimates store fixed
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, re
estimates store random
hausman fixed random
//H0: difference in coefficients are not systematic -> choose RE
//H1: differe in coeff is systematic -> FE
// p>0.05 we faile to reject H0 and have to use random effects. 

//FE: account for correlation between error term ui and any of the indipendent variables. 
//RE: assume no correlation between error term ui and any of the indipendent variables - very strong ass. Advantage: see impact of time-invariant variables as e.g. gender effect would in FE be omitted as usually time invariant (does not really change over time?). 


*Additionally*
xi: regress GDP_Gr conflict i.ccode
predict yhat
separate GDP_Gr, by(ccode)
separate yhat, by(ccode)

twoway connected yhat1-yhat10 conflict, msymbol(none diamond_hollow triangle_hollow square_hollow + circle_hollow x) ///
msize(medium) mcolor(black black black black black black black) || lfit GDP_Gr conflict, clwidth(thick) clcolor(black)
//bold black for OLS_1
//fe model uses colour lines difference for each entity across time. 

***Time fixed effect using "testparm" command
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.year, re
testparm i.year

xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.year, fe
testparm i.year

/*
The Prob>F is > 0.05, so we
failed to reject the null that the
coefficients for all years are jointly
equal to zero, therefore no time fixedeffects
are needed in this case.
*/

//we do not need to include time fixed effects because they are not significantly differet from zero. 

***alternatively***
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role i.year, fe
estimate store OLS_fe_time
testparm i.year

//only using cluser standard error when have at least 30 cluster(here only 10 countries)! otherwise use robust standard error or bootstrap. if not test with cameron test and test each cluster seperately. 
//for the vce(boot): for clustered standard error I'm forcing STATA to give small standard errors therefore the result will be significant for testparm. 



********************************************************************************
* 6) test for cross-sectional dependence/contemporaneous correlation in a fixed effect model	
********************************************************************************
**Breusch-Pagan LM test of independence

//problem for macro and large panels not for small and micro data. 

ssc install xttest2
help xttest2
help bpagan
help Breusch-Pagan
useless

xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, fe
xttest2 //ten error terms for the 10 entities, correlation matrix of residuals. 
//H0: The error terms are uncorrelated/independent. There is no cross-sectional dependence/contemporaneous correlation. 
// We fail to reject the H0 as p0.7277>0.05. There is no cross-sectional dependence.  






********************************************************************************
* 7)	Test for serial correlation and heteroskedasticity in a fixed effect model
********************************************************************************
**Serial correlation

search xtserial
* use package SJ3-2 st0039 and install

xtserial GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role
//H0: no first order autcorrelation
//We fail to reject H0 with p 0.8921 and conclude there is no autocorrelation. 



** Hetroskedasticity

ssc install xttest3
xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, fe
xttest3
//H0: homoskedasticity 
//H0: sigma ui^2=sigma^2
//sigma is variance
//sigma^2 costant variance
//costant variance  
//we reject the H0, so there is heteroskedasticity. 

xtreg GDP_Gr  conflict Pol_open Corruption  voice autocracy military_role, fe vce(robust)
//adressing the heteroskedastic standard error. 
estimate store OLS_fe_vce_robust 

estimates tab OLS OLS_dummy1 OLS_dummy2 OLS_fe OLS_fe_vce_ccode OLS_fe_time OLS_fe_robust, star stats(N r2 aic bic r2_a)


********************************************************************************
***** Save your modified data set
save "2 Output/tutorial5_V1.dta", replace

********************************************************************************

***** Close log file	
log close





********************************************************************************
*Thesis track Tutorial 6: Data Visulization
********************************************************************************
* Stata 16
* Last updated on 28 Jan 2020
********************************************************************************

********************************************************************************
*1)		Set your working directory and open a new log file
********************************************************************************
clear all
set more off
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\MPP Thesis\Methods Track\Quan\Tutorial 6"
use ""

capture log close
log using "5 Logs\quan6.log", replace


********************************************************************************
*2)	Open the first data using the link and Make a line graph on life expectancy
********************************************************************************
sysuse uslifeexp.dta, clear

* a) make a line graph on life expectancy
*use different Schemes for your graph i.e. s1mono or economist
/* to see list of scheme names: graph query, schemes
to change default scheme:
set scheme schemename
*/

graph query, schemes
line le year, scheme(s1mono)
line le year, scheme(economist)
line le year, scheme(s2color8)
line le year, scheme(s1rcolor)
twoway scatter le year || fpfit le year, scheme(s1mono) //fractional proportion fit
set scheme s2color8

********************************************************************************
* 3)	Draw a line graph for multiple dependent variables over year
********************************************************************************
* use le_wmale le_wfemale le_bmale le_bfemale

line le_wmale le_wfemale le_bmale le_bfemale year, scheme(s1mono)



********************************************************************************
*4) Add a text (1918 Influenza Pandemic) refering to the point "1918 and 30" when Influenza Panademic happened  
********************************************************************************
help added_text_options
*locate the text in point (32 1920)
line le_wmale le_wfemale le_bmale le_bfemale year, scheme(s2color8) text(32 1920 "1918 Influenza Pandemic", place(e) box just(center))

*alternatively 
line le_wmale le_wfemale le_bmale le_bfemale year, scheme(s2color8) text(32 1920 "{bf:1918}{it:influenza} Pandemic", place(3)) //"bf" stands for bold font and "it" stands for italics. 

*alternatively combining different graphs. 
line le_wmale year, saving(whitemale)
line le_bmale year, saving(blackmale)
line le_wfemale year, saving(whitefemale)
line le_bfemale year, saving(blackfemale)

gr combine whitemale.gph whitefemale.gph blackmale.gph blackfemale.gph, col(1) row(4) iscale(0.5) xcomm //iscale is 


*******************************************************************
*5) combine a scatter plot and its fit line for life expectancy "le" 
********************************************************************************

*a) for years above 1950

twoway ///
(scatter le year) || (qfit le year) if year>1950

*b)combine the scatter and the linear fitting line for for the life expectancy two separate years: a) years between 1925 and 1950 and b)for years above 1950

twoway ///
scatter le year if year>1950 || ///
qfit le year if year>1950 || ///
scatter le year if year>=1925 & year <=1950 || /// 
qfit le year if year>=1925 & year <=1950 

*alternatively
#delimit;
scatter le year if year>=1925 ||
lfit le year if year>=1925 & year <1950 ||
lfit le year if year>=1950;
#delimit cr
help delimit //command resets the character that marks the end of a
    command.  It can be used only in do-files and ado-files.


* c) combine the scatter and the linear fitting line for the life expectancy within two categories of male and  female for years years above 1950

twoway (scatter le_male year) || (scatter le_female year) if year>1950

*alternatively 
#delimit;
scatter le_male le_female year if year>=1950 ||
lfit le_male year if year>1950 ||
lfit le_female year if year>1950;
#delimit cr


*alternatively for the two periods
twoway ///
scatter le_male year if year>1950 || ///
qfit le_male year if year>1950 || ///
scatter le_male year if year>=1925 & year <=1950 || /// 
qfit le_male year if year>=1925 & year <=1950 || ///
scatter le_female year if year>1950 || ///
qfit le_female year if year>1950 || ///
scatter le_female year if year>=1925 & year <=1950 || /// 
qfit le_female year if year>=1925 & year <=1950 

* d) in the previous graph add the title "US Male and Female Life Expectancy, 1950-2000" and Removing the Legend

twoway (scatter le_male year) || (scatter le_female year) if year>1950, title("US Male and Female Life Expectancy", box span) legend(off)

*alternatively 
#delimit;
scatter le_male le_female year if year>=1950 ||
lfit le_male year if year>1950 ||
lfit le_female year if year>1950, 
title("US Male and Female Life Expectancy", box span) legend(off);
#delimit cr //span fits to the plot. 

*alternatively
twoway ///
scatter le_male year if year>1950 || ///
qfit le_male year if year>1950 || ///
scatter le_male year if year>=1925 & year <=1950 || /// 
qfit le_male year if year>=1925 & year <=1950 || ///
scatter le_female year if year>1950 || ///
qfit le_female year if year>1950 || ///
scatter le_female year if year>=1925 & year <=1950 || /// 
qfit le_female year if year>=1925 & year <=1950, ///
title("US Male and Female Life Expectancy, 1950-2000") legend(off)

help nolegend


* e) now add a text (i.e. Femail) for female graphs in point (75 1978) and one for male graphs  at point (68 1978) 
* and a title for Y vector "Life expectancy at birth"

twoway (scatter le_male year) || (scatter le_female year) if year>1950, title("US Male and Female Life Expectancy", box span) legend(off) text(75 1978 "Female") text(68 1978 "Male") ytitle("Life expectancy at birth")

*alternatively 
#delimit;
scatter le_male le_female year if year>=1950 ||
lfit le_male year if year>1950 ||
lfit le_female year if year>1950, 
title("US Male and Female Life Expectancy", box span) legend(off)
text(75 1978 "Female") text(68 1978 "Male") 
ytitle("Life expectancy at birth") xtitle("Year");
#delimit cr //span fits to the plot. 


twoway ///
scatter le_male year if year>1950 || ///
qfit le_male year if year>1950 || ///
scatter le_male year if year>=1925 & year <=1950 || /// 
qfit le_male year if year>=1925 & year <=1950 || ///
scatter le_female year if year>1950 || ///
qfit le_female year if year>1950 || ///
scatter le_female year if year>=1925 & year <=1950 || /// 
qfit le_female year if year>=1925 & year <=1950, ///
title("US Male and Female Life Expectancy, 1950-2000") legend(off) ///
text(75 1978 "Female") ///
text(68 1978 "Male") ///
ytitle("Life expectancy at birth")


********************************************************************************
* 6) Showing Confidence Intervals, Labelling Axes, Modifying Legend	
********************************************************************************
*open new dataset in bellow
sysuse lifeexp.dta, clear

* a) make a scatter plot for life expectancy ("lexp") and safe water ("safewater") for region area 2

scatter lexp safewater if region==2, title("Life expectancy at birth")

*95 ci
#delimit;
twoway (lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2);
#delimit cr

*90ci
#delimit;
twoway (lfitci lexp safewater if region==2, level(90))
(scatter lexp safewater if region==2);
#delimit cr

*90 ci entire region
#delimit;
twoway (lfitci lexp safewater, level(90))
(scatter lexp safewater);
#delimit cr

* b) add title "Life expectancy at birth by access to safe water, 1998" and add legends for the fit line "Linear fit" and confidence interval "95% CI" 

#delimit;
twoway 
(lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2), 
title("Life expectancy at birth by access to safe water, 1998")
legend(order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr //3 would be for the scatter point - like dialpad positioning. 



* c) add title for Y vector "Life expectancy at birth" and for X vector "Percent of population with access to safe water"

#delimit;
twoway 
(lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2), 
title("Life expectancy at birth by access to safe water, 1998")
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr //3 would be for the scatter point - like dialpad positioning.

* d) Add labels (country name) and subtitles "North and center America"

#delimit;
twoway 
(lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2, mlabel(country)), 
 title("Life expectancy at birth by access to safe water, 1998")
 subtitle("North and Center America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr //ring=where the clock spins, position of five of clock, positive is outside, negative pushes out  

	
*optional) change the position of the markers: using "mlabvposition(var)" option
***** first generate a variable for the position and for each city give a position number that you want it ot show
***** then use option "mlabvposition(var)"
gen pos=12 if country=="Panama"
replace pos=6 if country=="Honduras"
replace pos=10 if country=="Cuba"
replace pos=9 if country=="Jamaica"
replace pos=9 if country=="El Salvador"
replace pos=9 if country=="Trinidad and Tobago"
replace pos=9 if country=="Dominican Republic"
replace pos=3 if country=="Mexico"
replace pos=6 if country=="Puerto Rico"
replace pos=9 if country=="Canada"

#delimit;
twoway 
(lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2, 
mlabel(country) mlabvposition(pos)), 
 title("Life expectancy at birth by access to safe water, 1998")
 subtitle("North and Center America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(2 "Linear Fit" 1 "95% CI" 3 "Observations") 
 cols(1))
 plotregion(margin(r+10));
#delimit cr //ring=where the clock spins, position of five of clock, positive is outside, negative pushes out  


*e) to the previous graph in task d) now add region 3 without labels and add legend "North America" and "South America"

#delimit;
twoway 
(scatter lexp safewater if region==2)
(scatter lexp safewater if region==3), 
 title("Life expectancy at birth by access to safe water, 1998")
 subtitle("North and Center America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(1 "North America" 2 "South America")
 cols(1))
 plotregion(margin(r+10));
#delimit cr 


* f) add linear fit line to the scatter diagram and add legend for those lines

replace pos = 9 if country == "Argentina"
replace pos = 9 if country == "Canada"
replace pos = 9 if country == "Cuba"
replace pos = 9 if country == "Panama"
replace pos = 9 if country == "Venezuela"
replace pos = 9 if country == "Jamaica"
replace pos = 9 if country == "Dominican Republic"
replace pos = 9 if country == "Ecuador"
replace pos = 9 if country == "El Salvador"
replace pos = 12 if country == "Puerto Rico"
replace pos = 3 if country == "Trinidad and Tobago"

#delimit ;
twoway
(scatter lexp safewater if region == 2
,mlabel(country) mlabvposition(pos))
(scatter lexp safewater if region == 3
,mlabel(country) mlabvposition(pos))
,title("Life expectancy at birth by access to safe water, 1998")
subtitle("North and South America")
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(ring(0) pos(5) order(1 "North America" 2 "South America") cols(1));
#delimit c


#delimit ;
twoway
(scatter lexp safewater if region == 2)
(scatter lexp safewater if region == 3)
(lfit lexp safewater if region == 2)
(lfit lexp safewater if region == 3)
,title("Life expectancy at birth by access to safe water, 1998")
subtitle("North and South America")
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(ring(0) pos(5) cols(1) order(1 "North America" 2 "South America"
3 "North America linear fit" 4 "South America linear fit"));
#delimit cr

* g) add country labels and change the Marker Size and Symbol
* h) change the lines and change all colors  

#delimit ;
twoway
(scatter lexp safewater if region == 2
,mlabel(country) mlabvposition(pos) msize(small) mcolor(black) mlabcolor(black))
(scatter lexp safewater if region == 3
,mlabel(country) mlabvposition(pos) msize(small) mcolor(black) mlabcolor(black)
msymbol(t))
(lfit lexp safewater if region == 2, clcolor(black))
(lfit lexp safewater if region == 3, clcolor(black) clpattern(dash))
,title("Life expectancy at birth by access to safe water, 1998", color(black))
subtitle("North and South America")
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(ring(0) pos(5) cols(1) order(1 "North America" 2 "South America"
3 "North America linear fit" 4 "South America linear fit"));
#delimit cr
//circle_hollow as msymbol option. 







********************************************************************************
* 7)	Separate Graphs for Each Subset of Data using By-Graph
********************************************************************************
* a) for each region make and combine a scatter plot for life expectancy ("lexp") and safe water ("safewater") use "by" option
**add title for x and y vectors as before

#delimit ;
twoway scatter lexp safewater, by(region, total) // total option here will add a forth graph combining all regions
,ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water");
#delimit cr


* b) set Axis Scale, Ticks and Labels

#delimit ;
twoway scatter lexp safewater
, by(region,total style(compact)
title("Life expectancy by access to safe water") note("") ) //option note empty will exclude the by region text from the bottomn
xscale(range(20 100))
xtick(20(10)100)
xlabel(30(10)100, labsize(small))
xtitle("Percent of population with access to safe water")
ytitle("Life expectancy at birth")
ylabel(55(5)80, angle(0));
#delimit cr


********************************************************************************
* 7)	Storing graphs in memory and Combining them
********************************************************************************
*a) use the graph in excersize 6-d and store it with the name "North_Center_America"
** without title

#delimit;
twoway 
(lfitci lexp safewater if region==2)
(scatter lexp safewater if region==2, mlabel(country)),
 subtitle("North and Center America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr
graph save "\4 Graphs\"
graph export "\4 Graphs "

#delimit;
twoway 
(lfitci lexp safewater if region==3)
(scatter lexp safewater if region==2, mlabel(country)),
 subtitle("North and Center America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr

*b) do the same graph for region 3 and store it with the name "South_America"
* remember to change the subtitle

#delimit;
twoway 
(lfitci lexp safewater if region==3)
(scatter lexp safewater if region==3, mlabel(country)),
 subtitle("South America", color(blue))
 ytitle("Life expectancy at birth")
 xtitle("Percent of population with access to safe water")
 legend(ring(0) pos(5) order(2 "Linear Fit" 1 "95% CI" 3 "Observations"));
#delimit cr

* c) combine the graphs and add table
** you can change the graphs from a row to colomn 


#delimit ;
twoway
(scatter lexp safewater if region == 2,
mcolor(black) msize(small)
mlabel(country) mlabvposition(pos) mlabcolor(black))
(lfit lexp safewater if region == 2, clcolor(black))
,name(north_america, replace) //change the name
subtitle("North America", color(black))
ylabel(,angle(0))
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(off)
saving("North_Center_America");
#delimit cr

#delimit ;
twoway
(scatter lexp safewater if region == 3,
mcolor(black) msize(small)
mlabel(country) mlabvposition(pos) mlabcolor(black))
(lfit lexp safewater if region == 3, clcolor(black))
,name(south_america, replace)
subtitle("South America", color(black))
ylabel(, angle(0))
ytitle("Life expectancy at birth")
xtitle("Percent of population with access to safe water")
legend(off)
saving("South_America");
#delimit cr

************Combining Graphs

graph combine north_america south_america , title("Life expectancy by access to safe water", color(black)) col(1)

graph combine north_america south_america ,title("Life expectancy by access to safe water", color(black)) ///
xcommon ycommon xsize(7) ysize(10.5) col(1)

graph export "combinedamericas.png"
graph export "4 Graphs\combinedamericas.png"
graph save "combinedamericas.gph"
graph export "4 Graphs\combinedamericas.gph"

graph export "combinedamericas.pdf"
graph export "4 Graphs\combinedamericas.pdf"
graph save "combinedamericas.pdf"
graph export "4 Graphs\combinedamericas.pdf"




********************************************************************************
* 8)	Export the graphs using different formats
********************************************************************************

graph export "combinedamericas.png"
graph export "4 Graphs\combinedamericas.png"
graph save "combinedamericas.gph"
graph export "4 Graphs\combinedamericas.gph"

graph export "combinedamericas.pdf"
graph export "4 Graphs\combinedamericas.pdf"
graph save "combinedamericas.pdf"
graph export "4 Graphs\combinedamericas.pdf"


*vector formats contain drawing instructions (.wmf .emf .ps .eps .pdf)
********************************************************************************


*trying something else

sysuse citytemp, clear
help rarea

twoway rarea d1 zero x1, color("blue%50") ///
   ||  rarea d2 zero x2, color("purple%50") ///
   ||  rarea d3 zero x3, color("orange%50")  ///
   ||  rarea d4 zero x4, color("red%50") ///
        title(January Temperatures by Region) ///
        ytitle("Smoothed density") ///
      legend(ring(0) pos(2) col(1) order(2 "NC" 1 "NE" 3 "S" 4 "W"))    

graph export kernel.png, width(500) replace

********************************************
twoway kdensity tempjan, by(region)

forvalues i=1/4 {
    capture drop x`i' d`i'
   kdensity tempjan if region== `i', generate(x`i'  d`i')
    }
       
gen zero = 0
#delimit ;
twoway rarea d1 zero x1, color("blue%50")
   ||  rarea d2 zero x2, color("purple%50")
   ||  rarea d3 zero x3, color("orange%50") 
   ||  rarea d4 zero x4, color("red%50")
        title(January Temperatures by Region)
      ytitle("Smoothed density") ///
      legend(ring(0) pos(2) col(1) order(2 "NC" 1 "NE" 3 "S" 4 "W"));    
#delimit cr
graph export kernel.png, width(500) replace


***** Close log file	
log close



https://stats.idre.ucla.edu/stata/code/graphing-means-and-confidence-intervals-by-multiple-group-variables/










