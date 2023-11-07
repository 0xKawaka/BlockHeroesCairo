use game::Components::Battle::Entity::Skill::Buff::{BuffImpl};
use game::Components::Battle::Entity::Skill::Damage::{Damage, DamageImpl};
use game::Components::Battle::Entity::Skill::Heal::{Heal,HealImpl};
use game::Components::Battle::Entity::Skill::TargetType;
use game::Components::Battle::Entity::{Entity, EntityTrait};
use game::Components::Battle::{Battle, BattleImpl};
use game::Libraries::Random::rand32;
use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct SkillWithoutBuffs {
    name: felt252,
    cooldown: u8,
    damage: Damage,
    heal: Heal,
    targetType: TargetType,
    accuracy: u16,
}

fn new(
    name: felt252,
    cooldown: u8,
    damage: Damage,
    heal: Heal,
    targetType: TargetType,
    accuracy: u16,
) -> SkillWithoutBuffs {
    SkillWithoutBuffs {
        name: name,
        cooldown: cooldown,
        damage: damage,
        heal: heal,
        targetType: targetType,
        accuracy: accuracy,
    }
}
