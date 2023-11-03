use starknet::ContractAddress;
use super::super::Components::Hero::Hero;

#[starknet::interface]
trait IAccounts<TContractState> {
    fn addHero(ref self: TContractState, accountAdrs: ContractAddress, name: felt252, level: u16,  rank: u16);
    fn createAccount(ref self: TContractState, accountAdrs: ContractAddress);
    fn getHeroes(ref self: TContractState, accountAdrs: ContractAddress, heroesIds: Array<u16>) -> Array<Hero>;
    fn getHero(ref self: TContractState, accountAdrs: ContractAddress, heroId: u16) -> Hero;
}

#[starknet::contract]
mod Accounts {
    use core::array::SpanTrait;
use  debug::PrintTrait;
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    use game::Components::Account::AccountTrait;
    use super::super::super::Components::{Account, Account::AccountImpl};
    use super::super::super::Components::{Hero, Hero::HeroImpl};
    use super::super::super::Libraries::List::{List, ListTrait};

    #[storage]
    struct Storage {
        accounts: LegacyMap<ContractAddress, Account::Account>,
        heroes: LegacyMap<(ContractAddress, u16), Hero::Hero>, // (account, heroId) -> hero
    }

    #[external(v0)]
    impl AccountsImpl of super::IAccounts<ContractState> {
        fn addHero(ref self: ContractState, accountAdrs: ContractAddress, name: felt252, level: u16,  rank: u16) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut account = self.accounts.read(accountAdrs);
            self.heroes.write((accountAdrs, account.heroesCount), Hero::new(name, level, rank));
            account.incrementHeroes();
            self.accounts.write(accountAdrs, account);
        }
        fn createAccount(ref self: ContractState, accountAdrs: ContractAddress) {
            let acc = Account::new(accountAdrs);
            self.accounts.write(accountAdrs, acc);
        }
        fn getHeroes(ref self: ContractState, accountAdrs: ContractAddress, heroesIds: Array<u16>) -> Array<Hero::Hero> {
            let mut heroes: Array<Hero::Hero> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == heroesIds.len() {
                    break;
                }
                heroes.append(self.heroes.read((accountAdrs, *heroesIds[i])));
                i += 1;
            };
            return heroes;
        }
        fn getHero(ref self: ContractState, accountAdrs: ContractAddress, heroId: u16) -> Hero::Hero {
            return self.heroes.read((accountAdrs, heroId));
        }
    }

}