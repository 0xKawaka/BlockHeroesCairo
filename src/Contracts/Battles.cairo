#[starknet::interface]
trait IBattles<TContractState> {
}

#[starknet::contract]
mod Battles {
    use starknet::ContractAddress;
    use super::super::super::Components::Battle::{Battle, BattleImpl};
    use super::super::super::Libraries::List::{List, ListTrait};
    use super::super::super::Components::Battle::Entity::{Entity, EntityImpl, EntityTrait, AllyOrEnemy, Cooldowns::CooldownsTrait};
    use super::super::super::Components::Battle::Entity::HealthOnTurnProc::{HealthOnTurnProc, HealthOnTurnProcImpl};


    #[storage]
    struct Storage {
        battleIdCount: u64,
        entitiesCount: u16,
        battleId: LegacyMap<ContractAddress, u64>,
        entities: LegacyMap<(u64, u16), Entity>, // battleId, entityIndex
        aliveEntities: LegacyMap<u64, List<u16>>,
        deadEntities: LegacyMap<u64, List<u16>>,
        turnTimeline: LegacyMap<(u64, u16), u16>,  // (battleId, turnIndex) -> entityIndex
        alliesIndexes: LegacyMap<u64, List<u16>>,
        enemiesIndexes: LegacyMap<u64, List<u16>>,
        healthOnTurnProcsCount: LegacyMap<(u64, u16), u16>, // (battleId, entityIndex) -> healthOnTurnProcCount
        healthOnTurnProcs: LegacyMap<(u64, u16, u16), HealthOnTurnProc>, // (battleId, entityIndex, healthOnTurnProcIndex) -> HealthOnTurnProc
        isBattleOver: LegacyMap<u64, bool>,
        isWaitingForPlayerAction: LegacyMap<u64, bool>,
    }

    #[external(v0)]
    impl BattlesImpl of super::IBattles<ContractState> {
    }

}