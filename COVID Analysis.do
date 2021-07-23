
** Formatting settings & directories
********************************************************************************
local graphfont "Calibri"
graph set eps fontface `graphfont'
graph set eps fontfaceserif `graphfont'
graph set eps fontfacesans `graphfont'

graph set window fontface `graphfont'
graph set window fontfaceserif `graphfont'
graph set window fontfacesans `graphfont'

global data "/Users/temery/surfdrive/Moldova" // Change directory to local
global folder "/Users/temery/Documents/GitHub/GGSMoldovaCOVID" // Change directory to local working directory

set scheme plottig

** Open file and define sample
********************************************************************************

use "$data/GGP2020_WAVE1_MLD_V_0_2.dta", clear

keep if inrange(age,18,49) & corespartner == 1 // Restriction of sample to 18-49 and those with a co-resident partner.

gen covid = 0
replace covid = 1 if intdatem > 4 // Seperation of the sample into pre and post lockdown with May 1st taken as the cut off date.
rename sex asex


** Data cleaning and clarifications
********************************************************************************

lab def fer12_ 3501 "Sponge" 3502 "Hormonal Patch" 3503 "LAM" 9991 "None of the above", add modify  // Adding country specific labels to the variable fer12_
replace cov01 = . if cov01 == 93
lab var age "Age"


** Generating the Dependent Variables
********************************************************************************

gen fert = 0 if !missing(fer14)
replace fert = 1 if inlist(fer14,4,5) // Fertility intention defined as probably or defintely intending to have a child in the next 3 years.

gen trying = 0 if !missing(fer10a)
replace trying = 1 if fer10a == 1 // Trying to conceive defined as someone responding Yes to the question of whether they are trying to conceive.

gen hadsex = fer13
recode hadsex (2 = 0) // Sexually active defined as someone who said yes when asked if they had been sexually active in the last 4 weeks.

foreach x in a b c d e f g h i j k l m n o p { // creating variables that mark use of a specific contraceptive method. Note that respondents may use more than one method.
	gen fer12`x' = .
}

forval x=1(1)16 {
replace fer12a=1 if fer12_`x'==1
replace fer12b=1 if fer12_`x'==2
replace fer12c=1 if fer12_`x'==3
replace fer12d=1 if fer12_`x'==4
replace fer12e=1 if fer12_`x'==5
replace fer12f=1 if fer12_`x'==6
replace fer12g=1 if fer12_`x'==7
replace fer12h=1 if fer12_`x'==8
replace fer12i=1 if fer12_`x'==9
replace fer12j=1 if fer12_`x'==10
replace fer12k=1 if fer12_`x'==11
replace fer12l=1 if fer12_`x'==12
replace fer12m=1 if fer12_`x'==13
replace fer12n=1 if fer12_`x'==3501
replace fer12o=1 if fer12_`x'==3502
replace fer12p=1 if fer12_`x'==3503
}

lab var fer12a "Male condom"
lab var fer12b "Pills"
lab var fer12c "IUD"
lab var fer12d "Diaphragm"
lab var fer12e "Foam"
lab var fer12f "Injectables"
lab var fer12g "Implants"
lab var fer12h "Persona"
lab var fer12i "Emergency contraceptives"
lab var fer12j "Withdrawal"
lab var fer12k "Save Period Method"
lab var fer12l "Vaginal ring"
lab var fer12m "Female condom"
lab var fer12n "Sponge"
lab var fer12o "Hormonal patch"
lab var fer12p "LAM"

// Classification of methods based on United Nations standards, including the use of sterilization as measured by fer06 & fer09. Note that the methods are hierarchical. If a respondent uses both traditional and modern forms of contraceptive use, they are classified as using modern methods.

gen method=. 
	replace method=1 if fer06==1 & method==.
	replace method=2 if fer09==1 & method==.
	replace method=3 if fer12c==1 & method==.
	replace method=4 if fer12f==1 & method==.
	replace method=5 if fer12g==1 & method==.
	replace method=6 if (fer12b==1 | fer12o==1) & method==.
	replace method=7 if fer12i==1 & method==.
	replace method=8 if fer12a==1 & method==.
	replace method=9 if fer12m==13 & method==.
	replace method=10 if (fer12d==1 | fer12l==1) & method==.
	replace method=11 if (fer12e==1 | fer12n==1) & method==.
	replace method=12 if fer12p==1 & method==.
	replace method=13 if fer12k==1 & method==.
	replace method=14 if fer12h==1 & method==.				
	replace method=15 if fer12j==1 & method==.
	replace method=.c if fer01a==1 & method==.	
	replace method=0 if fer12_1 == 0 | (fer12_1==. & method==.)
	replace method=.a if fer12_1==.a & method==.
	replace method=.b if fer12_1==.b & method==.

	lab def method 0 "No use" 1 "Female sterilization" 2 "Male sterilization" 3 "IUD" 4 "Injectables" 5 "Implants" 6 "Pill" ///
	7 "Emergency contraception" 8 "Condom" 9 "Female condom" 10 "Diaphragm, cervical cap" 11 "Spermicidal foam, jelly, cream or sponge" ///
	12 "LAM" 13 "Save Period Method/Rhythm" 14 "Persona" 15 "Withdrawal" .a "Don't know" .b "Refusal" .c "NA - pregnant"
	lab val method method	
	
gen method_gr=method
	recode method_gr (0=0) (1 2 3 4 5 6 7 8 9 10 11 = 1) (12 13 14 15 = 2) // Seperation of methods into modern and traditionl
	lab def method_gr 0 "No use" 1 "Modern method" 2 "Traditional method" .a "Don't know" .b "Refusal" .c "NA - pregnant"
	lab val method_gr method_gr

gen mcu = 0 if !missing(method) 
replace mcu = 1 if inlist(method_gr,1)
lab var mcu "Contraceptive Use"
lab def mcu 0 "None used" 1 "Contraceptives used"
lab val mcu mcu


foreach x in fer12a fer12b fer12c fer12m fer12o fer12p {
	recode `x' (. = 0) if !missing(method)
}
	

