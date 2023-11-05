mod Statistics;
mod TurnBar;
mod Skill;
mod HealthOnTurnProc;
mod StunOnTurnProc;
mod Cooldowns;
mod SkillSet;

use HealthOnTurnProc::{DamageOrHealEnum};
use StunOnTurnProc::{StunOnTurnProcImpl};
use Skill::{SkillImpl, Buff::BuffType};
use Cooldowns::{CooldownsImpl, CooldownsTrait};
use SkillSet::{SkillSetImpl, SkillSetTrait};
use game::Components::Battle::Entity::{StunOnTurnProc::StunOnTurnProcTrait, Statistics::StatisticsTrait};
use game::Components::Battle::Entity::Statistics::{StatisticsImpl, Statistic::StatModifier::StatModifier};
use game::Components::Battle::Entity::TurnBar::TurnBarTrait;
use game::Libraries::NullableVector::{VecTrait, NullableVector};
use game::Libraries::SignedIntegers::{i64::i64, i64::i64Impl};
use game::Libraries::Random::{rand8};
use game::Libraries::List::{List, ListTrait};
use core::box::BoxTrait;
use core::traits::Into;
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
enum AllyOrEnemy {
    Ally,
    Enemy,
}

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Entity {
    index: u32,
    name: felt252,
    turnBar: TurnBar::TurnBar,
    statistics: Statistics::Statistics,
    skillSet: SkillSet::SkillSet,
    cooldowns: Cooldowns::Cooldowns,
    stunOnTurnProc: StunOnTurnProc::StunOnTurnProc,
    allyOrEnemy: AllyOrEnemy,
}

fn new(index: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64,
skillSet: SkillSet::SkillSet, allyOrEnemy: AllyOrEnemy) -> Entity {
    Entity {
        index: index,
        name: name,
        statistics: Statistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: TurnBar::new(index, speed),
        skillSet: skillSet,
        cooldowns: Cooldowns::new(),
        stunOnTurnProc: StunOnTurnProc::new(0),
        allyOrEnemy: allyOrEnemy,
    }
}

trait EntityTrait {
    fn playTurn(ref self: Entity, ref entities: List<Entity>, ref aliveEntities: List<u32>, ref deadEntities: List<u32>, ref turnTimeline: List<u32>, ref allies: List<u32>, ref enemies: List<u32>);
    fn playTurnPlayer(ref self: Entity, skillIndex: u8, ref target: Entity,);
    fn endTurn(ref self: Entity);
    fn die(ref self: Entity);
    fn pickSkill(ref self: Entity) -> u8;
    fn takeDamage(ref self: Entity, damage: u64);
    fn takeHeal(ref self: Entity, heal: u64);
    fn incrementTurnbar(ref self: Entity);
    fn updateTurnBarSpeed(ref self: Entity);
    fn processEndTurnProcs(ref self: Entity);
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8);
    fn applyPoison(ref self: Entity, value: u64, duration: u8);
    fn applyRegen(ref self: Entity, value: u64, duration: u8);
    fn applyStun(ref self: Entity, duration: u8);
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8);
    // fn randCrit(ref self: Entity) -> bool;
    fn isStunned(ref self: Entity) -> bool;
    fn isDead(ref self: Entity) -> bool;
    fn getIndex(self: @Entity) -> u32;
    fn getTurnBar(self: @Entity) -> @TurnBar::TurnBar;
    fn getAttack(self: @Entity) -> u64;
    fn getDefense(self: @Entity) -> u64;
    fn getSpeed(self: @Entity) -> u64;
    fn getCriticalChance(self: @Entity) -> u64;
    fn getCriticalDamage(self: @Entity) -> u64;
    fn getHealth(self: @Entity) -> i64;
    fn getMaxHealth(self: @Entity) -> u64;
    fn print(self: @Entity);
    fn printSkill(self: @Entity);
}

