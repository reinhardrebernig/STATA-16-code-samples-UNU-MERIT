*******************************************************************************
******************** Regression Analysis II **************************
						*Overview*
*******************************************************************************

* Tutorial 1-7 notes
* Topics: Endogeneity & model validity, binary outcome variables instrumental variables validity, fixed effects, time fixed effects, panal data and instrumental variables.  		
* Author: Reinhard Rebernig				        
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Revsion:  0007 Last change: 15/05/20 by Reinhard Rebernig






****************************************************************************
*****Tutorial 1: Tutorial 1: Endogeneity and model validity
**************************************************************************



/*1. Imagine you a re in a coffee break with a friend who is enthusiastic about
econometrics but has little o r no knowledge in econometric techniques.
Explain to him/her what endogeneity in applied research means and discuss
the implications for causality.*/

Endogeneity means that assumption 1 of the GM Theorem is violated. 
𝐸𝑢𝑖𝑋=𝑥=0
GM asssumption 1: The conditional mean of 𝑢𝑖given { 𝑋1𝑖,…, 𝑋𝐾𝑖}=0
𝐸𝑢𝑖𝑋1𝑖,…,𝑋𝐾𝑖=0
The error term ui is independent of the regressor. 𝐸𝑢𝑖𝑋𝑖=𝐸(𝑢𝑖) - does not apply! 
The error term is correlated to x. 
There is a part in the unobserved part of the model, in the 
error term u s hould be randomly distributed around a mean of 0 (normally unobserved)
In practice, we observe residuals (difference between the observed and predicted value)




/*2. Consider the simp le regression model:
crime = β 0 + β 1 unemployment + u,
where crime is the crime rate and unemployment is the unemployment rate of a district. Can you think of some reasons why the unobserved factors in u might be correlated with unemployment? Discuss with your peers.*/

simultaneity 
economic development less bc of crime rate - business do not want to go there, thereby crime causes unemployment




/*3. A researcher want s to estimate a model relating R&D expenditure to firms’ profit level using a data set spanning the years 2010 through 2017. The sample used i s not a random sample of firms in the data set, because many firms before 2012 did no t report R&D expenditure. Discuss potential biases that
may threaten the validity of this study.*/

sample selection bias, data is missing endogenously (not at random)


case 3 data are missing conditional on Y or u -> systematic. 
This has an effect on the internal validity
Estimated coefficients are biased ––“Sample Selection





/*4. A researcher estimates the effect of development aid on poverty by regressing the poverty head count ratio on the amount of aid a country received using country level data. Discuss potential biases that may threaten the validity of this study.*/




/*5. Let us have another look at the tutorial of Regression A nalysis 1: “As a team of social scientists, you are interested in studying the effect of schooling on earnings and see whether the effect of edu cation on earnings has changed over time and whether i t varies across the two genders. Go through each of the dimensions discussed during the lecture and d iscuss
the model validity. Be specific about the potential sources of endogeneity.*/


/*6. Do you think t hat the results are trustworthy? Why (not)?*/



****************************************************************************
*****Tutorial 2: binary outcome variables
**************************************************************************

clear all
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 2\1 Input"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 2\1 Input\psid.dta"


* 1. Use a scatterplot to discuss the relationship in the data between the labor market participation status (inlf) and the number of children the person has (kidslt6). (hint: use the jitter(10) option to reduce problems with overlapping observations)

twoway (scatter inlf kidslt6, jitter(10)) (lfit inlf kidslt6) // without jitter the marker (count/observations are on the same spot, jitter is the radius to spread the ovservations)

*Less observations (less bulk), in higher kids categories. 
*There is a negative relationship between the labor market participation and the number of kids younger than 6 years old - the more kids you have the less probable you are enter the labour market. 

pwcorr inlf kidslt6, sig // -0.0657




*2. Build an OLS model to estimate the effect of the number of children under the age of 6 (kidslt6) on the labor market participation inlf. Include years of schooling (educ) and at least three additional control variables in the estimation model. Interpret the estimated effect of kidslt6.

*inlfi=_b0+_b1kidslt6+_b2educ+_b3exper+_b4female+_b5c

reg inlf kidslt6 educ exper age spousewage female,r //linear probability model LPM
*The effect of having kids under the age of 6 on labour market participation is negative. 
*Alternatively: There is a negative relationship between having kids younger than age 6 and labour market participation. 
*On average, the probability to work decreases by 5.01% for every additional child under the age of 6, ceteris paribus. This result is statistically different from 0 at the 1% significance level. The model explains 26% of the variance of the observations. 

*On average, if you are female your probability to work decreses by 17.31%, ceteris paribus. This result is statistically different from 0 at the 1% significance level. The model explains 26% of the variance in observations. 




* 3. Based on the model predict a variable called y_hat (use STATA’s predict command). Use a scatter plot todisplay the relationship between y_hat and kidslt6. Interpret the differences compared with the previous graph and discuss the model fit? Why are some of the prediction problematic?

predict y_hat, xb 
//predicts the dependent variable from the build linear probability model; default mode: xb= linear prediction = default 
*y_hat is supposed to be the predicted variable from the model 
*stata predicts values so that the error is zero? 
twoway (scatter inlf kidslt6, jitter(10)) (scatter y_hat kidslt6, jitter(10))

//
*1. Problem: probability is bound between 0 and 1, values above 1 makes no sense, either yes or not (binary variable as predicted variable). 
*???Happens when you have heteroskedasticity??? 
*The linear probability model does not give the corresponding predictions. 
count if y_hat>1 //check for values above 1 - doesnt make sense. 

//for binary you use probit or logit or Maximum Likelihood estimation. Cases in which to use LPM for simplicity - only interested in the jump not in the estimates. Doesent matter if it is precise or not. Gives an first indication. LPM is also a simple descriptive method for data analysis. 
*???"Discriptive choice models."???

/* Problems:
- linear relationship doesn't make sense for binary outcomes. It doesn't make sense to predict values outside the [0;1] boundaries. Predicted Possibilities can be <0 or >1
- prediction is not accurate
- we are assuming a constant marginal effect (not applicable for non linear relationship): partial derivative is constant
- intrinsical heteroskedasticity
- Scatter with a binary variable doesnt invite linear fit*/




* 4. To avoid problematic predictions, we estimate a probit model using the same variables as in step 2. Discuss with your peers how a probit model differs from our standard OLS model. In particular, discuss the idea of a link function. When and why do we use probit models?

*******For illustrative purposes******
range z -4.5 4.5 1000

gen CDF_probit=normal(z)
gen CDF_logit=exp(z)/(1+exp(z))
twoway (line CDF_probit z) (line CDF_logit z), title(Probit and Logit response functions)

gen pdf_probit=normalden(z)
gen pdf_logit=exp(z)/(1+exp(z))^2
twoway (line pdf_probit z) (line pdf_logit z), title(Probit and Logit density functions)
*********************************************


//probit is specifically for modelling success and failure or binary dependent variables
//latent variable y*i?????

probit inlf kidslt6 educ exper age spousewage female,r
margins, dydx(*) post
marginsplot //for all variables 

//The relationship between having kids under the age of 6 and labour market participation is negative. On average for a additional child under the age of 6 your probability to enter the labour market decreases by 3.9%, CETERIS PARIBUS. This result is statistically different from zero at the 1% significance level. The model explains 35% of the variance in observations. 

//probit gives you z-scores which you need to transform.
//the first output in probit is a coefficient in z. 
//link function expresses the relationship between two variables. 
//A link function transforms the probabilities of the levels of a categorical response variable to a continuous scale that is unbounded. ... For example, a binary response variable can have two unique values. Conversion of these values to probabilities makes the response variable range from 0 to 1.
//phi 



predict y_hat2
twoway (scatter y_hat2 kidslt6, jitter(100)) (scatter inlf kidslt6, jitter(100)) // put the predicted variable first. 

twoway (scatter y_hat2 kidslt6, jitter(10)) (scatter inlf kidslt6, jitter(10)) (lfit y_hat2 kidslt6) (lfit inlf kidslt6)

return list
scalar z1= _b0[_cons]+_b1[_kidslt6]+_b2[educ]+_b3[exper]+_b4[age]+_b5[spousewage]+_b6[female]
display normprob(z1)


// Probit is the model that assumes the flat-S curve to be a standard Normal cumulative distribution function. We use it to model non constant marginal effects and to obtain only [0;1] values.
//OLS assumes the function is linear but in practice it is not. Probit is a non-linear model and differs in how it computes the slope coefficient with the marginal effect. 
// Link function: we apply a transformation to the OLS regression model in order to obtain the Probit regression model (we apply the normal distribution to it). We impose output values between 0 and 1 to the predicted estimations of the dependent variable.
//differences ... between linear or probit
*linear not precise
*linear constant makes no sense
*linear constant marginal effects, but sometimes no cme

