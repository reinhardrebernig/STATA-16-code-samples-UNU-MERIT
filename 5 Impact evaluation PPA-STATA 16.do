***************************************************************
***************IMPACT EVALUATION UCT IN MADAGASCAR*************
***************************************************************

* Public Policy Analysis: Written Assignment
* MPPHD 2019-20 UNU-MERIT

* Do-file is based on the material from: Khandker, S. R., Koolwal, G. B., & Samad, H. A. (2010) & Modifications of PPA-Tutor Team (UNU-MERIT 2019) 
* Topics: Propensity Score Matching, Impact Evaluation, Average Treatment Effect ATE / ATT
* Stata 16.0
* Do-file prepared by:
* Reinhard Rebernig, i6223139,
* r.rebernig@student.maastrichtuniversity.nl
* Last edit: 23.12.2019
***************************************************************

***************************************************************
* Impact evaluation of an unconditional cash transfer program to improve health and educational outcomes for school-aged girls in Madagascar
* Limitations: Randomization went wrong & years unknown. 
* Solution: Comparison in means to understand average treatment effect on treatment group (ATT) & Average Treatment Effect (ATE) after propensity score matching (PSM). 
***************************************************************

***************************************************************
* 0. Setting working directory, creating log file, loading the data
***************************************************************

cd "C:\Users\Reinhard Rebernig\Documents\Uni\UNU MERIT\Courses\Sem1\PPA\impact eval"
capture log close
log using "5 Logs\impacteval.log", replace
use "1 Input\ppa_ass2_data"


***************************************************************
* 1. Understanding the data I: Descriptive statistics
***************************************************************

*Setting the seed for the whole analysis once
set seed 12345

* Basic descriptive statistics
count // 3487 observations
describe // 16 variables, 
codebook, compact // 7 binary vars, 5 continous vars
summarize
*no missing observations. 

/*1.3. Overview (16) variables

Baseline variables at t:
Proxy-means testing for poverty: asset_index_baseline (see adjustment in section 3)
Categorical targeting: hhsize_baseline, age_baseline
Other observed variables: father_alive_baseline (binary), mother_alive_baseline (binary), female_headed_baseline (binary), urban_baseline (binary), highest_grade_baseline

Variables at t+1: 
Outcome variables:
Educational outcomes frac_attend, cog_std 
Health outcomes: pregnant (binary), married (binary)
Unconditional cash transfer amount monthly: uct_total_amount
Income: income
Observation enumerator: unit */





***************************************************************
* 2. Understanding the data II: Analysis
***************************************************************

*2.1. Generating dummies for analysis. 

*Generating a treatment dummy
gen uct=.
replace uct=1 if uct_total_amount>0
replace uct=0 if uct_total_amount==0 
lab var uct "Unconditional cash transfer program"
lab define uct01 0"Not-treated group" 1"Treated group"
lab values uct uct01
tab uct // 484 treated obs., 3003 unmachted control obs. in the sample 

*generating a dummy for educational system level
gen educ_level_baseline=.
replace educ_level_baseline=1 if highest_grade_baseline<=5
replace educ_level_baseline=2 if highest_grade_baseline>5 & highest_grade_baseline<=9
replace educ_level_baseline=3 if highest_grade_baseline>9
lab var educ_level_baseline "Educational level"
lab define educationallevel 1"Primary 6-11 years" 2"Junior secondary 12-15 years" 3"Senior secondary 16-18 years" 
lab values educ_level_baseline educationallevel
tab educ_level_baseline uct
*primary 5 years, ages 6-11 //502 Obs, 35 treated, 467 not treated
*junior secondary 4 years, ages 12-15 //2519 obs., 399 treated, 2120 not treated
*senior secondary 3 years, ages 16-18 //466 obs., 50 treated, 416 not treated. 

*Generating a dummy, indicating if educational level does not match the age of the individual.
graph box age_baseline, over(highest_grade_baseline) title("Distribution of baseline ages and school grades") b1title("Highest school grade at baseline") // the unqual distribution of age 
graph save "4 Graphs/unequalbox1.gph", replace
generate unequal=0 
replace unequal=1 if age_baseline==13 & highest_grade_baseline<7
replace unequal=1 if age_baseline==14 & highest_grade_baseline<8
replace unequal=1 if age_baseline==15 & highest_grade_baseline<9
replace unequal=1 if age_baseline==16 & highest_grade_baseline<10
replace unequal=1 if age_baseline==17 & highest_grade_baseline<11
replace unequal=1 if age_baseline>=18 & highest_grade_baseline<12
lab var unequal "Unequal age and educational level group"
tab uct unequal
*INSERT NOTE

*Generating cumpulsory school dummy 
gen cumpul_school_baseline=. 
replace cumpul_school_baseline=1 if educ_level_baseline==1 | educ_level_baseline==2 
replace cumpul_school_baseline=0 if educ_level_baseline==3
lab var cumpul_school_baseline "Cumpulsory school"
lab define cumpul01 0"Compulsory: 9 years" 1"Non-compulsory: 3 years"
label variable cumpul_school_baseline cumpul01

*Generating orphan dummy variable
gen orphan=.
replace orphan=1 if father_alive_baseline==0 & mother_alive_baseline==0
replace orphan=0 if father_alive_baseline==1 | mother_alive_baseline==1 
lab var "Orphans"

*2.2. Defining quintiles for subgroup-analysis. 
xtile age_quin= age_baseline, nq(5)
xtile grade_quin= highest_grade_baseline, nq(5)
xtile asset_quin= asset_index_baseline, nq(5)
xtile hhsize_quin= hhsize_baseline, nq(5)
table hhsize_quin, c(mean uct_total_amount)


