namespace AutoMapper.UnitTests;

// Held out from the agent: the MemberList enum is declared in AutoMapper.Core only, with its values unchanged, and the
// configuration API takes it.
public class StudyHiddenMoveTests
{
    [Fact]
    public void Enum_lives_in_the_new_namespace_only()
    {
        var asm = typeof(IMapper).Assembly;
        var moved = asm.GetType("AutoMapper.Core.MemberList");
        moved.ShouldNotBeNull();
        moved.IsEnum.ShouldBeTrue();
        asm.GetType("AutoMapper.MemberList").ShouldBeNull();
        asm.GetTypes().Count(t => t.Name == "MemberList").ShouldBe(1);
        Enum.GetNames(moved).ShouldBe(new[] { "Destination", "Source", "None" });
        typeof(IProfileExpression).GetMethods().Where(m => m.Name == "CreateMap")
            .SelectMany(m => m.GetParameters()).Any(p => p.ParameterType == moved).ShouldBeTrue();
    }
}
