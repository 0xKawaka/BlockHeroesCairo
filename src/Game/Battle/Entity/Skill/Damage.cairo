#[derive(Copy, Drop)]
struct Damage {
    damageType: DamageType,
}

#[derive(Copy, Drop)]
enum DamageType {
    Flat,
    Percent,
}

fn new(damageType: DamageType) -> Damage {
    return Damage {
        damageType: damageType,
    };
}

trait DamageTrait {
    fn computeDamage() -> u64;
}

impl DamageImpl of DamageTrait {
    fn computeDamage() -> u64 {
        return 0;
    }
}