*2.3. Numerical & graphical analysis 
*Limitation: Since the comparison is between unmatched groups, there may be bias. 

*Identification of the targeted individuals
tab uct_total_amount highest_grade_baseline
tab uct_total_amount age_baseline
//Shows that only targeted group were girls grade 3-12 and age 13-20. 

*Analysis to understand if there is a difference in distribution of uct (understanding targeting). Please see conclusion below. 
graph box uct_total_amount if uct==1, over(hhsize_baseline)
mean uct_total_amount, over(hhsize_baseline)
graph box uct_total_amount if uct==1, over(age_baseline)
mean uct_total_amount if uct==1, over(age_baseline) 
graph box uct_total_amount if uct==1, over(urban_baseline)
mean uct_total_amount if uct==1, over(urban_baseline)
ttest uct_total_amount if uct==1, by(urban_baseline) //Reject H0 at 1% level. 
graph box uct_total_amount if uct==1, over(father_alive_baseline)
mean uct_total_amount if uct==1, over(father_alive_baseline)
graph box uct_total_amount if uct==1, over(mother_alive_baseline)
mean uct_total_amount if uct==1, over(mother_alive_baseline)
graph box uct_total_amount if uct==1, over(unequal)
mean uct_total_amount if uct==1, over(unequal)
scatter uct_total_amount asset_index_baseline
*Analysis of correlations of covariates
pwcorr uct_total_amount $xlist, sig
pwcorr uct_total_amount $xlist if uct==1, sig
//Conclusion: It is unclear on which basis the amount transferred was determined as the distribution in the treatment group in regards to the baseline variables seems almost uniform in most cases. Therefore, the target process of the program may be questioned and potentially the whole sample is part of the targeted population. On average urban housholds received higher UCT. This result is statistically different from zero at the 1% significance level. However, as the sample contains a higher urban to rural ratio, this result may coincidentally stem from randomization, as long as not controlled for distribution and variance when performing the ttest. 
count if uct
hist uct_total_amount if uct==1, subtitle(`r(N)' observations in treatment group) title("Distribution of UCT") 
graph save "4 Graphs/hist_uct.gph", replace

*Understanding the role of asset index. 
graph box asset_index_baseline if uct==1, by(cumpul_school_baseline)
ttest asset_index_baseline if uct==1, by(cumpul_school_baseline)
//Amongst those receiving the treatment the asset index baseline is significantly lower for primary and junior secondary pupils than for senior secondary. 

mean asset_index_baseline, over(urban)
ttest asset_index_baseline, by(urban)
mean uct_total_amount if uct==1, over(urban)
ttest uct_total_amount if uct==1, by(urban_baseline)
//The mean asset_index_baseline is statistically higher in rural areas (Reject H0:diff=0, at 1% significance level). The mean uct_total_amount is statistically not higher in rural areas (Fail to reject H0:diff=0). 

mean uct_total_amount if uct==1, over(highest_grade_baseline)
graph box uct_total_amount if uct==1, over(highest_grade_baseline)
graph box uct_total_amount if uct==1, over(age_baseline)
mean uct_total_amount if uct==1, over(educ_level_baseline)
graph box uct_total_amount if uct==1, over(educ_level_baseline)
//As the amount UCT provided increased in grade 5, the program seems to be targeted for grades 5-12. The mean uct support provided is almost identical in all periods. It may be assumed that the program targeted the transitional period between primary and secondary or may be poorly targeted.

*Unequal: the group where the level of education does not match the age.  
tab highest_grade_baseline unequal
pwcorr cog_std unequal, sig
pwcorr asset_index_baseline unequal, sig
ttest asset_index_baseline, by(unequal)
ttest female_headed_baseline, by(unequal)
ttest highest_grade_baseline, by(unequal)
ttest cog_std, by(unequal)
ttest cog_std if uct==1, by(unequal) //indication that the treatment reduces the difference in cognitive standards 


*Understanding the outcome variables: 
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(urban_baseline)
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(father_alive_baseline)
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(hhsize_baseline)
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(highest_grade_baseline)
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(age_baseline) 
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(educ_level_baseline)
mean uct_total_amount frac_attend cog_std income pregnant married mobile, over(cumpul_school_baseline)



*2.4. Decisision for variables to be tested. 

*Following the analysis in 2.3 the influence of the following variables on educational and health outcomes is analysed.  

global xlist asset_index_baseline hhsize_baseline age_baseline father_alive_baseline urban_baseline female_headed_baseline mother_alive_baseline highest_grade_baseline 
global ylist frac_attend cog_std pregnant married 


***************************************************************
*3. Estimating impact of program participation 
***************************************************************

*This section serves to understand which variables should be included in the PSM model to mimic the targeting process. 
*The decision takes the significance of variables of the multiple regressions and theoretical considerations (more important) into account.

* 2.2. Education outcomes

* Cognitive score
tab uct, sum(cog_std) means standard
mean cog_std, over(uct)
ttest cog_std, by(uct)
reg cog_std uct, r
reg cog_std uct $xlist, r
/* 
Sig at 1% asset_index_baseline, urban_baseline, female_headed_baseline, highest_grade_baseline. 
Sig. at 5%: uct
Not sig.: others.*/

* Fraction of school attendence
tab uct, sum(frac_attend) means standard
mean frac_attend, over(uct) 
reg frac_attend uct, r 
reg frac_attend uct $xlist, r
/*Sig at 1% uct 
Sig. at 5%: age_baseline
Not sig.: others.*/



*2.3. Health outcomes

* Early marriage
tab uct, sum(married) means standard
mean married, over(uct) 
ttest married, by(uct)
probit married uct, r
margins, dydx(*)
probit married uct $xlist, r 
margins, dydx(*)
*/*Sig at 1% age_baseline, highest_grade_baseline 
Sig. at 5%: hhsize_baseline, father_alive_baseline, 
Not sig.: others.*/

* Pregnancy
tab uct, sum(pregnancy) means standard
mean pregnancy, over(uct) 
probit pregnancy uct, r
margins, dydx(*)
probit pregnacny uct $xlist, r
margins, dydx(*)
*/*Sig at 1% hhsize_baseline, age_baseline, highest_grade_baseline 
Not sig.: others.*/


*The significant variables provide a statistical justification for including them in the propensity score matching process. However, variables have to be chosen also according to program description and theory. 


********************************************************************************
* 4. Propensity score matching
********************************************************************************

*4.1. Choice of model: Arguments for PSM 

*RDD would require an index (e.g. poverty index) or indicator variable (e.g. income) with a cut-off point. 
scatter uct income
scatter uct asset_index_baseline 
scatter uct hhsize_baseline
scatter uct age_baseline
*No indication of any indexed or non indexed cut-off points, RDD is not the appropriate method. 
*Since the outcome variables t+1 are not measured at t, a Difference-in-Difference appraoch is not possible. 

*Therefore, PSM is considered the appropriate method of analysis.  

********************************************************************************
* 4.2. STEP 1. Estimate a binary model of program participation
********************************************************************************

*4.2.1: Choosing variables for PSM: 
/*PSM tries to mimic the matching process.The programme was implemented through a targeting process based on two criteria:
*1) Proxy-means test to select the poorest households;
vars: asset_index_baseline*/
*female_headed_baseline, as poverty proxy
ttest asset_index_baseline, by(female_headed_baseline) // Reject H0, that there is no difference in asset_index_baseline, between female and male headed households at the 1% significance level.

*urban_baseline, as poverty proxy
ttest asset_index_baseline, by(urban) //Reject the HO:diff means of asset_index_baseline in urban and rural areas =0 at the 1% significance level. 

*father_alive_baseline, as poverty proxy
ttest asset_index_baseline, by(father_alive_baseline)
//Reject, HO, that there is no difference in means of asset_index_baseline if the father is alive at the 5% significance level. 

pwcorr father_alive_baseline female_headed_baseline, sig //no sig. correlation. 


*Not included: orphan
ttest asset_index_baseline, by(orphan)
//Fail to reject H0, that there is no difference in means of asset_index_baseline

/*2) Categorical targeting to select large households with school-age girls.
*vars: hhsize_baseline, age_baseline, mother_alive_baseline.

/*Notes:
*mother_alive_baseline is considered as relevant for health outcomes in school-aged girls (Source, see report).
*highest_grade_baseline is considered as relevant for explaining cognitive outcomes (Source, see report).*/  

*Testing if the xlist variables are highly correlated (exclusion criterium for PSM) */
pwcorr $xlist $xlist, sig //No signifanct high correlations between xvariables.
pwcorr $ylist $xlist, sig //No significant high correlations between y and xvariables. 
 
*The model may potentially be overspecified. 


*4.2.2: Estimating a propensity score for each observation. 
drop ps1 block comsup
pscore uct $xlist, pscore(ps1) blockid(block) comsup
margins, dydx(*) //allows for % interpretation of probit regression the coefficents are the probability to be selected for the program).
lab var ps1 "Propensity score"
lab var comsup "Common support" 

*Table 2: Estimation of the propensity score. The probit regression shows how the different variables impact the probability of participating in the program.
*Log likelihood = -1365.3224 
*Sig at 1%: asset_index_baseline, age_baseline, highest grade
*Sig at 5%: female_headed_baseline, urban_baseline
*Not sig.: hhsize_baseline, father_alive_baseline, mother_alive_baseline 
*The region of common support is [.04558132, .29671258]
*The final number of blocks is 4
*The balancing property is satisfied. 
hist ps1, by(uct)
graph save "4 Graphs/hist1.gph", replace


********************************************************************************
* 4.3. STEP 2. Define the region of common support  
********************************************************************************

* Visualizing the distribution of the propensity score for the treated and non treated group 

histogram ps1 , by(uct, col(1)) title("Propensity score of group") 
graph save "4 Graphs/hist2.gph", replace
psgraph, treated (uct) pscore(ps1) title("Propensity score histogram by treatment") 
graph save "4 Graphs/psgraph1.gph", replace 

*Densityplot for area of common support (run all commands together): 
sum ps1 if uct==1, d  
local min=r(min) 
local max=r(max)  
graph twoway (kdensity ps1 if uct==1) (kdensity ps1 if uct==0), title("Kernel density") ytitle("Density") xtitle("Propensity score") legend(label(1 "Treated") label(2 "Untreated")) xline (`min') xline(`max')
graph save "4 Graphs/kdencsity_comsup1.gph", replace 

