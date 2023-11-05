use starknet::ContractAddress;

#[starknet::interface]
trait IGame<TContractState> {
    fn startBattle(ref self: TContractState, heroesIds: Array<u32>, world: u16, level: u16);
    fn playTurn(ref self: TContractState, spellIndex: u8, targetIndex: u32);
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

    use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
    use game::Contracts::EntityFactory::{IEntityFactoryDispatcher, IEntityFactoryDispatcherTrait};
    use game::Contracts::Levels::{ILevelsDispatcher, ILevelsDispatcherTrait};
    use game::Contracts::Battles::{IBattlesDispatcher, IBattlesDispatcherTrait};
    use game::Components::Account::{Account, AccountImpl};
    use game::Libraries::NullableVector::{NullableVector, NullableVectorImpl, VecTrait};
    use game::Components::Hero::{Hero, HeroImpl, HeroTrait};
    use game::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy};

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
        fn playTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            IBattlesDispatcher { contract_address: self.battlesAdrs.read()}.playTurn(get_caller_address(), spellIndex, targetIndex);
        }
        fn mintHero(ref self: ContractState) {
            IAccountsDispatcher { contract_address: self.accountsAdrs.read()}.addHero(get_caller_address(), 'knight', 1, 1);
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