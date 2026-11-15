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
    1a517667f37bfec8) cat <<'LIST'
guzzlehttp/promises https://github.com/guzzle/promises.git 67ab6e18aaa14d753cc148911d273f6e6cb6721e
guzzlehttp/psr7 https://github.com/guzzle/psr7.git 6d3cd8285a97eaa352956a4ada92fa03ecce1c4e
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-factory https://github.com/php-fig/http-factory.git 2b4765fddfe3b508ac62f829e852b1501d3f6e8a
psr/http-message https://github.com/php-fig/http-message.git 402d35bcb92c70c026d1a6a9883f06b2ead23d71
ralouphie/getallheaders https://github.com/ralouphie/getallheaders.git 120b605dfeb996808c31b6477290a714d356e822
symfony/deprecation-contracts https://github.com/symfony/deprecation-contracts.git feb1edf4e546af3b85c5caebe8359a20db230ca3
symfony/polyfill-php80 https://github.com/symfony/polyfill-php80.git 9c6a5d6b01ca51d486c813e9a9c0ed55f208bb74
bamarni/composer-bin-plugin https://github.com/bamarni/composer-bin-plugin.git 641d0663f5ac270b1aeec4337b7856f76204df47
clue/stream-filter https://github.com/clue/stream-filter.git 049509fef80032cb3f051595029ab75b49a3c2f7
doctrine/instantiator https://github.com/doctrine/instantiator.git 23da848e1a2308728fe5fdddabf4be17ff9720c7
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
php-http/client-integration-tests https://github.com/php-http/client-integration-tests.git 86238701ee79963580458f5bfa120bebb7bd0cbb
php-http/message https://github.com/php-http/message.git 06dd5e8562f84e641bf929bfe699ee0f5ce8080a
php-http/message-factory https://github.com/php-http/message-factory.git 4d8778e1c7d405cbb471574821c1ff5b68cc8f57
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 85402a822d1ecf1db1096959413d35e1c37cf1a5
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 5a10147d0aaf65b58940a0b72f71c9ac0423cc67
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git 5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git 5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git 133394556c813b61aa3481a87bef8419d8ec95c0
psr/log https://github.com/php-fig/log.git d49695b909c3b7628b6289db5479a1c204601f11
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git 2b56bea83a09de3ac06bb18b92f068e60cc6f50b
sebastian/code-unit https://github.com/sebastianbergmann/code-unit.git 1fc9f64c0927627ef78ba436c9b17d967e68e120
sebastian/code-unit-reverse-lookup https://github.com/sebastianbergmann/code-unit-reverse-lookup.git ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5
sebastian/comparator https://github.com/sebastianbergmann/comparator.git e4df00b9b3571187db2831ae9aada2c6efbd715d
sebastian/complexity https://github.com/sebastianbergmann/complexity.git 25f207c40d62b8b7aa32f5ab026c53561964053a
sebastian/diff https://github.com/sebastianbergmann/diff.git ba01945089c3a293b01ba9badc29ad55b106b0bc
sebastian/environment https://github.com/sebastianbergmann/environment.git 830c43a844f1f8d5b7a1f6d6076b784454d8b7ed
sebastian/exporter https://github.com/sebastianbergmann/exporter.git 4352c1a3df741a7ba9e61af6fed51d1fee41cbf7
sebastian/global-state https://github.com/sebastianbergmann/global-state.git b6781316bdcd28260904e7cc18ec983d0d2ef4f6
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git e1e4a170560925c26d424b6a03aed157e7dcc5c5
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 5c9eeac41b290a3712d88851518825ad78f45c71
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git b4f479ebdbf63ac605d183ece17d8d7fe49c15c7
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git c85be6922b7fd365942b986b9a50397d65407611
sebastian/resource-operations https://github.com/sebastianbergmann/resource-operations.git 05d5692a7993ecccd56a03e40cd7e5b09b1d404e
sebastian/type https://github.com/sebastianbergmann/type.git 75e2c2a32f5e0b3aef905b9ed0b179b953b3d7c7
sebastian/version https://github.com/sebastianbergmann/version.git c6c1022351a901512170118436c764e473f6de8c
th3n3rd/cartesian-product https://github.com/th3n3rd/cartesian-product.git 78b22f4feb4ef3efc1e99dfe5d932e17024b035d
theseer/tokenizer https://github.com/theseer/tokenizer.git b7489ce515e168639d17feec34b8847c326b0b3c
LIST
    ;;
    6c82894e72f69203) cat <<'LIST'
