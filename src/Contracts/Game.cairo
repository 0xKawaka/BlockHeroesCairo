use starknet::ContractAddress;

#[starknet::interface]
trait IGame<TContractState> {
    fn startBattle(ref self: TContractState, heroesIds: Array<u32>, world: u16, level: u16);
    fn mintHero(ref self: TContractState);
    fn createAccount(ref self: TContractState);
    fn setAccountsAdrs(ref self: TContractState, newAccountsAdrs: ContractAddress);
    fn setEntityFactoryAdrs(ref self: TContractState, newEntityFactoryAdrs: ContractAddress);
    fn setLevelsAdrs(ref self: TContractState, newLevelsAdrs: ContractAddress);
    fn setBattleAdrs(ref self: TContractState, newBattleAdrs: ContractAddress);
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
    use super::super::Levels::{ILevelsDispatcher, ILevelsDispatcherTrait};
    use super::super::Battles::{IBattlesDispatcher, IBattlesDispatcherTrait};
    use super::super::super::Components::Account::{Account, AccountImpl};
    use super::super::super::Libraries::NullableVector::{NullableVector, NullableVectorImpl, VecTrait};
    use super::super::super::Components::Hero::{Hero, HeroImpl, HeroTrait};
    use super::super::super::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy};

    #[storage]
    struct Storage {
        accountsAdrs: ContractAddress,
        entityFactoryAdrs: ContractAddress,
        levelsAdrs: ContractAddress,
        battlesAdrs: ContractAddress,
    }

    #[external(v0)]
    impl GameImpl of super::IGame<ContractState> {
        fn startBattle(ref self: ContractState, heroesIds: Array<u32>, world: u16, level: u16) {
            let caller = get_caller_address();
            let allyHeroes = IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.getHeroes(get_caller_address(), heroesIds);
            let allyEntities = IEntityFactoryDispatcher { contract_address: self.entityFactoryAdrs.read()}.newEntities(0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroes = ILevelsDispatcher { contract_address: self.levelsAdrs.read()}.getEnemies(world, level);
            let enemyEntities = IEntityFactoryDispatcher { contract_address: self.entityFactoryAdrs.read()}.newEntities(allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            IBattlesDispatcher { contract_address: self.battlesAdrs.read()}.newBattle(caller, allyEntities, enemyEntities);
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
        fn setLevelsAdrs(ref self: ContractState, newLevelsAdrs: ContractAddress) {
            self.levelsAdrs.write(newLevelsAdrs);
        }
        fn setBattleAdrs(ref self: ContractState, newBattleAdrs: ContractAddress) {
            self.battlesAdrs.write(newBattleAdrs);
        }
        fn getAccountsAdrs(self: @ContractState) -> ContractAddress {
            return self.accountsAdrs.read();
        }
        fn getEntityFactoryAdrs(self: @ContractState) -> ContractAddress {
            return self.entityFactoryAdrs.read();
        }
    }
}