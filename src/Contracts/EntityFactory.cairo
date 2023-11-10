use game::Components::Battle::Entity::{Entity, AllyOrEnemy};
use game::Components::Hero::Hero;
use starknet::ContractAddress;

#[starknet::interface]
trait IEntityFactory<TContractState> {
    fn newEntities(ref self: TContractState, owner: ContractAddress, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity>;
    fn newEntity(ref self: TContractState, owner: ContractAddress, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity;
    fn setAccountsAdrs(ref self: TContractState, accountsAdrs: ContractAddress);
}

#[starknet::contract]
mod EntityFactory {
    use game::Components::Hero::HeroTrait;
use starknet::ContractAddress;
    use game::Libraries::List::{List, ListTrait};
    use game::Components::Hero::{Hero, Rune::Rune, Rune::RuneImpl};
    use game::Components::Battle::{Entity, Entity::EntityImpl, Entity::EntityTrait, Entity::AllyOrEnemy, Entity::Cooldowns::CooldownsTrait, Entity::SkillSet};
    use game::Components::Battle::Entity::{Skill, Skill::SkillImpl, Skill::TargetType, Skill::Damage, Skill::Heal};
    use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::Components::{BaseStatistics, BaseStatistics::BaseStatisticsImpl};
    use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};

    use debug::PrintTrait;


    #[storage]
    struct Storage {
        baseStatistics: LegacyMap<felt252, BaseStatistics::BaseStatistics>,
        accountsAdrs: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initBaseStatisticsDict();
    }

    #[external(v0)]
    impl EntityFactoryImpl of super::IEntityFactory<ContractState> {
        fn newEntities(ref self: ContractState, owner: ContractAddress, startIndex: u32, heroes: Array<Hero>, allyOrEnemy: AllyOrEnemy) -> Array<Entity::Entity> {
            let mut entities: Array<Entity::Entity> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == heroes.len() {
                    break;
                }
                let entity = self.newEntity(owner, startIndex + i, *heroes[i], allyOrEnemy);
                entities.append(entity);
                i += 1;
            };
            return entities;
        }
        fn newEntity(ref self: ContractState, owner: ContractAddress, index: u32, hero: Hero, allyOrEnemy: AllyOrEnemy) -> Entity::Entity {
            let baseStats = self.baseStatistics.read(hero.name);
            let baseStatsValues = baseStats.getAllStatistics(hero.level, hero.rank);
            let runesIndex = hero.getRunesIndexArray();
            let runes = IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.getRunes(owner, runesIndex);
            let bonusStatsValues = self.computeRunesBonuses(runes, baseStatsValues);

            return Entity::new(
                index,
                hero.name,
                baseStatsValues.health,
                baseStatsValues.attack,
                baseStatsValues.defense,
                baseStatsValues.speed,
                baseStatsValues.criticalRate,
                baseStatsValues.criticalDamage,
                allyOrEnemy,
            );
        }
        fn setAccountsAdrs(ref self: ContractState, accountsAdrs: ContractAddress) {
            self.accountsAdrs.write(accountsAdrs);
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
        fn computeRunesBonuses(ref self: ContractState, runes: Array<Rune>, baseStats: BaseStatistics::BaseStatistics) -> BaseStatistics::BaseStatistics {
            let mut totalBonusStats = BaseStatistics::new(0, 0, 0, 0, 0, 0);
            let mut i: u32 = 0;
            loop {
                if i == runes.len() {
                    break;
                }
                let rune = *runes[i];
                let bonusStatsRune = rune.computeBonuses(baseStats);
                totalBonusStats.health += bonusStatsRune.health;
                totalBonusStats.attack += bonusStatsRune.attack;
                totalBonusStats.defense += bonusStatsRune.defense;
                totalBonusStats.speed += bonusStatsRune.speed;
                totalBonusStats.criticalRate += bonusStatsRune.criticalRate;
                totalBonusStats.criticalDamage += bonusStatsRune.criticalDamage;
                i += 1;
            };
            return totalBonusStats;
        }
    }
}