use starknet::ContractAddress;
use game::Components::Hero::Hero;

#[starknet::interface]
trait IAccounts<TContractState> {
    fn mintHero(ref self: TContractState, accountAdrs: ContractAddress);
    fn mintHeroAdmin(ref self: TContractState, accountAdrs: ContractAddress, name: felt252, level: u16, rank: u16);
    fn createAccount(ref self: TContractState, accountAdrs: ContractAddress);
    fn getHeroes(ref self: TContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero>;
    fn getHero(ref self: TContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero;
}

#[starknet::contract]
mod Accounts {
    use game::Components::Hero::HeroTrait;
use core::starknet::event::EventEmitter;
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

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NewAccount: NewAccount,
        HeroMinted: HeroMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct NewAccount {
        owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct HeroMinted {
        owner: ContractAddress,
        heroName: felt252,
    }

    #[external(v0)]
    impl AccountsImpl of super::IAccounts<ContractState> {
        fn mintHero(ref self: ContractState, accountAdrs: ContractAddress) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            let heroName = 'knight';
            heroesList.append(Hero::new(heroName, 1, 1));
            self.emit(HeroMinted { owner: accountAdrs, heroName: heroName });
        }
        fn mintHeroAdmin(ref self: ContractState, accountAdrs: ContractAddress, name: felt252, level: u16, rank: u16) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            heroesList.append(Hero::new(name, level, rank));
            self.emit(HeroMinted { owner: accountAdrs, heroName: name });
        }

        fn createAccount(ref self: ContractState, accountAdrs: ContractAddress) {
            assert(self.accounts.read(accountAdrs).owner != accountAdrs, 'Account already created');
            let acc = Account::new(accountAdrs);
            self.accounts.write(accountAdrs, acc);
            self.emit(NewAccount { owner: accountAdrs });
        }
        fn getHeroes(ref self: ContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero::Hero> {
            let mut heroes: Array<Hero::Hero> = Default::default();
            let heroesList = self.heroes.read(accountAdrs);
            let mut i: u32 = 0;
            loop {
                if i == heroesIds.len() {
                    break;
                }
                assert(heroesList.len() > *heroesIds[i], 'Hero not found');
                heroes.append(heroesList.get(*heroesIds[i]).unwrap());
                i += 1;
            };
            return heroes;
        }
        fn getHero(ref self: ContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero::Hero {
            let heroesList = self.heroes.read(accountAdrs);
            assert(heroesList.len() > heroId, 'Hero not found');
            heroesList[heroId].print();
            return heroesList[heroId];
        }
    }

}