** Generating the Independent Variables
********************************************************************************

recode asex (2 = 0)

gen educ = 0
replace educ = 1 if inlist(dem07,6,7,8) // education dichotomized into further education and non-further education

gen employ = 0 
replace employ = 1 if inlist(dem06,2,3,4,9,10,7) // self reported employment status dichotimized into working v non-working

gen inchit = 0
replace inchit = 1 if inlist(cov02f,4,5) // respondent indicated that the pandemic very or somewhet negatively affected household income

recode rep01 (2 = 0) // variable indicating whether others were present at the time of the interview

recode rep05 (0 1 2 3 4 5 6 7 8 9 = 0) (10 = 1) // Collapsing willingness to respond to questions to a dichotomous variable as its highly skewed

lab var asex "Sex of Respondent [Ref = Female]"
lab var coreskids "Number of Coresident Children"
label var rep01 "Others present"
label var educ "Education Level"
label var employ "Employment Status"
label var urban "Urban Resident"
label var inchit "Drop in Income"
label var trying "Trying to Conceive"
label var hadsex "Had intercourse"
label var fert "Fertility Intention"
label var covid "Post April 2020"
label var rep05 "Willingness to answer"

lab def covid 0 "Pre Lockdown" 1 "Post Lockdown"
lab val covid covid

lab def educ 0 "No Tertiary Education" 1 "Tertiary Education"
lab val educ educ

lab def employ 0 "Not Working" 1 "Working"
lab val employ employ

lab def others 0 "Interviewed Alone" 1 "Others Present", add modify
lab val rep01 others


** Descriptives
********************************************************************************

eststo clear
by covid, sort: eststo: quietly estpost summarize ///
    hadsex mcu trying fert
esttab using "$folder/tab1.tex", cells("mean(fmt(3)) sd(fmt(3))") label nodepvar title("Dependent Variables") replace

eststo clear
by covid, sort: eststo: quietly estpost summarize ///
    age asex educ employ coreskids urban rep05
esttab using "$folder/tab2.tex", cells("mean(fmt(3)) sd(fmt(3))") label nodepvar title("Independent Variables") replace 

by covid, sort: corr hadsex trying mcu fert

** Analysis
********************************************************************************

eststo clear
eststo: logit hadsex i.covid c.age i.asex c.coreskids i.educ i.employ i.urban i.rep05 i.rep01 [iweight = weight]
eststo: logit mcu i.covid c.age i.asex c.coreskids i.educ i.employ i.urban i.rep05 i.rep01  [iweight = weight]
eststo: logit mcu i.covid##i.urban  c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01  [iweight = weight]
margins covid, by(urban) // for reporting purposes
eststo: logit trying  i.covid c.age i.asex c.coreskids i.educ i.employ i.urban i.rep05 i.rep01  [iweight = weight]
eststo: logit fert i.covid c.age i.asex c.coreskids i.educ i.employ i.urban i.rep05 i.rep01  [iweight = weight]
eststo: logit fert i.covid##inchit c.age i.asex c.coreskids i.educ i.employ i.urban i.rep05 i.rep01  [iweight = weight]

esttab using "$folder/tab3.tex", label nobaselevels interaction(" X ") replace mtitles("Had sex" "CU" "CU" "Trying" "Intention" "Intention") title("Results of logistic regression on pre \& post population [Log Odds]")


