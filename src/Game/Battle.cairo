mod Entity;

use super::Hero::Hero;
use super::EntityFactory;
use super::EntityFactoryImpl;
use Entity::EntityImpl;
use Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};


use game::Game::Battle::Entity::TurnBar::{TurnBarTrait, TurnBarImpl};
use core::array::ArrayTrait;
use game::Game::Battle::Entity::EntityTrait;
use core::box::BoxTrait;
use core::option::OptionTrait;
use super::libraries::NullableVector::{NullableVector, NullableVectorImpl, VecTrait};
use super::libraries::Vector::{Vector, VectorImpl};
use super::libraries::ArrayHelper;
use debug::PrintTrait;

#[derive(Destruct)]
struct Battle {
    entities: NullableVector<Entity::Entity>, // Never remove entities
    deadEntities: Array<u32>,
    turnTimeline: Vector<u32>, // Entities indexes
    alliesIndexes: Array<u32>,
    enemiesIndexes: Array<u32>,
    healthOnTurnProcs: NullableVector<HealthOnTurnProc>,
    isBattleOver: bool,
    waitForPlayerAction: bool,
}

fn new(
    allies: @Array<Hero>, enemies: @Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory
) -> Battle {
    let mut battle = Battle {
        entities: VecTrait::<NullableVector, Entity::Entity>::new(),
        deadEntities: ArrayTrait::new(),
        turnTimeline: VecTrait::<Vector, u32>::new(),
        alliesIndexes: ArrayTrait::new(),
        enemiesIndexes: ArrayTrait::new(),
        healthOnTurnProcs: VecTrait::<NullableVector, HealthOnTurnProc>::new(),
        isBattleOver: false,
        waitForPlayerAction: false,
    };
    battle.initAllies(allies, ref battleHeroFactory);
    battle.initEnemies(enemies, allies.len(), ref battleHeroFactory);
    return battle;
}

trait BattleTrait {
    fn battleLoop(ref self: Battle);
    fn processHealthOnTurnProcs(ref self: Battle, ref entity: Entity::Entity);
    fn loopUntilNextTurn(ref self: Battle);
    fn updateTurnBarsSpeed(ref self: Battle);
    fn incrementTurnBars(ref self: Battle);
    fn sortTurnTimeline(ref self: Battle);
    fn getEntityHighestTurn(ref self: Battle) -> Entity::Entity;
    fn initAllies(
        ref self: Battle, heroes: @Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory
    );
    fn initEnemies(
        ref self: Battle,
        heroes: @Array<Hero>,
        startIndexEntity: u32,
        ref battleHeroFactory: EntityFactory::EntityFactory
    );
    fn isAlly(ref self: Battle, entityIndex: u32) -> bool;
    fn getAlliesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity>;
    fn getAllAllies(ref self: Battle) -> Array<Entity::Entity>;
    fn getAllEnemies(ref self: Battle) -> Array<Entity::Entity>;
    fn printAllEntities(ref self: Battle);
    fn printTurnTimeline(ref self: Battle);
    // fn printAllies(self: @Battle);
    // fn printEnemies(self: @Battle);
    fn print(ref self: Battle);
}

