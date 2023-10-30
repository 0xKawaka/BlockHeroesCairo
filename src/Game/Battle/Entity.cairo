mod Statistics;
mod TurnBar;
mod Skill;
mod HealthOnTurnProc;

use Statistics::StatisticsImpl;
use Skill::SkillImpl;
use super::Battle;
use super::super::libraries::NullableVector::{VecTrait, NullableVector};
use game::Game::Battle::Entity::TurnBar::TurnBarTrait;
use core::box::BoxTrait;

use super::super::libraries::SignedIntegers::{i64::i64, i64::i64Impl};

use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Entity {
    index: u32,
    name: felt252,
    turnBar: TurnBar::TurnBar,
    statistics: Statistics::Statistics,
    skillSpan: Span<Skill::Skill>,
    // HealthonTurnProcs: Array<HealthOnTurnProc::HealthOnTurnProc>,
    // skill: Skill::Skill,
}

// impl ArraySkillCopy of Copy<Array<Skill::Skill>> {
//     fn copy(self: @Array<Skill::Skill>) -> Array<Skill::Skill> {
//         *self
//     }
// }

fn new(index: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64,
skillSpan: Span<Skill::Skill>) -> Entity {
    Entity {
        index: index,
        name: name,
        statistics: Statistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: TurnBar::new(index, speed),
        skillSpan: skillSpan,
        // HealthonTurnProcs: Default::default(),
        // HealthonTurnProcs: VecTrait::<NullableVector, HealthOnTurnProc::HealthOnTurnProc>::new(),
    }
}

trait EntityTrait {
    fn playTurn(ref self: Entity, ref battle: Battle);
    // fn processHealthOnTurnProcs(ref self: Entity);
    fn takeDamage(ref self: Entity, damage: u64);
    fn takeHeal(ref self: Entity, heal: u64);
    fn incrementTurnbar(ref self: Entity);
    fn updateTurnBarSpeed(ref self: Entity);
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
        // self.processHealthOnTurnProcs();
    }
    // fn processHealthOnTurnProcs(ref self: Entity) {
        // let damages = []
        // let heals = []
        // for(let i = this.percentLifeHealthOnTurnProcArray.length - 1; i >= 0; i--) {
        // let damageOrHeal = this.percentLifeHealthOnTurnProcArray[i].proc(this, i)
        // if(damageOrHeal < 0) {
        //     damages.push(-damageOrHeal)
        // }
        // else if (damageOrHeal > 0) {
        //     heals.push(damageOrHeal)
        // }
        // }
        // this.stun.proc()
        // this.checkUnitHealth()
        // return {damages: damages, heals: heals}
    // }
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