/*Comments:
- Probit is the integral of a normal distribution or alternatively normal distribution is the derivative of probit
- Probit and logit solve problems of LPM through applying Cumulative DStandard Functions to the LPM model
- Both models use Maximum Likelihood method instesd of OLS or WLS
*/



* 5. How do the predictions of inlf (and the scatterplot) of step 3 change if you use your probit model to predict y_hat? Why is the difference important?

// We cannot interpret the coefficients of the Probit model as marginal effects, given that the marginal effects depend on the independent variable (on the value of X). 
 

predict y_hat2
twoway (scatter y_hat2 kidslt6, jitter(10)) (scatter inlf kidslt6, jitter(10)) // put the predicted variable first.
 
// Compared to before, the estimation is more accurate and we have solved the problem of estimations outside the [0;1] intervals. Still, the estimation is far from perfect.
ttest y_hat=y_hat2
// The hypothesis that they are the same holds: we are not able to reject the null hypothesis.




*6. Estimate the partial effect of an additional child under six on labor market participation graphically and interpret your findings. (use STATA’s margin and marginsplot commands).


probit inlf kidslt6 educ exper age spousewage female,r
margins, dydx(kidslt6) at(kidslt6=(0 (1) 4))
marginsplot

margins, dydx(kidslt6) at(kidslt6=(0 (1) 6)) //interpret as kids
marginsplot

margins, dydx(kidslt6) at(kidslt6=(0 (1) 4) female=1) //interpret as kids
marginsplot, noci //removes the confidence intervals

//larger confidence interval, smaller sample larger standard error 
//shows with 95% confidence the true value of the population. 

probit inlf kidslt6 educ exper age spousewage female,r
margins, dydx(*)
marginsplot

*alternatively,
margins, predict (p) at((median) kidslt6=(0(1)4)) vsquish
marginsplot

* Additional - LPM vs Probit vs LPM Effects

reg inlf kidslt6 educ spouseeduc female exper

probit inlf kidslt6 educ spouseeduc female exper, r 
margins, predict (p) at((median) kidslt6=(0(1)7)) vsquish

logit inlf kidslt6 educ spouseeduc female exper, r
margins, predict (p) at((median) kidslt6=(0(1)7)) vsquish


//how to show two marginsplot at the same time?
//following the normal distribution 

//look up contrast male female command 

***additional
margins, dydx(*) //same output as before but more precise. one unit change in kids will change the probability of entering the labour market in %. Based on fixed function of y=1 (as the first derivative of a non linear fuction is another function such as x2). 



scalar z1= _b0[_cons]+_b1[_kidslt6]+_b2[educ]+_b3[exper]+_b4[age]+_b5[spousewage]+_b6[female]
display normprob(z1)

margins, predict(p) at(median)
predict (stdp)






****************************************************************************
*****Tutorial 3: : Instrumental variables
**************************************************************************

clear all 
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 4"

use "institutions and economic development.dta"



*Preamble: 1. geography, 2. integration of countries in international markets, 3. quality of institutions - the three deep determinants of economic development
des
codebook lcgdp95 rule lcopen disteq safrica laam asiae neoeurope 
codebook logem4 engfrac eurfrac logfrankrom lnpop
des


/*1. Estimate the effect of geography on income (you should also control for at
least three additional variables but do not include any of the instrumental
variables!). 
*Does geography explain the income differences between
countries? 
*Discuss your findings and assess the goodness of fit of your model.
*Is the intercept economically meaningful? Explain and discuss.*/

des
codebook, c
codebook access
reg 
reg lcgdp95 disteq access area war, r
*sig access disteq both at 1%, others not. 
***???geography is as exogenous as it can get (birth lottery)???***

*Log-Lin Model Interpretation
*Holding all other factors constant, for one unit increase in distance from the equator (degrees) there is on average a 4.7% (b1*100) increase in GDP per capita. The result is statistically different from zero at the 1% significance level.  

*Holding all other factors constant, in case you have access to the sea there is on average a 65.38% increase in your GDP per capita. The result is statistically different from 0 at the 1% level. The model explains 52.73% in the variance of the observations. 

*Constant: log->0 is undefined, also area would be 0 and undefined, the country would not exist: it is not economically meaningful.  

//F: On average, an additional distance from the Equator unit increases the per capita GDP by 0.012*100%, ceteris paribus. This result is significant at 5% significance level. Geography's coefficient is positive but just slightly, even if statistically significant. The effect of an additional distance from the Equator unit on the log income is almost negligible. The goodness of fit of the model is pretty high (R2=0.7461), mainly because of the huge impact of institutions on income. The intercept would only be economically meaningful when the selected country has no institutions, no war, no access to the sea and when it's on the Equator.




/*2. Pick one of the variables: trade LCOPEN or institutions ( RULE )). Let us
denote X the chosen variable. Draw a scatter plot linking income and X.
Discuss and compare your figure with your peers who have a different X.
How different or similar are your figures? Would you say that your X is more
likely to explain the income difference than is the X of your peer?*/

twoway (scatter lcgdp95 rule) (lfit lcgdp95 rule)

*Rule of law is more likely to explain income per capita (obs have less variation). 

twoway (scatter lcgdp95 lcopen) (lfit lcgdp95 lcopen)

*explain: Heteroskedasticity refers to the errors (Gauss-Markov theorem)??? 




/*3. Re stimate 1 including the variable X. Is the effect of geography on income
similar to your estimate in 1 ? Discuss your results and compare the estimated
coefficient o f geography wit h the one obtained by your colleague s .*/

reg lcgdp95 disteq rule access area war, r //Democratization
reg lcgdp95 disteq lcopen access area war, r //market integration log-log model

*The effect of distance to the equator on income is positive. On average a 1 unit increase in distance to the equator increases economic growth by 1.17%. This result is statistically different from 0 at the 5% significance level. 

*Holding all other factors constant an increase 1% change in trade openness (lcopen) is associated on average with a 0.69% change in GDP per capita. The elasiticity of y with respect to x is 0.69. Very high 
*elasticity= rate of substitution. 

*in case of lin-log and log-log and a binary variable we have to ... 

*F:
reg lcgdp95 disteq war access lcopen, r
// Excluding the Rule of Law, geography's coefficient increases significantly. The result is now significant at 1% significance level. Geography's coefficient was overestimated. 
reg lcgdp95 disteq war access, r
// Excluding Trade, instead, does not change geography's coefficient (still 0.048): therefore, excluding Rule of Law can cause OVB, while excluding Trade does not impact in any way our analysis.





*4. Which of the variables geography or X explains the difference in incomes between countries?

*Magnitude of the effect for X and significance level both for lcopen and rule larger and better than geography. 

// According to everything we stated before, Rule of Law variable explains the difference in incomes between countries, not geography or neither trade.





/*5. You may believe that your estimations suffers from endogeneity bias. Discuss
the potential sources of endogeneity and the implications for the regression
results (consider at least three types of endogeneity). Which type of
endogeneity do you think is likely to be applicable to your case and why?*/

/*- Simultaneous causality: differences in income could affect the likelihood of countries to strongly apply a Rule of Law or the likelihood of war arising
- OVB: Rule of Law, country area, weather, mean temperature are all examples of variables (related to the Geography variable) that, if excluded, could potentially bias the results
- Measurement error: difficult to precisely measure income, for instance, in developing countries. Additionally, how can you quantitatively measure the level of application of the Rule of Law?
- Sample selection bias: it makes no sense to try to answer the question today grounding on data from 90s decade. Colonization?
- Functional form misspecification: it does not cause endogeneity problems, but an internal validity issue. Maybe the log-linear form is not the best one to describe this model
*/


*2 conditions for instrumental variables: 
*relevance needs to be correlated to x and needs to have an effect on y through x, but not directly (it should have statistical significance and the magnitude of the coefficient should be powerful in explainaing in respect to X) and 
*exogeneity (regressor Z shouldnt be related to ui-error term of the first equation)

*????Exclusion restriction for instrumental variables???


************Causes for endogeneity**********
*1. OVB - prob not as three deep expl
*2. Functional form misspecification - already log it
*3. measurement error - look up the paper - indicator of perception - transperancy international very subjective perceptive measurement indexed. At the aggregate level the systematic error should be accounted for. We cant rule out that there is measurement error. Cant test for this = limitation of the data. 
*4 Sample selection: all countries included, no sample selection bias. 
*5 reverse causality: yes, see Institutions Rule 2001: Rodrik. 





/*6. For each of the variables, geography and X, discuss whether there might be an
issue of causality with income, and discuss why?*/

*5 reverse causality: yes, see Institutions Rule 2001: Rodrik. Fig1. 
*Including a historian led to exclusion of exogenaous parts from the endogenous model. 

scatter lcgdp95 logem4, mlabel (country)
*You see the difference between extractive (Nigeria, Tanzania) (higher settler mortality) and non extractive (colonies) lower settler mortality (=instrument for the quality of institutions). Path dependency, not first generation europeans, learned to govern through the europeans. 

