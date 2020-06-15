*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Overview*
*******************************************************************************

* Tutorial 1 & 2 & Video lecture 1:		
* Dataset:	sample3.dta	
* Author: Reinhard Rebernig				        
* Tutor: Mario Gonzalez-Sauri / MGS /
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Mail:	Tutor mail: gonzalez@merit.unu.edu
* Revsion:  0001 Last change: 15/05/20 by Reinhard Rebernig


*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Content*
*******************************************************************************

*34 Tutorial 1
*65 Video Lecture 1
*219 Tutorial 2
*392 Lecture 2
*416 Tutorial 3
*467 Video Lecture 2
*739 Tutorial 4


*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Tutorial 1*
*******************************************************************************
*comments 

*asterix  is the first way to add a general comment
help // double-slash is the second way to add a comment in line 
/* slash-asterix is the third way to add comment on several lines
another wonderful comment following up 
until we close the comment again with asterix-slash */
help // to get any help type "help", to get any help about a topic type help+ topic related keyowrd eg. "help keyword" To find out more about any command – like what options it takes – type "help command"
*navigation commands dir & cd

*directory

dir // list of files inside working directory
cd // name of working directory
cd "..." // change working directory to the folder in the path 
import delimited "... .csv" // imports csv file

*descriptives 
browse // opens the data editor and displays data matrix
display cpsc[27] // displays a specific value of an variable 
describe cpsc // displays variable type, format, and any value/variable labels
summarize cpsc // print summary statistics mean, stdev, min, max for variables 
codebook // overview of of all variables, their type, stats and number of missing/unique values

*generating

help generate // find specifics for command - look at the bottom for syntax examples
generate hhremain = hhhage - hheduc //generate a new variable 
*setting up my own 
cd ""
dir //





*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Video Lecture 1*
*******************************************************************************
clear all
cd "~/Desktop"
help capture // capture supresses output 
capture log close // closes log file 

log using "Intro to visualizing with STATA.log", replace
set more off

import excel "IDSS data example.xlsx", sheet("Hoja1") firstrow


** Introduction to graphics and visualization with STATA **

encode Country, gen(country)
drop Country

set scheme s2color

* Simple bar chart

graph bar (mean) HDI, over(country)
graph bar (mean) HDI, over(country) ytitle("Mean Human Development Index 2010-2016")
graph bar (mean) HDI, over(country) asyvars ytitle("Mean Human Development Index 2010-2016") scheme(plotplainblind)

graph bar (mean) HDI, title("HDI for selected countries") over(country) asyvars ytitle("Mean Human Development Index 2010-2016") scheme(plotplainblind)

graph bar (mean) HDI, title("HDI for selected countries") over(country) asyvars ytitle("Mean Human Development Index 2010-2016") scheme(plotplainblind) blabel(bar, format(%4.1f))


* Bar chart by categories
 
graph bar (mean) Expected*, over(country) legend(lab(1 "Female") lab(2 "Male")) ytitle("Mean Expected Years of Schooling")
graph bar (mean) Expected*, over(country) legend(lab(1 "Female") lab(2 "Male")) ytitle("Mean Expected Years of Schooling") scheme(economist)
graph bar (mean) Expected*, over(country) xsize(12) ysize(7) legend(lab(1 "Female") lab(2 "Male")) ytitle("Mean Expected Years of Schooling") scheme(economist)


* Stacked bar chart
graph bar (mean) Expected*, over(country) stack legend(lab(1 "Female") lab(2 "Male")) ytitle("Mean Expected Years of Schooling")
graph bar (mean) Expected*, over(country) stack legend(lab(1 "Female") lab(2 "Male")) ytitle("Mean Expected Years of Schooling") blabel(bar, format(%4.1f))


gen develop = 0
replace develop = 1 if country==2 
replace develop = 1 if country==3 
replace develop =  1 if country==6
replace develop = 2 if country==1
replace develop = 2 if country==4
replace develop = 2 if country==5
replace develop = 2 if country==7
label var develop "Country development category"
label define develop 1 "Developed countries" 2 "Developing countries"
label values develop develop

graph bar Expected*, over(develop) stack legend(lab(1 "Female") lab(2 "Male")) scheme(sj) ytitle("Mean Expected Years of Schooling")
graph bar Expected*, over(develop) stack legend(lab(1 "Female") lab(2 "Male")) scheme(sj) ytitle("Mean Expected Years of Schooling") blabel(bar, format(%4.1f))


* Alternatively...
*ssc install betterbar
*betterbar HDI, n by (country) legend(on) scheme(sj) title("Mean HDI between 2010-2016")

* Histograms

clear all
use "IDSS FeA.dta"

hist age
hist educ

hist age, scheme(economist) title("Distribution of respondent's age")


* Time series plot
clear all
import excel "IDSS data example.xlsx", sheet("Hoja1") firstrow


xtset country Year
graph twoway tsline HDI, by(country)
tsline HDI if country==7
twoway (tsline HDI if country==7, lcol(red) title("HDI for Tanzania"))

tsline HDI if country==7 || tsline HDI if country==6


label var HDI "Human Development Index"
set scheme plotplainblind
#delimit ;
twoway  (tsline HDI if country==7, lcol(blue) lwidth(thick))
		(tsline HDI if country==6, lcol(cranberry) lwidth(thick)),
			legend(pos(3) cols(1) order(
			1 "Tanzania"
			2 "Netherlands"))
			note("Source: UNDP and World Bank")
			xsize(7) ysize(7);
	#delimit cr



