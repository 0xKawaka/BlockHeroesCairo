use game::Game::Battle::Entity::EntityTrait;
use debug::PrintTrait;

use super::{EntityImpl, Entity};

#[derive(Copy, Drop)]
enum DamageOrHealEnum {
    Damage,
    Heal,
}

#[derive(Copy, Drop)]
struct HealthOnTurnProc {
    entityIndex: u32,
    value: u32,
    duration: u32,
    damageOrHeal: DamageOrHealEnum,
}

fn new(entityIndex: u32, value: u32, duration: u32, damageOrHeal: DamageOrHealEnum) -> HealthOnTurnProc {
    HealthOnTurnProc {
        entityIndex: entityIndex,
        value: value,
        duration: duration,
        damageOrHeal: damageOrHeal,
    }
}

trait HealthOnTurnProcTrait {
    fn proc(ref self: HealthOnTurnProc, ref entity: Entity);
    fn isExpired(ref self: HealthOnTurnProc) -> bool;
    fn reduceDuration(ref self: HealthOnTurnProc);
    fn getEntityIndex(self: HealthOnTurnProc) -> u32;
}

impl HealthOnTurnProcImpl of HealthOnTurnProcTrait {
    fn proc(ref self: HealthOnTurnProc, ref entity: Entity) {
        self.reduceDuration();
        match self.damageOrHeal {
            DamageOrHealEnum::Damage => entity.takeDamage((self.value.into() * entity.getMaxHealth()) / 100),
            DamageOrHealEnum::Heal => entity.takeHeal((self.value.into() * entity.getMaxHealth()) / 100),
        }
    }
    fn isExpired(ref self: HealthOnTurnProc) -> bool {
        self.duration == 0
    }
    fn reduceDuration(ref self: HealthOnTurnProc) {
        self.duration -= 1;
    }
    fn getEntityIndex(self: HealthOnTurnProc) -> u32 {
        self.entityIndex
    }
}