*Know we know that settler mortality is an exogenous varialbe Z that relates to X. Affects only Y through X. Causality is only one way as income today does not affect settler mortality 500 years ago. 


//simulating 2 stage regression by instrumenting rule with settler mortality in the first stage and 
*Stage 1 model: rule_hat=b0+b1sm_hat+ui
*Stage 2 model: gdp_hat=b0+b1sm_hat+vi

reg rule logem4 engfrac eurfrac, r //0.43 of the variation explained of the exogenous parts
predict rule2

reg lcgdp95 rule2 disteq access area war, endog(rule) r first //both rule2 and access are significance. 

ivreg2 lcgdp95 rule logem engfrac 

****TUTORIAL WITH SOLOMON********
ivreg2 lcgdp95 disteq (rule = logem4) war access area, endog(rule) r first  //rule gets instrumented by european settler mortality
1. stage: 
/*
2 conditions: 
1. relevance
corr(x, zi)!=0
check in the first stage regressions
1. Is the instrument significant - check p values
2. check f-test if greater than 10 
in the exam you have to say: there are two ways to check for the relevance. Ftest of first stage and then cragg-donald wald f-statistic.
"Using the first stage identification weak the ftest <> than 10, therefore our instrument is weakstrong, however if we look at the second stage we see that the cragg donald wald test"
2. exogeneuity Hansen J Statistic. 
if m>k, 

anzahl instrumete anzahl der endogene variablen, 1X, 2V. good! 
for one variable: "equation is exactly identified", so we cannot determine the validity of the instrument (if the instrument is exogenous) because we cannot do the overidentification test.

Endogeneity - Exogeneity test: 
H0: X is exogenous
Ha: Ha is not exogenous
Reject H0 if P-value<0.05
We reject the H0 that x is exogeneous and we conclude that X is still endogenous. (IV is not good enough)   

Interpretation:
log lin - multiply with 100
lin log - divide by 100
log log - % %. 
The relationship between rule and gdp is positive. On average, an increase of one additional unit of rule increases GDP growth by 188.74%, holding all other factors constant. This result is statistically different from zero at any conventional significance level. 

The relationship between disteq and gdp growth is negative. 
On average, by every more km distance from the equator will decrease the GDP growth by 3.03%, holding all other factors constant.

Interpretion for lcopen. 
The relationship between lcopen and gdp is positive grown. On average a one 1%change in x is associated with a b1% (no multiply no divide) in gdp growth.  The elasiticity of y with respect to x is b1.
*/
ivreg2 lcgdp95 disteq (rule = logem4 engfrac) war access area, endog(rule) r first

/*same with two instruments
Now I can do the validity test! 
Hansen J statistic
pvalue should be larger than alpha to conclude that all instruments are valid. 
if m>k, 
anzahl instrumete anzahl der endogene variablen, 1X, 2V. good! 
H0= all instruments are valid (=exogenous)
Ha= at least one of them is not valid 
Reject H0 if CHI2-P<1%/5%/10%. 
We can reject the Hansen J statistic p value. 
We reject the H0 that all instruments are exogenous and we conclude that at least one of them is not valid.
******************SOLOMON Finis************
*/ 
 


/*7. Let’s consider that X is endogenous and “Z” is a potential instrument (Pick
one of the instrumental variable groups from the table that correspond to
your choice of X) X). Write down the two level equations for t he instrumental
variable regression model. Should you control for geography in the second
equation? Explain and discuss.*/


// Let's assume a 2SLS.
// Trade=B0+B1*openness+Z+e
// Trade(hat) it is the part that is exogenous to GDP
// GDP=Y0+Y1*geography+Y2*Trade(hat)+e
// We should control for geography in the second equation because it explains (even if only slightly) GDP. Still, we should remember that we are more interested in the effect of openness on GDP, than geography's one.

reg lcopen logfrankrom disteq war access, r
predict hat
reg lcgdp95 disteq war access hat, r



/*8. Estimate the instrumental variable instrumental variable model and discuss the results obtained in model and discuss the results obtained in the first and second steps. the first and second steps. Compare your results with your peers that use a different instrument but the same X. Is there a difference? (hint: you may want to look at the Stata command ivreg2)*/

*iv reg gives the same table as the manual approach
*ivreg2 two different statistical tests: J-test

ssc install ivreg2
ssc install ranktest

ivreg2 lcgdp95 (rule=logem4 engfrac eurfrac) disteq access area war, r 
*diff manually and software: manually not accounting for heteroskedastic errors, but software does it. 

*interpret in percent. 
test access=0


// ivreg2 is the same as ivregress 2sls
// Before proceeding, we should always check the validity of the instrumental variable (relevance and exogeneity).
ssc install ivreg2 // and proceed with ivreg2, which also shows test results
ssc install ranktest // install as well

ivreg2 lcgdp95 (lcopen=logfrankrom) disteq war access, r
*or*
ivregress 2sls lcgdp95 (lcopen=logfrankrom) disteq war access, vce(r)

ivreg2 lcgdp95 (lcopen=lnpop) disteq war access, r

// Before only correlation, now the effect is causal. Logfrankrom not significant, but lnpop yes. Using lnpop as an instrumental variable, rather than logfrankrom, increases trade's effect on GDP and it's also significant now.
corr lnpop lcopen
corr lnpop lcgdp95

ivreg2 lcgdp95 (rule=logem4) disteq war access, r

ivreg2 lcgdp95 (rule=engfrac) disteq war access, r

// Robust standard errors are lower when considering engfrac as an instrumental variable rather than logem4, even though the effect of the Rule of Law is also reduced.




****************************************************************************
*****Tutorial 4: Instrumental vari ables validity
**************************************************************************

clear all 
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 4"

use "institutions and economic development.dta"



*ivreg vs. ivreg2 vs. ivreg 2sls //test different commands and look at difference
ssc install motivate
motivate
ssc install reggae_music
reggae_music


* 1. Discuss with your colleagues why one needs to assess the quality of the instruments, and what one needs to assess the validity of an instrument What makes an instrument valid?

//the brackets allow to you identify which variable is endogenaous and with which variables you are instrumenting.
//rule is x1 and has a endogeneous and a exogneous part, which is instrumented with Z1 logem4 Z2 engfrac Z3 eurfrac
// first stage equation is in brackets 
// IV corrects reverse causality as here eg. language is not affected by GDP. 
// IV helps to split the exog and endo part of xi
// IV uncorreletad to ui and only correletad to xi only through its effect on y. 
//two conditions 
//relevant: corr(xi,zi)!=0 (as long as it is not 0 it is related to xi)
// Exogenous corr(ui, Zi)=0
// for each endog variable a first stage equation and one second stage equation.
//proxy income here as gdppc 
//war and econ development - simultanious causality

// When we have a very weak instrument, we won't be totally able to extrapolate the exogenous part of the independent variable, so the model will be biased. The model will be endogenous in itself, the 2SLS/IV estimator biased, the sampling distribution skewed and the usual inferences misleading. If you don't have a good instrument, you won't solve the endogeneity issue. To assess the validity of a model, you need to check its relevance (correlated with the regressor) and exogeneity (uncorrelated with the error term). The instrument is non-weak if all of the pi's are nearly zero.



*2. Re estimate the model 8 of the previous tutorial. Discuss with your peers which of the potential instruments you deem val id ? Implement the necessary t ests. For each of the tests discuss the null and alternative hypothesis of the test.

ivreg2 lcgdp95 (rule=logem4 engfrac eurfrac) disteq access area war, first r 

***************condition 1*****
relevance

*to test for condition nr1) relevance is: how smart are you and explain the theory. Statistically: first stage F-test only. Here 4Z + 3W
*Always specify first and then look at the f-test of the first reggression. 
*look at sanderson-windmeijer multivariate fest of excluded instruments. F>10 is goooooooood
*here  F(  3,    63) =     8.02 <10 therefore is a weak instrument. 

ivreg2 lcgdp95 (lcopen=lnpop) disteq access area war, first r 
// all of the variation explained comes from lnpop, great instrument as F=94

ivreg2 lcgdp95 (lcopen=lnpop logfrankrom) disteq access area war, first r 

//first stage, both lnpop and logfrankrom are significant, so correlation is there. how people use trade openness is the question, now able to explain less as F55>10. Would therefore delete logfrankrom. lowers the relevance of the mode. 

//from the first stage regression I understand that we have weak and strong instruments. 


*************condition 2******exogeneity

//second stage of rule
// rule sig 1%
//in this case only one endogenous variable and three instruments

// Underidentification test H0: to feq instruments M<k
//we are able to reject H0 with p0.01<alpha0.05

//weak identification test 
//Ftest  8.024 < 10. 
// look at all of them critical values and if at least one of the critical values is higher than the F statistic, then I know that I have a weak instrument. Have several critical values. ONLY works for one endog variable, not for several. 
//fail to reject that I have a weak instrument. 

