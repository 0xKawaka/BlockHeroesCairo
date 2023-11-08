use game::Components::Battle::Entity::{Entity, AllyOrEnemy};
use game::Components::Hero::Hero;

#[starknet::interface]
trait IEntityFactory<TContractState> {
    fn newEntities(ref self: TContractState, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity>;
    fn newEntity(ref self: TContractState, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity;
}

#[starknet::contract]
mod EntityFactory {
    use starknet::ContractAddress;
    use game::Libraries::List::{List, ListTrait};
    use game::Components::Hero::{Hero};
    use game::Components::Battle::{Entity, Entity::EntityImpl, Entity::EntityTrait, Entity::AllyOrEnemy, Entity::Cooldowns::CooldownsTrait, Entity::SkillSet};
    use game::Components::Battle::Entity::{Skill, Skill::SkillImpl, Skill::TargetType, Skill::Damage, Skill::Heal};
    use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::Components::{BaseStatistics, BaseStatistics::BaseStatisticsImpl};

    use debug::PrintTrait;


    #[storage]
    struct Storage {
        baseStatistics: LegacyMap<felt252, BaseStatistics::BaseStatistics>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initBaseStatisticsDict();
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

            return Entity::new(
                index,
                hero.name,
                health,
                attack,
                defense,
                speed,
                criticalRate,
                criticalDamage,
                allyOrEnemy,
            );
        }
    }

    #[generate_trait]
    impl InternalEntityFactoryImpl of InternalEntityFactoryTrait {
        fn initBaseStatisticsDict(ref self: ContractState) {
            self.baseStatistics.write('assassin', BaseStatistics::new(1300, 200, 100, 200, 10, 100));
            self.baseStatistics.write('knight', BaseStatistics::new(2000, 100, 200, 150, 10, 100));
            self.baseStatistics.write('priest', BaseStatistics::new(1500, 200, 100, 160, 10, 100));
            self.baseStatistics.write('hunter', BaseStatistics::new(1400, 100, 100, 170, 10, 200));
        }
    }
}