* Check if all treated are in the common support to avoid selection bias
tab comsup uct // all treated are in the common support group, therefore there is no selection bias and we don't need to re-estimate the model. 

*Descriptive on pre-programme characteristics after matching: looking for bias
pstest $xlist, t(uct) sup(comsup) mweight(ps1) rub graph both
graph save "4 Graphs/pstest1.gph", replace

//Comparing matched and unmatched. In all variables the bias is below 5%. In all variables the differences in means of the treated and control group in the sample are not statistically different from zero (fail to reject H0:diff=0 for all variables). This results are statistically significant at all conventional significance levels. 

//No percentages for concern and bad are defined and the match is considered as good with B=4.5 The specifications of the model achieve internal validity. 


********************************************************************************
* 4.4 STEP 3. Matching participants and non participants and evaluate the impact of the programme
********************************************************************************

*H0: mean(uct==1)-mean(uct==0)=0

/*Critical values for significance levels using t-statistics:
t* at 1%: 	2.57
t* at 5%: 	1.96
t* at 10%:	1.64
Condition: Reject H0 if t>t*/

/*Critical values for significance level using p-values: 
alpha= 1%,5%,10%
Condition: Reject H0 if p<alpha*/
 
* 4.4.1 Calculation of ATET effect (in quasi experimental methods different from ATT, whereas in RCT it is the same effect)
teffects psmatch (frac_attend) (uct $xlist, logit), ate
teffects psmatch (cog_std) (uct $xlist, logit), ate
teffects psmatch (married) (uct $xlist, logit), ate
teffects psmatch (pregnant) (uct $xlist, logit), ate 
teffects psmatch (mobile) (uct $xlist, logit), ate 
teffects psmatch (income) (uct $xlist, logit), ate 


