use super::StatModifier;
use super::StatModifier::StatModifierImpl;

#[derive(Drop, Copy)]
struct Statistic {
    value: u64,
    malus: StatModifier::StatModifier,
    bonus: StatModifier::StatModifier,
}

fn new(value: u64) -> Statistic {
    Statistic {
        value: value,
        malus: StatModifier::new(0, 0),
        bonus: StatModifier::new(0, 0),
    }
}

trait StatisticTrait {
    fn reduceDuration(self: Statistic) -> ();
    fn getModifiedValue(self: Statistic) -> u64;
    fn getBonusValue(self: Statistic) -> u64;
    fn getMalusValue(self: Statistic) -> u64;
    fn resetBonusMalus(self: Statistic) -> ();
    fn setBonus(self: Statistic, value: u64, duration: u8) -> ();
    fn setMalus(self: Statistic, value: u64, duration: u8) -> ();
}

impl StatisticImpl of StatisticTrait {
    fn reduceDuration(self: Statistic) {
        self.malus.reduceDuration();
        self.bonus.reduceDuration();
    }
    fn getModifiedValue(self: Statistic) -> u64 {
        self.value + self.getBonusValue() - self.getMalusValue()
    }
    fn getBonusValue(self: Statistic) -> u64 {
        if self.bonus.duration == 0 { return 0; }
        self.value * self.bonus.value
    }
    fn getMalusValue(self: Statistic) -> u64 {
        if self.malus.duration == 0 { return 0; }
        self.value * self.malus.value
    }
    fn resetBonusMalus(self: Statistic) {
        self.malus.reset();
        self.bonus.reset();
    }
    fn setBonus(self: Statistic, value: u64, duration: u8) {
        self.bonus.set(value, duration);
    }
    fn setMalus(self: Statistic, value: u64, duration: u8) {
        self.malus.set(value, duration);
    }

}