* Scatter plots
scatter TotalUnemploymentlabourfor HDI, by(country)
ssc install sepscatter
sepscatter TotalUnemploymentlabourfor HDI, sep(country)
scatter TotalUnemploymentlabourfor GrossNationalIncomeGNIper, by(country)
sepscatter TotalUnemploymentlabourfor GrossNationalIncomeGNIper, sep(country)
sepscatter HDI GrossNationalIncomeGNIper, sep(country)
set scheme plotplainblind
scatter TotalUnemploymentlabourfor HDI if country==3

* Pie charts

graph pie country, over(develop) 
graph pie country, over(develop) pie(1, color(64 0 0)) pie(2, color(192 0 0)) title("Country category of sample countries")
graph pie country, over(develop) pie(1, color(64 0 0)) pie(2, color(192 0 0)) plabel(1 percent) plabel(2 percent) title("Country category of sample countries")
graph pie country, over(develop) pie(1, color(64 0 0)) pie(2, color(192 0 0)) plabel(1 percent) plabel(2 percent) title("Country category of sample countries")
graph pie country, over(develop) pie(1, color(64 0 0) explode) pie(2, color(192 0 0)) plabel(1 percent) plabel(2 percent) title("Country category of sample countries")

clear all
use "FeA.dta"
graph pie educ, over(gmuni)
graph pie educ, over(gmuni) pie(1, color(192 0 0) explode) pie(2, color(126 0 0) explode) pie(3, color(64 0 0)) plabel(1 percent) plabel(2 percent) plabel( 3 percent) title("Educational Attainment by Region in Colombia")



************************
***** APPENDIX *********
************************


** Generating a QR code containing simple text **
txt2qr Welcome to our first video lecture of Introduction Data Science and Statistics! using "IDSS2.png", replace
close log


*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Tutorial 2*
*******************************************************************************
clear all
cd "\tutorial 2" // change working directory
use "group3.dta"

import delimited "sam3.csv" //imports csv file

encode hheduc, generate(hheduc2) // generate encoded categorical variable - from string to long
tostring hhhage, generate(hhhage2) // convertes a variable to a string variable - from byte to str
drop hhhage2 // deletes a variable
help local // unused command 
if 6<10 // unusued command - a logical question

*relational operators* for sub-sample anaylsis
display 6 < 10 //logical test A: 1=true
display 6 > 10 //logical test A: 0=false
display 6 <= 10 // logical test
display 6 >= 10 // logical test

*math operators*
display 6+10
display 6-10
display 6*10
display 6/10
display 6^10
display (2+7) + (8 *4)^2

*logical operators*
display 6 > 3 & 2<8 // true statement, result 1
display 3 > 6 & 2<8 // false statement, result 0
display 6>3 | 2<8 //operator for or
display 6>3 != 2<8 // !=operator for not equal
display 6 != 8
display 6>3==2<8 //operator for equal to
display 7==7

*control flow*
if 7 > 10 {
display "true"
} // if false will just be skipped

***chain of commands following below ***
 if 7 < 10 {
display "true"
display 5^3
} 
* if false will just be skipped
else if 9 !=6 {
display "true"
} 
*else if is part of a chain of commands and not to be used alone 
else {
display 0
}
***chain of commands closed ***
 
*generate a categorical variable from scratch*
gen povertyline  = 0
gen poverty // need to assign a variable 
label // doenst work needs operators
centile toty, centile (25 75) // creates income centiles at the 25% and 7% percent - gives back exact centile value
replace povertyline = 1 if toty <42753 // repplaces 0 with 1 if total income is lower than 25% centile and accordingly 25%-75% =2 and 75%-100% = 3
list povertyline // lists the variable 
replace povertyline = 2 if toty > 42753 & toty < 101104 
replace povertyline = 3 if toty >101104
list povertyline
label variable povertyline "poverty line" // labels the variable 
label define catego 1 "low income" 2 "medium income" 3 "high income"// defines labels for the label "catego"
label values povertyline catego // adresses the povertyline in catego labels

clear all // clears the session
use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\Introductory Data Science and Statistics\TG 8 tutorial 1\tutorial 2\group3.dta"
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\Introductory Data Science and Statistics\TG 8 tutorial 1\tutorial 2"

*exercise 1
/* categorical variables that relate to poverty:
region
gender
education
employment
subsidies 

bar charts and pie charts for categorical data 
*/

generate subsidy = 0
replace subsidy = 1 if y10 > 0
list subsidy

*creating pie charts
graph pie, over (region) plabel (_all percent)
graph export "cat_region_bar.png", replace
graph pie, over (hheduc) plabel (_all percent)
graph export "cat_hhheduc_bar.png", replace
graph pie, over (hhhempl) plabel (_all percent)
graph export "cat_hhempl_bar.png", replace
graph pie, over (subsidy) plabel (_all percent)
graph export "cat_subsidy_bar.png", replace
graph pie, over (hhhsex) plabel (_all percent)
graph export "cat_hhhsex_bar.png", replace // 

*creating bar charts
graph bar, over (region) blabel (_all percent)
graph export "bar_region_bar.png", replace
graph bar, over (hheduc) blabel (_all percent)
graph export "bar_hhheduc_bar.png", replace
graph bar, over (hhhempl) blabel (_all percent)
graph export "bar_hhempl_bar.png", replace
graph bar, over (subsidy) blabel (_all percent)
graph export "bar_subsidy_bar.png", replace
graph bar, over (hhhsex) blabel (_all percent)
graph export "bar_hhhsex_bar.png", replace // 

