# [Bug]: Body Param Ordering Wrong

### What happened?

Body param order to be same as validation ruleset.
`Rule::` items seem to be shuffled to the bottom.

### How to reproduce the bug

Using the following (simplified) ruleset on a custom Request class:
```
 [
    /**
     * Type of form being submitted.<br>
     * In the past we have used the following: `appointment`, `brochure`, `career`, `customercare`, `event`, `general`, `interest`, `land`, and `siteplan`.
     */
    'type' => 'required|string',

    /**
     * Customer's full name.
     * @example "Steven Berkshire"
     */
    'name' => 'required|string',

    // Development(s) that the contact request is relevant to.
    'development' => 'nullable|array',
    'development.*' => [
        Rule::in(['test', 'test2']),
    ],

    // Denotes how the customer wishes to be contacted.
    'contact_method' => 'nullable|array',
    'contact_method.*' => [
        Rule::enum(ContactMethod::class),
    ],

    /**
     * Job title being applied to for careers form submissions.
     * @example "Senior Architect"
     */
    'job' => 'nullable|string',
];
```

Produces the following docs:
<img width="581" height="543" alt="Image" src="https://github.com/user-attachments/assets/97155950-3213-4ab8-a531-f01c81de2bef" />

and the same order in the JSON version:
<img width="681" height="443" alt="Image" src="https://github.com/user-attachments/assets/fed0324d-ece5-47f6-b317-f782aaebefb6" />

### Package Version

0.12.23

### PHP Version

8.4.6

### Laravel Version

12.19.3

### Which operating systems does with happen with?

Windows

### Notes

Condensed config file.

```
[
    'api_path' => 'api',
    'api_domain' => null,
    'export_path' => 'api.json',
    'info' => [
        'version' => env('API_VERSION', '0.0.1'),
        'description' => '',
    ],
    'ui' => [
        'title' => null,
        'theme' => 'dark',
        'hide_try_it' => false,
        'hide_schemas' => true,
        'logo' => '',
        'try_it_credentials_policy' => 'include',
        'layout' => 'responsive',
    ],
    'servers' => null,
    'enum_cases_description_strategy' => 'description',
    'middleware' => [
        'web',
        'auth',
        'verified',
        RestrictedDocsAccess::class,
    ],
    'extensions' => [],
];
```
