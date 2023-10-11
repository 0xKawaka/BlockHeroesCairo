use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Hero {
    name: felt252,
    level: u16,
    rank: u16,
}

fn new(name: felt252, level: u16, rank: u16) -> Hero {
    Hero {
        name: name,
        level: level,
        rank: rank,
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
