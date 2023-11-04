use game::Libraries::List::ListTrait;
mod Entity;

use game::Components::Hero::Hero;
use game::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};
use game::Components::Battle::Entity::TurnBar::{TurnBarTrait, TurnBarImpl};
use game::Components::Battle::Entity::{EntityImpl, EntityTrait, AllyOrEnemy, Cooldowns::CooldownsTrait};
use game::Libraries::NullableVector::{NullableVector, NullableVectorImpl, VecTrait};
use game::Libraries::ArrayHelper;
use game::Libraries::SignedIntegers::{i64::i64Impl};
use game::Libraries::List::{List, ListImpl};
use debug::PrintTrait;
use starknet::ContractAddress;

#[derive(starknet::Store, Drop, Destruct)]
struct Battle {
    entities: List<Entity::Entity>,
    aliveEntities: List<u32>,
    deadEntities: List<u32>,
    turnTimeline: List<u32>,
    alliesIndexes: List<u32>,
    enemiesIndexes: List<u32>,
    healthOnTurnProcs: List<HealthOnTurnProc>,
    isBattleOver: bool,
    isWaitingForPlayerAction: bool,
}

trait BattleTrait {
    fn new(ref self: Battle, owner: ContractAddress, allies: Array<Entity::Entity>, enemies: Array<Entity::Entity>);
    fn battleLoop(ref self: Battle);
    fn playerAction(ref self: Battle, spellIndex: u8, targetIndex: u32);
    fn processHealthOnTurnProcs(ref self: Battle, ref entity: Entity::Entity);
    fn loopUntilNextTurn(ref self: Battle);
    fn updateTurnBarsSpeed(ref self: Battle);
    fn incrementTurnBars(ref self: Battle);
    fn sortTurnTimeline(ref self: Battle);
    fn getEntityHighestTurn(ref self: Battle) -> Entity::Entity;
    fn waitForPlayerAction(ref self: Battle);
    fn checkBattleOver(ref self: Battle) -> bool;
    fn isAlly(ref self: Battle, entityIndex: u32) -> bool;
    fn getAlliesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity>;
    fn getEnemiesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity>;
    fn getAllAllies(ref self: Battle) -> Array<Entity::Entity>;
    fn getAllEnemies(ref self: Battle) -> Array<Entity::Entity>;
    fn getEntityByIndex(ref self: Battle, entityIndex: u32) -> Entity::Entity;
    fn printAllEntities(ref self: Battle);
    fn printTurnTimeline(ref self: Battle);
    fn print(ref self: Battle);
    fn cleanLists(ref self: Battle);
}