guzzlehttp/promises https://github.com/guzzle/promises.git 67ab6e18aaa14d753cc148911d273f6e6cb6721e
guzzlehttp/psr7 https://github.com/guzzle/psr7.git 6d3cd8285a97eaa352956a4ada92fa03ecce1c4e
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-factory https://github.com/php-fig/http-factory.git 2b4765fddfe3b508ac62f829e852b1501d3f6e8a
psr/http-message https://github.com/php-fig/http-message.git 402d35bcb92c70c026d1a6a9883f06b2ead23d71
ralouphie/getallheaders https://github.com/ralouphie/getallheaders.git 120b605dfeb996808c31b6477290a714d356e822
symfony/deprecation-contracts https://github.com/symfony/deprecation-contracts.git feb1edf4e546af3b85c5caebe8359a20db230ca3
symfony/polyfill-php80 https://github.com/symfony/polyfill-php80.git 9c6a5d6b01ca51d486c813e9a9c0ed55f208bb74
bamarni/composer-bin-plugin https://github.com/bamarni/composer-bin-plugin.git 641d0663f5ac270b1aeec4337b7856f76204df47
clue/stream-filter https://github.com/clue/stream-filter.git 049509fef80032cb3f051595029ab75b49a3c2f7
doctrine/instantiator https://github.com/doctrine/instantiator.git 23da848e1a2308728fe5fdddabf4be17ff9720c7
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
php-http/client-integration-tests https://github.com/php-http/client-integration-tests.git 86238701ee79963580458f5bfa120bebb7bd0cbb
php-http/message https://github.com/php-http/message.git 06dd5e8562f84e641bf929bfe699ee0f5ce8080a
php-http/message-factory https://github.com/php-http/message-factory.git 4d8778e1c7d405cbb471574821c1ff5b68cc8f57
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 85402a822d1ecf1db1096959413d35e1c37cf1a5
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 5a10147d0aaf65b58940a0b72f71c9ac0423cc67
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git 5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git 5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git 133394556c813b61aa3481a87bef8419d8ec95c0
psr/log https://github.com/php-fig/log.git f16e1d5863e37f8d8c2a01719f5b34baa2b714d3
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git 2b56bea83a09de3ac06bb18b92f068e60cc6f50b
sebastian/code-unit https://github.com/sebastianbergmann/code-unit.git 1fc9f64c0927627ef78ba436c9b17d967e68e120
sebastian/code-unit-reverse-lookup https://github.com/sebastianbergmann/code-unit-reverse-lookup.git ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5
sebastian/comparator https://github.com/sebastianbergmann/comparator.git e4df00b9b3571187db2831ae9aada2c6efbd715d
sebastian/complexity https://github.com/sebastianbergmann/complexity.git 25f207c40d62b8b7aa32f5ab026c53561964053a
sebastian/diff https://github.com/sebastianbergmann/diff.git ba01945089c3a293b01ba9badc29ad55b106b0bc
sebastian/environment https://github.com/sebastianbergmann/environment.git 830c43a844f1f8d5b7a1f6d6076b784454d8b7ed
sebastian/exporter https://github.com/sebastianbergmann/exporter.git 4352c1a3df741a7ba9e61af6fed51d1fee41cbf7
sebastian/global-state https://github.com/sebastianbergmann/global-state.git b6781316bdcd28260904e7cc18ec983d0d2ef4f6
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git e1e4a170560925c26d424b6a03aed157e7dcc5c5
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 5c9eeac41b290a3712d88851518825ad78f45c71
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git b4f479ebdbf63ac605d183ece17d8d7fe49c15c7
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git c85be6922b7fd365942b986b9a50397d65407611
sebastian/resource-operations https://github.com/sebastianbergmann/resource-operations.git 05d5692a7993ecccd56a03e40cd7e5b09b1d404e
sebastian/type https://github.com/sebastianbergmann/type.git 75e2c2a32f5e0b3aef905b9ed0b179b953b3d7c7
sebastian/version https://github.com/sebastianbergmann/version.git c6c1022351a901512170118436c764e473f6de8c
th3n3rd/cartesian-product https://github.com/th3n3rd/cartesian-product.git 78b22f4feb4ef3efc1e99dfe5d932e17024b035d
theseer/tokenizer https://github.com/theseer/tokenizer.git b7489ce515e168639d17feec34b8847c326b0b3c
LIST
    ;;
    a3b1f6dd0497b37c) cat <<'LIST'
