mod Statistic;
mod StatModifier;

use StatModifier::StatModifierImpl;
use Statistic::StatisticImpl;

use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Statistics {
    maxHealth: u64,
    health: u64,
    attack: Statistic::Statistic,
    defense: Statistic::Statistic,
    speed: Statistic::Statistic,
    criticalChance: Statistic::Statistic,
    criticalDamage: Statistic::Statistic,
}

fn new(health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64) -> Statistics {
    Statistics {
        maxHealth: health,
        health: health,
        attack: Statistic::new(attack),
        defense: Statistic::new(defense),
        speed: Statistic::new(speed),
        criticalChance: Statistic::new(criticalChance),
        criticalDamage: Statistic::new(criticalDamage),
    }
}

trait StatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: Statistics);
    fn getStatsBuffs(self: @Statistics) -> Array<StatModifier::StatModifier>;
    fn getStatsDebuffs(self: @Statistics) -> Array<StatModifier::StatModifier>;
    fn applyBonusStatModifier(ref self: Statistics, stat: felt252, statModifierValue: u64, statModifierDuration: u8);
    fn applyMalusStatModifier(ref self: Statistics, stat: felt252, statModifierValue: u64, statModifierDuration: u8);
    fn resetBonusMalus(ref self: Statistics);
    fn getSpeedNextTurn(self: @Statistics) -> u64;
    fn print(self: @Statistics) -> ();
}

impl StatisticsImpl of StatisticsTrait {
    fn reduceBuffsStatusDuration(ref self: Statistics) {
        self.attack.bonus.reduceDuration();
        self.defense.bonus.reduceDuration();
        self.speed.bonus.reduceDuration();
        self.criticalChance.bonus.reduceDuration();
        self.criticalDamage.bonus.reduceDuration();
    }
    fn getStatsBuffs(self: @Statistics) -> Array<StatModifier::StatModifier> {
        let mut buffs: Array<StatModifier::StatModifier> = ArrayTrait::new();
        if(*self.attack.bonus.value != 0 && *self.attack.bonus.duration > 0){
            buffs.append(*self.attack.bonus);
        }
        if(*self.defense.bonus.value != 0 && *self.defense.bonus.duration > 0){
            buffs.append(*self.defense.bonus);
        }
        if(*self.speed.bonus.value != 0 && *self.speed.bonus.duration > 0){
            buffs.append(*self.speed.bonus);
        }
        if(*self.criticalChance.bonus.value != 0 && *self.criticalChance.bonus.duration > 0){
            buffs.append(*self.criticalChance.bonus);
        }
        if(*self.criticalDamage.bonus.value != 0 && *self.criticalDamage.bonus.duration > 0){
            buffs.append(*self.criticalDamage.bonus);
        }
        return buffs;
    }
    fn getStatsDebuffs(self: @Statistics) -> Array<StatModifier::StatModifier> {
        let mut debuffs: Array<StatModifier::StatModifier> = ArrayTrait::new();
        if(*self.attack.malus.value != 0 && *self.attack.malus.duration > 0){
            debuffs.append(*self.attack.malus);
        }
        if(*self.defense.malus.value != 0 && *self.defense.malus.duration > 0){
            debuffs.append(*self.defense.malus);
        }
        if(*self.speed.malus.value != 0 && *self.speed.malus.duration > 0){
            debuffs.append(*self.speed.malus);
        }
        if(*self.criticalChance.malus.value != 0 && *self.criticalChance.malus.duration > 0){
            debuffs.append(*self.criticalChance.malus);
        }
        if(*self.criticalDamage.malus.value != 0 && *self.criticalDamage.malus.duration > 0){
            debuffs.append(*self.criticalDamage.malus);
        }
        return debuffs;
    }
    fn applyBonusStatModifier(ref self: Statistics, stat: felt252, statModifierValue: u64, statModifierDuration: u8) {
        if(stat == 'speed'){
            self.speed.setBonus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'defense'){
            self.defense.setBonus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'attack'){
            self.attack.setBonus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'criticalChance'){
            self.criticalChance.setBonus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'criticalDamage'){
            self.criticalDamage.setBonus(statModifierValue, statModifierDuration);
        }
    }
    fn applyMalusStatModifier(ref self: Statistics, stat: felt252, statModifierValue: u64, statModifierDuration: u8) {
        if(stat == 'speed'){
            self.speed.setMalus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'defense'){
            self.defense.setMalus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'attack'){
            self.attack.setMalus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'criticalChance'){
            self.criticalChance.setMalus(statModifierValue, statModifierDuration);
        }
        else if(stat == 'criticalDamage'){
            self.criticalDamage.setMalus(statModifierValue, statModifierDuration);
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
    fn print(self: @Statistics) {
        (*self.health).print();
        (*self.attack.value).print();
        (*self.defense.value).print();
        (*self.speed.value).print();
        (*self.criticalChance.value).print();
        (*self.criticalDamage.value).print();
    }
}