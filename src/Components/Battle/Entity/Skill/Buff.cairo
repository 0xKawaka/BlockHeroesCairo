use game::Libraries::IVector::VecTrait;
use game::Components::Battle::{Battle, BattleTrait};
use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait};
use game::Libraries::List::ListTrait;
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
    fn applyByType(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool, duration: u8);
    fn applyByTypeAndSetChange(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool, duration: u8);
    fn getAoeEntities(self: Buff, ref caster: Entity, ref battle: Battle, isBonus: bool) -> Array<Entity>;
    fn isBonus(self: Buff) -> bool;
    fn isStat(self: Buff) -> bool;
}

impl BuffImpl of BuffTrait {
    fn apply(self: Buff, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        PrintTrait::print('Applying buff');
        let isBonus = self.isBonus();
        let isStat = self.isStat();
        if(self.aoe){
            let entities = self.getAoeEntities(ref caster, ref battle, isBonus);
            let mut i: u32 = 0;
            loop {
                if(i >= entities.len()){
                    break;
                }
                let mut entity = *entities[i];
                
                if(caster.getIndex() == entity.getIndex()){
                    if(isStat) {
                        // +1 cause reduce stat buff at end of turn
                        self.applyByType(ref caster, ref battle, isStat, isBonus, self.duration + 1);
                    }
                    else {
                        self.applyByType(ref caster, ref battle, isStat, isBonus, self.duration);
                    }
                }
                else if(target.index == entity.index){
                    self.applyByType(ref target, ref battle, isStat, isBonus, self.duration);
                }
                else {
                    self.applyByTypeAndSetChange(ref entity, ref battle, isStat, isBonus, self.duration);
                }
                i += 1;
            }
        }
        else {
            if(self.self){
                if(isStat) {
                    self.applyByType(ref caster, ref battle, isStat, isBonus, self.duration + 1);
                }
                else {
                    self.applyByTypeAndSetChange(ref caster, ref battle, isStat, isBonus, self.duration);
                }
            }
            if(self.target) {
                if(self.self && target.index == caster.index){
                    return;
                }
                self.applyByType(ref target, ref battle, isStat, isBonus, self.duration);
            }
        }
    }

    fn applyByType(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool, duration: u8) {
        if(isStat){
            entity.applyStatModifier(self.buffType, self.value, duration);
        }
        else if (self.buffType == BuffType::Poison) {
            entity.applyPoison(ref battle, self.value, duration);
        }
        else if (self.buffType == BuffType::Regen) {
            entity.applyRegen(ref battle, self.value, duration);
        }
        else if (self.buffType == BuffType::Stun) {
            entity.applyStun(duration);
        }
        else {
            let mut error = ArrayTrait::new();
            error.append('Buff type not implemented');
            panic(error);
        }
    }

    fn applyByTypeAndSetChange(self: Buff, ref entity: Entity, ref battle: Battle, isStat: bool, isBonus: bool, duration: u8) {
        self.applyByType(ref entity, ref battle, isStat, isBonus, duration);
        battle.entities.set(entity.getIndex(), entity);
    }
    fn getAoeEntities(self: Buff, ref caster: Entity, ref battle: Battle, isBonus: bool) -> Array<Entity> {
        if(isBonus) {
            return battle.getAliveAlliesOf(caster.getIndex());
        }
        else {
            return battle.getAliveEnemiesOf(caster.getIndex());
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

