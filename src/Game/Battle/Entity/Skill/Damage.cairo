use game::Game::Battle::BattleTrait;
use game::Game::Battle::Entity::EntityTrait;
use super::super::Entity;
use super::super::EntityImpl;
use super::super::super::Battle;

#[derive(Copy, Drop)]
struct Damage {
    value: u64,
    target: bool,
    aoe: bool,
    self: bool,
    damageType: DamageType,
}

#[derive(Copy, Drop)]
enum DamageType {
    Flat,
    Percent,
}

fn new(value: u64, target: bool, aoe: bool, self: bool, damageType: DamageType) -> Damage {
    return Damage { value: value, target: target, aoe: aoe, self: self, damageType: damageType, };
}

trait DamageTrait {
    fn processDamage(self: @Damage, ref caster: Entity, ref target: Entity, ref battle: Battle);
}

impl DamageImpl of DamageTrait {
    fn processDamage(self: @Damage, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        if (*self.value == 0) {
            return;
        }
        // VERIFY DAMAGE ARE TAKEN BY THE ENTITIES AND NOT COPY OF IT
        if (*self.aoe) {
            let enemies = battle.getAlliesOf(target.index);
            let mut i: u32 = 0;
            loop {
                if (i > enemies.len() - 1) {
                    break;
                }
                let mut enemy = *enemies[i];
                let damage = *self.value * (caster.getAttack() / enemy.getDefense());
                enemy.takeDamage(damage);
                i += 1;
            }
        } else {
            if (*self.self) {
                let damage = *self.value * (caster.getAttack() / caster.getDefense());
                caster.takeDamage(damage);
            }
            if (*self.target) {
                let damage = *self.value * (caster.getAttack() / target.getDefense());
                target.takeDamage(damage);
            }
        }
    }
}
