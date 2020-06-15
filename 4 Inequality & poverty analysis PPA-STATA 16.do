********************************************************************************
********************Public Policy Analysis Assignment 1 ************************
********************"LSMS Ethiopia Panel Analysis" *****************************
********************A Study on the Poverty and Inequalities in Ethiopia: *******
********************Identifying vulnerable groups and policy refinements *******
********************************************************************************

* Topics: Inequality and poverty analysis: Lorenz Curve, GINI, Poverty Headcount Ratio, Pen Parade, Palma ratio		
* Author: Reinhard Rebernig				        
* Data Worldbank LSMS Ethiopia Wave 1-3
* OS: Windows
* Stata Version: 16 
* Revision: 0003 Last change: 15/05/20 by Reinhard Rebernig


******************************************************************************************
*0: Loading files ... 
clear all 

cd ""
capture log close
log using "Logs", replace
use ""

set more off 


*********************************************
**Merging Datasets
*********************************************

use ""
keep household_id2 hh_s1q00 hh_s1q03 hh_s1q04a

***

merge m:m household_id2 using "sect2_hh_w3",keepusing (hh_s2q02 hh_s2q05 hh_s2q11 hh_s2q16) nogenerate

merge m:m household_id2 using "sect3_hh_w3", keepusing(hh_s3q08b) nogenerate

merge m:m household_id2 using "sect7_hh_w3", keepusing(hh_s7q01 hh_s7q03_a hh_s7q03_b) nogenerate

merge m:m household_id2 using "sect13_hh_w3", keepusing(hh_s13q01 hh_s13q0a)

***

use ""

merge m:m household_id2 using "sect1_hh_w3",nogenerate

save ""


*********************************************
*Cleaning data
*********************************************
*1 Deleting the outliers

graph box total_cons_ann
sum total_cons_ann, d
return list
replace total_cons_ann=. if total_cons_ann > (r(p75)+(1.5*(r(p75)-r(p25))))
sum total_cons_ann, d
drop if total_cons_ann < r(p1) | total_cons_ann > r(p99)
graph box total_cons_ann


*2 Renaming variables
rename hh_s1q03 gender
rename hh_s1q04a age
rename hh_s2q02 literacy
rename hh_s2q05 educ
rename saq01 region
rename hh_s13q0a assistance
encode assistance, gen(b)
gen PSNP=0
replace PSNP=1 if b==5


*3 Recoding
gen age_group=.
replace age_group=1 if age<=18
replace age_group=2 if age>18 & age<60
replace age_group=3 if age>=60
replace age_group=. if age==.
lab var age_group "1 if age<18 | 2 if 18>=age<=60 | 3 if age>60"

*4 Creating individual weights
gen iw=pw_w3/hh_size


*********************************************
*Consumption 
*********************************************

*1 Consumption per capita per day

gen pcc=total_cons_ann/hh_size
lab var pcc "Consumption per Capita"

gen pcc_day=pcc/365
lab var pcc_day "Consumption per Capita per Day"


*********************************************
*Absolute Poverty
*********************************************
*1 Absolute poverty line
//Poverty line: 1.90PPP --> PPP=4.92 in 2011

gen pov_line_abs=(1.90*4.92)
gen headcount_abs=.
replace headcount_abs=1 if pcc_day <pov_line_abs
replace headcount_abs=0 if pcc_day>=pov_line_abs
lab var headcount_abs "absolute poverty headcount"
tab headcount_abs
mean headcount_abs [pw=iw]
//27.64% of people live below the absolute poverty line

*2 Absolute poverty gap
gen pov_gap_abs=0
replace pov_gap_abs=pov_line_abs-pcc_day if pcc_day < pov_line_abs
lab var pov_gap_abs "absolute poverty gap"
mean pov_gap_abs [pw=iw]
//Absolute povery gap=0.784


*3 Absolute poverty index
gen pov_gapindex_abs=0
replace pov_gapindex_abs=pov_gap_abs/pov_line_abs if pcc_day < pov_line_abs
lab var pov_gapindex_abs "relative poverty gap index"
mean pov_gapindex_abs [pw=iw]
//Absolute poverty index=0.083


*4 Absolute Poverty severity
gen pov_sev_abs=(pov_gapindex_abs)^2
lab var pov_sev_abs "absolute poverty severity"
mean pov_sev_abs [pw=iw]
//Absolute poverty severity=0.036


*********************************************
*Absolute poverty by strata
*********************************************

