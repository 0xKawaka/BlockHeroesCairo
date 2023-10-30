use core::box::BoxTrait;
use core::option::OptionTrait;
use core::array::ArrayTrait;
mod Account;
mod Hero;
mod Battle;
mod EntityFactory;
mod StaticData;
mod libraries;
use EntityFactory::EntityFactoryImpl;
use Account::AccountImpl;
use Hero::HeroImpl;
use StaticData::Skillsets::createSkillsets;
use StaticData::SkillsDict::createSkillsDict;
use StaticData::BaseStatisticsDict::createBaseStatisticsDict;
use StaticData::WorldLevels;
// use BaseStatisticsDict::BaseStatisticsDictImpl;
use debug::PrintTrait;

fn initGame() {
    let mut account = Account::new();
    let knight: Hero::Hero = Hero::new('knight', 2, 2);
    let knight2: Hero::Hero = Hero::new('knight', 15, 1);
    let priest: Hero::Hero = Hero::new('priest', 5, 1);
    let priest2: Hero::Hero = Hero::new('priest', 10, 1);
    let hunter: Hero::Hero = Hero::new('hunter', 10, 1);
    // knight.print();
    account.addHero(knight);
    account.addHero(knight2);
    account.addHero(priest);
    account.addHero(priest2);
    account.addHero(hunter);
    let mut indexesHero: Array<u32> = ArrayTrait::new();
    indexesHero.append(0);
    indexesHero.append(1);
    // indexesHero.append(2);
    // let baseStatisticsDict = BaseStatisticsDict::new();
    let heroesSkillsets = createSkillsets();
    let skillsDict = createSkillsDict();
    let baseStatisticsDict = createBaseStatisticsDict();
    let battleInfosMatrix = WorldLevels::createWorldLevels();
    let mut battleHeroFactory = EntityFactory::new(baseStatisticsDict, skillsDict, heroesSkillsets);
    startBattle(ref account, @indexesHero, 1, 1, @battleInfosMatrix, ref battleHeroFactory);
}

fn startBattle(
    ref account: Account::Account,
    indexesHero: @Array<u32>,
    world: u32,
    level: u32,
    battleInfosMatrix: @Array<Array<WorldLevels::BattleInfos>>,
    ref battleHeroFactory: EntityFactory::EntityFactory
) {
    let worldBattleInfos = battleInfosMatrix[world];
    let levelBattleInfos = worldBattleInfos.get(level).unwrap().unbox();
    account.startBattle(indexesHero, levelBattleInfos.monsters, ref battleHeroFactory);
}
