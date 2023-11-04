use starknet::ContractAddress;
use super::super::Components::Battle::Entity::Entity;

#[starknet::interface]
trait IBattles<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, allies: Array<Entity>, enemies: Array<Entity>);
}

#[starknet::contract]
mod Battles {
    use core::box::BoxTrait;
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use core::debug::PrintTrait;
    use starknet::ContractAddress;
    use super::super::super::Components::Battle::{Battle, BattleImpl};
    use super::super::super::Libraries::List::{List, ListTrait};
    use super::super::super::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy, Cooldowns::CooldownsTrait};
    use super::super::super::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};

    #[storage]
    struct Storage {
        battles: LegacyMap<ContractAddress, Battle>
        // entities: LegacyMap<ContractAddress, List<Entity>>,
        // aliveEntities: LegacyMap<ContractAddress, List<u32>>,
        // deadEntities: LegacyMap<ContractAddress, List<u32>>,
        // turnTimeline: LegacyMap<ContractAddress, List<u32>>,
        // allies: LegacyMap<ContractAddress, List<u32>>,
        // enemies: LegacyMap<ContractAddress, List<u32>>,
        // healthOnTurnProcs: LegacyMap<(ContractAddress, u32), List<HealthOnTurnProc>>,
        // isBattleOver: LegacyMap<ContractAddress, bool>,
        // isWaitingForPlayerAction: LegacyMap<ContractAddress, bool>,
    }


    #[external(v0)]
    impl BattlesImpl of super::IBattles<ContractState> {
        fn newBattle(ref self: ContractState, owner: ContractAddress, allies: Array<Entity>, enemies: Array<Entity>) {
            let mut battle = self.battles.read(owner);
            battle.new(owner, allies, enemies);
            self.battles.write(owner, battle);
            self.battles.read(owner).isBattleOver.print();
        }
    }


}