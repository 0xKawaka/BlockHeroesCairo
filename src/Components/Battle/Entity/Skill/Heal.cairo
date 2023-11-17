use core::array::ArrayTrait;
use game::Libraries::IVector::VecTrait;
use game::Components::Battle::{Battle, BattleTrait};
use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait};
use game::Contracts::EventEmitter::IdAndValueEvent;
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
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent>;
    fn computeHeal(self: Heal, ref target: Entity) -> u64;
}

impl HealImpl of HealTrait {
    fn apply(self: Heal, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent> {
        let mut healByIdArray: Array<IdAndValueEvent> = Default::default();
        if (self.value == 0) {
            return healByIdArray;
        }

        if (self.aoe) {
            let allies = battle.getAliveAlliesOf(caster.index);
            let mut i: u32 = 0;
            loop {
                if (i >= allies.len()) {
                    break;
                }
                let mut ally = *allies[i];


                // Apply on caster direcly to prevent it being overwritten later
                if(caster.index == ally.getIndex()){
                    let heal = self.computeHeal(ref caster);
                    caster.takeHeal(heal);
                    healByIdArray.append(IdAndValueEvent { entityId: caster.index, value: heal });
                    i += 1;
                    continue;
                }
                // Apply on target direcly to prevent it being overwritten later
                else if(target.index == ally.getIndex()) {
                    let heal = self.computeHeal(ref target);
                    target.takeHeal(heal);
                    healByIdArray.append(IdAndValueEvent { entityId: target.index, value: heal });
                    i += 1;
                    continue;
                }

                let heal = self.computeHeal(ref ally);
                ally.takeHeal(heal);
                healByIdArray.append(IdAndValueEvent { entityId: ally.index, value: heal });
                battle.entities.set(ally.index, ally);
                i += 1;
            }
        } else {
            if (self.self) {
                let heal = self.computeHeal(ref caster);
                caster.takeHeal(heal);
                healByIdArray.append(IdAndValueEvent { entityId: caster.index, value: heal });
                // battle.entities.set(caster.index, caster);
            }
            if (self.target) {
                // if already healed self and target is self, return
                if(self.self && target.index == caster.index){
                    return healByIdArray;
                }

                let heal = self.computeHeal(ref target);
                target.takeHeal(heal);
                healByIdArray.append(IdAndValueEvent { entityId: target.index, value: heal });
                // battle.entities.set(target.index, target);
            }
        }
        return healByIdArray;
    }
    fn computeHeal(self: Heal, ref target: Entity) -> u64 {
        match self.healType {
            HealType::Flat => {
                return self.value;
            },
            HealType::Percent => {
                return (self.value * target.getMaxHealth()) / 100;
            },
        }
    }
}
