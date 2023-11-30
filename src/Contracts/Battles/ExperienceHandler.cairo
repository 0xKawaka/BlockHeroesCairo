use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};
use starknet::ContractAddress;

const levelZeroExperienceGiven: u32 = 100;
const bonusExperiencePercentEnemyGivesPerLevel: u32 = 5;

fn computeAndDistributeExperience(owner: ContractAddress, heroesIndexes: Array<u32>, enemmyLevels: Array<u16>, IAccountsDispatch: IAccountsDispatcher, IEventEmitterDispatch: IEventEmitterDispatcher) {
    let totalExperience = computeExperienceAmount(enemmyLevels);
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

fn computeExperienceAmount(enemmyLevels: Array<u16>) -> u32 {
    let mut totalExperiennce = 0;
    let mut i: u32 = 0;
    loop {
        if i == enemmyLevels.len() {
            break;
        }
        totalExperiennce += computeExperienceAmountForEnemy((*enemmyLevels[i]).into());
        i += 1;
    };
    return totalExperiennce;
}

fn computeExperienceAmountForEnemy(enemyLevel: u32) -> u32 {
    return levelZeroExperienceGiven + (((enemyLevel - 1) * levelZeroExperienceGiven * bonusExperiencePercentEnemyGivesPerLevel) / 100);
}