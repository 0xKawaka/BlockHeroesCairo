use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Hero {
    id: u32,
    name: felt252,
    level: u16,
    rank: u16,
}

fn new(id: u32, name: felt252, level: u16, rank: u16) -> Hero {
    Hero { id:id, name: name, level: level, rank: rank, }
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
