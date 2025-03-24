* Change pat_mrn_id to uppercase in subset for querying
rename pat_mrn_id PAT_MRN_ID

* Create and load the smaller dataset into a frame
frame create smaller
frame smaller: use "C:\Users\coule\OneDrive - Bentley University\Summer 2024 Chow\Harvard Data\Admits Psychosis 18-35 Subset.dta"
frame smaller: sort PAT_MRN_ID

* temp_larger_data.dta was created to change dx1 from a double to a string and to remove all duplicates of PAT_MRN_ID's for 1:1 merging
tostring dx1, replace
by PAT_MRN_ID, sort: keep if _n == 1

* Create and load the larger dataset into another frame
frame create larger
frame larger: use "C:\Users\coule\OneDrive - Bentley University\Summer 2024 Chow\Harvard Data\temp_larger_data.dta"
frame larger: sort PAT_MRN_ID

* Switch back to the main frame (default frame)
frame change smaller

* Merge with the temporary file saved from the larger frame
merge 1:1 PAT_MRN_ID using temp_larger_data.dta, keep(match master) nogenerate

* Replace race = Other with race from larger dataset
replace race_unmatched = race if race_unmatched == "Other"
replace race_unmatched = "Other" if race_unmatched == ""

* Replace race = Unknown with race from larger dataset
replace race_unmatched = race if race_unmatched == "Unknown"
replace race_unmatched = "Unknown" if race_unmatched == ""

* Rename race_unmatched to race_adjusted
rename race_unmatched race_adjusted

* Check for discrepancies in merged dataset
browse PAT_MRN_ID race_adjusted race Ethnicity EthnicGroup

browse PAT_MRN_ID race_adjusted race Ethnicity EthnicGroup if race_adjusted == "Other" & race == ""

browse PAT_MRN_ID race_adjusted race Ethnicity EthnicGroup if race_adjusted == "Black" & race == "White"

browse PAT_MRN_ID race_adjusted race Ethnicity EthnicGroup if race_adjusted == "White" & race == "Black"

* Check results for smaller adjusted dataset
tabulate race_adjusted

* Check results for smaller unmatched dataset
tabulate race_unmatched

* Check results for larger dataset
tabulate race

browse PAT_MRN_ID race_adjusted race Ethnicity EthnicGroup if ccHomlessness ==.

* RENAMED: 
rename Discharge_Meds_Antipsychotic_Rev Antipsych_Med_Rev
rename Discharge_Medications_Mood_Rev Mood_Stab_Med_Rev
rename Discharge_Meds_Benzo_Rev Benzo_Med_Rev

* Noticed 3 patients did not have reported value for antipsychotics
browse PAT_MRN_ID discharge_medication_antipsychot discharge_medication_mood_stabli discharge_med_benzo if discharge_medication_antipsychot == ""

* Create Variable Discharge_Meds_Antipsychotic_Rev
browse PAT_MRN_ID discharge_medication_antipsychot Antipsych_Med_Rev 
tabulate discharge_medication_antipsychot
tabulate Antipsych_Med_Rev 

gen Discharge_Meds_Antipsychotic_Rev = . 

* 0 = None
replace Discharge_Meds_Antipsychotic_Rev = 0 if discharge_medication_antipsychot == "none"

