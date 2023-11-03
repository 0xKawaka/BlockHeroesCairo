use starknet::ContractAddress;

#[starknet::interface]
trait IGame<TContractState> {
    fn startBattle(ref self: TContractState, heroesIds: Array<u16>, world: u16, level: u16);
    fn mintHero(ref self: TContractState);
    fn createAccount(ref self: TContractState);
    fn setAccountsAdrs(ref self: TContractState, newAccountsAdrs: ContractAddress);
    fn setEntityFactoryAdrs(ref self: TContractState, newEntityFactoryAdrs: ContractAddress);
    fn getAccountsAdrs(self: @TContractState) -> ContractAddress;
    fn getEntityFactoryAdrs(self: @TContractState) -> ContractAddress;
}
#[starknet::contract]
mod Game {
    use core::array::ArrayTrait;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use debug::PrintTrait;

    use super::super::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
    use super::super::EntityFactory::{IEntityFactoryDispatcher, IEntityFactoryDispatcherTrait};
    use super::super::super::Components::Account::{Account, AccountImpl};
    use super::super::super::Libraries::NullableVector::{NullableVector, NullableVectorImpl, VecTrait};
    use super::super::super::Components::Hero::{Hero, HeroImpl, HeroTrait};
    use super::super::super::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy};

    #[storage]
    struct Storage {
        accountsAdrs: ContractAddress,
        entityFactoryAdrs: ContractAddress,
    }

    #[external(v0)]
    impl GameImpl of super::IGame<ContractState> {
        fn startBattle(ref self: ContractState, heroesIds: Array<u16>, world: u16, level: u16) {
            let allyHeroes = IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.getHeroes(get_caller_address(), heroesIds);
            let allyEntities = IEntityFactoryDispatcher { contract_address: self.entityFactoryAdrs.read()}.newEntities(0, allyHeroes, AllyOrEnemy::Ally);
            
        }
        fn mintHero(ref self: ContractState) {
            IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.addHero(get_caller_address(), 'priest', 1, 1);
        }
        fn createAccount(ref self: ContractState) {
            IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.createAccount(get_caller_address());
        }
        fn setAccountsAdrs(ref self: ContractState, newAccountsAdrs: ContractAddress) {
            self.accountsAdrs.write(newAccountsAdrs);
        }
        fn setEntityFactoryAdrs(ref self: ContractState, newEntityFactoryAdrs: ContractAddress) {
            self.entityFactoryAdrs.write(newEntityFactoryAdrs);
        }
        fn getAccountsAdrs(self: @ContractState) -> ContractAddress {
            return self.accountsAdrs.read();
        }
        fn getEntityFactoryAdrs(self: @ContractState) -> ContractAddress {
            return self.entityFactoryAdrs.read();
        }
    }
}