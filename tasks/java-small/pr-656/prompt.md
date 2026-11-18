# Fail the build when no JSON provider is detected

When no JSON provider capability is detected (no Jackson or JSON-B extension present), ProblemProcessor.createFeature() logs an error but still produces the FeatureBuildItem. The extension registers as active but will produce broken responses at runtime since there is no serializer to render application/problem+json.

Throwing a DeploymentException instead would give clear feedback during development rather than mysterious failures at runtime.
