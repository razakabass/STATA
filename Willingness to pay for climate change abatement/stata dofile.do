/*******************************************************************************
Project: Willingness to pay for climate change abatement

Author: Abdul-Razak Abass Saeed
Date: 15 August 2026

********************************************************************************/


* Set working direcotory
cd "C:/Users/administrator1/OneDrive/W.I.P/Core Econs Project/R/wtp"

* Importing data
import excel "data.xlsx", sheet("Data") firstrow clear

* Inspecting data
describe
codebook
summarize
list in 1/5

* Create reverse-code cog_2,cog_5, scepticism_6,scepticism_7
foreach var of varlist cog_2 cog_5 scepticism_6 scepticism_7 {
    generate `var'_r = `var'
    recode `var'_r (1=5) (2=4) (3=3) (4=2) (5=1)
}

* Create a new variable WTP_plmin_euro for the minimum WTP
generate WTP_plmin_euro = .
replace WTP_plmin_euro = 48   if WTP_plmin == 1
replace WTP_plmin_euro = 72   if WTP_plmin == 2
replace WTP_plmin_euro = 84   if WTP_plmin == 3
replace WTP_plmin_euro = 108  if WTP_plmin == 4
replace WTP_plmin_euro = 156  if WTP_plmin == 5
replace WTP_plmin_euro = 192  if WTP_plmin == 6
replace WTP_plmin_euro = 252  if WTP_plmin == 7
replace WTP_plmin_euro = 324  if WTP_plmin == 8
replace WTP_plmin_euro = 432  if WTP_plmin == 9
replace WTP_plmin_euro = 540  if WTP_plmin == 10
replace WTP_plmin_euro = 720  if WTP_plmin == 11
replace WTP_plmin_euro = 960  if WTP_plmin == 12
replace WTP_plmin_euro = 1200 if WTP_plmin == 13
replace WTP_plmin_euro = 1440 if WTP_plmin == 14

* Create a new variable WTP_plmax_euro for the maximum WTP
generate WTP_plmax_euro = .
replace WTP_plmax_euro = 48   if WTP_plmax == 1
replace WTP_plmax_euro = 72   if WTP_plmax == 2
replace WTP_plmax_euro = 84   if WTP_plmax == 3
replace WTP_plmax_euro = 108  if WTP_plmax == 4
replace WTP_plmax_euro = 156  if WTP_plmax == 5
replace WTP_plmax_euro = 192  if WTP_plmax == 6
replace WTP_plmax_euro = 252  if WTP_plmax == 7
replace WTP_plmax_euro = 324  if WTP_plmax == 8
replace WTP_plmax_euro = 432  if WTP_plmax == 9
replace WTP_plmax_euro = 540  if WTP_plmax == 10
replace WTP_plmax_euro = 720  if WTP_plmax == 11
replace WTP_plmax_euro = 960  if WTP_plmax == 12
replace WTP_plmax_euro = 1200 if WTP_plmax == 13
replace WTP_plmax_euro = 1440 if WTP_plmax == 14

* Create index: Belief that climate change is a real phenomenon
egen climate = rowmean(scepticism_2 scepticism_6_r scepticism_7_r)

* Create index : Preference for government intervention to solve problem in socienty
egen gov_intervention = rowmean(cog_1 cog_2_r cog_3 cog_4 cog_5_r cog_6)

* Feeling of personal responsibility to be environmentally friendly
egen pro_environment = rowmean(PN_1 PN_2 PN_3 PN_4 PN_6 PN_7)

*** For each of the indices create a correlation coefficient and Cronbach's alpha to measure the index's reliability: 

*Climate Change belief index
pwcorr scepticism_2 scepticism_6_r scepticism_7_r, sig 
alpha scepticism_2 scepticism_6_r scepticism_7_r

*Government intervention 
pwcorr cog_1 cog_2_r cog_3 cog_4 cog_5_r cog_6
alpha PN_1 PN_2 PN_3 PN_4 PN_6 PN_7
	
* Personal responsibility/pro_environment
pwcorr PN_1 PN_2 PN_3 PN_4 PN_6 PN_7, sig obs
alpha cog_1 cog_2_r cog_3 cog_4 cog_5_r cog_6

* For each group (DC and TWPL), create tables to summarize the distribution of the following variables (a separate table for each variable) in percentage

* Gender
tabulate sex abst_format, column nofreq

* Age
tabulate age abst_format, column nofreq

* Number of children
tabulate kids_nr abst_format, column nofreq

* Household net income
tabulate hhnetinc abst_format, column nofreq

* Environmental organization membership
tabulate member abst_format, column nofreq

* Education
tabulate education abst_format, column nofreq

   *** Create a separate summary table(mean, standard deviation, min, max) for each of the three indices based on the two groups of individuals (DC and TWPL) in order to compare attitude of the two groups

* Climate Belief
tabstat climate, ///
    by(abst_format) ///
    statistics(mean sd min max) ///
    columns(statistics)

ttest climate, by(abst_format)

	
* Government Intervention
tabstat gov_intervention, ///
    by(abst_format) ///
    statistics(mean sd min max) ///
    columns(statistics)
	
ttest gov_intervention, by(abst_format)
	
* Personal Responsibility
tabstat pro_environment, ///
    by(abst_format) ///
    statistics(mean sd min max) ///
    columns(statistics)
	
ttest pro_environment, by(abst_format)

*** Column chartS for WTP_plmin_euro and WTP_plmax_euro

graph bar (count), ///
    over(WTP_plmin_euro, label(angle(45))) ///
    ytitle("Number of respondents") ///
    title("Distribution of Minimum WTP (€)") ///
    blabel(bar)

* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\WTP_plmin_euro.png", replace


	
graph bar (count), ///
    over(WTP_plmax_euro, label(angle(45))) ///
    ytitle("Number of respondents") ///
    title("Distribution of Maximum WTP (€)") ///
    blabel(bar)
* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\WTP_plmax_euro.png", replace

* create new variable average_wtp as average of WTP_plmax_euro and WTP_plmin_euro per obs	
egen WTP_average = rowmean(WTP_plmax_euro WTP_plmin_euro)
	
* summary statistics of average_wtp
summarize WTP_average, detail 
	
* correlation matrix between WTP_average, demographic variables and indices 
pwcorr WTP_average climate gov_intervention pro_environment, sig obs


     ***Frequency table of DC_ref_outcome variable and costs as well as their proportion. Abstain treated as No in computing proportion.
	
preserve 
 
* Count observations by costs and DC_ref_outcome 
contract costs DC_ref_outcome 
 
* Remove missing values 
drop if missing(costs) | missing(DC_ref_outcome) 
 
* Recode the string categories 
replace DC_ref_outcome = "No" ///
    if DC_ref_outcome == "do not support referendum and no pay" 
 
replace DC_ref_outcome = "Yes" ///
    if DC_ref_outcome == "support referendum and pay" 
 
replace DC_ref_outcome = "Abstain" ///
    if DC_ref_outcome == "would not vote" 
 
* Put outcomes into separate columns 
reshape wide _freq, i(costs) j(DC_ref_outcome) string 
 
* Rename columns 
rename _freqNo No 
rename _freqYes Yes 
rename _freqAbstain Abstain 

* Calculate total respondents at each cost level
generate total = Abstain + No + Yes
generate total_without_Abstain = No + Yes

* Calculate proportion choosing No or Yes among those who
* either choose No or Yes (excluding Abstain)
generate prop_no = (No+Abstain) / (total)
generate prop_no_without_abstain = No / total_without_Abstain
generate prop_yes = Yes / (total)
generate prop_yes_without_abstain = Yes / total_without_Abstain

* Save the table as a separate dataset
save "WTP_DC.dta", replace

* Display final table
list costs Abstain No Yes total prop_no prop_yes, noobs
 
restore

   *** Make a line chart showing the `demand curve', with percentage of individuals who voted `yes' as the vertical axis variable and costs (in euros) as the horizontal axis variable.

use "WTP_DC.dta", clear

twoway ///
    (scatter prop_yes costs) ///
    (line prop_yes costs), ///
    ytitle("% Voting 'Yes'") ///
    xtitle("Amount (euros)") ///
    xlabel(0(100)1500, angle(45))///
    ylabel(0(.1)1) ///
    title("Proportion Voting 'Yes' by Cost") ///
    graphregion(color(white))

* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\DC_outcome_cost.png", replace
	
* Exclude individuals who chose to abstain from the calculation of proportion and plot new demand curve with the old demand curve.

twoway ///
    (scatter prop_yes costs) ///
    (line prop_yes costs) ///
    (scatter prop_yes_without_abstain costs) ///
    (line prop_yes_without_abstain costs), ///
    ytitle("% Voting 'Yes'") ///
    xtitle("Amount (euros)") ///
    xlabel(0(100)1500, angle(45)) ///
    ylabel(0(.1)1) ///
    title("Proportion Voting 'Yes' by Cost") ///
    legend(order(2 "Including Abstentions" 4 "Excluding Abstentions")) ///
    graphregion(color(white))

* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\DC_outcome_cost.png", replace
	
      *** Compute DC and TWPL format Willingness to pay variables and conduct ttest
	  
preserve

* Create DC_WTP matrix
mkmat costs if DC_ref_outcome == "support referendum and pay" & !missing(costs), ///
    matrix(DC_WTP)

* Create TWPL_WTP matrix
mkmat WTP_average if !missing(WTP_average), ///
    matrix(TWPL_WTP)

* Convert matrices to variables
svmat DC_WTP
svmat TWPL_WTP

* Save as a Stata dataset
save "WTP_matrices.dta", replace

restore

use "WTP_matrices.dta", clear
summarize DC_WTP TWPL_WTP, detail

* Obtain 95% confidence intervals for the difference of means for each question format. Discuss your findings.
ttest DC_WTP == TWPL_WTP


	****  Check distribution of paired samples and conduct test 

preserve

* Keep the paired WTP variables
keep id DC_WTP TWPL_WTP

* Retain complete pairs
keep if !missing(DC_WTP, TWPL_WTP)

* Calculate paired differences
generate WTP_diff = DC_WTP - TWPL_WTP

* Obtain detailed descriptive statistics
summarize WTP_diff, detail

* Store distribution statistics
local q1  = r(p25)
local med = r(p50)
local q3  = r(p75)
local sk  = r(skewness)

* Compare the distances around the median
display "Q1: " `q1'
display "Median: " `med'
display "Q3: " `q3'
display "Lower distance: " `med' - `q1'
display "Upper distance: " `q3' - `med'
display "Skewness: " `sk'

* Plot the distribution and mark the median
histogram WTP_diff, kdensity xline(`med') ///
    title("Distribution of Paired WTP Differences") ///
    xtitle("DC_WTP - TWPL_WTP") ///
    ytitle("Frequency")
	
* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\histogram_paired_wtp_diff.png", replace

* Examine the box plot
graph box WTP_diff, ///
    title("Box Plot of Paired WTP Differences") ///
    ytitle("DC_WTP - TWPL_WTP")
* Save graph
graph export "C:\Users\administrator1\OneDrive\W.I.P\Core Econs Project\R\wtp\figures\boxplot_paired_wtp_diff.png", replace
	
* Conduct the Wilcoxon signed-rank test
signrank DC_WTP = TWPL_WTP

restore
	


	
	
	