*4.4.2 Calculation of ATT effect. 

* To account for the robustness of your results, we conduct different matching methods (e.g. attnd, atts, attr, attk)

********************************************************************************
*Educational outcomes: fraction of school days attended (significant impact)
* Nearest Neighbour matching (attnd)
attnd frac_attend uct, pscore(ps1) comsup //sig.
//The estimated coefficient of the effect uct has on the Standardized Cognitive Score is significant at the 5% level (t 1.88 > t* 1.64). Holding other factors constant, the impact of the program on the fraction of school days attended is quite low with 0.004 on average.

* Robustness check: 
* Stratification matching (atts)
atts frac_attend uct, pscore(ps1) blockid(block) comsup //sig.
* Radius matching (attr)
attr frac_attend uct, pscore(ps1) radius(0.01) comsup //sig.
* Kernel matching (attk) 
attk frac_attend uct, pscore(ps1) comsup bootstrap reps(150) //sig. 

*Educational outcomes: Cognitive Standards (no significant impact)

attnd cog_std uct, pscore(ps1) comsup 
atts cog_std uct, pscore(ps1) blockid(block) comsup
attr cog_std uct, pscore(ps1) radius(0.01) comsup
attk cog_std uct, pscore(ps1) comsup bootstrap reps(150) 

********************************************************************************
*Health outcomes: Pregnancy (no significant result)

attnd pregnant uct, pscore(ps1) comsup  
attr pregnant uct, pscore(ps1) radius(0.01) comsup
atts pregnant uct, pscore(ps1) blockid(block) comsup
attk pregnant uct, pscore(ps1) comsup bootstrap reps(150)

*Health outcomes: Early marriage (no significant effect)

attnd married uct, pscore(ps1) comsup 
atts married uct, pscore(ps1) blockid(block) comsup
attr married uct, pscore(ps1) radius(0.01) comsup
attk married uct, pscore(ps1) comsup bootstrap reps(150)

********************************************************************************
*Other outcomes: Mobile (significant effect) 
attnd mobile uct, pscore(ps1) comsup
atts mobile uct, pscore(ps1) blockid(block) comsup
attr mobile uct, pscore(ps1) radius(0.01) comsup
attk mobile uct, pscore(ps1) comsup bootstrap reps(150)

*Other outcomes: Income (significant effect) 
attnd income uct, pscore(ps1) comsup
atts income uct, pscore(ps1) blockid(block) comsup
attr income uct, pscore(ps1) radius(0.01) comsup
attk income uct, pscore(ps1) comsup bootstrap reps(150)

********************************************************************************
*Conclusion: The UCT has a very low impact on fraction of attended school days, a low-medium impact on access to mobile phone (both statistically different from zero at the 10% significance level), whereas no impact was found on cognitive score and health indicators early marriage and pregnancy. 




********************************************************************************
*4.4.3 Estimation of ATT on subgroups 
********************************************************************************


*Educational outcomes: Fraction of school days attended

*age_baseline (varied significant impact)
attnd frac_attend uct if age_quin==1&2, pscore(ps1) comsup //sig.
*Robustness check
atts frac_attend uct if age_quin==1&2, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if age_quin==1&2, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if age_quin==1&2, pscore(ps1) comsup bootstrap reps(150) //sig. 

attnd frac_attend uct if age_quin==3&4, pscore(ps1) comsup //n.s.
attnd frac_attend uct if age_quin==5, pscore(ps1) comsup //n.s.

*asset_index_baseline (no significant impact)
attnd frac_attend uct if asset_quin==1&2, pscore(ps1) comsup
attnd frac_attend uct if asset_quin==3&4, pscore(ps1) comsup 
attnd frac_attend uct if asset_quin==5, pscore(ps1) comsup 

*urban_baseline (varied significant impact)
attnd frac_attend uct if urban_baseline==1, pscore(ps1) comsup //sig.
*Robustness check:
atts frac_attend uct if urban_baseline==1, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if urban_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if urban_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd frac_attend uct if urban_baseline==0 , pscore(ps1) comsup //n.s.
 

*hhsize_baseline (no significant impact)
attnd frac_attend uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd frac_attend uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd frac_attend uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (no significant impact)
attnd frac_attend uct if female_headed_baseline==1, pscore(ps1) comsup //sig. 
atts frac_attend uct if female_headed_baseline==1, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if female_headed_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if female_headed_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd frac_attend uct if female_headed_baseline==0, pscore(ps1) comsup //n.s. 

