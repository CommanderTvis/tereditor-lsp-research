Slashes get cut off in CronStr

When creating a CronStr with Slashes (i.e. every 5 minutes = 0/5) this only works with wildcards (*).

Example:
```schedule = Schedule(cron="*/5 * * * *")
print(schedule.cron)
*/5 * * * *
schedule = Schedule(cron="0/5 * * * *")
print(schedule.cron)
0 * * * *
schedule = Schedule(cron="30/5 * * * *")
print(schedule.cron)
30 * * * *
```

The last example (which I need in my application) is meant to be "every five minutes from the 30th minute", so at :30, :35,..., :55.

I will submit a merge request for this.
