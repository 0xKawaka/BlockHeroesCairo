use core::array::ArrayTrait;
use core::result::ResultTrait;
use core::option::OptionTrait;
use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use starknet::get_caller_address;

use game::Contracts::Game::IGameDispatcher;
use game::Contracts::Game::IGameDispatcherTrait;
use game::Contracts::Accounts::IAccountsDispatcher;
use game::Contracts::Accounts::IAccountsDispatcherTrait;
use game::Contracts::Battles::IBattlesDispatcher;
use game::Contracts::Battles::IBattlesDispatcherTrait;
use game::Contracts::EntityFactory::IEntityFactoryDispatcher;
use game::Contracts::EntityFactory::IEntityFactoryDispatcherTrait;
use game::Contracts::Levels::ILevelsDispatcher;
use game::Contracts::Levels::ILevelsDispatcherTrait;
use game::Contracts::SkillFactory::ISkillFactoryDispatcher;
use game::Contracts::SkillFactory::ISkillFactoryDispatcherTrait;
use game::Contracts::EventEmitter::IEventEmitterDispatcher;
use game::Contracts::EventEmitter::IEventEmitterDispatcherTrait;

use game::Contracts::Game::IGameSafeDispatcher;
use game::Contracts::Game::IGameSafeDispatcherTrait;
use game::Contracts::Accounts::IAccountsSafeDispatcher;
use game::Contracts::Accounts::IAccountsSafeDispatcherTrait;
use game::Contracts::Battles::IBattlesSafeDispatcher;
use game::Contracts::Battles::IBattlesSafeDispatcherTrait;
use game::Contracts::EntityFactory::IEntityFactorySafeDispatcher;
use game::Contracts::EntityFactory::IEntityFactorySafeDispatcherTrait;
use game::Contracts::Levels::ILevelsSafeDispatcher;
use game::Contracts::Levels::ILevelsSafeDispatcherTrait;
use game::Contracts::SkillFactory::ISkillFactorySafeDispatcher;
use game::Contracts::SkillFactory::ISkillFactorySafeDispatcherTrait;
use game::Contracts::EventEmitter::IEventEmitterSafeDispatcher;
use game::Contracts::EventEmitter::IEventEmitterSafeDispatcherTrait;

use game::Components::Hero::Rune::RuneTrait;
use game::Components::Hero::{Hero, HeroImpl, HeroTrait};
use game::Components::Battle::Entity::{Entity, AllyOrEnemy, EntityImpl};
use game::Components::Hero::Rune::{Rune, RuneImpl};
use game::Components::Hero::EquippedRunes::{EquippedRunes, EquippedRunesImpl};

use debug::PrintTrait;

fn deployContract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

// #[test]
fn addHeroes() {
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    accountsDispatcher.mintHeroAdmin(testAdrs, 'priest', 10, 1);
    accountsDispatcher.mintHeroAdmin(testAdrs, 'knight', 1, 2);
    let hero0 = accountsDispatcher.getHero(testAdrs, 0);
    let hero1 = accountsDispatcher.getHero(testAdrs, 1);
    assert(hero0.name == 'priest' && hero0.level == 10 &&  hero0.rank == 1, 'Invalid hero');
    assert(hero1.name == 'knight', 'Invalid hero');
}

// #[test]
fn mintHeroes() {
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);

    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);

    let gameAccountsAdrs = gameDispatcher.getAccountsAdrs();
    assert(gameAccountsAdrs == accountsAdrs, 'Invalid accounts address');
    gameDispatcher.createAccount('usernameTest');
    let accountTest =  accountsDispatcher.getAccount(testAdrs);
    assert(accountTest.username == 'usernameTest', 'Invalid username');
    gameDispatcher.mintHero();
    let hero = accountsDispatcher.getHero(testAdrs, 0);
    assert(hero.name != 0, 'Hero not minted');
}

#[test]
fn mintAndUpgradeRunes(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    
    // let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    // snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    // FOUNDRY BUG IF UNCOMMENT BOTH LINE
    // let allRunes = accountsDispatcher.getAllRunes(testAdrs).unwrap();
    // assert(allRunes.len() == 3, 'Invalid allRunes length');
    // let selectedRunes = accountsDispatcher.getRunes(testAdrs, array![0, 1]).unwrap();
    // assert(selectedRunes.len() == 2, 'Invalid selectedRunes length');

    gameDispatcher.upgradeRune(1);
    // let rune = accountsDispatcher.getRune(testAdrs, 1).unwrap();
    // assert(rune.rank == 1, 'Invalid rune rank');

    gameDispatcher.upgradeRune(1);
    gameDispatcher.upgradeRune(1);
    gameDispatcher.upgradeRune(1);
    // let rune = accountsDispatcher.getRune(testAdrs, 1);
    // assert(rune.rank == 4, 'Invalid rune rank');
}

