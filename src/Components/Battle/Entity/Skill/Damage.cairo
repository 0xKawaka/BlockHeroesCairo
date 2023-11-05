use game::Libraries::IVector::VecTrait;
use game::Components::Battle::{Battle, BattleTrait};
use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait};
use game::Libraries::List::ListTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Damage {
    value: u64,
    target: bool,
    aoe: bool,
    self: bool,
    damageType: DamageType,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
enum DamageType {
    Flat,
    Percent,
}

fn new(value: u64, target: bool, aoe: bool, self: bool, damageType: DamageType) -> Damage {
    return Damage { value: value, target: target, aoe: aoe, self: self, damageType: damageType, };
}

trait DamageTrait {
    fn apply(self: Damage, ref caster: Entity, ref target: Entity, ref battle: Battle);
}

impl DamageImpl of DamageTrait {
    fn apply(self: Damage, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        if (self.value == 0) {
            return;
        }

        if (self.aoe) {
            let enemies = battle.getAlliesOf(target.index);
            let mut i: u32 = 0;
            loop {
                if (i >= enemies.len()) {
                    break;
                }
                let mut enemy = *enemies[i];
                // DamageType::Flat => {
                //     let damage = self.value * (caster.getAttack() / enemy.getDefense());
                //     enemy.takeDamage(damage);
                // },
                // DamageType::Percent => {
                //     let damage = self.value * caster.getMaxHealth() / 100;
                //     enemy.takeDamage(damage);
                // },
                let damage = self.value * (caster.getAttack() / enemy.getDefense());
                enemy.takeDamage(damage);
                battle.entities.set(enemy.getIndex(), enemy);
                i += 1;
            }
        } else {
            if (self.self) {
                let damage = self.value * (caster.getAttack() / caster.getDefense());
                caster.takeDamage(damage);
                battle.entities.set(caster.index, caster);
            }
            if (self.target) {
                let damage = self.value * (caster.getAttack() / target.getDefense());
                target.takeDamage(damage);
                battle.entities.set(target.index, target);
            }
        }
    }
}
