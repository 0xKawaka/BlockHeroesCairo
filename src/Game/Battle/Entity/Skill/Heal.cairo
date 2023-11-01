use game::Game::libraries::IVector::VecTrait;
use super::super::{Entity, EntityImpl, EntityTrait};
use super::super::super::{Battle, BattleTrait};

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
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle);
}

impl HealImpl of HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        if (self.value == 0) {
            return;
        }

        if (self.aoe) {
            let allies = battle.getAlliesOf(caster.index);
            let mut i: u32 = 0;
            loop {
                if (i > allies.len() - 1) {
                    break;
                }
                let mut ally = *allies[i];
                let heal = (self.value * ally.getMaxHealth()) / 100;
                ally.takeHeal(heal);
                battle.entities.set(ally.index, ally);
                i += 1;
            }
        } else {
            if (self.self) {
                let heal = (self.value * caster.getMaxHealth()) / 100;
                caster.takeHeal(heal);
                battle.entities.set(caster.index, caster);
            }
            if (self.target) {
                let heal = (self.value * target.getMaxHealth()) / 100;
                target.takeHeal(heal);
                battle.entities.set(target.index, target);
            }
        }

    }
}
