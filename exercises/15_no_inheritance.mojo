# There is NO class-based inheritance in Mojo. Verified against the compiler:
#
#   class Animal: ...
#   -> error: classes are not supported yet
#
#   struct Dog(Animal):     # Animal is a struct, not a trait
#   -> error: structs only conform to traits or trait compositions; remove
#      the struct type from the conformance list
#
# So structs can't inherit fields or method implementations from other
# structs — full stop. Mojo's real answers to "reuse behavior across types"
# are the two techniques below: COMPOSITION (embed a struct as a field) for
# code reuse, and TRAITS (see exercises/08_traits_generics.mojo) for
# polymorphism. Neither gives you classical subclassing, and that's by
# design, not a missing feature waiting to be discovered.
# Run: pixi run mojo run exercises/15_no_inheritance.mojo


# --- Composition: "has-a" instead of "is-a" ---
# A struct field can be another struct. This is the substitute for
# inheriting shared data/behavior — Car doesn't extend Engine, it CONTAINS one.
@fieldwise_init
struct Engine(Copyable, Movable):
    var horsepower: Int

    def describe(self) -> String:
        return String(self.horsepower) + " hp"


@fieldwise_init
struct Car(Copyable, Describable, Movable):
    var engine: Engine
    var name: String

    def describe(self) -> String:
        # Delegate to the contained struct rather than inheriting its method.
        return self.name + " (" + self.engine.describe() + ")"


# --- Traits: "can-do" instead of "is-a" ---
# Multiple UNRELATED structs implement the same trait — this is Mojo's
# polymorphism, with no shared base type or implementation involved.
trait Describable:
    def describe(self) -> String:
        ...


@fieldwise_init
struct Robot(Describable):
    var id: Int

    def describe(self) -> String:
        return "unit-" + String(self.id)


def print_description[T: Describable](item: T):
    print(item.describe())


def main():
    # Composition in action: Car reuses Engine's behavior by containing one.
    var e = Engine(300)
    var c = Car(e^, "Tesla")  # `^` transfers e into Car (Engine isn't
    #                           implicitly copyable — see docs/language-notes.md
    #                           if this is unfamiliar)
    print(c.describe())  # Tesla (300 hp)

    # Traits in action: Car and Robot share NO struct ancestry whatsoever,
    # yet both work with the same generic function because both implement
    # Describable.
    print_description(c)  # Tesla (300 hp)
    print_description(Robot(7))  # unit-7
