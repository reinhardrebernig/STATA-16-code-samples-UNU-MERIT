*******************************************************************************
******************** Microsimulation & Mapping of Effects *********************
*******************************************************************************

 		
* Author: Reinhard Rebernig				        
* Data courtesy of UNU-MERIT
* OS: Windows
* Stata Version: 16 
* Revsion:  0002 Last change: 15/05/20 by Reinhard Rebernig




clear
set more off


**Change directory**
*replace 'your path' with the directory you are using on your computer
global path "C:" 
*when you use $path Stata will automatically use "C:" 


*we use data from the data folder and store our results in the output folder
global in "$path\Data"
global out "$path\Output"
*command cd $in now tells Stata to change directory to data folder
*command cd $out now tells Stata to change directory to output folder



*change directory to data folder and load the data
cd "$in"
use UNPS11


/*
use survey weights to get representative results
weight indicate how many "similar" households exist in Uganda
e.g. household weight=100 --> there are 100 households with similar characteristics in Uganda 
--> we apply weights to simulate program outcomes for the whole population and not only for our sample
--> [weight=HH_Weight] tells Stata that we use the variable HH_Weight as weight
*/
global weight [weight=HH_Weight]



**********1. Descriptive Statistics*********************************************

*store excel file with results in the output folder*
cd "$out"

*create excel sheet ("results") using putexcel -->  cell B1 contains text 'Mean' etc
*use 'modify' if you want to edit existing file (replace deletes old file and creates a new one with the same name)

putexcel set results, sheet("summary stats") modify
putexcel   B1=("Mean") C1=("SD") D1=("N") 


*summarize variables of interest
*use r(mean), r(sd), r(N)  to retrieve mean, standard deviation, and number of observations of last summarized variable (r(min), r(max) for min and max values)

*first row Income in cells A2-D2
sum PC_Income $weight
putexcel  A2=("Income (monthly)") B2=(r(mean)) C2=(r(sd)) D2=(r(N)) 

*second row Poverty in cells A3-D3
sum Poverty $weight
putexcel  A3=("Poverty Headcount") B3=(r(mean)) C3=(r(sd)) D3=(r(N)) 

*second row school attendance in cells A4-D4
sum School_Attendance if Age >5 & Age<19 $weight
putexcel  A4=("Enrolment (age 6-18)") B4=(r(mean)) C4=(r(sd)) D4=(r(N)) 

*school attainment in cells A5-D5
sum Mean_Educ_Att if Age >17 $weight
putexcel  A5=("Mean HH educational attainment (years)") B5=(r(mean)) C5=(r(sd)) D5=(r(N))







*************************2. Arithmetic Simulation******************************

clear
set more off

cd "$in"
use UNPS11


***2. Arithmetic Simulation***

/*
steps:
-define benficiary households
-allocate program benefits to beneficiaries
-compute poverty & inequality based on new income level
-compute program induced changes and present results
*/ 


*************************Simulation******************************

*define beneficiaries and assign benefits to household head
bysort HH_id: egen hhcns=total(Child)
generate beneficiary=0 if !missing(Age) //be careful with missing values!!!
replace beneficiary=1 if hhcns==1 & Poverty==1  & Head==1 
replace beneficiary=2 if hhcns>1 & !missing(hhcns) & Poverty==1  & Head==1 

*allocate transfers to benficiaries
generate newincome=PC_Income
replace newincome=PC_Income+15000 if beneficiary==1
replace  newincome=PC_Income+30000 if beneficiary==2

*Assumption: household members share income equally --> adjust income per capita
*sum up income of all household members and assign every member the household mean income*
bysort HH_id: egen hhincome=total(newincome)
bysort HH_id: replace newincome=hhincome/HH_Size

*each individual in our data has now income with and without policy
** income variable without policy: PC_Income
** income variable with policy: newincome




**********************ANALYSIS OF SIMULATED DATA****************************

*update outcome variables of interest based on new income level*
*poverty (dummy variable =1 if new income is below the poverty line (spline)
generate povertynew= (newincome<Pov_Line) if !missing(newincome)

*inequality (gini coefficient)
fastgini newincome $weight
generate gininew=r(gini)

*generate difference in outcomes with and without the program (in percentage points --> *100)
generate incomediff=newincome-PC_Income
generate povertydiff=(Poverty-povertynew)*100
generate ginidiff=(Gini-gininew)*100


***************Save Simulation Data**************************************
save simulation, replace



*********************Create Result Table************************************
*store results in the output folder*
cd "$out"
putexcel set results, sheet("arithmetic") modify

*table with old and new outcome variables
putexcel  A2=("Income")  A3=("Poverty") A4=("Inequality") B1=("Baseline") C1=("With Program") D1=("Difference") 
sum PC_Income $weight
putexcel   B2=(r(mean)) 
sum newincome $weight
putexcel   C2=(r(mean)) 
sum incomediff $weight
putexcel   D2=(r(mean))

sum Poverty $weight
putexcel   B3=(r(mean)) 
sum povertynew $weight
putexcel   C3=(r(mean)) 
sum povertydiff $weight
putexcel   D3=(r(mean)) 

sum Gini $weight
putexcel   B4=(r(mean)) 
sum gininew $weight
putexcel   C4=(r(mean)) 
sum ginidiff $weight
putexcel   D4=(r(mean)) 




***************3. Mapping of Data**************************************

clear
********************************************************************************
********************************************************************************
**** 1)  Set the directory to data folder
cd "$in"

