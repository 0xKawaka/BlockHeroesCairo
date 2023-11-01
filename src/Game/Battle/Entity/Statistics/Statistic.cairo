use super::StatModifier;
use super::StatModifier::StatModifierImpl;

#[derive(Drop, Copy, Destruct)]
struct Statistic {
    value: u64,
    malus: StatModifier::StatModifier,
    bonus: StatModifier::StatModifier,
}

fn new(value: u64) -> Statistic {
    Statistic { value: value, malus: StatModifier::new(0, 0), bonus: StatModifier::new(0, 0), }
}

trait StatisticTrait {
    fn reduceDuration(ref self: Statistic);
    fn getModifiedValue(self: @Statistic) -> u64;
    fn getBonusValue(self: @Statistic) -> u64;
    fn getMalusValue(self: @Statistic) -> u64;
    fn resetBonusMalus(ref self: Statistic);
    fn setBonus(ref self: Statistic, value: u64, duration: u8);
    fn setMalus(ref self: Statistic, value: u64, duration: u8);
}

impl StatisticImpl of StatisticTrait {
    fn reduceDuration(ref self: Statistic) {
        self.malus.reduceDuration();
        self.bonus.reduceDuration();
    }
    fn getModifiedValue(self: @Statistic) -> u64 {
        (*self.value + self.getBonusValue()) - self.getMalusValue()
    }
    fn getBonusValue(self: @Statistic) -> u64 {
        if *self.bonus.duration == 0 {
            return 0;
        }
        return (*self.value * *self.bonus.value) / 100;
    }
    fn getMalusValue(self: @Statistic) -> u64 {
        if *self.malus.duration == 0 {
            return 0;
        }
        return (*self.value * *self.malus.value) / 100;
    }
    fn resetBonusMalus(ref self: Statistic) {
        self.malus.reset();
        self.bonus.reset();
    }
    fn setBonus(ref self: Statistic, value: u64, duration: u8) {
        if(duration < self.bonus.duration && value < self.bonus.value) {
            return;
        }
        self.bonus.set(value, duration);
    }
    fn setMalus(ref self: Statistic, value: u64, duration: u8) {
        assert(value < 100, 'Malus value greater than 100');
        if(duration < self.malus.duration && value < self.malus.value) {
            return;
        }
        self.malus.set(value, duration);
    }
}
