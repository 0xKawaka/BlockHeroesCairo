mod Account;
mod Hero;
mod BaseStatistics;
mod Battle;
use Account::AccountImpl;
use Hero::HeroImpl;
use BaseStatistics::BaseStatisticsImpl;
use debug::PrintTrait;

fn initGame() {
    let mut account = Account::new();
    let knight: Hero::Hero = Hero::new('knight', 1, 2);
    let priest: Hero::Hero = Hero::new('priest', 10, 1);
    // knight.print();
    account.addHero(knight);
    account.addHero(priest);
    // account.print();
}