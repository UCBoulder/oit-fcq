# build fcq calendar for new semester
library(lubridate)

# set the year
year <- 2025
yr <- 2025

# format for functions below
year <- as.Date(paste0(year, '-01-01'))
yr <- as.Date(paste0(yr, '-01-01'))

year <- format(year, '%Y')
yr <- format(yr, '%Y')

# set the term based on 1 = spring, 4 = summer, 7 = fall
sem147 <- 7

if (sem147 == 1) {
  start_date <- as.Date(paste0(year, '-01-01'))
  end_date <- as.Date(paste0(year, '-05-31'))
} else if (sem147 == 4) {
  start_date <- as.Date(paste0(year, '-05-01'))
  end_date <- as.Date(paste0(year, '-08-31'))
} else if (sem147 == 7) {
  start_date <- as.Date(paste0(year, '-08-01'))
  end_date <- as.Date(paste0(year, '-12-31'))
}

#############################################################################
# get holidays to account for in weekly session setup
#############################################################################

# identify campus holidays by observed dates
get_observed_date <- function(actual_date) {
  weekday <- wday(actual_date)
  if (weekday == 7) {
# observed on Friday
    actual_date - days(1)
  } else if (weekday == 1) {
# observed on Monday
    actual_date + days(1)
  } else {
    actual_date
  }
}

# get holidays with observed dates
get_cu_holidays <- function(year) {
  date_in_year <- function(month_day) as.Date(paste0(year, '-', month_day))
  
# store as named vector, not list (avoids coercion issues)
  holidays <- c(
# MLK Day – 3rd Monday in January
    mlk_day = date_in_year('01-01') + weeks(2) + (1 - wday(date_in_year('01-01') + weeks(2), week_start = 1)) %% 7,
    
# Memorial Day – Last Monday in May
    memorial_day = date_in_year('05-31') - (wday(date_in_year('05-31'), week_start = 1) - 1) %% 7,
    
# Juneteenth – June 19
    juneteenth = date_in_year('06-19'),
    
# Independence Day – July 4
    july_fourth = date_in_year('07-04'),
    
# Labor Day – First Monday in September
    labor_day = date_in_year('09-01') + (8 - wday(date_in_year('09-01'), week_start = 1)) %% 7,
    
# Thanksgiving – 4th Thursday in November
    thanksgiving = date_in_year('11-01') + weeks(3) + (5 - wday(date_in_year('11-01') + weeks(3), week_start = 1)) %% 7
  )
  
# get observed dates
  observed_dates <- sapply(holidays, get_observed_date)

# convert to tibble
  tibble(
    holiday = names(holidays),
    actual_date = holidays,
    observed_date = as.Date(observed_dates, origin = '1970-01-01'),
    actual_formatted = format(holidays, format = '%b %d, %Y'),
    observed_formatted = format(observed_dates, format = '%b %d, %Y')
  )
}

get_cu_holidays(yr)

#############################################################################
# get dates for upcoming semester to set up weekly administrations
#############################################################################

# generate sequence of all dates in the range
all_dates <- seq.Date(start_date, end_date, by = 'day')

# identify days
monday <- all_dates[weekdays(all_dates) == 'Monday']
tuesday <- all_dates[weekdays(all_dates) == 'Tuesday']
wednesday <- all_dates[weekdays(all_dates) == 'Wednesday']
friday <- all_dates[weekdays(all_dates) == 'Friday']

# filter to dates within semester range
dtrange <- wednesday[wednesday + days(6) <= end_date]

# create data frame with Wednesday and following Tuesday
date_ranges <- data.frame(
  Wednesday = format(dtrange, '%m/%d/%Y'),
  Tuesday = format(dtrange + days(6), '%m/%d/%Y')
)

# create weekly session dates
date_sessions <- data.frame(
  fcqsessions = paste(format(monday, '%b %d'), format(friday + days(7), '%b %d'), sep = '-')
)

date_diff <- ncol(date_ranges) - ncol(date_sessions)

if (date_diff == 0) {
  date_cal <- cbind(date_ranges, date_sessions)
} else if (date_diff > 0) {
  date_sessions <- date_sessions[-nrow(date_sessions), ]
  date_cal <- cbind(date_ranges, date_sessions)
} else if (date_diff < 0) {
  date_ranges <- date_ranges[-nrow(date_ranges), ]
  date_cal <- cbind(date_ranges, date_sessions)
}

date_cal2 <- date_cal %>%
  mutate(code = paste0("adminInd == 1 & between(fcqEnDt, '", Wednesday, "','", Tuesday, "') ~ '", date_sessions, "',"))

cat(date_cal2$code, sep = '\n')

# copy output in console and paste into FCQ_Audit03.R
# cleanup formatting and dates (e.g., beg, end, finals)

#############################################################################
# needed?
#############################################################################
# create data frame with Tuesday and Wednesday for each week
calendar_df <- data.frame(
  Tuesday = format(tuesday, '%m/%d/%Y'),
  Wednesday = format(tuesday + days(1), '%m/%d/%Y')
)

# convert first Tuesday and last Wednesday to NA and move to bottom
calendar_df$Tuesday[1] <- NA
calendar_df$Wednesday[nrow(calendar_df)] <- NA
calendar_df$Tuesday <- c(na.omit(calendar_df$Tuesday), rep(NA, sum(is.na(calendar_df$Tuesday))))
calendar_df$Wednesday <- c(na.omit(calendar_df$Wednesday), rep(NA, sum(is.na(calendar_df$Wednesday))))

# remove NA
calendar_fixed <- na.omit(calendar_df)

# arrange for proper date ranges
calendar_fixed2 <- calendar_fixed %>%
  select(Wednesday, Tuesday)

# view the result
#print(calendar_fixed2)
