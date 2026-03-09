# Data processing script for Year 4 and 5 of NP Trends survey

# Libraries
library(data.table)
library(tidyverse)
library(spatstat)
library(rlang)
library(stats)
library(ntistools)

# Helper functions
# config.R defines: nptrends_y4_raw_path, nptrends_y5_raw_path,
#   survey_analysis_vars, percent_vars, numstaff_vars, multi_select_cols,
#   total_expenditure_cols, grant_value_change_cols, ceo_bchair_binary_ls,
#   binary_rcv_cols_ls, percentdem_vars
source(here::here("R", "config.R"))

# Load in raw survey data
nptrends_y4_raw <- data.table::fread(nptrends_y4_raw_path,
                                     select = survey_analysis_vars) |>
  dplyr::mutate(year = "2024")
nptrends_y5_raw <- data.table::fread(nptrends_y5_raw_path,
                                     select = survey_analysis_vars) |>
  dplyr::mutate(year = "2025")
nptrends_full_raw <- nptrends_y4_raw |>
  dplyr::bind_rows(nptrends_y5_raw)

# Preprocess data
nptrends_full_preprocessed <- nptrends_full_raw |>
  dplyr::mutate(
    SizeStrata = factor(
      SizeStrata,
      levels = c(1, 2, 3, 4, 5),
      labels = c(
        "$50,000–$99,999",
        "$100,000–$499,999",
        "$500,000–$999,999",
        "$1 million–$9,999,999",
        "$10 million and above"
      )
    ),
    Subsector = dplyr::case_when(
      ntmaj12 == "AR" ~ "Arts, culture, and humanities",
      ntmaj12 == "ED" ~ "Education",
      ntmaj12 == "EN" ~ "Environment and animals",
      ntmaj12 == "HE" ~ "Health",
      ntmaj12 == "HU" ~ "Human services",
      ntmaj12 == "IN" ~ "International and foreign affairs",
      ntmaj12 == "PU" ~ "Public and societal benefit",
      ntmaj12 == "RE" ~ "Religion",
      .default = NA
    ),
    census_urban_area = dplyr::case_when(census_urban_area == 1 ~ "Urban", census_urban_area == 0 ~ "Rural", ),
    CensusRegion4 = factor(
      CensusRegion4,
      levels = c(1, 2, 3, 4),
      labels = c("Northeast", "Midwest", "South", "West")
    ),
    state = dplyr::coalesce(state, State),
    CensusRegion4 = dplyr::case_when(
      state == "NY" & CensusRegion4 == "West" ~ "Northeast",
      state == "CO" & CensusRegion4 == "Midwest" ~ "West",
      state == "MO" & CensusRegion4 == "West" ~ "Midwest",
      state == "CA" & CensusRegion4 == "South" ~ "West",
      state == "AZ" & CensusRegion4 == "South" ~ "West",
      .default = CensusRegion4
    ),
    National = "National"
  ) %>%
  # Percent variables should be under 100%
  dplyr::mutate(
    dplyr::across(
      .cols = percent_vars,
      .fns = ~ ifelse(.x > 1, NA_real_, .x)
    )
  ) %>%
  # Binary flags for new variables where 1 if any of the variables are 1 and 0 if all are 0
  dplyr::mutate(
    percent_expenses_inCashReserves = dplyr::case_when(
      is.na(Reserves_Est) & Reserves_NA_X == 1 ~ 0,
      is.na(TotExp) | TotExp == 0 ~ NA_real_,
      .default = Reserves_Est / TotExp
    ),
    FndRaise_DnrBlw250_ratio = FndRaise_DnrBlw250 / (FndRaise_DnrAbv250 + FndRaise_DnrBlw250),
    FndRaise_DnrAbv250_ratio = FndRaise_DnrAbv250 / (FndRaise_DnrBlw250 + FndRaise_DnrAbv250),
    PplSrv_MeetDemand = dplyr::case_when(
      PplSrv_NumWait == 0 | (PplSrv_NumWait_NA_X == 1 & PplSrv_NumServed > 0) ~ "Able to meet demand",
      PplSrv_NumWait > 0 ~ "Unable to meet demand",
      .default = NA_character_
    ),
    dplyr::across(
      .cols = numstaff_vars[grepl("Fulltime", numstaff_vars)],
      .fns = ~ dplyr::case_when(
        Staff_Fulltime_NA == 1 & is.na(.x) ~ "0",
        .x == 0 ~ "0",
        .x == 1 ~ "1",
        .x >= 2 &  .x <= 9 ~ "2–9",
        .x >= 10 & .x <= 49 ~ "10–49",
        .x >= 50 ~ "50+",
        .default = NA_character_
      )
    ),
    dplyr::across(
      .cols = numstaff_vars[grepl("Parttime", numstaff_vars)],
      .fns = ~ dplyr::case_when(
        Staff_Parttime_NA == 1 & is.na(.x) ~ "0",
        .x == 0 ~ "0",
        .x == 1 ~ "1",
        .x >= 2 &  .x <= 9 ~ "2–9",
        .x >= 10 & .x <= 49 ~ "10–49",
        .x >= 50 ~ "50+",
        .default = NA_character_
      )
    ),
    Dem_BChair_Under35 = dplyr::case_when(
      Dem_BChair_Age %in% c(1, 2) ~ "Board chair is under age 35",
      Dem_BChair_Age %in% c(3, 4, 5, 6, 7, 8, 9, 97) ~ "Board chair is not under age 35",
      .default = NA_character_
    ),
    Dem_CEO_Under35 = dplyr::case_when(
      Dem_CEO_Age %in% c(1, 2) ~ "CEO is under age 35",
      Dem_CEO_Age %in% c(3, 4, 5, 6, 7, 8, 9, 97) ~ "CEO is not under age 35",
      .default = NA_character_
    ),
    BChair_POC = dplyr::case_when(
      BChairrace %in% c(1, 2, 3, 4, 6, 7) ~ "Board chair is a person of color",
      BChairrace %in% c(5) ~ "Board chair is not a person of color",
      .default = NA_character_
    ),
    CEOrace_POC = dplyr::case_when(
      CEOrace %in% c(1, 2, 3, 4, 6, 7) ~ "CEO is a person of color",
      CEOrace %in% c(5) ~ "CEO is not a person of color",
      .default = NA_character_
    )
  ) |>
  # Replace binary_flag() calls with combine_binary (strict_na = TRUE)
  combine_binary(GeoAreas_ServedLocal, GeoAreas_Local,
                 GeoAreas_MultipleLocal, GeoAreas_RegionalWithin,
                 strict_na = TRUE) |>
  combine_binary(GeoAreas_Servedmultistate, GeoAreas_MultipleState,
                 GeoAreas_RegionalAcross, strict_na = TRUE) |>
  # Impute from flag with flag_map for year-suffixed variable names
  impute_from_flag(
    vars = c("Staff_RegVlntr_2023", "Staff_RegVlntr_2024"),
    flag_map = c(Staff_RegVlntr_2023 = "Staff_RegVlntr_NA",
                 Staff_RegVlntr_2024 = "Staff_RegVlntr_NA")
  ) |>
  impute_from_flag(
    vars = c("Staff_EpsdVltnr_2023", "Staff_EpsdVltnr_2024"),
    flag_map = c(Staff_EpsdVltnr_2023 = "Staff_EpsdVltnr_NA",
                 Staff_EpsdVltnr_2024 = "Staff_EpsdVltnr_NA")
  ) |>
  impute_from_flag(
    vars = c("Staff_Boardmmbr_2023", "Staff_Boardmmbr_2024"),
    flag_map = c(Staff_Boardmmbr_2023 = "Staff_Boardmmbr_NA",
                 Staff_Boardmmbr_2024 = "Staff_Boardmmbr_NA")
  ) |>
  # Recode ProgDem_ columns: 0 -> 0, 1/2 -> 1
  recode_binary(grep("^ProgDem_", names(nptrends_full_raw), value = TRUE),
                ones = c(1, 2), zeros = 0) |>
  # Label binary columns
  label_binary(
    labels = list(
      FinanceChng_Reserves = c("Drew on cash reserves", "Did not draw on cash reserves"),
      GeoAreas_ServedLocal = c("Serving local areas", "Not serving local areas"),
      GeoAreas_State = c("Serving statewide", "Not serving statewide"),
      GeoAreas_Servedmultistate = c("Serving multiple states", "Not serving multiple states"),
      GeoAreas_National = c("Serving nationally", "Not serving nationally"),
      GeoAreas_International = c("Serving internationally", "Not serving internationally"),
      PrgSrvc_Suspend = c("Paused or suspended services", "Did not pause or suspend services")
    ),
    na_values = 97
  ) |>
  label_binary(
    labels = list(
      ProgDem_BelowFPL = c("Serving people living in poverty", "Not serving people living in poverty"),
      ProgDem_Disabled = c("Serving people with disabilities", "Not serving people with disabilities"),
      ProgDem_Veterans = c("Serving veterans", "Not serving veterans"),
      ProgDem_LGBTQ = c("Serving LGBTQ people", "Not serving LGBTQ people"),
      ProgDem_Foreign = c("Serving foreign-born people", "Not serving foreign-born people"),
      ProgDem_Latinx = c("Serving Latinx/Hispanic populations", "Not serving Latinx/Hispanic populations"),
      ProgDem_Black = c("Serving Black/African American populations", "Not serving Black/African American populations"),
      ProgDem_Indigenous = c("Serving Indigenous/Native American and Alaska Native populations", "Not serving Indigenous/Native American and Alaska Native populations"),
      ProgDem_Asian = c("Serving Asian populations", "Not serving Asian populations"),
      ProgDem_Men = c("Serving men and boys", "Not serving men and boys"),
      ProgDem_Women = c("Serving women and girls", "Not serving women and girls"),
      ProgDem_Nonbinary = c("Serving nonbinary people", "Not serving nonbinary people"),
      ProgDem_Children = c("Serving children and youth", "Not serving children and youth"),
      ProgDem_YoungAdults = c("Serving young adults", "Not serving young adults"),
      ProgDem_Adults = c("Serving adults", "Not serving adults"),
      ProgDem_Elders = c("Serving seniors", "Not serving seniors")
    )
  ) |>
  # Dmnd_NxtYear uses non-standard values (0/1/2), label manually
  dplyr::mutate(
    Dmnd_NxtYear = dplyr::case_when(
      Dmnd_NxtYear == 2 ~ "Anticipated increase",
      Dmnd_NxtYear == 1 ~ "No change",
      Dmnd_NxtYear == 0 ~ "Anticipated decrease",
      .default = NA_character_
    ),
    # Consult ceo_bchair_binary_ls object in R/config.R
    dplyr::across(
      .cols = names(ceo_bchair_binary_ls),
      .fns = ~ dplyr::case_when(
        .x == 1 ~ ceo_bchair_binary_ls[[dplyr::cur_column()]][[1]],
        .x %in% c(0, 97) ~ ceo_bchair_binary_ls[[dplyr::cur_column()]][[2]],
        .default = NA_character_
      )
    ),
    # binary_rcv_cols_ls uses gsub for false labels — keep as manual across()
    dplyr::across(
      .cols = dplyr::all_of(names(binary_rcv_cols_ls)),
      .fns = ~ dplyr::case_when(.x == 1 ~ binary_rcv_cols_ls[[dplyr::cur_column()]],
                                .x == 0 ~ gsub("Received",
                                               "Did not receive",
                                               binary_rcv_cols_ls[[dplyr::cur_column()]]),
                                .default = NA_character_)
    ),
    # Percentage demographic binning (single instance, domain-specific)
    dplyr::across(
      .cols = dplyr::all_of(percentdem_vars),
      .fns = ~ dplyr::case_when(
        .x == 0 ~ "0%",
        .x %in% c(1, 2) ~ "1–20%",
        .x %in% c(3, 4) ~ "21–40%",
        .x %in% c(5, 6) ~ "41–60%",
        .x %in% c(7, 8) ~ "61–80%",
        .x %in% c(9, 10) ~ "81–99%",
        .x == 11 ~ "100%",
        .x == 97 ~ NA_character_,
        .default = NA_character_
      )
    ),
    svywt = dplyr::coalesce(year4wt, year5wt)
  ) |>
  # Label Likert-scale columns
  label_likert(multi_select_cols,
               labels = c("Decrease", "No change", "Increase")) |>
  label_likert(total_expenditure_cols,
               labels = c("Decrease in expenditures", "No change", "Increase in expenditures")) |>
  label_likert(grant_value_change_cols,
               labels = c("Decrease in value", "No change", "Increase in value")) |>
  dplyr::mutate(
    Staff_RegVlntr = dplyr::coalesce(Staff_RegVlntr_2023, Staff_RegVlntr_2024),
    Staff_EpsdVlntr = dplyr::coalesce(Staff_EpsdVlntr_2023, Staff_EpsdVltnr_2024),
    Staff_Boardmmbr = dplyr::coalesce(Staff_Boardmmbr_2023, Staff_Boardmmbr_2024),
    Staff_Fulltime = dplyr::coalesce(Staff_Fulltime_2023, Staff_Fulltime_2024),
    Staff_Parttime = dplyr::coalesce(Staff_Parttime_2023, Staff_Parttime_2024)
  ) |>
  dplyr::mutate(
    Cash_Reserves = dplyr::case_when(
      is.na(Reserves_Est) & Reserves_NA_X == 1 ~ "Did not have cash reserves",
      Reserves_Est > 0 ~ "Had cash reserves",
      Reserves_Est <= 0 ~ "Did not have cash reserves",
      .default = NA_character_
    ),
    # Year-conditional Likert — kept as manual case_when (2 vars only)
    FndRaise_Cashbelow250_Chng = dplyr::case_when(
      FndRaise_Cashbelow250_Chng %in% c(1, 2) ~ "Decrease in donations < $250",
      FndRaise_Cashbelow250_Chng == 3 ~ "No change",
      FndRaise_Cashbelow250_Chng %in% c(4, 5) ~ "Increase in donations < $250",
      year == 2024 & FndRaise_Cashbelow250_Chng == 98 ~ "Unsure",
      year == 2025 & FndRaise_Cashbelow250_Chng == 97 ~ "Unsure",
      .default = NA_character_
    ),
    FndRaise_Cashabove250_Chng = dplyr::case_when(
      FndRaise_Cashabove250_Chng %in% c(1, 2) ~ "Decrease in donations ≥ $250",
      FndRaise_Cashabove250_Chng == 3 ~ "No change",
      FndRaise_Cashabove250_Chng %in% c(4, 5) ~ "Increase in donations ≥ $250",
      year == 2024 & FndRaise_Cashabove250_Chng == 98 ~ "Unsure",
      year == 2025 & FndRaise_Cashabove250_Chng == 97 ~ "Unsure",
      .default = NA_character_
    )
  ) |>
  # Remaining Likert columns handled individually with label_likert
  label_likert("FinanceChng_TotExp",
               labels = c("Decrease in expenses", "No change", "Increase in expenses")) |>
  label_likert("FinanceChng_Salaries",
               labels = c("Decrease in salaries and wages", "No change", "Increase in salaries and wages")) |>
  label_likert("PrgSrvc_Amt_Fee",
               labels = c("Decrease in $ amount", "No change", "Increase in $ amount"))

# Save intermediate file
data.table::fwrite(nptrends_full_preprocessed,
                   "data/intermediate/nptrends_full_preprocessed.csv")
