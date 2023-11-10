use game::Components::Hero::HeroTrait;
use core::result::ResultTrait;
use core::option::OptionTrait;
use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use starknet::get_caller_address;

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
use game::Components::Hero::{Hero, HeroImpl};
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
    // let battlesAdrs = deployContract('Battles');
    // let factoryAdrs = deployContract('EntityFactory');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    // let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    // let entityF= IEntityFactorySafeDispatcher { contract_address: factoryAdrs };
    gameDispatcher.setAccountsAdrs(accountsAdrs);
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    accountsDispatcher.mintHeroAdmin(testAdrs, 'priest', 10, 1);
    accountsDispatcher.mintHeroAdmin(testAdrs, 'knight', 1, 2);
    let hero0 = accountsDispatcher.getHero(testAdrs, 0).unwrap();
    let hero1 = accountsDispatcher.getHero(testAdrs, 1).unwrap();
    assert(hero0.name == 'priest' && hero0.level == 10 &&  hero0.rank == 1, 'Invalid hero');
    assert(hero1.name == 'knight', 'Invalid hero');
}

// #[test]
fn mintHeroes() {
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let factoryAdrs = deployContract('EntityFactory');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    let entityF= IEntityFactorySafeDispatcher { contract_address: factoryAdrs };

    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.setAccountsAdrs(accountsAdrs);
    let gameAccountsAdrs = gameDispatcher.getAccountsAdrs().unwrap();
    assert(gameAccountsAdrs == accountsAdrs, 'Invalid accounts address');
    gameDispatcher.createAccount('usernameTest');
    let accountTest =  accountsDispatcher.getAccount(testAdrs).unwrap();
    assert(accountTest.username == 'usernameTest', 'Invalid username');
    gameDispatcher.mintHero();
    let hero = accountsDispatcher.getHero(testAdrs, 0).unwrap();
    assert(hero.name != 0, 'Hero not minted');
}

// #[test]
fn mintRunes(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };

    gameDispatcher.setAccountsAdrs(accountsAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();

    // FOUNDRY BUG IF UNCOMMENT BOTH LINE
    // let allRunes = accountsDispatcher.getAllRunes(testAdrs).unwrap();
    // assert(allRunes.len() == 3, 'Invalid allRunes length');
    let selectedRunes = accountsDispatcher.getRunes(testAdrs, array![0, 1]).unwrap();
    assert(selectedRunes.len() == 2, 'Invalid selectedRunes length');
}

// #[test]
fn equipRunes(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };

    gameDispatcher.setAccountsAdrs(accountsAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');

    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    // FOUNDRY BUG IF HERO NOT MINTED ASSERT ERROR ISN'T RAISED

    gameDispatcher.mintRune();
    gameDispatcher.mintRune();
    gameDispatcher.mintRune();

    gameDispatcher.equipRune(0, 1);
    // let hero = accountsDispatcher.getHero(testAdrs, 1).unwrap();
    // hero.getRunes().print();
}

#[test]
fn startBattle(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let entityFactoryAdrs = deployContract('EntityFactory');
    let skillFactoryAdrs = deployContract('SkillFactory');
    let levelsAdrs = deployContract('Levels');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    let entityFactoryDispatcher = IEntityFactorySafeDispatcher { contract_address: entityFactoryAdrs };
    let skillentityF= ISkillFactorySafeDispatcher { contract_address: levelsAdrs };
    let levelsDispatcher = ILevelsSafeDispatcher { contract_address: levelsAdrs };

    gameDispatcher.setAccountsAdrs(accountsAdrs);
    entityFactoryDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.setEntityFactoryAdrs(entityFactoryAdrs);
    gameDispatcher.setLevelsAdrs(levelsAdrs);
    gameDispatcher.setBattleAdrs(battlesAdrs);
    battlesDispatcher.setSkillFactoryAdrs(skillFactoryAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount('usernameTest');
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    let heroIds: Array<u32> = array![1, 2];
    gameDispatcher.startBattle(heroIds, 0, 1);
    // gameDispatcher.playTurn(1, 2);
}
