#[derive(starknet::Store, Copy, Drop, Serde)]
struct SkillNameSet {
    skill0: felt252,
    skill1: felt252,
    skill2: felt252,
}

fn new(skill0: felt252, skill1: felt252, skill2: felt252) -> SkillNameSet {
    SkillNameSet {
        skill0,
        skill1,
        skill2,
    }
}