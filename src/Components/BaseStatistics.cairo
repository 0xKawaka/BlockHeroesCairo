use starknet::ContractAddress;

use dict::Felt252DictTrait;
use nullable::{nullable_from_box, match_nullable, FromNullableResult};

const decimals: u64 = 100;
const LEVEL_MULTIPLIER_BY_RANK: u64 = 10;

use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct BaseStatistics {
    health: u64,
    attack: u64,
    defense: u64,
    speed: u64,
    criticalRate: u64,
    criticalDamage: u64,
}


fn new(
    health: u64, attack: u64, defense: u64, speed: u64, criticalRate: u64, criticalDamage: u64
) -> BaseStatistics {
    return BaseStatistics {
        health: health,
        attack: attack,
        defense: defense,
        speed: speed,
        criticalRate: criticalRate,
        criticalDamage: criticalDamage,
    };
}

trait BaseStatisticsTrait {
    fn getHealth(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getAttack(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getDefense(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getSpeed(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getCriticalRate(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getCriticalDamage(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getAllStatistics(
        self: BaseStatistics, level: u16, rank: u16
    ) -> BaseStatistics;
}

impl BaseStatisticsImpl of BaseStatisticsTrait {
    fn getHealth(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.health + self.health * (level.into() - 1) / decimals;
    }
    fn getAttack(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.attack + self.attack * (level.into() - 1) / decimals;
    }
    fn getDefense(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.defense + self.defense * (level.into() - 1) / decimals;
    }
    fn getSpeed(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.speed + self.speed * (level.into() - 1) / decimals;
    }
    fn getCriticalRate(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.criticalRate;
    }
    fn getCriticalDamage(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.criticalDamage;
    }
    fn getAllStatistics(
        self: BaseStatistics, level: u16, rank: u16
    ) -> BaseStatistics {
        return super::BaseStatistics::new(
            self.getHealth(level, rank),
            self.getAttack(level, rank),
            self.getDefense(level, rank),
            self.getSpeed(level, rank),
            self.getCriticalRate(level, rank),
            self.getCriticalDamage(level, rank)
        );
    }
}

