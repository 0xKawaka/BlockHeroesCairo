#[derive(Copy, Drop)]
struct Heal {
    value: u64,
    target: bool,
    aoe: bool,
    self: bool,
    healType: HealType,
}

#[derive(Copy, Drop)]
enum HealType {
    Flat,
    Percent,
}

fn new(value: u64, target: bool, aoe: bool, self: bool, healType: HealType) -> Heal {
    return Heal { value: value, target: target, aoe: aoe, self: self, healType: healType, };
}

trait HealTrait {
    fn processHeal();
}

impl HealImpl of HealTrait {
    fn processHeal() {}
}
