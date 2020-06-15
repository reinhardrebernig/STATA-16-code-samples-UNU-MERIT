*******************************************************************************
******************** Regression Analysis I **************************
						*Overview*
*******************************************************************************

* Tutorial 1-6 notes		
* Author: Reinhard Rebernig				        
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Revsion:  0006 Last change: 15/05/20 by Reinhard Rebernig


***************************************
***TUTORIAL 1***
***************************************

pwd

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial\psid.dta"

dir

br

*1.1. Given you are interested in estimating the returns to education, what are the dependent and independent variables in your estimation model? Write down the estimation model and discuss the parameters.
* ^y=a+beta*x+e
* wagei=b0+beduc+ui

// total obs 6603
// missing people are unemployd



*1.2. 2. Open the dataset in Stata and draw a scatter plot showing the relationship between education and wage. What do you observe?
scatter wage educ //gives the 5450 

gen lnwage=ln(wage)
scatter lnwage educ

// 


*1.3. Add a fitted OLS line to the scatter plot to display the relationship between education and wages. What is the meaning of the line and what does the line suggest? How well does the line fit the data?
twoway (scatter wage educ) (lfit wage educ), legend(off)

twoway (scatter lnwage educ) (lfit lnwage educ), legend(off)

gen balaba=7 if educ>5000 | age>18 // "||" and "|" are logical operators for "or"
order wage edu blabla // order variables 

help scatter


*1.4. 4. Estimate the effect of education on wages using OLS. Interpret the slope coefficient (coefficient size, sign and implication). In what units is the slope measured?

reg wage educ // reg Y X 

*1.5. 5. Interpret the intercept. Is it economically meaningful? Intercept not meaningfull

*1.6. What is the expected wage for a woman/man with 10 years of education? What if years of education increase to 11 years? And someone without formal education?

reg wage educ if educ==10 & female==0

gen 

* for both genders =  10.97967 for man/woman with 10 years of education
display -14.24362+10*( 2.522329)

*for both genders with 11 = 13.501999 
display -14.24362+11*( 2.522329)

**for both genders with 0= -14.24362
display -14.24362+0*( 2.522329)

//the difference between 10 and 11 years of schooling is almost exactly the coefficient in wage
reg wage educ if female==1 //would split the sample and bring different results
reg wage educ
display _b[_cons]+_b[educ]*10
display -14.24362+ 2.522329*11
by female, sort: reg wage educ



*1.7. BONUS What is the expected wage for a male/female whose years of schooling are equal to the sample mean. 

sum educ, d
return list 
*r(mean)= 13.19188247766167
display -14.24362+r(mean)*( 2.522329) // 19.030648

sum wage, d // reveals that r(mean) =  19.37972 almost similar bc missing values still countet in 
sum wage if wage!=., d 
//  19.37972

reg wage educ
sum educ if wage!=. //excluding educ when wage is missing
return list
di _b[_cons] + _b[educ]*r(mean)

//different values bc different number of observations



***************************************
***TUTORIAL 2***
***************************************


*2.1. Re-run the estimation on the effect of schooling on earnings using OLS. 

reg wage educ

*Are the slope and the intercept significant at the 1% significance level? 

*H0: educ does noet have any effect on education
*H0: Beta1=0

ttable
ztable 
// look up 0.5-alpha/2 for two tailed 
// look up 0.5-alpha for one tailed

slope
t=17.51 
if the t value is > significance values 
95% 1.96
99% 2.58
90% 1.64
P>t 0.000 < 0.01 // yes, significant. We can reject H0, fail to reject Ha. P value is the value of the probability that H0 is correct. If it is below alpha we can reject. If it is above alpha we accept H0. 
* P<alpha, reject H0
* P>alpha, accept H0

_cons
t=-7.30 // rejact H0 and conclude that the 0.01 significance level education has indeed an effect on wage. It it is statistically meaningful. 
P>t 0.000 < 0.01 // yes, significant
*same explanation

*Explain how you assess the significance of these two coefficients. 

*Does your evaluation change at the 5% significance level? At the 10% level? Discuss.

reg wage educ

//


*2.2 What is the 95% confidence interval of the estimated effect of years of education according to the regression output? Explain at an intuitive level what this confidence interval means.

reg wage educ

//95%
// 2.239994    2.804665

// 99%
// 2.15123    2.893429

// We are 95% confident that the true value of the parameter beta1 educ 2.522329 lies within [2.239994    2.804665]


*2.3. How do you interpret the R2 and the “Root MSE” reported in your output?

reg wage educ
R-squared       =    0.0533

//A: 5% of the variance of wage (dependent variable) is explained by education (independent variable)

// Proportion of the variance of y explained by x.
// Example: 0.4% of the variance of employment is explained by the level of minimum wage.

//RMSE root mean square error. The standard deviation of the regression error = standard deviation of the regression error

