# Oracle: methods that call Shopware\Core\Content\Media\MediaEntity::getThumbnails directly (src/)

Derived without a language server: PHPStan (version in projects/php-xlarge/locks) by mutation. Rename the declaration to `getThumbnailsStudyMutation`,
run `phpstan analyse --error-format=raw -c study-phpstan.neon` (`parameters: level: 9`) on the files that contain `->getThumbnails(` or
`::getThumbnails(` plus MediaEntity.php; every `Call to an undefined method Shopware\Core\Content\Media\MediaEntity::getThumbnails()` is a call:
12 locations (src/Core/Content/Media/File/FileSaver.php:154, src/Core/Content/Media/File/FileSaver.php:396, src/Core/Content/Media/File/FileSaver.php:400, src/Core/Content/Media/Subscriber/MediaDeletionSubscriber.php:115, src/Core/Content/Media/Subscriber/MediaDeletionSubscriber.php:119, src/Core/Content/Media/Thumbnail/ThumbnailService.php:179, src/Core/Content/Media/Thumbnail/ThumbnailService.php:184, src/Core/Content/Media/Thumbnail/ThumbnailService.php:546, src/Core/Content/Media/Thumbnail/ThumbnailService.php:550, src/Core/Content/Media/Thumbnail/ThumbnailService.php:74, src/Core/Content/Media/Thumbnail/ThumbnailService.php:83, src/Core/Content/Media/Thumbnail/ThumbnailService.php:98). Each location was mapped to the nearest preceding named `function` declaration (no named
function nests another here), giving 6 methods.

Judgement calls: none; calls through other methods are excluded by the prompt (direct callers only).
