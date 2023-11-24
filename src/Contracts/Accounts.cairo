use starknet::ContractAddress;
use game::Components::Hero::{Hero, Rune::Rune};
use game::Components::Account::Account;
use game::Contracts::EventEmitter::IEventEmitterDispatcher;

#[starknet::interface]
trait IAccounts<TContractState> {
    fn equipRune(ref self: TContractState, accountAdrs: ContractAddress, runeId: u32, heroId: u32);
    fn unequipRune(ref self: TContractState, accountAdrs: ContractAddress, runeId: u32);
    fn upgradeRune(ref self: TContractState, accountAdrs: ContractAddress, runeId: u32);
    fn mintHero(ref self: TContractState, accountAdrs: ContractAddress);
    fn mintHeroAdmin(ref self: TContractState, accountAdrs: ContractAddress, name: felt252, level: u16, rank: u16);
    fn mintRune(ref self: TContractState, accountAdrs: ContractAddress);
    fn createAccount(ref self: TContractState,  username: felt252, accountAdrs: ContractAddress);
    fn setIEventEmitterDispatch(ref self: TContractState, eventEmitterAdrs: ContractAddress);
    fn getAccount(self: @TContractState, accountAdrs: ContractAddress) -> Account;
    fn getHero(self: @TContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero;
    fn getHeroes(self: @TContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero>;
    fn getAllHeroes(self: @TContractState, accountAdrs: ContractAddress) -> Array<Hero>;
    fn getRune(self: @TContractState, accountAdrs: ContractAddress, runeId: u32) -> Rune;
    fn getRunes(self: @TContractState, accountAdrs: ContractAddress, runesIds: Array<u32>) -> Array<Rune>;
    fn getAllRunes(self: @TContractState, accountAdrs: ContractAddress) -> Array<Rune>;
}

#[starknet::contract]
mod Accounts {
    use game::Contracts::Accounts::IAccounts;
use game::Components::Hero::Rune::RuneTrait;
use core::array::ArrayTrait;
use core::option::OptionTrait;
use core::box::BoxTrait;
use game::Components::Hero::HeroTrait;
    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;

    use game::Components::Account::AccountTrait;
    use game::Components::{Account, Account::AccountImpl};
    use game::Components::{Hero, Hero::HeroImpl, Hero::Rune, Hero::EquippedRunesImpl, Hero::Rune::RuneImpl};
    use game::Libraries::List::{List, ListTrait};
    use game::Libraries::Random::rand32;
    use game::Contracts::EventEmitter::{IEventEmitterDispatcher, IEventEmitterDispatcherTrait};

    use debug::PrintTrait;

    #[storage]
    struct Storage {
        accounts: LegacyMap<ContractAddress, Account::Account>,
        heroes: LegacyMap<ContractAddress, List<Hero::Hero>>,
        runes: LegacyMap<ContractAddress, List<Rune::Rune>>,
        IEventEmitterDispatch: IEventEmitterDispatcher,
    }

    #[external(v0)]
    impl AccountsImpl of super::IAccounts<ContractState> {
        fn equipRune(ref self: ContractState, accountAdrs: ContractAddress, runeId: u32, heroId: u32) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            // PrintTrait::print(heroesList.len());
            // PrintTrait::print(heroId);
            // PrintTrait::print(heroesList.len() > heroId);
            assert(heroesList.len() > heroId, 'heroId out of range');
            let mut runesList = self.runes.read(accountAdrs);
            assert(runesList.len() > runeId, 'runeId out of range');
            let mut hero = heroesList[heroId];
            let mut rune = runesList[runeId];
            hero.equipRune(ref rune, ref runesList);
            // hero.print();
            // hero.getRunes().print();
            // rune.print();
            // heroesList.set(heroId, hero);
            runesList.set(runeId, rune);
            heroesList.set(heroId, hero);

            // let newHeroesList = self.heroes.read(accountAdrs);
            let newHero = heroesList[heroId];
            // newHero.print();
            // newHero.getRunes().print();
            let newRuneList = self.runes.read(accountAdrs);
            let newRune = newRuneList[runeId];
            // newRune.print();
        }
        fn unequipRune(ref self: ContractState, accountAdrs: ContractAddress, runeId: u32) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut runesList = self.runes.read(accountAdrs);
            assert(runesList.len() > runeId, 'runeId out of range');
            let mut rune = runesList[runeId];
            assert(rune.isEquipped(), 'Rune not equipped');
            let mut heroesList = self.heroes.read(accountAdrs);
            let mut hero = heroesList[rune.getHeroEquipped()];
            hero.unequipRune(ref rune);
            heroesList.set(hero.id, hero);
            runesList.set(runeId, rune);
        }
        fn upgradeRune(ref self: ContractState, accountAdrs: ContractAddress, runeId: u32) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut runesList = self.runes.read(accountAdrs);
            assert(runesList.len() > runeId, 'runeId out of range');
            let mut rune = runesList[runeId];
            rune.upgrade(accountAdrs, self.IEventEmitterDispatch.read());
            runesList.set(runeId, rune);
        }
        fn mintHero(ref self: ContractState, accountAdrs: ContractAddress) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            let heroesPossible: Array<felt252> = array!['priest', 'assassin', 'knight', 'hunter'];
            let randIndex = rand32(get_block_timestamp(), heroesPossible.len());
            let heroName = *heroesPossible[randIndex];
            heroesList.append(Hero::new(heroesList.len(), heroName, 1, 1));
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, heroName);
        }
        fn mintHeroAdmin(ref self: ContractState, accountAdrs: ContractAddress, name: felt252, level: u16, rank: u16) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut heroesList = self.heroes.read(accountAdrs);
            heroesList.append(Hero::new(heroesList.len(), name, level, rank));
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, name);
        }
        fn mintRune(ref self: ContractState, accountAdrs: ContractAddress) {
            assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
            let mut runesList = self.runes.read(accountAdrs);
            runesList.append(Rune::new(runesList.len()));
            self.IEventEmitterDispatch.read().runeMinted(accountAdrs, runesList[runesList.len() - 1]);
        }

        // fn mint(ref self: ContractState, accountAdrs: ContractAddress, rune: Rune::Rune) {
        //     assert(self.accounts.read(accountAdrs).owner == accountAdrs, 'Account not created');
        //     let mut runesList = self.runes.read(accountAdrs);
        //     runesList.append(rune);
        //     self.IEventEmitterDispatch.read().runeMinted(accountAdrs, runesList[runesList.len() - 1]);
        // }

        fn createAccount(ref self: ContractState, username: felt252, accountAdrs: ContractAddress) {
            assert(self.accounts.read(accountAdrs).owner != accountAdrs, 'Account already created');
            let acc = Account::new(username, accountAdrs);
            self.accounts.write(accountAdrs, acc);
            self.IEventEmitterDispatch.read().newAccount(accountAdrs, username);
            self.mintStarterHeroes(accountAdrs);
            self.mintStarterRunes(accountAdrs);
        }
        fn setIEventEmitterDispatch(ref self: ContractState, eventEmitterAdrs: ContractAddress) {
            self.IEventEmitterDispatch.write(IEventEmitterDispatcher { contract_address: eventEmitterAdrs });
        }
        fn getAccount(self: @ContractState, accountAdrs: ContractAddress) -> Account::Account {
            return self.accounts.read(accountAdrs);
        }
        fn getRune(self: @ContractState, accountAdrs: ContractAddress, runeId: u32) -> Rune::Rune {
            let runesList = self.runes.read(accountAdrs);
            assert(runesList.len() > runeId, 'runeId out of range');
            return runesList[runeId];
        }
        fn getRunes(self: @ContractState, accountAdrs: ContractAddress, runesIds: Array<u32>) -> Array<Rune::Rune> {
            let mut runes: Array<Rune::Rune> = Default::default();
            let runesList = self.runes.read(accountAdrs);
            let mut i: u32 = 0;
            loop {
                if i == runesIds.len() {
                    break;
                }
                assert(runesList.len() > *runesIds[i], 'runeId out of range');
                runes.append(runesList.get(*runesIds[i]).unwrap());
                i += 1;
            };
            return runes;
        }
        fn getAllRunes(self: @ContractState, accountAdrs: ContractAddress) -> Array<Rune::Rune> {
            let runesList = self.runes.read(accountAdrs);
            return runesList.array();
        }
        fn getHero(self: @ContractState, accountAdrs: ContractAddress, heroId: u32) -> Hero::Hero {
            let heroesList = self.heroes.read(accountAdrs);
            assert(heroesList.len() > heroId, 'heroId out of range');
            return heroesList[heroId];
        }
        fn getHeroes(self: @ContractState, accountAdrs: ContractAddress, heroesIds: Array<u32>) -> Array<Hero::Hero> {
            let mut heroes: Array<Hero::Hero> = Default::default();
            let heroesList = self.heroes.read(accountAdrs);
            let mut i: u32 = 0;
            loop {
                if i == heroesIds.len() {
                    break;
                }
                assert(heroesList.len() > *heroesIds[i], 'heroId out of range');
                heroes.append(heroesList.get(*heroesIds[i]).unwrap());
                i += 1;
            };
            return heroes;
        }
        fn getAllHeroes(self: @ContractState, accountAdrs: ContractAddress) -> Array<Hero::Hero> {
            let heroesList = self.heroes.read(accountAdrs);
            return heroesList.array();
        }
    }
    use game::Components::Hero::Rune::{RuneStatistic, RuneRarity, RuneType};
    #[generate_trait]
    impl InternalSkillFactoryImpl of InternalSkillFactoryTrait {
        fn mintStarterHeroes(ref self: ContractState, accountAdrs: ContractAddress) {
            let mut heroesList = self.heroes.read(accountAdrs);
            heroesList.append(Hero::new(heroesList.len(), 'priest', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'priest', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'assassin', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'assassin', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'knight', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'knight', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'hunter', 1, 1));
            heroesList.append(Hero::new(heroesList.len(), 'hunter', 1, 1));
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'priest');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'priest');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'assassin');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'assassin');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'knight');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'knight');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'hunter');
            self.IEventEmitterDispatch.read().heroMinted(accountAdrs, heroesList.len() - 1, 'hunter');
        }
        fn mintStarterRunes(ref self: ContractState, accountAdrs: ContractAddress) {
            let mut runesList = self.runes.read(accountAdrs);
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Attack, false, RuneRarity::Common, RuneType::First));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Attack, true, RuneRarity::Common, RuneType::Second));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Attack, false, RuneRarity::Common, RuneType::Third));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Defense, false, RuneRarity::Common, RuneType::Third));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Defense, true, RuneRarity::Common, RuneType::Fourth));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Defense, true, RuneRarity::Common, RuneType::Sixth));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Health, false, RuneRarity::Common, RuneType::Fifth));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Health, true, RuneRarity::Common, RuneType::Fifth));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Health, true, RuneRarity::Common, RuneType::Second));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Speed, false, RuneRarity::Common, RuneType::Sixth));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Speed, false, RuneRarity::Common, RuneType::First));
            runesList.append(Rune::newDeterministic(runesList.len(), RuneStatistic::Speed, true, RuneRarity::Common, RuneType::Fourth));
            self.equipRune(accountAdrs, 1, 1);
            self.equipRune(accountAdrs, 2, 1);
        }
    }
}