impl BattleImpl of BattleTrait {
    fn battleLoop(ref self: Battle) {
        loop {
            if (self.isBattleOver) {
                break;
            }
            self.loopUntilNextTurn();
            let mut entity = self.getEntityHighestTurn();
            let entityIndex = entity.getIndex();
            self.processHealthOnTurnProcs(ref entity);
            entity.playTurn(ref self);

            // if (self.isAlly(entityIndex)) {
            //     entity.playTurn(ref self);
            //     // self.waitForPlayerAction = true;
            //     break;
            // } else {

            // }
            let bugFix: bool = true;
        };
    }
    fn processHealthOnTurnProcs(ref self: Battle, ref entity: Entity::Entity) {
        if(self.healthOnTurnProcs.len() == 0) {
            return;
        }
        let mut i: u32 = 0;
        loop {
            if (i > self.healthOnTurnProcs.len() - 1) {
                break;
            }
            let mut onTurnProc = self.healthOnTurnProcs.getValue(i);
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
        self.entities.set(entity.getIndex(), entity);
    }
    fn loopUntilNextTurn(ref self: Battle) {
        self.updateTurnBarsSpeed();
        self.sortTurnTimeline();
        loop {
            if ((*self.getEntityHighestTurn().getTurnBar()).isFull()) {
                break;
            }
            self.incrementTurnBars();
            self.sortTurnTimeline();
        };
    // self.printTurnTimeline();
    }
    fn updateTurnBarsSpeed(ref self: Battle) {
        let mut i: u32 = 0;
        loop {
            if (i > self.entities.len() - 1) {
                break;
            }
            let mut entity = self.entities.getValue(i);
            entity.updateTurnBarSpeed();
            self.entities.set(i, entity);
            i = i + 1;
        };
    }
    fn incrementTurnBars(ref self: Battle) {
        let mut i: u32 = 0;
        loop {
            if (i > self.entities.len() - 1) {
                break;
            }
            let mut entity = self.entities.getValue(i);
            entity.incrementTurnbar();
            self.entities.set(i, entity);
            i = i + 1;
        };
    }
    fn sortTurnTimeline(ref self: Battle) {
        if self.turnTimeline.len() <= 1 {
            return;
        }
        let mut idx1 = 0;
        let mut idx2 = 1;
        let mut sortedIteration = 0;
        let mut sortedArray: Array<u32> = Default::default();

        loop {
            if idx2 == self.turnTimeline.len() {
                sortedArray.append(self.turnTimeline.getValue(idx1));
                // ArrayHelper::print(@sortedArray);
                if sortedIteration == 0 {
                    break;
                }
                self.turnTimeline = VecTrait::<Vector, u32>::newFromArray(sortedArray);
                sortedArray = array![];
                idx1 = 0;
                idx2 = 1;
                sortedIteration = 0;
            } else {
                let entityIndex1 = self.turnTimeline.getValue(idx1);
                let entityIndex2 = self.turnTimeline.getValue(idx2);
                let entity1TurnBar = *self.entities.getValue(entityIndex1).getTurnBar().turnbar;
                let entity2TurnBar = *self.entities.getValue(entityIndex2).getTurnBar().turnbar;
                if entity2TurnBar > entity1TurnBar {
                    sortedArray.append(self.turnTimeline.getValue(idx2));
                    // ArrayHelper::print(@sortedArray);
                    idx2 += 1;
                    sortedIteration = 1;
                } else {
                    sortedArray.append(self.turnTimeline.getValue(idx1));
                    // ArrayHelper::print(@sortedArray);
                    idx1 = idx2;
                    idx2 += 1;
                }
            };
        };
        // ArrayHelper::print(@sortedArray);
        self.turnTimeline = VecTrait::<Vector, u32>::newFromArray(sortedArray);
    // self.printTurnTimeline();
    }
    fn getEntityHighestTurn(ref self: Battle) -> Entity::Entity {
        let entityIndex = self.turnTimeline.getValue(0);
        let entity = self.entities.getValue(entityIndex);
        return entity;
    }
    fn initAllies(
        ref self: Battle, heroes: @Array<Hero>, ref battleHeroFactory: EntityFactory::EntityFactory
    ) {
        let mut i: u32 = 0;
        let mut heroesSpan = heroes.span();
        let heroesSpanLen = heroesSpan.len();
        loop {
            if (i > heroesSpanLen - 1) {
                break;
            }
            let heroOption = heroesSpan.pop_front();
            let hero = *heroOption.unwrap();
            self.entities.push(battleHeroFactory.newHero(i, hero));
            self.alliesIndexes.append(i);
            self.turnTimeline.push(i);
            i = i + 1;
        };
    }
    fn initEnemies(
        ref self: Battle,
        heroes: @Array<Hero>,
        startIndexEntity: u32,
        ref battleHeroFactory: EntityFactory::EntityFactory
    ) {
        let mut i: u32 = 0;
        let mut heroesSpan = heroes.span();
        let heroesSpanLen = heroesSpan.len();
        loop {
            if (i > heroesSpanLen - 1) {
                break;
            }
            let heroOption = heroesSpan.pop_front();
            let hero = *heroOption.unwrap();
            self.entities.push(battleHeroFactory.newHero(i, hero));
            self.enemiesIndexes.append(i + startIndexEntity);
            self.turnTimeline.push(i + startIndexEntity);
            i = i + 1;
        };
    }
    fn isAlly(ref self: Battle, entityIndex: u32) -> bool {
        return ArrayHelper::includes(@self.alliesIndexes, @entityIndex);
    }
    fn getAlliesOf(ref self: Battle, entityIndex: u32) -> Array<Entity::Entity> {
        if (self.isAlly(entityIndex)) {
            return self.getAllAllies();
        }
        return self.getAllEnemies();
    }
    fn getAllAllies(ref self: Battle) -> Array<Entity::Entity> {
        let mut allies: Array<Entity::Entity> = ArrayTrait::new();
        let mut i: u32 = 0;
        let mut alliesIndexesSpan = self.alliesIndexes.span();
        let alliesIndexesSpanLen = alliesIndexesSpan.len();
        loop {
            if (i > alliesIndexesSpanLen - 1) {
                break;
            }
            let allyIndexOption = alliesIndexesSpan.pop_front();
            let allyIndex = *allyIndexOption.unwrap();
            allies.append(self.entities.getValue(allyIndex));
            i = i + 1;
        };
        return allies;
    }
    fn getAllEnemies(ref self: Battle) -> Array<Entity::Entity> {
        let mut enemies: Array<Entity::Entity> = ArrayTrait::new();
        let mut i: u32 = 0;
        let mut enemiesIndexesSpan = self.enemiesIndexes.span();
        let enemiesIndexesSpanLen = enemiesIndexesSpan.len();
        loop {
            if (i > enemiesIndexesSpanLen - 1) {
                break;
            }
            let enemyIndexOption = enemiesIndexesSpan.pop_front();
            let enemyIndex = *enemyIndexOption.unwrap();
            enemies.append(self.entities.getValue(enemyIndex));
            i = i + 1;
        };
        return enemies;
    }
    fn printTurnTimeline(ref self: Battle) {
        let mut i: u32 = 0;
        loop {
            if (i > self.turnTimeline.len() - 1) {
                break;
            }
            let entityIndex = self.turnTimeline.getValue(i);
            entityIndex.print();
            let entity = self.entities.getValue(entityIndex);
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
        loop {
            if (i > self.entities.len() - 1) {
                break;
            }
            let battleHero = self.entities.getValue(i);
            battleHero.print();
            i = i + 1;
        };
    }
// fn printAllies(self: @Battle) {
//     let mut i: u32 = 0;
//     let mut allyEntitiesSpan = self.entities.span();
//     let  allyEntitiesSpanLen = allyEntitiesSpan.len();
//     loop {
//         if(i > allyEntitiesSpanLen - 1) {
//             break;
//         }
//         let battleHeroOption = allyEntitiesSpan.pop_front();
//         let battleHero = *battleHeroOption.unwrap();
//         battleHero.print();
//         i = i + 1;
//     };
// }
// fn printEnemies(self: @Battle) {
//     let mut i: u32 = 0;
//     let mut enemyEntitiesSpan = self.enemyEntities.span();
//     let  enemyEntitiesSpanLen = enemyEntitiesSpan.len();
//     loop {
//         if(i > enemyEntitiesSpanLen - 1) {
//             break;
//         }
//         let battleHeroOption = enemyEntitiesSpan.pop_front();
//         let battleHero = *battleHeroOption.unwrap();
//         battleHero.print();
//         i = i + 1;
//     };
// }
}

