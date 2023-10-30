mod Damage;
mod Heal;
// use Damage::Damage;
// use Heal::Heal;

use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Skill {
    name: felt252,
    description: felt252,
    cooldown: u16,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: felt252,
    accuracy: u16,
}

fn new(
    name: felt252,
    description: felt252,
    cooldown: u16,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: felt252,
    accuracy: u16,
) -> Skill {
    Skill {
        name: name,
        description: description,
        cooldown: cooldown,
        damage: damage,
        heal: heal,
        targetType: targetType,
        accuracy: accuracy,
    }
}

trait SkillTrait {
    fn print(self: @Skill);
}

impl SkillImpl of SkillTrait {
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
// name: string
// description: string
// cooldown: number
// damage: IDamage
// heal: IHeal
// targetType: string
// accuracy: number
// // aoe: boolean
// skillStatusArray: Array<ISkillBuffStatus>
// skillBuffArray: Array<ISkillBuffStatus>

// constructor(name: string, description: string, cooldown: number, damage: IDamage, heal: IHeal, targetType: string, accuracy: number, aoe: boolean, skillStatusArray: Array<ISkillBuffStatus>, skillBuffArray: Array<ISkillBuffStatus>) {
//   this.name = name
//   this.description = description
//   this.cooldown = cooldown
//   this.damage = damage
//   this.heal = heal
//   this.targetType = targetType
//   this.accuracy = accuracy
//   // this.aoe = aoe
//   this.skillStatusArray = skillStatusArray
//   this.skillBuffArray = skillBuffArray
// }

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

// computeHeal(caster: IEntity, target: IEntity, battle:Battle): {[key: number]: {value: number}} {
//   let healDict = this.heal.computeHeal(caster, target, battle)
//   return healDict
// }

// computeDamage(caster: IEntity, target: IEntity, battle:Battle): {[key: number]: {isCrit: boolean, value: number}} {
//   let damageDict = this.damage.computeDamage(caster, target, battle)
//   this.applyCrit(caster, damageDict)
//   return damageDict
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

// pickTargetCastedByEnemy(caster: IEntity, battle:Battle): IEntity | false {
//   if (this.targetType === "enemy") {
//     return battle.pickRandomAlly()
//   } else if (this.targetType === "self") {
//     return caster
//   } else {
//     return battle.pickRandomEnemy()
//   }
// }