********************************************************************************
**** 2)  install  spmap, shp2dta, and mif2dta STATA commands.
********************************************************************************
ssc install spmap

ssc install shp2dta

ssc install mif2dta

********************************************************************************
**** 3)   Search the web for the files that describe the map on which you want to graph your data.
****  You can use ESRI shapefiles or MapInfo Interchange Format. 
****  If you use ESRI you will have an .shp shape file, a .dbf dBASE file, and an .shx index file. 
**** .shp, the coordinates;
**** .shx, an index; and
**** .dbf, the codings.

**** To get them you can go to http://www.diva-gis.org/datadown
********************************************************************************
********************************************************************************  


********************************************************************************  
**** 4)   Create database and files from the shapefile:
**** database(uganda_map_db) specified that we want the database file to be named uganda_map_db.dta.
**** coordinates(uganda_map_coord) specified that we want the coordinate file to be named uganda_map_coord.dta.

**** the command creates two new .dta datasets
********************************************************************************

shp2dta using Uganda_regions_2014, database(uganda_map_db) coordinates(uganda_map_coord)

********************************************************************************  
**** 5)   To achieve our goal, we need to rename the variables with the region codes with the same name
**** in this case I have used _ID
********************************************************************************
cd "$in" 
use simulation.dta , clear

recode Region 0=1
rename Region _ID
sort _ID	
merge _ID using uganda_map_db
drop _merge
********************************************************************************
		
********************************************************************************  
**** 6)   Create the map
**** the _ID is the variable with the code of the region/district
**** var is the variable that we want to represent the map
**** uganda_map_coord is the file created previously
**** BEFORE RUNNING THE MAP, WE NEED TO COLLAPSE THE ORIGINAL FILE TO HAVE ONE OBSERVATION PER REGION/DISTRICT
********************************************************************************
recode beneficiary 2=1
collapse beneficiary $weight, by(_ID)
spmap beneficiary using uganda_map_coord, id(_ID) fcolor(Blues)

**adjust layout...
format beneficiary %4.2f
spmap beneficiary using uganda_map_coord, id(_ID) fcolor(Blues) title("Program Beneficiaries per Region, 2011", size(*0.8))  ///
legtitle("Program Beneficiaries)")  legstyle(1) legend(position(4)) 



********************************************************************************
********************************************************************************


***************4. Mapping of Districts**************************************


clear
set more off

pwd

cd ""



*  ^^ For the Uganda district coding the source is:
	*************	   https://geo.nyu.edu/catalog/stanford-vg894mz3698 
	
	
********************************************************************************
*************************** CONVERTING .SHP INTO .DTA **************************
********************************************************************************

    shp2dta using "Maps\UGA_Dis_2010\UGA_Dis_2010.shp", ///
	     database("Maps\UGA_Dis_2010\UGA_Dis_2010_Map_Db.dta") ///
      coordinates("Maps\UGA_Dis_2010\UGA_Dis_2010_Map_Coord.dta") replace			

********************************************************************************
*************************** CONVERTING .SHP INTO .DTA **************************
********************************************************************************

clear
	 
	 use "Maps\UGA_Dis_2010\UGA_Dis_2010_Map_Db.dta", clear
	   codebook
       browse

clear

use "Output\UNPS11.dta", clear
 codebook DISTRICT_id
 rename DISTRICT_id _ID
  recode _ID (101 = 1) (102 = 1) (103 = 2) (103 = 3) (104 = 4) (105 = 5) (106 = 6) ///
             (107 = 7) (108 = 8) (109 = 9) (110 = 10) (111 = 11) (112 = 12) (113 = 13) ///
			 (114 = 14) (115 = 15) (116 = 16) (117 = 17) (118 = 18) (119 = 19) (120 = 20) ///
			 (121 = 21) (122 = 22) (123 = 23) (124 = 24) (201 = 25) (202 = 26) (203 = 27) ///
			 (204 = 28) (205 = 29) (206 = 30) (207 = 31) (208 = 32) (209 = 33) (210 = 34) ///
			 (211 = 35) (212 = 36) (213 = 37) (214 = 38) (215 = 39) (216 = 40) (217 = 41) ///
			 (218 = 42) (219 = 43) (220 = 44) (221 = 45) (222 = 46) (223 = 47) (224 = 48) ///
			 (225 = 49) (226 = 50) (227 = 51) (228 = 52) (229 = 53) (230 = 54) (231 = 55) ///
			 (232 = 56) (301 = 57) (302 = 58) (303 = 59) (304 = 60) (305 = 61) (306 = 62) ///
			 (307 = 63) (308 = 64) (309 = 65) (310 = 66) (311 = 67) (312 = 68) (313 = 69) ///
			 (314 = 70) (315 = 71) (316 = 72) (317 = 73) (318 = 74) (319 = 75) (320 = 76) ///
			 (321 = 77) (322 = 78) (323 = 79) (324 = 80) (325 = 81) (326 = 82) (327 = 83) ///
			 (328 = 84) (329 = 85) (330 = 86) (401 = 87) (402 = 88) (403 = 89) (404 = 90) ///
			 (405 = 91) (406 = 92) (407 = 93) (408 = 94) (409 = 95) (410 = 96) (411 = 97) ///
			 (412 = 98) (413 = 99) (414 = 100) (415 = 101) (416 = 102) (417 = 103) (418 = 104) ///
			 (419 = 105) (420 = 106) (421 = 107) (422 = 108) (423 = 109) (424 = 110) (425 = 111)  (426 = 112)  
  
  codebook _ID
   sort _ID   