//Absolute poverty by strata (not accounting for gender, as Ethiopia is a rather equal country)
*n-strata=n-rural x n-region x n-age_group
*n-strata= 3*11*3 = 99 stratas 
mean headcount_abs [aw=iw]
mean headcount_abs [aw=iw], over(rural age_group)
di 0.46/0.28 // 1.6428571
//On average 27.64% of people in Ethiopia are below the absolute poverty line. In rural areas 46.13% of young people below the age of 18 are below the absolute poverty line. Their rate of being affected by poverty is 64.28% higher in comparison to the national average. 

mean pcc_day [aw=iw]
mean pcc_day [aw=iw], over(rural age_group)
 di 17.39/11.29 //1.5403012
// On average the daily per capita consumption in Ethiopia is 17.39 ETB. In rural areas the daily per capita consumption of young people below the age of 18 is 11.29 ETB. Their consumption is 54.03% below the national average.

*********************************************
*Extreme Poverty
*********************************************

*1 Extreme poverty line
//Extreme poverty line: 1.25PPP --> PPP=4.92 in 2011

gen pov_line_ext=(1.25*4.92)
gen headcount_ext=.
replace headcount_ext=1 if pcc_day <pov_line_ext
replace headcount_ext=0 if pcc_day>=pov_line_ext
lab var headcount_ext "extreme poverty headcount"
tab headcount_ext
mean headcount_ext [pw=iw]
//11.36% of ethiopian people are below the extreme poverty line


*2 Extreme poverty gap
gen pov_gap_ext=0
replace pov_gap_ext=pov_line_ext-pcc_day if pcc_day < pov_line_ext
lab var pov_gap_ext "extreme poverty gap"
mean pov_gap_ext [pw=iw]
//Extreme poverty gap:0.181

*3 Extreme poverty index
gen pov_gapindex_ext=0
replace pov_gapindex_ext=pov_gap_ext/pov_line_ext if pcc_day < pov_line_ext
lab var pov_gapindex_ext "extreme poverty gap index"
mean pov_gapindex_ext [pw=iw]
//Extreme poverty index=0.029


*4 Extreme Poverty severity
gen pov_sev_ext=(pov_gapindex_ext)^2
lab var pov_sev_ext "extreme poverty severity"
mean pov_sev_ext [pw=iw]
//Extreme poverty severity=0.011


*********************************************
*Relative Poverty
********************************************* 
*1 Relative poverty line

*60% of median consumption
sum pcc_day, d
return list
gen pov_line_rel=(0.6*r(p50))
gen headcount_rel=.
replace headcount_rel=1 if pcc_day<pov_line_rel
replace headcount_rel=0 if pcc_day>=pov_line_rel
lab var pov_line_rel "relative poverty line"
lab var headcount_rel "relative headcount"
mean headcount_rel [pw=iw]
//Relative poverty line = 5.99Birr/day/capita
//10.76% of ethiopian people are under the relative poverty line


*2 Relative poverty gap
gen pov_gap_rel=0
replace pov_gap_rel=pov_line_rel-pcc_day if pcc_day < pov_line_rel
lab var pov_gap_rel "relative poverty gap"
mean pov_gap_rel [aw=iw]

*3 Relative poverty index
gen pov_gapindex_rel=0
replace pov_gapindex_rel=pov_gap_rel/pov_line_rel if pcc_day < pov_line_rel
lab var pov_gapindex_rel "relative poverty gap index"
mean pov_gapindex_rel [aw=iw]


*4 Poverty severity
gen pov_sev_rel=(pov_gapindex_rel)^2
lab var pov_sev_rel "relative poverty severity"
mean pov_sev_rel [aw=iw]



*********************************************
*Absolute Poverty by groups with weight
*********************************************

*1 Absolute poverty with weight 

mean headcount_abs [pweight=iw]
//The weighted absolute poverty is 27.64% --> that means that 27.64% of ethiopian people are below the weighted absolute poverty line, they earn less than 1.90$ per day


*2 Absolute poverty with weight by groups

mean headcount_abs, over(region), [pweight=iw]
////Here some results are striking: first the regions of Benshagul Gumuz and SNNP have respectively, 44.94% and 39.76% under the absolute poverty line with a 5% significance level. Second, the region of Addis Ababa (the capital of Ethiopia) only has 2.14% of people under the absolute poverty line, with a 5% significance level. And Diredwa, the second biggest agglomeration of Ethiopa has 6.86% of people under the absolute poverty line. It shows great disparity between the regions. The first two examples being rural areas and the lasts being large towns, we can make the assumption that wealth is more concentrated in cities and poverty strikes the rural areas. 

