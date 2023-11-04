mod SkillNameSet;

use super::super::Components::Battle::Entity::{Entity, AllyOrEnemy};
use super::super::Components::Hero::Hero;

#[starknet::interface]
trait IEntityFactory<TContractState> {
    fn newEntities(ref self: TContractState, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity>;
    fn newEntity(ref self: TContractState, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity;
}

#[starknet::contract]
mod EntityFactory {
    use starknet::ContractAddress;
    use super::super::super::Components::Battle::{Battle, BattleImpl};
    use super::super::super::Libraries::List::{List, ListTrait};
    use super::super::super::Components::Hero::{Hero};
    use super::super::super::Components::Battle::{Entity, Entity::EntityImpl, Entity::EntityTrait, Entity::AllyOrEnemy, Entity::Cooldowns::CooldownsTrait, Entity::SkillSet};
    use super::super::super::Components::Battle::Entity::{Skill, Skill::SkillImpl, Skill::TargetType, Skill::Damage, Skill::Heal};
    use super::super::super::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use super::super::super::Components::EntityFactory::{BaseStatistics, BaseStatistics::BaseStatisticsImpl};
    use super::SkillNameSet;

    use debug::PrintTrait;


    #[storage]
    struct Storage {
        baseStatistics: LegacyMap<felt252, BaseStatistics::BaseStatistics>,
        skills: LegacyMap<felt252, Skill::Skill>,
        skillNameSets: LegacyMap<felt252, SkillNameSet::SkillNameSet>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initBaseStatisticsDict();
        self.initHeroSkillNameSet();
        self.initSkills();
    }

    #[external(v0)]
    impl EntityFactoryImpl of super::IEntityFactory<ContractState> {
        fn newEntities(ref self: ContractState, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity::Entity> {
            let mut entities: Array<Entity::Entity> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == heroes.len() {
                    break;
                }
                let entity = self.newEntity(startIndex + i, *heroes[i], allyOrEnemy);
                entities.append(entity);
                i += 1;
            };
            return entities;
        }
        fn newEntity(ref self: ContractState, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity::Entity {
            let baseStats = self.baseStatistics.read(hero.name);
            let (health, attack, defense, speed, criticalRate, criticalDamage) = baseStats
                .getAllStatistics(hero.level, hero.rank);

            let skillNameSet = self.skillNameSets.read(hero.name);
            let skill0 = self.skills.read(skillNameSet.skill0);
            let skill1 = self.skills.read(skillNameSet.skill1);
            let skill2 = self.skills.read(skillNameSet.skill2);

            return Entity::new(
                index,
                hero.name,
                health,
                attack,
                defense,
                speed,
                criticalRate,
                criticalDamage,
                SkillSet::new(skill0, skill1, skill2),
                allyOrEnemy,
            );
        }
    }

    #[generate_trait]
    impl InternalEntityFactoryImpl of InternalEntityFactoryTrait {
        fn initBaseStatisticsDict(ref self: ContractState) {
            self.baseStatistics.write('knight', BaseStatistics::new(1000, 100, 100, 100, 20, 100));
            self.baseStatistics.write('priest', BaseStatistics::new(2000, 200, 200, 102, 20, 150));
            self.baseStatistics.write('hunter', BaseStatistics::new(3000, 300, 300, 103, 20, 300));
        }
        fn initHeroSkillNameSet(ref self: ContractState) {
            self.skillNameSets.write('knight', SkillNameSet::new('AttackKnight', 'Fire Swing', 'Fire Strike'));
            self.skillNameSets.write('priest', SkillNameSet::new('AttackPriest', 'Water Heal', 'Water Shield'));
            self.skillNameSets.write('hunter', SkillNameSet::new('AttackHunter', 'Forest Senses', 'Arrows Rain'));
        }
        fn initSkills(ref self: ContractState) {
            self.skills.write('AttackKnight', Skill::new('AttackKnight', 'AttackKnight', 1, Damage::new(10, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('Fire Swing', Skill::new('Fire Swing', 'Fire Swing', 1, Damage::new(20, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('Fire Strike', Skill::new('Fire Strike', 'Fire Strike', 1, Damage::new(20, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('AttackPriest', Skill::new('AttackPriest', 'AttackPriest', 1, Damage::new(10, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('Water Heal', Skill::new('Water Heal', 'Water Heal', 3, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(10, false, true, false, Heal::HealType::Percent), TargetType::Ally, 1, array![].span()));
            self.skills.write('Water Shield', Skill::new('Water Shield', 'Water Shield', 2, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Ally, 1, array![].span()));
            self.skills.write('AttackHunter', Skill::new('AttackHunter', 'AttackHunter', 1, Damage::new(10, true, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('Arrows Rain', Skill::new('Arrows Rain', 'Arrows Rain', 1, Damage::new(0, false, true, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Enemy, 1, array![].span()));
            self.skills.write('Forest Senses', Skill::new('Forest Senses', 'Forest Senses', 1, Damage::new(0, false, false, false, Damage::DamageType::Flat), Skill::Heal::new(0, false, false, false, Heal::HealType::Percent), TargetType::Ally, 1, array![].span()));
        }
    }
}