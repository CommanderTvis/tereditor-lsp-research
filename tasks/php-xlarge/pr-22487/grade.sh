#!/bin/sh
# shopware/shopware#22487 at its base commit: the library's syntax check, then the pull request's test file(s) (its new tests fail before
# the fix; the other tests of the file(s) pass before and after).
set -e
exec sh /project/check.sh tests/unit/Core/Content/Media/Commands/GenerateMediaTypesCommandTest.php tests/unit/Core/Content/Media/Commands/GenerateThumbnailsCommandTest.php tests/unit/Core/Framework/Demodata/Generator/MediaGeneratorTest.php tests/unit/Core/Maintenance/SalesChannel/Command/SalesChannelReplaceUrlCommandTest.php tests/unit/Storefront/Theme/Command/ThemeChangeCommandTest.php tests/unit/Storefront/Theme/Message/CompileThemeHandlerTest.php tests/unit/Storefront/Theme/ThemeServiceTest.php
