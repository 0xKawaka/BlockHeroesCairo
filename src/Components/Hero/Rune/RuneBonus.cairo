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
            RuneStatistic::Health => statisticStr = 'health',
            RuneStatistic::Attack => statisticStr = 'attack',
            RuneStatistic::Defense => statisticStr = 'defense',
            RuneStatistic::Speed => statisticStr = 'speed',
        }
        return statisticStr;
    }
}