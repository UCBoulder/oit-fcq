#########################################################################
# Set up administration calendar for new semester
# created: Vince Darcangelo 8/7/25
# most recent update: Vince Darcangelo 8/12/25
# \OneDrive - UCB-O365\Documents\oit-fcq\code\R\account-mgmt\newSemCalendar.R
#########################################################################

# build fcq calendar for new semester
library(lubridate)

# set the term based on 1 = spring, 4 = summer, 7 = fall
sem147 <- 7

# set the year
year <- '2025'
yr <- '2025'

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
# account for holidays in weekly sessions
#############################################################################

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

# convert to tibble
  tibble(
    holiday = names(holidays),
    actual_date = holidays,
    actual_formatted = format(holidays, format = '%b %d, %Y'),
  )
}

# holiday calendar
holiday_cal <- get_cu_holidays(yr)

holiday_cal2 <- holiday_cal %>%
  filter(actual_date >= start_date & actual_date <= end_date)

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
  mutate(code = paste0("adminInd == 1 & between(fcqEnDt,'", Wednesday, "','", Tuesday, "') ~ '", date_sessions, "',"))

# run the following calls and follow "instructions for FCQ_Audit03.R" below
cat(date_cal2$code, sep = '\n')
cat(holiday_cal2$actual_formatted, sep = '\n')

#############################################################################
# instructions for FCQ_Audit03.R
#############################################################################

# copy date_cal2 output in console and paste into FCQ_Audit03.R
# cleanup formatting and dates (e.g., beg, end, finals)
# use holiday_cal2 output to adjust the session dates as needed
#   if Monday holiday, run session Tuesday - Saturday
#   if midweek holiday (Juneteenth, July 4), run session Monday - Saturday
#   if weekend holiday, run session normally
#   note that Thanksgiving coincides with fall break, so no change required


#############################################################################
# instructions for fcq calendar
#############################################################################

library(tibble)

# create web calendar
fcq_calendar <- date_cal2 %>%
  mutate(Session = row_number()) %>%
  mutate(FCQ_Dates = date_sessions) %>%
  mutate(Wednesday = as.Date(Wednesday, format = '%m/%d/%Y')) %>%
  mutate(Tuesday = as.Date(Tuesday, format = '%m/%d/%Y')) %>%
  mutate(CIW_end_date = paste0('between ', format(Wednesday, '%b %d'), '-', format(Tuesday, '%b %d'))) %>%
  mutate(weekday = 'Monday-Friday') %>%
  select(Session, FCQ_Dates, weekday, CIW_end_date)

# review output
print(fcq_calendar)

# generate html code for website
knitr::kable(fcq_calendar, format = "html", table.attr = "style='width:100%'")

# copy fcq_calendar output in console and paste into FCQ calendar website
# fix dates (e.g., remove pre-, final, and post-sessions)
# update semester timeline