mean headcount_abs, over(rural), [pweight=iw]
// These results support the previous ones stating that rural areas are more likely to concentrate poor people. In this table we see that 36.32% of ethiopian people in rural areas are below the absolute poverty line, with a 5% significance level. Whereas 6.22% of people in towns (medium to large) are below this line of 1.90$ a day per capita. 

mean headcount_abs, over(gender), [pweight=iw]
//Regarding the proportion of men and women below the absolute pvoerty line, it is unsuprisingly equal. Studies have shown that there are not any gender inequalities in Ethiopia. Therefore, in this table we can see that 29.88% and 27.08% of men and women respectively are below the absolute poverty line. Consequently, we know that the policy recommendation will not focus on one gender in particular because there are not any striking inequalities. 

mean headcount_abs, over(age_group), [pweight=iw]
// The proportion of young people being below the absolute poverty line is bigger than adult and the eldery. In the table we see that 38.65% of ethiopians below the age of 18, earn less then 1.90$ a day. 

mean headcount_abs, over(educ), [pweight=iw]


*********************************************
*Relative Poverty by groups with weight
*********************************************


*1 Relative poverty with weight 

mean headcount_rel [pweight=iw]


*2 Relative poverty with weight by groups

mean headcount_rel, over(region), [pweight=iw]

mean headcount_rel, over(rural), [pweight=iw]

mean headcount_rel, over(gender), [pweight=iw]

mean headcount_rel, over(age_group), [pweight=iw]



*********************************************
*Extreme Poverty by groups with weight
*********************************************

*1 Extreme poverty with weight 

mean headcount_ext [pweight=iw]

*2 Extreme poverty with weight by groups

mean headcount_ext, over(region), [pweight=iw]

mean headcount_ext, over(rural), [pweight=iw]

mean headcount_ext, over(gender), [pweight=iw]

mean headcount_ext, over(age_group), [pweight=iw]


*********************************************
*Correlations
*********************************************


*hh_size seems to have a moderately strong but ambigious correlation with poverty measures 
pwcorr hh_size pcc_day [aw=iw], sig 
// corr -0.4374 p 0.00
pwcorr hh_size headcount_abs [aw=iw], sig 
// 0.36180  p 0.00
pwcorr hh_size headcount_ext [aw=iw], sig 
//  0.2984  p 0.00
pwcorr hh_size headcount_rel [aw=iw], sig 
// 0.2939 p 0.00
pwcorr hh_size hh_s7q01 [aw=iw], sig 
//  -0.0406 p 0.00 //cutting meals past 7 days
pwcorr hh_size literacy [aw=iw], sig 
// 0.0026 p 0.6836
pwcorr hh_size educ [aw=iw], sig 
//-0.3575 p 0.00

pwcorr headcount_abs literacy [aw=iw], sig 
// 0.1427 p 0.00
pwcorr headcount_abs rural [aw=iw], sig 
//-0.2914 with p=0.00
//Used in the paper
pwcorr headcount_abs gender [aw=iw], sig //-0.032 p=0.00
pwcorr headcount_abs region [aw=iw], sig //-0.0610 p0.00
pwcorr headcount_abs age_group [aw=iw], sig
//unclear interpretation 


//Testing if there is a significant difference between rural and urban regions in 
*generating dummy for rural regions
gen rurald=.
replace rurald=1 if rural==1
replace rurald=0 if rural==2
replace rurald=0 if rural==3

pwcorr rurald headcount_abs [aw=iw], sig
// 0.2842 p 0.00
pwcorr rurald literacy [aw=iw], sig
// 0.3396 p 0.00
ttest pcc_day, by(rurald)
//Reject H0 that there is no difference between the mean of urban and rural. 
//We find evidence that the mean of rural is much smaller than the mean of urban (daily per capita consumption) at the 1% significance level. 



*********************************************
*Graphs
*********************************************

//Graphs on poverty
hist total_cons_ann
hist pcc_day

twoway (histogram pcc_day) (kdensity pcc_day), legend (label(1 "Per capita consumption per day [ETB]") label(2 "Density of per capita consumption per day")) legend(size(*0.75)) title("Distribution of the consumption in 2015") 
graph save "Graph" "/"

graph bar (mean) pcc_day [aw=iw], over(region) title("Daily consumption per capita by region") blabel(bar, format(%4.1f)) xsize(12) ytitle("Average daily consumption per capita [ETB]")
graph save "Graph" ""

