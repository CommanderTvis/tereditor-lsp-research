Missing name of the test at tap13 format output when timing is required

**Describe the bug**
When the output format is selected to be tap13 and timing option is selected by -T, the names of failed tests will not be shown.

**To Reproduce**
A test.bats looks like
-----------------------------------------------------
```
load $HOME/test/'test_helper/batsassert/load.bash'
load $HOME/test/'test_helper/batscore/load.bash'

@test "TestToFail" {
  assert_output "None"
}
```
bats -T -F tap13 test.bats gives the following output,
```
TAP version 13
1..1

  ---
  duration_ms: 6
  message: |
     (from function `assert_output' in file /root/test/test_helper/batsassert/src/assert.bash, line 239,"
      in test file ./script.bats, line 35)"
       `assert_output "dd"' failed"
     -- output differs --"
     expected : None"
     actual   :"
     --"
  ...
```

------------------------------------------------------

**Expected behavior**
Expect to see `not ok 1 TestToFail` in the output.

