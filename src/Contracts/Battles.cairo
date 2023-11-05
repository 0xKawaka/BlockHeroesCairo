use starknet::ContractAddress;
use game::Components::Battle::Entity::Entity;

#[starknet::interface]
trait IBattles<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, allyEntites: Array<Entity>, enemyEntities: Array<Entity>);
    // fn playerAction(ref self: Contract, spellIndex: u8, targetIndex: u32);
}

#[starknet::contract]
mod Battles {

    use core::debug::PrintTrait;
    use starknet::ContractAddress;

    use game::Libraries::List::{List, ListTrait};
    use game::Libraries::ArrayHelper;
    use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy, Cooldowns::CooldownsTrait};
    use game::Components::Battle::Entity::{TurnBar::TurnBarImpl};
    use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};

    #[storage]
    struct Storage {
        // battles: LegacyMap<ContractAddress, Battle>
        entities: LegacyMap<ContractAddress, List<Entity>>,
        aliveEntities: LegacyMap<ContractAddress, List<u32>>,
        deadEntities: LegacyMap<ContractAddress, List<u32>>,
        turnTimeline: LegacyMap<ContractAddress, List<u32>>,
        allies: LegacyMap<ContractAddress, List<u32>>,
        enemies: LegacyMap<ContractAddress, List<u32>>,
        healthOnTurnProcs: LegacyMap<(ContractAddress, u32), List<HealthOnTurnProc>>,
        isBattleOver: LegacyMap<ContractAddress, bool>,
        isWaitingForPlayerAction: LegacyMap<ContractAddress, bool>,
    }


    #[external(v0)]
    impl BattlesImpl of super::IBattles<ContractState> {
        fn newBattle(ref self: ContractState, owner: ContractAddress, allyEntites: Array<Entity>, enemyEntities: Array<Entity>) {
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
            self.battleLoop(ref entities, ref aliveEntities, ref deadEntities, ref turnTimeline, ref allies, ref enemies, owner);
        }
    }

    #[generate_trait]
    impl InternalEntityFactoryImpl of InternalEntityFactoryTrait {
        fn battleLoop(ref self: ContractState, ref entities: List<Entity>, ref aliveEntities: List<u32>, ref deadEntities: List<u32>, ref turnTimeline: List<u32>, ref allies: List<u32>, ref enemies: List<u32>, owner: ContractAddress) {
            let mut i: u32 = 0;
            // let mut aliveEntitiesArray = aliveEntities.array();
            // let mut turnTimelineArray = turnTimeline.array();
            self.loopUntilNextTurn(ref entities, ref turnTimeline, aliveEntities);
            // loop {
            //     if (self.isBattleOver.read(owner) || self.isWaitingForPlayerAction.read(owner)) {
            //         break;
            //     }
            //     self.loopUntilNextTurn(ref entities, ref turnTimeline, aliveEntities);
            //     let mut entity = self.getEntityHighestTurn(entities, turnTimeline);
            //     self.processHealthOnTurnProcs(ref entity, ref entities, owner);
            //     // entity.playTurn(ref entities, ref aliveEntities, ref deadEntities, ref turnTimeline, ref allies, ref enemies, owner);
            //     i += 1;
            // };
        }
        fn processHealthOnTurnProcs(ref self: ContractState, ref entity: Entity, ref entities: List<Entity>, owner: ContractAddress) {
            let mut entityHealthOnTurnProcs = self.healthOnTurnProcs.read((owner, entity.getIndex()));
            if(entityHealthOnTurnProcs.len() == 0) {
                return;
            }
            let mut i: u32 = 0;
            loop {
                if (i >= entityHealthOnTurnProcs.len()) {
                    break;
                }
                let mut onTurnProc = entityHealthOnTurnProcs.get(i).unwrap();
                if (onTurnProc.getEntityIndex() == entity.getIndex()) {
                    onTurnProc.proc(ref entity);
                    if(onTurnProc.isExpired()) {
                        entityHealthOnTurnProcs.remove(i);
                        i = i - 1;
                    }
                    else {
                        entityHealthOnTurnProcs.set(i, onTurnProc);
                    }
                }
                i = i + 1;
            };
            entities.set(entity.getIndex(), entity);
        }
        fn loopUntilNextTurn(ref self: ContractState, ref entities: List<Entity>, ref turnTimeline: List<u32>, aliveEntities: List<u32>) {
            self.updateTurnBarsSpeed(ref entities, aliveEntities);
            self.sortTurnTimeline(entities, ref turnTimeline);
            loop {
                if ((*self.getEntityHighestTurn(entities, turnTimeline).getTurnBar()).isFull()) {
                    break;
                }
                PrintTrait::print('incrementTurnBars');
                self.incrementTurnBars(ref entities, aliveEntities);
                PrintTrait::print('sortTurnTimeline');
                self.sortTurnTimeline(entities, ref turnTimeline);
                // self.printTurnTimeline(turnTimeline, entities);
            };
            // self.printTurnTimeline(turnTimeline, entities);
        }
        fn updateTurnBarsSpeed(ref self: ContractState, ref entities: List<Entity>, aliveEntities: List<u32>) {
            let mut i: u32 = 0;
            let aliveEntitiesArray = aliveEntities.array();
            loop {
                if (i == aliveEntitiesArray.len()) {
                    break;
                }
                let entityIndex = *aliveEntitiesArray[i];
                let mut entity = entities[entityIndex];
                entity.updateTurnBarSpeed();
                entities.set(entityIndex, entity);
                i = i + 1;
            };
        }
        fn incrementTurnBars(ref self: ContractState, ref entities: List<Entity>, aliveEntities: List<u32>) {
            let mut i: u32 = 0;
            let aliveEntitiesArray = aliveEntities.array();
            loop {
                if (i  == aliveEntitiesArray.len()) {
                    break;
                }
                let entityIndex = *aliveEntitiesArray[i];
                entities.len().print();
                entityIndex.print();
                let mut entity = entities[i];
                entity.print();
                entity.incrementTurnbar();
                entities.set(entityIndex, entity);
                i = i + 1;
            };
        }
        fn sortTurnTimeline(ref self: ContractState, entities: List<Entity>, ref turnTimeline: List<u32>) {
            let mut turnTimeLineArray = turnTimeline.array();
            let entitiesArray = entities.array();
            if turnTimeLineArray.len() < 2 {
                return;
            }
            let mut idx1 = 0;
            let mut idx2 = 1;
            let mut sortedIteration = 0;
            let mut sortedArray: Array<u32> = Default::default();

            loop {
                if idx2 == turnTimeLineArray.len() {
                    sortedArray.append(*turnTimeLineArray[idx1]);
                    // ArrayHelper::print(@sortedArray);
                    if sortedIteration == 0 {
                        break;
                    }
                    turnTimeLineArray = sortedArray;
                    sortedArray = array![];
                    idx1 = 0;
                    idx2 = 1;
                    sortedIteration = 0;
                } else {
                    let entityIndex1 = *turnTimeLineArray[idx1];
                    let entityIndex2 = *turnTimeLineArray[idx2];
                    let entity1TurnBar = *entitiesArray[entityIndex1].getTurnBar().turnbar;
                    let entity2TurnBar = *entitiesArray[entityIndex2].getTurnBar().turnbar;
                    if entity2TurnBar > entity1TurnBar {
                        sortedArray.append(*turnTimeLineArray[idx2]);
                        idx2 += 1;
                        sortedIteration = 1;
                    } else {
                        sortedArray.append(*turnTimeLineArray[idx1]);
                        idx1 = idx2;
                        idx2 += 1;
                    }
                };
            };
            turnTimeline.from_array(@sortedArray);
        }
        fn getEntityHighestTurn(ref self: ContractState, entities: List<Entity>, turnTimeline: List<u32>) -> Entity {
            let entityIndex = turnTimeline[0];
            let entity = entities[entityIndex];
            return entity;
        }
        fn waitForPlayerAction(ref self: ContractState, owner: ContractAddress) {
            PrintTrait::print('Waiting for player action');
            self.isWaitingForPlayerAction.write(owner, true);
        }
        fn checkBattleOver(ref self: ContractState, deadEntities: List<u32>, allies: List<u32>, enemies: List<u32>, owner: ContractAddress) -> bool {
            let mut i: u32 = 0;
            let mut alliesDeadCount: u32 = 0;
            let mut enemiesDeadCount: u32 = 0;
            let alliesArray = allies.array();
            loop {
                if (i >= deadEntities.len()) {
                    break;
                }
                let entityIndex = deadEntities[i];
                if (self.isAlly(entityIndex, @alliesArray)) {
                    alliesDeadCount = alliesDeadCount + 1;
                } else {
                    enemiesDeadCount = enemiesDeadCount + 1;
                }
                i = i + 1;
            };
            if (alliesDeadCount == allies.len() || enemiesDeadCount == enemies.len()) {
                self.isBattleOver.write(owner, true);
                return true;
            }
            return false;
        }
        fn isAlly(ref self: ContractState, entityIndex: u32, alliesArray: @Array<u32>) -> bool {
            return ArrayHelper::includes(alliesArray, @entityIndex);
        }
        fn getAlliesOf(ref self: ContractState, entityIndex: u32, entities: List<Entity>, allies: List<u32>, enemies: List<u32>) -> Array<Entity> {
            if (self.isAlly(entityIndex, @allies.array())) {
                return self.getAllAllies(entities, allies);
            }
            return self.getAllEnemies(entities, enemies);
        }
        fn getEnemiesOf(ref self: ContractState, entityIndex: u32, entities: List<Entity>, allies: List<u32>, enemies: List<u32>) -> Array<Entity> {
            if (self.isAlly(entityIndex, @allies.array())) {
                return self.getAllEnemies(entities, enemies);
            }
            return self.getAllAllies(entities, allies);
        }
        fn getAllAllies(ref self: ContractState, entities: List<Entity>, allies: List<u32>) -> Array<Entity> {
            let mut allyEntities: Array<Entity> = ArrayTrait::new();
            let mut i: u32 = 0;
            // let mut alliesIndexesArray = self.alliesIndexes.array();
            // let entitiesArray = self.entities.array();
            loop {
                if (i == allies.len()) {
                    break;
                }
                let allyIndex = allies[i];
                let mut entity = entities[allyIndex];
                if(!entity.isDead()) {
                    allyEntities.append(entity);
                }
                i = i + 1;
            };
            return allyEntities;
        }
        fn getAllEnemies(ref self: ContractState, entities: List<Entity>, enemies: List<u32>) -> Array<Entity> {
            let mut enemyEntities: Array<Entity> = ArrayTrait::new();
            let mut i: u32 = 0;
            // let mut enemiesIndexesArray = self.enemiesIndexes.array();
            // let entitiesArray = self.entities.array();
            loop {
                if (i == enemies.len()) {
                    break;
                }
                let enemyIndex = enemies[i];
                let mut entity = entities[enemyIndex];
                if(!entity.isDead()) {
                    enemyEntities.append(entity);
                }
                i = i + 1;
            };
            return enemyEntities;
        }
        fn getEntityByIndex(ref self: ContractState, entityIndex: u32, entities: List<Entity>) -> Entity {
            return entities[entityIndex];
        }
        fn printTurnTimeline(ref self: ContractState, turnTimeline: List<u32>, entities: List<Entity>) {
            let mut i: u32 = 0;
            // let turnTimelineArray = self.turnTimeline.array(); 
            // let entitiesArray = self.entities.array();
            loop {
                if (i >= turnTimeline.len()) {
                    break;
                }
                let entityIndex = turnTimeline[i];
                entityIndex.print();
                let entity = entities[entityIndex];
                (*entity.getTurnBar().turnbar).print();
                entity.getSpeed().print();
                i = i + 1;
            };
        }
        fn printAllEntities(ref self: ContractState, entities: List<Entity>) {
            let mut i: u32 = 0;
            // let entitiesArray = self.entities.array();
            loop {
                if (i >= entities.len()) {
                    break;
                }
                let battleHero = entities[i];
                battleHero.print();
                i = i + 1;
            };
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