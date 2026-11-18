#!/bin/sh
# Build and tests pass; the old file and type name are gone and the new ones exist.
set -eu
sh /project/check.sh
[ ! -e MediaBrowser.Providers/Books/ComicImageProvider.cs ] || { echo "old file still present"; exit 1; }
[ -e MediaBrowser.Providers/Books/ComicBookImageProvider.cs ] || { echo "new file missing"; exit 1; }
if grep -rIlw --include='*.cs' ComicImageProvider . | grep -q .; then echo "old type name ComicImageProvider is still present"; exit 1; fi
grep -qw ComicBookImageProvider MediaBrowser.Providers/Books/ComicBookImageProvider.cs || { echo "type not renamed"; exit 1; }
