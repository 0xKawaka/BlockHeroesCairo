use debug::PrintTrait;
use option::OptionTrait;
use super::Hero::{Hero, HeroTrait, HeroImpl};
use super::Battle;
use starknet::ContractAddress;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Account {
    energy: u32,
    shards: u32,
    owner: ContractAddress,
}

const maxEnergy: u32 = 100;
fn new(owner: ContractAddress) -> Account {
    Account {
        energy: maxEnergy,
        shards: 0,
        owner: owner,
    }
}

trait AccountTrait {
    fn print(self: Account);
}

impl AccountImpl of AccountTrait {
    fn print(self: Account) {
        self.energy.print();
        self.shards.print();
    }
}

