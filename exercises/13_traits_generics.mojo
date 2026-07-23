# Tutorial §7: traits (a method contract) and generics
# (compile-time type parameters in square brackets).
# Run: pixi run mojo run exercises/13_traits_generics.mojo


trait Greet:
    def hello(self) -> String:
        ...


@fieldwise_init
struct Dog(Greet):
    var name: String

    def hello(self) -> String:
        return self.name + " says woof"


@fieldwise_init
struct Robot(Greet):
    var id: Int

    def hello(self) -> String:
        return String("unit-", self.id, " says beep")


# Works for ANY type that implements Greet, resolved at compile time.
def greet[T: Greet](t: T) -> String:
    return t.hello()


# --- Trait composition: a trait can require conformance to OTHER traits,
# bundling several contracts into one. A struct that conforms to `Shape`
# must implement every method from BOTH `Drawable` and `Measurable`. ---
trait Drawable:
    def draw(self) -> String:
        ...


trait Measurable:
    def area(self) -> Float64:
        ...


trait Shape(Drawable, Measurable):
    pass


@fieldwise_init
struct Square(Shape):
    var side: Float64

    def draw(self) -> String:
        return "[square]"

    def area(self) -> Float64:
        return self.side * self.side


@fieldwise_init
struct Circle(Shape):
    var radius: Float64

    def draw(self) -> String:
        return "(circle)"

    def area(self) -> Float64:
        return 3.14159 * self.radius * self.radius


# A generic function bounded by the COMPOSED trait accepts either struct,
# and can call methods from either half of the composition.
def describe[T: Shape](s: T) -> String:
    return s.draw() + " area=" + String(s.area())


def main():
    print(greet(Dog("Rex")))  # Rex says woof
    print(greet(Robot(7)))  # unit-7 says beep

    print(describe(Square(4.0)))  # [square] area=16.0
    print(describe(Circle(2.0)))  # (circle) area=12.56636