guzzlehttp/promises https://github.com/guzzle/promises.git 094d0ec418eb3b1411ea271a180ec95cae6ae933
guzzlehttp/psr7 https://github.com/guzzle/psr7.git 180bd6fcebd1dc289cbec5c576135f4b6f576e02
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-factory https://github.com/php-fig/http-factory.git 2b4765fddfe3b508ac62f829e852b1501d3f6e8a
psr/http-message https://github.com/php-fig/http-message.git 402d35bcb92c70c026d1a6a9883f06b2ead23d71
symfony/deprecation-contracts https://github.com/symfony/deprecation-contracts.git feb1edf4e546af3b85c5caebe8359a20db230ca3
symfony/polyfill-php80 https://github.com/symfony/polyfill-php80.git 9c6a5d6b01ca51d486c813e9a9c0ed55f208bb74
symfony/polyfill-php82 https://github.com/symfony/polyfill-php82.git 843bbe8b2a7934307b749751eede0f111f5d1cfc
bamarni/composer-bin-plugin https://github.com/bamarni/composer-bin-plugin.git 641d0663f5ac270b1aeec4337b7856f76204df47
clue/stream-filter https://github.com/clue/stream-filter.git 049509fef80032cb3f051595029ab75b49a3c2f7
doctrine/instantiator https://github.com/doctrine/instantiator.git 23da848e1a2308728fe5fdddabf4be17ff9720c7
guzzlehttp/test-server https://github.com/guzzle/test-server.git c2365bea39b2059a6bba3c9dba98be2dabf31070
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
php-http/message https://github.com/php-http/message.git 06dd5e8562f84e641bf929bfe699ee0f5ce8080a
php-http/message-factory https://github.com/php-http/message-factory.git 4d8778e1c7d405cbb471574821c1ff5b68cc8f57
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 85402a822d1ecf1db1096959413d35e1c37cf1a5
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 5a10147d0aaf65b58940a0b72f71c9ac0423cc67
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git 5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git 5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git 133394556c813b61aa3481a87bef8419d8ec95c0
psr/log https://github.com/php-fig/log.git f16e1d5863e37f8d8c2a01719f5b34baa2b714d3
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git 2b56bea83a09de3ac06bb18b92f068e60cc6f50b
sebastian/code-unit https://github.com/sebastianbergmann/code-unit.git 1fc9f64c0927627ef78ba436c9b17d967e68e120
sebastian/code-unit-reverse-lookup https://github.com/sebastianbergmann/code-unit-reverse-lookup.git ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5
sebastian/comparator https://github.com/sebastianbergmann/comparator.git e4df00b9b3571187db2831ae9aada2c6efbd715d
sebastian/complexity https://github.com/sebastianbergmann/complexity.git 25f207c40d62b8b7aa32f5ab026c53561964053a
sebastian/diff https://github.com/sebastianbergmann/diff.git ba01945089c3a293b01ba9badc29ad55b106b0bc
sebastian/environment https://github.com/sebastianbergmann/environment.git 830c43a844f1f8d5b7a1f6d6076b784454d8b7ed
sebastian/exporter https://github.com/sebastianbergmann/exporter.git 4352c1a3df741a7ba9e61af6fed51d1fee41cbf7
sebastian/global-state https://github.com/sebastianbergmann/global-state.git b6781316bdcd28260904e7cc18ec983d0d2ef4f6
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git e1e4a170560925c26d424b6a03aed157e7dcc5c5
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 5c9eeac41b290a3712d88851518825ad78f45c71
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git b4f479ebdbf63ac605d183ece17d8d7fe49c15c7
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git c85be6922b7fd365942b986b9a50397d65407611
sebastian/resource-operations https://github.com/sebastianbergmann/resource-operations.git 05d5692a7993ecccd56a03e40cd7e5b09b1d404e
sebastian/type https://github.com/sebastianbergmann/type.git 75e2c2a32f5e0b3aef905b9ed0b179b953b3d7c7
sebastian/version https://github.com/sebastianbergmann/version.git c6c1022351a901512170118436c764e473f6de8c
th3n3rd/cartesian-product https://github.com/th3n3rd/cartesian-product.git 78b22f4feb4ef3efc1e99dfe5d932e17024b035d
theseer/tokenizer https://github.com/theseer/tokenizer.git b7489ce515e168639d17feec34b8847c326b0b3c
LIST
    ;;
    ddc4c689728b45c4) cat <<'LIST'