*unequal (no significant impact)
attnd frac_attend uct if unequal==1, pscore(ps1) comsup
attnd frac_attend uct if unequal==0, pscore(ps1) comsup

*highest_grade_baseline (varied signifanct impact)
attnd frac_attend uct if grade_quin==1&2, pscore(ps1) comsup //n.s.
attnd frac_attend uct if grade_quin==3&4, pscore(ps1) comsup //sig.
* Robustness check
atts frac_attend uct if grade_quin==3&4, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if grade_quin==3&4, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if grade_quin==3&4, pscore(ps1) comsup bootstrap reps(150) //sig.

*cumpul_school_baseline (varied signifanct impact)
attnd frac_attend uct if cumpul_school_baseline==0, pscore(ps1) comsup //n.s.
attnd frac_attend uct if cumpul_school_baseline==1, pscore(ps1) comsup //sig.
*Robustness check: 
atts frac_attend uct if cumpul_school_baseline==1, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if cumpul_school_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if cumpul_school_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

*educ_level_baseline (varied signifanct impact)
attnd frac_attend uct if educ_level_baseline==1, pscore(ps1) comsup //n.s.
attnd frac_attend uct if educ_level_baseline==2, pscore(ps1) comsup //sig.
*Robustness check: 
atts frac_attend uct if educ_level_baseline==2, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if educ_level_baseline==2, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if educ_level_baseline==2, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd frac_attend uct if educ_level_baseline==3, pscore(ps1) comsup //n.s.


*father_alive_baseline (no significant impact)
attnd frac_attend uct if father_alive_baseline==1, pscore(ps1) comsup
attnd frac_attend uct if father_alive_baseline==0, pscore(ps1) comsup 

*mother_alive_baseline (varied signifanct impact)
attnd frac_attend uct if mother_alive_baseline==1, pscore(ps1) comsup //sig. 
*Robustness check
atts frac_attend uct if mother_alive_baseline==1, pscore(ps1) blockid(block) comsup //sig. 
attr frac_attend uct if mother_alive_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk frac_attend uct if mother_alive_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd frac_attend uct if mother_alive_baseline==0, pscore(ps1) comsup //n.s.


*Conclusion: The following subgroups all have a significant impact at the 1% significance level (in not economically meaningful magnitude) on fraction of school days attended: urban area, mother alive, compulsory schooling, junior secondary schooling. At the 5% significane level: highest grade. 


********************************************************************************
*Educational outcomes: Cognitive Score

*age_baseline (no significant impact)
attnd cog_std uct if age_quin==1&2, pscore(ps1) comsup
attnd cog_std uct if age_quin==3&4, pscore(ps1) comsup
attnd cog_std uct if age_quin==5, pscore(ps1) comsup

*asset_index_baseline (no significant impact)
attnd cog_std uct if asset_quin==1&2, pscore(ps1) comsup
attnd cog_std uct if asset_quin==3&4, pscore(ps1) comsup 
attnd cog_std uct if asset_quin==5, pscore(ps1) comsup 

*urban_baseline (no significant impact)
attnd cog_std uct if urban_baseline==1, pscore(ps1) comsup
attnd cog_std uct if urban_baseline==0 , pscore(ps1) comsup
 
*hhsize_baseline (no significant impact)
attnd cog_std uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd cog_std uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd cog_std uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (no significant impact)
attnd cog_std uct if female_headed_baseline==1, pscore(ps1) comsup  
attnd cog_std uct if female_headed_baseline==0, pscore(ps1) comsup 

*unequal (varied significant impact)
attnd cog_std uct if unequal==1, pscore(ps1) comsup //sig.
*Robustness check
atts cog_std uct if unequal==1, pscore(ps1) blockid(block) comsup //sig. 
attr cog_std uct if unequal==1, pscore(ps1) radius(0.01) comsup //sig. 
attk cog_std uct if unequal==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd cog_std uct if unequal==0, pscore(ps1) comsup  //n.s.

*highest_grade_baseline (varied signifanct impact)
attnd cog_std uct if grade_quin==1&2, pscore(ps1) comsup //sig.
* Robustness check
atts cog_std uct if grade_quin==1&2, pscore(ps1) blockid(block) comsup //sig. 
attr cog_std uct if grade_quin==1&2, pscore(ps1) radius(0.01) comsup //sig. 
attk cog_std uct if grade_quin==1&2, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd cog_std uct if grade_quin==3&4, pscore(ps1) comsup //n.s.
attnd cog_std uct if grade_quin==5, pscore(ps1) comsup //n.s. 

*cumpul_school_baseline (no signifanct impact)
attnd cog_std uct if cumpul_school_baseline==0, pscore(ps1) comsup //n.s.
attnd cog_std uct if cumpul_school_baseline==1, pscore(ps1) comsup //n.s. 


*educ_level_baseline (varied signifanct impact)
attnd cog_std uct if educ_level_baseline==1, pscore(ps1) comsup //sig.
*Robustness check 
atts cog_std uct if educ_level_baseline==1, pscore(ps1) blockid(block) comsup //sig. 
attr cog_std uct if educ_level_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk cog_std uct if educ_level_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd cog_std uct if educ_level_baseline==2, pscore(ps1) comsup //n.s.
attnd cog_std uct if educ_level_baseline==3, pscore(ps1) comsup //n.s.

*father_alive_baseline (no significant impact)
attnd cog_std uct if father_alive_baseline==1, pscore(ps1) comsup
attnd cog_std uct if father_alive_baseline==0, pscore(ps1) comsup 

