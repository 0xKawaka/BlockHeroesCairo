mod RuneBonus;

use game::Components::BaseStatistics;
use game::Libraries::Random::rand32;
use starknet::get_block_timestamp;
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
enum RuneType {
    First,
    Second,
    Third,
    Fourth,
    Fifth,
    Sixth,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
enum RuneRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(starknet::Store, Copy, Drop, Serde, PrintTrait)]
enum RuneStatistic {
    Health,
    Attack,
    Defense,
    Speed,
    // CriticalRate,
    // CriticalDamage,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Rune {
    id: u32,
    statistic: RuneStatistic,
    isPercent: bool,
    rank: u32,
    rarity: RuneRarity,
    runeType: RuneType,
    heroEquipped: Option<u32>,
    rank4Bonus: Option<RuneBonus::RuneBonus>,
    rank8Bonus: Option<RuneBonus::RuneBonus>,
    rank12Bonus: Option<RuneBonus::RuneBonus>,
    rank16Bonus: Option<RuneBonus::RuneBonus>,
}

const RUNE_STAT_COUNT: u32 = 4;
const RUNE_RARITY_COUNT: u32 = 5;
const RUNE_TYPE_COUNT: u32 = 6;

fn new(id: u32) -> Rune {
    let seed = get_block_timestamp() + 22;
    let statistic = getRandomStat(seed);
    let isPercent = getRandomIsPercent(seed);
    let rarity = getRandomRarity(seed);
    let runeType = getRandomType(seed);

    Rune {
        id: id,
        statistic: statistic,
        isPercent: isPercent,
        rank: 0,
        rarity: rarity,
        runeType: runeType,
        heroEquipped: Option::None,
        rank4Bonus: Option::None,
        rank8Bonus: Option::None,
        rank12Bonus: Option::None,
        rank16Bonus: Option::None,
    
    }
}

fn getRandomStat(seed: u64) -> RuneStatistic {
    let rand = rand32(seed, RUNE_STAT_COUNT);
    if rand == 0 {
        return RuneStatistic::Attack;
    } else if rand == 1 {
        return RuneStatistic::Defense;
    } else if rand == 2 {
        return RuneStatistic::Health;
    } else if rand == 3 {
        return RuneStatistic::Speed;
    }
    return RuneStatistic::Attack;
}
fn getRandomRarity(seed: u64) -> RuneRarity {
    return RuneRarity::Common;
    // let rand = rand32(seed, RUNE_RARITY_COUNT);
    // if rand == 0 {
    //     return RuneRarity::Common;
    // } else if rand == 1 {
    //     return RuneRarity::Uncommon;
    // } else if rand == 2 {
    //     return RuneRarity::Rare;
    // } else if rand == 3 {
    //     return RuneRarity::Epic;
    // } else if rand == 4 {
    //     return RuneRarity::Legendary;
    // }
    // return RuneRarity::Common;
}

fn getRandomType(seed: u64) ->  RuneType {
    let rand = rand32(seed, RUNE_TYPE_COUNT);
    if rand == 0 {
        return RuneType::First;
    } else if rand == 1 {
        return RuneType::Second;
    } else if rand == 2 {
        return RuneType::Third;
    } else if rand == 3 {
        return RuneType::Fourth;
    } else if rand == 4 {
        return RuneType::Fifth;
    } else if rand == 5 {
        return RuneType::Sixth;
    }
    return RuneType::First;
}

fn getRandomIsPercent(seed: u64) -> bool {
    let rand = rand32(seed, 2);
    if rand == 0 {
        return true;
    }
    return false;
}

trait RuneTrait {
    // fn computeBonuses(self: Rune,  baseStats: BaseStatistics::BaseStatistics) -> BaseStatistics::BaseStatistics;
    fn upgrade(ref self: Rune);
    fn print(self: Rune);
    fn statisticToString(self: Rune)-> felt252;
}

impl RuneImpl of RuneTrait {
    // fn computeBonuses(self: Rune, baseStats: BaseStatistics::BaseStatistics) -> BaseStatistics::BaseStatistics {
    //     return BaseStatistics::new(0, 0, 0, 0, 0, 0);
    // }
    fn upgrade(ref self: Rune) {
        self.rank += 1;

        let seed = get_block_timestamp() + 22;
        if self.rank == 4 {
            self.rank4Bonus = Option::Some(RuneBonus::new(getRandomStat(seed), false));
        } else if self.rank == 8 {
            self.rank8Bonus = Option::Some(RuneBonus::new(getRandomStat(seed), false));
        } else if self.rank == 12 {
            self.rank12Bonus = Option::Some(RuneBonus::new(getRandomStat(seed), false));
        } else if self.rank == 16 {
            self.rank16Bonus = Option::Some(RuneBonus::new(getRandomStat(seed), false));
        }
    }
    fn print(self: Rune) {
        PrintTrait::print('Rune');
        self.id.print();
        self.statisticToString().print(); 
    }
    fn statisticToString(self: Rune)-> felt252 {
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