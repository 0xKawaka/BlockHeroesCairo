use starknet::ContractAddress;

#[starknet::interface]
trait IGame<TContractState> {
    fn startBattle(ref self: TContractState, heroesIds: Array<u32>, world: u16, level: u16);
    fn playTurn(ref self: TContractState, spellIndex: u8, targetIndex: u32);
    fn equipRune(ref self: TContractState, runeId: u32, heroId: u32);
    fn upgradeRune(ref self: TContractState, runeId: u32);
    fn mintHero(ref self: TContractState);
    fn mintRune(ref self: TContractState);
    fn createAccount(ref self: TContractState, username: felt252);
    fn setIAccountsDispatch(ref self: TContractState, newAccountsAdrs: ContractAddress);
    fn setIEntityFactoryDispatch(ref self: TContractState, newEntityFactoryAdrs: ContractAddress);
    fn setILevelsDispatch(ref self: TContractState, newLevelsAdrs: ContractAddress);
    fn setIBattlesDispatch(ref self: TContractState, newBattleAdrs: ContractAddress);
    fn getAccountsAdrs(self: @TContractState) -> ContractAddress;
    fn getEntityFactoryAdrs(self: @TContractState) -> ContractAddress;
    fn getLevelsAdrs(self: @TContractState) -> ContractAddress;
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
        IAccountsDispatch: IAccountsDispatcher,
        IEntityFactoryDispatch: IEntityFactoryDispatcher,
        ILevelsDispatch: ILevelsDispatcher,
        IBattlesDispatch: IBattlesDispatcher,
    }

    #[external(v0)]
    impl GameImpl of super::IGame<ContractState> {
        fn startBattle(ref self: ContractState, heroesIds: Array<u32>, world: u16, level: u16) {
            let caller = get_caller_address();
            let allyHeroes = self.IAccountsDispatch.read().getHeroes(get_caller_address(), heroesIds);
            let allyEntities = self.IEntityFactoryDispatch.read().newEntities(get_caller_address(), 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroes = self.ILevelsDispatch.read().getEnemies(world, level);
            let enemyEntities = self.IEntityFactoryDispatch.read().newEntities(get_caller_address(), allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            self.IBattlesDispatch.read().newBattle(caller, allyEntities, enemyEntities);
        }
        fn playTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            self.IBattlesDispatch.read().playTurn(get_caller_address(), spellIndex, targetIndex);
        }
        fn equipRune(ref self: ContractState, runeId: u32, heroId: u32) {
            self.IAccountsDispatch.read().equipRune(get_caller_address(), runeId, heroId);
        }
        fn upgradeRune(ref self: ContractState, runeId: u32) {
            self.IAccountsDispatch.read().upgradeRune(get_caller_address(), runeId);
        }
        fn mintHero(ref self: ContractState) {
            self.IAccountsDispatch.read().mintHero(get_caller_address());
        }
        fn mintRune(ref self: ContractState) {
            self.IAccountsDispatch.read().mintRune(get_caller_address());
        }
        fn createAccount(ref self: ContractState, username: felt252) {
            self.IAccountsDispatch.read().createAccount( username, get_caller_address());
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'priest', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'priest', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'hunter', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'hunter', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'knight', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'knight', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'assassin', 1, 1);
            self.IAccountsDispatch.read().mintHeroAdmin( get_caller_address(), 'assassin', 1, 1);
        }
        fn setIAccountsDispatch(ref self: ContractState, newAccountsAdrs: ContractAddress) {
            self.IAccountsDispatch.write(IAccountsDispatcher { contract_address: newAccountsAdrs });
        }
        fn setIEntityFactoryDispatch(ref self: ContractState, newEntityFactoryAdrs: ContractAddress) {
            self.IEntityFactoryDispatch.write(IEntityFactoryDispatcher { contract_address: newEntityFactoryAdrs });
        }
        fn setILevelsDispatch(ref self: ContractState, newLevelsAdrs: ContractAddress) {
            self.ILevelsDispatch.write(ILevelsDispatcher { contract_address: newLevelsAdrs });
        }
        fn setIBattlesDispatch(ref self: ContractState, newBattleAdrs: ContractAddress) {
            self.IBattlesDispatch.write(IBattlesDispatcher { contract_address: newBattleAdrs });
        }
        fn getAccountsAdrs(self: @ContractState) -> ContractAddress {
            return self.IAccountsDispatch.read().contract_address;
        }
        fn getEntityFactoryAdrs(self: @ContractState) -> ContractAddress {
            return self.IEntityFactoryDispatch.read().contract_address;
        }
        fn getLevelsAdrs(self: @ContractState) -> ContractAddress {
            return self.ILevelsDispatch.read().contract_address;
        }

    }
}