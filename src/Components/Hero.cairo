use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Hero {
    name: felt252,
    level: u16,
    rank: u16,
}

fn new(name: felt252, level: u16, rank: u16) -> Hero {
    Hero { name: name, level: level, rank: rank, }
}

trait HeroTrait {
    fn getName(self: Hero) -> felt252;
    fn print(self: @Hero);
}

impl HeroImpl of HeroTrait {
    fn getName(self: Hero) -> felt252 {
        self.name
    }
    fn print(self: @Hero) {
        (*self.name).print();
    }
}
