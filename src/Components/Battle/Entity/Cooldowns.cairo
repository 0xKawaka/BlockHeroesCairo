use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct Cooldowns {
    skill1: u8,
    skill2: u8,
}

fn new() -> Cooldowns {
    Cooldowns {
        skill1: 0,
        skill2: 0,
    }
}

trait CooldownsTrait {
    fn reduceCooldowns(ref self: Cooldowns);
    fn setCooldown(ref self: Cooldowns, skillIndex: u8, cooldown: u8);
    fn isOnCooldown(self: Cooldowns, skillIndex: u8) -> bool;
}

impl CooldownsImpl of  CooldownsTrait {
    fn reduceCooldowns(ref self: Cooldowns) {
        if(self.skill1 > 0) {
            self.skill1 -= 1;
        }
        if(self.skill2 > 0) {
            self.skill2 -= 1;
        }
    }
    fn setCooldown(ref self: Cooldowns, skillIndex: u8, cooldown: u8) {
        if(skillIndex  ==  0){
            return;
        }
        if(skillIndex == 1) {
            self.skill1 = cooldown;
        }
        if(skillIndex == 2) {
            self.skill2 = cooldown;
        }
    }
    fn isOnCooldown(self: Cooldowns, skillIndex: u8) -> bool {
        if(skillIndex  ==  0){
            return false;
        }
        if(skillIndex == 1) {
            return self.skill1 > 0;
        }
        if(skillIndex == 2) {
            return self.skill2 > 0;
        }
        return true;
    }
}