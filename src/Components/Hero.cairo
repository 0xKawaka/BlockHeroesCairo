mod EquippedRunes;
mod Rune;

use Rune::{RuneImpl};
use EquippedRunes::{EquippedRunesImpl};
use game::Libraries::List::List;
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};
use starknet::ContractAddress;
use debug::PrintTrait;

const levelZeroExperienceNeeded: u32 = 100;
const bonusExperiencePercentRequirePerLevel: u32 = 10;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Hero {
    id: u32,
    name: felt252,
    level: u16,
    rank: u16,
    experience: u32,
    runes: EquippedRunes::EquippedRunes,
}

fn new(id: u32, name: felt252, level: u16, rank: u16) -> Hero {
    Hero { id:id, name: name, level: level, rank: rank, experience: 0, runes: EquippedRunes::new() }
}

trait HeroTrait {
    fn gainExperience(ref self: Hero, experience: u32, owner: ContractAddress, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn equipRune(ref self: Hero, ref rune: Rune::Rune, ref runesList: List<Rune::Rune>);
    fn unequipRune(ref self: Hero, ref rune: Rune::Rune);
    fn getRunes(self: Hero) -> EquippedRunes::EquippedRunes;
    fn getRunesIndexArray(self: Hero) -> Array<u32>;
    fn getLevel(self: Hero) -> u16;
    fn getExperience(self: Hero) -> u32;
    fn getName(self: Hero) -> felt252;
    fn setName(ref self: Hero, name: felt252);
    fn print(self: @Hero);
}

impl HeroImpl of HeroTrait {
    fn gainExperience(ref self: Hero, experience: u32, owner: ContractAddress, IEventEmitterDispatch: IEventEmitterDispatcher) {
        self.experience += experience;
        let mut requiredExperience = 0;
        let previousLevel = self.level;
        loop {
            requiredExperience = levelZeroExperienceNeeded + (((self.level.into() - 1) * levelZeroExperienceNeeded * bonusExperiencePercentRequirePerLevel) / 100);
            if(self.experience < requiredExperience) {
                break;
            }
            self.level += 1;
            self.experience -= requiredExperience;
        };
        IEventEmitterDispatch.experienceGain(owner, self.id, experience, self.level, self.experience);
        // if(previousLevel != self.level) {
        //     IEventEmitterDispatch.levelUp(owner, self.id, self.level, self.experience);
        // }
    }
    fn equipRune(ref self: Hero, ref rune: Rune::Rune, ref runesList: List<Rune::Rune>) {
        self.runes.equipRune(ref rune, self.id, ref runesList);
    }
    fn unequipRune(ref self: Hero, ref rune: Rune::Rune) {
        self.runes.unequipRune(ref rune, self.id);
    }
    fn getRunes(self: Hero) -> EquippedRunes::EquippedRunes {
        self.runes
    }
    fn getRunesIndexArray(self: Hero) -> Array<u32> {
        self.runes.getRunesIndexArray()
    }
    fn getLevel(self: Hero) -> u16 {
        self.level
    }
    fn getExperience(self: Hero) -> u32 {
        self.experience
    }
    fn getName(self: Hero) -> felt252 {
        self.name
    }
    fn setName(ref self: Hero, name: felt252) {
        self.name = name;
    }

    fn print(self: @Hero) {
        (*self.name).print();
    }
}
