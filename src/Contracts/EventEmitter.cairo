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
    fn skill(ref self: TContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<IdAndValueEvent>, heals: Array<IdAndValueEvent>, deaths: Array<u32>); 
    fn startTurn(ref self: TContractState, owner: ContractAddress, entityId: u32, damages: Array<u64>, heals: Array<u64>, buffs: Array<EntityBuffEvent>, status: Array<EntityBuffEvent>, isDead: bool);
    fn endTurn(ref self: TContractState, owner: ContractAddress, buffs: Array<BuffEvent>, status: Array<BuffEvent>, speeds: Array<IdAndValueEvent>);
    fn endBattle(ref self: TContractState, owner: ContractAddress, playerHasWon: bool);
    fn loot(ref self: TContractState, owner: ContractAddress, crystals: u32);
    fn experienceGain(ref self: TContractState, owner: ContractAddress, entityId: u32, experienceGained: u32,  levelAfter: u16, experienceAfter: u32);
    fn newAccount(ref self: TContractState, owner: ContractAddress, username: felt252);
    fn heroMinted(ref self: TContractState, owner: ContractAddress, id: u32, name: felt252);
    fn runeMinted(ref self: TContractState, owner: ContractAddress, rune: Rune::Rune);
    fn runeUpgraded(ref self: TContractState, owner: ContractAddress, id: u32, rank: u32, crystalCost: u32);
    fn runeBonus(ref self: TContractState, owner: ContractAddress, id: u32, rank: u32, procStat: felt252, isPercent: bool);
    fn arenaDefense(ref self: TContractState, owner: ContractAddress, heroeIds: Span<u32>);
    fn rankChange(ref self: TContractState, owner: ContractAddress, rank: u64);
    fn initArena(ref self: TContractState, owner: ContractAddress, rank: u64, heroeIds: Span<u32>);
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
        EndTurn: EndTurn,
        EndBattle: EndBattle,

        Loot: Loot,
        ExperienceGain: ExperienceGain,

        NewAccount: NewAccount,
        HeroMinted: HeroMinted,

        RuneMinted: RuneMinted,
        RuneUpgraded: RuneUpgraded,
        RuneBonus: RuneBonus,

        ArenaDefense: ArenaDefense,
        RankChange: RankChange,
        InitArena: InitArena,
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
        deaths: Array<u32>,
    }

    #[derive(Drop, starknet::Event)]
    struct EndTurn {
        owner: ContractAddress,
        buffs: Array<BuffEvent>,
        status: Array<BuffEvent>,
        speeds: Array<IdAndValueEvent>,
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
        playerHasWon: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct Loot {
        owner: ContractAddress,
        crystals: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct ExperienceGain {
        owner: ContractAddress,
        entityId: u32,
        experienceGained: u32,
        levelAfter: u16,
        experienceAfter: u32,
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
    #[derive(Drop, starknet::Event)]
    struct RuneUpgraded {
        owner: ContractAddress,
        id: u32,
        rank: u32,
        crystalCost: u32,
    }
    #[derive(Drop, starknet::Event)]
    struct RuneBonus {
        owner: ContractAddress,
        id: u32,
        rank: u32,
        procStat: felt252,
        isPercent: bool,
    }
    #[derive(Drop, starknet::Event)]
    struct ArenaDefense {
        owner: ContractAddress,
        heroeIds: Span<u32>,
    }
    #[derive(Drop, starknet::Event)]
    struct RankChange {
        owner: ContractAddress,
        rank: u64,
    }
    #[derive(Drop, starknet::Event)]
    struct InitArena {
        owner: ContractAddress,
        rank: u64,
        heroeIds: Span<u32>,
    }

    #[external(v0)]
    impl BattlesImpl of super::IEventEmitter<ContractState> {
        fn newBattle(ref self: ContractState, owner: ContractAddress, healthsArray: Array<u64>) {
            self.emit(NewBattle {
                owner: owner,
                healthsArray: healthsArray,
            });
        }
        fn skill(ref self: ContractState, owner: ContractAddress, casterId: u32, targetId: u32, skillIndex: u8, damages: Array<IdAndValueEvent>, heals: Array<IdAndValueEvent>, deaths: Array<u32>) {
            self.emit(Skill {
                owner: owner,
                casterId: casterId,
                targetId: targetId,
                skillIndex: skillIndex,
                damages: damages,
                heals: heals,
                deaths: deaths
            });
        }
        fn endTurn(ref self: ContractState, owner: ContractAddress, buffs: Array<BuffEvent>, status: Array<BuffEvent>, speeds: Array<IdAndValueEvent>) {
            self.emit(EndTurn {
                owner: owner,
                buffs: buffs,
                status: status,
                speeds: speeds,
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
        fn endBattle(ref self: ContractState, owner: ContractAddress, playerHasWon: bool) {
            self.emit(EndBattle {
                owner: owner,
                playerHasWon: playerHasWon,
            });
        }
        fn loot(ref self: ContractState, owner: ContractAddress, crystals: u32) {
            self.emit(Loot {
                owner: owner,
                crystals: crystals,
            });
        }
        fn experienceGain(ref self: ContractState, owner: ContractAddress, entityId: u32, experienceGained: u32, levelAfter: u16, experienceAfter: u32 ) {
            self.emit(ExperienceGain {
                owner: owner,
                entityId: entityId,
                experienceGained: experienceGained,
                levelAfter: levelAfter,
                experienceAfter: experienceAfter,
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
        fn runeUpgraded(ref self: ContractState, owner: ContractAddress, id: u32, rank: u32, crystalCost: u32) {
            self.emit(RuneUpgraded {
                owner: owner,
                id: id,
                rank: rank,
                crystalCost: crystalCost,
            });
        }
        fn runeBonus(ref self: ContractState, owner: ContractAddress, id: u32, rank: u32, procStat: felt252, isPercent: bool) {
            self.emit(RuneBonus {
                owner: owner,
                id: id,
                rank: rank,
                procStat: procStat,
                isPercent: isPercent,
            });
        }
        fn arenaDefense(ref self: ContractState, owner: ContractAddress, heroeIds: Span<u32>) {
            self.emit(ArenaDefense {
                owner: owner,
                heroeIds: heroeIds,
            });
        }
        fn rankChange(ref self: ContractState, owner: ContractAddress, rank: u64) {
            self.emit(RankChange {
                owner: owner,
                rank: rank,
            });
        }
        fn initArena(ref self: ContractState, owner: ContractAddress, rank: u64, heroeIds: Span<u32>) {
            self.emit(InitArena {
                owner: owner,
                rank: rank,
                heroeIds: heroeIds,
            });
        }
    }
}