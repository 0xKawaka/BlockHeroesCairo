use game::Libraries::SignedIntegers::IntegerTrait::IntegerTrait;
use core::box::BoxTrait;

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

use game::Components::Battle::Entity::Statistics::Statistic::StatisticTrait;
use game::Components::Battle::Entity::{StunOnTurnProc::StunOnTurnProcTrait, Statistics::StatisticsTrait};
use game::Components::Battle::BattleTrait;
use game::Components::Battle::Entity::Statistics::{StatisticsImpl, Statistic::StatModifier::StatModifier, Statistic::Statistic};
use game::Components::Battle::Entity::TurnBar::TurnBarTrait;
use game::Components::Battle::{Battle, BattleImpl};
use game::Libraries::NullableVector::{VecTrait, NullableVector};
use game::Libraries::SignedIntegers::{i64::i64, i64::i64Impl};
use game::Libraries::Random::{rand8};
use game::Libraries::List::{List, ListTrait};
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait, EventEmitter::BuffEvent, EventEmitter::EntityBuffEvent, SkillEventParams};
use debug::PrintTrait;
use starknet::get_block_timestamp;


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
    cooldowns: Cooldowns::Cooldowns,
    stunOnTurnProc: StunOnTurnProc::StunOnTurnProc,
    allyOrEnemy: AllyOrEnemy,
}

fn new(index: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64, allyOrEnemy: AllyOrEnemy) -> Entity {
    Entity {
        index: index,
        name: name,
        statistics: Statistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: TurnBar::new(index, speed),
        cooldowns: Cooldowns::new(),
        stunOnTurnProc: StunOnTurnProc::new(0),
        allyOrEnemy: allyOrEnemy,
    }
}

trait EntityTrait {
    fn playTurn(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn playTurnPlayer(ref self: Entity, skillIndex: u8, targetIndex: u32, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn endTurn(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn die(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn pickSkill(ref self: Entity) -> u8;
    fn takeDamage(ref self: Entity, damage: u64);
    fn takeHeal(ref self: Entity, heal: u64);
    fn takeHealAllowOverheal(ref self: Entity, heal: u64);
    fn setMaxHealthIfHealthIsGreater(ref self: Entity);
    fn incrementTurnbar(ref self: Entity);
    fn updateTurnBarSpeed(ref self: Entity);
    fn processEndTurnProcs(ref self: Entity, ref battle: Battle);
    fn applyStatModifier(ref self: Entity, buffType: BuffType, value: u64, duration: u8);
    fn applyPoison(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyRegen(ref self: Entity, ref battle: Battle, value: u64, duration: u8);
    fn applyStun(ref self: Entity, duration: u8);
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8);
    // fn randCrit(ref self: Entity) -> bool;
    fn isStunned(ref self: Entity) -> bool;
    fn isDead(ref self: Entity) -> bool;
    fn getEventBuffsArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatisticsBuffsArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatusArray(self: Entity) -> Array<EntityBuffEvent>;
    fn getEventStatisticsStatusArray(self: Entity) -> Array<EntityBuffEvent>;
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
}

impl EntityImpl of EntityTrait {
    fn playTurn(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        if(self.isDead()) {
            self.die(ref battle, IEventEmitterDispatch);
            return;
        }
        self.setMaxHealthIfHealthIsGreater();
        PrintTrait::print('health:');
        self.getHealth().print();

        self.cooldowns.reduceCooldowns();
        if(self.isStunned()){
            PrintTrait::print('stunned');
            self.endTurn(ref battle, IEventEmitterDispatch);
            return;
        }
        else {
            match self.allyOrEnemy {
                AllyOrEnemy::Ally => {
                    battle.waitForPlayerAction();
                    // self.name.print();
                    // self.index.print();
                    battle.entities.set(self.getIndex(), self);
                },
                AllyOrEnemy::Enemy => {
                    let skillIndex = self.pickSkill();
                    let skillSet = battle.skillSets.get(self.index).unwrap().unbox();
                    let skill = *skillSet.get(skillIndex.into()).unwrap().unbox();
                    let skillEventParams = skill.cast(skillIndex, ref self, ref battle);
                    IEventEmitterDispatch.skill(battle.owner, skillEventParams.casterId, skillEventParams.targetId, skillIndex, skillEventParams.damages, skillEventParams.heals, battle.checkAndProcessDeadEntities(IEventEmitterDispatch));
                    self.endTurn(ref battle, IEventEmitterDispatch);
                },
            }
        }
    }
    fn playTurnPlayer(ref self: Entity, skillIndex: u8, targetIndex: u32, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        let mut target = battle.getEntityByIndex(targetIndex);
        assert(!target.isDead(), 'Target is dead');
        assert(!self.cooldowns.isOnCooldown(skillIndex), 'Skill is on cooldown');
        let skillSet = battle.skillSets.get(self.index).unwrap().unbox();
        let skill = *skillSet.get(skillIndex.into()).unwrap().unbox();
        let skillEventParams = skill.castOnTarget(skillIndex, ref self, ref target, ref battle);
        IEventEmitterDispatch.skill(battle.owner, skillEventParams.casterId, skillEventParams.targetId, skillIndex, skillEventParams.damages, skillEventParams.heals, battle.checkAndProcessDeadEntities(IEventEmitterDispatch));
        self.endTurn(ref battle, IEventEmitterDispatch);
    }
    fn endTurn(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        // self.setMaxHealthIfHealthIsGreater();
        self.processEndTurnProcs(ref battle);
        self.turnBar.resetTurn();
        battle.entities.set(self.getIndex(), self);
        IEventEmitterDispatch.endTurn(battle.owner, battle.getEventBuffsArray(), battle.getEventStatusArray(), battle.getEventSpeedsArray());
    }
    fn die(ref self: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        PrintTrait::print('death');
        PrintTrait::print(self.index);        
        battle.deadEntities.append(self.getIndex());

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveEntities.len()) {
                break;
            }
            let entityIndex = battle.aliveEntities.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveEntities.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.turnTimeline.len()) {
                break;
            }
            let entityIndex = battle.turnTimeline.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.turnTimeline.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveAlliesIndexes.len()) {
                break;
            }
            let entityIndex = battle.aliveAlliesIndexes.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveAlliesIndexes.remove(i);
                break;
            }
            i = i + 1;
        };

