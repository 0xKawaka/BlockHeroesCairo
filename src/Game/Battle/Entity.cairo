use game::Game::Battle::BattleTrait;
use game::Game::Battle::Entity::StunOnTurnProc::StunOnTurnProcTrait;
use game::Game::Battle::Entity::Statistics::StatisticsTrait;
mod Statistics;
mod TurnBar;
mod Skill;
mod HealthOnTurnProc;
mod StunOnTurnProc;

use Statistics::{StatisticsImpl, Statistic::StatModifier::StatModifier};
use HealthOnTurnProc::{DamageOrHealEnum};
use Skill::{SkillImpl, Buff::BuffType};
use StunOnTurnProc::{StunOnTurnProcImpl};
use super::{Battle, BattleImpl};
use super::super::libraries::NullableVector::{VecTrait, NullableVector};
use game::Game::Battle::Entity::TurnBar::TurnBarTrait;
use core::box::BoxTrait;

use super::super::libraries::SignedIntegers::{i64::i64, i64::i64Impl};
use super::super::libraries::Random::rand32;

use debug::PrintTrait;

#[derive(Copy, Drop)]
enum AllyOrEnemy {
    Ally,
    Enemy,
}

#[derive(Copy, Drop)]
struct Entity {
    index: u32,
    name: felt252,
    turnBar: TurnBar::TurnBar,
    statistics: Statistics::Statistics,
    skillSpan: Span<Skill::Skill>,
    stunOnTurnProc: StunOnTurnProc::StunOnTurnProc,
    allyOrEnemy: AllyOrEnemy,
}

fn new(index: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64,
skillSpan: Span<Skill::Skill>, allyOrEnemy: AllyOrEnemy) -> Entity {
    Entity {
        index: index,
        name: name,
        statistics: Statistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: TurnBar::new(index, speed),
        skillSpan: skillSpan,
        stunOnTurnProc: StunOnTurnProc::new(0),
        allyOrEnemy: allyOrEnemy,
    }
}

trait EntityTrait {
    fn playTurn(ref self: Entity, ref battle: Battle);
    fn playTurnPlayer(ref self: Entity, spellIndex: u32, targetIndex: u32, ref battle: Battle);
    fn endTurn(ref self: Entity, ref battle: Battle);
    fn pickSkill(ref self: Entity) -> Skill::Skill;
    fn takeDamage(ref self: Entity, damage: u64);
    fn takeHeal(ref self: Entity, heal: u64);
    fn incrementTurnbar(ref self: Entity);
    fn updateTurnBarSpeed(ref self: Entity);
    fn processEndTurnProcs(ref self: Entity, ref battle: Battle);
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8);
    fn applyPoison(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyRegen(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyStun(ref self: Entity, duration: u8);
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
    fn playTurn(ref self: Entity, ref battle: Battle) {
        if(self.isStunned()){
            return;
        }
        else {
            match self.allyOrEnemy {
                AllyOrEnemy::Ally => {
                    battle.waitForPlayerAction();
                },
                AllyOrEnemy::Enemy => {
                    let skill = self.pickSkill();
                    skill.cast(ref self, ref battle);
                    self.endTurn(ref battle);
                },
            }
        }
    }
    fn playTurnPlayer(ref self: Entity, spellIndex: u32, targetIndex: u32, ref battle: Battle) {
        let skill = *self.skillSpan[spellIndex];
        let mut target =  battle.getEntityByIndex(targetIndex);
        skill.castOnTarget(ref self, ref target, ref battle);
        self.endTurn(ref battle);
    }
    fn endTurn(ref self: Entity, ref battle: Battle) {
        self.processEndTurnProcs(ref battle);
        self.turnBar.resetTurn();
        battle.entities.set(self.getIndex(), self);
    }
    fn pickSkill(ref self: Entity) -> Skill::Skill {
        let mut seed: u32 = 3;
        let skillIndex = rand32(seed, self.skillSpan.len());
        return *self.skillSpan[skillIndex];
    }
    fn takeDamage(ref self: Entity, damage: u64) {
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
    fn processEndTurnProcs(ref self: Entity, ref battle: Battle) {
        if(self.isStunned()) {
            self.stunOnTurnProc.proc();
        }
        self.statistics.reduceBuffsStatusDuration();
    }
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8) {
        self.statistics.applyStatModifier(buffType, value, duration);
    }
    fn applyPoison(ref self: Entity, ref battle: Battle, value: u64, duration: u8) {
        battle.healthOnTurnProcs.push(HealthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Damage));
    }
    fn applyRegen(ref self: Entity, ref battle: Battle, value: u64, duration: u8) {
        battle.healthOnTurnProcs.push(HealthOnTurnProc::new(self.getIndex(), value, duration, DamageOrHealEnum::Heal));
    }
    fn applyStun(ref self: Entity, duration: u8) {
        self.stunOnTurnProc.setStunned(duration);
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
        let mut i: u32 = 0;
        loop {
            if(i > (*self.skillSpan).len() - 1) {
                break;
            }
            let skill = (*self.skillSpan)[i];
            skill.print();
            i = i + 1;
        };
    }
}