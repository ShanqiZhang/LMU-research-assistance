*Date: Mar 22 2023
*Topic: data summary & analysis for DestructionResults
*Author: Christine Zhang

clear

*import data 
import excel "/Users/shanqizhang/Dropbox/Survey/DestructionResults.xlsx", sheet("Data") firstrow
drop in 1
drop in 97/102

*destring variables
destring Baselinedecision, replace
destring Create1decsn, replace
destring Create5decsn, replace

*********************Data Summary1********************************************
*ttest for mean of transfer in each treatment
*Trsfr diff of means
ttest Baselinedecision == Create1decsn, unpaired
ttest Create1decsn == Create5decsn, unpaired
ttest Baselinedecision == Create5decsn, unpaired
*Imptc diff of means
ttest Baselineimptc == Create1imptc, unpaired
ttest Create1imptc == Create5imptc, unpaired
ttest Baselineimptc == Create5imptc, unpaired
*% trsfr>0 diff of prop
prtesti 34 0 30 0.6667
prtesti 30 0.6667 32 0.75
prtesti 34 0 32 0.75
*% trsfr>=0 diff of prop
prtesti 34 0.794118 30 0.8
prtesti 30 0.8 32 0.90625
prtesti 34 0.794118 32 0.90625
*% imptc>0 diff of prop
prtesti 34 0.882353 30 0.7
prtesti 30 0.7 32 0.875
prtesti 34 0.882353 32 0.875
*% imptc>3 diff of prop
prtesti 34 0.470588 30 0.3 
prtesti 30 0.3 32 0.40625 
prtesti 34 0.470588 32 0.40625
*% imptc>=3 diff of prop
prtesti 34 0.558824 30 0.5
prtesti 30 0.5 32 0.65625
prtesti 34 0.558824 32 0.65625

**********STEP1: DATA CLEANING & CREATING VARIABLES*******************

*create the 'treatment' variable, fill all with  value 2 first
gen Treatment = 99
*replace 'treatment' values with the correct treatment values
replace Treatment =0 if Baselinedecision != .
replace Treatment =1 if Create1decsn != .
replace Treatment =5 if Create5decsn != .
*make sure all values are replaced and processed in 'treatment'
count if Treatment == 99

*creat the 'ln_t_plus_1'variable, its value = Ln(value of treatment +1)
gen ln_t_plus_1 = ln1p(Treatment)

*similarly, create the 'Transfer' variable that indicates the amout each respondant chose to transfer (negative value if they choose to take away)
gen Decision = 99
replace Decision = Baselinedecision if Baselinedecision !=.
replace Decision = Create1decsn if Create1decsn!=.
replace Decision = Create5decsn if Create5decsn!=.
count if Decision == 99

*similarly, create the 'Give' variable that has a value of 1 if respodant transferred a positive amount, otherwise value is 0.
gen Give = 99
replace Give = 1 if Decision >0
replace Give = 0 if Decision <=0
count if Give == 99

*creat the 'Censored_Decision' variable, it equals the value of the transfer, if it is negative but is equal to zero otherwise.
gen Censored_Decision = (-Give+1) * Decision

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
reg Decision Treatment, robust
display e(r2_a)

*6th regression: Transfer = a + b1*ln_t_plus_1[ln(t+1)]
reg Decision ln_t_plus_1, robust
display e(r2_a)

*7th regression: Transfer = a + b1*Treatment[t] + b2*ln_t_plus_1[ln(t+1)]
reg Decision Treatment ln_t_plus_1, robust
display e(r2_a)

*8th regression: Transfer = a + b1*Treatment + b2*t_sq
reg Decision Treatment t_sq, robust
display e(r2_a)

*******************************************************
*1st tobit regression: LHS=Censored_t, RHS=Treatment(t)
tobit Censored_Decision Treatment, ll(-10) ul(0)

*2nd tobit regression: LHS=Censored_t, RHS=ln(t+1)
tobit Censored_Decision ln_t_plus_1, ll(-10) ul(0)

*3rd tobit regression: LHS=Censored_t, RHS=Treatment, ln(t+1)
tobit Censored_Decision Treatment ln_t_plus_1, ll(-10) ul(0)

*4th tobit regression: LHS=Censored_t, RHS=Treatment(t), t_sq
tobit Censored_Decision Treatment t_sq, ll(-10) ul(0)

*********************DATA SUMMARY2******************************************

*generate a inportance score variable 
gen imptc= 99
replace imptc = Baselineimptc if Baselineimptc!=.
replace imptc = Create1imptc if Create1imptc!=.
replace imptc = Create5imptc if Create5imptc!=.
count if imptc==99

*conduct spearman correlation 
spearman imptc Decision
spearman imptc Treatment

*conduct fisher's exact test
gen Nonnegative = 99
replace Nonnegative = 1 if Decision >=0
replace Nonnegative = 0 if Decision <0
count if Nonnegative == 99
tabulate Nonnegative Treatment,row chi exact

*One tail test: Difference % importance give5>give1+take
prtesti 32 0.656250 64 0.531250

