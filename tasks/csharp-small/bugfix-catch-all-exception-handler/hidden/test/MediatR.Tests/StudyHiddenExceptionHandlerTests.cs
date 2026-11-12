namespace MediatR.Tests.StudyHidden;

using System;
using System.Threading;
using System.Threading.Tasks;
using Lamar;
using MediatR.Pipeline;
using Shouldly;
using Xunit;

public class StudyHiddenExceptionHandlerTests
{
    public class Ask : IRequest<Answer> { public string? Text { get; set; } }

    public class Answer { public string? Text { get; set; } }

    public class OddException : InvalidOperationException
    {
        public OddException(string message) : base(message) { }
    }

    public class ThrowingHandler : IRequestHandler<Ask, Answer>
    {
        public Task<Answer> Handle(Ask request, CancellationToken cancellationToken)
        {
            if (request.Text == "plain")
            {
                throw new Exception("plain");
            }

            throw new OddException("odd");
        }
    }

    public class CatchAllHandler : IRequestExceptionHandler<Ask, Answer, Exception>
    {
        public Task Handle(Ask request, Exception exception, RequestExceptionHandlerState<Answer> state, CancellationToken cancellationToken)
        {
            state.SetHandled(new Answer { Text = "fallback:" + exception.Message });
            return Task.CompletedTask;
        }
    }

    public class InvalidOperationHandler : IRequestExceptionHandler<Ask, Answer, InvalidOperationException>
    {
        public Task Handle(Ask request, InvalidOperationException exception, RequestExceptionHandlerState<Answer> state, CancellationToken cancellationToken)
        {
            state.SetHandled(new Answer { Text = "specific:" + exception.Message });
            return Task.CompletedTask;
        }
    }

    private static IMediator Build(bool withSpecific)
    {
        var container = new Container(cfg =>
        {
            cfg.For<IRequestHandler<Ask, Answer>>().Use<ThrowingHandler>();
            cfg.For<IRequestExceptionHandler<Ask, Answer, Exception>>().Use<CatchAllHandler>();
            if (withSpecific)
            {
                cfg.For<IRequestExceptionHandler<Ask, Answer, InvalidOperationException>>().Use<InvalidOperationHandler>();
            }
            cfg.For(typeof(IPipelineBehavior<,>)).Add(typeof(RequestExceptionProcessorBehavior<,>));
            cfg.For<IMediator>().Use<Mediator>();
        });
        return container.GetInstance<IMediator>();
    }

    [Fact]
    public async Task Catch_all_handler_handles_derived_exception()
    {
        var answer = await Build(withSpecific: false).Send(new Ask { Text = "x" });
        answer.Text.ShouldBe("fallback:odd");
    }

    [Fact]
    public async Task Catch_all_handler_handles_plain_exception()
    {
        var answer = await Build(withSpecific: true).Send(new Ask { Text = "plain" });
        answer.Text.ShouldBe("fallback:plain");
    }

    [Fact]
    public async Task Most_specific_handler_still_wins()
    {
        var answer = await Build(withSpecific: true).Send(new Ask { Text = "x" });
        answer.Text.ShouldBe("specific:odd");
    }
}
