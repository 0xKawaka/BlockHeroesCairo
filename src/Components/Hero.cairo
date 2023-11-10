mod EquippedRunes;
mod Rune;

use EquippedRunes::{EquippedRunesImpl};
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Hero {
    id: u32,
    name: felt252,
    level: u16,
    rank: u16,
    runes: EquippedRunes::EquippedRunes,
}

fn new(id: u32, name: felt252, level: u16, rank: u16) -> Hero {
    Hero { id:id, name: name, level: level, rank: rank, runes: EquippedRunes::new() }
}

trait HeroTrait {
    fn equipRune(ref self: Hero, ref rune: Rune::Rune);
    fn getRunes(self: Hero) -> EquippedRunes::EquippedRunes;
    fn getRunesIndexArray(self: Hero) -> Array<u32>;
    fn setName(ref self: Hero, name: felt252);
    fn getName(self: Hero) -> felt252;
    fn print(self: @Hero);
}

impl HeroImpl of HeroTrait {
    fn equipRune(ref self: Hero, ref rune: Rune::Rune) {
        self.runes.equip(ref rune, self.id);
    }
    fn getRunes(self: Hero) -> EquippedRunes::EquippedRunes {
        self.runes
    }
    fn getRunesIndexArray(self: Hero) -> Array<u32> {
        self.runes.getRunesIndexArray()
    }
    fn setName(ref self: Hero, name: felt252) {
        self.name = name;
    }
    fn getName(self: Hero) -> felt252 {
        self.name
    }
    fn print(self: @Hero) {
        (*self.name).print();
    }
}
