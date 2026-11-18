# MediatR license key configuration

Currently delivering license key is possible either during MediatR services registration
```
services.AddAutoMapper(cfg => { cfg.LicenseKey = "key"; });
```
or by using mapper configuration directly
```
var config = new MapperConfiguration(cfg => { cfg.LicenseKey = "key"; }, loggerFactory);
var mapper = new Mapper(config);
```
of by setting one of the env variables
```
MEDIATR_LICENSE_KEY
LUCKYPENNY_LICENSE_KEY
```
The problem is that when license key is delivered by another service e.g.
```
public interface ILicenseKeyProvider {
  string GetMediatrLicense()
  string GetAutomapperLicense()
}
```
it is not possible to inject and use such service to configure license key. It would be nice to be able to do following
```
        services
            .AddOptions<MediatRServiceConfiguration>()
            .Configure<ILicenseKeyProvider>(
                (cfg, lp) => {
            cfg.LicenseKey = lp.GetMediatrLicense();
        });
```
Such approach would also open ```IConfigureOptions<MediatRServiceConfiguration>``` pattern. It's interesting that Automapper supports this approach already.

