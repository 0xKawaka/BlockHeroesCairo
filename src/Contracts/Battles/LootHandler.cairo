use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};
use starknet::{ContractAddress, get_block_timestamp};
use game::Libraries::Random::rand32;

const baseCrystalsGivenPerEnemy: u32 = 100;
const crystalsBonusPercentPerLevel: u32 = 5;
const runeLootChance: u32 = 6;

fn computeAndDistributeLoot(owner: ContractAddress, enemyLevels: @Array<u16>, IAccountsDispatch: IAccountsDispatcher, IEventEmitterDispatch: IEventEmitterDispatcher) {
    let mut totalLevel: u32 = 0;
    let mut i: u32 = 0;
    let enemiesLen = enemyLevels.len();
    loop {
        if i == enemiesLen {
            break;
        }
        totalLevel += (*enemyLevels[i]).into();
        i += 1;
    };
    let crystals: u32 = baseCrystalsGivenPerEnemy * enemiesLen + ((baseCrystalsGivenPerEnemy * (totalLevel - enemiesLen) * crystalsBonusPercentPerLevel) / 100);
    IAccountsDispatch.increaseCrystals(owner, crystals);
    if(hasLootedRune()) {
        IAccountsDispatch.mintRune(owner);
    }
    IEventEmitterDispatch.loot(owner, crystals);
}

fn hasLootedRune() -> bool {
    return rand32(get_block_timestamp(), 10) < runeLootChance;
}