# Scheduling

CronCreate jobs live only inside the current session and expire within 7 days — never offer them for anything that must outlive the session. Durable schedules are cloud routines: the schedule skill / RemoteTrigger, cron in UTC (fixed offset — local time drifts across DST), minimum interval 1 hour. Routines cannot be deleted via API; only at claude.ai/code/routines.
