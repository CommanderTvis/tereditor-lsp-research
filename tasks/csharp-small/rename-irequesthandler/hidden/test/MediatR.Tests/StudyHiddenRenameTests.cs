using System.Linq;
using Xunit;

namespace MediatR.Tests;

// Held out from the agent: the two-parameter request handler interface is called IQueryHandler<TRequest, TResponse>,
// no type named IRequestHandler with two type parameters is left, and the one-parameter IRequestHandler<TRequest> is
// untouched.
public class StudyHiddenRenameTests
{
    [Fact]
    public void Renamed_interface_exists_and_old_name_is_gone()
    {
        var asm = typeof(IMediator).Assembly;
        var renamed = asm.GetType("MediatR.IQueryHandler`2");
        Assert.NotNull(renamed);
        Assert.True(renamed!.IsInterface);
        Assert.NotNull(renamed.GetMethod("Handle"));
        Assert.Null(asm.GetType("MediatR.IRequestHandler`2"));
        Assert.Empty(asm.GetTypes().Where(t => t.Name == "IRequestHandler`2"));
        Assert.Empty(typeof(StudyHiddenRenameTests).Assembly.GetTypes().Where(t => t.Name == "IRequestHandler`2"));
    }

    [Fact]
    public void One_parameter_handler_keeps_its_name()
    {
        var single = typeof(IMediator).Assembly.GetType("MediatR.IRequestHandler`1");
        Assert.NotNull(single);
        Assert.True(single!.IsInterface);
    }
}
