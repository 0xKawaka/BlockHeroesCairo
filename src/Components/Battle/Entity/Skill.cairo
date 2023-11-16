use game::Components::Battle::BattleTrait;
mod Damage;
mod Heal;
mod Buff;
use game::Components::Battle::Entity::Skill::Buff::{BuffImpl};
use game::Components::Battle::Entity::Skill::Damage::{DamageImpl};
use game::Components::Battle::Entity::Skill::Heal::{HealImpl};
use game::Components::Battle::Entity::{Entity, EntityTrait};
use game::Components::Battle::{Battle, BattleImpl};
use game::Libraries::Random::rand32;
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait, IdAndValueEvent};
use starknet::get_block_timestamp;

use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, PartialEq, Serde)]
enum TargetType {
    Ally,
    Enemy,
}

#[derive(Copy, Drop, Serde)]
struct Skill {
    name: felt252,
    cooldown: u8,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: TargetType,
    buffs: Span<Buff::Buff>
}

fn new(
    name: felt252,
    cooldown: u8,
    damage: Damage::Damage,
    heal: Heal::Heal,
    targetType: TargetType,
    buffs: Span<Buff::Buff>
) -> Skill {
    Skill {
        name: name,
        cooldown: cooldown,
        damage: damage,
        heal: heal,
        targetType: targetType,
        buffs: buffs
    }
}

trait SkillTrait {
    fn cast(self: Skill, skillIndex: u8, ref caster: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn castOnTarget(self: Skill, skillIndex: u8, ref caster: Entity, ref target: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher);
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle);
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent>;
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent>;
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity;
    fn print(self: @Skill);
}

impl SkillImpl of SkillTrait {
    fn cast(self: Skill, skillIndex: u8, ref caster: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        let mut target = self.pickTarget(caster, ref battle);
        self.castOnTarget(skillIndex, ref caster, ref target, ref battle, IEventEmitterDispatch);
    }
    fn castOnTarget(self: Skill, skillIndex: u8, ref caster: Entity, ref target: Entity, ref battle: Battle, IEventEmitterDispatch: IEventEmitterDispatcher) {
        match self.targetType {
            TargetType::Ally => {
                assert(battle.isAllyOf(caster.getIndex(),  target.getIndex()), 'Target should be ally');
            },
            TargetType::Enemy => {
                assert(!battle.isAllyOf(caster.getIndex(),  target.getIndex()), 'Target should be enemy');
            },
        }
        PrintTrait::print('caster:');
        PrintTrait::print(caster.name);
        PrintTrait::print(caster.getIndex());
        PrintTrait::print(self.name);
        PrintTrait::print('target:');
        PrintTrait::print(target.getIndex());
        let damages = self.applyDamage(ref caster, ref target, ref battle);
        let heals = self.applyHeal(ref caster, ref target, ref battle);
        self.applyBuffs(ref caster, ref target, ref battle);
        caster.setOnCooldown(self.cooldown, skillIndex);
        IEventEmitterDispatch.skill(battle.owner, caster.getIndex(), target.getIndex(), skillIndex, damages, heals, battle.getEventBuffsArray(), battle.getEventStatusArray(), battle.getEventSpeedsArray(), battle.checkAndProcessDeadEntities());
    }
    fn applyBuffs(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) {
        let  mut i: u32 = 0;
        loop {
            if (i >= self.buffs.len()) {
                break;
            }
            let buff = *self.buffs[i];
            buff.apply(ref caster, ref target, ref battle);
            i += 1;
        }
    }
    fn applyDamage(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent> {
        return self.damage.apply(ref caster, ref target, ref battle);
        // TODO : ADD CRIT LATER
    }
    fn applyHeal(self: Skill, ref caster: Entity, ref target: Entity, ref battle: Battle) -> Array<IdAndValueEvent> {
        return self.heal.apply(ref caster, ref target, ref battle);
    }
    fn pickTarget(self: Skill, caster: Entity, ref battle: Battle) -> Entity {
        let mut seed = get_block_timestamp();
        if self.targetType == TargetType::Ally {
            let allies = battle.getAlliesOf(caster.getIndex());
            let randIndex = rand32(seed, allies.len());
            let entity = *allies.get(randIndex).unwrap().unbox();
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
