#[derive(starknet::Store, Copy, Drop, Serde)]
struct StatisticsWrapper {
    health: u64,
    attack: u64,
    defense: u64,
    speed: u64,
    criticalRate: u64,
    criticalDamage: u64,
}

fn new(health: u64, attack: u64, defense: u64, speed: u64, criticalRate: u64, criticalDamage: u64) -> StatisticsWrapper {
    StatisticsWrapper {
        health,
        attack,
        defense,
        speed,
        criticalRate,
        criticalDamage,
    }
}