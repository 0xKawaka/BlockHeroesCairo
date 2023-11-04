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

use debug::PrintTrait;

fn deployContract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

// #[test]
fn testAddHeroes() {
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let factoryAdrs = deployContract('EntityFactory');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    let factoryDispatcher = IEntityFactorySafeDispatcher { contract_address: factoryAdrs };
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.createAccount();
    accountsDispatcher.addHero(testAdrs, 'priest', 10, 1);
    accountsDispatcher.addHero(testAdrs, 'knight', 1, 2);
    let hero0 = accountsDispatcher.getHero(testAdrs, 0).unwrap();
    let hero1 = accountsDispatcher.getHero(testAdrs, 1).unwrap();
    assert(hero0.name == 'priest' && hero0.level == 10 &&  hero0.rank == 1, 'Invalid hero');
    assert(hero1.name == 'knight', 'Invalid hero');
}

// #[test]
fn testMintHeroes() {
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let factoryAdrs = deployContract('EntityFactory');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    let factoryDispatcher = IEntityFactorySafeDispatcher { contract_address: factoryAdrs };

    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.setAccountsAdrs(accountsAdrs);
    let gameAccountsAdrs = gameDispatcher.getAccountsAdrs().unwrap();
    assert(gameAccountsAdrs == accountsAdrs, 'Invalid accounts address');
    gameDispatcher.createAccount();
    gameDispatcher.mintHero();
    let hero = accountsDispatcher.getHero(testAdrs, 0).unwrap();
    assert(hero.name != 0, 'Hero not minted');
}

#[test]
fn EntityFactoryTest(){
    let gameAdrs = deployContract('Game');
    let accountsAdrs = deployContract('Accounts');
    let battlesAdrs = deployContract('Battles');
    let factoryAdrs = deployContract('EntityFactory');
    let levelsAdrs = deployContract('Levels');

    let gameDispatcher = IGameSafeDispatcher { contract_address: gameAdrs };
    let accountsDispatcher = IAccountsSafeDispatcher { contract_address: accountsAdrs };
    let battlesDispatcher = IBattlesSafeDispatcher { contract_address: battlesAdrs };
    let factoryDispatcher = IEntityFactorySafeDispatcher { contract_address: factoryAdrs };
    let levelsDispatcher = ILevelsSafeDispatcher { contract_address: levelsAdrs };

    gameDispatcher.setAccountsAdrs(accountsAdrs);
    gameDispatcher.setEntityFactoryAdrs(factoryAdrs);
    gameDispatcher.setLevelsAdrs(levelsAdrs);
    gameDispatcher.setBattleAdrs(battlesAdrs);
    
    let testAdrs = starknet::contract_address_try_from_felt252('0x123').unwrap();
    snforge_std::start_prank(gameAdrs, testAdrs);
    gameDispatcher.createAccount();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    gameDispatcher.mintHero();
    let heroIds: Array<u32> = array![1, 2];
    gameDispatcher.startBattle(heroIds, 0, 1);
}