graph bar (mean) pcc_day [aw=iw], over(rural) title("Daily consumption per capita by areas") blabel(bar, format(%4.1f)) xsize(5) ytitle("Average daily consumption per capita [ETB]")
graph save "Graph" ""


//Graphs on inequalities
*boxplot of pcc_day per area 
graph box pcc_day if pcc_day<50 [pw=iw], title("Per Capita Consumption: Areas") yline(9.348, lcol(black)) yline(6.15, lcol(red)) over(rural) nooutside

graph save "4 Graphs/boxplot pcc_day areas.phg", replace
graph export "4 Graphs/boxplot pcc_day areas.png", replace
//Not used in the paper

*boxplot of pcc_day per area and age group
graph box pcc_day if pcc_day<50 [pw=iw], over(age_group) title("Per Capita Consumption: Areas and Age groups") yline(9.348, lcol(black)) yline(6.15, lcol(red)) over(rural) nooutside

graph save "4 Graphs/boxplot pcc_day age areas.phg", replace
graph export "4 Graphs/boxplot pcc_day age areas.png", replace

*per gender, no difference visible 
graph box pcc_day if pcc_day<50 [pw=iw], over(gender) title("Per Capita Consumption: Areas and Age groups") yline(9.348, lcol(black)) yline(6.15, lcol(red)) over(rural) nooutside

*********************************************
*Summarizing distributions using parametric indices of inequality for annual per capita consumption (pcc)
*********************************************

ineqdeco pcc [aw=iw]
/*
national:
GINI 0.36901
THEIL (GE:1): 0.23011
Mean-log (GE:2):  0.28795
p90/p10:  5.843
*/

mean pcc_day [pw=iw]

*Inequality measures by groups, comparing between group inequality GE=1 Theil index
ineqdeco pcc [aw=iw], by(region) // 0.01714
ineqdeco pcc [aw=iw], by(rural) // 0.05524
ineqdeco pcc [aw=iw], by(age_group) // 0.01785
ineqdeco pcc [aw=iw], by(gender) //  0.00028


*Palma ratio
quietly pshare estimate pcc [pw=iw], percentiles(40 90)
nlcom (Palma: _b[90-100]/_b[0-40])
//Palma ratio 1.558977


*********************************************
*Lorenz curve 
*********************************************

***Relative Lorenz Curve ***
quietly glcurve total_cons_ann, pvar(py) glvar(rly) lorenz // 

sort py
graph twoway (line rly py [pw=iw], yaxis(1 2)) ///
	(function y = x, range(0 1) yaxis(1 2) ), ///
	aspect(1) xtitle("Cumulative population share")  ///
	title("Relative Lorenz Curve: National") ytitle("Lorenz Ordinate", axis(1)) ytitle("Share of national consumption in 2015", axis(2)) legend( label(1 "Distribution of Consumption") label(2 "Line of Equality"))
graph save "4 Graphs\relative_lorenz_curve_national.gph", replace
graph export "4 Graphs\relative_lorenz_curve_national.png", replace


***Generalized_lorenz_curve***

cap drop py //
cap drop gly*
glcurve total_cons_ann, pvar(py) glvar(gly)

sort py
graph twoway (line gly py [pw=iw], yaxis(1 2)) ///
	,aspect(1) xtitle("Cumulative population share") ///
	title("Generalized Lorenz Curve: National")ytitle("Generalized Lorenz Ordinate", axis(1)) ytitle("Scaled Individual consumption [ETB]", axis(2)) ///
    legend(label(1 "")) 
graph save "4 Graphs\generalized_lorenz_curve_national", replace //standardized by the mean population income. 
graph export "4 Graphs\generalized_lorenz_curve_national.png", replace //exports the graph as .png





*********************************************
*Lorenz curve per rural area
*********************************************

glcurve total_cons_ann, by(rural) split pvar(ptca) glvar(rltca) lorenz 

sort ptca
graph twoway (line rltca_1 ptca [pw=iw], yaxis(1 2)) ///
	(line rltca_2 ptca [pw=iw], yaxis(1 2)) ///
	(line rltca_3 ptca [pw=iw], yaxis(1 2)) ///
	(function y = x, range(0 1) yaxis(1 2) ), ///
	aspect(1) xtitle("Cumulative population share") ///
	title("Relative Lorenz Curve: Area") ytitle("Lorenz ordinate", axis(1)) ytitle("Share of national consumption in 2015", axis(2)) legend(label(1 "Rural") label(2 "Small Town") label(3 "Medium and Large Towns")label(4 "Line of Equality")) 
