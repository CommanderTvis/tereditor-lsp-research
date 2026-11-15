using Microsoft.Extensions.Logging.Abstractions;

namespace AutoMapper.UnitTests;

// Held out from the agent: IValueResolver<TSource, TDestination, TDestMember>.Resolve takes the ResolutionContext
// first, resolvers written that way are called with the right arguments, and IMemberValueResolver keeps its order.
public class StudyHiddenSignatureTests
{
    public class Src { public int Value { get; set; } public string Name { get; set; } }
    public class Dst { public int Value { get; set; } public string Name { get; set; } }

    public class ContextFirstResolver : IValueResolver<Src, Dst, int>
    {
        public int Resolve(ResolutionContext context, Src source, Dst destination, int destMember) =>
            source.Value * 10 + (int)context.Items["add"] + destMember;
    }

    public class MemberResolver : IMemberValueResolver<Src, Dst, string, string>
    {
        public string Resolve(Src source, Dst destination, string sourceMember, string destMember, ResolutionContext context) =>
            sourceMember + "/" + context.Items["suffix"];
    }

    [Fact]
    public void Context_is_the_first_parameter()
    {
        var resolve = typeof(IValueResolver<,,>).GetMethod("Resolve");
        var ps = resolve.GetParameters();
        ps.Length.ShouldBe(4);
        ps[0].ParameterType.ShouldBe(typeof(ResolutionContext));
        ps[1].ParameterType.ShouldBe(typeof(IValueResolver<,,>).GetGenericArguments()[0]);
        var member = typeof(IMemberValueResolver<,,,>).GetMethod("Resolve").GetParameters();
        member.Length.ShouldBe(5);
        member[4].ParameterType.ShouldBe(typeof(ResolutionContext));
    }

    [Fact]
    public void Resolvers_are_called_with_the_right_arguments()
    {
        var config = new MapperConfiguration(cfg => cfg.CreateMap<Src, Dst>()
            .ForMember(d => d.Value, o => o.MapFrom<ContextFirstResolver>())
            .ForMember(d => d.Name, o => o.MapFrom<MemberResolver, string>(s => s.Name)), NullLoggerFactory.Instance);
        var mapper = config.CreateMapper();
        var dst = mapper.Map(new Src { Value = 4, Name = "n" }, new Dst { Value = 1 }, o => { o.Items["add"] = 2; o.Items["suffix"] = "x"; });
        dst.Value.ShouldBe(43);
        dst.Name.ShouldBe("n/x");
    }
}
