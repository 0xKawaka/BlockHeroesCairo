use super::super::Components::Hero::Hero;

#[starknet::interface]
trait ILevels<TContractState> {
    fn init(ref self: TContractState);
}

#[starknet::contract]
mod Levels {
    use super::super::super::Components::{Hero};

    #[storage]
    struct Storage {
        enemiesCount: LegacyMap<(u16, u16), u16>,
        enemies: LegacyMap<(u16, u16, u16), Hero::Hero>,
        energyCost: LegacyMap<(u16, u16), u16>,
    }

    #[external(v0)]
    impl LevelsImpl of super::ILevels<ContractState> {
        fn init(ref self: ContractState) {
            // ------------------ World 0 ------------------
            // Level 0
            self.enemiesCount.write((0, 0), 1);
            self.enemies.write((0, 0, 0), Hero::new('knight', 1, 1));
            self.energyCost.write((0, 0), 1);
            // Level 1
            self.enemiesCount.write((0, 1), 2);
            self.enemies.write((0, 1, 0), Hero::new('priest', 1, 1));
            self.enemies.write((0, 1, 1), Hero::new('priest', 1, 1));
            self.energyCost.write((0, 1), 2);

            // ------------------ World 1 ------------------
            // Level 0
            self.enemiesCount.write((1, 0), 1);
            self.enemies.write((1, 0, 0), Hero::new('knight', 2, 2));
            self.energyCost.write((1, 0), 3);
            // Level 1
            self.enemiesCount.write((1, 1), 2);
            self.enemies.write((1, 1, 0), Hero::new('priest', 2, 2));
            self.enemies.write((1, 1, 1), Hero::new('priest', 2, 2));
            self.energyCost.write((1, 1), 4);
        }
    }
}