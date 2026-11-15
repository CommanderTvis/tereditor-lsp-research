// Held-out check of the rename: every node class answers IsShallowEqual, none still has the old member.
#include "tinyxml2.h"
#include <cstdio>
#include <type_traits>
using namespace tinyxml2;

template <typename T, typename = void> struct has_old : std::false_type {};
template <typename T> struct has_old<T, decltype((void)&T::ShallowEqual, void())> : std::true_type {};
static_assert(!has_old<XMLNode>::value, "XMLNode::ShallowEqual still exists");
static_assert(!has_old<XMLElement>::value, "XMLElement::ShallowEqual still exists");
static_assert(!has_old<XMLText>::value, "XMLText::ShallowEqual still exists");
static_assert(!has_old<XMLComment>::value, "XMLComment::ShallowEqual still exists");
static_assert(!has_old<XMLDeclaration>::value, "XMLDeclaration::ShallowEqual still exists");
static_assert(!has_old<XMLUnknown>::value, "XMLUnknown::ShallowEqual still exists");
static_assert(!has_old<XMLDocument>::value, "XMLDocument::ShallowEqual still exists");

int main() {
    XMLDocument a, b;
    a.Parse("<?xml version=\"1.0\"?><!--c--><r k=\"v\">t<!x></r>");
    b.Parse("<?xml version=\"1.0\"?><!--c--><r k=\"v\">t<!x></r>");
    int fails = 0;
    const XMLNode* x = a.FirstChild();
    const XMLNode* y = b.FirstChild();
    for (; x && y; x = x->NextSibling(), y = y->NextSibling()) fails += !x->IsShallowEqual(y);
    const XMLElement* r = a.FirstChildElement("r");
    fails += !r->FirstChild()->IsShallowEqual(b.FirstChildElement("r")->FirstChild());
    fails += r->IsShallowEqual(a.FirstChild());
    fails += a.IsShallowEqual(&b);
    std::printf("hidden rename check: %d failures\n", fails);
    return fails != 0;
}
