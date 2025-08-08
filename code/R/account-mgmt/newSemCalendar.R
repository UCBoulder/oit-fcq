# build fcq calendar for new semester
library(lubridate)

# set the year
year <- year(Sys.Date())
yr <- year(Sys.Date())

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
  # store as named vector, not list (avoids coercion issues)
  holidays <- c(
# MLK Day – 3rd Monday in January
    mlk_day       = as.Date(paste0(year, '-01-01')) + weeks(2) + (1 - wday(as.Date(paste0(year, '-01-01')) + weeks(2))) %% 7,
# Memorial Day – Last Monday in May
    memorial_day  = as.Date(paste0(year, '-05-31')) - (wday(as.Date(paste0(year, '-05-31'))) - 2) %% 7,
# Juneteenth – June 19
    juneteenth    = as.Date(paste0(year, '-06-19')),
# Independence Day – July 4
    july_fourth   = as.Date(paste0(year, '-07-04')),
# Labor Day – First Monday in September
    labor_day     = as.Date(paste0(year, '-09-01')) + (8 - wday(as.Date(paste0(year, '-09-01')))) %% 7,
# Thanksgiving – 4th Thursday in November
    thanksgiving  = as.Date(paste0(year, '-11-01')) + weeks(3) + (5 - wday(as.Date(paste0(year, '-11-01')) + weeks(3))) %% 7
  )
  
# get observed dates
  observed_dates <- sapply(holidays, get_observed_date)
  
# convert to data frame
  tibble(
    holiday = names(holidays),
    actual_date = holidays,
    observed_date = as.Date(observed_dates, origin = '1970-01-01'),
    actual_formatted = format(holidays, '%b %d, %Y'),
    observed_formatted = format(observed_dates, '%b %d, %Y')
  )
}

get_cu_holidays(yr)

####################################
library(lubridate)
library(dplyr)

get_observed_date <- function(date) {
  wd <- wday(date)
  if (wd == 7) {
    date - days(1)  # Sat → Fri
  } else if (wd == 1) {
    date + days(1)  # Sun → Mon
  } else {
    date
  }
}

get_us_holidays <- function(year) {
  mlk_day      <- as.Date(paste0(year, "-01-01")) + weeks(2) + ((2 - wday(as.Date(paste0(year, "-01-01")) + weeks(2))) %% 7)
  memorial_day <- as.Date(paste0(year, "-05-31")) - ((wday(as.Date(paste0(year, "-05-31"))) - 2) %% 7)
  juneteenth   <- as.Date(paste0(year, "-06-19"))
  july_fourth  <- as.Date(paste0(year, "-07-04"))
  labor_day    <- as.Date(paste0(year, "-09-01")) + ((2 - wday(as.Date(paste0(year, "-09-01")))) %% 7)
  thanksgiving <- as.Date(paste0(year, "-11-01")) + weeks(3) + ((5 - wday(as.Date(paste0(year, "-11-01")) + weeks(3))) %% 7)

  actual_dates <- c(mlk_day, memorial_day, juneteenth, july_fourth, labor_day, thanksgiving)
  holidays <- c("mlk_day", "memorial_day", "juneteenth", "july_fourth", "labor_day", "thanksgiving")

  # Check classes before formatting
  print(class(actual_dates))        # Should print "Date"
  
  observed_dates <- sapply(actual_dates, get_observed_date)
  print(class(observed_dates))      # Should print "Date"
  
  # Defensive conversion (make sure it's Date)
  observed_dates <- as.Date(observed_dates, origin = "1970-01-01")

  tibble(
    holiday = holidays,
    actual_date = actual_dates,
    observed_date = observed_dates,
    actual_formatted = format(actual_dates, "%b %d, %Y"),
    observed_formatted = format(observed_dates, "%b %d, %Y")
  )
}

get_us_holidays(year)




cu_holidays <- as.Date(c(
  '2025-09-01',  # Labor Day
  '2025-11-11',  # Veterans Day
  '2025-11-27',  # Thanksgiving
  '2025-12-25'   # Christmas
))

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


# get_wednesday_start <- function(date) {
#   wday <- wday(date, week_start = 1)
#   offset <- ifelse(wday >= 4, wday - 4, wday + 3)
#   return(date - offset)
# }
# 
# # Apply the function
# dates_df <- data.frame(
#   Date = all_dates,
#   Week_Start_Wed = get_wednesday_start(all_dates)
# )
# 
# week_groups <- dates_df %>%
#   group_by(Week_Start_Wed) %>%
#   summarise(Week = paste(min(Date), "to", max(Date)))

# Create a data frame with Tuesday and Wednesday for each week
calendar_df <- data.frame(
  Tuesday = tuesdays,
  Wednesday = tuesdays + days(1)
)

# View the result
print(calendar_df)
