mod Account;
mod Hero;
use Account::AccountImpl;
use Hero::HeroImpl;

fn initGame() {
    let mut account = Account::new();
    let testHero1: Hero::Hero = Hero::new('testHero1');
    let testHero2: Hero::Hero = Hero::new('testHero2');
    // testHero1.print();
    account.addHero(testHero1);
    account.addHero(testHero2);
    // account.print();
}