//J test, overiedentification 
// as p 0.0045<0.5 alpha I reject the H0 that I have overidentified the model. 



*******intrepreting cond2 for lcopen****
ivreg2 lcgdp95 (lcopen=lnpop) disteq access area war,  r //excluded log frankrom as considered not relevant

// not underidentified reject H0
// not weak identification
// not overidentified reject H0. 
// conclusion: good instrument. 

********************************************************************************

***Manually Rubin J statistical test for exogeneity***

*1stage reg
reg lcopen lnpop disteq access area war, r //manual 1st stage reg
predict x_hat //gen var x_hat predicted by first stage 
*2stage reg
reg lcgdp95 x_hat disteq access area war, r //x_hat is trade integration the estimated part 

*3stage: predict y estimate
predict y_hat 

*4stage: predict the errors
gen u_i=lcgdp95-y_hat //population value - predicted value gives the residuals (the unexplained part)

*5stage: regress on controls of first stage + esp. the 
regress u_i disteq access area war lnpop, r 
// testing for exogeneity of the errors, good if nothing is significant as the vars are not related to the error term u_i of the org equation. 

*6stage: Anderson Rubin J statistic, the higher this number the higher the 
di F*M(#instruments in equation)
di lnpop pr*Fstatistic
di 0*1
//the higher this number the worse, bc more endogeneity (with 0 we have 0 endogeneity)
*The higher the number the worse, here it is equal to 0, so there is no correlation between the exogenous variable and the error term - which good. 


ivregress 2sls lcgdp95 (lcopen=logfrankrom) disteq war access, vce(r) first // You can both use the ivregress 2sls..., vce(r) command to check validity, or the ivreg2 command (preferable). You also need to add "first" to ask Stata to report the first-stage F. The rule of thumb of >10 is always fine. Otherwise, you could also check that your F (or the Kleibergen-Paap rk Wald F statistic) is larger than the Stock-Yogo weak id test critical values (one for each percentage of bias).
// F=36.64>10, so logfrankrom (empirically) is not a weak instrument (it is therefore relevant), according to the rule of thumb. The second-stage model won't be biased. We can't test exogeneity here given that the number of endogenous variables is the same as the number of instrumental variables (1=1). Additionally, you should also theoretically argue why the instrument should both be relevant and exogenous.

ivregress 2sls lcgdp95 (lcopen=lnopen) disteq war access, vce(r) first
// First-stage F=35.74>10, so the lnopen instrument is not weak. It is relevant.

ivreg2 lcgdp95 (rule=logem4) disteq war access, r first
// First-stage F=9.24<10, so the logem4 instrument is weak. It is not relevant. We cannot reject the null hypothesis.

ivreg2 lcgdp95 (rule=engfrac) disteq war access, r first
// First-stage F=18.35>10, so the logem4 instrument is not weak. It is relevant. We reject the null hypothesis.

// For any model:
// H0: all pi's are nearly zero (weak instrument problem)
// Ha: any pi is sufficiently different from zero, so the instrument is not weak DESIRABLE

// For any model:
// H0: the IV regression is overidentified (the instruments are exogenous) DESIRABLE
// Ha: the IV regression is underidentified

ivreg2 lcgdp95 (rule=logem4 engfrac) disteq war access, r first
// First-stage F=13.54>10, so the instrument is relevant. Additionally, we can now test exogeneity. The J test has p-value<0.02. We reject the null hypothesis, but in this case it is a bad thing: we have some underidentification problem, so the instruments are not valid given that they are not totally exogenous.
// --> in general, you want to reject the null hypothesis for the weak identification test and not to reject it for the J test of overidentification.

ivreg2 lcgdp95 (rule=logem4 engfrac) disteq war access, r endog(rule)
// Endogeneity test: if you fail to reject (checking the p-value), treat Rule as an exogenous variable, even if you cannot be totally sure about it. The latter because we should also check the quality of our IV model.

// H0: exogeneity DESIRABLE
// Ha: endogeneity




*3. Now consider a model where institutions and trade are both treated as endogenous. How many equations will be estimated? Write down the equations of the first and second st age.

*in model 8 only rule as only endog variable that has been instrumented

ivreg2 lcgdp95 (rule lcopen = logem4 engfrac eurfrac lnpop) disteq access area war, endog(rule lcopen) first r //logfrankrom excluded as weak instrument. //specifying that rule and lcopen are really my endog variables - so that STATA is not doing something funky. 

***looking at first stage regression

***looking at second stage regression. 
*instrument rule and disteq trumps over everything else. Quality of institutions (rule) is what matters most for econ development. 

//under, reject H0 at 5% that it is underid
//weak id all of the critical values are larger than the F, therefore weak, but we dont know which, so we have to manually do the first stage first to exclude weak instrument. I have id a weak instrument but I dont know which one. 
// over, reject H0 at 5% that it is overid pval   0.0475<0.05% but getting closer. 


//comparing first stage and second stage: difference to first stage, at which STATA does not differ between instrumented and exogenous variables. 


********************************************************************************
ivreg2 lcgdp95 (rule lcopen=logem4 logfrankrom) disteq war access, r endog(rule lcopen) first
// Rule variable coefficient is statistically significant. On average, an additional unit of Rule of Law will increase the per capita GDP by 2.02*100%, ceteris paribus. This result is statistically significant at 1% significance level. Trade is not statistically significant, so does not affect GDP. Distance from Equator negatively impacts GDP, at 10% significance level. 3 equations (2 first-stage ones) will be estimated:
lcopen=P0+P1*logfrankrom+P2*logem4+...+u
rule=D0+D1*logfrankrim+D2*logem4+...+v

lcgdp95=B0+B1*rule(hat)+B2*lcopen(hat)+...+w
// The instrument is not weak until 15% bias level. We cannot check exogeneity (M=K). We reject the endogeneity test, so we have some endogeneity issues.






*4. Compare your estimated coefficients with the ones obtained in exercise 8 of the last tutorial . What are the differences? 

// Let's re-run regression from Tutorial 3, question 8:
ivreg2 lcgdp95 (lcopen=lnpop) access war disteq, r endog(lcopen)
// lcopen's coefficient now switches direction compared to question 3: it is now positive. Moreover, it is now also significant, on the contrary of the model in question 3. The instrument is not weak. We cannot check for exogeneity (in fact, J=0).



*5. Assess the validity of the instruments. Compared with the results you obtained when testing the vali dity of the instruments in ex ercise 8 of the last tutorial . Discuss with your


//How to compare results of full model with the individual models? 
//compare model through r2
//compare the validity through the statistics. 
//in terms of vailidity the trade only would be most prefereable but low r2
// weakest model rule only 
//weak instruments can be still be included in the model as long as the relationship is non zero. 
// is the weak instrument the driver of the full model? 
//subject to measurement error -> record keeping of settler mortailty. 
// layer beneath the people, their interactions and the rules which they are based on.
//therefore turn to behavioural economics 

findit joke
joke 

// We already checked in question 3 its IV model validity: we obtained not weak instruments. Still, we found some endogeneity issues.
// Question 4's model is not weak: Kleibergen-Paap rk Wald F statistic=144>10 and also > that the Stock-Yogo weak ID test critical values, at any level of bias. we can't check for the exogeneity of instruments (M=K). Endogeneity test: we can't reject the null hypothesis (p-value=0.202), so we don't have endogeneity problems, but we may have reverse causality ones. We should still check for the quality of the IV regression model.

***OPTIONAL: J test
ivreg2 lcgdp95 disteq (rule=engfrac logem4), r
predict e, resid
reg e disteq engfrac logem4
// If the error term is correlated with the instrumental variables, the IV model quality is not high, so we cannot ensure their exogeneity.
test engfrac logem4
// F=2.66
// J=2.66*2=5.32
// (degrees of freedom=M,N-M-L)



****************************************************************************
*****Tutorial 5: Fixed effects
**************************************************************************
clear all 
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 5"

use "1 Input\panel_development.dta"


/*1. 
1a) What differentiates panel data from cross-sectional data? 
Panel data follows the same person overtime (trends), whereas cross-sectional data asks several things at a specific point of time. 
Time-series of cross-sectional data is not a panel data, as different individuals are interviewed on the same topics.
  
1b) What is the difference between balanced and unbalanced panel data?
//In unbalanced data we have missing or incomplete variables.  

1c) Considering that our key variable sof interest are growth and demo, is the data set balanced?*/

*1c
codebook
des 
tab country if demo ==. 
//little islands have a systematic thing going on ... 7 missing. our capacity to assess the quality of institutions is not as good when we look at these islands. 
//this panel is still balanced, as there are only few values missing. 


// Panel data: multiple variables measured at different points in time. Cross-sectional data: multiple variables measured at a single point in time.
// Balanced panel data: all observations are measured through every considered period of time.

xtset countryid year, delta(5) // Delta tells Stata how long your time periods are. If you don't specify delta, you will assume the intervals are 1 year (or 1 unit) long.
xtsum countryid year // More detailed table: we can check that N=n*T for both variables. We can then conclude that he dataset is therefore strongly balanced.

/*2. Estimate the effect of demo on growth controlling for lngdpl separately for the year
2000 and 1980 ( Interpret the effect of our measure of the quality of
institutions. Do the results change if you control for our measure of human capital
lneduc25*/

reg growth demo lngdpl if year ==1980, r  
reg growth demo lngdpl if year ==2000, r  
//not significant

reg growth demo lngdpl lneduc25 if year ==1980, r  
reg growth demo lngdpl lneduc25 if year ==2000, r
//not significant  

//Interpretation: 
//growth: measured as a rate - pace at which a country is growing. by default instead of a total it gives you a percentage(=rate). How meaningful is that in interpretation? What are we capturing
//Controlling for log-gdp to make y and x comparable for developing and developed countries. 
//We observe that in 1980 the quality of institutions improved the rate of growth more than in the year 2000. Using initial gdp we try to explain that there is a threshold of decreasing marginal returns. Constant quality of government eventually the marginal returns are getting less as "there is only so much one can do". 
//lin-log model: semi-elasticity: shows diminishing marginal returns due to the compressing effect of the log (the curve flattens and there are less returns per unit increase). 

//Exercise for explaining the compressing effect of the log:
display log(10000)
display log(15000)
//Effect of 5000 extra a month, makes a lot of difference: 0.4
display log(200000)
//way less effect of 5000 a month more - only 0.03. 
display log(205000)



********************************************************************************
// We are regressing for single years, so we can run typical regressions.
reg growth demo lngdpl if year==1980, r
reg growth demo lngdpl if year==2000, r
// No variable is significant at the 10% significance level, but they even become less significant in 2000 than they were in 1980.
reg growth demo lngdpl lneduc25 if year==1980, r
reg growth demo lngdpl lneduc25 if year==2000, r
// No variable is significant at the 10% significance level, but they even become less significant in 2000 than they were in 1980. Adding lneduc25, for the year 2000, strongly decreases demo's coefficient's p-value (even if it is still non significant).
// On average, a unit increase in demo is expected to increase the growth rate by 16.9% percentage points over a 5-year period, ceteris paribus, for the year 1980. The result is still not significant.



/*3. Re estimate the models using all years. What can you say about the effect o f
institutions on growth and the role of human capital on this relationship?*/

//"Pooling the data" = "Pooling together all the years: country averages across thirty years"

reg growth demo lngdpl, r  
reg growth demo lngdpl lneduc25, r 
//Holding all other factors constant an one unit increase in demo leads to an increase in the rate of growth of 0.0866. Linear to Linear. This result is statistically different from zero at the 10% significance level. 

//Holding all other factors constant, in one 1% of education is associated with a change of (b1/100=) 0.0071pp in growth. 

********************************************************************************
tab year

reg growth demo lngdpl, r
reg growth demo lngdpl lneduc25, r
// Considering all years together (by not specifying the year, as it wasn't a panel data), the demo coefficients become significant at 10% significance level for both models.
*SECOND MODEL
// On average, a unit change in demo would be expected to increase the growth rate by 0.98% percentage points over a 5-year period, ceteris paribus. This result is significant at 10% significant level.
// On average, for each 1% change in lngdpl we would expect the growth rate to decrease by 0.01*0.37% percentage points over a 5-year period, ceteris paribus. This result is not significant.
// On average, for each 1% change in lneduc25 we would expect the growth rate to decrease by 0.01*0.72% percentage points over a 5-year period, ceteris paribus. This result is significant at 5% significance level.


/*4. There are many t hreats to the internal validity. Discuss different sources of
endogeneity in this research context and give specific examples to describe factors
that may cause en dogeneity problem s*/

// simultanious causality yes, as education and human capital may increase growth and vice versa. 
//sample selection bias - usually 
//ovb - deep determinants of growth missing (no geography, trade liberalization and integration of markets)
//functional form misspecification, 
//measurement errors - always 


********************************************************************************
/*
- Simultaneous causality: differences in income growth could affect the likelihood of countries to have strong institutions or better functioning educational systems
- OVB: geography, trade, previous performance, sectors, climate are all variables that, if excluded, could potentially bias the results
- Measurement error: difficult to precisely measure income, for instance, in developing countries. Additionally, how can you quantitatively measure the strength level of institutions (question index of institutions)?
- Sample selection bias: the considered time period may not be the best one in order to assess the relationship. Missing countries
- Functional form misspecification (theoretical): it does not cause endogeneity problems, but an internal validity issue. Maybe the linear-log form is not the best one to describe this model*/




/*5. Entity fixed effects can be used to reduce the risk of omitted variable bias ( OVB).
Write down the equations for the Least Squares Dummy Variable approach and the
within entity fixed effects approach. D iscuss how these model s help to re duce OVB
concerns.*/

//5.1. dummy approach for fixed effects. 
LSDV: yit=_b0+_b1Xit+_G1Di1+...+_GnDik+uit
xi: reg growth demo i.countryid, r 

//5.2. within entitiy fixed effects
yit=b1xit+alphai+ui
alpha=b0+b2zi (the entitity effect)

//fixed effect do not vary across time. 
//assumption that fixed effect stays the same is dependent on unique country variables e.g. hard to influence things like coastal country or inelastic culture. 
//alpha gives you good idea of a possible state of the world economy (base line), add the austrian province specific alpha and the general constant of the model to get an interpretable constant for modelling and projection. Otherwise alphai is not relevant or interpretable nor economically meaningful. 



********************************************************************************
Yit = B0 + B1*X(it) + G(1)*D(i1) + ... + G(n)*D(ik) + u(it) // Entity (country) fixed effects
Yit = B1*X(it) + A(1) + u(it)  where A = B0 + B2*Z(i)// Time fixed effects
Y(it) = A(i) + B(1)*X(it) + u(it)
// You can include both entity and time fixed effects by also creating dummy variables for each year.
// Time invariant part is extremely important for the model. In our case, it could be geography. Through the panel data method, we reduce the risk of having OVB: for example, with a normal regression we would miss the geography variable effect, but through a panel data method we can control for it.
// By adding entity fixed effects, you can check unit invariant variables.


******By SOLOMON*****

//entity fixed effect and time fixed if i add i.year effect time with LSDV approachreg 
reg growth demo lngdpl lneduc25 i.countryid, r 
//There is a positive relation between democracy and growth. On average an additional unit of democracy increases growth by 0.13, holding all other factors constand. This result is statistically different from 0 at alpha 5% significance level. 

//lin-log-
//There is negative relationship between lngdpl and growth. On average a 1% increase in lngdpl increases growth by 0.05, holding all other factors constand. This result is statistically different from 0 at the 1% level. 

//Country 2: On average country 2 has 2.27 more growth than country 1, holding all other factor constant. This is significant at the 10% significance level. 

//constant does not have any meaning. 

****
//entitity fixed effect: entitity demeaned

xtset countryid year 
xtreg growth demo lngdpl lneduc25, fe vce(cluster countryid) //incluster we define the entitiy. 
//EXAM only diff is that the slope coeff stays the same. but the lsdv gives you an additional info for the country. if you search for country information.
//EXAM: vce: cluster countryid we cluster the standard errors in the country specific heteroskedasticity. correlation within the clusters not between the entitity. correct for serial correlation.  

//EXAM: What does the cluster do: 
//vce corrects for heteroskedasticity and autocorrelation. 
//b1 stay the same, but standard errors gets hgigher, p value gets higher. 

*******************************SOLOMON finis************************

/*6. Estimate t he model of step 4 including entity fixed effects ( hint : you first need to
define the panel structure in Stata : xtset year countryid ). Use the xtreg command to
estimate the fixed effects estimation. Interpret the effect of demo on growth and
discuss the ro le of our measure of human capital ( lneduc25 on this relationship.*/

xtset countryid year //setting the variables. 

xtreg growth lngdpl demo lneduc25, fe vce(cluster countryid) //variance covarriance estimate - guaranteeing robustness. 

//Holding all other factors constant, for an increase in one unit in the quality in instuttions there is an increase in the rate of growth by 0.13. 

//One percent increase in initial GDP is associated with a decrease in (b1/100) of 0.0462

********************************************************************************

xtset countryid year, delta(5) // To define the panel structure
xtreg growth demo lngdpl lneduc25, fe r
*or*
xtreg growth demo lngdpl lneduc25, fe vce(cluster countryid) // The cluster command tries to cluster the standard errors of different countries (separate country effect from variables that change over time, and include that in the error term). We do that to avoid serial correlation or "autocorrelation".
// On average, for each unit change in demo we would expect the growth rate to increase by 0.13 percentage points over a 5-year period, ceteris paribus. This result is significant at 5% significance level.
// On average, for each 1% change in lngdpl we would expect the growth rate to decrease by 0.01*4.62% percentage points over a 5-year period, ceteris paribus. This result is significant at 1% significance level.
// On average, for each 1% change in lneduc25 we would expect the growth rate to increase by 0.01*0.35% percentage points over a 5-year period, ceteris paribus. This result is not significant.



*****************************SOLOMON START*************************
*Tutorial 5: Fixed effects: 


//time and entity fixed effect combined 
xtset countryid year, delta(5)
xtreg growth demo lngdpl lneduc25 i.year, fe vce(cluster countryid) //both comibined effects for both time and entitity effects

xtreg growth demo lngdpl lneduc25, r




//Interpretation. 1970 as reference: On average in 1975 growth was 0.86 more than in 1970, ceteris paribus. This is statistically different from 0 at the 10% significance level. 

//LSDV for time and entitity fixed effects
reg growth demo lngdpl lneduc25 i.countryid i.year, r 

//EXAM: After controlling for entity fixed effects is it still possible to have OVB? Why is there still the risk of OVB. 1) Inbalanced panel. Culture constant for a long time, but somtimes changes. 
//EXAM: Idea is that the Unobserved variables should vary acorss country and not across time, the moment it varies across countries and time there is a risk of OVB.


/*7. Why is there still a risk of OVB? Give a specific example .*/
// There is still a risk of OVB because the variable is time varying so even if we use panel data method we cannot completely control for it. We can check for time fixed effects and entity fixed effects, but not for both (such as infrastructure or productivity).

*ADDITIONAL CONSIDERATIONS*
xtreg growth demo lngdpl lneduc25 lat_abst, fe vce(cluster countryid)
// The latitude is omitted because it is constant over time (reason behind is the same as the multicollinearity issue).







****************************************************************************
*****Tutorial 6: Time fixed effects
**************************************************************************

*panel data- substract the mean. 

*first difference equation in time data (looking at the differences, only works when i only one entity)
*yi1988=b0+b1beeri1988+ui1988
*yi1982=b0+b1beer1982+ui1982

*dyi1988-1982=b1*(beeri1988-beeri19882)+ui1988-ui1982
//the fixed effect lambda and the intercept cancels out.
//when you have multiple entitity over time the lambda is captured by the intercept
//the fixed effect always disappears - it cancels out.  

******************************************


cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 5"

use "1 Input\panel_development.dta"


/*1. In the last tutorial, we estimated entity fixed effects models. Discuss what the entity
fixed effects captu re. How are time fixed effect s different from entity fixed effects?
Write down the estimation equations of a time fixed effects model for a simple
setup with 2 time periods.*/

*time fixed effects: effects that vary with entity but not with time
*entity fixed effects: effects that vary with time but not with entity. 

*time fixed effect equation (decomposed, for multiple entities):
*yuit=b1xit+lamdat+uit
*lambdat=b0+b2Xt

*dummy version of time fixed effects (here the dummy is a time period, therefore no subject t - in a dummy model we have an intercept)
*yit=b0+b1Xit+b1greekDi+uit


********************************************************************************
 Entity: captures individual effects which are constant over time (e.g. geography of countries)
		*includes t subscript in regressions for dummies
* Time: captures time effects which are constant for entities (e.g. season for european countries; interest rate changes in Eurozone)
		*includes i subscript in regressions for dummies

* Fixed effects explains the entity effects which are constant over time

* (Fixed effects data sets are hard to collect)

Y(it)= B0 + B1*X(it) + G1*E1 + G2*E2 + D1*T1 + U(it) where E1,E2=entity fixed effects and T=time fixed effects
// If we have two time periods, we will just create n-1=1 dummy for one of the two years



/*2. Estimate the effect of demo on growth using a standard OLS model as we did in
st ep 4 of the last tutorial). N ow add time fixed effects to the model. Interpret the
effect of demo , lneduc25, and the time fixed effects.*/ 

//gen dummy variables 
gen y70=(year==1970)
gen y75=(year==1975)
gen y80=(year==1980)
gen y85=(year==1985)
gen y90=(year==1990)
gen y95=(year==1995)
gen y00=(year==1900)
global yeardum "y70 y75 y80 y85 y90 y95 y00"

reg growth demo lneduc25 lngdpl i.year , r
//reference group 1970 is automatically omited. 
tab year //check all the number of years.

//Ceteris paribus, when the quality of institutions increases by one unit growth increases by 0.08488 %p (unclear if %p). This result is significant at the 10% level.

//Ceteris paribus, with a 1% increase in education growth increases by (b/100) 0.0102. This result is significant at the 1% level. 

//Ceteris paribus, in the year 1975 growth was on average 0.29 less than in 1970. //does not refer to the previous year but to the baseline. 
//Ceteris paribus, in the year 1980 grow was on average 2.54 lower than growth in the year 1970. 
//Cp, in the year 19990 growth was on average 1.97 lower than in the year 1970. 



********other options********
xtset growth $yeardum
xtreg growth demo $yeardum, fe vce(cluster state)
reg growth demo lneduc25 $yeardum, r 

********************************************************************************

reg growth demo lngdpl lneduc25, r
tab year, gen(y)
reg growth demo lngdpl lneduc25 i.year, r

// On average, a unit change in demo would be expected to increase the growth rate by 0.085% percentage points over a 5-year period, ceteris paribus. This result is significant at 10% significant level.
// On average, a 1% change in lneduc25 would be expected to increase the growth rate by 0.01*1.02% percentage points over a 5-year period, ceteris paribus. This result is significant at 1% significant level.
// Time effects: in comparison to 1970, each subsequent 5-year period had a negative impact on growth (but in a decreasing way). Results are mostly significant.
// On average, the average year between 1975 and 1980 would be expected to decrease the growth rate by 2.55% in comparison to 1970 percentage points over a 5-year period, ceteris paribus. This result is significant at 1% significant level.



/*3. How do you interpret the intercept in this model?*/
*not economically meaningfully
*cons=average of the lambdas=b0 of the whole model + the average of all time fixed components = lambda = the intercept of every time period. 

// B0 is the impact on growth of the omitted year (1970) if all the other variables are 0. * 1970 growth rate is equal to constant, given independent variables are zero

reg growth demo lngdpl lneduc25 y1-y7, r noconst // To check coefficient of 1970 (y1) = 4.97 is the same as the intercept of the previous model.


/*4. Test whether the time effects are jointly different from 0.*/

testparm i.year //JOINT TEST: F-test: a t-test for multiple variables. // p 0<0.05 - reject the H0 that jointly there is no time effect. Therefore time has an effect and we include it. 

// Basically we are trying to see if we should include time fixed effects in the model (JOINT SIGNIFICANCE TEST).
testparm i.year
// We reject the null hypothesis that all years coefficients are 0 at 1% significance level.


/*5. What does it mean to cluster the s tandard errors? Under which circumstances is it important to cluster standard errors in a panel data? What happens to the
coefficients and the standard errors if we cluster? Does it make a difference for the
interpretation of o ur findings?*/

//we are not going to have to estimate the std. error for panel data. 
//demeaning of variables - consequence for standard errors. following the same person over time - if there is a error term that is correlated between years = autocorrelation or serial correlation. likely to happen in panel data. Clustering is done for entitites. Eg. Students per University share traits that unobserved, error term similar amongs one entity. Before there was assumption no corr between x and error terms. Now we allow for that zero to take on a small value. Allowing for auto or serial correlation in the standard errors, we relax one of the assumption in our models. 
// in the entity fixed effects we allowed for clustering per entity e.g. ppl in a region are similar. so within a cluster the correlation of the error term is allowed but not between clusters. 
//time periods are a form of clustering as well. 
//when we observe autocorrelation then we cluster
//coefficients are not affected but p value is affected. 
// std. errors get bigger, t values get smaller and p vlaues get larger. 
//magnitude of b gets not affected as it is based on variance and covariance 

* Clustering tackles the problem of autocorrelation within entitities, as you allow correlation across time for entities
// We want to cluster because of time dependency. Clustering means allowing correlation across time. You are violating assumption 5, so the model will be less efficient but also less misleading.
// Coefficients will be the same but standard errors will be more correct (not sure if larger or smaller).
// You shouldn't cluster when there are no changes across time and across entities.


/*6. Let’s combine time and entity fixed effects. What is and what isn’t
captured by the fixed effects? Estimate the model and discuss the role of our
measure of human capital ( lneduc25 on this relationship.*/

xtset countryid year //first panel then year //we told stata that we are working with a panel structure 

*****optional*****
xtset countryid year, delta(5) //changed for every five years, could enhance the efficiency of our estimation. 

xtreg growth demo lneduc25 lngdpl i.year, fe vce(cluster countryid) //all without the i.year was entity fixed effects with i.year its time fixed effects. vce() variance covariance estimation matrix measures st.error for heteroskedastic robust standard error. 

//the increase in one unit of the quality of institution results in a decrease of 0.008 unit in growth , hoevwer the result is not significant. 
//In 1975, compared to 1970, growth increased by 0.86. 
//when we pulled the years, the effect of education was positive and significant
// decreasing marginal utility of education over the years probably. average level of education of young people in 1970. This is not changing by time but is at 1970. Whereever you started out in 1970 the effect was negative. 
//phd may be costly and less efficient in terms of economic output for the countries. 
//cons b0 that is not measurable and time fixed effects that are not captured
//r2 89 percent of the variation is explained by something else. 
 

//corr (u_i, xb)=-0.96 is the correlation of alpha (the fixed effects constants) and X. 
//rho: (fraction of variance due to u_i)
// sigma_u: error term for the entitiy fixed effects
// sigma_e: error term for the time fixed effects. 
//magical number to understand if a balance is balanced or not: delta 1
//stata looks at panel components only, therefore balanced statement of xtset not valid


xtset countryid year, delta(5)
xtreg growth demo lngdpl lneduc25 i.year, fe vce(cluster countryid)
// We are accounting for things that don't change over time (entity fixed effects such as geography) and across countries (time fixed effects such as climate change). But we are not capturing things that vary across time and entity.
// On average, a 1% change in lneduc25 would be expected to decrease the growth rate by 0.01*2.37% percentage points over a 5-year period, ceteris paribus. This result is significant at 1% significance level.



/*7. There are different ways to estimate fixed effect s models. We have mostly relied on Stata’s built in command xtreg, but we could also “manually” estimate the effects using multiple binary variables ( Least Squares Dummy Variable approach )). How many binary variables to we need on the right hand side to est imate the time andentity fixed effects model?

//we need dummies for countries and years
//for dummmies we always include n-1
//7 years=7-1=6
//103 countries= 102 dummy variables
// 102+6=108 number of variables that you should be adding in order to manually estimate this 

//useless but the general model would be: 
//yit=b0+x1b1it+lambda1Zi1+...+ lambdanZiK+...+b1greekD1t+uit

study over the weekend:
instrumental variables and entity fixed effects

*/
// LSDV Approach: we would need 102 dummies for countries (there are 103 countries) and 6 dummies for time (there are 7 years) --> 108 dummies in total.
reg growth demo lngdpl lneduc25 i.year i.countryid, vce(cluster countryid)

/* Summary Fixed Effects Model

	1. Definition Panel Data
		a. Balanced vs. Unbalanced
	2. "Within" Regression - Fixed Effects - LSDV
		a. Entity fixed effects
			I Omitted Variable Bias (unobserved heterogeneity)
		b. Time fixed effects
			I Omitted Variable Bias (unobserved heterogeneity)
		c. Clustering of Entities for SE*/




		
		
****************************************************************************
*****Tutorial 7: Panel data and instrumental variables
**************************************************************************

clear all 
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAII\Tutorial 7"

use "war_growth_data"

////////////////////////////////////////////////////////////////////////////////
/*1. Describe the relationship between economic growth current at time t; gdp_g and
civil conflict graphically. There are two thresholds used to classify civil conflicts:
more than 25 deaths (any_prio) and a more restrictive definition using more than
1000 death s due to an event ( prio)prio). Pick one of the definitions and compare
results with your peers. How are the variables economic growth and civil conflict
distributed?*/

scatter any_prio gdp_g //gdp growth goes from negative to positive on the x, y is binary, can we see a positive or negative relationship between 1 war and gdp, we see a slightly negative relationship - for easy to read jitter 
scatter any_prio gdp_g, jitter(20) || lfit any_prio gdp_g // jitter specifies a radius from the observations and allows you to observe the spread better. allows you to see the true concentration of the observations 

//a weak negative relationship, lfit is not trusted as there is a binary relationship. try correlation pwcorr y x, sig to check for strength 
pwcorr any_prio gdp_g, sig
//we observe a weak and not significant correlation between the two variables. 
//negative relationship - there may be sim causality between conflict and gdp_g*/
// Higher GDP decrease the likelihood of war. Still, we have a functional form misspecification given that the war variables are binary.

hist gdp_g, normal //is normally distributed 
twoway hist gdp_g || kdensity gdp_g

hist any_prio //probability of success or failure 
// distribution of binary variable: two categories = bernoulli distribution, it follows a logistic shape. (probability distribution!)





////////////////////////////////////////////////////////////////////////////////
/*2. Use pooled OLS to regress economic growth on your variable of civil conflict. Add
control variables for religious and ethnolinguistic fractiona lization ( ethfrac; relfrac )
as well as at least two other control v ariables . Interpret the effect of economic
growth on conflict and discuss whether the definition of conflicts matters. Why
could the functional form of the model be miss specified?*/

//reg model 

reg any_prio gdp_g ethfrac relfrac pop trade_pGDP, r 


// binary dependent variable and OLS: not wrong but inefficient: its a linear probability model - the dependent variable is binary.  -> not accurate. if you want to be accurate then use probit model which accounts for the fact that you only have two categories. but LPM gives indication what we would expect from a probit model. 
*Comparing probit to LPM. bc for panel data there is no probit. Do results differ? -> to udnerstand if we can trust LPM

//EXAM: Correct standard interpretation.
*There is a negative relationship between any prio and gdp_g. 
*On average, with a one unit increase in gdp growth the probability of war happening decreases by 28.9%, ceteris paribus. This is not significant at any conventional level. 

*The relationship between any prio and trade is negative. 
//On average, with a one unit increase in trade the probability of war decreases by 0.34%, ceteris paribus. This is significant at the 1% 5% and 10% level.

//Why could the ff miss-specified?
//bc, it goes above 1 and below zero. It does not show the distribution in the values of the dummy. This is an OLS regression but the dep var is binary, thats why it could be misspecified. We get an approx to an estimate, but cannot use it to make prediction. If you are only interested in the jump the change the delta and not the prediction then a good model. OLS should not be used to make predictions for dep binary model. 
*simple:
// The functional form of the model could be misspecified because the dependent variable is binary.



////////////////////////////////////////////////////////////////////////////////
/*3. Estimate the same model using a P robit regression. Report the marginal effects at
the mean and compare the results to the OLS model of 2. Do you find substantial
differences in the effect of economic growth on conflict*/

probit any_prio gdp_g ethfrac relfrac pop trade_pGDP, r 

//This coeff does not tell us probabilities therefore the margins command. 
margins, dydx(*) atmeans post
//taking the mean coefficient and take the first derivative to get the probabilities. 
//close enough values of trade and gdp_g - the probit is a more accurate model 
//atmeans bc all are continous variables, could also do at value for categorical variables. We conclude that estimations from the LPM are ok but not the predictions.

//interpret trade again. The relationship between war and trade is negative. On average, with every additional unit (1% or 1%p?) of trade the probability of war decreases by 0.42%, ceteris paribus. This is significant at the 1% 5% and 10% significance level. 

*Alternatively
//The average marginal effect of GDP on the likelihood of war is -11% for each additional unit of GDP growth, ceteris paribus. This result is not significant at any alpha level. 

//IN LPM WE TRUST//
 

 
 
////////////////////////////////////////////////////////////////////////////////
/*4. Reestimate 2 with a country fixed effects model (OLS model). 
Does the effect of economic growth on civil conflict change? 
What about the effect of your control variables?*/

//*Country fixed effect model: simpliest form of fixed effect is to add a dummy variable. 
encode country_code, gen(country_x)
reg any_prio gdp_g ethfrac relfrac pop trade_pGDP i.country_x, r 
//ZMB and ZWE are omitted bc of collinearity. 
//very alike, very similar history. 
//AGD is the reference group, but not omitted, its within the model. 
//in order to change reference group change order of country. 
//pooled ols - values centered around 0 in order not to xxxx lfit between countries but account for all countries. intercept in fixed effect changes but average slope stays the same. 
//constant is not economically meaningful as it contains b0 and the fixed effect. 

*Country fixed effect model 
xtset ccode year
// The panel data is unbalanced.
xtreg war_prio gdp_g ethfrac relfrac lpop Oil i.year, fe vce(r)
// Control variables ethfrac and relfrac are omitted given that they are time-invariant = perfect multicollinearity with the intercept.
// The effect of economic growth on war is still not significant.




////////////////////////////////////////////////////////////////////////////////
/*5. Some researcher argue that economic growth may be endogenous in your model ?
Discuss why you do(n’t) agree.*/

//EXAM: // OVB, functional form misspecification, measurement error, sample bias and simultaneous causality are all threats to the internal validity of the model.

*1 reverse causality or similtunaity 
//if war economy shuts down and if econ shuts down people unhappy and there is war.
 
*2 ovb
// food insecurity, unrepresentativeness of ethnicity in democtratic institutions, 
//EXAM ARGUE gdp_g: exp side, prod side, export-import (all included?)
// would the production side not include hh wellbeing and food security
//I argue no: example ethiopia, gdp growth rate impressive but food insecurity is due to regional geographical differences, market structure, etc.
//Understand the logic of the model and why the model is valid or not valid.
//Model arises from theory and thinking, what is out there and what data is there to explain it. 
//EXAM: READ THE PAPER - to understand the logic - the perspective of the whole of the macroeconomy. 
//democracy: institutional system, for example the more parties the more potential for strife. 
// Prof. Collier for studying conflict.

*3 sample bias 
//only this one talks about external validity 
*internal validity only in ss africa
*cannot explain conflict in asia or latin america. 
*global: only if countries from outside exogenous. 

*4 measurement errors
// gdp_g hard to measure. 

*5 ff missspecification 
//see above - GLM vs probit, we are estimating a linear prob model for a binary variable. 

//EXAM: Discuss all of them in Detail! 




////////////////////////////////////////////////////////////////////////////////
/*6. Pick one of the potential instrument s for economic growth. Under which
circumstances is rainfall/aid a valid instrument for growth? Estimate an IV fixed
effects model and test whether we should treat economic growth as endogenous.
(hint: use Stat a’s xtivreg 2 command). Briefl y discuss with your peers whether you trust your instrument. Do the results hold if you use economic growth in the past
(period t1 ; gdp_g_1)?*/

ssc install xtivreg2
xtivreg2 any_prio ethfrac relfrac pop trade_pGDP (gdp_g=GPCP_g), fe endog(gdp_g) r first
//rainfall at time t
//fe fixed effects
//specify gdp_g as endogenous variable. 
// no vce clustering necessary (relax the assumption that std errors are correlated within certain clusters)

*1. Output table interpreted the same way. Ethn frac are omitted, bc collinearity, they vary across countries but dont vary over country but not overt time, are therefore accounted for in the constand in the fixed effects model. 
*2 interpretation *e^-xy eulers number. The number is very close to zero! 
*When you interpret the tests (they all relate to the instrument), always state the null hypothesis

*A) Underidentification test of the instrument. Ha: not underidentified, we have at least as many instruments as endogenous variables. H0: instrument was underidentified. When pvalue <0.05 then reject the H0 that instrument has been underidentified. Therefore it has not been underitendified. Only about the number of instruments and the number of endogenous variables! The instrument is supposed to be endogenous but used to control for exogeneity. 
*Now we know that we have one endogenous variable (and one instrument=same in this case)

