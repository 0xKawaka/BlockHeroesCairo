use core::option::OptionTrait;
use game::Components::Hero::Rune::{Rune, RuneImpl, RuneType};
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct EquippedRunes {
    first: Option<u32>,
    second: Option<u32>,
    third: Option<u32>,
    fourth: Option<u32>,
    fifth: Option<u32>,
    sixth: Option<u32>,
}

fn new() -> EquippedRunes {
    EquippedRunes {
        first: Option::None,
        second: Option::None,
        third: Option::None,
        fourth: Option::None,
        fifth: Option::None,
        sixth: Option::None,
    }
}

trait EquippedRunesTrait {
    fn equip(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn handleEquipRune(ref self: EquippedRunes, runeAlreadyEquipped: Option<u32>, ref rune: Rune, heroId: u32);
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32>;
    fn print(self: EquippedRunes);
    fn printIfValue(self: EquippedRunes, optionRune: Option<u32>);
}

impl EquippedRunesImpl of EquippedRunesTrait {
    fn equip(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => self.handleEquipRune(self.first, ref rune, heroId),
            RuneType::Second => self.handleEquipRune(self.second, ref rune, heroId),
            RuneType::Third => self.handleEquipRune(self.third, ref rune, heroId),
            RuneType::Fourth => self.handleEquipRune(self.fourth, ref rune, heroId),
            RuneType::Fifth => self.handleEquipRune(self.fifth, ref rune, heroId),
            RuneType::Sixth => self.handleEquipRune(self.sixth, ref rune, heroId),
        }
    }
    fn handleEquipRune(ref self: EquippedRunes, runeAlreadyEquipped: Option<u32>, ref rune: Rune, heroId: u32) {
        match runeAlreadyEquipped {
            Option::Some(mut equippedRune) => {
                // TODO : Pass List as ref to set rune to None
                // equippedRune.heroEquipped = Option::None;
                self.equipRuneEmptySlot(ref rune, heroId);
            },
            Option::None => self.equipRuneEmptySlot(ref rune, heroId),
        }
    }
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => self.first = Option::Some(rune.id),
            RuneType::Second => self.second = Option::Some(rune.id),
            RuneType::Third => self.third = Option::Some(rune.id),
            RuneType::Fourth => self.fourth = Option::Some(rune.id),
            RuneType::Fifth => self.fifth = Option::Some(rune.id),
            RuneType::Sixth => self.sixth = Option::Some(rune.id),
        }
        // match rune.runeType {
        //     RuneType::First => self.first = Option::None,
        //     RuneType::Second => self.second = Option::None,
        //     RuneType::Third => self.third = Option::None,
        //     RuneType::Fourth => self.fourth = Option::None,
        //     RuneType::Fifth => self.fifth = Option::None,
        //     RuneType::Sixth => self.sixth = Option::None,
        // }
        // match rune.runeType {
        //     RuneType::First => PrintTrait::print('first'),
        //     RuneType::Second => PrintTrait::print('second'),
        //     RuneType::Third => PrintTrait::print('third'),
        //     RuneType::Fourth => PrintTrait::print('fourth'),
        //     RuneType::Fifth => PrintTrait::print('fifth'),
        //     RuneType::Sixth => PrintTrait::print('sixth'),
        // }
        rune.heroEquipped = Option::Some(heroId);
    }
    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32> {
        let mut runesIndexArray: Array<u32> = Default::default();
        if(self.first != Option::None) {
            runesIndexArray.append(self.first.unwrap());
        }
        if(self.second != Option::None) {
            runesIndexArray.append(self.second.unwrap());
        }
        if(self.third != Option::None) {
            runesIndexArray.append(self.third.unwrap());
        }
        if(self.fourth != Option::None) {
            runesIndexArray.append(self.fourth.unwrap());
        }
        if(self.fifth != Option::None) {
            runesIndexArray.append(self.fifth.unwrap());
        }
        if(self.sixth != Option::None) {
            runesIndexArray.append(self.sixth.unwrap());
        }
        return runesIndexArray;
    }
    fn print(self: EquippedRunes) {
        self.printIfValue(self.first);
        self.printIfValue(self.second);
        self.printIfValue(self.third);
        self.printIfValue(self.fourth);
        self.printIfValue(self.fifth);
        self.printIfValue(self.sixth);
    }
    fn printIfValue(self: EquippedRunes, optionRune: Option<u32>) {
        match optionRune {
            Option::Some(runeIndex) => runeIndex.print(),
            Option::None => {},
        }   
    }

}