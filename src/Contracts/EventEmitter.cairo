use starknet::ContractAddress;
use game::Components::Battle::Entity::{Entity};
use game::Components::Hero::{Rune};

use game::Contracts::EventEmitter::EventEmitter::{IdAndValueEvent, BuffEvent, TurnBarEvent, EntityBuffEvent};

#[derive(Destruct, Serde)]
struct SkillEventParams {
    casterId: u32,
    targetId: u32,
    skillIndex: u8,
    damages: Array<IdAndValueEvent>,
    heals: Array<IdAndValueEvent>,
}

#[starknet::interface]
trait IEventEmitter<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, healthsArray: Array<u64>);
    fn skill(ref self: TContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<IdAndValueEvent>, heals: Array<IdAndValueEvent>, buffs: Array<BuffEvent>, status: Array<BuffEvent>, speeds: Array<IdAndValueEvent>, deaths: Array<u32>); 
    fn startTurn(ref self: TContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>, buffs: Array<EntityBuffEvent>, status: Array<EntityBuffEvent>, isDead: bool);
    fn endBattle(ref self: TContractState, owner: ContractAddress);
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
        StartTurn: StartTurn,
        EndBattle: EndBattle,

        NewAccount: NewAccount,
        HeroMinted: HeroMinted,
        RuneMinted: RuneMinted,
    }

    #[derive(Drop, starknet::Event)]
    struct NewBattle {
        owner: ContractAddress,
        healthsArray: Array<u64>,
    }
    #[derive(Drop, Copy, Serde)]
    struct BuffEvent {
        entityId: u32,
        name: felt252,
        duration: u8,
    }
    #[derive(Drop, Copy, Serde)]
    struct IdAndValueEvent {
        entityId: u32,
        value: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct Skill {
        owner: ContractAddress,
        casterId: u32,
        targetId: u32,
        skillIndex: u8,
        damages: Array<IdAndValueEvent>,
        heals: Array<IdAndValueEvent>,
        buffs: Array<BuffEvent>,
        status: Array<BuffEvent>,
        speeds: Array<IdAndValueEvent>,
        deaths: Array<u32>,
    }

    #[derive(Drop, Copy, Serde)]
    struct TurnBarEvent {
        entityId: u32,
        value: u64,
    }

    #[derive(Drop, Copy, Serde)]
    struct EntityBuffEvent {
        name: felt252,
        duration: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct StartTurn {
        owner: ContractAddress,
        entityId: u32,
        damages: Array<u64>,
        heals: Array<u64>,
        buffs: Array<EntityBuffEvent>,
        status: Array<EntityBuffEvent>,
        isDead: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct EndBattle {
        owner: ContractAddress,
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


        fn newBattle(ref self: ContractState, owner: ContractAddress, healthsArray: Array<u64>) {
            self.emit(NewBattle {
                owner: owner,
                healthsArray: healthsArray,
            });
        }

        fn skill(ref self: ContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<IdAndValueEvent>, heals: Array<IdAndValueEvent>, buffs: Array<BuffEvent>, status: Array<BuffEvent>, speeds: Array<IdAndValueEvent>,  deaths: Array<u32>) {
            self.emit(Skill {
                owner: owner,
                casterId: casterId,
                targetId: targetId,
                skillIndex: skillIndex,
                damages: damages,
                heals: heals,
                buffs: buffs,
                status: status,
                speeds: speeds,
                deaths: deaths
            });
        }

        fn startTurn(ref self: ContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>, buffs: Array<EntityBuffEvent>, status: Array<EntityBuffEvent>, isDead: bool) {
            self.emit(StartTurn {
                owner: owner,
                entityId: entityId,
                damages: damages,
                heals: heals,
                buffs: buffs,
                status: status,
                isDead: isDead,
            });
        }

        fn endBattle(ref self: ContractState, owner: ContractAddress) {
            self.emit(EndBattle {
                owner: owner,
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