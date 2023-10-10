mod Account;
mod Hero;
mod BaseStatistics;
use Account::AccountImpl;
use Hero::HeroImpl;
use BaseStatistics::BaseStatisticsImpl;
use nullable::{match_nullable, FromNullableResult};
use debug::PrintTrait;

fn initGame() {
    let mut account = Account::new();
    let knight: Hero::Hero = Hero::new('knight', 1, 2);
    let priest: Hero::Hero = Hero::new('priest', 10, 1);
    // knight.print();
    account.addHero(knight);
    account.addHero(priest);
    // account.print();

    let mut baseStatisticsDict = BaseStatistics::createBaseStatisticsDict();
    let baseStatsKnightBox = baseStatisticsDict.get(knight.name);
    let baseStatsKnight = match match_nullable(baseStatsKnightBox) {
        FromNullableResult::Null(()) => panic_with_felt252('No value found knight'),
        FromNullableResult::NotNull(val) => val.unbox(),
    };
    let health = baseStatsKnight.getHealth(knight.level, knight.rank);
    health.print();



}