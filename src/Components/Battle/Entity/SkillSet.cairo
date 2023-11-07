use game::Components::Battle::Entity::Skill::{Skill};

#[derive(Copy, Drop, Serde)]
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

trait SkillSetTrait {
    fn get(self: SkillSet, index: u8) -> Skill;
}

impl SkillSetImpl of SkillSetTrait {
    fn get(self: SkillSet, index: u8) -> Skill {
        assert(index < 3, 'index must be less than 3');
        if(index == 0) {
            return self.skill0;
        } else if(index == 1) {
            return self.skill1;
        } else if(index == 2) {
            return self.skill2;
        }
        return self.skill0;
    }
}