//exam q: what does it mean and interpret it. 
// sensitive to the unit of measurement/scale - should be close to 0 for a good fit

 Root MSE        =    26.107
 
// pretty high stdev of the regression error

// SS(residual)/df
display 3713132.8/5448 //681.55888
// take the square root from MS
display sqrt(681.55888) //26.106683

//To verify RMSE, (after reg and predict e, resid)

reg wage educ
predict e, resid
gen sq=e^ 2
egen sum=total(sq)
gen rmse=sqrt(sum/758)
sum rmse

*2.4. Re-do the scatterplot with the fitted line (task 3 of tutorial 1). Discuss the concept of heteroscedasticity?

twoway (scatter wage educ) (lfit wage educ), ytitle() xtitle() legend(off) 

//Heteroskedasticity: the variances for all observations are not the same. More speciffcally, the variance depends on x. If the dependent variable increases the variance of observations changes. 
//Heteroskedasticity: The pheonomen that the variance of y (the dependent variable) depends on x (the independent) variable. 

The spread of Y is dependent on X. 

predict e, resid
scatter e wage

*2.5. Re-estimate 1 with robust standard errors. Test for the significance of the slope and the intercept at 1%, 5% and 10%. Compare with the previous results.

reg wage educ, r

/*R-squared         =     0.0533
Prob > F          =     0.0000

 wage |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        educ |   2.522329   .1501905    16.79   0.000     2.227896    2.816763
       _cons |  -14.24362   1.827658    -7.79   0.000    -17.82656   -10.66068

coef educ P>t = 0.000 < 0.05 reject H0 that slope=0
coef _cons P>t = 0.000 < 0.05 reject H0 that intercept=0*/

	   
*2.6. Overall, what is your conclusion to the question of the effect of education on earnings?

*With significane of 1% level we can say that an individual earns 2.5 USD more per year of education, but the relationship cannot be fully explained by our model as educ only explains 5.33% of the variance of the dependent variable wage. Heteroskedasticity appears in our data. 

//F test tests the overall probability for 

/*
1. direction
2. magnitude
3. significance level 
Education has a positive effect on wage. For each additional year of education the hrly wage increases by 2.52 USD, holding all other factors constant. This result is significant at the 0.01% level. But the relationship cannot be fully explained by our model as educ only explains 5.33% of the variance of the dependent variable wage. Heteroskedasticity appears in our data. 




***************************************
***TUTORIAL 3***
**************************************


pwd

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial\psid.dta"

dir

br

describe


*1. Your estimation of the effect of education on wages may suffer from omitted variable bias because you did not account for differences in work experience. Discuss with your peers under which circumstances this bias occurs using Stock and Watson’s Key Concept 6.1.

corr wage exper
corr educ exper


*2. Is the effect of education on wage upward biased (+) or downward biased (−) when experience is not controlled for? Explain your answer using an argument based on Stock & Watson’s formula (6.1) and the surrounding text (or the lecture slides). */

reg wage educ, r
reg wage educ exper, r

corr educ exper //downward bias bc the effect depends on the correlation. The education coefficient is overestimated if you dont control for experience (include it in the Model). 

//if you dont add experience you have a downward bias. 

//checking for overestimeation only comparing models
//


*3. Estimate the effect of education on wage controlling for work experience. What do the estimated coefficients and the intercept measure?

// focusing on one variable education and controlling for years of experience

// wagei=b0+b1*educi+b2experi+ei

reg wage educ exper

/*1. direction
2. magnitude
3. significance level 
Education has a positive effect on wage controlling ceteris paribus for experience. For each additional year of education the hrly wage increases by 2.35 USD, holding all other factors constant. This result is significant at the 0.01% level. But the relationship cannot be fully explained by our model as educ only explains 14.62% of the variance of the dependent variable wage. Heteroskedasticity appears in our data.*/

hettest // tests the Ho: Constant variance  of the variables if Prob > chi2  =   0.0000
// we reject the H0 because Pr < 0.05 alpha 

reg wage educ exper, r 
reg wage educ
//without the control variable exper the coeff for education was bigger = upward bias of b1

// With level of significance of 1% we can say that with every additional year of education the hourley wage increases 2.35 USD more holding all other factors constant (ceteris paribus years of experience)

// With level of significance of 1% we can say that with year of work experience the hourley wage increases 0.67 USD more holding all other factors constant (ceteris paribus years of education with partial effect of 2.35)
// 




*4. Check if the effect of education on wage is the same after controlling for at least three additional variables of your choice (you should explain the choice of the variables you picked).

des
reg wage educ exper age i.city i.female, r

// we see that the gender gap causes a -3.54 hourly wage gap for females 

reg wage female, r 
ttest wage, by(female)

// reveals that the male mean (22) is higher than the female (15) and that when we do the regression reg wage female b1 of female is -6 -> 22-6.=15.
// the diff in the t test is exactly the delta in the regression 