*plots for numeric variables histogram
/* types of variables: 
plot 5 numeric variables related to poverty
explaining poverty directly but are not poverty itself
poverty is certain level of income
income is already an explanatory variable

**********************************HOMEWORK********************************************
COME UP WITH A LIST OF NUMERIC VARIABLES RELATED TO POVERTY (directly or indirectly)
**************************************************************************************

numercial variables
y1 wage
xf3 meat consumption
xf11 coffee tea consumption
xnf13 jewelry
xnf13 cosmetics
xu2 central heating
xu4 electricity
xf food consumption
xnf non food consumption
xh health expenditure
xe education expenditure
cf food consumption incl eating out
totx total expenditure
totc total consumption
pcc consumption per capita totc/hsize
pccx annual food per cap totx/hsize
pccf annual food per cap cf/hsize

*/

*bar charts for numerical values

graph bar (mean) y1, title("Average wage per region") over(region) asyvars ytitle("[currency unit]") scheme(economist) blabel(bar, format(%4.1f))
graph export "bar_y10wageperregion_bar.png", replace // 
graph bar (mean) xf3, title("Average meat consumption") over(region) asyvars ytitle("[currency unit]") scheme(economist) blabel(bar, format(%4.1f))
graph export "bar_xf3meatperregion_bar.png", replace // 


*creating histograms

hist totx, normal

histogram y1, title("Wage distribution") scheme(economist) xtitle ("Wage [currency]")
graph export "histo_y1wagedistribution_hist.png", replace // 

histogram xf3, title("Average meat consumption") scheme(economist) xtitle ("Expenditure [currency]")
graph export "histo_xf3meat consumption_hist.png", replace // 

*creating boxplots

graph box y1, over (region) nooutside 
graph export "box_y1wagedistribution_box.png"
graph box xf3, over (region) nooutside 
graph export "box_xf3meatexpenditure_box.png"

scatter y1 xf3
corr y1 xf3 // shows the correlation coefficient

scatter toty totx || lfit toty totx/hsize
twoway (scatter toty totx) (lfit toty totx)



*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Lecture 2*
*******************************************************************************

cd "\tutorial 2"
dir
describe
summarize toty
tabulate toty, nolabel
tabulate y1, nolabel
replace y1=. if toty==0 // replacing invalid values (here 0)
scatter toty y1
scatter toty y1, jitter (0) //jitter gives the distribution
summarize toty y1, detail
graph box toty, over (region)
graph box toty, over (region) nooutside scheme(economist) 
corr toty y1 // shows the correlation coefficient
help economist
sum toty if region=="South Rural" // doenst work
graph box y1, over (region) // boxplot over regions with outliers



*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Tutorial 3*
*******************************************************************************

clear all
dir
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2"
use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2\group3_2.dta"
dir




su detail region hhhsex hheduc hhhempl subsidy
su y1 xf3 xnf13 xu4 xf cf 

scatter y1 xf3
corr y1 xf3

scatter pccx pccf, by(region)

label variable pccx "Annual total expenditure per capita (totx/hsize)" // relabeling a variable 

****start here 