*B) Weak identification test:
*Cragg Donald Wald F statistic (same as for first stage equation): 
*Is it then or above
*if below ten then I have a weak instrument. 
*My Fstatistic is 9.18 and that is below the threshold of 10, therefore I can conclude that I have a weak instrument. 
*Stock-Yogo (whats gonna happen to the estimation of your instrument if it is weak) - for any of these cat you have a critical value. If one of these crit values is larger than the fstatistic, then we know that at most a 10% bias of the estimation. In this case cat 1 10% max iv size is 16.38>9.18 wald fstatistic - therefore 10% of our estimation are biased. 
*know why: weak instrument bc wald below 10 and XY% bias so i would exclude or include bc other instruments are hard to find. 

//- no first stage input in exam. 

*C)Hansen J statistic (overidentification test for all of the instruments)
*H0: we have overidentified our instruments
*Ha: we have not overidentified our instruments
*we can rejcet h0 at 1%, we have appropriately identified our instruments. 

*D) Denogeneity test: most important bc even if corrently identified but remeins endogeneity. 
/*we want to fail to reject h0
H0: the istrument is exogenous
we want our instrument to be exogenous 
withchi2 p 0.83 we fail to reject the h0 that the isntrument is exogenous.*/

//We have an exactly identified exogenous instrument with at least 10% bias. It is relevant, close to 10 but weak. Have to decide on my own to if I want to keep it.  

