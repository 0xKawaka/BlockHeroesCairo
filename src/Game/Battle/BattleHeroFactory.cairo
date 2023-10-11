use super::BattleHero;
use super::super::BaseStatistics;
use BaseStatistics::BaseStatisticsImpl;
use nullable::{match_nullable, FromNullableResult};

struct BattleHeroFactory {
    baseStatisticsDict: Felt252Dict<Nullable<BaseStatistics::BaseStatistics>>,
}

fn new() -> BattleHeroFactory {
    let mut baseStatisticsDict = BaseStatistics::createBaseStatisticsDict();
    BattleHeroFactory {
        baseStatisticsDict: baseStatisticsDict,
    }
}

trait BattleHeroFactoryTrait {
    fn newHero(self: BattleHeroFactory, name: felt252, level: u16, rank: u16) -> BattleHero::BattleHero;
}

impl BattleHeroFactoryImpl of BattleHeroFactoryTrait {
    fn newHero(mut self: BattleHeroFactory, name: felt252, level: u16, rank: u16) -> BattleHero::BattleHero {
        let baseStatsBox = self.baseStatisticsDict.get(name);
        let baseStats = match match_nullable(baseStatsBox) {
            FromNullableResult::Null(()) => panic_with_felt252('No value found newHero'),
            FromNullableResult::NotNull(val) => val.unbox(),
        };
        // let health = baseStatsKnight.getHealth(level, rank);
        // health.print();
        let mut statistics = baseStats.getAllStatistics(level, rank);
    }
}

