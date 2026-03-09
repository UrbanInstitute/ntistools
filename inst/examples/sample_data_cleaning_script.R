##### PREP ####
##### Load libraries #####
library(data.table)
library(tidyverse)
library(dplyr)

##### Import datasets #####
# Update this path to point to your local copy of the survey data
d5 <- read.csv("path/to/your/survey_data.csv")

##### Clean data #####
###### GeoAreas variables ######
# First I want to group GeoAreas_Local, GeoAreas_MultipleLocal, and
# GeoAreas_RegionalWithin into GeoAreas_Locally.
d5 <-
  d5 %>%
  mutate(
    GeoAreas_Locally = case_when(
      GeoAreas_Local == 1 | GeoAreas_MultipleLocal == 1 |
        GeoAreas_RegionalWithin == 1 ~ 1,
      is.na(GeoAreas_Local) & is.na(GeoAreas_MultipleLocal) &
        is.na(GeoAreas_RegionalWithin) ~ NA,
      .default = 0
    )
  )

# Now I want to group GeoAreas_RegionalAcross and GeoAreas_MultipleState
# into GeoAreas_MultipleState.
d5 <-
  d5 %>%
  mutate(
    GeoAreas_MultipleState = case_when(
      GeoAreas_RegionalAcross == 1 | GeoAreas_MultipleState == 1 ~ 1,
      is.na(GeoAreas_RegionalAcross) &
        is.na(GeoAreas_MultipleState) ~ NA,
      .default = 0
    )
  )

###### ProgDem variables ######
# I want values of 0 to be 0, 1 to be 1, 2 to be 1, and 98 to be NA.
recode_progdem <- function(x) {
  case_when(x == 0 ~ 0, x == 1 ~ 1, x == 2 ~ 1, x == 98 ~ NA_real_, TRUE ~ NA_real_)
}

progdem_vars <- c(
  "ProgDem_Children",
  "ProgDem_YoungAdults",
  "ProgDem_Adults",
  "ProgDem_Elders",
  "ProgDem_Veterans",
  "ProgDem_BelowFPL",
  "ProgDem_Below200FPL",
  "ProgDem_Foreign",
  "ProgDem_Latinx",
  "ProgDem_Black",
  "ProgDem_Indigenous",
  "ProgDem_Asian",
  "ProgDem_NativeHawaiian",
  "ProgDem_Disabled",
  "ProgDem_Men",
  "ProgDem_Women",
  "ProgDem_Nonbinary",
  "ProgDem_LGBTQ"
)

d5 <- d5 %>%
  mutate(across(all_of(progdem_vars), recode_progdem, .names = "{.col}_re"))

###### PplSrv_NumWait_clean ######
# I want to clean PplSrv_NumWait so that if PplSrv_NumWait_NA_X is 1 and
# PplSrv_NumServed is not NA, change the clean variable to 0.
d5 <-
  d5 %>%
  mutate(
    PplSrv_NumWait_clean = case_when(
      PplSrv_NumWait_NA_X == 1 & !is.na(PplSrv_NumServed) ~ 0,
      .default = PplSrv_NumWait
    )
  )

###### Staff variables ######
# I want to clean these variables so that if the variable is NA and the
# corresponding Staff_[]_NA variable = 1, the variable = 0, and otherwise, the
# variable = the variable.
cols <- c(
  "Staff_Fulltime",
  "Staff_Parttime",
  "Staff_Boardmmbr",
  "Staff_RegVlntr",
  "Staff_EpsdVltnr",
  "Staff_AmerVlntr",
  "Staff_PdCnslt",
  "Staff_Other_Est"
)
years <- c("2024", "2025")

d5 <- d5 %>%
  mutate(across(
    all_of(outer(cols, years, paste, sep = "_") |> as.vector()),
    ~ case_when(is.na(.) &
                  get(paste0(
                    sub("_[0-9]{4}$", "", cur_column()), "_NA"
                  )) == 1 ~ 0, TRUE ~ .),
    .names = "{.col}_re"
  ))

