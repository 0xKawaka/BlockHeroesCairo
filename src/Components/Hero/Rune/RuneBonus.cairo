use  game::Components::Hero::Rune::RuneStatistic;

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