/*"Endogeneity tests of one or more endogenous regressors can implemented using the
endog option.  Under the null hypothesis that the specified endogenous regressors
can actually be treated as exogenous, the test statistic is distributed as
chi-squared with degrees of freedom equal to the number of regressors tested.
The endogeneity test implemented by ivreg2, is, like the C statistic, defined as the difference of two Sargan-Hansen statistics:  one for the equation with the
smaller set of instruments, where the suspect regressor(s) are treated as
endogenous, and one for the equation with the larger set of instruments, where
the suspect regressors are treated as exogenous.  Also like the C statistic, the
estimated covariance matrix used guarantees a non-negative test statistic.  Under
conditional homoskedasticity, this endogeneity test statistic is numerically
equal to a Hausman test statistic; see Hayashi (2000, pp. 233-34).  The
endogeneity test statistic can also be calculated after ivreg or ivreg2 by the
command ivendog.  Unlike the Durbin-Wu-Hausman tests reported by ivendog, the
endog option of ivreg2 can report test statistics that are robust to various
violations of conditional homoskedasticity; the ivendog option unavailable in
ivreg2 is the Wu-Hausman F-test version of the endogeneity test.  See help 
ivendog (if installed).
"*/

*ALTERNATIVE VERSION
xtivreg2 war_prio (gdp_g=GPCP_g aid_capita) ethfrac relfrac lpop Oil, fe r endog(gdp_g) first
// The instruments are weak: first-stage F=3.91<10. Moreover, the Hansen J statistic's p-value=0.0143<0.05 so we reject the overidentification null hypothesis. Instruments are weak and endogenous, so they are not relevant/valid at all.
// The instrumented variable income growth is exogenous (endogeneity test p-value=0.24, so we cannot reject the null hypothesis of exogeneity). We could then use a simple OLS instead of IV regression.
 

 
 
