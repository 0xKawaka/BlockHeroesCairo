use super::Skill::{Skill};

#[derive(starknet::Store, Copy, Drop, Serde)]
struct SkillSet {
    skill0: Skill,
    skill1: Skill,
    skill2: Skill,
}

fn new(skill0: Skill, skill1: Skill, skill2: Skill) -> SkillSet {
    SkillSet {
        skill0,
        skill1,
        skill2,
    }
}