*mother_alive_baseline (no signifanct impact)
attnd cog_std uct if mother_alive_baseline==1, pscore(ps1) comsup
attnd cog_std uct if mother_alive_baseline==0, pscore(ps1) comsup



********************************************************************************
*Health outcomes: pregnant

*age_baseline (no significant impact)
attnd pregnant uct if age_quin==1&2, pscore(ps1) comsup
attnd pregnant uct if age_quin==3&4, pscore(ps1) comsup
attnd pregnant uct if age_quin==5, pscore(ps1) comsup

*asset_index_baseline (no significant impact)
attnd pregnant uct if asset_quin==1&2, pscore(ps1) comsup
attnd pregnant uct if asset_quin==3&4, pscore(ps1) comsup 
attnd pregnant uct if asset_quin==5, pscore(ps1) comsup 

*urban_baseline (varied significant impact)
attnd pregnant uct if urban_baseline==1, pscore(ps1) comsup //sig.
*Robustness check:
atts pregnant uct if urban_baseline==1, pscore(ps1) blockid(block) comsup //n.s. 
attr pregnant uct if urban_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk pregnant uct if urban_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd pregnant uct if urban_baseline==0 , pscore(ps1) comsup //n.s.
 

*hhsize_baseline (no significant impact)
attnd pregnant uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd pregnant uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd pregnant uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (no significant impact)
attnd pregnant uct if female_headed_baseline==1, pscore(ps1) comsup  
attnd pregnant uct if female_headed_baseline==0, pscore(ps1) comsup 

*unequal (varied significant impact)
attnd pregnant uct if unequal==1, pscore(ps1) comsup //sig.
*Robustness check
atts pregnant uct if unequal==1, pscore(ps1) blockid(block) comsup //n.s. 
attr pregnant uct if unequal==1, pscore(ps1) radius(0.01) comsup //n.s.
attk pregnant uct if unequal==1, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd pregnant uct if unequal==0, pscore(ps1) comsup  //n.s.

*highest_grade_baseline (varied signifanct impact)
attnd pregnant uct if grade_quin==1&2, pscore(ps1) comsup //sig.
* Robustness check
atts pregnant uct if grade_quin==1&2, pscore(ps1) blockid(block) comsup //n.s. 
attr pregnant uct if grade_quin==1&2, pscore(ps1) radius(0.01) comsup //n.s.
attk pregnant uct if grade_quin==1&2, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd pregnant uct if grade_quin==3&4, pscore(ps1) comsup //n.s.
attnd pregnant uct if grade_quin==5, pscore(ps1) comsup //n.s. 

*cumpul_school_baseline (no signifanct impact)
attnd pregnant uct if cumpul_school_baseline==0, pscore(ps1) comsup
attnd pregnant uct if cumpul_school_baseline==1, pscore(ps1) comsup 

*educ_level_baseline (no signifanct impact)
attnd pregnant uct if educ_level_baseline==1, pscore(ps1) comsup
attnd pregnant uct if educ_level_baseline==2, pscore(ps1) comsup
attnd pregnant uct if educ_level_baseline==3, pscore(ps1) comsup

*father_alive_baseline (no significant impact)
attnd pregnant uct if father_alive_baseline==1, pscore(ps1) comsup
attnd pregnant uct if father_alive_baseline==0, pscore(ps1) comsup 

*mother_alive_baseline (varied signifanct impact)
attnd pregnant uct if mother_alive_baseline==1, pscore(ps1) comsup //n.s.
attnd pregnant uct if mother_alive_baseline==0, pscore(ps1) comsup //sig.
*Robustness check
atts pregnant uct if mother_alive_baseline==0, pscore(ps1) blockid(block) comsup //n.s. 
attr pregnant uct if mother_alive_baseline==0, pscore(ps1) radius(0.01) comsup //n.s.
attk pregnant uct if mother_alive_baseline==0, pscore(ps1) comsup bootstrap reps(150) //n.s.



********************************************************************************
*Health outcomes: married

*age_baseline (varied significant impact)
attnd married uct if age_quin==1&2, pscore(ps1) comsup //n.s.
attnd married uct if age_quin==3&4, pscore(ps1) comsup //sig.
*Robustness check
atts married uct if age_quin==3&4, pscore(ps1) blockid(block) comsup //n.s. 
attr married uct if age_quin==3&4, pscore(ps1) radius(0.01) comsup //n.s.
attk married uct if age_quin==3&4, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd married uct if age_quin==5, pscore(ps1) comsup //n.s.

*asset_index_baseline (no significant impact)
attnd married uct if asset_quin==1&2, pscore(ps1) comsup
attnd married uct if asset_quin==3&4, pscore(ps1) comsup 
attnd married uct if asset_quin==5, pscore(ps1) comsup 

*urban_baseline (varied significant impact)
attnd married uct if urban_baseline==1, pscore(ps1) comsup //n.s.
attnd married uct if urban_baseline==0 , pscore(ps1) comsup //sig.
*Robustness check: 
atts married uct if urban_baseline==0, pscore(ps1) blockid(block) comsup //n.s. 
attr married uct if urban_baseline==0, pscore(ps1) radius(0.01) comsup //n.s.
attk married uct if urban_baseline==0, pscore(ps1) comsup bootstrap reps(150) //n.s.

*hhsize_baseline (no significant impact)
attnd married uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd married uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd married uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (no significant impact)
attnd married uct if female_headed_baseline==1, pscore(ps1) comsup  
attnd married uct if female_headed_baseline==0, pscore(ps1) comsup 

*unequal (no significant impact)
attnd married uct if unequal==1, pscore(ps1) comsup 
attnd married uct if unequal==0, pscore(ps1) comsup  