/*7. Instruments are usually debatable. As robustness check, a colleague recommends
you to use settler mortality as in strument for economic growth? If you were to reestimate model 6, what would you expect to happen?*/

xtivreg2 any_prio ethfrac rel, fe vce(r)

*rainfall affects economic growth, highly relevant for agrarian societies. 
*settler mortality: not instrument for gdp_growth bc it would be instrument of the instrument. gdp_g is controlled by qual institution and quality of institution is controlled by settler mortality.  
*2 conditions for instrumental
*only correleted to the outcome y through its effect on x
*model: panel data set. settler mortality was estimated in one period. when settler arrived remains constand over time. in panel data set one single number for all of the years. - would stay as fixed effect as doesnt change over time, would be dropped by stata automatically. 
//D crombrughe cultural factors change but does not change is not captured normal panels. 

br country_x year ethfrac relfrac
codebook ethfrac relfrac, c

*// It's not okay to use settler mortality as an instrumental variable given that it is time-invariant (there is only one settlement period), so Stata will drop it.






****************************************************************************
*****Tutorial 7 (with Solomon). 
**************************************************************************
*look at the interpretation and look at instrumental variable, panel and fixed effects together 
xt and ivreg2 combined 

*they say that gdp is endogenous, there is simulteneity and ovb, measurement error (precision of measuring conflict) 

