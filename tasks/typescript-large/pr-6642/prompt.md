Passing File Path for FileLogger as an option

**Issue type:**

[ ] question
[ ] bug report
[x] feature request
[ ] documentation issue

**Database system/driver:**

[ ] `cordova`
[ ] `mongodb`
[ ] `mssql`
[ ] `mysql` / `mariadb`
[ ] `oracle`
[ ] `postgres`
[ ] `cockroachdb`
[ ] `sqlite`
[ ] `sqljs`
[ ] `react-native`
[ ] `expo`

**TypeORM version:**

[x] `latest`
[ ] `@next`
[ ] `0.x.x` (or put your version here)

**Steps to reproduce or a small repository showing the problem:**

The FileLogger is working really well. The only problem is the file path it's using. I would like to have the file path destination of the file log as an option instead of being hardcoded.

PlatformTools_1.PlatformTools.appendFileSync(basePath + "/ormlogs.log", strings.join("\r\n") + "\r\n");

Thank you



