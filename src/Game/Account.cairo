use debug::PrintTrait;
use option::OptionTrait;
use super::Hero;
use super::Hero::HeroTrait;
use super::Hero::HeroImpl;
use super::Battle;
use super::Battle::BattleImpl;
use super::EntityFactory;
use super::EntityFactoryImpl;

#[derive(Destruct)]
struct Account {
    energy: u32,
    shards: u32,
    heroes: Array<Hero::Hero>,
    isBattling: bool,
    battle: Option<Battle::Battle>,
}

const maxEnergy: u32 = 100;
fn new() -> Account {
    Account {
        energy: maxEnergy,
        shards: 0,
        heroes: ArrayTrait::new(),
        isBattling: false,
        battle: Option::None,
    // battle: Battle::new(),
    }
}

impl OptionBattleDestruct of Destruct<Option<Battle::Battle>> {
    fn destruct(self: Option<Battle::Battle>) nopanic {
        match self {
            Option::Some(x) => x.destruct(),
            Option::None => {},
        }
    }
}

trait AccountTrait {
    fn startBattle(
        ref self: Account,
        heroesIndexes: @Array<u32>,
        enemies: @Array<Hero::Hero>,
        ref battleHeroFactory: EntityFactory::EntityFactory
    );
    fn addHero(ref self: Account, hero: Hero::Hero);
    fn print(self: Account);
    fn printHeroes(self: Account);
}

impl AccountImpl of AccountTrait {
    fn startBattle(
        ref self: Account,
        heroesIndexes: @Array<u32>,
        enemies: @Array<Hero::Hero>,
        ref battleHeroFactory: EntityFactory::EntityFactory
    ) {
        let mut heroArray: Array<Hero::Hero> = ArrayTrait::new();
        let heroesSpan = self.heroes.span();
        let mut i: u32 = 0;
        let mut heroesIndexesSpan = heroesIndexes.span();
        let heroesIndexesSpanLen = heroesIndexesSpan.len();
        loop {
            if (i > heroesIndexesSpanLen - 1) {
                break;
            }
            let indexOption = heroesIndexesSpan.pop_front();
            let index = *indexOption.unwrap();
            let hero = heroesSpan[index];
            heroArray.append(*hero);
            i = i + 1;
        };
        let mut battle = Battle::new(@heroArray, enemies, ref battleHeroFactory);
        battle.battleLoop();
        // battle.print();
        self.battle = Option::Some(battle);
    }
    fn addHero(ref self: Account, hero: Hero::Hero) {
        self.heroes.append(hero);
    }
    fn print(self: Account) {
        self.energy.print();
        self.shards.print();
        self.printHeroes();
    }
    fn printHeroes(self: Account) {
        let mut i: u32 = 0;
        let mut heroesSpan = self.heroes.span();
        let heroesSpanLen = heroesSpan.len();
        loop {
            if (i > heroesSpanLen - 1) {
                break;
            }
            let heroOption = heroesSpan.pop_front();
            let hero = *heroOption.unwrap();
            hero.print();
            i = i + 1;
        }
    }
}

