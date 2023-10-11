mod Statistic;
mod StatModifier;

struct Statistics {
    maxHealth: u64,
    health: u64,
    attack: Statistic::Statistic,
    defense: Statistic::Statistic,
    speed: Statistic::Statistic,
    criticalChance: Statistic::Statistic,
    criticalDamage: Statistic::Statistic,
}