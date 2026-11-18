PhoneNumberValidator with number_format='NATIONAL' drops the country code of foreign numbers, so the model can't reload its own output

### Description

With `PhoneNumberValidator(default_region='GB', number_format='NATIONAL')`, a valid number from another country is accepted, but the stored value drops its country code. The model then can't load its own output:

```python
from typing import Annotated, Union

import phonenumbers
from pydantic import BaseModel

from pydantic_extra_types.phone_numbers import PhoneNumberValidator


class Contact(BaseModel):
    phone: Annotated[
        Union[str, phonenumbers.PhoneNumber],
        PhoneNumberValidator(default_region='GB', number_format='NATIONAL'),
    ]


c = Contact(phone='+1 650 253 0000')
print(c.phone)  # (650) 253-0000  -- the +1 country code is gone
Contact.model_validate_json(c.model_dump_json())  # ValidationError: value is not a valid phone number
```

The same happens for every non-GB number I tried:

| Input | Stored | Reloading the stored value |
|---|---|---|
| `+33 1 23 45 67 89` | `01 23 45 67 89` | fails |
| `+49 30 901820` | `030 901820` | fails |
| `+91 22 2778 8888` | `022 2778 8888` | fails |
| `+44 20 7946 0958` | `020 7946 0958` | ok |

None of these reloaded as a *different* valid number, but nothing stops that in general: a foreign national number can also be a valid GB national number.

### Possible fixes

`NATIONAL` is only lossless for numbers in `default_region`. Options:

1. For `NATIONAL`, format numbers from other regions in `INTERNATIONAL` form (`+1 650-253-0000`). Same-region numbers keep their national form.
2. Use `phonenumbers.format_out_of_country_calling_number(number, default_region)`, which does that split but writes the GB dialling prefix (`00 1 650-253-0000`).
3. Leave the behaviour and document that `NATIONAL` should be combined with `supported_regions=[default_region]`.

I'd suggest (1). Happy to send a PR for whichever you prefer.

### Versions

Python 3.12.12, pydantic 2.14.1, pydantic-extra-types 2.11.2 (main @ 9a775cd), phonenumbers 9.0.41.

I found this with a round-trip test over the validators in this package, using Claude Code. I ran and checked the example above myself.
