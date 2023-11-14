use starknet::ContractAddress;
use game::Components::Battle::Entity::{Entity};
use game::Components::Hero::{Rune};

use  game::Contracts::EventEmitter::EventEmitter::{DamageOrHealEvent, BuffEvent, TurnBarEvent};

#[starknet::interface]
trait IEventEmitter<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, allies: Span<Entity>, enemies: Span<Entity>);
    fn skill(ref self: TContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<DamageOrHealEvent>, heals: Array<DamageOrHealEvent>, buffs: Array<BuffEvent>, status: Array<BuffEvent>); 
    fn healthOnTurnProcs(ref self: TContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>, turnBars: Array<TurnBarEvent>);
    fn death(ref self: TContractState, owner: ContractAddress, entityId: u32);
    fn newAccount(ref self: TContractState, owner: ContractAddress, username: felt252);
    fn heroMinted(ref self: TContractState, owner: ContractAddress, id: u32, name: felt252);
    fn runeMinted(ref self: TContractState, owner: ContractAddress, rune: Rune::Rune);
}
#[starknet::contract]
mod EventEmitter {
    use starknet::ContractAddress;
    use game::Components::Battle::Entity::{Entity};
    use game::Components::Hero::{Rune};

    use debug::PrintTrait;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NewBattle: NewBattle,
        Skill: Skill,
        HealthOnTurnProcs: HealthOnTurnProcs,
        Death: Death,

        NewAccount: NewAccount,
        HeroMinted: HeroMinted,
        RuneMinted: RuneMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct NewBattle {
        owner: ContractAddress,
        allies: Span<Entity>,
        enemies: Span<Entity>,
    }
    #[derive(Drop, Copy, Serde)]
    struct BuffEvent {
        entityId: u32,
        name: felt252,
        duration: u8,
    }
    #[derive(Drop, Copy, Serde)]
    struct DamageOrHealEvent {
        entityId: u32,
        value: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct Skill {
        owner: ContractAddress,
        casterId: u32,
        targetId: u32,
        skillIndex: u8,
        damages: Array<DamageOrHealEvent>,
        heals: Array<DamageOrHealEvent>,
        buffs: Array<BuffEvent>,
        status: Array<BuffEvent>,
    }

    #[derive(Drop, Copy, Serde)]
    struct TurnBarEvent {
        entityId: u32,
        value: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct HealthOnTurnProcs {
        owner: ContractAddress,
        entityId: u32,
        damages: Array<u64>,
        heals: Array<u64>,
        turnBars: Array<TurnBarEvent>,
    }
    #[derive(Drop, starknet::Event)]
    struct Death {
        owner: ContractAddress,
        entityId: u32,
    }
    #[derive(Drop, starknet::Event)]
    struct NewAccount {
        owner: ContractAddress,
        username: felt252,
    }
    #[derive(Drop, starknet::Event)]
    struct HeroMinted {
        owner: ContractAddress,
        id: u32,
        name: felt252,
    }
    #[derive(Drop, starknet::Event)]
    struct RuneMinted {
        owner: ContractAddress,
        rune: Rune::Rune,
    }

    #[external(v0)]
    impl BattlesImpl of super::IEventEmitter<ContractState> {

        fn newBattle(ref self: ContractState, owner: ContractAddress, allies: Span<Entity>, enemies: Span<Entity>) {
            self.emit(NewBattle {
                owner: owner,
                allies: allies,
                enemies: enemies,
            });
        }

        fn skill(ref self: ContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<DamageOrHealEvent>, heals: Array<DamageOrHealEvent>, buffs: Array<BuffEvent>, status: Array<BuffEvent>) {
            self.emit(Skill {
                owner: owner,
                casterId: casterId,
                targetId: targetId,
                skillIndex: skillIndex,
                damages: damages,
                heals: heals,
                buffs: buffs,
                status: status,
            });
        }

        fn healthOnTurnProcs(ref self: ContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>, turnBars: Array<TurnBarEvent>) {
            self.emit(HealthOnTurnProcs {
                owner: owner,
                entityId: entityId,
                damages: damages,
                heals: heals,
                turnBars: turnBars,
            });
        }

        fn death(ref self: ContractState, owner: ContractAddress, entityId: u32) {
            self.emit(Death {
                owner: owner,
                entityId: entityId,
            });
        }

        fn newAccount(ref self: ContractState, owner: ContractAddress, username: felt252) {
            self.emit(NewAccount {
                owner: owner,
                username: username,
            });
        }

        fn heroMinted(ref self: ContractState, owner: ContractAddress, id: u32, name: felt252) {
            self.emit(HeroMinted {
                owner: owner,
                id: id,
                name: name,
            });
        }

        fn runeMinted(ref self: ContractState, owner: ContractAddress, rune: Rune::Rune) {
            self.emit(RuneMinted {
                owner: owner,
                rune: rune,
            });
        }
    }
}