###### Have_Staff ######
# When analyzing the following variables, I want to remove organizations with
# no full-time or part-time paid staff.
d5 <- d5 %>%
  mutate(
    HaveStaff = case_when(
      Staff_Fulltime_2025_re > 0 | Staff_Parttime_2025_re > 0 ~ 1,
      Staff_Fulltime_2025_re == 0 & Staff_Parttime_2025_re == 0 ~ 0,
      .default = NA
    )
  )

remove_if_no_staff <- c(
  "StaffVacancies",
  "StaffVacanciesImpact",
  "Benefits_Health",
  "Benefits_HSAFSA",
  "Benefits_Dental",
  "Benefits_Vision",
  "Benefits_Insurance_Other",
  "Benefits_Pension_No",
  "Benefits_Pension_Yes_With",
  "Benefits_Pension_Yes_Without",
  "Benefits_Retire_No",
  "Benefits_Retire_Yes_With",
  "Benefits_Retire_Yes_Without",
  "Benefits_Retirement_Other",
  "Benefits_Vacation",
  "Benefits_Sick",
  "Benefits_Volunteer",
  "Benefits_Holidays",
  "Benefits_Religious",
  "Benefits_Personal",
  "Benefits_PTO_Other",
  "Benefits_Parental",
  "Benefits_Family",
  "Benefits_Medical",
  "Benefits_Sabbatical",
  "Benefits_Leave_Other",
  "Benefits_Childcare_Info",
  "Benefits_Dependent",
  "Benefits_Onsite_Childcare",
  "Benefits_Childcare_Other",
  "Benefits_Hybrid",
  "Benefits_Remote",
  "Benefits_Flexible_Hours",
  "Benefits_Flexible_Other",
  "BenefitsImpact"
)

d5 <- d5 %>%
  mutate(across(
    all_of(remove_if_no_staff),
    ~ case_when(HaveStaff == 1 ~ ., .default = NA)
  ))

###### Reserves_Est_clean ######
# I want to clean Reserves_Est so that if Reserves_Est is NA and
# Reserves_NA_X is 1, change the clean variable to 0.
d5 <-
  d5 %>%
  mutate(Reserves_Est_clean = case_when(is.na(Reserves_Est) &
                                          Reserves_NA_X == 1 ~ 0, .default = Reserves_Est))

###### Regulation variables ######
# I want to recode the following variables so that respondents who selected
# 0 for Regulations have values of 0 for these variables and respondents who
# selected 97 have values of 97 for these variables.
regulation_vars_to_recode <- c(
  "Regulations_Federal",
  "Regulations_State",
  "Regulations_Local",
  "Regulations_Requests",
  "Regulations_Info_Existing",
  "Regulations_Info_NewProposed",
  "Regulations_Info_Registration",
  "Regulations_Info_Form",
  "Regulations_Forms",
  "Regulations_Research",
  "Regulations_Advocate",
  "Regulations_Programming",
  "Regulations_Other",
  "Regulations_Info_Fed",
  "Regulations_Info_State",
  "Regulations_Info_Loc",
  "Regulations_Info_Fed",
  "Regulations_Info_State",
  "Regulations_Info_Loc"
)

d5 <-
  d5 %>%
  mutate((across(
    all_of(regulation_vars_to_recode),
    ~ case_when(Regulations == 0 ~ 0, Regulations == 97 ~ 97, TRUE ~ .),
    .names = "{.col}_re"
  )))

###### Combine Likert values ######
# Sometimes I want to combine Likert values. These are just example variables.
# It's not an exhaustive list.
LikertFive <- function(data, var_name) {
  data <-
    data %>%
    mutate("{{var_name}}_re" := case_match({{var_name}}, 1 ~ 1, 2 ~ 1, 3 ~ 2, 4 ~ 3, 5 ~ 3, 97 ~ 97, .default = NA))
  return(data)
}

