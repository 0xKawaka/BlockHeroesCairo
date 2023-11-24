use game::Components::Hero::Hero;

#[starknet::interface]
trait ILevels<TContractState> {
    fn getEnemies(self: @TContractState, world: u16, level: u16) -> Array<Hero>;
}

#[starknet::contract]
mod Levels {
    use game::Components::{Hero};
    use game::Libraries::List::{List, ListTrait};
    use debug::PrintTrait;

    #[storage]
    struct Storage {
        enemies: LegacyMap<(u16, u16), List<Hero::Hero>>,
        energyCost: LegacyMap<(u16, u16), u16>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.init();
    }

    #[external(v0)]
    impl LevelsImpl of super::ILevels<ContractState> {
        fn getEnemies(self: @ContractState, world: u16, level: u16) -> Array<Hero::Hero> {
            let mut heroes = self.enemies.read((world, level));
            return heroes.array();
        }
    }
    #[generate_trait]
    impl InternalLevelsImpl of InternalLevelsTrait {
        fn init(ref self: ContractState) {
            // ------------------ World 0 ------------------
            // Level 0
            let mut heroes = self.enemies.read((0, 0));
            heroes.append(Hero::new(0, 'knight', 1, 1));
            heroes.append(Hero::new(0, 'hunter', 1, 1));
            heroes.append(Hero::new(0, 'priest', 1, 1));
            heroes.append(Hero::new(0, 'assassin', 1, 1));
            self.energyCost.write((0, 0), 1);
            // Level 1
            let mut heroes = self.enemies.read((0, 1));
            heroes.append(Hero::new(0, 'knight', 1, 1));
            heroes.append(Hero::new(0, 'knight', 1, 1));
            heroes.append(Hero::new(0, 'hunter', 1, 1));
            heroes.append(Hero::new(0, 'assassin', 1, 1));
            self.energyCost.write((0, 1), 2);
            // ------------------ World 1 ------------------
            // Level 0
            let mut heroes = self.enemies.read((1, 0));
            heroes.append(Hero::new(0, 'priest', 1, 1));
            heroes.append(Hero::new(0, 'priest', 1, 1));
            heroes.append(Hero::new(0, 'hunter', 1, 1));
            heroes.append(Hero::new(0, 'assassin', 1, 1));
            self.energyCost.write((1, 0), 3);
            // Level 1
            let mut heroes = self.enemies.read((1, 1));
            heroes.append(Hero::new(0, 'priest', 1, 1));
            heroes.append(Hero::new(0, 'hunter', 1, 1));
            heroes.append(Hero::new(0, 'assassin', 1, 1));
            heroes.append(Hero::new(0, 'assassin', 1, 1));
            self.energyCost.write((1, 1), 4);
        }
    }
}