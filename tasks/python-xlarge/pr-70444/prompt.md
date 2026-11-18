[BUG] scheduler trigger duplicate jobs due multimaster config

**Description**
Salt Scheduler on Windows minion, triggers job twice due it's set up in multimaster.
The job is set to run with queue: True

Here the log shows the duplicate execution, there are two `Running scheduled job: ` almost at the same time separated by miliseconds.

It seems to be erratic, some times after removing the job, using schedule.delete, restarting the minion and adding it again, seems to work, but again erratically, could be all good and a sudden change like modifying the job may cause the issue to trigger again.



```
2025-04-24 05:50:00,067 [salt.utils.schedule:1762][DEBUG   ][4360] schedule: Job schedule_temp_folder_fix was scheduled with jid_include, adding to cache (jid_include defaults to True)
2025-04-24 05:50:00,067 [salt.utils.schedule:1768][DEBUG   ][4360] schedule: Job schedule_temp_folder_fix was scheduled with a max number of 1
2025-04-24 05:50:00,067 [salt.utils.schedule:1792][INFO    ][4360] Running scheduled job: schedule_temp_folder_fix with jid 20250424125000067332
2025-04-24 05:50:00,681 [salt.utils.process:1145][DEBUG   ][4360] Subprocess Schedule(name=schedule_temp_folder_fix, jid=20250424125000067332) added
2025-04-24 05:50:00,734 [salt.utils.schedule:32  ][TRACE   ][4360] ==== evaluating schedule now None =====
2025-04-24 05:50:00,734 [salt.utils.schedule:1762][DEBUG   ][4360] schedule: Job schedule_temp_folder_fix was scheduled with jid_include, adding to cache (jid_include defaults to True)
2025-04-24 05:50:00,734 [salt.utils.schedule:1768][DEBUG   ][4360] schedule: Job schedule_temp_folder_fix was scheduled with a max number of 1
2025-04-24 05:50:00,734 [salt.utils.schedule:1792][INFO    ][4360] Running scheduled job: schedule_temp_folder_fix with jid 20250424125000734042
2025-04-24 05:50:01,226 [salt.utils.process:1145][DEBUG   ][4360] Subprocess Schedule(name=schedule_temp_folder_fix, jid=20250424125000734042) added




2025-04-24 05:50:10,410 [salt.loaded.int.module.cmdmod:922 ][DEBUG   ][3772] stdout: local:

----------

          ID: write_line

    Function: file.append

        Name: C:\\saltLogging.txt

      Result: True

     Comment: Appended 1 lines

     Started: 05:50:08.827882
2025-04-24 05:50:10,410 [salt.loaded.int.module.cmdmod:1352][DEBUG   ][3772] output: local:

----------

          ID: write_line

    Function: file.append

        Name: C:\\saltLogging.txt

      Result: True

     Comment: Appended 1 lines

     Started: 05:50:08.827882



2025-04-24 05:50:12,304 [salt.loaded.int.module.cmdmod:922 ][DEBUG   ][5480] stdout: local:

----------

          ID: write_line

    Function: file.append

        Name: C:\\saltLogging.txt

      Result: True

     Comment: Appended 1 lines

     Started: 05:50:10.410239

2025-04-24 05:50:12,304 [salt.loaded.int.module.cmdmod:1352][DEBUG   ][5480] output: local:

----------

          ID: write_line

    Function: file.append

        Name: C:\\saltLogging.txt

      Result: True

     Comment: Appended 1 lines

     Started: 05:50:10.410239
```

**Setup**
(Please provide relevant configs and/or SLS files (be sure to remove sensitive info. There is no general set-up of Salt.)

Please be as specific as possible and give set-up details.

- [ ] on-prem machine
- [ ] VM (Virtualbox, KVM, etc. please specify)
- [ ] VM running on a cloud service, please be explicit and add details
- [ ] container (Kubernetes, Docker, containerd, etc. please specify)
- [ ] or a combination, please be explicit
- [ ] jails if it is FreeBSD
- [ ] classic packaging
- [ ] onedir packaging
- [ ] used bootstrap to install


**Steps to Reproduce the behavior**
(Include debug logs if possible and relevant)

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Versions Report**
<details><summary>salt --versions-report</summary>
(Provided by running salt --versions-report. Please also mention any differences in master/minion versions.)

```yaml
PASTE HERE
```
</details>

**Additional context**
Add any other context about the problem here.
