# [Bug]: `ModelInfo::getVirtualAttributes()` ignores accessor method return types

### What happened?

I have a model accessor that's clearly typed as nullable:

```php
class Post extends Model
{
    public function getExcerptAttribute(): ?string
    {
        return $this->body ? substr($this->body, 0, 100) : null;
    }
}
```

When I expose this through a JsonResource and generate the OpenAPI spec, the field comes out as a required, non-nullable `string` — even though the PHP return type explicitly says it can be `null`.

I tried a few things to nudge Scramble toward the right type, all without effect:

- Using `: string | null` instead of `: ?string` on the accessor
- Adding `@property-read string|null $excerpt` to the model's class docblock

Only an inline `// @var string|null` directly above the field in `toArray()` produces the correct nullable type. That works as a workaround, but it means every accessor-backed field across the codebase needs a redundant annotation that just restates what the PHP signature already says.

### How to reproduce the bug

Basically whats written above already

### Package Version

0.13.22

### PHP Version

8.4.18

### Laravel Version

12.57.0

### Which operating systems does with happen with?

_No response_

### Notes

_No response_
