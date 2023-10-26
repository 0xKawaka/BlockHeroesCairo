#[derive(Copy, Drop)]
struct Heal {
    healType: HealType,
}

#[derive(Copy, Drop)]
enum HealType {
    Flat,
    Percent,
}

fn new(healType: HealType) -> Heal {
    return Heal {
        healType: healType,
    };
}

trait HealTrait {
    fn computeHeal() -> u64;
}

impl HealImpl of HealTrait {
    fn computeHeal() -> u64 {
        return 0;
    }
}