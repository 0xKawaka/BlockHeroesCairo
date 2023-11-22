use game::Libraries::List::ListTrait;
use core::option::OptionTrait;
use game::Components::Hero::Rune::{Rune, RuneImpl, RuneType};
use game::Libraries::List::List;
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct EquippedRunes {
    isFirstRuneEquipped: bool,
    first: u32,
    isSecondRuneEquipped: bool,
    second: u32,
    isThirdRuneEquipped: bool,
    third: u32,
    isFourthRuneEquipped: bool,
    fourth: u32,
    isFifthRuneEquipped: bool,
    fifth: u32,
    isSixthRuneEquipped: bool,
    sixth: u32,
}

fn new() -> EquippedRunes {
    EquippedRunes {
        isFirstRuneEquipped: false,
        isSecondRuneEquipped: false,
        isThirdRuneEquipped: false,
        isFourthRuneEquipped: false,
        isFifthRuneEquipped: false,
        isSixthRuneEquipped: false,
        first: 0,
        second: 0,
        third: 0,
        fourth: 0,
        fifth: 0,
        sixth: 0,
    }
}

trait EquippedRunesTrait {
    fn equipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32, ref runesList: List<Rune>);
    fn handleEquipRune(ref self: EquippedRunes, isAnotherRuneAlreadyEquipped: bool, runeAlreadyEquippedId: u32, ref rune: Rune, heroId: u32, ref runesList: List<Rune>);
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn unequipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32);
    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32>;
    fn print(self: EquippedRunes);
}

impl EquippedRunesImpl of EquippedRunesTrait {
    fn equipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32, ref runesList: List<Rune>) {
        match rune.runeType {
            RuneType::First => self.handleEquipRune(self.isFirstRuneEquipped, self.first, ref rune, heroId, ref runesList),
            RuneType::Second => self.handleEquipRune(self.isSecondRuneEquipped, self.second, ref rune, heroId, ref runesList),
            RuneType::Third => self.handleEquipRune(self.isThirdRuneEquipped, self.third, ref rune, heroId, ref runesList),
            RuneType::Fourth => self.handleEquipRune(self.isFourthRuneEquipped, self.fourth, ref rune, heroId, ref runesList),
            RuneType::Fifth => self.handleEquipRune(self.isFifthRuneEquipped, self.fifth, ref rune, heroId, ref runesList),
            RuneType::Sixth => self.handleEquipRune(self.isSixthRuneEquipped, self.sixth, ref rune, heroId, ref runesList),
        }
    }
    fn handleEquipRune(ref self: EquippedRunes, isAnotherRuneAlreadyEquipped: bool, runeAlreadyEquippedId: u32, ref rune: Rune, heroId: u32, ref runesList: List<Rune>) {
        if(isAnotherRuneAlreadyEquipped) {
            // runeAlreadyEquipped.unequip();
            let mut runeAlreadyEquipped = runesList[runeAlreadyEquippedId];
            runeAlreadyEquipped.unequip();
            runesList.set(runeAlreadyEquipped.id, runeAlreadyEquipped);
            self.equipRuneEmptySlot(ref rune, heroId);
        } else {
            self.equipRuneEmptySlot(ref rune, heroId);
        }
    }
    fn equipRuneEmptySlot(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => {
                self.first = rune.id;
                self.isFirstRuneEquipped = true;
            },
            RuneType::Second => {
                self.second = rune.id;
                self.isSecondRuneEquipped = true;
            },
            RuneType::Third => {
                self.third = rune.id;
                self.isThirdRuneEquipped = true;
            },
            RuneType::Fourth => {
                self.fourth = rune.id;
                self.isFourthRuneEquipped = true;
            },
            RuneType::Fifth => {
                self.fifth = rune.id;
                self.isFifthRuneEquipped = true;
            },
            RuneType::Sixth => {
                self.sixth = rune.id;
                self.isSixthRuneEquipped = true;
            },
        }
        rune.setEquippedBy(heroId);
    }
    fn unequipRune(ref self: EquippedRunes, ref rune: Rune, heroId: u32) {
        match rune.runeType {
            RuneType::First => {
                self.isFirstRuneEquipped = false;
            },
            RuneType::Second => {
                self.isSecondRuneEquipped = false;
            },
            RuneType::Third => {
                self.isThirdRuneEquipped = false;
            },
            RuneType::Fourth => {
                self.isFourthRuneEquipped = false;
            },
            RuneType::Fifth => {
                self.isFifthRuneEquipped = false;
            },
            RuneType::Sixth => {
                self.isSixthRuneEquipped = false;
            },
        }
        rune.unequip();
    }

    fn getRunesIndexArray(self: EquippedRunes) -> Array<u32> {
        let mut runesIndexArray: Array<u32> = Default::default();
        if(self.isFirstRuneEquipped) {
            runesIndexArray.append(self.first);
        }
        if(self.isSecondRuneEquipped) {
            runesIndexArray.append(self.second);
        }
        if(self.isThirdRuneEquipped) {
            runesIndexArray.append(self.third);
        }
        if(self.isFourthRuneEquipped) {
            runesIndexArray.append(self.fourth);
        }
        if(self.isFifthRuneEquipped) {
            runesIndexArray.append(self.fifth);
        }
        if(self.isSixthRuneEquipped) {
            runesIndexArray.append(self.sixth);
        }
        return runesIndexArray;
    }
    fn print(self: EquippedRunes) {
        if(self.isFirstRuneEquipped) {
            self.first.print();
        }
        if(self.isSecondRuneEquipped) {
            self.second.print();
        }
        if(self.isThirdRuneEquipped) {
            self.third.print();
        }
        if(self.isFourthRuneEquipped) {
            self.fourth.print();
        }
        if(self.isFifthRuneEquipped) {
            self.fifth.print();
        }
        if(self.isSixthRuneEquipped) {
            self.sixth.print();
        }
    }

}