* Date: 2023 Mar 17
* Topic:regression for DestructionResults
* Editor: Shanqi Zhang

clear
*********STEP1: DATA CLEANING & CREATING VARIABLES*******************
*import origional excel
import excel "/Users/shanqizhang/Dropbox/DataAnalysis&Graphs/DestructionResults.xlsx", sheet("Data") firstrow

*drop the firstrow(data doscription)
drop in 1

*drop row because they contain gaps and two observations that dropped out of study because they failed to answer the first two qiestions, therefore no giving data has been recorded.
drop in 95/120
*rename vars for convenience
rename AA Give5transfer
rename AC Give1imptc
rename AD Give5imptc
rename Z Give1transfer
rename Baselinedecision Baselinetransfer

*change the type of data in all treatment & control groups
destring Give1transfer, replace
destring Give5transfer, replace
destring Baselinetransfer, replace
destring Give1imptc, replace
destring Give5imptc, replace
destring Baselineimptc, replace

*create the 'treatment' variable, fill all with  value 2 first
gen Treatment = 99
*replace 'treatment' values with the correct treatment values
replace Treatment =0 if Baselinetransfer != .
replace Treatment =1 if Give1transfer != .
replace Treatment =5 if Give5transfer != .

*creat the 'ln_t_plus_1'variable, its value = Ln(value of treatment +1)
gen ln_t_plus_1 = ln1p(Treatment)

*similarly, create the 'Transfer' variable that indicates the amout each respondant chose to transfer (negative value if they choose to take away)
gen Transfer = 99
replace Transfer = Baselinetransfer if Baselinetransfer !=.
replace Transfer = Give1transfer if Give1transfer !=.
replace Transfer = Give5transfer if Give5transfer !=.
count if Transfer == 99

gen Give = 0
replace Give = 1 if Transfer >0
*creat the 'Censored_t' variable, all positive values are set equal to zero, and they are right censored at zero.
gen Censored_t = (1-Give) * Transfer

*creat the t_sq variable, its value = Treatment*Treatment
gen t_sq = Treatment^2

**********STEP2: RUNNING REGRESSIONS**********************************

*1st regression: Give[I] = a + b1*Treatment[t]
reg Give Treatment, robust
display e(r2_a)
 
*2nd regression: Give[I] = a + b1*ln_t_plus_1[ln(t+1)]
reg Give ln_t_plus_1, robust
display e(r2_a)

*3rd regression: Give[I] = a + b1*Treatment[t] + b2*ln_t_plus_1[ln(t+1)]
reg Give Treatment ln_t_plus_1, robust
display e(r2_a)

*4th regression: Give = a + b1*Treatment + b2*t_sq
reg Give Treatment t_sq, robust
display e(r2_a)

*5th regression: Transfer = a + b1*Treatment[t]
reg Transfer Treatment, robust
display e(r2_a)

*6th regression: Transfer = a + b1*ln_t_plus_1[ln(t+1)]
reg Transfer ln_t_plus_1, robust
display e(r2_a)

*7th regression: Transfer = a + b1*Treatment[t] + b2*ln_t_plus_1[ln(t+1)]
reg Transfer Treatment ln_t_plus_1, robust
display e(r2_a)

*8th regression: Transfer = a + b1*Treatment + b2*t_sq
reg Transfer Treatment t_sq, robust
display e(r2_a)
*******************************************************

*1st tobit regression: LHS=Censored_t, RHS=Treatment(t)
tobit Censored_t Treatment, ul(0) 

*2nd tobit regression: LHS=Censored_t, RHS=ln(t+1)
tobit Censored_t ln_t_plus_1, ul(0) 

*3rd tobit regression: LHS=Censored_t, RHS=Treatment, ln(t+1)
tobit Censored_t Treatment ln_t_plus_1, ul(0) 

*4th tobit regression: LHS=Censored_t, RHS=Treatment(t), t_sq
tobit Censored_t Treatment t_sq, ul(0) 


*******PART3: GENERATE SPEARMAN CORRELATION COEFFICIENT***********************

*destring the impotance-related vairables
destring Baselineimptc, replace
destring Give1imptc, replace
destring Give5imptc,replace

*generate a inportance score variable 
gen imptc= 99
replace imptc = Baselineimptc if Baselineimptc!=.
replace imptc = Give1imptc if Give1imptc!=.
replace imptc = Give5imptc if Give5imptc!=.
count if imptc==99

*conduct spearman correlation 
spearman imptc Transfer
spearman imptc Treatment

*conduct fisher's exact test
tabulate Give Treatment,row chi exact

*One tail test: Difference % importance give5>give1+take
prtesti 32 0.71875 62 0.580645
prtesti 30 0.4 60 0.183333
