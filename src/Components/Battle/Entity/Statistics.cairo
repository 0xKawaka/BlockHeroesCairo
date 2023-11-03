use super::super::super::Battle::Entity::Statistics::Statistic::StatisticTrait;
mod Statistic;
mod StatModifier;

use StatModifier::StatModifierImpl;
use Statistic::StatisticImpl;
use super::super::super::super::Libraries::SignedIntegers::{i64::i64, i64::i64Impl};
use super::Skill::Buff::BuffType;

use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Statistics {
    maxHealth: u64,
    health: i64,
    attack: Statistic::Statistic,
    defense: Statistic::Statistic,
    speed: Statistic::Statistic,
    criticalChance: Statistic::Statistic,
    criticalDamage: Statistic::Statistic,
}

fn new(
    health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage: u64
) -> Statistics {
    Statistics {
        maxHealth: health,
        health: i64Impl::new(health, false),
        attack: Statistic::new(attack),
        defense: Statistic::new(defense),
        speed: Statistic::new(speed),
        criticalChance: Statistic::new(criticalChance),
        criticalDamage: Statistic::new(criticalDamage),
    }
}

trait StatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: Statistics);
    fn applyStatModifier(
        ref self: Statistics, buffType: BuffType, statModifierValue: u64, statModifierDuration: u8,
    );
    fn resetBonusMalus(ref self: Statistics);
    fn getSpeedNextTurn(self: @Statistics) -> u64;
    fn getAttack(self: @Statistics) -> u64;
    fn getDefense(self: @Statistics) -> u64;
    fn getSpeed(self: @Statistics) -> u64;
    fn getCriticalChance(self: @Statistics) -> u64;
    fn getCriticalDamage(self: @Statistics) -> u64;
    fn getHealth(self: @Statistics) -> i64;
    fn getMaxHealth(self: @Statistics) -> u64;
    fn print(self: @Statistics);
}

impl StatisticsImpl of StatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: Statistics) {
        self.attack.bonus.reduceDuration();
        self.defense.bonus.reduceDuration();
        self.speed.bonus.reduceDuration();
        self.criticalChance.bonus.reduceDuration();
        self.criticalDamage.bonus.reduceDuration();
    }
    fn applyStatModifier(
        ref self: Statistics, buffType: BuffType, statModifierValue: u64, statModifierDuration: u8
    ) {
        if(buffType == BuffType::SpeedUp) {
            self.speed.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::SpeedDown) {
            self.speed.setMalus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::AttackUp) {
            self.attack.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::AttackDown) {
            self.attack.setMalus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::DefenseUp) {
            self.defense.setBonus(statModifierValue, statModifierDuration);
        }
        else if (buffType == BuffType::DefenseDown) {
            self.defense.setMalus(statModifierValue, statModifierDuration);
        }      
    }
    fn resetBonusMalus(ref self: Statistics) {
        self.attack.resetBonusMalus();
        self.defense.resetBonusMalus();
        self.speed.resetBonusMalus();
        self.criticalChance.resetBonusMalus();
        self.criticalDamage.resetBonusMalus();
    }
    fn getSpeedNextTurn(self: @Statistics) -> u64 {
        return *self.speed.value;
    }
    fn getAttack(self: @Statistics) -> u64 {
        return self.attack.getModifiedValue();
    }
    fn getDefense(self: @Statistics) -> u64 {
        return self.defense.getModifiedValue();
    }
    fn getSpeed(self: @Statistics) -> u64 {
        return self.speed.getModifiedValue();
    }
    fn getCriticalChance(self: @Statistics) -> u64 {
        return self.criticalChance.getModifiedValue();
    }
    fn getCriticalDamage(self: @Statistics) -> u64 {
        return self.criticalDamage.getModifiedValue();
    }
    fn getHealth(self: @Statistics) -> i64 {
        return *self.health;
    }
    fn getMaxHealth(self: @Statistics) -> u64 {
        return *self.maxHealth;
    }
    fn print(self: @Statistics) {
        (*self.health).print();
        (*self.attack.value).print();
        (*self.defense.value).print();
        (*self.speed.value).print();
        (*self.criticalChance.value).print();
        (*self.criticalDamage.value).print();
    }
}
