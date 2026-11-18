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
    1e333a07bb648990) cat <<'LIST'
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
laravel/framework https://github.com/laravel/framework.git f5c01f6b63803f16f38ebb31622c4fea412bd022
laravel/prompts https://github.com/laravel/prompts.git abdfc75a1ae6c6f21522daed50da7124cbff09d2
laravel/serializable-closure https://github.com/laravel/serializable-closure.git 2bfb44e8af009b553ed2c060c94b0bc3c67b4769
league/commonmark https://github.com/thephpleague/commonmark.git 8eb53e906fd60c67038d22f1f1cab420ed58b8be
league/config https://github.com/thephpleague/config.git 754b3604fb2984c71f4af4a9cbe7b57f346ec1f3
league/flysystem https://github.com/thephpleague/flysystem.git f7fb152932f30072d573510cbd4dd657d6475b25
league/flysystem-local https://github.com/thephpleague/flysystem-local.git a099b24dce160f3b2239043d13d47c4a1a214ea4
league/mime-type-detection https://github.com/thephpleague/mime-type-detection.git f5f47eff7c48ed1003069a2ca67f316fb4021c76
league/uri https://github.com/thephpleague/uri.git be89e2382e37acdef232259071ade5180821397b
league/uri-interfaces https://github.com/thephpleague/uri-interfaces.git ea66240cff4ae9a56ce85d577a04d038b771e51c
monolog/monolog https://github.com/Seldaek/monolog.git 1f5f55bb4a9a230ff6d8a4ceccea31d10b0142ac
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nesbot/carbon https://github.com/CarbonPHP/carbon.git ce0e5636fae7d1e99856eb70cae4c719a284aa08
nette/schema https://github.com/nette/schema.git af9fa8a86bfca9b02b10346220db26e62ef942ec
nette/utils https://github.com/nette/utils.git 6bf24518accf32cf845bca305e0b92078700fd01
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
nunomaduro/termwind https://github.com/nunomaduro/termwind.git 9b85ae4d802403bfc004ea633ce542bc262ee5c3
phpoption/phpoption https://github.com/schmittjoh/php-option.git 67b192b6a42ec03944b972d6e633ddec78ad2c6d
phpstan/phpdoc-parser https://github.com/phpstan/phpdoc-parser.git af8e840551031d254cfdb3a18a62c3470a309c10
psr/clock https://github.com/php-fig/clock.git e41a24703d4560fd0acb709162f73b8adfc3aa0d
psr/container https://github.com/php-fig/container.git c71ecc56dfe541dbd90c5360474fbc405f8d5963
psr/event-dispatcher https://github.com/php-fig/event-dispatcher.git dbefd12671e8a14ec7f180cab83036ed26714bb0
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-factory https://github.com/php-fig/http-factory.git 2b4765fddfe3b508ac62f829e852b1501d3f6e8a
psr/http-message https://github.com/php-fig/http-message.git 402d35bcb92c70c026d1a6a9883f06b2ead23d71
psr/log https://github.com/php-fig/log.git f16e1d5863e37f8d8c2a01719f5b34baa2b714d3
psr/simple-cache https://github.com/php-fig/simple-cache.git 764e0b3939f5ca87cb904f570ef9be2d78a07865
ramsey/collection https://github.com/ramsey/collection.git 344572933ad0181accbf4ba763e85a0306a8c5e2
ramsey/uuid https://github.com/ramsey/uuid.git f9aa3efc8015fcbc013d84d699583b268ccb593a
spatie/laravel-package-tools https://github.com/spatie/laravel-package-tools.git 7aeef26bd8d4909bec744dbf47aee7d1395588c1
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
symfony/polyfill-php85 https://github.com/symfony/polyfill-php85.git 94c794cb5ba51784bc259f11e9f128593297d8dc
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
brianium/paratest https://github.com/paratestphp/paratest.git 81c80677c9ec0ed4ef16b246167f11dec81a6e3d
composer/pcre https://github.com/composer/pcre.git d5a341b3fb61f3001970940afb1d332968a183ed
composer/semver https://github.com/composer/semver.git d92543b7ede9c4ec6b59853cefb061e39866d2cf
composer/xdebug-handler https://github.com/composer/xdebug-handler.git 6c1925561632e83d60a44492e0b344cf48ab85ef
doctrine/deprecations https://github.com/doctrine/deprecations.git d2e16653a734c8784c1851ad68b02f997b53ca82
fakerphp/faker https://github.com/FakerPHP/Faker.git e0ee18eb1e6dc3cda3ce9fd97e5a0689a88a64b5
fidry/cpu-core-counter https://github.com/theofidry/cpu-core-counter.git d384a7d0d6e67aa497327260ca95023e92dc2032
filp/whoops https://github.com/filp/whoops.git d5480d53f10069dc4620a39f87e38e8945d47322
hamcrest/hamcrest-php https://github.com/hamcrest/hamcrest-php.git b61cd040da1a4925bc90a51c074f5297e7c0fa52
iamcal/sql-parser https://github.com/iamcal/SQLParser.git 610392f38de49a44dab08dc1659960a29874c4b8
jean85/pretty-package-versions https://github.com/Jean85/pretty-package-versions.git 4d7aa5dab42e2a76d99559706022885de0e18e1a
larastan/larastan https://github.com/larastan/larastan.git ffb29680700b7e56000183ddacd68fab991f690b
laravel/pail https://github.com/laravel/pail.git 72d615ff1104717c1317c6d5d7eab679e43a0408
laravel/pint https://github.com/laravel/pint.git 1cf8e0320bed4b3c6e51df92039a5636c3887728
laravel/scout https://github.com/laravel/scout.git 19431c40c79b1886a8f9da44205467633ae95a2c
laravel/tinker https://github.com/laravel/tinker.git 5fab2518167975b302e10d1fdf9a8c8113849201
mockery/mockery https://github.com/mockery/mockery.git 967a801bd188989a5669bd280f252d51c0fdc9ee
nunomaduro/collision https://github.com/nunomaduro/collision.git 68806f9257968f23775bee62970cb90925b79d51
orchestra/canvas https://github.com/orchestral/canvas.git d13e6ec66cb1a285fcc7f092c804abaaf2e24ede
orchestra/canvas-core https://github.com/orchestral/canvas-core.git 88d091ff989748e2ca447bca0cd06ab14671ba82
orchestra/sidekick https://github.com/orchestral/sidekick.git cbdfe583afc069be2ca6790489e9dda007d14d00
orchestra/testbench https://github.com/orchestral/testbench.git 7081895e5bbbdf2fd333fdf34e8ddec6cd4db713
orchestra/testbench-core https://github.com/orchestral/testbench-core.git 237c374996a8346fa76b8002a02fb65000bb95a7
orchestra/workbench https://github.com/orchestral/workbench.git 660046639af4538d6c56373c9222ca4c93055c42
pestphp/pest https://github.com/pestphp/pest.git 5b2293f67adcf1b2320b33f521b94a692d18f360
pestphp/pest-plugin https://github.com/pestphp/pest-plugin.git 9d4b93d7f73d3f9c3189bb22c220fef271cdf568
pestphp/pest-plugin-arch https://github.com/pestphp/pest-plugin-arch.git 3fb0d02a91b9da504b139dc7ab2a31efb7c3215c
pestphp/pest-plugin-laravel https://github.com/pestphp/pest-plugin-laravel.git 3057a36669ff11416cc0dc2b521b3aec58c488d0
pestphp/pest-plugin-mutate https://github.com/pestphp/pest-plugin-mutate.git d9b32b60b2385e1688a68cc227594738ec26d96c
pestphp/pest-plugin-profanity https://github.com/pestphp/pest-plugin-profanity.git 343cfa6f3564b7e35df0ebb77b7fa97039f72b27
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
phpdocumentor/reflection-common https://github.com/phpDocumentor/ReflectionCommon.git ee15a5a2022c8383906b225055e9496a6a5e6e3b
phpdocumentor/reflection-docblock https://github.com/phpDocumentor/ReflectionDocBlock.git 7bae67520aa9f5ecc506d646810bd40d9da54582
phpdocumentor/type-resolver https://github.com/phpDocumentor/TypeResolver.git dbe2133bb23e2e33a6834f4ed417f24a1b167769
phpstan/extension-installer https://github.com/phpstan/extension-installer.git 85e90b3942d06b2326fba0403ec24fe912372936
phpstan/phpstan-deprecation-rules https://github.com/phpstan/phpstan-deprecation-rules.git 67bedd65c24bc72840afc45aed48b1059dd44bec
phpstan/phpstan-phpunit https://github.com/phpstan/phpstan-phpunit.git ffff35d4f96c4642d7f41a3515d90afa0f58be62
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 7440368d94738d54f2c1de24dbd3871793bbb0dd
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git a248d1640ab059b075f53a2ef0f9856e864e06b5
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 12b54e689b07a25a9b41e57736dfab6ec9ae5406
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git babab73b7ef9fae406f2eb3ee11323a61caa63d5
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git f258ce36aa457f3aa3339f9ed4c81fc66dc8c2cc
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git b98e028a26c5c5ba7e4a54be96ccf35f2914d184
psy/psysh https://github.com/bobthecow/psysh.git ca0fdcf8a7617afa3adfdf1b5fef573dffb69ca1
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git 7d05781b13f7dec9043a629a21d086ed74582a15
sebastian/comparator https://github.com/sebastianbergmann/comparator.git 7c65c1e79836812819705b473a90c12399542485
sebastian/complexity https://github.com/sebastianbergmann/complexity.git bad4316aba5303d0221f43f8cee37eb58d384bbb
sebastian/diff https://github.com/sebastianbergmann/diff.git cd4cabe39f8a4e8ee6818ba99f10a05561ea4ad6
sebastian/environment https://github.com/sebastianbergmann/environment.git 9d32c685773823b1983e256ae4ecd48a10d6e439
sebastian/exporter https://github.com/sebastianbergmann/exporter.git c5e21b5de653ce0a769fb36f5cdfcb5e7a32cf23
sebastian/global-state https://github.com/sebastianbergmann/global-state.git b164d3274d6537ab462591c5755f76a8f5b1aae9
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git d543b8ef219dcd8da262cbb958639a96bedba10e
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 1effe8e9b8e068e9ae228e542d5d11b5d16db894
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git 4bfa827c969c98be1e527abd576533293c634f6a
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git 0b01998a7d5b1f122911a66bebcb8d46f0c82d8c
sebastian/type https://github.com/sebastianbergmann/type.git 82ff822c2edc46724be9f7411d3163021f602773
sebastian/version https://github.com/sebastianbergmann/version.git a8b6643a19ba6c8125a473623e45fb8cbb0e4159
spatie/laravel-permission https://github.com/spatie/laravel-permission.git 15a9daf02ba02d3ae77aaa6da582708231ef999b
spatie/pest-plugin-snapshots https://github.com/spatie/pest-plugin-snapshots.git eaecab46bd481f25d5e1e3f1b89197a8964c00d7
spatie/phpunit-snapshot-assertions https://github.com/spatie/phpunit-snapshot-assertions.git b5ad3efab36e6003c491bb42fb997b226760d5a0
staabm/side-effects-detector https://github.com/staabm/side-effects-detector.git d8334211a140ce329c13726d4a715adbddd0a163
symfony/polyfill-php83 https://github.com/symfony/polyfill-php83.git 80ccff923a8d61f73ebe9da0aa94e25232f004ce
symfony/property-access https://github.com/symfony/property-access.git d080c2afa37114d46e4f950ed8593667f01f7cab
symfony/property-info https://github.com/symfony/property-info.git b5afa379a5b54f15a594c1d45ceaa19969d38a16
symfony/serializer https://github.com/symfony/serializer.git 05624c94507c3acf065b6486bb626f0d741af459
symfony/type-info https://github.com/symfony/type-info.git 9fd1414061c4bbf953bcfc183b133cbfa0a73c73
symfony/yaml https://github.com/symfony/yaml.git e8266f55160f674f290a5f567cb55e11e21f921b
ta-tikoma/phpunit-architecture-test https://github.com/ta-tikoma/phpunit-architecture-test.git 1248f3f506ca9641d4f68cebcd538fa489754db8
theseer/tokenizer https://github.com/theseer/tokenizer.git 7989e43bf381af0eac72e4f0ca5bcbfa81658be4
webmozart/assert https://github.com/webmozarts/assert.git e578132c01bd0c64108386ab20d8217cd175ddec
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