graph save "4 Graphs/relative_lorenz_curve_area", replace
graph export "4 Graphs\relative_lorenz_curve_area.png", replace //exports the graph as .png


*** Generalized Lorenz curves per area

cap drop ptca 
cap drop gltca*
glcurve total_cons_ann, by(rural) split pvar(ptca) glvar(gltca)

sort ptca
graph twoway (line gltca_1 ptca, yaxis(1 2)) ///
	(line gltca_2 ptca, yaxis(1 2)) ///
	(line gltca_3 ptca, yaxis(1 2)) ///
	, title("Generalized Lorenz Curve: Area") aspect(1) xtitle("Cumulative population share") ///
	ytitle("Generalized Lorenz ordinate", axis(1)) ytitle("Scaled individual consumption [ETB]", axis(2)) ///
    legend(label(1 "Rural") label(2 "Small Towns") label(3 "Medium and Large Towns")) 
graph save "4 Graphs/generalized_lorenz_curve_area", replace
graph export "4 Graphs/generalized_lorenz_curve_area.png", replace //exports the graph as .png


*Applying the commands from the lecture 
ssc install fastgini
ssc install lorenz

fastgini total_cons_ann if rural==1 [pw=iw]
fastgini total_cons_ann if rural==2 [pw=iw]
fastgini total_cons_ann if rural==3 [pw=iw]

lorenz total_cons_ann [pw=iw]
lorenz graph
lorenz total_cons_ann [pw=iw], over(rural) total gini
lorenz graph, overlay
//We decided not to include this graph for reasons of oversight, simplicity and coherence. 


*********************************************
*Pen Parade
*********************************************

* Pen Parade per Area for total annual consumption 
bysort rural: cumul total_cons_ann, gen(cdf_cons) 
lab var cdf_cons "Cumulative population annual consumption share" 
sort rural cdf_cons

* Pen Parade for total annual consumption 
graph twoway  /// 
(line total_cons_ann cdf_cons if rural == 1 [pw=iw])  /// 
(line total_cons_ann cdf_cons if rural == 2 [pw=iw])  /// 
(line total_cons_ann cdf_cons if rural == 3 [pw=iw]),  /// 
title("Pen Parade - Annual Consumption: Areas") legend(label(1 "Rural")  /// 
label(2 "Small Town") label(3 "Medium and large town"))

graph save "4 Graphs\penparadetca.phg", replace
graph export "4 Graphs\penparadetca.png", replace


* Pen Parade for per capita consumption per day. 
bysort rural: cumul pcc_day [aw=iw], gen(cdf_pcc_day2) 
lab var cdf_pcc_day2 "Cumulative population daily per capita consumption"
sort rural cdf_pcc_day2

graph twoway  /// 
(line pcc_day cdf_pcc_day2 if rural == 1 [pw=iw])  /// 
(line pcc_day cdf_pcc_day2 if rural == 2 [pw=iw])  /// 
(line pcc_day cdf_pcc_day2 if rural == 3 [pw=iw]),  /// 
yline(9.348, lcol(black))  /// //inserting line for absolute poverty
yline(6.15, lcol(red))  ///  //inserting line for extreme poverty
title("Pen Parade - Consumption per Capita per Day: Area")  /// 
legend(label(1 "Rural") label(2 "Small Town") label(3 "Medium and large town") label(4 "Absolute poverty line") label(5 "Extreme poverty line"))

graph save "4 Graphs\penparadepcc_day2.phg", replace
graph export "4 Graphs\penparadepcc_day2.png", replace

***for lower income levels 50% of population share 
graph twoway  ///
(line pcc_day cdf_pcc_day2 if rural==1 & cdf_pcc_day2<0.5 [pw=iw])  ///
(line pcc_day cdf_pcc_day2 if rural==2 & cdf_pcc_day2<0.5 [pw=iw])  ///
(line pcc_day cdf_pcc_day2 if rural==3 & cdf_pcc_day2<0.5 [pw=iw]),  ///
yline(9.348, lcol(black))  ///
yline(6.15, lcol(red))  ///
title("Pen Parade - Consumption per Capita per Day: Area") legend(label(1 "Rural") label(2 "Small Town") label(3 "Medium and large town"))

graph save "4 Graphs\penparadepcc_daylower2.phg", replace
graph export "4 Graphs\penparadepcc_daylower2.png", replace



****************************************************
*Saving dataset
****************************************************
save "", replace