impl EntityImpl of EntityTrait {
    fn playTurn(ref self: Entity, ref entities: List<Entity>, ref aliveEntities: List<u32>, ref deadEntities: List<u32>, ref turnTimeline: List<u32>, ref allies: List<u32>, ref enemies: List<u32>) {
        // if(self.isDead()) {
        //     self.die(ref battle);
        //     return;
        // }
        // if(self.isStunned()){
        //     self.endTurn(ref battle);
        //     return;
        // }
        // else {
        //     match self.allyOrEnemy {
        //         AllyOrEnemy::Ally => {
        //             battle.waitForPlayerAction();
        //             battle.entities.set(self.getIndex(), self);
        //         },
        //         AllyOrEnemy::Enemy => {
        //             let skillIndex = self.pickSkill();
        //             // let skill = *self.skillSpan[skillIndex.into()];
        //             let skill = self.skillSet.get(skillIndex);
        //             skill.cast(skillIndex, ref self, ref battle);
        //             self.endTurn(ref battle);
        //         },
        //     }
        // }
    }
    fn playTurnPlayer(ref self: Entity, skillIndex: u8, ref target: Entity) {
        // let skill = self.skillSet.get(skillIndex);
        // skill.castOnTarget(skillIndex, ref self, ref target, ref battle);
        // self.endTurn(ref battle);
    }
    fn endTurn(ref self: Entity) {
        // self.processEndTurnProcs(ref battle);
        // self.turnBar.resetTurn();
        // self.cooldowns.reduceCooldowns();
        // battle.entities.set(self.getIndex(), self);
    }
    fn die(ref self: Entity) {
        // battle.deadEntities.append(self.getIndex());
        // if(battle.checkBattleOver()) {
        //     return;
        // }
        // let mut i: u32 = 0;
        // loop {
        //     if(i > battle.aliveEntities.len() - 1) {
        //         break;
        //     }
        //     let entityIndex = battle.aliveEntities.get(i).unwrap();
        //     if (entityIndex == self.getIndex()) {
        //         battle.aliveEntities.(i);
        //         break;
        //     }
        //     i = i + 1;
        // };

        // let mut i: u32 = 0;
        // loop {
        //     if(i > battle.turnTimeline.len() - 1) {
        //         break;
        //     }
        //     let entityIndex = battle.turnTimeline.get(i).unwrap();
        //     if (entityIndex == self.getIndex()) {
        //         battle.turnTimeline.remove(i);
        //         break;
        //     }
        //     i = i + 1;
        // };
    }
    fn pickSkill(ref self: Entity) -> u8 {
        // let mut iSeed: u32 = 0;
        // if(self.cooldowns.isOnCooldown(1) && self.cooldowns.isOnCooldown(2)) {
        //     return 0;
        // }
        // let mut skillIndex = rand8(iSeed, self.skillSpan.len());
        // loop {
        //     if(!self.cooldowns.isOnCooldown(skillIndex)) {
        //         break;
        //     }
        //     skillIndex = rand8(iSeed, self.skillSpan.len());
        //     iSeed += 1;
        // };
        // return skillIndex.into();
        return 0;
    }
    fn takeDamage(ref self: Entity, damage: u64) {
        PrintTrait::print('takeDamage');
        damage.print();
        self.statistics.health -= i64Impl::new(damage, false);
    }
    fn takeHeal(ref self: Entity, heal: u64) {
        self.statistics.health += i64Impl::new(heal, false);
    }
    fn incrementTurnbar(ref self: Entity) {
        self.turnBar.incrementTurnbar();
    }
    fn updateTurnBarSpeed(ref self: Entity) {
        self.turnBar.setSpeed(self.getSpeed());
    }
    fn processEndTurnProcs(ref self: Entity) {
        if(self.isStunned()) {
            self.stunOnTurnProc.proc();
        }
        self.statistics.reduceBuffsStatusDuration();
    }
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8) {
        self.statistics.applyStatModifier(buffType, value, duration);
    }
    fn applyPoison(ref self: Entity, value: u64, duration: u8) {
        // battle.healthOnTurnProcs.append(HealthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Damage));
    }
    fn applyRegen(ref self: Entity, value: u64, duration: u8) {
        // battle.healthOnTurnProcs.append(HealthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Heal));
    }
    fn applyStun(ref self: Entity, duration: u8) {
        self.stunOnTurnProc.setStunned(duration);
    }
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8) {
        self.cooldowns.setCooldown(skillIndex, duration);
    }
    fn isStunned(ref self: Entity) -> bool {
        self.stunOnTurnProc.isStunned()
    }
    fn isDead(ref self: Entity) -> bool {
        if (self.statistics.getHealth().min(i64Impl::new(1, false)) == self.statistics.getHealth()) {
            return true;
        }
        return false;
    }
    fn getIndex(self: @Entity) -> u32 {
        *self.index
    }
    fn getTurnBar(self: @Entity) -> @TurnBar::TurnBar {
        self.turnBar
    }
    fn getAttack(self: @Entity) -> u64 {
        self.statistics.getAttack()
    }
    fn getDefense(self: @Entity) -> u64 {
        self.statistics.getDefense()
    }
    fn getSpeed(self: @Entity) -> u64 {
        self.statistics.getSpeed()
    }
    fn getCriticalChance(self: @Entity) -> u64 {
        self.statistics.getCriticalChance()
    }
    fn getCriticalDamage(self: @Entity) -> u64 {
        self.statistics.getCriticalDamage()
    }
    fn getHealth(self: @Entity) -> i64 {
        self.statistics.getHealth()
    }
    fn getMaxHealth(self: @Entity) -> u64 {
        self.statistics.getMaxHealth()
    }

    fn print(self: @Entity) {
        (*self.name).print();
        (*self.index).print();
        self.statistics.print();
        self.printSkill();
    }
    fn printSkill(self: @Entity) {
        // let mut i: u32 = 0;
        // loop {
        //     if(i > (*self.skillSpan).len() - 1) {
        //         break;
        //     }
        //     let skill = (*self.skillSpan)[i];
        //     skill.print();
        //     i = i + 1;
        // };
    }
}