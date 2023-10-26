use core::box::BoxTrait;
mod Statistics;
mod TurnBar;
mod Skill;

use Statistics::StatisticsImpl;
use Skill::SkillImpl;

use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Entity {
    index: u32,
    name: felt252,
    statistics: Statistics::Statistics,
    turnBar: TurnBar::TurnBar,
    skillSpan: Span<Skill::Skill>,
    // skill: Skill::Skill,
}

// impl ArraySkillCopy of Copy<Array<Skill::Skill>> {
//     fn copy(self: @Array<Skill::Skill>) -> Array<Skill::Skill> {
//         *self
//     }
// }

fn new(index: u32, name: felt252, health: u64, attack: u64, defense: u64, speed: u64, criticalChance: u64, criticalDamage:u64,
skillSpan: Span<Skill::Skill>) -> Entity {
    Entity {
        index: index,
        name: name,
        statistics: Statistics::new(health, attack, defense, speed, criticalChance, criticalDamage),
        turnBar: TurnBar::new(index, speed),
        skillSpan: skillSpan,
    }
}

trait EntityTrait {
    fn print(self: @Entity) -> ();
    fn printSkill(self: @Entity) -> ();
}

impl EntityImpl of EntityTrait {
    fn print(self: @Entity) {
        (*self.name).print();
        (*self.index).print();
        self.statistics.print();
        self.printSkill();
    }
    fn printSkill(self: @Entity) {
        let mut i: u32 = 0;
        loop {
            if(i > (*self.skillSpan).len() - 1) {
                break;
            }
            let skillOption = (*self.skillSpan).get(i);
            let skillBox = skillOption.unwrap();
            let skill = *skillBox.unbox();
            skill.print();
            i = i + 1;
        };
    }
}