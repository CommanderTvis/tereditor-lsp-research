# Not all Jackson exceptions mapper have been overruled

Quarkus: 3.4.3
Resteasy-Problem: 3.0.0

It seems like that not all ``Jackson`` exceptions are handled by `resteasy-problem`.

![image](https://github.com/TietoEVRY/quarkus-resteasy-problem/assets/3606282/cf44c790-92c8-4444-b066-3a0bb659492d)

Although there is a mapper for ``JsonProcessingException``, both child exceptions ``MismatchedInputException`` and ``InvalidDefinitionException`` are handled by Jackson itself. 

According to the spec, this seems totally fine:

```
When choosing an exception mapping provider to map an exception, an implementation MUST use the
provider whose generic type is the nearest superclass of the exception. If two or more exception providers
are applicable, the one with the highest priority MUST be chosen as described in Section 4.1.3.
```

That is a little annoying cause it looks like you need to overrule each exception mapper individually. 

Do you have any strategy in place to detected new mappers automatically?
