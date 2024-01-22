use starknet::ContractAddress;

#[starknet::interface]
trait IPvp<TContractState> {
    fn initPvp(ref self: TContractState, owner: ContractAddress, heroeIds: Array<u32>);
    fn setTeam(ref self: TContractState, owner: ContractAddress, heroeIds: Array<u32>);
    fn getTeam(self: @TContractState, owner: ContractAddress) -> Array<u32>;
    fn swapRanks(ref self: TContractState, winner: ContractAddress, looser: ContractAddress);
    fn setEnemyRangesByRank(ref self: TContractState, minRank: Array<u64>, range: Array<u64>);
    fn setGemsRewards(ref self: TContractState, minRank: Array<u64>, gems: Array<u32>);
    fn getGemsReward(self: @TContractState, owner: ContractAddress) -> u32;
    fn isEnemyInRange(self: @TContractState, owner: ContractAddress, enemyOwner: ContractAddress) -> bool;
    fn getRank(self: @TContractState, owner: ContractAddress) -> u64;
}

#[starknet::contract]
mod Pvp {
    use game::Contracts::Accounts::{IAccountsDispatcher, IAccountsDispatcherTrait};
    use game::Contracts::Pvp::IPvp;
    use game::Libraries::List::{List, ListTrait};
    use starknet::ContractAddress;
    use debug::PrintTrait;

    #[storage]
    struct Storage {
        ranking: LegacyMap<ContractAddress, u64>,
        teams: LegacyMap<ContractAddress, List<u32>>,
        currentRankIndex: u64,
        enemyRangesByRank: LegacyMap<u32, (u64, u64)>, // index, (minRank, range) has to be sorted by minRank
        enemyRangesByRankLength: u32,

        gemsRewards: LegacyMap<u32, (u64, u32)>, // index, (minRank, gems) has to be sorted by minRank
        gemsRewardsLength: u32,

        lastClaimedRewards: LegacyMap<ContractAddress, u64>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.currentRankIndex.write(1);
    }

    #[external(v0)]
    impl PvpImpl of super::IPvp<ContractState> {
        fn initPvp(ref self: ContractState, owner: ContractAddress, heroeIds: Array<u32>) {
            let currentRankIndex = self.currentRankIndex.read();
            self.ranking.write(owner, currentRankIndex);
            self.currentRankIndex.write(currentRankIndex + 1);
            self.setTeam(owner, heroeIds);
        }

        fn setTeam(ref self: ContractState, owner: ContractAddress, heroeIds: Array<u32>) {
            let mut team = self.teams.read(owner);
            team.clean();
            let mut i: u32 = 0;
            loop {
                if i >= heroeIds.len() {
                    break;
                }
                team.append(*heroeIds[i]);
                i += 1;
            };
            self.teams.write(owner, team);
        }

        fn getTeam(self: @ContractState, owner: ContractAddress) -> Array<u32> {
            self.teams.read(owner).array()
        }

        fn swapRanks(ref self: ContractState, winner: ContractAddress, looser: ContractAddress) {
            let winnerRank = self.ranking.read(winner);
            let looserRank = self.ranking.read(looser);
            self.ranking.write(winner, looserRank);
            self.ranking.write(looser, winnerRank);
        }

        fn setEnemyRangesByRank(ref self: ContractState, minRank: Array<u64>, range: Array<u64>) {
            let mut i: u32 = 0;
            loop {
                if i >= minRank.len() {
                    break;
                }
                self.enemyRangesByRank.write(i, (*minRank[i], *range[i]));
                i += 1;
            };
            self.enemyRangesByRankLength.write(i);
        }

        fn setGemsRewards(ref self: ContractState, minRank: Array<u64>, gems: Array<u32>) {
            let mut i: u32 = 0;
            loop {
                if i >= minRank.len() {
                    break;
                }
                self.gemsRewards.write(i, (*minRank[i], *gems[i]));
                i += 1;
            };
            self.gemsRewardsLength.write(i);
        }

        fn getGemsReward(self: @ContractState, owner: ContractAddress) -> u32 {
            let ownerRank = self.ranking.read(owner);
            let mut i: u32 = 0;
            let mut res = 0;
            loop {
                if i >= self.gemsRewardsLength.read() {
                    break;
                }
                let (minRank, gems) = self.gemsRewards.read(i);

                if ownerRank <= minRank {
                    res = gems;
                    break;
                }
                i += 1;
            };
            res
        }

        fn isEnemyInRange(self: @ContractState, owner: ContractAddress, enemyOwner: ContractAddress) -> bool {
            let enemyRank = self.ranking.read(enemyOwner);
            let ownerRank = self.ranking.read(owner);
            assert(ownerRank > enemyRank, 'ownerRank <= enemyRank');
            let mut i: u32 = 0;
            let mut res = false;
            loop {
                if i >= self.enemyRangesByRankLength.read() {
                    break;
                }
                let (minRank, range) = self.enemyRangesByRank.read(i);

                if ownerRank <= minRank {
                    if enemyRank + range >= ownerRank {
                        res = true;
                    }
                    break;
                }
                i += 1;
            };
            res
        }

        fn getRank(self: @ContractState, owner: ContractAddress) -> u64 {
            self.ranking.read(owner)
        }


    }

}