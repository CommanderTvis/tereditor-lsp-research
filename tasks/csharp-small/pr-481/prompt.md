# AggregateException is thrown on Mediator.Send(object)

`Task<object> Send(object request, CancellationToken cancellationToken)` is throwing `AggregateException` instead of the main exception.

Here's the code to reproduce : 

```csharp
public class Request : IRequest
{

}

public class RequestHandler : IRequestHandler<Request>
{
    public async Task<Unit> Handle(Request request, CancellationToken cancellationToken)
    {
        throw new NotImplementedException();
    }
}

class Program
{
    static async Task Main(string[] args)
    {
        var container = new ServiceCollection()
            .AddMediatR(typeof(Program).Assembly)
            .BuildServiceProvider();

        var mediator = container.GetService<IMediator>();

        try
        {
            Request request = new Request();
            await mediator.Send(request);
        }
        catch (Exception exception)
        {
            //exception is NotImplementedException
        }

        try
        {
            object request = new Request();
            await mediator.Send(request);
        }
        catch (Exception ex)
        {
            //exception is AggregateException
        }
    }
}
```