// #[test]
fn equipRunes(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };
    let entityFactoryDispatcher = IEntityFactoryDispatcher { contract_address: entityFactoryAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    entityFactoryDispatcher.setAccountsAdrs(accountsAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');

    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();

    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();

    gameDispatcher.equipRune(0, 0);
    gameDispatcher.equipRune(1, 0);
    gameDispatcher.equipRune(0, 1);
    gameDispatcher.equipRune(2, 2);
    // let hero = accountsDispatcher.getHero(testAdrs, 0);
    // hero.getRunes().print();
    // let hero = accountsDispatcher.getHero(testAdrs, 1);
    // hero.getRunes().print();
    // let hero = accountsDispatcher.getHero(testAdrs, 2);
    // hero.getRunes().print();
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    gameDispatcher.upgradeRune(2);
    let hero = accountsDispatcher.getHero(testAdrs, 2);
    let entity = entityFactoryDispatcher.newEntity(testAdrs, 0, hero, AllyOrEnemy::Ally);
    entity.print();

    // BUGS WHEN GETRUNES BEFORE TESTING ENTITY
    // let allRunes = accountsDispatcher.getAllRunes((testAdrs));
    // let rune = *allRunes[2];
    // rune.print();
    // let hero = accountsDispatcher.getHero(testAdrs, 2);
    // let entity = entityFactoryDispatcher.newEntity(testAdrs, 0, hero, AllyOrEnemy::Ally);
    // entity.print();
}

// #[test]
fn startBattle(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesDispatcher { contract_address: battlesAdrs };
    let entityFactoryDispatcher = IEntityFactoryDispatcher { contract_address: entityFactoryAdrs };
    let skillentityF= ISkillFactoryDispatcher { contract_address: levelsAdrs };
    let levelsDispatcher = ILevelsDispatcher { contract_address: levelsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    entityFactoryDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.setIEntityFactoryDispatch(entityFactoryAdrs);
    gameDispatcher.setILevelsDispatch(levelsAdrs);
    gameDispatcher.setIBattlesDispatch(battlesAdrs);
    battlesDispatcher.setISkillFactoryDispatch(skillFactoryAdrs);
    battlesDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    let heroIds: Array<u32> = array![1, 2];
    gameDispatcher.startBattle(heroIds, 0, 1);
}

// #[test]
fn battle(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesDispatcher { contract_address: battlesAdrs };
    let entityFactoryDispatcher = IEntityFactoryDispatcher { contract_address: entityFactoryAdrs };
    let skillentityF= ISkillFactoryDispatcher { contract_address: levelsAdrs };
    let levelsDispatcher = ILevelsDispatcher { contract_address: levelsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    entityFactoryDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.setIEntityFactoryDispatch(entityFactoryAdrs);
    gameDispatcher.setILevelsDispatch(levelsAdrs);
    gameDispatcher.setIBattlesDispatch(battlesAdrs);
    battlesDispatcher.setISkillFactoryDispatch(skillFactoryAdrs);
    battlesDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    // gameDispatcher.mintHero();
    // gameDispatcher.mintHero();
    // gameDispatcher.mintHero();

    let heroIds: Array<u32> = array![5];
    gameDispatcher.startBattle(heroIds, 0, 1);
    gameDispatcher.playTurn(2, 2);
    gameDispatcher.playTurn(0, 2);
    gameDispatcher.playTurn(0, 2);
    gameDispatcher.playTurn(0, 2);
    gameDispatcher.playTurn(0, 2);
    gameDispatcher.playTurn(0, 3);
    gameDispatcher.playTurn(0, 3);
    gameDispatcher.playTurn(0, 3);

}

// #[test]
fn experience(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');
    let eventEmitterAdrs = deployContract('EventEmitter');

    let gameDispatcher = IGameDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesDispatcher { contract_address: battlesAdrs };
    let entityFactoryDispatcher = IEntityFactoryDispatcher { contract_address: entityFactoryAdrs };
    let skillentityF= ISkillFactoryDispatcher { contract_address: levelsAdrs };
    let levelsDispatcher = ILevelsDispatcher { contract_address: levelsAdrs };

    gameDispatcher.setIAccountsDispatch(accountsAdrs);
    entityFactoryDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.setIEntityFactoryDispatch(entityFactoryAdrs);
    gameDispatcher.setILevelsDispatch(levelsAdrs);
    gameDispatcher.setIBattlesDispatch(battlesAdrs);
    battlesDispatcher.setISkillFactoryDispatch(skillFactoryAdrs);
    battlesDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    battlesDispatcher.setILevelsDispatch(levelsAdrs);
    battlesDispatcher.setIAccountsDispatch(accountsAdrs);
    accountsDispatcher.setIEventEmitterDispatch(eventEmitterAdrs);
    
    // let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    // snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');

    let heroIds: Array<u32> = array![5];
    gameDispatcher.startBattle(heroIds, 0, 0);
    gameDispatcher.playTurn(2, 2);

    let heroIds: Array<u32> = array![5];
    gameDispatcher.startBattle(heroIds, 0, 1);
    gameDispatcher.playTurn(2, 2);

    let heroIds: Array<u32> = array![5];
    gameDispatcher.startBattle(heroIds, 0, 1);
    gameDispatcher.playTurn(2, 2);
}
