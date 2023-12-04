use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};
use starknet::ContractAddress;

const baseCrystalsGivenPerEnemy: u32 = 100;
const crystalsBonusPercentPerLevel: u32 = 5;

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
    IEventEmitterDispatch.loot(owner, crystals);
}