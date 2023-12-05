use game::Components::Hero::Hero;

#[starknet::interface]
trait ILevels<TContractState> {
    fn getEnemies(self: @TContractState, world: u16, level: u16) -> Array<Hero>;
    fn getEnergyCost(self: @TContractState, world: u16, level: u16) -> u16;
    fn getEnemiesLevels(self: @TContractState, world: u16, level: u16) -> Array<u16>;
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
        fn getEnergyCost(self: @ContractState, world: u16, level: u16) -> u16 {
            return self.energyCost.read((world, level));
        }
        fn getEnemies(self: @ContractState, world: u16, level: u16) -> Array<Hero::Hero> {
            let mut heroes = self.enemies.read((world, level));
            return heroes.array();
        }
        fn getEnemiesLevels(self: @ContractState, world: u16, level: u16) -> Array<u16> {
            let mut heroes = self.enemies.read((world, level));
            let mut levels: Array<u16> = array![];
            let mut i: u32 = 0;
            loop {
                if(i == heroes.len()) {
                    break;
                }
                let hero = heroes[i];
                levels.append(hero.level);
                i += 1;
            };
            return levels;
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
            heroes.append(Hero::new(0, 'knight', 5, 1));
            heroes.append(Hero::new(0, 'knight', 5, 1));
            heroes.append(Hero::new(0, 'hunter', 5, 1));
            heroes.append(Hero::new(0, 'assassin', 5, 1));
            self.energyCost.write((0, 1), 1);
            // ------------------ World 1 ------------------
            // Level 0
            let mut heroes = self.enemies.read((1, 0));
            heroes.append(Hero::new(0, 'priest', 10, 1));
            heroes.append(Hero::new(0, 'priest', 10, 1));
            heroes.append(Hero::new(0, 'hunter', 10, 1));
            heroes.append(Hero::new(0, 'assassin', 10, 1));
            self.energyCost.write((1, 0), 1);
            // Level 1
            let mut heroes = self.enemies.read((1, 1));
            heroes.append(Hero::new(0, 'priest', 20, 1));
            heroes.append(Hero::new(0, 'hunter', 20, 1));
            heroes.append(Hero::new(0, 'assassin', 20, 1));
            heroes.append(Hero::new(0, 'assassin', 20, 1));
            self.energyCost.write((1, 1), 1);
        }
    }
}