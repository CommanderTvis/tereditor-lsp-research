'typeorm' does not provide an export named 'Column'

**Issue type:**

[X] bug report
[ ] feature request
[ ] documentation issue

**Database system/driver:**

[ ] `cordova`
[ ] `mongodb`
[ ] `mssql`
[X] `mysql` / `mariadb`
[ ] `oracle`
[ ] `postgres`
[ ] `cockroachdb`
[ ] `sqlite`
[ ] `sqljs`
[ ] `react-native`
[ ] `expo`

**TypeORM version:**

[X] `latest`
[ ] `@next`
[ ] `0.x.x` (or put your version here)

**Steps to reproduce or a small repository showing the problem:**
If i initialize my MySQL Connection over typeorm with my Accounts entityi get this error:

```ts
import { BaseEntity, Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
                     ^^^^^^
SyntaxError: The requested module 'typeorm' does not provide an export named 'Column'
```
my Accounts entity
```ts
import { BaseEntity, Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
@Entity({ name: 'accounts' })
export class Accounts extends BaseEntity {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'varchar' })
    username: string;

    @Column({ type: 'varchar' })
    password: string;

    @Column({ type: 'varchar' })
    hardwareID: string;

    @Column({ type: 'int' })
    maxCharacter: number;
} 
```
