use  game::Components::Hero::Rune::RuneStatistic;
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct RuneBonus {
    statistic: RuneStatistic,
    isPercent: bool,
}

fn new(statistic: RuneStatistic, isPercent: bool) -> RuneBonus {
    RuneBonus {
        statistic,
        isPercent,
    }
}

trait RuneBonusTrait {
    fn print(self: RuneBonus);
    fn statisticToString(self: RuneBonus)-> felt252;
}

impl RuneBonusImpl of RuneBonusTrait {
    fn print(self: RuneBonus) {
        self.statisticToString().print();
    }
    fn statisticToString(self: RuneBonus)-> felt252 {
        let mut statisticStr: felt252 = '';
        match self.statistic {
            RuneStatistic::Health => statisticStr = 'Health',
            RuneStatistic::Attack => statisticStr = 'Attack',
            RuneStatistic::Defense => statisticStr = 'Defense',
            RuneStatistic::Speed => statisticStr = 'Speed',
        }
        return statisticStr;
    }
}