d5 <- LikertFive(d5, FinanceChng_Benefits)
d5 <- LikertFive(d5, FinanceChng_Salaries)

###### Create new variables ######
# Sometimes I want to create new variables. These are just example variables.
# It's not an exhaustive list.
d5 <-
  d5 %>%
  mutate(
    LLAnyDisruption = case_when(
      LLLost == 1 | LLDelay == 1 | LLStop == 1 ~ 1,
      is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
      .default = 0
    )
  )

d5 <-
  d5 %>%
  mutate(LLOneDisruption = case_when(
    (LLLost == 1 & LLDelay != 1 & LLStop != 1) |
      (LLLost != 1 & LLDelay == 1 & LLStop != 1) |
      (LLLost != 1 & LLDelay != 1 & LLStop == 1) ~ 1,
    is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
    .default = 0
  ))

d5 <-
  d5 %>%
  mutate(LLTwoDisruption = case_when(
    (LLLost == 1 & LLDelay == 1 & LLStop != 1) |
      (LLLost == 1 & LLDelay != 1 & LLStop == 1) |
      (LLLost != 1 & LLDelay == 1 & LLStop == 1) ~ 1,
    is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
    .default = 0
  ))

d5 <-
  d5 %>%
  mutate(
    LLAllDisruption = case_when(
      LLLost == 1 & LLDelay == 1 & LLStop == 1 ~ 1,
      is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
      .default = 0
    )
  )

d5 <-
  d5 %>%
  mutate(
    StaffingPlans_Hire = case_when(
      StaffingPlans_HireDifferent == 1 |
        StaffingPlans_HireSame == 1 ~ 1,
      StaffingPlans_HireDifferent == 0 &
        StaffingPlans_HireSame == 0 ~ 0,
      .default = NA
    )
  )

###### Remove 98 ######
# Often, I want to remove values of 98. These are just example variables.
# It's not an exhaustive list.
variables_to_remove_98 <- c(
  "PrgSrvc_Amt_Num",
  "PrgSrvc_Amt_Srvc",
  "PrgSrvc_Amt_Area",
  "PrgSrvc_Amt_Fee",
  "PrgSrvc_Suspend",
  "PrgSrvc_NewOffc",
  "PrgSrvc_ClsdOffc",
  "PrgSrvc_Oth",
  "DonImportance",
  "FndRaise_TotExp",
  "FndRaise_Overall_Priv_Chng",
  "FndRaise_Cashbelow250_Chng",
  "FndRaise_Cashabove250_Chng",
  "FndRaise_Priv_Grnt_Chng",
  "FndRaise_Corp_Grnt_Chng",
  "FndRaise_DAF_Grnt_Chng",
  "FndRaise_Pub_Grnt_Chng",
  "FndRaise_In_Kind_Chng",
  "FndRaise_Rstr_Priv_Chng",
  "FndRaise_Unrstr_Priv_Chng",
  "FinanceChng_Reserves",
  "FinanceChng_Borrow",
  "FinanceChng_Benefits",
  "FinanceChng_TotRent",
  "FinanceChng_Salaries",
  "FinanceChng_Hours",
  "FinanceChng_TotTech",
  "FinanceChng_TotExp",
  "FinanceChng_Other",
  "LeadershipChng_ChngCEO",
  "LeadershipChng_ChngBC",
  "LeadershipChng_RetCEO",
  "LeadershipChng_RsgnCEO",
  "LeadershipChng_TrmnCEO",
  "LeadershipChng_HireCEO",
  "LeadershipChng_IntrmCEO",
  "LeadershipChng_OthCEO"
)

d5 <-
  d5 %>%
  mutate((across(
    all_of(variables_to_remove_98),
    ~ case_when(. == 98 ~ NA, TRUE ~ .),
    .names = "{.col}"
  )))
