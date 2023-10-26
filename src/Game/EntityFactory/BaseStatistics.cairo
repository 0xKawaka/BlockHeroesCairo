use starknet::ContractAddress;

use dict::Felt252DictTrait;
use nullable::{nullable_from_box, match_nullable, FromNullableResult};

const decimals: u64 = 1000;
const LEVEL_MULTIPLIER_BY_RANK: u64 = 10;

use debug::PrintTrait;

#[derive(Copy, Drop)]
struct BaseStatistics {
    health: u64,
    attack: u64,
    defense: u64,
    speed: u64,
    criticalChance: u64,
    criticalDamage: u64,
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
    fn getAttack(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getDefense(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getSpeed(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getCriticalChance(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getCriticalDamage(self: BaseStatistics, level: u16, rank: u16) -> u64;
    fn getAllStatistics(self: BaseStatistics, level: u16, rank: u16) -> (u64, u64, u64, u64, u64, u64);
}

impl BaseStatisticsImpl of BaseStatisticsTrait {
    fn getHealth(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.health + self.health * (level.into() - 1) * LEVEL_MULTIPLIER_BY_RANK / decimals;
    }
    fn getAttack(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.attack + self.attack * (level.into() - 1) * LEVEL_MULTIPLIER_BY_RANK / decimals;
    }
    fn getDefense(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.defense + self.defense * (level.into() - 1) * LEVEL_MULTIPLIER_BY_RANK / decimals;
    }
    fn getSpeed(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.speed + self.speed * (level.into() - 1) * LEVEL_MULTIPLIER_BY_RANK / decimals;
    }
    fn getCriticalChance(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.criticalChance;
    }
    fn getCriticalDamage(self: BaseStatistics, level: u16, rank: u16) -> u64 {
        return self.criticalDamage;
    }
    fn getAllStatistics(self: BaseStatistics, level: u16, rank: u16) -> (u64, u64, u64, u64, u64, u64) {
        return (self.getHealth(level, rank), self.getAttack(level, rank), self.getDefense(level, rank), self.getSpeed(level, rank), self.getCriticalChance(level, rank), self.getCriticalDamage(level, rank));
    }

}


    
