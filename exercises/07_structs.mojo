# Tutorial §6: structs — @fieldwise_init (replaces the old @value),
# read-only methods (self), and mutating methods (mut self).
# Run: pixi run mojo run exercises/07_structs.mojo

@fieldwise_init
struct Point:
    var x: Int
    var y: Int


@fieldwise_init
struct Counter:
    var n: Int

    def get(self) -> Int:      # read-only method
        return self.n

    def inc(mut self):         # mutates the struct
        self.n += 1


struct Cat:                    # a fieldless struct still needs an __init__
    def __init__(out self):
        pass

    def speak(self) -> String:
        return "meow"


def main():
    var p = Point(1, 2)        # constructor generated from fields
    print("point:", p.x, p.y)  # point: 1 2

    var c = Counter(0)
    c.inc()
    c.inc()
    print("counter:", c.get()) # counter: 2

    print("cat:", Cat().speak())  # cat: meow
