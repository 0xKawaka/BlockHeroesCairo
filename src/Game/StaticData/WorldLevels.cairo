use super::super::Hero;
use core::array::ArrayTrait;

#[derive(Drop)]
struct BattleInfos {
    monsters: Array<Hero::Hero>,
    energyCost: u32,
}

fn new(monsters: Array<Hero::Hero>, energyCost: u32) -> BattleInfos {
    BattleInfos { monsters: monsters, energyCost: energyCost, }
}

fn createWorldLevels() -> Array<Array<BattleInfos>> {
    let mut worldLevels: Array<Array<BattleInfos>> = Default::default();

    // -------- World 0 ---------
    let mut firstWorldLevels: Array<BattleInfos> = Default::default();

    // Level 0
    let mut monstersArray: Array<Hero::Hero> = Default::default();
    monstersArray.append(Hero::new('knight', 1, 1));
    firstWorldLevels.append(new(monstersArray, 1));

    // Level 1
    let mut monstersArray: Array<Hero::Hero> = Default::default();
    monstersArray.append(Hero::new('priest', 1, 1));
    monstersArray.append(Hero::new('priest', 1, 1));
    firstWorldLevels.append(new(monstersArray, 2));

    worldLevels.append(firstWorldLevels);

    // -------- World 1 ---------
    let mut secondWorldLevels: Array<BattleInfos> = Default::default();

    // Level 0
    let mut monstersArray: Array<Hero::Hero> = Default::default();
    monstersArray.append(Hero::new('knight', 2, 2));
    secondWorldLevels.append(new(monstersArray, 3));

    // Level 1
    let mut monstersArray: Array<Hero::Hero> = Default::default();
    monstersArray.append(Hero::new('priest', 2, 2));
    monstersArray.append(Hero::new('priest', 2, 2));
    secondWorldLevels.append(new(monstersArray, 4));

    worldLevels.append(secondWorldLevels);

    // -------- World 2 ---------

    return worldLevels;
}
// const battlesByWorldsDict = {
//   "world1": 
//   [
//     {
//       background: "battle1",
//       monsterNames: ["Hunter", "Hunter", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//     {
//       background: "battle1",
//       monsterNames: ["Priest", "Priest", "Priest", "Priest"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//     {
//       background: "battle1",
//       monsterNames: ["Priest", "Knight", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 2,
//     },
//     {
//       background: "battle1",
//       monsterNames: ["Assassin", "Knight", "Priest", "Assassin"],
//       monsterLevels: [12, 11, 13, 12],
//       energyCost: 3,
//     }
//   ],
//   "world2": 
//   [
//     {
//       background: "battle1",
//       monsterNames: ["Hunter", "Hunter", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//     {
//       background: "battle1",
//       monsterNames: ["Knight", "Knight", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//   ],
//   "world3": 
//   [
//     {
//       background: "battle1",
//       monsterNames: ["Hunter", "Hunter", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//     {
//       background: "battle1",
//       monsterNames: ["Knight", "Knight", "Priest", "Assassin"],
//       monsterLevels: [10, 11, 10, 12],
//       energyCost: 1,
//     },
//   ]
// };

// function getAllBattlesMontsersInfos() {
//   let battlesMontsersInfos = {};
//   for (let world in battlesByWorldsDict) {
//     battlesMontsersInfos[world] = [];
//     battlesByWorldsDict[world].forEach((battle, i) => {
//       let enemies = {names: [], levels: []};
//       battle.monsterNames.forEach((monsterName, index) => {
//         enemies.names.push(monsterName)
//         enemies.levels.push(battle.monsterLevels[index])
//       })
//       battlesMontsersInfos[world][i] = {enemies: enemies, energyCost: battle.energyCost};
//     })
//   }
//   return battlesMontsersInfos;
// }

// function getAllBattlesMontsersInfosWithStats() {
//   let battlesMontsersInfos = {};
//   for (let world in battlesByWorldsDict) {
//     battlesMontsersInfos[world] = [];
//     battlesByWorldsDict[world].forEach((battle, i) => {
//       let enemies = {names: [], levels: [], statistics: []};
//       battle.monsterNames.forEach((monsterName, index) => {
//         enemies.names.push(monsterName)
//         enemies.levels.push(battle.monsterLevels[index])
//         enemies.statistics.push(baseStatsDict[monsterName]);
//       })
//       battlesMontsersInfos[world][i] = {enemies: enemies, energyCost: battle.energyCost};
//     })
//   }
//   return battlesMontsersInfos;
// }

// function getBattleMonstersInfos(world, battleIndex){
//   let monstersInfos = {};
//   monstersInfos.names = battlesByWorldsDict[world][battleIndex].monsterNames;
//   monstersInfos.levels = battlesByWorldsDict[world][battleIndex].monsterLevels;
//   monstersInfos.statistics = [];
//   for(let i=0; i<battlesByWorldsDict[world][battleIndex].monsterNames.length; i++){
//     monstersInfos.statistics.push(baseStatsDict[battlesByWorldsDict[world][battleIndex].monsterNames[i]]);
//   }
//   monstersInfos.skills = [];
//   for(let i=0; i<battlesByWorldsDict[world][battleIndex].monsterNames.length; i++){
//     let skills = [];
//     const skillset = skillsetByName[battlesByWorldsDict[world][battleIndex].monsterNames[i]];
//     for(let j=0; j<skillset.length; j++){
//       skills.push(skillsDict[skillset[j]]);
//     }
//     monstersInfos.skills.push(skills);
//   }
//   // console.log(monstersInfos);
//   return monstersInfos;
// }

// module.exports = {getAllBattlesMontsersInfos, getBattleMonstersInfos, getAllBattlesMontsersInfosWithStats} 

