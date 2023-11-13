use game::Libraries::IVector::VecTrait;
use game::Components::Battle::{Battle, BattleTrait};
use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait};
use game::Libraries::List::ListTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Heal {
    value: u64,
    target: bool,
    aoe: bool,
    self: bool,
    healType: HealType,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
enum HealType {
    Flat,
    Percent,
}

fn new(value: u64, target: bool, aoe: bool, self: bool, healType: HealType) -> Heal {
    return Heal { value: value, target: target, aoe: aoe, self: self, healType: healType, };
}

trait HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn computeHeal(self: Heal, ref caster: Entity, ref target: Entity) -> u64;
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
                if (i >= allies.len()) {
                    break;
                }
                let mut ally = *allies[i];
                let heal = self.computeHeal(ref caster, ref ally);
                ally.takeHeal(heal);
                battle.entities.set(ally.index, ally);
                i += 1;
            }
        } else {
            if (self.self) {
                let heal = self.computeHeal(ref caster, ref caster);
                caster.takeHeal(heal);
                battle.entities.set(caster.index, caster);
            }
            if (self.target) {
                let heal = self.computeHeal(ref caster, ref target);
                target.takeHeal(heal);
                battle.entities.set(target.index, target);
            }
        }
    }
    fn computeHeal(self: Heal, ref caster: Entity, ref target: Entity) -> u64 {
        match self.healType {
            HealType::Flat => {
                return self.value;
            },
            HealType::Percent => {
                return self.value * target.getMaxHealth() / 100;
            },
        }
    }
}