//we reject the null hypothesis at 95% ci, as the p-value is below the significance level of 5% in support of the alternative hypothesis --> we fail to reject the alternative hypothesis -> wage levels are differt by gender (very clear if we look at the mean in the table). 

tab female, gen(gender1)
reg wage educ exper age gender1, r

reg wage hours educ i.city exper age i.female, r 
// if city=1 it means that one lives in an urban area. this mean sthat on average if on lives in a city ears 3.07 more than one who lives in a arural area, holding other factors constant. 

sum age, d

graph box age
scatter wage age // peaks in middle age and then lower again

gen age2=age*age

reg wage age age2, r //to show that collinearity exists and an inverse relation

***trying regression with categorical***

drop agecat
gen agecat=. 
replace agecat=1 if age<=18
replace agecat=2 if age>18 & age<65
replace agecat=3 if age>65

label var agecat "Age categories"
label define agecat 1 "below 18" 2 "age 18-65" 3 "above 65", replace
label values agecat agecat

tab agecat, gen(agedum)
br agedum*


reg wage i.agecat edu, r 
reg wage agedum1 agedum2 agedum3, r





*5. Does the intercept in the model from (4) have practical relevance? Explain.

reg wage hours educ i.city exper age i.female, r

// meaningless constant  





*6. Use Stata’s predict command to predict wages of all observations in your data set with the model used in task 5. Graphically compare the predicted wages with the actual wages. Based on the graph, what can you say about the model fit?

reg wage educ i.city exper age i.female, r
predict wage_pred2

graph box wage wage_pred // not the right one

scatter wage educ || scatter wage_pred2 educ

*With significane of 1% level we can say that an individual earns 2.5 USD more per year of education, but the relationship cannot be fully explained by our model as educ only explains 5.33% of the variance of the dependent variable wage. Heteroskedasticity appears in our data.





***************************************
***TUTORIAL 4***
***************************************
clear all 

pwd

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial\psid.dta"

dir

br

des


*1. Re-estimate the effect of schooling on earnings, controlling for experience and at least three other explanatory variables of your choice. Interpret the regression output.

reg wage educ exper age i.female i.city, r

How to interpret. 
effect
statistical significance
measure of fit of data

direction
magnitude
significance
R2
Heterskedasticity
Controlling for all other factors


// Interpretation: With level of 1% level of confidence (since P>t=0.000<0.01) Every additional year of education will give you 2.21 USD more wage per hour, holding all other factors constand.

//adjusted r2 takes into account
//r2 willl alaways increase since you add variables, since it snot meaningful anymore. 
//Therefore we have to adjust it.  

reg wage edu, r
predict residuals, resid
replace residuals=residuals+rnormal()
corr residuals wage educ
reg wage edu, r 
reg wage edu residuals, r 

//constructing a variable that is only corr to wage but not to educ (condition 1 is not satisified) beta does not change - not so problematic


*2. We are interested in testing whether the coefficients on education and on experience are independently equal to zero. Write down the null and alternative hypotheses. What test statistics do you need? Conduct the tests at 1%, 5% and 10% levels and discuss your findings.

reg wage educ exper age i.female i.city, r

//Testing that there is no correlation - horizontal? Test if there is a correlation between educ and wage and exper on rage ? 

//H0: beta1educ=0
//H1: beta1educ!=0
reg wage educ exper age i.female i.city, r // if the Prob>F = 0.10 the model has no explenatory value compared to the intercept. Tests the value between The F-statistic in the output table: all regressors = 0i.e. intercept-only model vs. full model Slide 28/35 lecture 3


//H0: b1=b2=b3=0 - read the ftable for it F value comparing with 
test educ
test exper

ftable // F test value we get is higher than the value we get from the f distribution (critical value) = we reject the H0

//https://keydifferences.com/difference-between-t-test-and-f-test.html

//Use restricted model to understand if the coefficient is significantly different from zero
// the command test assumes H0: beta0=0
//  Prob > F =    0.0000 = At the 1% significance level we can reject H0 and can say that the variable is unequal to zero and has an effect. 


//H0: beta1exper=0
//H1: beta1exper!=0





*3. Test the hypotheses that the coefficients of education and experience are both zero against the alternative that at least one of the coefficients is different from zero. Write down the null and the alternative. Implement the test and discuss the results.

//H0: bedu=bexp=0
/*H1: 
Bedu=0 bexp!=0
Bedu!=0 bexp=0
Bedu!=0 bexp!=0
*/// "Joint test" of variables

reg wage educ exper age i.female i.city, r
test educ exper 
ftable

//We can reject the H0 that both variables are equal to 0 at the 1% significance level since Prob > F =    0.0000 < 0.01 
// and F(  2,  5441) =  311.64 > 3.00
// The Ftest of the regression tests this automatically in the reg statistics

//e.g. policy maker statement: Neither education nor experience has an effect on wage. Which I can reject with rejecting the H0

