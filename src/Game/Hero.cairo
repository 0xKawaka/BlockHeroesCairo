mod Statistics;
use debug::PrintTrait;


#[derive(Copy, Drop)]
struct Hero {
    name: felt252,
    // statistics: Statistics,
}

fn new(name: felt252) -> Hero {
    Hero {
        name: name,
    }
}

trait HeroTrait {
    fn print(self: Hero) -> ();
}

impl HeroImpl of HeroTrait {
    fn print(self: Hero) {
        self.name.print();
    }
}
