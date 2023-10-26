use game::Game::Battle::Entity::Skill::SkillTrait;
use core::array::ArrayTrait;
use core::traits::Destruct;
mod BaseStatistics;
use BaseStatistics::BaseStatisticsImpl;

use super::Battle::Entity;
use super::Hero::Hero;
use super::Battle::Entity::Skill;

use nullable::{match_nullable, FromNullableResult};
use debug::PrintTrait;

#[derive(Destruct)]
struct EntityFactory {
    baseStatisticsDict: Felt252Dict<Nullable<BaseStatistics::BaseStatistics>>,
    skillsDict: Felt252Dict<Nullable<Skill::Skill>>,
    heroSkillset: Felt252Dict<Nullable<Span<felt252>>>,
}

fn new(baseStatisticsDict: Felt252Dict<Nullable<BaseStatistics::BaseStatistics>>, skillsDict: Felt252Dict<Nullable<Skill::Skill>>, heroSkillset: Felt252Dict<Nullable<Span<felt252>>>) -> EntityFactory {
    EntityFactory {
        baseStatisticsDict: baseStatisticsDict,
        skillsDict: skillsDict,
        heroSkillset: heroSkillset,
    }
}

trait EntityFactoryTrait {
    fn newHero(ref self: EntityFactory, index: u32, hero: Hero) -> Entity::Entity;
}

impl EntityFactoryImpl of EntityFactoryTrait {
    fn newHero(ref self: EntityFactory, index: u32, hero: Hero) -> Entity::Entity {
        let baseStatsBox = self.baseStatisticsDict.get(hero.name);
        let baseStats = match match_nullable(baseStatsBox) {
            FromNullableResult::Null(()) => panic_with_felt252('No baseStats found newHero'),
            FromNullableResult::NotNull(val) => val.unbox(),
        };
        let (health, attack, defense, speed, criticalRate, criticalDamage) = baseStats.getAllStatistics(hero.level, hero.rank);

        let skillSetNull = self.heroSkillset.get(hero.name);
        let mut skillSet = match match_nullable(skillSetNull) {
            FromNullableResult::Null(()) => panic_with_felt252('No skillSet found newHero'),
            FromNullableResult::NotNull(val) => val.unbox(),
        };
        let mut i: u32 = 0;
        let mut skills: Array<Skill::Skill> = Default::default();
        let skillSetLen = skillSet.len();
        loop {
            if(i > skillSetLen - 1) {
                break;
            }
            let skillNameOption = skillSet.pop_front();
            let skillName = *skillNameOption.unwrap();

            let skillNull = self.skillsDict.get(skillName);
            let skill = match match_nullable(skillNull) {
                FromNullableResult::Null(()) => panic_with_felt252('No skill found newHero'),
                FromNullableResult::NotNull(val) => val.unbox(),
            };
            skills.append(skill);
            i = i + 1;
        };

        return Entity::new(index, hero.name, health, attack, defense, speed, criticalRate, criticalDamage, skills.span());
    }
}

