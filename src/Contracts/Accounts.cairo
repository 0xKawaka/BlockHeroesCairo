use starknet::ContractAddress;
use game::Components::Hero::Hero;

#[starknet::interface]
trait IAccounts<TContractState> {
    fn addHero(ref self: TContractState, accountAdrs: ContractAddress, name: felt252, level: u16,  rank: u16);
    fn createAccount(ref self: TContractState, accountAdrs: ContractAddress);
    fn getHeroes(ref self: TContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero>;
    fn getHero(ref self: TContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero;
}

#[starknet::contract]
mod Accounts {
    use debug::PrintTrait;
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    use game::Components::Account::AccountTrait;
    use game::Components::{Account, Account::AccountImpl};
    use game::Components::{Hero, Hero::HeroImpl};
    use game::Libraries::List::{List, ListTrait};

    #[storage]
    struct Storage {
        accounts: LegacyMap<ContractAddress, Account::Account>,
        heroes: LegacyMap<ContractAddress, List<Hero::Hero>>,
    }

    #[external(v0)]
    impl AccountsImpl of super::IAccounts<ContractState> {
        fn addHero(ref self: ContractState, accountAdrs: ContractAddress, name: felt252, level: u16,  rank: u16) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            heroesList.append(Hero::new(name, level, rank));
        }
        fn createAccount(ref self: ContractState, accountAdrs: ContractAddress) {
            let acc = Account::new(accountAdrs);
            self.accounts.write(accountAdrs, acc);
        }
        fn getHeroes(ref self: ContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero::Hero> {
            let mut heroes: Array<Hero::Hero> = Default::default();
            let heroesList = self.heroes.read(accountAdrs);
            let mut i: u32 = 0;
            loop {
                if i == heroesIds.len() {
                    break;
                }
                heroes.append(heroesList.get(*heroesIds[i]).unwrap());
                i += 1;
            };
            return heroes;
        }
        fn getHero(ref self: ContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero::Hero {
            return self.heroes.read(accountAdrs).get(heroId).unwrap();
        }
    }

}