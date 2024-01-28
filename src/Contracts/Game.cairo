use starknet::ContractAddress;

#[starknet::interface]
trait IGame<TContractState> {
    fn startPvpBattle(ref self: TContractState, enemyOwner: ContractAddress, heroesIds: Array<u32>);
    fn playPvpTurn(ref self: TContractState, spellIndex: u8, targetIndex: u32);
    fn startBattle(ref self: TContractState, heroesIds: Array<u32>, world: u16, level: u16);
    fn playTurn(ref self: TContractState, spellIndex: u8, targetIndex: u32);
    fn initPvp(ref self: TContractState, heroesIds: Array<u32>);
    fn setPvpTeam(ref self: TContractState, heroesIds: Array<u32>);
    fn equipRune(ref self: TContractState, runeId: u32, heroId: u32);
    fn unequipRune(ref self: TContractState, runeId: u32);
    fn upgradeRune(ref self: TContractState, runeId: u32);
    fn mintHero(ref self: TContractState);
    fn mintRune(ref self: TContractState);
    fn createAccount(ref self: TContractState, username: felt252);
    fn setIAccountsDispatch(ref self: TContractState, newAccountsAdrs: ContractAddress);
    fn setIEntityFactoryDispatch(ref self: TContractState, newEntityFactoryAdrs: ContractAddress);
    fn setILevelsDispatch(ref self: TContractState, newLevelsAdrs: ContractAddress);
    fn setIBattlesDispatch(ref self: TContractState, newBattleAdrs: ContractAddress);
    fn setIPvpDispatch(ref self: TContractState, newPvpAdrs: ContractAddress);
    fn setIArenaBattlesDispatch(ref self: TContractState, newPvpBattleAdrs: ContractAddress);
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
    use game::Contracts::Pvp::{IPvpDispatcher, IPvpDispatcherTrait};
    use game::Contracts::ArenaBattles::{IArenaBattlesDispatcher, IArenaBattlesDispatcherTrait};
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
        IPvpDispatch: IPvpDispatcher,
        IArenaBattlesDispatch: IArenaBattlesDispatcher,
    }

    #[external(v0)]
    impl GameImpl of super::IGame<ContractState> {
        fn startPvpBattle(ref self: ContractState, enemyOwner: ContractAddress, heroesIds: Array<u32>) {
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            let caller = get_caller_address();
            self.IPvpDispatch.read().isEnemyInRange(caller, enemyOwner);
            self.IAccountsDispatch.read().decreasePvpEnergy(caller, 1);
            let allyHeroes = self.IAccountsDispatch.read().getHeroes(get_caller_address(), heroesIds.span());
            let allyEntities = self.IEntityFactoryDispatch.read().newEntities(get_caller_address(), 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroesIndex = self.IPvpDispatch.read().getTeam(enemyOwner);
            let enemyHeroes = self.IAccountsDispatch.read().getHeroes(enemyOwner, enemyHeroesIndex.span());
            let enemyEntities = self.IEntityFactoryDispatch.read().newEntities(enemyOwner, allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            self.IArenaBattlesDispatch.read().newBattle(caller, enemyOwner, allyEntities, enemyEntities, heroesIds);
        }
        fn playPvpTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            self.IArenaBattlesDispatch.read().playTurn(get_caller_address(), spellIndex, targetIndex);
        }
        fn startBattle(ref self: ContractState, heroesIds: Array<u32>, world: u16, level: u16) {
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            let caller = get_caller_address();
            let energyCost = self.ILevelsDispatch.read().getEnergyCost(world, level);
            self.IAccountsDispatch.read().decreaseEnergy(caller, energyCost);
            let allyHeroes = self.IAccountsDispatch.read().getHeroes(get_caller_address(), heroesIds.span());
            let allyEntities = self.IEntityFactoryDispatch.read().newEntities(get_caller_address(), 0, allyHeroes, AllyOrEnemy::Ally);
            let enemyHeroes = self.ILevelsDispatch.read().getEnemies(world, level);
            let enemyEntities = self.IEntityFactoryDispatch.read().newEntities(get_caller_address(), allyEntities.len(), enemyHeroes, AllyOrEnemy::Enemy);
            self.IBattlesDispatch.read().newBattle(caller, allyEntities, enemyEntities, heroesIds, world, level);
        }
        fn playTurn(ref self: ContractState, spellIndex: u8, targetIndex: u32) {
            self.IBattlesDispatch.read().playTurn(get_caller_address(), spellIndex, targetIndex);
        }
        fn initPvp(ref self: ContractState, heroesIds: Array<u32>) {
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            self.IAccountsDispatch.read().hasAccount(get_caller_address());
            self.IAccountsDispatch.read().isOwnerOfHeroes(get_caller_address(), heroesIds.span());
            self.IPvpDispatch.read().initPvp(get_caller_address(), heroesIds);
        }
        fn setPvpTeam(ref self: ContractState, heroesIds: Array<u32>) {
            assert(heroesIds.len() < 5 && heroesIds.len() > 0, '1 hero min, 4 heroes max');
            self.IAccountsDispatch.read().hasAccount(get_caller_address());
            self.IAccountsDispatch.read().isOwnerOfHeroes(get_caller_address(), heroesIds.span());
            self.IPvpDispatch.read().setTeam(get_caller_address(), heroesIds.span());
        }
        fn equipRune(ref self: ContractState, runeId: u32, heroId: u32) {
            self.IAccountsDispatch.read().equipRune(get_caller_address(), runeId, heroId);
        }
        fn unequipRune(ref self: ContractState, runeId: u32) {
            self.IAccountsDispatch.read().unequipRune(get_caller_address(), runeId);
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
        fn setIPvpDispatch(ref self: ContractState, newPvpAdrs: ContractAddress) {
            self.IPvpDispatch.write(IPvpDispatcher { contract_address: newPvpAdrs });
        }
        fn setIArenaBattlesDispatch(ref self: ContractState, newPvpBattleAdrs: ContractAddress) {
            self.IArenaBattlesDispatch.write(IArenaBattlesDispatcher { contract_address: newPvpBattleAdrs });
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