// ftest only by homoskedasticity




*4. Test whether the coefficient of education is equal to the coefficient of experience.

*H0: beduc=bexper
*H1: beduc!=bexper

// Prob > F =    0.0000 < alpha 0.01 we are able to reject H0 that the coefficients are the same in the restricted model 

reg wage educ exper age i.female i.city, r

test edu = exper



*5. Run a ‘restricted’ model by dropping at least two variables of your choice in the restricted model compared to the model used in question 1. Which model has a better goodness of fit? Why?

reg wage educ exper age i.female i.city, r

reg wage educ exper city, r

reg wage educ exper age i.female i.city

reg wage educ exper city 

//use adjusted r square to compare models as it accounts for the "the more variables the better the explanation" effect
// adjusted r2 is used to compare models with different number of variables 
// the larger the value the better the model

reg wage educ exper age female faminc // better fit




***************************************
***TUTORIAL 5***
***************************************

clear all 

pwd

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial\psid.dta"





*1. Re-estimate your preferred specification of the last tutorial. Discuss why you would(n’t) expect interaction effects between any of the independent variables.

reg wage educ exper age i.female i.city, r 

// likely that age and exper is correlated
corr educ city
corr age exper // only high correlation
corr female educ
corr age city
// likely that city and education has a correlation

gen inter1=female*educ //theory that female and educ has interaction effect 

reg wage educ exper age i.female i.city inter1, r //telling the model that the relationship between educ and wage is not linear bc we expect a difference for female and male 

// Ceteris paribus, effect of interaction (inter1=female*educ) the effect of the interaction means that for every extra year of education the wage of the female decreases by USD -1.59. Remember what you combine. 

/* lec 6 slide 16
//

1.
Is there a shift in the intercept β2
𝐻0:β2=0 t test

asking for case number three 

2.
Are slopes different?
𝐻0:β3=0 t test
3.
Do functions coincide?
𝐻0:β2=β3=0 joint F test*/

gen inter2=educ*exper

reg wage educ exper age i.female i.city inter1 inter2, r

//

reg wage c.educ##i.female exper i.city age, r

reg wage c.educ##i.female c.educ##c.exper i.city age, r 





*2. Now use the data to include interaction terms of education with at least one continuous and one binary variable. Explain your choices. Discuss in which scenario we are in (see lecture slides or Stock & Watson Figure 8.8). 

// Decide for one model 

gen inter2=educ*exper

reg wage educ exper age i.female i.city inter1 inter2, r

//

reg wage c.educ##i.female exper i.city age, r

reg wage c.educ##i.female c.educ##c.exper i.city age, r 

// The effect of education varies with experince, meaning that the marginal effect of education is higher for people with more market experience. 
//As people acquire more experience, the effect of edcuation on wage becomes more and more positive
//look up slide 19 lecture 6
// The effect on wage of an additional year of experience increases by 0.07 for each additional year of education that an worker has. 

// practice group 
reg wage c.educ##c.exper age female city, r 



//The marginal effect of an additional year of experience on wage for each additional year of education is the coeff of exper+ the coeff of education. 
//The marginal effect of education when you dont have experience is just beta2.
// The marginal effect of an additional year of education on wage increases with an additional year of experience by b3. 



reg wage c.educ##i.female exper age city, r 
// The effect on wage of an additional year of education is decreasing by -1.59 when you are women. =correct interpretation. 

//When you are an female, the marginal effect of education on wage is b1+b3. =2.93+(-1.59)=1.4 something

//When you are a male the effect of an additional year of education on wage is 2.93. only b1. When you are a male for each additional year of education your wage increases 2.93 USD per hr, keeping all other factors constant. 
//Whn you are a female, the marginal effect of an additional year of edcuation on wage is 2.93 -1.59=1.34. 

//The expected value of wage for an additional year of education is reduced when you are an female by -1.59

//For female the marginal effect of education on wage is 1.34. When you are female the hourly wage increases by 1.34 USD on average 



*3. Interpret the coefficients (constant and all coefficients of interacted variables) and discuss which specification you prefer.

reg wage c.educ##i.female exper age i.city
testparm i.female##c.educ //we test jointly if b1, b2 and b3 is zero //slide 19 q3
test c.educ#1.female 1.female c.educ // tests b2 and b3 - same but to specify all parameters extra
//

// look at t value of q1 and q2
// there fore we are in scenario 2

reg wage c.educ##c.exper i.female age i.city,r 
test c.educ#c.exper c.exper
testparm c.educ#c.exper 

//A: prefer 1 bc of higher adjusted R2. i.female##c.educ 
//A: parameter of interaction significance is significantly//
//A: 

//The marginal effect of an additional year of experience on wage for each additional year of education is the coeff of exper+ the coeff of education. 



*4. Let us consider the interaction between education and experience. Test the hypothesis that the effect of education does not vary with experience. Characterize the partial effect of an additional year of education for women with 5, 6, 7,…, 17 years of education graphically. Interpret your findings.

