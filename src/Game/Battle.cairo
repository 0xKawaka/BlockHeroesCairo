
mod Entity;
use super::Hero::Hero;

use super::EntityFactory;
use super::EntityFactoryImpl;
use Entity::EntityImpl;

use debug::PrintTrait;

#[derive(Destruct)]
struct Battle {
    battleHeroes: Array<Entity::Entity>,
}

fn new(heroes: Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory) -> Battle {
    let mut battle = Battle {
        battleHeroes: ArrayTrait::new(),
    };
    battle.createHeroesFromHeroesArray(heroes, ref battleHeroFactory);
    return battle;
}

trait BattleTrait {
    fn createHeroesFromHeroesArray(ref self: Battle, heroes: Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory) -> ();
    fn print(self: @Battle) -> ();
}

impl BattleImpl of BattleTrait {
    fn createHeroesFromHeroesArray(ref self: Battle, heroes: Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory) {
        let mut i: u32 = 0;
        let mut heroesSpan = heroes.span();
        let heroesSpanLen = heroesSpan.len();
        loop {
            if(i > heroesSpanLen - 1) {
                break;
            }
            let heroOption = heroesSpan.pop_front();
            let hero = *heroOption.unwrap();
            self.battleHeroes.append(battleHeroFactory.newHero(i, hero));
            i = i + 1;
        };
    }
    fn print(self: @Battle) {
        let mut i: u32 = 0;
        let mut battleHeroesSpan = self.battleHeroes.span();
        let  battleHeroesSpanLen = battleHeroesSpan.len();
        loop {
            if(i > battleHeroesSpanLen - 1) {
                break;
            }
            let battleHeroOption = battleHeroesSpan.pop_front();
            let battleHero = *battleHeroOption.unwrap();
            battleHero.print();
            i = i + 1;
        };
    }
}