scatter any_prio gdp_g, jitter(25) || lfit any_prio gdp_g

xtset (ccode year)
xtivreg2 war_prio (gdp_g=GPCP_g aid_capita) ethfrac relfrac Oil lpop fh_civ soc, r fe endog(gdp_g) first

//relevance: cragg donald wald f weak instrument fail to reject H0: the instruments are weak

//exogeneity test: (valid or not): hansjen statistic 
/* Overidentification tested
H0: all instruments are valid (they both are exogenous)
H1: at least one of them is not valid=endogenous*/
//We dont want to reject the H0!
//Reject H0 if chi2 p value <0.05 
// Chi-sq(1) P-val =    0.1022 >0.10%  
//if p is bigger than alpha, we fail to reject H0, the instruments are exogenous.
//The higher the alpha we fail to reject the H0 with the better.  

//Endogeneity test on X: After controlling for endo in our model can we now conclude that our x is exogenous. if our innitial endo variable X is now exogenous or not 
//H0 x(gdp_g) is exogneous (immer positiv)
//Ha
//Reject H0 if p<0.05
// Chi-sq(1) P-val =    0.1279 >0.05 
//We fail to reject H0, so that means that X is now exogenous. 
//We want to fail to to reject. 

//Interpretation. 
//Holding all other factors constant, an additional unit in gdp decreases the propability of war by 196.77% (have to multiply by 100 bc of binary). Significance. 
// ethfrac relfrac omitted correcting for entity fixed effect. vary across countries but does not change over time. (idea of fixed effect)
//LPM vs. probit. problem with predicted values bc they go beyond zero and one. 
//not the true estimate


//with one instrument. 
xtivreg2 war_prio (gdp_g=GPCP_g) ethfrac relfrac Oil lpop fh_civ soc, r fe endog(gdp_g) first 
//we cannot perform the validity test with one instrument for one x. The equation is exactly identified. 

