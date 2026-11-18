<?php declare(strict_types=1);

// Bootstrap for the unit tests (tests/unit) without a database: Shopware's own src/Core/TestBootstrap.php installs the
// system into MySQL, which the grading toolchain does not have. This registers the same autoloader and kernel lifecycle
// state and skips the install.
use Shopware\Core\TestBootstrapper;

$root = getcwd();
$_SERVER['PROJECT_ROOT'] = $_ENV['PROJECT_ROOT'] = $root;
if (!defined('TEST_PROJECT_DIR')) {
    define('TEST_PROJECT_DIR', $root);
}
$_SERVER['DATABASE_URL'] = $_ENV['DATABASE_URL'] = 'mysql://root:root@127.0.0.1:3306/shopware';
$_SERVER['APP_ENV'] = $_ENV['APP_ENV'] = 'test';

$classLoader = require $root . '/vendor/autoload.php';

// The feature flags a booted kernel registers (FeatureFlagCompilerPass): the unit tests' FeatureFlag extension switches every
// registered flag on and turns off the ones a test lists in #[DisabledFeatures].
$flags = [];
foreach (\Symfony\Component\Yaml\Yaml::parseFile($root . '/src/Core/Framework/Resources/config/packages/feature.yaml')['shopware']['feature']['flags'] as $flag) {
    $name = $flag['name'];
    unset($flag['name']);
    $flags[$name] = $flag;
}
\Shopware\Core\Framework\Feature::registerFeatures($flags);

\Shopware\Core\Framework\Test\TestCaseBase\KernelLifecycleManager::prepare($classLoader);
