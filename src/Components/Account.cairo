use debug::PrintTrait;
use option::OptionTrait;
use super::Hero::{Hero, HeroTrait, HeroImpl};
// use super::Hero::HeroTrait;
// use super::Hero::HeroImpl;
use super::Battle;
use super::Battle::BattleImpl;
// use super::EntityFactory;
// use super::EntityFactoryImpl;
use starknet::ContractAddress;

// #[derive(starknet::Store, Destruct)]
#[derive(starknet::Store, Copy, Drop, Serde)]
struct Account {
    energy: u32,
    shards: u32,
    owner: ContractAddress,
    // heroes: Array<Hero::Hero>,
    // heroes: List<Hero>,
    // battle: Option<Battle::Battle>,
}

const maxEnergy: u32 = 100;
fn new(owner: ContractAddress) -> Account {
    Account {
        energy: maxEnergy,
        shards: 0,
        owner: owner,
        // heroes: Default::default(),
        // battle: Option::None,
    }
}

// impl OptionBattleDestruct of Destruct<Option<Battle::Battle>> {
//     fn destruct(self: Option<Battle::Battle>) nopanic {
//         match self {
//             Option::Some(x) => x.destruct(),
//             Option::None => {},
//         }
//     }
// }

trait AccountTrait {
    // fn startBattle(
    //     ref self: Account,
    //     heroesIndexes: @Array<u32>,
    //     enemies: @Array<Hero::Hero>,
    //     ref battleHeroFactory: EntityFactory::EntityFactory
    // );
    // fn playerAction(self: Account, spellIndex: u8, targetIndex: u32);
    fn print(self: Account);
    // fn printHeroes(self: Account);
}

impl AccountImpl of AccountTrait {
    // fn startBattle(
    //     ref self: Account,
    //     heroesIndexes: @Array<u32>,
    //     enemies: @Array<Hero::Hero>,
    //     ref battleHeroFactory: EntityFactory::EntityFactory
    // ) {
    //     let mut heroArray: Array<Hero::Hero> = ArrayTrait::new();
    //     let heroesSpan = self.heroes.span();
    //     let mut i: u32 = 0;
    //     let mut heroesIndexesSpan = heroesIndexes.span();
    //     let heroesIndexesSpanLen = heroesIndexesSpan.len();
    //     loop {
    //         if (i >= heroesIndexesSpanLen) {
    //             break;
    //         }
    //         let indexOption = heroesIndexesSpan.pop_front();
    //         let index = *indexOption.unwrap();
    //         let hero = heroesSpan[index];
    //         heroArray.append(*hero);
    //         i = i + 1;
    //     };
    //     let mut battle = Battle::new(@heroArray, enemies, ref battleHeroFactory);
    //     battle.battleLoop();
    //     // battle.print();
    //     self.battle = Option::Some(battle);
    // }
    // fn playerAction(self: Account, spellIndex: u8, targetIndex: u32) {
    //     match self.battle {
    //         Option::Some(mut battleVal) => {
    //             battleVal.playerAction(spellIndex, targetIndex);
    //         },
    //         Option::None => {},
    //     }
    // }
    // fn addHero(ref self: Account, hero: Hero::Hero) {
    //     self.heroes.append(hero);
    // }
    fn print(self: Account) {
        self.energy.print();
        self.shards.print();
        // self.printHeroes();
    }
    // fn printHeroes(self: Account) {
    //     let mut i: u32 = 0;
    //     let mut heroesSpan = self.heroes.span();
    //     let heroesSpanLen = heroesSpan.len();
    //     loop {
    //         if (i >= heroesSpanLen) {
    //             break;
    //         }
    //         let heroOption = heroesSpan.pop_front();
    //         let hero = *heroOption.unwrap();
    //         hero.print();
    //         i = i + 1;
    //     }
    // }
}