summarize toty, detail // in order to get the mean
graph box toty, over (region) nooutside // gives back all boxplots for region
tabulate toty // shows us frequency and cummulative frequency
tabstat toty, by(oblast) statistics (count, mean, median, sd, range iqr) // show the desired variables 
graph box toty, over(oblast) asyvars title(cucardio) xsize(6) ysize(10)
list toty if toty > 1.5*(101075-43150) // homework get all outliers by IQR
su toty, detail 
display toty `r(sd)' // display the sd 
list toty
graph box toty

*replacing outliers left hand and right hand to less and more than three times of the standard deviation
graph box toty
sum toty, d 
replace toty=. if toty > (r(mean) + 3*r(sd)) 
replace toty=. if toty < (r(mean) - 3*r(sd)) 

graph box toty

// this is the rule that stata applies
sum toty, d //
return list //
display r(p75)+1.5*(r(p75)-r(p25)) // uper threshhold
display r(p25)-1.5*(r(p75)-r(p25)) // lower threshhold
replace toty=. if toty>189008.5
replace toty=. if toty<-45635.5

graph box toty, mark(1,mlab(toty))

//
sum xserv, d //
return list //
display (r(p75)-r(p25))*1.5
replace xserv=. if xserv> 5516.25
br xserv
// r always refers to the previous summary

scatter y1 xf3
corr y1 xf3
list toty
graph box toty


********************************************************************************
***** Video Lecture 2:PROBABILITY, DESCRIPTIVE STATISTICS AND SAMPLING ********
********************************************************************************

cd "~/Desktop/Documents/MPP UNU-MERIT/IDSS Video lectures/Video Lecture 2"

*** Let's start with some basic PROBABILITY *** 

* What is the probability that I get heads, if I flip a coin?

ssc install heads
* or findit heads

findit heads

heads,flips(5) 
heads,flips(10)
heads,flips(100)
heads,flips(5000)
heads,flips(6000) 

* We know that the probability is 0.5, but if we throw a coin 10 times, we won't
// get a 0.5 probability using frequency. However, as the number of coin tosses increases
// we approximate to the theoretical p=0.5, and this is an example of what is known as
// THE LAW OF LARGE NUMBERS. 



** Now, let's get some data! **
// STATA has a lot of example datasets, and in this video lecture we will learn
// how to call data from the web either hosted by STATA or another organization
// with open, public data.

webuse auto, clear


* describe will give you a short description of your dataset
// With describe, you can find out what type of variables you have (e.g. string variables)
// the labels of each variable, the total number of observations in your dataset and the 
// total number of variables  
describe 
br make

* codebook will describe the variables that are contained in your data frame (compact is a specification //
* so that it displays only the more crucial information).

codebook, compact
codebook

** Now, let's get some descriptive statistics of a single variable using the summary command **

sum price
sum

* To get more information about the variable of interest, specify detail in the code!
* It will display a larger set of descriptives in your output

sum price, detail
sum price, d

// let's see how a normal distribution looks like
#delimit ;
twoway 
  function y=normalden(x), range(-4 -1.96) bcolor(gs12) recast(area) || 
  function y=normalden(x), range(1.96 4) bcolor(gs12) recast(area) ||
  function y=normalden(x), range(-4 4) clstyle(foreground) ||, 
  plotregion(style(none))
  yscale(off) xscale(noline)
  legend(off)
  xlabel(-4 "-4 sd" -3 "-3 sd" -2 "-2 sd" -1 "-1 sd" 0 "mean" 
  1 "1 sd"   2 "2 sd"   3 "3 sd"   4 "4 sd", grid gmin gmax)
  xtitle("Standardized Normal Distribution")
  ;
#delimit cr

* let's see the distribution of car prices
hist price
hist price, normal // is it normally distributed?
 

// while the average (mean) price of a car is of 6165.2, we can see that most cars cost below 5000
// the mean is pulled by the few cars that cost a lot more

* now, let's visualize the cost of cars by how many miles they can go, per gallon of gas

gen symbol = "🚗"
scatter price mpg, mlabel(symbol) mlabposition(0) msymbol(i) scheme(s2mono)

twoway (scatter price mpg,mlabel(symbol) mlabposition(0) msymbol(i) scheme(s2mono)) (lfit price mpg)
// fitted line

** With our scatterplot, we assume that the price  of a car is correlated to it's mileage
// let's get the covariance of these two variables: remember, a negative correlation coefficient
// implies a negative slope in your scatterplot!

corr price mpg

// corr stands for correlation and it displays the correlation matrix of our selected variables
// To see a covariance matrix, we're simply adding a covariance specification to our command 

corr price mpg, covariance

 // covariance and correlation both tell us the direction of a linear relationship b/w two variables
 // cov and corr are similar to each other, but in a covariance matrix the data are not standardized
 // because it is standardized (from -1 to 1), a correlation allows you to also assess the strength of the
// relationship.

* AN ADVANCED BONUS: 
pwcorr price mpg, sig
// pwcorr stands for pairwise correlation, and the sig specification stands for statistical significance

** What about some probabilities? Let's look at the probability of of a car being foreign made

tab foreign

// how about being foreign and costing above 6000 USD?
//I want to know how many foreign and domestic car cost more than the mean

gen six=.
replace six=1 if price>=6000
replace six=0 if price<6000

tab foreign six
display 9/74

tab foreign six, cell nofreq

** LOOKING FOR OUTLIERS  **

graph box price

// box plots are a display of distribution, they allow us to visually observe for outliers in our data
 

sum price, d  // sum is short for summary, and the d is short for detail
return list //return list is a command that temporarily stores values from the previous calculations,
// in this case, it will allow us to not only store the values, but use those stored values to calculate
// outliers

di (r(p75)-r(p25)) // Inter Quartile Range
di 1.5*(r(p75)-r(p25)) // Calculating the threshold 
di r(p75)+(1.5*(r(p75)-r(p25))) // upper threshold
di r(p25)-(1.5*(r(p75)-r(p25))) // lower threshold

*So how can i know which observations in my box plot are outliers?
list price if price > 9562.5 // list of prices if the price is above the upper threshold

list price if price < 974.5 // list of prices if the price is below the lower threshold


* you can also get these values with...
tabstat price, statistics(iqr, p25, p75)

graph box price, mark(1, mlabel(price))
*graph box price, mark(1, mlabel(symbol) msymbol(i) mlabposition(0))

graph box price, mark(1, mlabel(symbol) msymbol(i) mlabposition(0))


********************************************************************************
*****                 EXCERCISE FOR YOU TO TRY AT HOME                  ********
********************************************************************************

*1. Obtain the summary statistics of the variable mpg (mileage/miles per gallon)

sum mpg, detail

*1.1 What does the standard deviation mean?
return list //r(sd) 5.785503 - the distance of each single value to the mean

*2. What does it mean that price is in the x axis, and mileage in the y axis?
// hint: in a scatterplot, we normally have the dependent variable in the vertical axis
// and the independent on the horizontal axis.

*y = vertical = dependent = milage // something that reacts in the experiment 
*x = horizontal = independent = price // something that I control in the experiment

*this means that the milage depends on the price of the car and this doesnt make any sense at all.  

scatter mpg price
// wrong 
scatter price mpg 
// right 

*3. Obtain the correlation between price and weight: what does the coefficient mean?

scatter price weight
corr price weight
***corr = 0.5386 slightly positive means that about half the change in weight translates into a change in price
 
*4. Calculate the probability that, if I pick a car at random from our sample
// it will be either domestic made OR cost less that 6000 USD?

sum foreign, d
tab foreign six
tab foreign six, cell nofreq
* 52/74 domestic cars and 22/54 foreign cars
*count if foreign="Domestic"
*count foreign

sum price, d 
list price if price < 6000
count if price < 6000
*51 cars cost less than 6000 USD

**** Probability
*P(A or B)=P(A)+P(B)-P(A&B)
*P(A&B)=P(A)*P(B given A)
*P(B given A)= P(A&B) /P(A)? // have to understand how many are both! 

tab foreign six, cell nofreq
display 52/74 + 51/74 - 38/74 //right 
*0.87837838


*** Sampling ***

sample 35,count  // drawing a random sample of  35 observations (_N - 35)
des // describes data
clear all // retrieving original dataset
webuse auto
sample 35  // drawing a random sample that represents 35% of your data (100-#)%
des
sample 35, by(foreign) // as above but 35% for each category
help sample



** Would you like to calculate the growth rate of any given variable of country X? 
* The World Bank has open datasets that you can directly access from STATA
clear all
ssc install wbopendata

wbopendata, country(usa) indicator(NY.GDP.PCAP.CD) year(2008:2018) clear 
br

/// GDP per capita in the USA for the years 2008-2012
browse

generate pc_growth = ((yr2012 - yr2008)/yr2008) * 100
display pc_growth

// GDP per capita in the USA for the years 2008-2018
gen pc_growth2 = ((yr2018 - yr2008)/yr2008) * 100
display pc_growth2

*or

display ((62641.02-48382.56)/48382.56)*100


*** 29% growth of per capita GDP between the years 08-18

********************************************************************************
*****                 EXCERCISE FOR YOU TO TRY AT HOME                  ********
********************************************************************************

* 5. Calculate the per capita economic growth of th Netherlands for the years 2008-2018

wbopendata, country(nl) indicator(NY.GDP.PCAP.CD) year(2008:2018) clear

gen pc_growth2 = ((yr2018 - yr2008)/yr2008) * 100
display pc_growth2
* = -8.0945187





********************************************************************************
*****	Tutorial 4 	********
********************************************************************************

dir
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2"
use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2\group3_2.dta"
dir
br

display (0.61)^10*100
display (0.61)^9*(0.39)^1*100

display (0.61^9*0.39^1)*10
display (0.61^9*0.39^1)*

sample 10, count

list hhhage
sum hhhage, d
return list

*1. Calculate mean of hhhage
sum hhhage, d
return list
*2. Calculate zscore of mean with mean and sd from entire survey
display ((r(mean)-51.65)/14.29)
*-.18194542

help ztable 


*4.3. 

sum hhhage, d
display (r(mean)-51.65)/14.29

ztable

*4.3.1. Z>Zj = 0.57218722
display 1-normal(-.18194542)
// same as z table + 0.5

*4.3.2. Z<Zj = .42781278
display normal(-.18194542)

4.3.3. 0<Z<Zj = .07218722
display 0.5-normal(-.18194542)



****by fillipo***
*1*
* calculate probability of 10 out of 10 observations are from an urban area *
display (0.61)^10

* calculate probability of 9 out of 10 observations are from an urban area and the last 1 is from a rural area *
display (0.61)^9*(0.39)^1

* calculate probability that exactly 1 ou of the 10 draws is from a rural area, and 9 from an urban area *
display (exp(lnfactorial(10)))/(exp(lnfactorial(1))*(exp(lnfactorial(9)))) // calculate number of possible combinations = 10
display ((0.61)^9*(0.39)^1)*10

*2*
* calculate probability that in 10 draws, 2 are from a rural area and 8 are from an urban area *
display (exp(lnfactorial(10)))/(exp(lnfactorial(2))*(exp(lnfactorial(8)))) // calculate number of possible combinations = 45
display ((0.61)^8*(0.39)^2)*45



*3*
* calculate mean of hhhage and Z-score of that value *
summarize hhhage, detail
return list

display (45.15-51.65)/14.29
// Z1=-0.455 for group1

* calculate probabilities Z>Z1, Z<Z1, 0<Z<Z1 assuming normally distributed probabilities *
help ztable
ztable

display 0.5+0.1736
// probability Z>Z1 = 0.6736

display 0.5-0.1736
// probability Z<Z1 = 0.3264

display 0.1736
// probability 0<Z<Z1 = 0.1736

*4*
// The most biased sample is the one with the Z farthest from 0. For all 3 groups, the bias has negative direction



********************************************************************************
***** Video Lecture 3: POPULATIONS, SAMPLES, & CONFIDENCE INTERVALS ********
********************************************************************************

*** Define your working directory

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\lecture 4"

*** upload the data you will be working with
webuse cattaneo2, clear
describe //describe data set

*** Standardizing variables ***
*1. Let's standardize the values of the the age of the mother
codebook mage
sum mage, d
egen stmage=std(mage) // egen allows you to generate new variables using complex functions
// For more on gen, egen and replace go to: http://wlm.userweb.mwn.de/Stata/wstatgen.htm
br stmage

* Alternatively 
findit zscore
zscore mage

br mage stmage z_mage


sum stmage, d

//After we standardized, we can see in the summary statistics
//that the mean is approximately 0 ((0.00000000318)) and the standard deviation is 1.

** HOMEWORK: Why do we standardize the values? What can we learn from std. values?


*2. Normal distribution: does mother's age follow a normal distribution?

hist mage, norm 


*To download a ttable or ztable on stata use:
 findit probtabl
*Click on the link to install
*The commands to display the t or z table to find critical values: 
 ttable
 ztable

**** Now let's look at our zscore (in a normal distribution)
display normal(-0.0897)
display normprob(-0.0897)
//returns the cumulative probability associated with a value from the 
//standard normal distribution 
// we would like to find the area under the standard normal distribution’s
// probability density function less than or equal to a value of -0.0897
// OR the proportion of the area under the normal curve that lies below z = -0.0897

display 1-normal(-0.0897) 
display 1-normprob(-0.0897)
// what lies above the zscore


di invnormal(0.95)
//returns the inverse cdf value based on the standard normal distribution
//here we are interested in finding the 95th percentile of a standard normal distribution
// OR how many standard deviations above the mean we need to be in order to lie in the 95th percentile of the normal curve


* let's do a normal probability plot

qnorm mage, ylabel(13(26)45) xlabel(13(26)45) ///
scheme(s1color) ytitle("Age of mother")              ///
yscale(titlegap(4)) xscale(titlegap(4))

//qnorm places the observed variable, mother's age, on the vertical axis instead of the horizontal axis
//it plots quantiles of mother's age against quantiles of normal distribution

codebook mbsmoke

findit qplot

qplot mage, trscale(invnormal(@)) over(mbsmoke) aspect(1) ///
xtitle(standard normal dev) legend(col(1) order(2 1) pos(11) ring(0))

// qplot produces a plot of the ordered values of one or more variables 
// against the so-called plotting positions, which are essentially quantiles of a
// uniform distribution on [0,1] for the same number of values
// To show probabilities on an inverse normal scale, specify trscale(invnormal(@))


// In probability plots: 1. A (perfect) sample from a normal distribution falls exactly on a straight line.
// Curvature may be suggestive of the need for transformation. 

**** CONFIDENCE INTERVALS ***
*3. Confidence intervals

ci means mage 

ci means mage, level(99)

codebook mbsmoke
ci means mage if mbsmoke==1
ci means mage if mbsmoke==0


*cii n mean sd, level(95) // for when you are working with descriptive statistics not in varlist

** HOMEWORK: 
* Interpret the confidence intervals!
// hint: I am  95% confident that...

* Problem. X is distributed normally, n = 9, mean = 4, variance = 9. Construct a 99% c.i. for the mean of
//the parent population.
ttable

* CI in graphs
findit ciplot

ciplot mage
ciplot mage, by(mbsmoke)

drop pregnant
gen pregnant="👩🚬"
ciplot mage, by(mbsmoke) mlabel(pregnant) mlabposition(0) msymbol(i) xtitle("Smoking behaviour of subject")




********************************************************************************
***** Tutorial 6: Hypothesis Testing ********
********************************************************************************

clear all 

dir
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2"
use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2\group3.dta"
dir
br


*4.3. 

*3*
* calculate mean of hhhage and Z-score of that value *
summarize hhhage, detail
return list

display (r(mean)-51.65)/14.29
// Z1=-0.455 for group1

* calculate probabilities Z>Z1, Z<Z1, 0<Z<Z1 assuming normally distributed probabilities *
help ztable
ztable

*4.3.1 
display 1-normal(-0.18194542)

*4.3.2.
display normal(-0.18194542)

*4.3.3. 
cisplay 0.5-normal(-0.18194542)


***calculating standard error from hhhage
sum hhhage, d
return list
*calculate standard error
di (r(sd)/10) //divided by the square root of 100
*** 1.2687682

***t value
ttable // 100df 95% t=1.984

*** CI (95%)
*** CI=r(mean)+-(1.984*12687682)
display r(mean)+(1.984*1.2687682)
display r(mean)-(1.984*1.2687682)
*** with a confidence level of 95% we can state that the true value of the population mew lies between the vaules 46.532764 (lower boundary) and 51.567236

ci means hhhage 

*********************************
generate foodshares=

help egen // homework - look it up // functions to generate values 

drop food_share

*5.1. creating categories

egen food_share=rowtotal(xf1 - xf13)
egen health_share=rowtotal(xh1- xh3)
egen housing_share=rowtotal(xu1-xu9)
egen tempt_share=rowtotal(xf14-xf15)

replace food_share=food_share/totx
replace health_share=health_share/totx
replace housing_share=housing_share/totx
replace tempt_share=tempt_share/totx

br

gen xfoods=food_share/totx
gen xhealths=health_share/totx
gen xhouses=housing_share/totx
gen xtempts=tempt_share/totx

ci means x*s

ci means x*s, level(99)

sum food_share, d
return list
display r(sd)/10

ttable

display r(mean)+(1.984*3.365e-07)
display r(mean)-(1.984*3.365e-07)

ci means food_share health_share housing_share tempt_share

ci means food_share health_share housing_share tempt_share, level (90), 

ci means food_share health_share housing_share tempt_share, level (99), 

/***homework 
z-score (normal distribution), 
t-score (t-student distribution) - 
When to use what?
For which cases??? */ 





*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Video Lecture 4*
*******************************************************************************


clear all
cd "~/Desktop/Documents/MPP UNU-MERIT/IDSS Video Lectures/Video Lecture 4"
set more off
import excel "~/Desktop/Documents/MPP UNU-MERIT/IDSS Video Lectures/Video Lecture 4/Political survey Great Britain.xlsx", sheet("Hoja1") firstrow

*********my opening***********
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\lecture 5"
dir
import excel "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\lecture 5\Political survey Great Britain.xlsx", sheet("Hoja1") firstrow
br

clear all 
set more off
ttable



**** CI of Proportions ****

* You have survey data of Great Britain from the year 2011 about the population's interest in politics*
* Let's find out how many people find the topic of politics complicated*
describe
tab complicated_politics

* 72.4% of my sample find politics complicated. Is this a reflection of the population in
* Great Britain? Let's find out with a confidence interval.

cii proportions 3901 2826, exact // [cii proportions n successes, exact]

* 90% confidence interval
cii proportions 3901 2826, exact level (99)



// I am 95% confident that the true proportion of the GB that find politics complicated
// is between 71 and 73%

* Alternatively
proportion complicated_politics
encode complicated_politics, g(complicated_pol)

proportion complicated_pol
br complicated_politcis complicated_pol

//The proportion command calculates the proportions of all the categories in my binary (or categorical)
// variable of interest and estimates confidence intervals automatically

** CIs of proportions by subgroups // ARE POLITICS FUN? A GENDERED PERSPECTIVE
br gender gender2
encode gender, g(gender2)

codebook gender2
drop if gender2 == 1

encode politics_fun, g(fun_politics)
proportion fun_politics
proportion fun_politics, over(gender2)

/* HOMEWORK: INTERPRET CONFIDENCE INTERVALS OF THESE PROPORTIONS */

describe //cntry, eduyrs
encode cntry, g(cntry_code)
br cntry_code
proportion fun_politics, over(cntry_code)
encode eduyrs, g(eduyrs_code)
br eduyrs eduyrs_code
proportion fun_politics, over(eduyrs_code)
br

****valuable below ******
tabstat eduyrs_code
tab cntry_code, sum(eduyrs_code)


**** Hypothesis Testing ***

clear all

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\lecture 5\pizza.dta"
br

* Popular TV shows from the US, televised in my homecountry, have lead me to believe US Americans
* spend a lot of money on pizza anually. The pizza chain, Domino's, released data saying that, on
* average, a regular costumer spends 200 USD a year in their store. 

ttest pizza = 200
ttable
//Ho: mean annual pizza expenditure in the US is 200 USD
//Ha: mean anual pizza expenditure in the US is not 200 USD

// I fail to reject the null hypothesis (p of Ha > 0.05)

* HOMEWORK: INTERPRET THE 1 TAILED ALTERNATIVE HYPOTHESIS *

** Now you want to observe the difference in pizza consumption between genders:
* HOMEWORK: What is your null, and what is your alternative in this scenario?

*H0=there is no difference
*Ha=there is a differnce 

ttest pizza, by(female)

// I can reject the null hypothesis that the difference in mean pizza expenditures between
// men and women is zero (or that there is no difference) with Ha: diff != 0 at p<0.05


graph box pizza, by(female) // let's visualize this difference!


* HOMEWORK: What is your null, and what is your alternative in this scenario?

** Hypothesis Tests for 1 and 2 proportions **

clear all
import excel "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\lecture 5\Political survey Great Britain.xlsx", sheet("Hoja1") firstrow

*The government of Great Britain claims that 80% of their population have completed 
*secondary education (or at least 12 years of schooling). We want to find out the
* accuracy of this claim   
destring eduyrs, g(educ_years)

count if educ_years > 12 // number of people in the sample who have completed 12 years of education

prtesti 3870 2132 .8, count level(99) // prtesti n #successes proportion to compareitto

** HOMEWORK CAN YOU REJECT THE NULL? 
*H0 reject
*Ha accept

* Two Sample proportions
des
encode politics_fun, g(fun_politics)
encode gender, g(gender2)
drop if gender2==1
drop if fun_politics==.
tab fun_politics
codebook fun_politics

replace fun_politics=0 if fun_politics==2
replace fun_politics=1 if fun_politics==1

replace gender2=0 if gender2==3
replace gender2=1 if gender2==2
label drop gender2
label define gender2 0 "Male" 1 "Female"
label values gender2 gender2

** do men and women have the same proportions of considering politics a fun topic?


prtest fun_politics, by(gender2)

// we can reject the null hypothesis
// accept Ha



****TUTORIAL 6*****

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2"
dir

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\TG 8 tutorial 1\tutorial 2\group3_2"
br

***t-table





***6.1.


*t-score standard distribution of the sample
*z-score standard distribution of the population

help egen // homework - look it up // functions to generate values 

drop food_share
egen totalexpenditure 
egen food_share=rowtotal(xf1 - xf13)
egen health_share=rowtotal(xh1- xh3)
egen housing_share=rowtotal(xu1-xu9)
egen tempt_share=rowtotal(xf13-xf15)

replace food_share=food_share/totx
replace health_share=health_share/totx
replace housing_share=housing_share/totx
replace tempt_share=tempt_share/totx

br

sum food_share, d
return list
display r(sd)/10

sum food_share, d
return list
display r(sd)/10

ttable

display r(mean)+(1.984*3.365e-07)
display r(mean)-(1.984*3.365e-07)

ci means food_share health_share housing_share tempt_share

ci means food_share health_share housing_share tempt_share, level (90), 

ci means food_share health_share housing_share tempt_share, level (99), 


*6.2. 
*H01 = share of spending on food is equal to the share of spending on health 
*Ha1= negation of H0 means that I find evidence for Ha
ttest food_share=health_share // for numerical

/*
1. way two sided test Pr(|T|>|t|)=0.0000 < 0.05
2. H0 compare with diff conf intervall, if not included then fail to accept (=reject) H0
3. if |t|>3 then fail to accept (=reject) H0 (bc. t is measured in standard deviations - so everything that is >3 standard deviations is an outlier)
I can reject the H0 and accept the Ha
*/


/*How to manually calculate the t-score 
t=meanfood_share-meanhousing_share/(sdfood_share/squareroot n)
display 5.28e-06- 
*/

sum food_share, d 
display (r(mean))-.0108341)/(r(sd)/sqrt(100))



*H02
ttest food_share=housing_share

*H03
ttest health_share=housing_share

*H04 
ttest health_share=tempt_share
prtest food_share=housing_share // only for categorical!!!

*6.3. 
count if xu4>2000
*51

hist xu4, normal

*6.4. 
gen ln_xu4=ln(xu4)

hist ln_xu4, frequency normal
hist ln_xu4, normal
hist ln_xu4

sum xu4, d
return list

sum ln_xu4, d 
return list



*6.5. 

tab ln_xu4, sort
tab ln_xu4 if ln_xu4>6

z-score = (value-mean)/standard deviation

sum ln_xu4, d
return list
display (6-r(mean))/r(sd)
// -3.1063034

display 1-normal(-3.1063034)
// .99905279

*or try this 

di invnormal(0.05)
sum ln_xu4, d
return list
di (-1.6448536*r(sd))+r(mean)
*=6.7770218
di exp(6.7770218)
*=877.4516

sum xu4, d
return list


*6.6. 
sum ln_xu4, d
return list
ztable 
display (X???)-r(mean))/r(sd) // z-score

display (-1.65*0.53)+7.65

display normprob(-1.65)

ztable

****
sum toty, d
return list 
gen povertyline=. 
replace povertyline=1 if toty<r(p25)
replace povertyline=2 if toty>r(p25) & toty<r(p75)
replace povertyline=3 if toty>r(p75)





*******************************************************************************
******** INTRODUCTION TO DATA SCIENCE AND STATISTICS **************************
						*Tutorial 7*
*******************************************************************************
clear all
cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\exam bsp1" // change working directory

use "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\IDSS\exam bsp1\IDSS_data.dta"

dir
des

generate ypc=toty/hsize //y per cap
replace ypc=ypc/365 // y per cap and day
replace ypc=ypc/69.82 // conversion in USD

hist ypc, normal 

histogram ypc, title("Income per capita and day") scheme(economist) xtitle ("Income per capita and day [USD]") normal
graph export "histo_ypc_hist.png", replace //

*creating the poverty line
sum ypc, d 
return list
generate povline=.
replace povline=1 if ypc<1.90

*creating povertyline classes - uncessesary 
generate povlineclass=.
replace povlineclass=1 if ypc<r(p25)
replace povlineclass=2 if ypc>r(p25) & ypc<r(p75)
replace povlineclass=3 if ypc>r(p75)
br toty ypc povline povlineclass

//alternatively PPP from world bank data 
drop ypc2
drop povline2
generate ypcPPP=toty/hsize //y per cap
replace ypcPPP=ypcPPP/365 // y per cap and day
replace ypcPPP=ypcPPP/20.92 // conversion in PPP
count if ypcPPP<1.9

sum ypcPPP

hist ypcPPP, normal
count if ypcPPP<1.9

gen lnypcPPP=ln(ypcPPP)
hist lnypcPPP, normal

histogram ypcPPP, title("Income per capita and day") scheme(economist) xtitle ("Income per capita and day [USD]") normal
graph export "histo_ypc_hist.png", replace //

sum ypc2, d 
return list
generate povline2=.
replace povline2=1 if ypc2<1.90




*7.2. Hypothesis that there is no poverty in Kyrgystan 

*look up t-score 
sum ypcPPP, d
ttable //looking up the probability 100 df 

*two tailed 1.984
*one tailed 1.660

*standard error
sum ypcPPP, d 
return list
display = r(sd)/sqrt(100)
// standard error= 1.195485394883759

/*t value for USD povertyline
t value=sample value 1.984-r(mean) of sample/
*tvalue */
display (1.984-r(mean))/0.03582004
*40.363798

*t value for PPP povertyline
sum ypc2, d
return list
display r(sd)/sqrt(100)
display (1.984-r(mean))/.11954854
*1.5715791
display (1.984-r(mean))/(r(sd)/sqrt(100))
*1.5715791

ttest ypcPPP=1.9 //same threshhold 1.9USD in PPP for povertyline 
ttest ypcPPP==1.9


*****removing outliers
sum ypcPPP, d
return list
count if ypcPPP>(r(p75)+((r(p75)-r(p25))*1.5))
replace ypcPPP=. if ypcPPP>(r(p75)+((r(p75)-r(p25))*1.5))

ttest ypcPPP=1.9

graph box ypcPPP 
/* Reverse probability



Ho: mean = 1.9
Ha: mean < 1.9
Pr(T < t) = 0.1935 
The probability that persons are earning less than 1.9 is p=0.19.
very small p - evidence that the true mean is smaller than 

Ha: mean != 1.9 
Pr(|T| > |t|) = 0.3870
The probability that persons are earning 1.9 is p=0.3870.

Pr(T > t) = 0.8065 > 0.05 fail to reject H0 (=accept it)
The probability that persons are earning 1.9 is p=0.8065.

H0: fail to reject in all tests (accept)

*/

*7.3. use ypcPPP to understand the difference between two oblasts

by oblast, sort: sum ypcPPP
codebook oblast // choose chui
summarize ypcPPP if oblast == 41708 //choose the man of oblast chui= 3.362199
ttest ypcPPP if oblast==41704 = 3.362199 // compare the two means of narnia with chui 

bysort region: ttest ypcPPP==1.9

*Interpretation
/*
Then, you look for the p-value of the two sided test. It the p-value is smaller than .05 you reject the null, H0: mean poverty in CHIU is equal to the mean poverty in Naryn. Hence, there are statistically different levels of poverty in the two regions. Conversely, p-value is greater than .05, you fail to reject, and you do not find statistically different levels of poverty between regions.
*/


codebook oblast

tab ypcPPP=1.9 if oblast==41706
  

ttest ypcPPP, by(region2) // two sample ttest
ttest ypc2==region2 //wrong bc invalid comparison

codebook region
gen region2=.
replace region2=1 if region==1
replace region2=1 if region==3
replace region2=2 if region==2
replace region2=2 if region==4

label var region2 "region in kyrgyztan"
label define region2 1 "North Urban" 2 "South Rural"
label values region2 region2

by oblast, sort: sum ypcPPP, d

graph box ypc2, over(region2), addline(1.9)

ttest ypcPPP, by(region2)
ttest ypcPPP, by(oblast)


ttest ypcPPP=1.9