eststo clear
eststo: logit fer12a i.covid c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01 i.urban##i.covid  [iweight = weight]
quietly margins, by(urban covid) saving(mcondom, replace)
eststo: logit fer12b i.covid c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01 i.urban##i.covid  [iweight = weight]
quietly margins,  by(urban covid) saving(pills, replace)
eststo: logit fer12c i.covid c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01 i.urban##i.covid  [iweight = weight]
quietly margins,  by(urban covid) saving(IUD, replace)
eststo: logit fer12m i.covid c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01 i.urban##i.covid  [iweight = weight]
quietly margins,  by(urban covid) saving(fcondom, replace)
eststo: logit fer12o i.covid c.age i.asex c.coreskids i.educ i.employ i.rep05 i.rep01 i.urban##i.covid  [iweight = weight]
quietly margins,  by(urban covid) saving(patch, replace)

combomarginsplot mcondom pills IUD fcondom patch, offset(-0.2) recast(scatter) horizontal yscale(lwidth(0pt)  titlegap(5)) ylab(1 "Male Condom" 2 "Pills" 3 "IUD" 4 "Female Condom" 5 "Patch", noticks  labgap(15)) graphregion(color(white)) ytitle("Contraceptive Method") xtitle("") title("Marginal Effects at the Mean" "Proportion of the population aged 18-49 using method") xlab(0(.1).5) legend(order(1 "Rural, pre-lockdown" 2 "Rural, post-lockdown" 3 "Urban, pre-lockdown" 4 "Urban, post-lockdown") pos(7) region(lcolor(white)) forcesize rows(1) colgap(25) symx(.5))
graph export "$folder/fig4.png", replace


** Creating Figure 3
********************************************************************************


gen month = intdatem
recode month (1 = 2) (4 6 = 3)

label def month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", add modify
lab val month month
drop if month == 12

preserve

** Had Sex
collapse (mean) m_sex = hadsex (sd) sd_sex = hadsex (count) n = hadsex, by(month)
generate hi_sex = m_sex + invttail(n-1,0.025)*(sd_sex / sqrt(n))
generate low_sex = m_sex - invttail(n-1,0.025)*(sd_sex / sqrt(n))

graph twoway (rcap hi_sex low_sex month, color(gs10)) (scatter m_sex month, color("0 125 129")) , graphregion(color(white)) legend(off) xtitle("") ytitle("Proportion") xlab(1(1)12, val angle(90) labgap(14) notick glcolor(gs14)) ylab(0(0.1)1, notick) xscale(lcolor(gs14)) yscale(lcolor(white)) caption("c) Had sex in the last 4 weeks")
graph save had_sex, replace 

** Contraceptive

restore
preserve

collapse (mean) m_mcu = mcu (sd) sd_mcu = mcu (count) n = mcu, by(month)
generate hi_mcu = m_mcu + invttail(n-1,0.025)*(sd_mcu / sqrt(n))
generate low_mcu = m_mcu - invttail(n-1,0.025)*(sd_mcu / sqrt(n))

graph twoway (rcap hi_mcu low_mcu month, color(gs10)) (scatter m_mcu month, color("0 125 129")) , graphregion(color(white)) legend(off) xtitle("") ytitle("Proportion") xlab(1(1)12, val angle(90) labgap(14) notick glcolor(gs14)) ylab(0(0.1)1, notick) xscale(lcolor(gs14)) yscale(lcolor(white)) caption("b) Contraceptive Use")
graph save cont, replace


** Trying

restore
preserve

collapse (mean) m_try = trying (sd) sd_try = trying (count) n = try, by(month)
generate hi_try = m_try + invttail(n-1,0.025)*(sd_try / sqrt(n))
generate low_try = m_try - invttail(n-1,0.025)*(sd_try / sqrt(n))

graph twoway (rcap hi_try low_try month, color(gs10)) (scatter m_try month, color("0 125 129")) , graphregion(color(white)) legend(off) xtitle("") ytitle("Proportion") xlab(1(1)12, val angle(90) labgap(14) notick glcolor(gs14)) ylab(0(0.1)1, notick) xscale(lcolor(gs14)) yscale(lcolor(white)) caption("a) Trying to Conceive")
graph save trying, replace


** Intentions 

restore

collapse (mean) m_fert = fert (sd) sd_fert = fert (count) n = fert, by(month)
generate hi_fert = m_fert + invttail(n-1,0.025)*(sd_fert / sqrt(n))
generate low_fert = m_fert - invttail(n-1,0.025)*(sd_fert / sqrt(n))

graph twoway (rcap hi_fert low_fert month, color(gs10)) (scatter m_fert month, color("0 125 129")) , graphregion(color(white)) legend(off) xtitle("") ytitle("Proportion") xlab(1(1)12, val angle(90) labgap(14) notick glcolor(gs14)) ylab(0(0.1)1, notick) xscale(lcolor(gs14)) yscale(lcolor(white)) caption("d) Intends to have a child in the next 3 years")
graph save fert, replace

graph combine trying.gph cont.gph had_sex.gph fert.gph, row(2) graphregion(color(white))
graph export "$folder/fig3.png", replace 