*fit OLS
reg wage c.educ##c.exper i.female age i.city,r 
**testing for shifts in intercept and slope. check regression coefficient for simple ttest
*joint significance test ----> does slope and intercept shift make a significant


*predicted effect
*marginal effect of gender at different levels of school attainment
margins, dydx(educ) at(exper=(5 (1) 17) female=1)
*plot margins //marginal effect of education at different levels of work experience
marginsplot //effect of education on wage varies with work experience

// same for female
reg wage i.female##c.educ exper age i.city,r
margins female
margins female , at(educ=(0 (2) 16)) 
*plot margins
marginsplot

//trying for education
margins, dydx(educ) at(educ=(1 (1) 17) female=1)
*plot margins
marginsplot //effect of education on wage varies with work experience





***************************************
***Tutorial 5***
***************************************
pwd

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\PSID tutorial\psid.dta"




*1. Graphically assess the relationship between the variable wage and educ. What can you say about the functional form of the relationship?
twoway (scatter wage educ) (lfit wage educ)
//line only depicts the linear relationship but does not depict the non-linear non-constant marginal effect 




* 2. Log transform the dependent variable and compare the results to the estimations of the previous tutorial. What do the estimated slope and the intercept measure?
gen lnwage=ln(wage)
// generated over 1000 missing values and thats ok bc we can only work fully with the log on the dependent variable or with the linear term, but not keeping it and 
*gen lnwage=ln(wage) if wage>0 //this is not acceptable
*solution everything plus 1
// now we have the new log transformed dependent variable -> case II. 


reg lnwage educ, r
//Correct Interpretation: A change in education by one unit is associated with a (100*0.11)=11% of change in wage, at a significance level of 1%. 
// If education is equal to zero, the constant the lnwage is equal to 1.09. If we raise e^intercept than we find the real intercept. ln(y) = 1.095 transformed to y=e^1.095
di exp(1.095112) //gives us the real intercept (command exp uses euler number as base)
// the expected hourly base wage without education (the intercept) is USD 2.99. 
// Economists like ln transformation bc when you transform a variable in ln then you can interpret the coefficient in % change.
//approximation only works for delta of y <0.1 in independent variables. marginal change (x axis) in one unit has a non continous effect (y axis)
twoway (scatter lnwage educ) (lfit lnwage educ)
twoway (scatter lnwage educ) (scatter wage educ)





*3. Now also transform the independent variable exper. How do you interpret the estimated coefficient? Does a transformation make sense in this case?

reg lnwage educ exper female city age, r 
//Interpretation: 
// With every year of education the hourly wage increases by (0.1097*100=) 10.97% (holding all other factors constant), at a significance level of 1%. 
// With every year of experience the wage will increase by (0.05*100=)5%, holding all other factors constant. This is significant at the 1% level. 

//Interpetation of the intercept. Ln wage is equal to 2.17 (the intercept) if all the variables are equal to 0)

*answering question 3
gen lnexper=ln(exper)
reg lnwage educ lnexper female city age, r 
// A 1% change in years of experience is associated with a 0.49% change in wage, so 0.49 (no percent) is the elasticity of wage with respect to X. 
//Elasticity usually if %price changes how does %demand change.  Here: Price elasticity of demand. 

