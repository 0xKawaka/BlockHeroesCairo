use starknet::ContractAddress;
use game::Components::Battle::Entity::{Entity};
use game::Components::Hero::{Rune};

#[starknet::interface]
trait IEventEmitter<TContractState> {
    fn newBattle(ref self: TContractState, owner: ContractAddress, allies: Span<Entity>, enemies: Span<Entity>);
    fn playingTurn(ref self: TContractState, owner: ContractAddress, entityId: u32, turnBars: Array<u64>);
    fn skillEvent(ref self: TContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<u64>, heals: Array<u64>);
    fn healthOnTurnProcsEvent(ref self: TContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>);
    fn newAccount(ref self: TContractState, owner: ContractAddress, username: felt252);
    fn heroMinted(ref self: TContractState, owner: ContractAddress, heroName: felt252);
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
        PlayingTurn: PlayingTurn,
        SkillEvent: SkillEvent,
        HealthOnTurnProcsEvent: HealthOnTurnProcsEvent,

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
    #[derive(Drop, starknet::Event)]
    struct PlayingTurn {
        owner: ContractAddress,
        entityId: u32,
        turnBars: Array<u64>,
    }
    #[derive(Drop, starknet::Event)]
    struct SkillEvent {
        owner: ContractAddress,
        casterId: u32,
        targetId: u32,
        skillIndex: u8,
        damages: Array<u64>,
        heals: Array<u64>,
    }
    #[derive(Drop, starknet::Event)]
    struct HealthOnTurnProcsEvent {
        owner: ContractAddress,
        entityId: u32,
        damages: Array<u64>,
        heals: Array<u64>,
    }

    #[derive(Drop, starknet::Event)]
    struct NewAccount {
        owner: ContractAddress,
        username: felt252,
    }
    #[derive(Drop, starknet::Event)]
    struct HeroMinted {
        owner: ContractAddress,
        heroName: felt252,
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

        fn playingTurn(ref self: ContractState, owner: ContractAddress, entityId: u32, turnBars: Array<u64>) {
            self.emit(PlayingTurn {
                owner: owner,
                entityId: entityId,
                turnBars: turnBars,
            });
        }

        fn skillEvent(ref self: ContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<u64>, heals: Array<u64>) {
            self.emit(SkillEvent {
                owner: owner,
                casterId: casterId,
                targetId: targetId,
                skillIndex: skillIndex,
                damages: damages,
                heals: heals,
            });
        }

        fn healthOnTurnProcsEvent(ref self: ContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>) {
            self.emit(HealthOnTurnProcsEvent {
                owner: owner,
                entityId: entityId,
                damages: damages,
                heals: heals,
            });
        }

        fn newAccount(ref self: ContractState, owner: ContractAddress, username: felt252) {
            self.emit(NewAccount {
                owner: owner,
                username: username,
            });
        }

        fn heroMinted(ref self: ContractState, owner: ContractAddress, heroName: felt252) {
            self.emit(HeroMinted {
                owner: owner,
                heroName: heroName,
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