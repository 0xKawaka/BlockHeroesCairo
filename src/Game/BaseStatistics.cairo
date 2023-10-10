use starknet::ContractAddress;

use dict::Felt252DictTrait;
use nullable::{nullable_from_box, match_nullable, FromNullableResult};

const decimals: u64 = 1000;
const LEVEL_MULTIPLIER_BY_RANK: u64 = 10;


#[derive(Copy, Drop)]
struct BaseStatistics {
    health: u64,
    attack: u64,
    defense: u64,
    speed: u64,
    criticalChance: u64,
    criticalDamage: u64,
}

fn createBaseStatisticsDict() -> Felt252Dict<Nullable<BaseStatistics>> {
    let mut dict: Felt252Dict<Nullable<BaseStatistics>> = Default::default();
    dict.insert('knight', nullable_from_box(BoxTrait::new(new(100, 10, 10, 10, 10, 10))));
    dict.insert('priest', nullable_from_box(BoxTrait::new(new(100, 10, 10, 10, 10, 10))));
    return dict;
}

fn new(health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage: u64) -> BaseStatistics {
    return BaseStatistics {
        health: health,
        attack: attack,
        defense: defense,
        speed: speed,
        criticalChance: criticalChance,
        criticalDamage: criticalDamage,
    };
}

trait BaseStatisticsTrait {
    fn getHealth(self: BaseStatistics, level: u16, rank: u16) -> u64;
}

impl BaseStatisticsImpl of BaseStatisticsTrait {
    fn getHealth(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.health + self.health * level.into() * LEVEL_MULTIPLIER_BY_RANK / decimals;
    }
}


    
