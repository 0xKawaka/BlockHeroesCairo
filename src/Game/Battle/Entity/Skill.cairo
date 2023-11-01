use core::box::BoxTrait;
use core::option::OptionTrait;
mod Damage;
mod Heal;
mod Buff;
// use Damage::Damage;
// use Heal::Heal;
use Buff::{BuffImpl};
use super::{Entity, EntityTrait};
use super::super::{Battle, BattleImpl};
use super::super::super::libraries::Random::rand32;
use Damage::{DamageImpl};
use Heal::{HealImpl};

use debug::PrintTrait;

#[derive(Copy, Drop, PartialEq)]
enum TargetType {
    Ally,
    Enemy,
}

#[derive(Copy, Drop)]
struct Skill {
    name: felt252,
    description: felt252,
    cooldown: u16,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: TargetType,
    accuracy: u16,
    buffs: Span<Buff::Buff>
}

fn new(
    name: felt252,
    description: felt252,
    cooldown: u16,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: TargetType,
    accuracy: u16,
    buffs: Span<Buff::Buff>
) -> Skill {
    Skill {
        name: name,
        description: description,
        cooldown: cooldown,
        damage: damage,
        heal: heal,
        targetType: targetType,
        accuracy: accuracy,
        buffs: buffs
    }
}

trait SkillTrait {
    fn cast(self: Skill, ref caster: Entity, ref battle: Battle);
    fn castOnTarget(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity;
    fn print(self: @Skill);
}

impl SkillImpl of SkillTrait {
    fn cast(self: Skill, ref caster: Entity, ref battle: Battle) {
        let mut target = self.pickTarget(caster, ref battle);
        self.castOnTarget(ref caster, ref target, ref battle);
    }
    fn castOnTarget(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        self.applyDamage(ref caster, ref target, ref battle);
        self.applyHeal(ref caster, ref target, ref battle);
        self.applyBuffs(ref caster, ref target, ref battle);
    }
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        let  mut i: u32 = 0;
        loop {
            if (i > self.buffs.len() - 1) {
                break;
            }
            let buff = *self.buffs[i];
            buff.apply(ref caster, ref target, ref battle);
            i += 1;
        }
    }
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        self.damage.apply(ref caster, ref target, ref battle);
        // ADD CRIT LATER
    }
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        self.heal.apply(ref caster, ref target, ref battle);
    }
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity {
        let seed: u32 = 3;
        if self.targetType == TargetType::Ally {
            let allies = battle.getAlliesOf(caster.getIndex());
            let entity = *allies.get(rand32(seed, allies.len())).unwrap().unbox();
            return entity;
        } else if self.targetType == TargetType::Enemy {
            let enemies = battle.getEnemiesOf(caster.getIndex());
            let entity = *enemies.get(rand32(seed, enemies.len())).unwrap().unbox();
            return entity;
        } else {
            return caster;
        }
    }
    fn print(self: @Skill) {
        (*self.name).print();
    // (*self.description).print();
    // (*self.cooldown).print();
    // (*self.damage).print();
    // (*self.heal).print();
    // (*self.targetType).print();
    // (*self.accuracy).print();
    }
}

// applyBuffs(caster: IEntity, target: IEntity, battle:Battle) {
//   for (let i = 0; i < this.skillBuffArray.length; i++) {
//     this.skillBuffArray[i].apply(caster, target, battle)
//   }
// }

// applyStatus(caster: IEntity, target: IEntity, battle:Battle) {
//   for (let i = 0; i < this.skillStatusArray.length; i++) {
//     this.skillStatusArray[i].apply(caster, target, battle)
//   }
// }

// applyCrit(caster: IEntity, damageDict: {[key: number]: {isCrit: boolean, value: number}}) {
//   for (let key in damageDict) {
//     let isCrit = Math.random() < caster.getCriticalChance()
//     damageDict[key].isCrit = isCrit
//     if (isCrit) {
//       damageDict[key].value *= caster.getCriticalDamage()
//     }
//   }
// }