        let mut i: u32 = 0;
        loop {
            if(i >= battle.aliveEnemiesIndexes.len()) {
                break;
            }
            let entityIndex = battle.aliveEnemiesIndexes.get(i).unwrap();
            if (entityIndex == self.getIndex()) {
                battle.aliveEnemiesIndexes.remove(i);
                break;
            }
            i = i + 1;
        };
    }
    fn pickSkill(ref self: Entity) -> u8 {
        let mut seed = get_block_timestamp();
        if(self.cooldowns.isOnCooldown(1) && self.cooldowns.isOnCooldown(2)) {
            return 0;
        }
        let mut skillIndex = rand8(seed, 3);
        loop {
            if(!self.cooldowns.isOnCooldown(skillIndex)) {
                break;
            }
            skillIndex = rand8(seed, 3);
            seed += 1;
        };
        return skillIndex;
    }
    fn takeDamage(ref self: Entity, damage: u64) {
        self.statistics.health -= i64Impl::new(damage, false);
    }
    fn takeHeal(ref self: Entity, heal: u64) {
        self.statistics.health += i64Impl::new(heal, false);
        self.setMaxHealthIfHealthIsGreater();
    }
    fn takeHealAllowOverheal(ref self: Entity, heal: u64) {
        self.statistics.health += i64Impl::new(heal, false);
    }
    fn setMaxHealthIfHealthIsGreater(ref self: Entity) {
        if(!self.getHealth().sign && self.getHealth().mag > self.getMaxHealth()) {
            self.statistics.health = i64Impl::new(self.getMaxHealth(), false);
        }
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
    fn setOnCooldown(ref self: Entity, skillIndex: u8, duration: u8) {
        self.cooldowns.setCooldown(skillIndex, duration);
    }
    fn isStunned(ref self: Entity) -> bool {
        self.stunOnTurnProc.isStunned()
    }
    fn isDead(ref self: Entity) -> bool {
        if (self.statistics.getHealth().min(i64Impl::new(0, false)) == self.statistics.getHealth()) {
            return true;
        }
        return false;
    }
    fn getEventBuffsArray(self: Entity) -> Array<EntityBuffEvent> {
        return self.getEventStatisticsBuffsArray();
    }
    fn getEventStatisticsBuffsArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut buffsArray: Array<EntityBuffEvent> = Default::default();
        if(self.statistics.attack.getBonusValue() > 0 && self.statistics.attack.bonus.duration > 0) {
            buffsArray.append(EntityBuffEvent { name: 'attack', duration: self.statistics.attack.bonus.duration });
        }
        if(self.statistics.defense.getBonusValue() > 0 && self.statistics.defense.bonus.duration > 0) {
            buffsArray.append(EntityBuffEvent { name: 'defense', duration: self.statistics.defense.bonus.duration });
        }
        if(self.statistics.speed.getBonusValue() > 0 && self.statistics.speed.bonus.duration > 0) {
            buffsArray.append(EntityBuffEvent { name: 'speed', duration: self.statistics.speed.bonus.duration });
        }
        return buffsArray;
    }
    fn getEventStatusArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut statusArray: Array<EntityBuffEvent> = self.getEventStatisticsStatusArray();
        if(self.stunOnTurnProc.isStunned()){
            statusArray.append(EntityBuffEvent { name: 'stun', duration: self.stunOnTurnProc.duration })
        }
        return statusArray;
    }
    fn getEventStatisticsStatusArray(self: Entity) -> Array<EntityBuffEvent> {
        let mut statusArray: Array<EntityBuffEvent> = Default::default();
        if(self.statistics.attack.getMalusValue() > 0 && self.statistics.attack.malus.duration > 0) {
            statusArray.append(EntityBuffEvent { name: 'attack', duration: self.statistics.attack.malus.duration });
        }
        if(self.statistics.defense.getMalusValue() > 0 && self.statistics.defense.malus.duration > 0) {
            statusArray.append(EntityBuffEvent { name: 'defense', duration: self.statistics.defense.malus.duration });
        }
        if(self.statistics.speed.getMalusValue() > 0 && self.statistics.speed.malus.duration > 0) {
            statusArray.append(EntityBuffEvent { name: 'speed', duration: self.statistics.speed.malus.duration });
        }
        return statusArray;
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
    }
}