impl BattleImpl of BattleTrait {
    fn new(ref self: Battle, owner: ContractAddress, allies: Array<Entity::Entity>, enemies: Array<Entity::Entity>) {
        self.isBattleOver = false;
        self.isWaitingForPlayerAction = false;
        self.cleanLists();

        let alliesSpan = allies.span();
        let enemiesSpan = enemies.span();

        let mut i: u32 = 0;
        loop {
            if( i == alliesSpan.len() ) {
                break;
            }
            let ally = *alliesSpan[i];
            self.entities.append(ally);
            // self.aliveEntities.append(ally.getIndex());
            // self.turnTimeline.append(ally.getIndex());
            // self.alliesIndexes.append(ally.getIndex());
            i += 1;
        };

        let mut i: u32 = 0;
        loop {
            if( i == enemiesSpan.len() ) {
                break;
            }
            let enemy = *enemiesSpan[i];
            // self.entities.append(enemy);
            self.aliveEntities.append(enemy.getIndex());
            // self.turnTimeline.append(enemy.getIndex());
            // self.enemiesIndexes.append(enemy.getIndex());
            i += 1;
        };
        self.entities[0].print();
        self.battleLoop();
    }
    fn battleLoop(ref self: Battle) {
        let mut i: u32 = 0;
        self.loopUntilNextTurn();
        // loop {
        //     if (self.isBattleOver || self.isWaitingForPlayerAction) {
        //         break;
        //     }
        //     self.loopUntilNextTurn();
        //     let mut entity = self.getEntityHighestTurn();
        //     self.processHealthOnTurnProcs(ref entity);
        //     entity.playTurn(ref self);
        //     i += 1;
        // };
    }
    fn playerAction(ref self: Battle, spellIndex: u8, targetIndex: u32) {
        assert(!self.isBattleOver, 'Battle is over');
        assert(self.isWaitingForPlayerAction, 'Not waiting for player action');
        assert(!self.isAlly(targetIndex), 'Target is not an enemy');
        let mut target = self.getEntityByIndex(targetIndex);
        assert(!target.isDead(), 'Target is dead');
        let mut entity = self.getEntityHighestTurn();
        assert(!entity.cooldowns.isOnCooldown(spellIndex), 'Spell is on cooldown');
        entity.playTurnPlayer(spellIndex, ref target, ref self);
        let mut target = self.getEntityByIndex(targetIndex);
        // PrintTrait::print('Target health after:');
        // target.getHealth().print();
        // target.isStunned().print();
        self.isWaitingForPlayerAction = false;
        self.battleLoop();
    }
    fn processHealthOnTurnProcs(ref self: Battle, ref entity: Entity::Entity) {
        if(self.healthOnTurnProcs.len() == 0) {
            return;
        }
        let mut i: u32 = 0;
        loop {
            if (i >= self.healthOnTurnProcs.len()) {
                break;
            }
            let mut onTurnProc = self.healthOnTurnProcs.get(i).unwrap();
            if (onTurnProc.getEntityIndex() == entity.getIndex()) {
                onTurnProc.proc(ref entity);
                if(onTurnProc.isExpired()) {
                    self.healthOnTurnProcs.remove(i);
                    i = i - 1;
                }
                else {
                    self.healthOnTurnProcs.set(i, onTurnProc);
                }
            }
            i = i + 1;
        };
        // self.entities.set(entity.getIndex(), entity);
    }
    fn loopUntilNextTurn(ref self: Battle) {
        // self.entities.get(0).unwrap().print();
        self.updateTurnBarsSpeed();
        self.sortTurnTimeline();
        // loop {
        //     if ((*self.getEntityHighestTurn().getTurnBar()).isFull()) {
        //         break;
        //     }
        //     self.incrementTurnBars();
        //     self.sortTurnTimeline();
        // };
    }
    fn updateTurnBarsSpeed(ref self: Battle) {
        let mut i: u32 = 0;
        let aliveEntitiesArray = self.aliveEntities.array();
        loop {
            if (i == aliveEntitiesArray.len()) {
                break;
            }
            let entityIndex = *aliveEntitiesArray[i];
            let mut entity = self.entities.get(entityIndex).unwrap();
            entity.updateTurnBarSpeed();
            self.entities.set(entityIndex, entity);
            i = i + 1;
        };
    }
    fn incrementTurnBars(ref self: Battle) {
        let mut i: u32 = 0;
        let aliveEntitiesArray = self.aliveEntities.array();
        loop {
            if (i  == aliveEntitiesArray.len()) {
                break;
            }
            let entityIndex = *aliveEntitiesArray[i];
            let mut entity = self.entities.get(entityIndex).unwrap();
            entity.incrementTurnbar();
            self.entities.set(entityIndex, entity);
            i = i + 1;
        };
    }
    fn sortTurnTimeline(ref self: Battle) {
        let mut turnTimeLineArray = self.turnTimeline.array();
        let entitiesArray = self.entities.array();
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
        self.turnTimeline.from_array(@sortedArray);
    }
    fn getEntityHighestTurn(ref self: Battle) -> Entity::Entity {
        let entityIndex = self.turnTimeline.get(0).unwrap();
        let entity = self.entities.get(entityIndex).unwrap();
        return entity;
    }
    fn waitForPlayerAction(ref self: Battle) {
        PrintTrait::print('Waiting for player action');
        self.isWaitingForPlayerAction = true;
    }
    fn checkBattleOver(ref self: Battle) -> bool {
        let mut i: u32 = 0;
        let mut alliesDeadCount: u32 = 0;
        let mut enemiesDeadCount: u32 = 0;
        loop {
            if (i >= self.deadEntities.len()) {
                break;
            }
            let entityIndex = self.deadEntities.get(i).unwrap();
            if (self.isAlly(entityIndex)) {
                alliesDeadCount = alliesDeadCount + 1;
            } else {
                enemiesDeadCount = enemiesDeadCount + 1;
            }
            i = i + 1;
        };
        if (alliesDeadCount == self.alliesIndexes.len()) {
            self.isBattleOver = true;
            return true;
        }
        if (enemiesDeadCount == self.enemiesIndexes.len()) {
            self.isBattleOver = true;
            return true;
        }
        return false;
    }
    fn isAlly(ref self: Battle, entityIndex: u32) -> bool {
        return ArrayHelper::includes(@self.alliesIndexes.array(), @entityIndex);
    }
    fn getAlliesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity> {
        if (self.isAlly(entityIndex)) {
            return self.getAllAllies();
        }
        return self.getAllEnemies();
    }
    fn getEnemiesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity> {
        if (self.isAlly(entityIndex)) {
            return self.getAllEnemies();
        }
        return self.getAllAllies();
    }
    fn getAllAllies(ref self: Battle) -> Array<Entity::Entity> {
        let mut allies: Array<Entity::Entity> = ArrayTrait::new();
        let mut i: u32 = 0;
        let mut alliesIndexesArray = self.alliesIndexes.array();
        let entitiesArray = self.entities.array();
        loop {
            if (i == alliesIndexesArray.len()) {
                break;
            }
            let allyIndex = *alliesIndexesArray[i];
            let mut entity = *entitiesArray[allyIndex];
            if(!entity.isDead()) {
                allies.append(entity);
            }
            i = i + 1;
        };
        return allies;
    }
    fn getAllEnemies(ref self: Battle) -> Array<Entity::Entity> {
        let mut enemies: Array<Entity::Entity> = ArrayTrait::new();
        let mut i: u32 = 0;
        let mut enemiesIndexesArray = self.enemiesIndexes.array();
        let entitiesArray = self.entities.array();
        loop {
            if (i == enemiesIndexesArray.len()) {
                break;
            }
            let enemyIndex = *enemiesIndexesArray[i];
            let mut entity = *entitiesArray[enemyIndex];
            if(!entity.isDead()) {
                enemies.append(entity);
            }
            i = i + 1;
        };
        return enemies;
    }
    fn getEntityByIndex(ref self: Battle, entityIndex: u32) -> Entity::Entity {
        return self.entities.get(entityIndex).unwrap();
    }
    fn printTurnTimeline(ref self: Battle) {
        let mut i: u32 = 0;
        let turnTimelineArray = self.turnTimeline.array(); 
        let entitiesArray = self.entities.array();
        loop {
            if (i >= turnTimelineArray.len()) {
                break;
            }
            let entityIndex = *turnTimelineArray[i];
            entityIndex.print();
            let entity = entitiesArray[entityIndex];
            (*entity.getTurnBar().turnbar).print();
            entity.getSpeed().print();
            i = i + 1;
        };
    }
    fn print(ref self: Battle) {
        self.printAllEntities();
    //     self.printAllies();
    //     self.printEnemies();
    }
    fn printAllEntities(ref self: Battle) {
        let mut i: u32 = 0;
        let entitiesArray = self.entities.array();
        loop {
            if (i >= entitiesArray.len()) {
                break;
            }
            let battleHero = entitiesArray[i];
            battleHero.print();
            i = i + 1;
        };
    }
    fn cleanLists(ref self: Battle) {
        self.entities.clean();
        self.aliveEntities.clean();
        self.deadEntities.clean();
        self.turnTimeline.clean();
        self.alliesIndexes.clean();
        self.enemiesIndexes.clean();
        self.healthOnTurnProcs.clean();
    }
}

