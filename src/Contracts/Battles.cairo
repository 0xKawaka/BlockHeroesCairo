use starknet::ContractAddress;
use game::Components::Battle::Entity::Entity;

#[starknet::interface]
trait IBattles<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, allyEntites: Array<Entity>, enemyEntities: Array<Entity>);
    fn playTurn(ref self: TContractState, owner: ContractAddress, spellIndex: u8, targetIndex: u32);
    fn setISkillFactoryDispatch(ref self: TContractState, skillFactoryAdrs: ContractAddress);
    fn setIEventEmitterDispatch(ref self: TContractState, eventEmitterAdrs: ContractAddress);
}

#[starknet::contract]
mod Battles {
    use game::Components::Battle::BattleTrait;
use game::Components::Battle::Entity::Skill::SkillTrait;
    use core::box::BoxTrait;
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use core::debug::PrintTrait;
    use starknet::ContractAddress;

    use game::Libraries::List::{List, ListTrait};
    use game::Libraries::IVector::VecTrait;
    use game::Components::{Battle, Battle::BattleImpl};
    use game::Components::Battle::Entity::{Entity, EntityImpl, Skill::SkillImpl};
    use game::Components::Battle::Entity::{TurnBar::TurnBarImpl};
    use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
    use game::Contracts::SkillFactory::{ISkillFactoryDispatcher, ISkillFactoryDispatcherTrait};
    use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};

    #[storage]
    struct Storage {
        entities: LegacyMap<ContractAddress, List<Entity>>,
        aliveEntities: LegacyMap<ContractAddress, List<u32>>,
        deadEntities: LegacyMap<ContractAddress, List<u32>>,
        turnTimeline: LegacyMap<ContractAddress, List<u32>>,
        allies: LegacyMap<ContractAddress, List<u32>>,
        enemies: LegacyMap<ContractAddress, List<u32>>,
        healthOnTurnProcs: LegacyMap<(ContractAddress, u32), List<HealthOnTurnProc>>,
        isBattleOver: LegacyMap<ContractAddress, bool>,
        isWaitingForPlayerAction: LegacyMap<ContractAddress, bool>,

        ISkillFactoryDispatch: ISkillFactoryDispatcher,
        IEventEmitterDispatch: IEventEmitterDispatcher,
    }

    #[external(v0)]
    impl BattlesImpl of super::IBattles<ContractState> {
        fn newBattle(ref self: ContractState, owner: ContractAddress, allyEntites: Array<Entity>, enemyEntities: Array<Entity>) {
            let alliesSpan = allyEntites.span();
            let enemiesSpan = allyEntites.span();
            self.initBattleStorage(owner, allyEntites, enemyEntities);
            let IEventEmitterDispatch = self.IEventEmitterDispatch.read();
            // health, 
            let mut battle = self.getBattle(owner);
            let healthsArray = battle.getHealthsArray();
            IEventEmitterDispatch.newBattle(owner, healthsArray);
            battle.battleLoop(IEventEmitterDispatch);
            self.storeBattleState(ref battle, owner);
        }
        fn playTurn(ref self: ContractState, owner: ContractAddress, spellIndex: u8, targetIndex: u32) {
            let mut battle = self.getBattle(owner);
            battle.playTurn(spellIndex, targetIndex, self.IEventEmitterDispatch.read());
            self.storeBattleState(ref battle, owner);
        }
        fn setISkillFactoryDispatch(ref self: ContractState, skillFactoryAdrs: ContractAddress) {
            self.ISkillFactoryDispatch.write(ISkillFactoryDispatcher { contract_address: skillFactoryAdrs });
        }
        fn setIEventEmitterDispatch(ref self: ContractState, eventEmitterAdrs: ContractAddress) {
            self.IEventEmitterDispatch.write(IEventEmitterDispatcher { contract_address: eventEmitterAdrs });
        }
    }

    #[generate_trait]
    impl InternalEntityFactoryImpl of InternalEntityFactoryTrait {
        fn initBattleStorage(ref self: ContractState, owner: ContractAddress, allyEntites: Array<Entity>, enemyEntities: Array<Entity>) {
            self.isBattleOver.write(owner, false);
            self.isWaitingForPlayerAction.write(owner, false);
            self.cleanLists(owner, allyEntites.len() + enemyEntities.len());

            let mut entities = self.entities.read(owner);
            let mut aliveEntities = self.aliveEntities.read(owner);
            let mut deadEntities = self.deadEntities.read(owner);
            let mut turnTimeline = self.turnTimeline.read(owner);
            let mut allies = self.allies.read(owner);
            let mut enemies = self.enemies.read(owner);

            let mut i: u32 = 0;
            loop {
                if( i == allyEntites.len() ) {
                    break;
                }
                let ally = *allyEntites[i];
                entities.append(ally);
                aliveEntities.append(ally.getIndex());
                turnTimeline.append(ally.getIndex());
                allies.append(ally.getIndex());
                i += 1;
            };

            let mut i: u32 = 0;
            loop {
                if( i == enemyEntities.len() ) {
                    break;
                }
                let enemy = *enemyEntities[i];
                entities.append(enemy);
                aliveEntities.append(enemy.getIndex());
                turnTimeline.append(enemy.getIndex());
                enemies.append(enemy.getIndex());
                i += 1;
            };
        }
        fn storeBattleState(ref self: ContractState, ref battle: Battle::Battle, owner: ContractAddress) {
            self.isWaitingForPlayerAction.write(owner, battle.isWaitingForPlayerAction);
            self.isBattleOver.write(owner, battle.isBattleOver);
            let mut entities = self.entities.read(owner);
            entities.from_array(@battle.entities.toArray());
            let mut aliveEntities = self.aliveEntities.read(owner);
            aliveEntities.from_array(@battle.aliveEntities.toArray());
            let mut deadEntities = self.deadEntities.read(owner);
            deadEntities.from_array(@battle.deadEntities);
            let mut turnTimeline = self.turnTimeline.read(owner);
            turnTimeline.from_array(@battle.turnTimeline.toArray());
            let mut allies = self.allies.read(owner);
            allies.from_array(@battle.alliesIndexes);
            let mut enemies = self.enemies.read(owner);
            enemies.from_array(@battle.enemiesIndexes);
            let mut i: u32 = 0;
            loop {
                if( i == battle.entities.len() ) {
                    break;
                }
                let mut healthOnTurnProcs = self.healthOnTurnProcs.read((owner, i));
                healthOnTurnProcs.from_array(@battle.getHealthOnTurnProcsEntity(i));
                i += 1;
            };
        }
        fn getBattle(ref self: ContractState, owner: ContractAddress) -> Battle::Battle {
            let entities = self.entities.read(owner).array();
            let aliveEntities = self.aliveEntities.read(owner).array();
            let deadEntities = self.deadEntities.read(owner).array();
            let turnTimeline = self.turnTimeline.read(owner).array();
            let allies = self.allies.read(owner).array();
            let enemies = self.enemies.read(owner).array();
            let healthOnTurnProcs = self.getHealthOnTurnProcs(owner);
            let mut entitiesNames: Array<felt252> = Default::default();
            let entitiesSpan = entities.span();
            let mut i: u32 = 0;
            loop {
                if( i == entitiesSpan.len() ) {
                    break;
                }
                let entity = *entitiesSpan[i];
                entitiesNames.append(entity.name);
                i += 1;
            };
            let skillSets = self.ISkillFactoryDispatch.read().getSkillSets(entitiesNames);

            let battle = Battle::new(entities, aliveEntities, deadEntities, turnTimeline, allies, enemies, healthOnTurnProcs, skillSets, self.isBattleOver.read(owner), self.isWaitingForPlayerAction.read(owner), owner);
            return battle;
        }
        fn getHealthOnTurnProcs(ref self: ContractState, owner: ContractAddress) -> Array<HealthOnTurnProc> {
            let mut healthOnTurnProcs: Array<HealthOnTurnProc> = Default::default();
            let mut i: u32 = 0;
            let entitiesCount = self.entities.read(owner).len();
            loop {
                if( i == entitiesCount ) {
                    break;
                }
                let healthOnTurnProcEntity = self.healthOnTurnProcs.read((owner, i)).array();
                let mut j: u32 = 0;
                loop {
                    if( j == healthOnTurnProcEntity.len() ) {
                        break;
                    }
                    healthOnTurnProcs.append(*healthOnTurnProcEntity[j]);
                    j += 1;
                };
                i += 1;
            };
            return healthOnTurnProcs;
        }
        fn cleanLists(ref self: ContractState, owner: ContractAddress, entitiesCount: u32) {
            let mut entities = self.entities.read(owner);
            entities.clean();
            let mut alivesEntities = self.aliveEntities.read(owner);
            alivesEntities.clean();
            let mut deadEntities = self.deadEntities.read(owner);
            deadEntities.clean();
            let mut turnTimeline = self.turnTimeline.read(owner);
            turnTimeline.clean();
            let mut allies = self.allies.read(owner);
            allies.clean();
            let mut enemies = self.enemies.read(owner);
            enemies.clean();
            let mut i: u32 = 0;
            loop {
                if( i == entitiesCount ) {
                    break;
                }
                let mut healthOnTurnProcs = self.healthOnTurnProcs.read((owner, i));
                healthOnTurnProcs.clean();
                i += 1;
            };
        }
    }
}