*highest_grade_baseline (varied signifanct impact)
attnd married uct if grade_quin==1&2, pscore(ps1) comsup //sig.
* Robustness check
atts married uct if grade_quin==1&2, pscore(ps1) blockid(block) comsup //n.s. 
attr married uct if grade_quin==1&2, pscore(ps1) radius(0.01) comsup //n.s.
attk married uct if grade_quin==1&2, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd married uct if grade_quin==3&4, pscore(ps1) comsup //n.s.
attnd married uct if grade_quin==5, pscore(ps1) comsup //n.s. 

*cumpul_school_baseline (no signifanct impact)
attnd married uct if cumpul_school_baseline==0, pscore(ps1) comsup
attnd married uct if cumpul_school_baseline==1, pscore(ps1) comsup 

*educ_level_baseline (no signifanct impact)
attnd married uct if educ_level_baseline==1, pscore(ps1) comsup
attnd married uct if educ_level_baseline==2, pscore(ps1) comsup
attnd married uct if educ_level_baseline==3, pscore(ps1) comsup

*father_alive_baseline (no significant impact)
attnd married uct if father_alive_baseline==1, pscore(ps1) comsup
attnd married uct if father_alive_baseline==0, pscore(ps1) comsup 

*mother_alive_baseline (no signifanct impact)
attnd married uct if mother_alive_baseline==1, pscore(ps1) comsup 
attnd married uct if mother_alive_baseline==0, pscore(ps1) comsup


********************************************************************************
*Other outcome: mobile

*age_baseline (no significant impact)
attnd mobile uct if age_quin==1&2, pscore(ps1) comsup
attnd mobile uct if age_quin==3&4, pscore(ps1) comsup
attnd mobile uct if age_quin==5, pscore(ps1) comsup

*asset_index_baseline (no significant impact)
attnd mobile uct if asset_quin==1&2, pscore(ps1) comsup
attnd mobile uct if asset_quin==3&4, pscore(ps1) comsup 
attnd mobile uct if asset_quin==5, pscore(ps1) comsup 

*urban_baseline (varied significant impact)
attnd mobile uct if urban_baseline==1, pscore(ps1) comsup //sig.
atts mobile uct if urban_baseline==1, pscore(ps1) blockid(block) comsup //n.s. 
attr mobile uct if urban_baseline==1, pscore(ps1) radius(0.01) comsup //n.s.
attk mobile uct if urban_baseline==1, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd mobile uct if urban_baseline==0 , pscore(ps1) comsup //n.s.

*hhsize_baseline (no significant impact)
attnd mobile uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd mobile uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd mobile uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (varied significant impact)
attnd mobile uct if female_headed_baseline==1, pscore(ps1) comsup //n.s. 
attnd mobile uct if female_headed_baseline==0, pscore(ps1) comsup //sig.
*Robustness check
atts mobile uct if female_headed_baseline==0, pscore(ps1) blockid(block) comsup //n.s. 
attr mobile uct if female_headed_baseline==0, pscore(ps1) radius(0.01) comsup //n.s.
attk mobile uct if urban_baseline==1, pscore(ps1) comsup bootstrap reps(150) //n.s.

*unequal (varied significant impact)
attnd mobile uct if unequal==1, pscore(ps1) comsup //sig.
atts mobile uct if unequal==1, pscore(ps1) blockid(block) comsup //sig.
attr mobile uct if unequal==1, pscore(ps1) radius(0.01) comsup //n.s.
attk mobile uct if unequal==1, pscore(ps1) comsup bootstrap reps(150) //sig. 
.
attnd mobile uct if unequal==0, pscore(ps1) comsup  //n.s.

*highest_grade_baseline (no signifanct impact)
attnd mobile uct if grade_quin==1&2, pscore(ps1) comsup
attnd mobile uct if grade_quin==3&4, pscore(ps1) comsup
attnd mobile uct if grade_quin==5, pscore(ps1) comsup

*cumpul_school_baseline (varied signifanct impact)
attnd mobile uct if cumpul_school_baseline==0, pscore(ps1) comsup //n.s.
attnd mobile uct if cumpul_school_baseline==1, pscore(ps1) comsup //sig.
*Robustness check
atts mobile uct if cumpul_school_baseline==1, pscore(ps1) blockid(block) comsup //sig.
attr mobile uct if cumpul_school_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk mobile uct if cumpul_school_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig. 

*educ_level_baseline (varied signifanct impact)
attnd mobile uct if educ_level_baseline==1, pscore(ps1) comsup //sig.
*Robustness check: 
atts mobile uct if educ_level_baseline==1, pscore(ps1) blockid(block) comsup //n.s. 
attr mobile uct if educ_level_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk mobile uct if educ_level_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig. 

attnd mobile uct if educ_level_baseline==2, pscore(ps1) comsup //n.s.
attnd mobile uct if educ_level_baseline==3, pscore(ps1) comsup //n.s. 

*father_alive_baseline (varied significant impact)
attnd mobile uct if father_alive_baseline==1, pscore(ps1) comsup //sig.
*Robustness check 
atts mobile uct if father_alive_baseline==1, pscore(ps1) blockid(block) comsup //n.s. 
attr mobile uct if father_alive_baseline==1, pscore(ps1) radius(0.01) comsup //n.s. 
attk mobile uct if father_alive_baseline==1, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd mobile uct if father_alive_baseline==0, pscore(ps1) comsup //n.s.

