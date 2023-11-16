mod SkillWithoutBuffs;
mod SkillNameSet;
use game::Components::Battle::Entity::Skill::Skill;

#[starknet::interface]
trait ISkillFactory<TContractState> {
    fn newSkill(self: @TContractState, name: felt252) -> Skill;
    fn getSkillSets(self: @TContractState, names: Array<felt252>) -> Array<Array<Skill>>;
}

#[starknet::contract]
    mod SkillFactory {
    use game::Components::Battle::Entity::Skill::SkillTrait;
use core::array::ArrayTrait;
    use starknet::ContractAddress;
    use game::Libraries::List::{List, ListTrait};
    use game::Components::Hero::{Hero};
    use game::Components::Battle::{Entity, Entity::EntityImpl, Entity::EntityTrait, Entity::AllyOrEnemy, Entity::Cooldowns::CooldownsTrait, Entity::SkillSet};
    use game::Components::Battle::Entity::{Skill, Skill::SkillImpl, Skill::TargetType, Skill::Damage, Skill::Heal, Skill::Buff, Skill::Buff::BuffType};
    use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::Components::{BaseStatistics, BaseStatistics::BaseStatisticsImpl};
    use super::SkillWithoutBuffs;
    use super::SkillNameSet;
    use debug::PrintTrait;

    #[storage]
    struct Storage {
        skills: LegacyMap<felt252, SkillWithoutBuffs::SkillWithoutBuffs>,
        skillsBuffs: LegacyMap<felt252, List<Buff::Buff>>,
        skillNameSets: LegacyMap<felt252, SkillNameSet::SkillNameSet>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initSkills();
        self.initSkillsBuffs();
        self.initHeroSkillNameSet();
    }

    #[external(v0)]
    impl SkillFactoryImpl of super::ISkillFactory<ContractState> {
        fn newSkill(self: @ContractState, name: felt252) -> Skill::Skill {
            let skillWithoutBuffs = self.skills.read(name);
            let skillsBuffs = self.skillsBuffs.read(name).array().span();
            let skill = Skill::new(skillWithoutBuffs.name, skillWithoutBuffs.cooldown, skillWithoutBuffs.damage, skillWithoutBuffs.heal, skillWithoutBuffs.targetType, skillsBuffs);
            return skill;
        }
        fn getSkillSets(self: @ContractState, names: Array<felt252>) -> Array<Array<Skill::Skill>> {
            let mut skills: Array<Array<Skill::Skill>> = Default::default();
            let mut i: u32 = 0;
            loop {
                if(i == names.len()) {
                    break;
                }
                let entityName = *names[i];
                let skillNameSet = self.skillNameSets.read(entityName);
                let mut skillSet: Array<Skill::Skill> = Default::default();
                skillSet.append(self.newSkill(skillNameSet.skill0));
                skillSet.append(self.newSkill(skillNameSet.skill1));
                skillSet.append(self.newSkill(skillNameSet.skill2));
                skills.append(skillSet);
                i += 1;
            };
            return skills;
        }   
    }

    #[generate_trait]
    impl InternalSkillFactoryImpl of InternalSkillFactoryTrait {
        fn initSkills(ref self: ContractState) {
            self.skills.write('Attack Knight', SkillWithoutBuffs::new('Attack Knight', 0, Damage::new(100, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Fire Swing', SkillWithoutBuffs::new('Fire Swing', 2, Damage::new(200, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Fire Strike', SkillWithoutBuffs::new('Fire Strike', 3, Damage::new(200, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Attack Priest', SkillWithoutBuffs::new('Attack Priest', 0, Damage::new(100, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Water Heal', SkillWithoutBuffs::new('Water Heal', 3, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(10, false, true, false, Heal::HealType::Percent), TargetType::Ally, 1));
            self.skills.write('Water Shield', SkillWithoutBuffs::new('Water Shield', 3, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Ally, 1));
            self.skills.write('Attack Hunter', SkillWithoutBuffs::new('Attack Hunter', 0, Damage::new(100, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Arrows Rain', SkillWithoutBuffs::new('Arrows Rain', 3, Damage::new(0, false, true, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Forest Senses', SkillWithoutBuffs::new('Forest Senses', 3, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Ally, 1));
            self.skills.write('Attack Assassin', SkillWithoutBuffs::new('Attack Assassin', 0, Damage::new(100, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Sand Strike', SkillWithoutBuffs::new('Sand Strike', 2, Damage::new(200, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
            self.skills.write('Sandstorm', SkillWithoutBuffs::new('Sandstorm', 3, Damage::new(100, false, true, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1));
        }
        fn initSkillsBuffs(ref self: ContractState) {
            let mut FireSwingBuffs = self.skillsBuffs.read('Fire Swing');
            FireSwingBuffs.append(Buff::new(BuffType::Stun, 0, 2, true, false, false));
            let mut FireStrikeBuffs = self.skillsBuffs.read('Fire Strike');
            FireStrikeBuffs.append(Buff::new(BuffType::Poison, 20, 2, true, false, false));
            let mut WaterHealBuffs = self.skillsBuffs.read('Water Heal');
            WaterHealBuffs.append(Buff::new(BuffType::Regen, 10, 2, false, true, false));
            let mut WaterShieldBuffs = self.skillsBuffs.read('Water Shield');
            WaterShieldBuffs.append(Buff::new(BuffType::DefenseUp, 100, 3, true, false, true));
            let mut ArrowsRainBuffs = self.skillsBuffs.read('Arrows Rain');
            ArrowsRainBuffs.append(Buff::new(BuffType::Poison, 15, 2, false, true, false));
            let mut ForestSensesBuffs = self.skillsBuffs.read('Forest Senses');
            ForestSensesBuffs.append(Buff::new(BuffType::AttackUp, 100, 2, false, false, true));
            ForestSensesBuffs.append(Buff::new(BuffType::SpeedUp, 100, 2, false, false, true));
            let mut SandStrikeBuffs = self.skillsBuffs.read('Sand Strike');
            SandStrikeBuffs.append(Buff::new(BuffType::AttackUp, 50, 2, false, false, true));
            let mut SandstormBuffs = self.skillsBuffs.read('Sandstorm');
            SandstormBuffs.append(Buff::new(BuffType::SpeedDown, 20, 2, false, true, false));
        }
        fn initHeroSkillNameSet(ref self: ContractState) {
            self.skillNameSets.write('knight', SkillNameSet::new('Attack Knight', 'Fire Swing', 'Fire Strike'));
            self.skillNameSets.write('priest', SkillNameSet::new('Attack Priest', 'Water Heal', 'Water Shield'));
            self.skillNameSets.write('hunter', SkillNameSet::new('Attack Hunter', 'Forest Senses', 'Arrows Rain'));
            self.skillNameSets.write('assassin', SkillNameSet::new('Attack Assassin', 'Sand Strike', 'Sandstorm'));
        }
    }
}