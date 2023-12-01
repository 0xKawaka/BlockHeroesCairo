use core::traits::TryInto;
use core::traits::Into;
use debug::PrintTrait;
use option::OptionTrait;
use super::Hero::{Hero, HeroTrait, HeroImpl};
use super::Battle;
use {starknet::ContractAddress, starknet::get_block_timestamp};


#[derive(starknet::Store, Copy, Drop, Serde)]
struct Account {
    username: felt252,
    energy: u16,
    shards: u32,
    lastEnergyActionTimestamp: u64,
    owner: ContractAddress,
}

const maxEnergy: u16 = 5;
fn new(username: felt252, owner: ContractAddress) -> Account {
    Account {
        username: username,
        energy: maxEnergy,
        shards: 0,
        lastEnergyActionTimestamp: get_block_timestamp(),
        owner: owner,
    }
}

trait AccountTrait {
    fn updateEnergy(ref self: Account);
    fn decreaseEnergy(ref self: Account, energyCost: u16);
    fn print(self: Account);
}

impl AccountImpl of AccountTrait {
    fn updateEnergy(ref self: Account) {
        let now = get_block_timestamp();
        
        if(self.energy == maxEnergy) {
            self.lastEnergyActionTimestamp = now;
            return;
        }

        let timeDiff = now - self.lastEnergyActionTimestamp;
        let energyToAdd = timeDiff / 120;
        let timeLeft = timeDiff % 120;

        if(energyToAdd >= maxEnergy.into()) {
            self.energy = maxEnergy;
            self.lastEnergyActionTimestamp = now;
            return;
        }

        self.energy = self.energy + energyToAdd.try_into().unwrap();
        self.lastEnergyActionTimestamp = now - timeLeft;
    }
    fn decreaseEnergy(ref self: Account, energyCost: u16) {
        assert(self.energy >= energyCost, 'Not enough energy');
        self.energy = self.energy - energyCost;
    }
    fn print(self: Account) {
        self.energy.print();
        self.shards.print();
    }
}

