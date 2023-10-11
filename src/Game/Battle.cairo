mod BattleHeroFactory;
mod BattleHero;

struct Battle {
    battleHeroFactory: BattleHeroFactory::BattleHeroFactory,
}

fn new() -> Battle {
    Battle {
        battleHeroFactory: BattleHeroFactory::new(),
    }
}

