use debug::PrintTrait;
use option::OptionTrait;
use super::Hero;
use super::Hero::HeroTrait;
use super::Hero::HeroImpl;

#[derive(Drop)]
struct Account {
    energy: u32,
    shards: u32,
    heroes: Array<Hero::Hero>,
}

const maxEnergy: u32 = 100;
fn new() -> Account {
    Account {
        energy: maxEnergy,
        shards: 0,
        heroes: ArrayTrait::new(),
    }
}

trait AccountTrait {
    fn addHero(ref self: Account, hero: Hero::Hero) -> ();
    fn print(self: Account) -> ();
    fn printHeroes(self: Account) -> ();
}

impl AccountImpl of AccountTrait {
    fn addHero(ref self: Account, hero: Hero::Hero) {
        self.heroes.append(hero);
    }
    fn print(self: Account) {
        self.energy.print();
        self.shards.print();
        self.printHeroes();
    }
    fn printHeroes(self: Account) {
        let mut i: usize = 0;
        let mut heroesSpan = self.heroes.span();
        loop {
            if(i > heroesSpan.len()) {
                break;
            }
            let heroOption = heroesSpan.pop_front();
            let hero = *heroOption.unwrap();
            hero.print();
            i = i + 1;
        }
    }
}

