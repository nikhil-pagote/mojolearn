# Tutorial §7: traits (a method contract) and generics
# (compile-time type parameters in square brackets).
# Run: pixi run mojo run exercises/08_traits_generics.mojo

trait Greet:
    def hello(self) -> String: ...


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


def main():
    print(greet(Dog("Rex")))    # Rex says woof
    print(greet(Robot(7)))      # unit-7 says beep
