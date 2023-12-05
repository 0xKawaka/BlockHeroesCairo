use core::traits::TryInto;
use core::traits::Into;
use debug::PrintTrait;
use option::OptionTrait;
use super::Hero::{Hero, HeroTrait, HeroImpl};
use super::Battle;
use {starknet::ContractAddress, starknet::get_block_timestamp};

const timeTickEnergy: u64 = 1200;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Account {
    username: felt252,
    energy: u16,
    crystals: u32,
    lastEnergyUpdateTimestamp: u64,
    owner: ContractAddress,
}

const maxEnergy: u16 = 5;
fn new(username: felt252, owner: ContractAddress) -> Account {
    Account {
        username: username,
        energy: maxEnergy,
        crystals: 10000,
        lastEnergyUpdateTimestamp: get_block_timestamp(),
        owner: owner,
    }
}

trait AccountTrait {
    fn updateEnergy(ref self: Account);
    fn decreaseEnergy(ref self: Account, energyCost: u16);
    fn increaseCrystals(ref self: Account, crystalsToAdd: u32);
    fn decreaseCrystals(ref self: Account, crystalsToSub: u32);
    fn getEnergyInfos(self: Account) -> (u16, u64);
    fn print(self: Account);
}

impl AccountImpl of AccountTrait {
    fn updateEnergy(ref self: Account) {
        let now = get_block_timestamp();
        
        if(self.energy == maxEnergy) {
            self.lastEnergyUpdateTimestamp = now;
            return;
        }

        PrintTrait::print('self.lastEnergyUpdateTimestamp');
        PrintTrait::print(self.lastEnergyUpdateTimestamp);

        let timeDiff = now - self.lastEnergyUpdateTimestamp;
        let energyToAdd = timeDiff / timeTickEnergy;

        if(energyToAdd == 0) {
            return;
        }
        self.energy = self.energy + energyToAdd.try_into().unwrap();

        if(self.energy >= maxEnergy) {
            self.energy = maxEnergy;
            self.lastEnergyUpdateTimestamp = now;
            return;
        }

        let timeLeft = timeDiff % timeTickEnergy;
        self.lastEnergyUpdateTimestamp = now - timeLeft;
    }
    fn decreaseEnergy(ref self: Account, energyCost: u16) {
        assert(self.energy >= energyCost, 'Not enough energy');
        self.energy = self.energy - energyCost;
    }
    fn increaseCrystals(ref self: Account, crystalsToAdd: u32) {
        self.crystals = self.crystals + crystalsToAdd;
    }
    fn decreaseCrystals(ref self: Account, crystalsToSub: u32) {
        assert(self.crystals >= crystalsToSub, 'Not enough crystals');
        self.crystals = self.crystals - crystalsToSub;
    }
    fn getEnergyInfos(self: Account) -> (u16, u64) {
        return (self.energy, self.lastEnergyUpdateTimestamp);
    }
    fn print(self: Account) {
        self.energy.print();
        self.crystals.print();
    }
}