*mother_alive_baseline (varied signifanct impact)
attnd mobile uct if mother_alive_baseline==1, pscore(ps1) comsup //sig.
*Robustness check
atts mobile uct if mother_alive_baseline==1, pscore(ps1) blockid(block) comsup //n.s. 
attr mobile uct if mother_alive_baseline==1, pscore(ps1) radius(0.01) comsup //n.s. 
attk mobile uct if mother_alive_baseline==1, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd mobile uct if mother_alive_baseline==0, pscore(ps1) comsup //n.s.


********************************************************************************
*Other outcome: income

*age_baseline (varied significant impact)
attnd income uct if age_quin==1&2, pscore(ps1) comsup //sig.
*Robustness check
atts income uct if age_quin==1&2, pscore(ps1) blockid(block) comsup //sig.
attr income uct if age_quin==1&2, pscore(ps1) radius(0.01) comsup //sig.
attk income uct if age_quin==1&2, pscore(ps1) comsup bootstrap reps(150) //sig.

attnd income uct if age_quin==3&4, pscore(ps1) comsup //n.s.
attnd income uct if age_quin==5, pscore(ps1) comsup //n.s.

*asset_index_baseline (no significant impact)
attnd income uct if asset_quin==1&2, pscore(ps1) comsup //n.s.
attnd income uct if asset_quin==3&4, pscore(ps1) comsup //sig.
*Robustness check
atts income uct if asset_quin==3&4, pscore(ps1) blockid(block) comsup //n.s.
attr income uct if asset_quin==3&4, pscore(ps1) radius(0.01) comsup //sig.
attk income uct if asset_quin==3&4, pscore(ps1) comsup bootstrap reps(150) //n.s.

attnd income uct if asset_quin==5, pscore(ps1) comsup //n.s.

*urban_baseline (varied significant impact)
attnd income uct if urban_baseline==1, pscore(ps1) comsup //sig.
*Robustness check 
atts income uct if urban_baseline==1, pscore(ps1) blockid(block) comsup //sig.
attr income uct if urban_baseline==1, pscore(ps1) radius(0.01) comsup //sig.
attk income uct if urban_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig. 

attnd income uct if urban_baseline==0 , pscore(ps1) comsup //n.s.

*hhsize_baseline (no significant impact)
attnd income uct if hhsize_quin==1&2 , pscore(ps1) comsup 
attnd income uct if hhsize_quin==3&4, pscore(ps1) comsup 
attnd income uct if hhsize_quin==5, pscore(ps1) comsup

*female_headed_baseline (varied significant impact)
attnd income uct if female_headed_baseline==1, pscore(ps1) comsup //n.s. 
attnd income uct if female_headed_baseline==0, pscore(ps1) comsup //sig.
*Robustness check
atts income uct if female_headed_baseline==0, pscore(ps1) blockid(block) comsup //n.s. 
attr income uct if female_headed_baseline==0, pscore(ps1) radius(0.01) comsup //n.s.
attk income uct if female_headed, pscore(ps1) comsup bootstrap reps(150) //n.s.

*unequal (varied significant impact)
attnd income uct if unequal==1, pscore(ps1) comsup //sig.
*Robustness check
atts income uct if unequal==1, pscore(ps1) blockid(block) comsup //sig.
attr income uct if unequal==1, pscore(ps1) radius(0.01) comsup //sig. 
attk income uct if unequal==1, pscore(ps1) comsup bootstrap reps(150) //sig. 

attnd income uct if unequal==0, pscore(ps1) comsup  //n.s.

*highest_grade_baseline (no signifanct impact)
attnd income uct if grade_quin==1&2, pscore(ps1) comsup
attnd income uct if grade_quin==3&4, pscore(ps1) comsup
attnd income uct if grade_quin==5, pscore(ps1) comsup

*cumpul_school_baseline (varied signifanct impact)
attnd income uct if cumpul_school_baseline==0, pscore(ps1) comsup //n.s.
attnd income uct if cumpul_school_baseline==1, pscore(ps1) comsup //sig.
*Robustness check
atts income uct if cumpul_school_baseline==1, pscore(ps1) blockid(block) comsup //sig.
attr income uct if cumpul_school_baseline==1, pscore(ps1) radius(0.01) comsup //sig. 
attk income uct if cumpul_school_baseline==1, pscore(ps1) comsup bootstrap reps(150) //sig. 

*educ_level_baseline (varied signifanct impact)
attnd income uct if educ_level_baseline==1, pscore(ps1) comsup //n.s.
attnd income uct if educ_level_baseline==2, pscore(ps1) comsup //sig. 
*Robustness check 
atts income uct if educ_level_baseline==2, pscore(ps1) blockid(block) comsup //sig.
attr income uct if educ_level_baseline==2, pscore(ps1) radius(0.01) comsup //sig. 
attk income uct if educ_level_baseline==2, pscore(ps1) comsup bootstrap reps(150) //sig. 

attnd income uct if educ_level_baseline==3, pscore(ps1) comsup //n.s. 

*father_alive_baseline (no significant impact)
attnd income uct if father_alive_baseline==1, pscore(ps1) comsup //n.s.
attnd mobile uct if father_alive_baseline==0, pscore(ps1) comsup //n.s.

*mother_alive_baseline (no signifanct impact)
attnd income uct if mother_alive_baseline==1, pscore(ps1) comsup //n.s.
attnd income uct if mother_alive_baseline==0, pscore(ps1) comsup //n.s.

***************************************************************
*5.0. Conclusions 
*************************************************************** 
mean frac_attend if comsup==1, over(uct)
ttest frac_attend if comsup==1, by(uct)

***************************************************************
*6.0. Saving and closing the log file. 
*************************************************************** 
capture log save 
capture log close