* 1 = First generation antipsychotics: perphenazine, thorazine (chlorpromazine), haldol (haloperidol), fluphenazine, chlorproazine, loxapine
replace Discharge_Meds_Antipsychotic_Rev = 1 if strpos(lower(trim(discharge_medication_antipsychot)), lower("perphenazine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("thorazine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("chlorpromazine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("haldol")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("haloperidol")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("fluphenazine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("chlorproazine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("loxapine")) > 0 

* 2 = Second generation antipsychotics: Zyprexa, olanzapine, geodon (ziprasidone), risperidone, risperdal, quetiapine, seroquel, paliperidone, ziprazidone, abilify, aripiprozole, lurasidone (latuda)
replace Discharge_Meds_Antipsychotic_Rev = 2 if strpos(lower(trim(discharge_medication_antipsychot)), lower("zyprexa")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("olanzapine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("geodon")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("risperidone")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("risperdal")) > 0 |strpos(lower(trim(discharge_medication_antipsychot)), lower("quetiapine")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("seroquel")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("paliperidone")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("ziprazidone")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("abilify")) > 0 | strpos(lower(trim(discharge_medication_antipsychot)), lower("aripiprozole")) > 0

* 3 = Clozapine, Clozaril
replace Discharge_Meds_Antipsychotic_Rev = 3 if strpos(lower(trim(discharge_medication_antipsychot)), lower("clozapine")) > 0 

* This medication was not prescribed to any patients in the subset
replace Discharge_Meds_Antipsychotic_Rev = 3 if strpos(lower(trim(discharge_medication_antipsychot)), lower("clozaril")) > 0

* Create Variable Discharge_Medications_Mood_Rev
browse PAT_MRN_ID discharge_medication_mood_stabli Mood_Stab_Med_Rev
tabulate discharge_medication_mood_stabli
tabulate Mood_Stab_Med_Rev

gen Discharge_Medications_Mood_Rev = . 

* 0 = None
replace Discharge_Medications_Mood_Rev = 0 if discharge_medication_mood_stabli == "none"

* 1 = Depakote and all of the multiple divalproex's as 1 category
replace Discharge_Medications_Mood_Rev = 1 if strpos(lower(trim(discharge_medication_mood_stabli)), lower("depakote")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("divalproex")) > 0

* 2 = a second category with all other mood stabilizers: including lithium, trileptal, lamotrigine, lamictil, oxycarbemazepine, carbamazepine
replace Discharge_Medications_Mood_Rev = 2 if strpos(lower(trim(discharge_medication_mood_stabli)), lower("lithium")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("trileptal")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("lamotrigine")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("lamictil")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("oxycarbemazepine")) > 0 | strpos(lower(trim(discharge_medication_mood_stabli)), lower("carbamazepine")) > 0

* Create Variable Discharge_Meds_Benzo_Rev
browse PAT_MRN_ID discharge_med_benzo Benzo_Med_Rev
tabulate discharge_med_benzo
tabulate Benzo_Med_Rev

gen Discharge_Meds_Benzo_Rev = . 

* 1 = Any mention of benzos
replace Discharge_Meds_Benzo_Rev = 1 if strpos(lower(trim(discharge_med_benzo)), lower("klonopin")) > 0 | strpos(lower(trim(discharge_med_benzo)), lower("lorazepam")) > 0 

* 0 = all else (none)
replace Discharge_Meds_Benzo_Rev = 0 if discharge_med_benzo == "none"

* Create Variable Homicide_Rev
browse PAT_MRN_ID Homicidal_Ideation Homicide_Rev
tabulate Homicidal_Ideation   
tabulate Homicide_Rev

gen Homicide_Rev = . 
replace Homicide_Rev = 0 if strpos(lower(trim(Homicidal_Ideation)), lower("no")) > 0 
replace Homicide_Rev = 1 if strpos(lower(trim(Homicidal_Ideation)), lower("yes")) > 0

* Create Variable Restraint_Rev
browse PAT_MRN_ID inpatient_restraints Restraint_Rev
tabulate tabulate inpatient_restraints  
tabulate Restraint_Rev

gen Restraint_Rev = . 
replace Restraint_Rev = 0 if strpos(lower(trim(inpatient_restraints)), lower("no")) > 0 
replace Restraint_Rev = 1 if strpos(lower(trim(inpatient_restraints)), lower("yes")) > 0

* Create Variable Suicide_Attempt_Hosp_Rev
browse PAT_MRN_ID suicide_attempts_index_hosp Suicide_Attempt_Hosp_Rev
tabulate suicide_attempts_index_hosp 
tabulate Suicide_Attempt_Hosp_Rev

gen Suicide_Attempt_Hosp_Rev = . 
replace Suicide_Attempt_Hosp_Rev = 0 if strpos(lower(trim(suicide_attempts_index_hosp)), lower("no")) > 0 
replace Suicide_Attempt_Hosp_Rev = 1 if strpos(lower(trim(suicide_attempts_index_hosp)), lower("yes")) > 0

* Create Variable Suicide_Ideation_Hosp_Rev
browse PAT_MRN_ID suicidal_ideation_index_hosp Suicide_Ideation_Hosp_Rev
tabulate suicidal_ideation_index_hosp
tabulate Suicide_Ideation_Hosp_Rev

gen Suicide_Ideation_Hosp_Rev = . 
replace Suicide_Ideation_Hosp_Rev = 0 if strpos(lower(trim(suicidal_ideation_index_hosp)), lower("no")) > 0 
replace Suicide_Ideation_Hosp_Rev = 1 if strpos(lower(trim(suicidal_ideation_index_hosp)), lower("yes")) > 0

* Create Variable Suicide_Att_Pre_Hosp_Rev
browse PAT_MRN_ID suicide_attempts_lifetime_pre_ho Suicide_Att_Pre_Hosp_Rev
tabulate suicide_attempts_lifetime_pre_ho
tabulate Suicide_Att_Pre_Hosp_Rev

gen Suicide_Att_Pre_Hosp_Rev = . 
replace Suicide_Att_Pre_Hosp_Rev = 0 if strpos(lower(trim(suicide_attempts_lifetime_pre_ho)), lower("no")) > 0 
replace Suicide_Att_Pre_Hosp_Rev = 1 if strpos(lower(trim(suicide_attempts_lifetime_pre_ho)), lower("yes")) > 0

* Create Variable Suicide_Idea_Pre_Hosp_Rev
browse PAT_MRN_ID suicidal_ideation_lifetime_pre_h Suicide_Idea_Pre_Hosp_Rev
tabulate suicidal_ideation_lifetime_pre_h
tabulate Suicide_Idea_Pre_Hosp_Rev

gen Suicide_Idea_Pre_Hosp_Rev = . 
replace Suicide_Idea_Pre_Hosp_Rev = 0 if strpos(lower(trim(suicidal_ideation_lifetime_pre_h)), lower("no")) > 0 
replace Suicide_Idea_Pre_Hosp_Rev = 1 if strpos(lower(trim(suicidal_ideation_lifetime_pre_h)), lower("yes")) > 0

* Create Variable Ref_Rise_Rev
browse PAT_MRN_ID ref_to_RISE Ref_Rise_Rev
tabulate ref_to_RISE
tabulate Ref_Rise_Rev

gen Ref_Rise_Rev = . 
replace Ref_Rise_Rev = 0 if strpos(lower(trim(ref_to_RISE)), lower("no")) > 0 
replace Ref_Rise_Rev = 1 if strpos(lower(trim(ref_to_RISE)), lower("yes")) > 0

* Create LOS Variable
browse PAT_MRN_ID HOSP_ADMSN_TIME HOSP_DISCH_TIME

* Create Admit and Discharge Variables:
* Convert string datetime variables to Stata datetime format
gen Admit_Date = dofc(HOSP_ADMSN_TIME)
gen Discharge_Date = dofc(HOSP_DISCH_TIME)

* Format the new date variables to display as dates
format Admit_Date %td
format Discharge_Date %td

* Create LOS variable
gen LOS = Discharge_Date - Admit_Date

* Check Result
browse PAT_MRN_ID HOSP_ADMSN_TIME HOSP_DISCH_TIME Admit_Date Discharge_Date LOS

* Create Days_To_Death_Post_Hosp Variable
* Convert string datetime variables to Stata datetime format
gen Discharge_Date = dofc(HOSP_DISCH_TIME)
gen Death_Date = date(date_of_death, "DMY")

* Format the new date variables to display as dates
format Discharge_Date %td
format Death_Date %td

* Create Days_To_Death_Post_Hosp variable
gen Days_To_Death_Post_Hosp = Death_Date - Discharge_Date

* Check Result
browse PAT_MRN_ID Discharge_Date Death_Date Days_To_Death_Post_Hosp
browse PAT_MRN_ID race_adjusted Discharge_Date Death_Date Days_To_Death_Post_Hosp if Days_To_Death_Post_Hosp !=.

* Create Qualify_Rise_Rev variable
browse PAT_MRN_ID qual_for_RISE Qualify_Rise_Rev Ref_Rise_Rev
browse PAT_MRN_ID qual_for_RISE Qualify_Rise_Rev Ref_Rise_Rev if qual_for_RISE == "unknown"
tabulate qual_for_RISE
tabulate Qualify_Rise_Rev

gen Qualify_Rise_Rev = . 
replace Qualify_Rise_Rev = 0 if strpos(lower(trim(qual_for_RISE)), lower("no")) > 0 | strpos(lower(trim(qual_for_RISE)), lower("out of state")) > 0
replace Qualify_Rise_Rev = 1 if strpos(lower(trim(qual_for_RISE)), lower("yes")) > 0

* Tests

* Fisher's Exact Test
tabulate Antipsych_Med_Rev race_adjusted, exact
tabulate Mood_Stab_Med_Rev race_adjusted, exact

* Statistically significant with 0.037 p-value
tabulate Benzo_Med_Rev race_adjusted, exact

tabulate Homicide_Rev race_adjusted, exact
tabulate Substances race_adjusted, exact
tabulate Restraint_Rev race_adjusted, exact
tabulate Suicide_Attempt_Hosp_Rev race_adjusted, exact
tabulate Suicide_Ideation_Hosp_Rev race_adjusted, exact
tabulate Suicide_Att_Pre_Hosp_Rev race_adjusted, exact
tabulate Suicide_Idea_Pre_Hosp_Rev race_adjusted, exact
tabulate Ref_Rise_Rev race_adjusted, exact
tabulate Qualify_Rise_Rev race_adjusted, exact

* Post-hoc Fisher's Exact Test for Benzos comparing with White (try comparing with black)
* p-values based on Bonferroni-corrected pairwise technique (5 possible pairs = 0.05/5 = 0.01)
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "White" | race_adjusted == "Asian", exact
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "White" | race_adjusted == "Black", exact

* Resulted with 0.002 which is significant at 0.01
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "White" | race_adjusted == "Hispanic", exact

tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "White" | race_adjusted == "Other/Unknown", exact
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "White" | race_adjusted == "Portuguese", exact

* Post-hoc Fisher's Exact Test for Benzos comparing with Black
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "Black" | race_adjusted == "Asian", exact
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "Black" | race_adjusted == "White", exact

* Resulted with  0.033 which is not significant at 0.01
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "Black" | race_adjusted == "Hispanic", exact

tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "Black" | race_adjusted == "Other/Unknown", exact
tabulate race_adjusted Benzo_Med_Rev if race_adjusted == "Black" | race_adjusted == "Portuguese", exact

*DID NOT YIELD SIGNIFICANT P_VALUE
* Kruskal Wallis Test
kwallis LOS, by(race_adjusted)

* Summary Statistics

* Define the list of categorical/binary variables
local vars Sex Antipsych_Med_Rev Mood_Stab_Med_Rev Benzo_Med_Rev Homicide_Rev Restraint_Rev Suicide_Attempt_Hosp_Rev Suicide_Ideation_Hosp_Rev Suicide_Att_Pre_Hosp_Rev Suicide_Idea_Pre_Hosp_Rev Substances Qualify_Rise_Rev  

* Loop through each variable and tabulate with respect to race_adjusted
foreach var of local vars {
    tabulate `var' race_adjusted, row
}

* Summary Statistics for Ref_Rise_Rev by Race as a Percent of Qualified for RISE
tabulate Ref_Rise_Rev race_adjusted if Qualify_Rise_Rev == 1, row

* Summarize continuous variables with respect to race_adjusted

* Summary of LOS by race_adjusted
by race_adjusted, sort: summarize LOS

* Summary of Age by race_adjusted
by race_adjusted, sort: summarize AdmissionAge

* Tabulations and Summaries for Aggregate N (X%)
tabulate race_adjusted
tabulate Antipsych_Med_Rev 
tabulate Mood_Stab_Med_Rev 
tabulate Benzo_Med_Rev 
tabulate Homicide_Rev 
tabulate Restraint_Rev 
tabulate Suicide_Attempt_Hosp_Rev 
tabulate Suicide_Ideation_Hosp_Rev 
tabulate Suicide_Att_Pre_Hosp_Rev 
tabulate Suicide_Idea_Pre_Hosp_Rev 
tabulate Substances
tabulate Qualify_Rise_Rev
tabulate Ref_Rise_Rev
summarize LOS
summarize AdmissionAge

* Were all patients who were referred to RISE also qualified for rise? Yes
tabulate Ref_Rise_Rev
tabulate Ref_Rise_Rev if Qualify_Rise_Rev == 1

* Summary Statistics Pre and Post Covid (1/2019-12/31/2019) & (1/2020-12/31/2020) 
* Creating Covid dummy variable for pre and post Covid (pre=0/post=1)
gen Covid = . 
replace Covid = 0 if Admit_Date >= mdy(1, 1, 2019) & Admit_Date <= mdy(12, 31, 2019)
replace Covid = 1 if Admit_Date >= mdy(1, 1, 2020) & Admit_Date <= mdy(12, 31, 2020)

* Aggregate N (X%) Tabulations and Summarizations for Each Variable Pre and Post Covid

* Pre-Covid
tabulate race_adjusted if Covid == 0
summarize AdmissionAge if Covid == 0
tabulate Sex if Covid == 0
tabulate Antipsych_Med_Rev if Covid == 0
tabulate Mood_Stab_Med_Rev if Covid == 0
tabulate Benzo_Med_Rev if Covid == 0
tabulate Restraint_Rev if Covid == 0
tabulate Homicide_Rev if Covid == 0
tabulate Suicide_Attempt_Hosp_Rev if Covid == 0
tabulate Suicide_Att_Pre_Hosp_Rev if Covid == 0
tabulate Suicide_Ideation_Hosp_Rev if Covid == 0
tabulate Suicide_Idea_Pre_Hosp_Rev if Covid == 0
tabulate Substances if Covid == 0
tabulate Qualify_Rise_Rev if Covid == 0
tabulate Ref_Rise_Rev if Covid == 0
summarize LOS if Covid == 0
summarize AdmissionAge if Covid == 0

* Post-Covid
tabulate race_adjusted if Covid == 1
tabulate Sex if Covid == 1
tabulate Antipsych_Med_Rev if Covid == 1
tabulate Mood_Stab_Med_Rev if Covid == 1
tabulate Benzo_Med_Rev if Covid == 1
tabulate Restraint_Rev if Covid == 1
tabulate Homicide_Rev if Covid == 1
tabulate Suicide_Attempt_Hosp_Rev if Covid == 1
tabulate Suicide_Att_Pre_Hosp_Rev if Covid == 1
tabulate Suicide_Ideation_Hosp_Rev if Covid == 1
tabulate Suicide_Idea_Pre_Hosp_Rev if Covid == 1
tabulate Substances if Covid == 1
tabulate Qualify_Rise_Rev if Covid == 1
tabulate Ref_Rise_Rev if Covid == 1
summarize LOS if Covid == 1
summarize AdmissionAge if Covid == 1

* Tabulate Variables by Pre and Post Covid with Respect to race_adjusted

* Define the list of categorical/binary variables
local vars Sex Antipsych_Med_Rev Mood_Stab_Med_Rev Benzo_Med_Rev Restraint_Rev Homicide_Rev Suicide_Attempt_Hosp_Rev Suicide_Att_Pre_Hosp_Rev Suicide_Ideation_Hosp_Rev Suicide_Idea_Pre_Hosp_Rev Substances Qualify_Rise_Rev Ref_Rise_Rev

* Loop through each variable and tabulate with respect to race when Covid == 0
foreach var of local vars {
    preserve
    keep if Covid == 0
    tabulate `var' race_adjusted, row
    restore
}

* Define the list of categorical/binary variables
local vars Sex Antipsych_Med_Rev Mood_Stab_Med_Rev Benzo_Med_Rev Restraint_Rev Homicide_Rev Suicide_Attempt_Hosp_Rev Suicide_Att_Pre_Hosp_Rev Suicide_Ideation_Hosp_Rev Suicide_Idea_Pre_Hosp_Rev Substances Qualify_Rise_Rev

* Loop through each variable and tabulate with respect to race when Covid == 1
foreach var of local vars {
    preserve
    keep if Covid == 1
    tabulate `var' race_adjusted, row
    restore
}

* Summary Statistics for Ref_Rise_Rev pre and post Covid as a Percent of Qualified for RISE
tabulate Ref_Rise_Rev race_adjusted if Qualify_Rise_Rev == 1 & Covid == 0, row
tabulate Ref_Rise_Rev race_adjusted if Qualify_Rise_Rev == 1 & Covid == 1, row

* Summarize continuous variables with respect to race_adjusted

* Summary of Age by race_adjusted
by race_adjusted, sort: summarize AdmissionAge if Covid == 0
by race_adjusted, sort: summarize AdmissionAge if Covid == 1

* Summary of LOS by race_adjusted
by race_adjusted, sort: summarize LOS if Covid == 0
by race_adjusted, sort: summarize LOS if Covid == 1

* Analysis Pre and Post Covid (1/2019-12/31/2019) & (1/2020-12/31/2020) 

* Fisher's Exact Pre/Post Covid Tests for Each Variable
tabulate Antipsych_Med_Rev Covid, exact
tabulate Mood_Stab_Med_Rev Covid, exact
tabulate Benzo_Med_Rev Covid, exact
tabulate Homicide_Rev Covid, exact
tabulate Restraint_Rev Covid, exact
tabulate Suicide_Attempt_Hosp_Rev Covid, exact
tabulate Suicide_Ideation_Hosp_Rev Covid, exact
tabulate Suicide_Att_Pre_Hosp_Rev Covid, exact
tabulate Suicide_Idea_Pre_Hosp_Rev Covid, exact
tabulate Substances Covid, exact
tabulate Ref_Rise_Rev Covid, exact
tabulate Qualify_Rise_Rev Covid, exact

* Kruskal-Wallis Test for Length of Stay Pre/Post Covid
kwallis LOS, by(Covid)

* Categorizing and create dummy variable for substance abuse
* Substances Variable: 0=None 1=Cannabis 2=Cannabis/Other Substance(s) 3=Tobacco 4=Other 5=Polysubstance/No Cannabis
tabulate lifetime_substanceuse_preadmis

* Browse use of Cannabis
browse PAT_MRN_ID lifetime_substanceuse_preadmis if strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("marijuana")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("cannabis")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("thc")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("mj")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("cannabinoids")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("k2")) > 0

* Browse use of Tobacco/Cigarettes
browse PAT_MRN_ID lifetime_substanceuse_preadmis if strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("tobacco")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("cigarettes")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("smoker")) > 0

* Browse use of Alcohol
browse PAT_MRN_ID lifetime_substanceuse_preadmis if strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("alcohol")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("drink")) > 0

browse PAT_MRN_ID lifetime_substanceuse_preadmis if strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("substance")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("polysubstance")) > 0

* Browse patients with no known substance abuse (a few manuals will need to be done)
browse PAT_MRN_ID lifetime_substanceuse_preadmis if inlist(lower(trim(lifetime_substanceuse_preadmis)), "none", "n/a", "", "no")

* Create Substances Variable
browse PAT_MRN_ID Substances lifetime_substanceuse_preadmis
gen Substances = . 
replace Substances = 0 if inlist(lower(trim(lifetime_substanceuse_preadmis)), "none", "n/a", "", "no")
replace Substances = 2 if strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("marijuana")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("cannabis")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("thc")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("mj")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("cannabinoids")) > 0 | strpos(lower(trim(lifetime_substanceuse_preadmis)), lower("k2")) > 0

* Remaining will be manually adjusted according to categories
tabulate Substances

* Chi-Square test for substance abuse 
tabulate Substances race_adjusted, chi2

* Chi-Square test post-hoc analysis for substance abuse due to sig p-value 0.044
* Calculate Expected Frequencies and Observed Frequencies
tabulate Substances race_adjusted, expected

* Store Standardized Residuals for each cell of 
preserve
* Standardized Residuals for Substances = 0
gen Asian_0 = (7 - 3.3) / sqrt(3.3)
gen Black_0 = (28 - 24.8) / sqrt(24.8)
gen Hispanic_0 = (5 - 10.1) / sqrt(10.1)
gen Other_0 = (1 - 1.1) / sqrt(1.1)
gen Portuguese_0 = (3 - 2.2) / sqrt(2.2)
gen White_0 = (31 - 33.5) / sqrt(33.5)

* Standardized Residuals for Substances = 1
gen Asian_1 = (2 - 2.7) / sqrt(2.7)
gen Black_1 = (15 - 20.8) / sqrt(20.8)
gen Hispanic_1 = (15 - 8.5) / sqrt(8.5)
gen Other_1 = (1 - 0.9) / sqrt(0.9)
gen Portuguese_1 = (1 - 1.8) / sqrt(1.8)
gen White_1 = (29 - 28.2) / sqrt(28.2)

* Standardized Residuals for Substances = 2
gen Asian_2 = (1 - 3.7) / sqrt(3.7)
gen Black_2 = (34 - 27.8) / sqrt(27.8)
gen Hispanic_2 = (9 - 11.3) / sqrt(11.3)
gen Other_2 = (1 - 1.2) / sqrt(1.2)
gen Portuguese_2 = (3 - 2.4) / sqrt(2.4)
gen White_2 = (36 - 37.6) / sqrt(37.6)

* Standardized Residuals for Substances = 3
gen Asian_3 = (1 - 0.7) / sqrt(0.7)
gen Black_3 = (5 - 5.0) / sqrt(5.0)
gen Hispanic_3 = (1 - 2.0) / sqrt(2.0)
gen Other_3 = (1 - 0.2) / sqrt(0.2)
gen Portuguese_3 = (0 - 0.4) / sqrt(0.4)
gen White_3 = (7 - 6.7) / sqrt(6.7)

* Standardized Residuals for Substances = 4
gen Asian_4 = (1 - 0.8) / sqrt(0.8)
gen Black_4 = (5 - 6.0) / sqrt(6.0)
gen Hispanic_4 = (6 - 2.4) / sqrt(2.4)
gen Other_4 = (0 - 0.3) / sqrt(0.3)
gen Portuguese_4 = (1 - 0.5) / sqrt(0.5)
gen White_4 = (5 - 8.1) / sqrt(8.1)

* Standardized Residuals for Substances = 5
gen Asian_5 = (0 - 0.9) / sqrt(0.9)
gen Black_5 = (4 - 6.6) / sqrt(6.6)
gen Hispanic_5 = (1 - 2.7) / sqrt(2.7)
gen Other_5 = (0 - 0.3) / sqrt(0.3)
gen Portuguese_5 = (0 - 0.6) / sqrt(0.6)
gen White_5 = (15 - 8.9) / sqrt(8.9)

* Collapse the data to find the maximum value for each absolute residual
collapse (max) Asian_0 Black_0 Hispanic_0 Other_0 Portuguese_0 White_0 Asian_1 Black_1 Hispanic_1 Other_1 Portuguese_1 White_1 Asian_2 Black_2 Hispanic_2 Other_2 Portuguese_2 White_2 Asian_3 Black_3 Hispanic_3 Other_3 Portuguese_3 White_3 Asian_4 Black_4 Hispanic_4 Other_4 Portuguese_4 White_4 Asian_5 Black_5 Hispanic_5 Other_5 Portuguese_5 White_5

* List the values of all absolute value variables to determine which are sig
list Asian_0 Black_0 Hispanic_0 Other_0 Portuguese_0 White_0 Asian_1 Black_1 Hispanic_1 Other_1 Portuguese_1 White_1 Asian_2 Black_2 Hispanic_2 Other_2 Portuguese_2 White_2 Asian_3 Black_3 Hispanic_3 Other_3 Portuguese_3 White_3 Asian_4 Black_4 Hispanic_4 Other_4 Portuguese_4 White_4 Asian_5 Black_5 Hispanic_5 Other_5 Portuguese_5 White_5
restore

* Another method for finding absolute standardized residuals
ssc install tab_chi

* Finds Chi-Squared for Substances by Race and Ethnic Group and Expected Frequencies and Pearson Residuals for Each Cell. Comparison between standardized residuals come down to "rule of thumb" (|Std Resid|>2).
tabchi Substances race_adjusted, pearson

* Same as above, but calculates Adjusted Pearson Residuals which have a follow a normal distribution allowing for straight forward post-hoc analysis on the standardized residuals based on the critical value of alpha.
tabchi Substances race_adjusted, adj 

* It is good practice to make a Bonferroni-correction to avoid type-1 errors when making so many comparisons. In this case there was 36 comparisons (6 Substance Categories x 6 Race/Ethnicity Categories) so the adjustment is: 0.05/36 = 0.00138889

* Calculate the significance level for two tail
local alpha = 0.00138889

* Calculate the critical values
display "Lower critical value: " invnormal(`alpha'/2)
display "Upper critical value: " invnormal(1 - `alpha'/2)

* The result is ±3.197 meaning that standardized residuals with an absolute value greater than 3.197 are significantly different than expected. When making this adjustment opposed to using the "rule of thumb" value of 2, there are no longer any standardized residuals that suggest significantly different than expected rate of substance abuse by race and ethnicity.

* Fisher's Exact Test Pre/During Covid by Race/Ethnicity for Each Variable
tabulate race_adjusted Covid if Antipsych_Med_Rev == 0, exact
tabulate race_adjusted Covid if Antipsych_Med_Rev == 1, exact
tabulate race_adjusted Covid if Antipsych_Med_Rev == 2, exact
tabulate race_adjusted Covid if Antipsych_Med_Rev == 3, exact
tabulate race_adjusted Covid if Antipsych_Med_Rev == 4, exact

tabulate race_adjusted Covid if Mood_Stab_Med_Rev == 0, exact
tabulate race_adjusted Covid if Mood_Stab_Med_Rev == 1, exact
tabulate race_adjusted Covid if Mood_Stab_Med_Rev == 2, exact

tabulate race_adjusted Covid if Benzo_Med_Rev == 0, exact
tabulate race_adjusted Covid if Benzo_Med_Rev == 1, exact

tabulate race_adjusted Covid if Homicide_Rev == 0, exact
tabulate race_adjusted Covid if Homicide_Rev == 1, exact

tabulate race_adjusted Covid if Restraint_Rev == 0, exact
tabulate race_adjusted Covid if Restraint_Rev == 1, exact

tabulate race_adjusted Covid if Suicide_Attempt_Hosp_Rev == 0, exact
tabulate race_adjusted Covid if Suicide_Attempt_Hosp_Rev == 1, exact

tabulate race_adjusted Covid if Suicide_Ideation_Hosp_Rev == 0, exact
tabulate race_adjusted Covid if Suicide_Ideation_Hosp_Rev == 1, exact

tabulate race_adjusted Covid if Suicide_Att_Pre_Hosp_Rev == 0, exact

* p-value = 0.045 which is significant at 0.05, but not at Bonferroni-corrected 0.05/10 = 0.005
tabulate race_adjusted Covid if Suicide_Att_Pre_Hosp_Rev == 1, exact

tabulate race_adjusted Covid if Suicide_Idea_Pre_Hosp_Rev == 0, exact
tabulate race_adjusted Covid if Suicide_Idea_Pre_Hosp_Rev == 1, exact

tabulate race_adjusted Covid if Substances == 0, exact
tabulate race_adjusted Covid if Substances == 1, exact
tabulate race_adjusted Covid if Substances == 2, exact
tabulate race_adjusted Covid if Substances == 3, exact
tabulate race_adjusted Covid if Substances == 4, exact
tabulate race_adjusted Covid if Substances == 5, exact

tabulate race_adjusted Covid if Ref_Rise_Rev == 0, exact
tabulate race_adjusted Covid if Ref_Rise_Rev == 1, exact

tabulate race_adjusted Covid if Qualify_Rise_Rev == 0, exact
tabulate race_adjusted Covid if Qualify_Rise_Rev == 1, exact