guzzlehttp/promises https://github.com/guzzle/promises.git 67ab6e18aaa14d753cc148911d273f6e6cb6721e
guzzlehttp/psr7 https://github.com/guzzle/psr7.git e4490cabc77465aaee90b20cfc9a770f8c04be6b
psr/http-client https://github.com/php-fig/http-client.git bb5906edc1c324c9a05aa0873d40117941e5fa90
psr/http-message https://github.com/php-fig/http-message.git cb6ce4845ce34a8ad9e68117c10ee90a29919eba
ralouphie/getallheaders https://github.com/ralouphie/getallheaders.git 120b605dfeb996808c31b6477290a714d356e822
clue/stream-filter https://github.com/clue/stream-filter.git 049509fef80032cb3f051595029ab75b49a3c2f7
doctrine/instantiator https://github.com/doctrine/instantiator.git 23da848e1a2308728fe5fdddabf4be17ff9720c7
myclabs/deep-copy https://github.com/myclabs/DeepCopy.git 8680aa248f8e07bc8fb43f56f0f5fc77a0c96aae
nikic/php-parser https://github.com/nikic/PHP-Parser.git 9e33da9553fe7786f0962b35f4e4ecf01be89def
phar-io/manifest https://github.com/phar-io/manifest.git 54750ef60c58e43759730615a392c31c80e23176
phar-io/version https://github.com/phar-io/version.git 4f7fd7836c6f332bb2933569e566a0d6c4cbed74
php-http/client-integration-tests https://github.com/php-http/client-integration-tests.git 86238701ee79963580458f5bfa120bebb7bd0cbb
php-http/message https://github.com/php-http/message.git 06dd5e8562f84e641bf929bfe699ee0f5ce8080a
php-http/message-factory https://github.com/php-http/message-factory.git 4d8778e1c7d405cbb471574821c1ff5b68cc8f57
phpunit/php-code-coverage https://github.com/sebastianbergmann/php-code-coverage.git 85402a822d1ecf1db1096959413d35e1c37cf1a5
phpunit/php-file-iterator https://github.com/sebastianbergmann/php-file-iterator.git cf1c2e7c203ac650e352f4cc675a7021e7d1b3cf
phpunit/php-invoker https://github.com/sebastianbergmann/php-invoker.git 5a10147d0aaf65b58940a0b72f71c9ac0423cc67
phpunit/php-text-template https://github.com/sebastianbergmann/php-text-template.git 5da5f67fc95621df9ff4c4e5a84d6a8a2acf7c28
phpunit/php-timer https://github.com/sebastianbergmann/php-timer.git 5a63ce20ed1b5bf577850e2c4e87f4aa902afbd2
phpunit/phpunit https://github.com/sebastianbergmann/phpunit.git 133394556c813b61aa3481a87bef8419d8ec95c0
psr/log https://github.com/php-fig/log.git d49695b909c3b7628b6289db5479a1c204601f11
sebastian/cli-parser https://github.com/sebastianbergmann/cli-parser.git 2b56bea83a09de3ac06bb18b92f068e60cc6f50b
sebastian/code-unit https://github.com/sebastianbergmann/code-unit.git 1fc9f64c0927627ef78ba436c9b17d967e68e120
sebastian/code-unit-reverse-lookup https://github.com/sebastianbergmann/code-unit-reverse-lookup.git ac91f01ccec49fb77bdc6fd1e548bc70f7faa3e5
sebastian/comparator https://github.com/sebastianbergmann/comparator.git e4df00b9b3571187db2831ae9aada2c6efbd715d
sebastian/complexity https://github.com/sebastianbergmann/complexity.git 25f207c40d62b8b7aa32f5ab026c53561964053a
sebastian/diff https://github.com/sebastianbergmann/diff.git ba01945089c3a293b01ba9badc29ad55b106b0bc
sebastian/environment https://github.com/sebastianbergmann/environment.git 830c43a844f1f8d5b7a1f6d6076b784454d8b7ed
sebastian/exporter https://github.com/sebastianbergmann/exporter.git 4352c1a3df741a7ba9e61af6fed51d1fee41cbf7
sebastian/global-state https://github.com/sebastianbergmann/global-state.git b6781316bdcd28260904e7cc18ec983d0d2ef4f6
sebastian/lines-of-code https://github.com/sebastianbergmann/lines-of-code.git e1e4a170560925c26d424b6a03aed157e7dcc5c5
sebastian/object-enumerator https://github.com/sebastianbergmann/object-enumerator.git 5c9eeac41b290a3712d88851518825ad78f45c71
sebastian/object-reflector https://github.com/sebastianbergmann/object-reflector.git b4f479ebdbf63ac605d183ece17d8d7fe49c15c7
sebastian/recursion-context https://github.com/sebastianbergmann/recursion-context.git c85be6922b7fd365942b986b9a50397d65407611
sebastian/resource-operations https://github.com/sebastianbergmann/resource-operations.git 05d5692a7993ecccd56a03e40cd7e5b09b1d404e
sebastian/type https://github.com/sebastianbergmann/type.git 75e2c2a32f5e0b3aef905b9ed0b179b953b3d7c7
sebastian/version https://github.com/sebastianbergmann/version.git c6c1022351a901512170118436c764e473f6de8c
th3n3rd/cartesian-product https://github.com/th3n3rd/cartesian-product.git 78b22f4feb4ef3efc1e99dfe5d932e17024b035d
theseer/tokenizer https://github.com/theseer/tokenizer.git b7489ce515e168639d17feec34b8847c326b0b3c
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
