use core::array::ArrayTrait;
use game::Libraries::IVector::VecTrait;
use game::Components::Battle::{Battle, BattleTrait};
use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait};
use game::Contracts::EventEmitter::DamageOrHealEvent;
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
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<DamageOrHealEvent>;
    fn computeHeal(self: Heal, ref caster: Entity, ref target: Entity) -> u64;
}

impl HealImpl of HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<DamageOrHealEvent> {
        let mut healByIdArray: Array<DamageOrHealEvent> = Default::default();
        if (self.value == 0) {
            return healByIdArray;
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
                healByIdArray.append(DamageOrHealEvent { entityId: ally.index, value: heal });
                battle.entities.set(ally.index, ally);
                i += 1;
            }
        } else {
            if (self.self) {
                let heal = self.computeHeal(ref caster, ref caster);
                caster.takeHeal(heal);
                healByIdArray.append(DamageOrHealEvent { entityId: caster.index, value: heal });
                battle.entities.set(caster.index, caster);
            }
            if (self.target) {
                let heal = self.computeHeal(ref caster, ref target);
                target.takeHeal(heal);
                healByIdArray.append(DamageOrHealEvent { entityId: target.index, value: heal });
                battle.entities.set(target.index, target);
            }
        }
        return healByIdArray;
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
