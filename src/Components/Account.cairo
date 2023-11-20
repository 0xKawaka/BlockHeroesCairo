use debug::PrintTrait;
use option::OptionTrait;
use super::Hero::{Hero, HeroTrait, HeroImpl};
use super::Battle;
use starknet::ContractAddress;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Account {
    username: felt252,
    energy: u32,
    shards: u32,
    owner: ContractAddress,
    // lastEnergyActionTimestamp
}

const maxEnergy: u32 = 10;
fn new(username: felt252, owner: ContractAddress) -> Account {
    Account {
        username: username,
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

