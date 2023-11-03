use super::super::super::super::super::Libraries::IVector::VecTrait;
use super::super::super::{Battle, BattleTrait};
use super::super::{Entity, EntityImpl, EntityTrait};

use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, PartialEq, Serde)]
enum BuffType {
    SpeedUp,
    SpeedDown,
    AttackUp,
    AttackDown,
    DefenseUp,
    DefenseDown,
    Poison,
    Regen,
    Stun,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Buff {
    buffType: BuffType,
    value: u64,
    duration: u8,
    target: bool,
    aoe: bool,
    self: bool,
}

fn new(buffType: BuffType, value: u64, duration: u8, target: bool, aoe: bool, self: bool) -> Buff {
    Buff {
        buffType: buffType,
        value: value,
        duration: duration,
        target: target,
        aoe: aoe,
        self: self,
    }
}

trait BuffTrait {
    fn apply(self: Buff, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn applyStatOrOther(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool);
    fn getAoeEntities(self: Buff, ref caster: Entity, ref battle: Battle, isBonus: bool) -> Array<Entity>;
    fn isBonus(self: Buff) -> bool;
    fn isStat(self: Buff) -> bool;
}

impl BuffImpl of BuffTrait {
    fn apply(self: Buff, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        let isBonus = self.isBonus();
        let isStat = self.isStat();
        if(self.aoe){
            let entities = self.getAoeEntities(ref caster, ref battle, isBonus);
            let mut i: u32 = 0;
            loop {
                if(i > entities.len() - 1){
                    break;
                }
                let mut entity = *entities[i];
                self.applyStatOrOther(ref entity, ref battle, isStat, isBonus);
                battle.entities.set(entity.getIndex(), entity);
                i += 1;
            }
        }
        else {
            if(self.self && self.target && caster.getIndex() == target.getIndex() && battle.getAlliesOf(caster.getIndex()).len() > 1){
                self.applyStatOrOther(ref caster, ref battle, isStat, isBonus);
                // battle.pickAllyTarget(caster).applyBonusStatModifier(self.type, new StatModifier(self.value, self.duration))
                return;
            }
            if(self.self){
                self.applyStatOrOther(ref caster, ref battle, isStat, isBonus);

            }
            if(self.target) {
                self.applyStatOrOther(ref target, ref battle, isStat, isBonus);
            }
        }
    }
    fn applyStatOrOther(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool) {
        if(isStat){
            entity.applyStatModifier(self.buffType, self.value, self.duration);
        }
        else if (self.buffType == BuffType::Poison) {
            entity.applyPoison(ref battle, self.value, self.duration);
        }
        else if (self.buffType == BuffType::Regen) {
            entity.applyRegen(ref battle, self.value, self.duration);
        }
        else if (self.buffType == BuffType::Stun) {
            entity.applyStun(self.duration);
        }
        else {
            let mut error = ArrayTrait::new();
            error.append('Buff type not implemented');
            panic(error);
        }
        battle.entities.set(entity.getIndex(), entity);
    }
    fn getAoeEntities(self: Buff, ref caster: Entity, ref battle: Battle, isBonus: bool) -> Array<Entity> {
        if(isBonus) {
            return battle.getAlliesOf(caster.getIndex());
        }
        else {
            return battle.getEnemiesOf(caster.getIndex());
        }
    }
    fn isBonus(self: Buff) -> bool {
        match self.buffType {
            BuffType::SpeedUp => true,
            BuffType::SpeedDown => false,
            BuffType::AttackUp => true,
            BuffType::AttackDown => false,
            BuffType::DefenseUp => true,
            BuffType::DefenseDown => false,
            BuffType::Poison => false,
            BuffType::Regen => true,
            BuffType::Stun => false,
        }
    }
    fn isStat(self: Buff) -> bool {
        match self.buffType {
            BuffType::SpeedUp => true,
            BuffType::SpeedDown => true,
            BuffType::AttackUp => true,
            BuffType::AttackDown => true,
            BuffType::DefenseUp => true,
            BuffType::DefenseDown => true,
            BuffType::Poison => false,
            BuffType::Regen => false,
            BuffType::Stun => false,
        }
    }
}

