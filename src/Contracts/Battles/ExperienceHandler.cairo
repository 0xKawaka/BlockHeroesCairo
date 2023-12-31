use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};
use starknet::ContractAddress;

const levelZeroExperienceGiven: u32 = 100;
const bonusExperiencePercentEnemyGivesPerLevel: u32 = 5;

fn computeAndDistributeExperience(owner: ContractAddress, heroesIndexes: Array<u32>, enemyLevels: @Array<u16>, IAccountsDispatch: IAccountsDispatcher, IEventEmitterDispatch: IEventEmitterDispatcher) {
    let totalExperience = computeExperienceAmount(enemyLevels);
    let experiencePerHero = totalExperience / heroesIndexes.len();
    let mut i: u32 = 0;
    loop {
        if i == heroesIndexes.len() {
            break;
        }
        IAccountsDispatch.addExperienceToHeroId(owner, *heroesIndexes[i], experiencePerHero, IEventEmitterDispatch);
        i += 1;
    };
}

fn computeExperienceAmount(enemyLevels: @Array<u16>) -> u32 {
    let mut totalExperiennce = 0;
    let mut i: u32 = 0;
    loop {
        if i == enemyLevels.len() {
            break;
        }
        totalExperiennce += computeExperienceAmountForEnemy((*enemyLevels[i]).into());
        i += 1;
    };
    return totalExperiennce;
}

fn computeExperienceAmountForEnemy(enemyLevel: u32) -> u32 {
    return levelZeroExperienceGiven + (((enemyLevel - 1) * levelZeroExperienceGiven * bonusExperiencePercentEnemyGivesPerLevel) / 100);
}