#!/bin/sh
# Intelephense resolves third-party types by indexing vendor/. There is no PHP or composer in the server's sandbox, so
# the packages locked for this commit (locks/<sha256 of composer.json, first 16 hex>.lock, the same lock grading
# installs) are fetched at their locked source commits and exported with `git archive` (which honours export-ignore,
# like a composer dist install). Generated from the lock files by the curation script; vendor/ is git-ignored upstream,
# so none of this is part of the agent's diff.
set -eu
h=$(sha256sum composer.json | cut -c1-16)
list() {
  case "$h" in
    8e4b9a09ccec4a74) cat <<'LIST'
brick/math https://github.com/brick/math.git 2effe05d2177c451b86c6a073196a4034c02f211
carbonphp/carbon-doctrine-types https://github.com/CarbonPHP/carbon-doctrine-types.git 5fa5eacafd9ef47c8c6ab9143fc901ba0194d3dc
dflydev/dot-access-data https://github.com/dflydev/dflydev-dot-access-data.git a23a2bf4f31d3518f3ecb38660c95715dfead60f
doctrine/inflector https://github.com/doctrine/inflector.git 46351b6812b7b6d52b82c3efa5dfb786a198ec88
doctrine/lexer https://github.com/doctrine/lexer.git 71d305eaa6480d3d3460c7d053d1da7749fa9cca
dragonmantank/cron-expression https://github.com/dragonmantank/cron-expression.git 4189372ffeff09bf14f731f67a9de90c7b413ebe
egulias/email-validator https://github.com/egulias/EmailValidator.git d42c8731f0624ad6bdc8d3e5e9a4524f68801cfa
fruitcake/php-cors https://github.com/fruitcake/php-cors.git 38aaa6c3fd4c157ffe2a4d10aa8b9b16ba8de379
graham-campbell/result-type https://github.com/GrahamCampbell/Result-Type.git adccca3324eece92ca35463648c12b9e6293c05b
guzzlehttp/guzzle https://github.com/guzzle/guzzle.git f8aca40edffeae0ec508b92f4594766083c6e203
guzzlehttp/promises https://github.com/guzzle/promises.git 094d0ec418eb3b1411ea271a180ec95cae6ae933
guzzlehttp/psr7 https://github.com/guzzle/psr7.git 180bd6fcebd1dc289cbec5c576135f4b6f576e02
guzzlehttp/uri-template https://github.com/guzzle/uri-template.git 7a466ad606491eb6528c717482f7cca77f1851f3
laravel/prompts https://github.com/laravel/prompts.git abdfc75a1ae6c6f21522daed50da7124cbff09d2
laravel/serializable-closure https://github.com/laravel/serializable-closure.git 2bfb44e8af009b553ed2c060c94b0bc3c67b4769
league/commonmark https://github.com/thephpleague/commonmark.git 8eb53e906fd60c67038d22f1f1cab420ed58b8be
league/config https://github.com/thephpleague/config.git 754b3604fb2984c71f4af4a9cbe7b57f346ec1f3
league/flysystem https://github.com/thephpleague/flysystem.git f7fb152932f30072d573510cbd4dd657d6475b25
league/flysystem-local https://github.com/thephpleague/flysystem-local.git a099b24dce160f3b2239043d13d47c4a1a214ea4
league/mime-type-detection https://github.com/thephpleague/mime-type-detection.git f5f47eff7c48ed1003069a2ca67f316fb4021c76
league/uri https://github.com/thephpleague/uri.git be89e2382e37acdef232259071ade5180821397b
league/uri-interfaces https://github.com/thephpleague/uri-interfaces.git ea66240cff4ae9a56ce85d577a04d038b771e51c
monolog/monolog https://github.com/Seldaek/monolog.git d7059e4c691d05ea1222b5124bed0f961be46e15
nesbot/carbon https://github.com/CarbonPHP/carbon.git ce0e5636fae7d1e99856eb70cae4c719a284aa08
nette/schema https://github.com/nette/schema.git af9fa8a86bfca9b02b10346220db26e62ef942ec
nette/utils https://github.com/nette/utils.git 6bf24518accf32cf845bca305e0b92078700fd01
nunomaduro/termwind https://github.com/nunomaduro/termwind.git 9b85ae4d802403bfc004ea633ce542bc262ee5c3
phpoption/phpoption https://github.com/schmittjoh/php-option.git 67b192b6a42ec03944b972d6e633ddec78ad2c6d
psr/clock https://github.com/php-fig/clock.git e41a24703d4560fd0acb709162f73b8adfc3aa0d
psr/container https://github.com/php-fig/container.git c71ecc56dfe541dbd90c5360474fbc405f8d5963
psr/event-dispatcher https://github.com/php-fig/event-dispatcher.git dbefd12671e8a14ec7f180cab83036ed26714bb0
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-factory https://github.com/php-fig/http-factory.git 2b4765fddfe3b508ac62f829e852b1501d3f6e8a
psr/http-message https://github.com/php-fig/http-message.git 402d35bcb92c70c026d1a6a9883f06b2ead23d71
psr/log https://github.com/php-fig/log.git f16e1d5863e37f8d8c2a01719f5b34baa2b714d3
psr/simple-cache https://github.com/php-fig/simple-cache.git 764e0b3939f5ca87cb904f570ef9be2d78a07865
ramsey/collection https://github.com/ramsey/collection.git 344572933ad0181accbf4ba763e85a0306a8c5e2
ramsey/uuid https://github.com/ramsey/uuid.git 75d73f48d02797c2c285a7e9f348fadc0102ffe2
symfony/clock https://github.com/symfony/clock.git 945ea3b64d6da9c1c2c354fe5c07b27455df6442
symfony/console https://github.com/symfony/console.git 5a315b092b81f3e920e9daea1a2ae4c66ed298b9
symfony/css-selector https://github.com/symfony/css-selector.git 9cfd588b8b07cf83e3426b030dbafd2291c132d9
symfony/deprecation-contracts https://github.com/symfony/deprecation-contracts.git feb1edf4e546af3b85c5caebe8359a20db230ca3
symfony/error-handler https://github.com/symfony/error-handler.git 84c6d73f990ae22dbd45625c056d7ff99ca6810d
symfony/event-dispatcher https://github.com/symfony/event-dispatcher.git 7458da64220376b2e0dc2d8451bf43382c1ad297
symfony/event-dispatcher-contracts https://github.com/symfony/event-dispatcher-contracts.git 658e29751424da3ef4758c60f769e59d1b2981eb
symfony/finder https://github.com/symfony/finder.git a2902e479ba5691d20d51d100a715ea19ad2c837
symfony/http-foundation https://github.com/symfony/http-foundation.git 30fa3efe6e736b0d06f5331cc6abe813582c0a26
symfony/http-kernel https://github.com/symfony/http-kernel.git 460658504e26a2794aa614b4fbe6cf9bac2076fe
symfony/mailer https://github.com/symfony/mailer.git 4ba81a8f04fbf0bb1691f7bff760b301f1956fd7
symfony/mime https://github.com/symfony/mime.git 8d1232052c9cdef170ed9608b3147bca4f61ff69
symfony/polyfill-ctype https://github.com/symfony/polyfill-ctype.git 141046a8f9477948ff284fa65be2095baafb94f2
symfony/polyfill-intl-grapheme https://github.com/symfony/polyfill-intl-grapheme.git 5a8f33c87aeecffce24e721b5064fab05f4becf8
symfony/polyfill-intl-idn https://github.com/symfony/polyfill-intl-idn.git 533d68cf99c8f8ee2e8893c59ed59192e92cfd74
symfony/polyfill-intl-normalizer https://github.com/symfony/polyfill-intl-normalizer.git ebd57ccc7edb93d632e184efbe7693d2517bab3b
symfony/polyfill-mbstring https://github.com/symfony/polyfill-mbstring.git 122889ed24dc000165bcbfd77ec412f15cbdfc6a
symfony/polyfill-php80 https://github.com/symfony/polyfill-php80.git 9c6a5d6b01ca51d486c813e9a9c0ed55f208bb74
symfony/polyfill-php82 https://github.com/symfony/polyfill-php82.git 843bbe8b2a7934307b749751eede0f111f5d1cfc
symfony/polyfill-php84 https://github.com/symfony/polyfill-php84.git 22c6548499cbe5c5bb072fc0c42312dff062a015
symfony/polyfill-php85 https://github.com/symfony/polyfill-php85.git 86a42cbcc07adc331481a5ab310a4024bfc227f6
symfony/polyfill-php86 https://github.com/symfony/polyfill-php86.git 8840df45b24f33a49dc419fa18dc0057231ae1d8
symfony/polyfill-time https://github.com/symfony/polyfill-time.git ac9f1ed802dd58f37e720388130c088434aa09fc
symfony/polyfill-uuid https://github.com/symfony/polyfill-uuid.git b23ff8245cc5c4479ea2be3d0132d2e6dd433993
symfony/process https://github.com/symfony/process.git 08aa69fa0998bb65a089f9e148a2c0f8b391398e
symfony/routing https://github.com/symfony/routing.git f3fefc6cad3748d538be970ca81b71f06d7aa8b3
symfony/service-contracts https://github.com/symfony/service-contracts.git 052852a96fd5e5ebdb617dba22031e41a3300fb5
symfony/string https://github.com/symfony/string.git 6c6110979c0150393bbb336170e286d51ab4d76c
symfony/translation https://github.com/symfony/translation.git d065adf56e5508293e80d7c140b0a9e043b63e9c
symfony/translation-contracts https://github.com/symfony/translation-contracts.git 0a3ae917402632fcba2aeddae9c98332f3d7dd05
symfony/uid https://github.com/symfony/uid.git cb487cf30380f0b0b090973bb9c0588193c06685
symfony/var-dumper https://github.com/symfony/var-dumper.git 3412a5af7d34a19515a77890fc804fe8e50d1a4f
tijsverkoyen/css-to-inline-styles https://github.com/tijsverkoyen/CssToInlineStyles.git f0292ccf0ec75843d65027214426b6b163b48b41
vlucas/phpdotenv https://github.com/phpdotenv/phpdotenv.git 96149103e62ac67e915f6d2ef59b72dee2e011e0
voku/portable-ascii https://github.com/voku/portable-ascii.git 8e1051fe39379367aecf014f41744ce7539a856f
ably/pubsub-server https://github.com/ably/ably-pubsub-php.git 112950fde31d83227e3873305cc018e3f9466ab9
aws/aws-crt-php https://github.com/awslabs/aws-crt-php.git d71d9906c7bb63a28295447ba12e74723bd3730e
aws/aws-sdk-php https://github.com/aws/aws-sdk-php.git 39b30513acab6e4cdcca6d8e179d4f4d98189f78
composer/semver https://github.com/composer/semver.git d92543b7ede9c4ec6b59853cefb061e39866d2cf
fakerphp/faker https://github.com/FakerPHP/Faker.git e0ee18eb1e6dc3cda3ce9fd97e5a0689a88a64b5
hamcrest/hamcrest-php https://github.com/hamcrest/hamcrest-php.git b61cd040da1a4925bc90a51c074f5297e7c0fa52
intervention/gif https://github.com/Intervention/gif.git bb395af960deffe64d70c976b4df9283f68e762d
intervention/image https://github.com/Intervention/image.git 3a47838f2e0f4ec6c8c9b43a5d73ac985b975830
jasonmccreary/double https://github.com/jasonmccreary/double.git e16e1a4bdd9837e8974baac492b9bc5e084b34e3
laravel/pint https://github.com/laravel/pint.git 1cf8e0320bed4b3c6e51df92039a5636c3887728
league/flysystem-aws-s3-v3 https://github.com/thephpleague/flysystem-aws-s3-v3.git b03780cb97585ee7e48977f40ed599b33b751634
league/flysystem-ftp https://github.com/thephpleague/flysystem-ftp.git 878dde9b0e5baf5076855adb0e7737d8553876da
league/flysystem-path-prefixing https://github.com/thephpleague/flysystem-path-prefixing.git d7f667c2d9d6684b74f30c6ad81ae7a0c23232f3
league/flysystem-read-only https://github.com/thephpleague/flysystem-read-only.git 46ac89575200417154712a4bd0d58ce481e6b191
league/flysystem-sftp-v3 https://github.com/thephpleague/flysystem-sftp-v3.git 5004b451cedd3bc4fdf84fcd427b858ec1b66a02
mockery/mockery https://github.com/mockery/mockery.git 967a801bd188989a5669bd280f252d51c0fdc9ee
mtdowling/jmespath.php https://github.com/jmespath/jmespath.php.git 2157c5e50e813ec6a96c1eed3be7f64a20fb32a8
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
opis/json-schema https://github.com/opis/json-schema.git b87b424da3fbeaab09567910fda48dc88d9dcbd8
opis/string https://github.com/opis/string.git 3e4d2aaff518ac518530b89bb26ed40f4503635e
opis/uri https://github.com/opis/uri.git 0f3ca49ab1a5e4a6681c286e0b2cc081b93a7d5a
orchestra/sidekick https://github.com/orchestral/sidekick.git cbdfe583afc069be2ca6790489e9dda007d14d00
orchestra/testbench-core https://github.com/orchestral/testbench-core.git 237c374996a8346fa76b8002a02fb65000bb95a7
paragonie/constant_time_encoding https://github.com/paragonie/constant_time_encoding.git 5efef6e6cb43e088ccab7d0c1e2f2ab25b9e8b54
paragonie/random_compat https://github.com/paragonie/random_compat.git 996434e5492cb4c3edcb9168db6fbb1359ef965a
pda/pheanstalk https://github.com/pheanstalk/pheanstalk.git e915a4cad2f4d8fc9a7c9165c80785985d2571ad
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
php-http/discovery https://github.com/php-http/discovery.git 82fe4c73ef3363caed49ff8dd1539ba06044910d
phpseclib/phpseclib https://github.com/phpseclib/phpseclib.git 91f3a6436bb84040ac0cf49e761977f17d16a39b
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 2f122b9b48af71ad9b4448368febc26af86534c9
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git 9bb4e6c58b62c1e043be995c66abec7c97307aae
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 42e5c5cae0c65df12d1b1a3ab52bf3f50f244d88
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git 97107691cb2b6c743b5e0c44be19e983cb337a02
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git a0e12065831f6ab0d83120dc61513eb8d9a966f6
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git e6458d44279e3b4fc492d4c41fe8e677efed7a2c
predis/predis https://github.com/predis/predis.git 2496e6d91ba4e137b47a6b802dc7e088ebf31df4
psr/cache https://github.com/php-fig/cache.git aa5030cfa5405eccfdcb1083ce040c2cb8d253bf
psr/link https://github.com/php-fig/link.git 84b159194ecfd7eaa472280213976e96415433f7
rector/rector https://github.com/rectorphp/rector.git 7e46709996a4b3dc59e1d6ecbb6a38ace335bd58
resend/resend-php https://github.com/resend/resend-php.git f615aaa9bde31a0235dd2f9856cbbea63bf14ac9
rybakit/msgpack https://github.com/rybakit/msgpack.php.git f483081fe9eb611f6787b63b62dc4593fe2358e8
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git eeb759ad3146b7096fb59c3195d39e071cd409e3
sebastian/comparator https://github.com/sebastianbergmann/comparator.git 3b070e608146cba00fd6fd1f0ffba89e5a8897fb
sebastian/complexity https://github.com/sebastianbergmann/complexity.git c5651c795c98093480df79350cb050813fc7a2f3
sebastian/diff https://github.com/sebastianbergmann/diff.git a2df6626c1baf31d5a88674882a3072f151b5a26
sebastian/environment https://github.com/sebastianbergmann/environment.git d4dd10267a11055066a2a78ae04583d8ddd4f595
sebastian/exporter https://github.com/sebastianbergmann/exporter.git 24a3b69bba4a12ab615fca9d34680c5598d9ab7a
sebastian/file-filter https://github.com/sebastianbergmann/file-filter.git 33a26f394330f6faa7684bb9cc73afb7727aae93
sebastian/git-state https://github.com/sebastianbergmann/git-state.git 31a565f463686f0eefa85f899549256bf5805985
sebastian/global-state https://github.com/sebastianbergmann/global-state.git ba68ba79da690cf7eddefd3ce5b78b20b9ba9945
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git d1b6f8fce682505dbd048977f1abedf1b8ad3ff8
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 511064ecde82bd747e2ba2fab3dda8d977b59576
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git f71bbcdc4f95456b4622810bec64eb06372e25b2
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git 32dba72f2b4642d6a93db22d6c0a9280ff2e3ca0
sebastian/type https://github.com/sebastianbergmann/type.git bd1df467864cb95140414059a535b2d906173fcf
sebastian/version https://github.com/sebastianbergmann/version.git 08e41d0c7e146bfc8cef7e63989b1294453a6d6a
spomky-labs/pki-framework https://github.com/Spomky-Labs/pki-framework.git 792e909d4e387adffe3c4f404451c7d57a3d2022
staabm/side-effects-detector https://github.com/staabm/side-effects-detector.git d8334211a140ce329c13726d4a715adbddd0a163
symfony/cache https://github.com/symfony/cache.git 60b6bfd51e671219b1ab9066b94c617d1760d7cf
symfony/cache-contracts https://github.com/symfony/cache-contracts.git af26a91232085b7edd4e04be62f75e7c25159ece
symfony/filesystem https://github.com/symfony/filesystem.git 58f57b6a33e3495f7f41e01258f1ae5ef76cccd2
symfony/http-client https://github.com/symfony/http-client.git 1758b323ba9c5e88b42602b9c2cb27b640de4d36
symfony/http-client-contracts https://github.com/symfony/http-client-contracts.git f9f94260f787446c6fd430b2ae1969fe41ae1ba8
symfony/mercure https://github.com/symfony/mercure.git 920f08c73793f37e94981e5d9fc1a84351ec8c6c
symfony/polyfill-deepclone https://github.com/symfony/polyfill-deepclone.git 82274308b59f6e96f53a3fb37fc40877d843e5a5
symfony/polyfill-php83 https://github.com/symfony/polyfill-php83.git 80ccff923a8d61f73ebe9da0aa94e25232f004ce
symfony/psr-http-message-bridge https://github.com/symfony/psr-http-message-bridge.git cfa8f3ac693fec234a91d8745b45ed9a81a0b799
symfony/var-exporter https://github.com/symfony/var-exporter.git e94442cdefc1df995528d26acb40d25c2d50504d
symfony/web-link https://github.com/symfony/web-link.git 87ca04297acf837a1de25d3f6c31b9551235dcbd
web-token/jwt-library https://github.com/web-token/jwt-library.git 62643a2f31274c546a7d158ceab6dd5c052db911
LIST
    ;;
    *) echo "prepare.sh: no lock for composer.json $h" >&2; exit 1 ;;
  esac
}
pkgs=$(mktemp); list > "$pkgs"
while read -r name url ref; do
  [ -n "$name" ] || continue
  tmp=$(mktemp -d)
  git -C "$tmp" init -q && git -C "$tmp" fetch -q --depth 1 "$url" "$ref"
  mkdir -p "vendor/$name" && git -C "$tmp" archive FETCH_HEAD | tar -x -C "vendor/$name"
  rm -rf "$tmp"
done < "$pkgs"
rm -f "$pkgs"
git check-ignore -q vendor