*4. Now specify a Mincer earnings function (https://en.wikipedia.org/wiki/Mincer_earnings_function). Discuss whether work experience has a statistically significant non-linear effect on wages according to your model.

/*The Mincer earnings function is a single-equation model that explains wage income as a function of schooling and experience, named after Jacob Mincer.[1][2] The equation has been examined on many datasets and Thomas Lemieux argues it is "one of the most widely used models in empirical economics". Typically the logarithm of earnings is modelled as the sum of years of education and a quadratic function of "years of potential experience".[3][4]

ln w=f(s,x)=ln w_{0}+rho*s+b1x+b2x^2

Where the variables have the following meanings; w is earnings (the intercept w0) is the earnings of someone with no education and no experience); s is years of schooling; x is years of potential labour market experience.
The parameters rho, and beta1 beta2  can be interpreted as the returns to schooling and experience, respectively.

Sherwin Rosen, in his article celebrating Mincer's contribution, memorably noted that when data was interrogated using this equation one might describe them as having been Mincered.*/

reg lnwage educ c.exper##c.exper, r

//Interpretation
// A change in 1 year of education is associated with a (100*0.1102)11.02% change in hourly wage, holding all other factors constant at and significant at the 1% level. 

//Where the one year change in experience causes a 3.42% in wage the non-linear marginal effect hints at a inverted u-shaped form with a small negative -0.02184% change in wage in increasing years of experience. Holding all other factors constant. Significant at the 1% level. 

reg wage educ c.exper##c.exper, r
// without the ln transformation term we see that the x^2 is small and non significant. We use the ln(wage) to see the very small changes!  


*5. Based on your preferred model specification: Mary (Antoine) is a 30 year old woman (man), with 14 years of education, has 2 children under 6 and average in terms of other control variables. Susan (Patrick) is like Mary (Antoine) but has 16 years of education and has no children. Compute the expected difference in earnings between Mary (Antoine) and Susan (Patrick).

// compare Mary,30,female, 14 years of educ, 2 kids, with Susan,30,female, 16 years of educ, no kids, both female
// compare Antoine with Patrick, both male

reg wage educ exper kidslt6 age i.female, r //since they are both female and you compare them

di _const+14*_b1+ 2*b3
di  4.069956+(14*2.412194) + (2*.6280307) + (30*-.8080022) + (1*-3.484037) //Mary 11.37263
di  4.069956+(16*2.412194) + (0*.6280307) + (30*-.8080022) + (1*-3.484037) //Susan 14.940957

// compare delta 
di 14.940957 - 11.37263 //= 3.568327

// complicated way which doestn work. 
// or use 2*2.412194 +- 2*  .6280307
di 2*2.412194 + 2*  .6280307  //6.0804494
di 2*2.412194 - 2*  .6280307 // 3.5683266
dompare delta 
di 6.0804494 - 3.5683266 = 2.5121228 //doesnt make any sense

// for male
di _const+14*_b1+ 2*b3
di  4.069956+(14*2.412194) + (2*.6280307) + (30*-.8080022) + (0*-3.484037) //Antoine 14.856667
di  4.069956+(16*2.412194) + (0*.6280307) + (30*-.8080022) + (0*-3.484037) //Patrick 18.424994

// compare delta 
di 18.424994 - 14.856667 //= 3.568327




reg lnwage educ c.exper##c.exper kidslt6 age female, r 

***************************************
***Tutorial 6***
***************************************


*Question 1*
twoway (scatter wage educ) (lfit wage educ)
/*the marginal effect is not constant - 
the line does not fit the data
marginal effect is a small change in the 
independent variable
it is still a change in one unit
 there is a change of slope along the line 
(the change is not constant)*/

*Question 2*
gen lnwage if wage=ln(wage)
//OR
gen lnwage=ln(wage)
/*the missing values are for the negative values 
or values equal to 0 --> log transform only works 
on values>0
need to be consistant, you cannot mix 
log-transformed variables with linear 
variables --> you only work with the 
log-transformed variables and you accept the
 missing values*/
reg lnwage educ, r
/*Holding other factors constant, for one unit
 change in education would result in the 
 coefficient*100 - in a 11% change in wage
 If education is equal to 0, the expected log
 wage is equal to 1.09
The expected wage can be found by the e-value to
the power of the intercept*/
display exp(1.095112)
/*the expected wage is equal to 2.98 dollars/hour 
when education is equal to 0
log(y)=1.09
y=e^1.09  */

*Question 3*
reg lnwage educ exper female city age, r
/*interpretation of the constant: lnwage is 
equal to 2.17 (the intercept) when
all the variables are equal to 0 


interpretation of the coefficient: For each 
extra year of experience, there is an increase
of 5.55% in wage
For each extra year of education, there is a 
10.97% change in wage (log-linear)*/

gen lnexper=ln(exper)
reg lnwage educ lnexper female city age, r
/* A 1% change in experience results in a 
0.49% change in wage (log-log)*/

*Question 4*
reg lnwage educ c.exper##c.exper, r
/*There is a inverted U-shaped relationship
because the coefficient of experience is positive
and as it increases (exper#exxper) it becomes 
negative
A change in one unit in education leads to a
change of 11% in wage*/
/*With the log transformation is able to
 identify small changes, so the result is
 smaller and more significant than the linear 
 regression*/
reg wage educ c.exper##c.exper, r

*Question 5*
reg wage educ exper kidslt6 age female, r
display  4.069956 + (14*2.412194) + (2*.6280307) + (30* -.8080022) + (1*-3.484037)
display  4.069956 + (16*2.412194) + (0*.6280307) + (30* -.8080022) + (1*-3.484037)


***************************************
***Skills Test tutorial***
***************************************

clear all

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\skills test"

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\RAI\skills test\strike.dta"


*1. Use the “rename” command in Stata to rename the variable gen_strike to“strike”, bankcrisislv12 to “crisis” and debtToGDP to “debt”. (Hint: check the help page to see how the command works).
rename gen_strike strike
rename bankcrisislv12 crisis
rename debtToGDP debt

*2 Estimate the effects of banking crises on strikes with a simple regression model, assuming homoscedasticity.

reg strike crisis
*H0: Strike is dependent on debt 

Here we assume homoscedasticity (for illustrative purpose). Please use
heteroscedasticity-robust standard errors in the exam!

*3. Interpret the intercept and slope coefficient. Conclude whether banking crises have an effect on strike at the 5% significance level. State the null and alternative hypothesis.

/*The slope coefficient is equal to 0.15. It means that for a country with a
banking crisis, the strike indicator is 0.15 point higher than country with
no banking crisis on average.
The intercept is equal to 0.19. It means that for a country, which does
not have a banking crisis, the strike indicator is equal to 0.19.
H0: β1(crisis) = 0
H1: βcrisis ≠ 0
The p-value is equal to 0.169, which is higher than 0.05. We conclude that
banking crises have no statistically significant impact on strike at the 5%
level.*/ 

*if p>0.05 or t<1.96 i fail to reject H0
*if p<0.05 or t>1.96 i reject H0 

*On average the the existance of a banking crisis in the previeous five year increases the number of strikes by 0.15, ceteris paribus. This result is not significant, neither on the 10% nor on the 5% level. Therefore banking crisis does not have statistically significant effect on stikes at 5% significance level.

//increases or decreases would be one tailed test - this here is a two tailed test.  


*4. Previous research suggests that the effect of banking crises on strike depends on the level of public debt. Write down the regression model that allows us to test this hypothesis. Put only the necessary variables in the regression model (i.e. ignore the issue of OVB).

*depends= signal word for interaction

/*
Since the effect depends on another variable, we can model
conditionality by interacting two variables.
Strike = β0 + β1 crisis + β2 debt + β3 crisis x debt + ε
*/





/*5. Estimate the above model in Stata.

Debt is a continuous variable. We use c.debt instead of i.debt.
Put ## instead of # to let Stata know that you want to include debt and
crisis as separate variables in the model. */
reg strike c.debt##i.crisis, r

/*
strike = continous variable #1-6
debt = cont 0-0.75
strike = dummy 0 or 1 

Debt: When each unit in debt increaes strike increases by 0.0052 units. */
tab debt // unit increase visible

*1.crisis: If there is a crisis there are -1.00 less strike. Only significant at 10% level. P 0.070>0.05 but but significant at 10% level <0.1

/*interaction effect crisis#debt 
If there is a crisis for each unit increase in debt increases strike by 0.0169, holding all other factors constant. This result is significant at the 10% level. 

*/



/*6. Based on your estimated result, predict the value of the strike indicator for a
country, which does not experience a banking crisis and its debt to GDP ratio equals to the sample mean. (Hint: you can do this using the display command).

For a country with no banking crisis (i.e. crisis = 0):
Strike = β0 + β1 crisis + β2 debt + β3 crisis x debt
Strike = β0 + β1 (0) + β2 debt + β3 (0) x debt
we replace crisis with zero because its no crisis time
Strike = β0 + β2 debt // no error term considered=put a hat on the coefficients = estimators
β2 is the marginal effect of debt on strike for a country with no banking
crisis.*/

tab crisis
sum debt
di -0.12+0.005*61.1 // cons
*alternatively, 
reg strike c.debt##i.crisis, r
sum debt
di _b[_cons]+_b[debt]*r(mean)

// .1855 # of strikes in a country with no crisis and its debt to GDP ratio equals to the sample mean. 





/*
7. Predict the value of the strike indicator for a country, which has a banking crisis
and its debt to GDP ratio equal to the sample mean. (Hint: you can do this using
the display command).
For a country with no banking crisis (i.e. crisis = 1):
Strike = β0 + β1 crisis + β2 debt + β3 crisis x debt
Strike = β0 + β1 (1) + β2 debt + β3 (1 x debt)
Strike = β0 + β1 + (β2 + β3) x debt
Intercept = β0 + β1
Slope = β2 + β3
β2 + β3 is the marginal effect of debt on strike for a country experiencing
a banking crisis.
only beta2 and beta3 are influencing our result*/

tab crisis
sum debt
// di _cons+-1.crisis + (1.debt+crisis##debt)*debtmean
// constant+dummycoeff+(coeffdebt+coeffinteraction)*meanof debt
di -0.12-1.01+ (0.005+0.017)*61.1
reg strike c.debt##i.crisis, r
sum debt
di _b[_cons]+_b[1.crisis] +_b[debt]*r(mean)+_b[1.crisis#c.debt]*r(mean)
//constant +b1crisis + b2debt +b3debt*mean of debt+b3intercrisisdebt*mean

// .2142 strikes in a country with a crisis and debt mean. 




/*8. Graphically show how the marginal effect of banking crises (with the 95%
confidence intervals) varies with the levels of public debt.
From Q6, we know that the range of the debt ratio is between 4 and 175.*/
margins, dydx(crisis) at(debt=(0(10)180))
marginsplot




/*9. Re-estimate the model you specified in Question 5 by adding country dummies to
the regression model. (Hint: use the “tab” command; see the slides in lecture 3.)*/

tab country, gen(cty)
tab cty1
sum cty1
reg strike c.debt##i.crisis cty1-cty14, r

/*We omit cty15 in the model to avoid perfect multicollinearity. The
problem arises because cty1 + cty2 + … + cty15 = 1 always. Adding
cty15 to the model does not give us extra information.
(cf. the example of gender: we won’t put both male and female in a
regression model).*/

reg strike c.debt##i.crisis cty1-cty15, r //omits cty15 UK automatically to avoid perfect multicollinearity (=would be a linear combination of the other country variables. E.g. compare cty 5 coeff stays the same). But all variables compare to the reference group = here UK. 




/*10.Test whether Portugal and Spain are equally prone to strike at the 5%
significance level.*/
reg strike c.debt##i.crisis cty1-cty14, r
test cty12=cty13
/*The p-value equals to 0.0522>0.05. We fail to reject the null hypothesis at the
5% significance level and conclude that Portugal and Spain are statistically equally
prone to strike.*/




/*11.Test the null hypothesis that the country effects are jointly significant at the 5% level. Based on the test result, should we include the country dummies in the
final model?*/
test cty1 cty2 cty3 cty4 cty5 cty6 cty7 cty8 cty9 cty10 cty11 cty12 cty13 cty14


//H0: cty1-14=0  Prob > F =    0.0000 < 0.05 alpha and 0.01 alpha -> all effect of countries are jointly significant -> therefore dummy variable should be included!
//H0: null hypothesis is objection that they are jointly insignificant 

/*
The p-value equals to 0.0000. We reject the null hypothesis at the 5%
significance level and conclude that we should include the country
dummies in the model to account for cross-country variations.*/




/*12.Include the variable deficit into the regression model in Question 5. We want to
know whether there is an inverted-U relationship between government deficit and
strikes. Estimate the model that allows us to test this hypothesis and conclude
whether an inverted-U relationship exists between deficit and strikes.*/

//when you square a value you are giving more weight to the highest values

reg strike c.debt##i.crisis c.deficit##c.deficit, r // c.deficit##c.deficit = square same as gen def2=deficit*deficit 

//inverted-U = nonlinear relationship. 
// deficit coeff and c.deficit#c.deficit is the opposit
// def is usually increasing but by giving higher weight to higher values of deficit we see its not anymore increasing. 
// logic not valid as R2 is pretty low and only maybe bc if you run out of money you stop the strike 
// would be inverse negative then positive for non inverted normal ushape

//check the output 
//H0 b of squared term is equal to zero. if P<alpha we reject H0 and keep the term. 


/*The p-value of the coefficient of the quadratic term equals to 0.001,
which is less than 0.05. The coefficient is negative. Therefore, we
conclude that there may be an inverted-U relationship between deficit
and strikes.*/

// both, deficit and def2 are significant at the 0.05 level. 




/*13.Generate a new variable called euro, which is equal to 1 for countries which
adopted the euro as their common currency. */
gen euro=1
replace euro =0 if cty3==1 | cty14==1 | cty15==1
// Denmark, Sweden, UK

/*
14.On average, are the member states of the euro zone more (KEY WORD FOR ONE TAILED TEST) prone to strikes than a
non-member state? Answer the question based on the model you specified in Question 12.*/
reg strike c.debt##i.crisis c.deficit##c.deficit euro, r

/*
Note that this is a one-tailed test, because the alternative hypothesis is
“more prone to strikes” (i.e. βeuro=1 > βeuro≠1)
The coefficient of the variable euro is equal to 0.17, with the p-value
equal to 0.000/2 < 0.05. We reject the null hypothesis at the 5%
significance level and conclude that the member states of the euro zone
are more prone to strike, holding other factors (e.g. deficit, debt and
crisis) constant.
Note that the coefficient tells us only about the average effect (that’s
why the phrase on average in the interpretation). Individual member
state (e.g. Luxemburg) could be less prone to banking crisis than a nonmember state (e.g. UK). The higher average could be due to states like
Greece and Ireland.*/





/*15.Forget about financial crises and deficit and focus only on public debt. Does the effect of public debt on strikes become more pronounced after the Maastricht Treaty, which came into effects in 1993? 

More pronounced after 1992 -> the marginal effect of public debt is larger after 1992 à interaction effect*/

gen maas=year>1992 //creating a dummy variable for all countries after the Maastricht treaty 0= <1992 1=>1992
br maas
by maas, sort: sum debt
reg strike i.maas##c.debt, r

//in interaction term you cannot say its more pronounced - you cannot compare this with years before 1993. you can only say that there are different slopes

// from 1993 onwards there is a -0.7 lower level of strike per year sig at 5
//interaction is most interesting. If treaty=1 for each unit increase in debt strikes will increase at 0.012

/*The coefficient on the interaction term is positive, with the p-value equal
to 0.000. It means that the regression lines before and after the
Maastricht Treaty have different slopes.*/

*homoskedasticity= the variance of the error term is zero*
*heteroscedasticity= when the error changes with the level of x