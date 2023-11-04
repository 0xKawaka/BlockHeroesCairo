use game::Components::Battle::Entity::EntityTrait;
use debug::PrintTrait;

use game::Components::Battle::Entity::{EntityImpl, Entity};

#[derive(starknet::Store, Copy, Drop, Serde)]
struct StunOnTurnProc {
    duration: u8,
    stunned: bool,
}

fn new(duration: u8) -> StunOnTurnProc {
    StunOnTurnProc {
        duration: duration,
        stunned: false,
    }
}

trait StunOnTurnProcTrait {
    fn proc(ref self: StunOnTurnProc);
    fn setStunned(ref self: StunOnTurnProc, duration: u8);
    fn isStunned(ref self: StunOnTurnProc) -> bool;
    fn updateStunned(ref self: StunOnTurnProc);
}

impl StunOnTurnProcImpl of StunOnTurnProcTrait {
    fn proc(ref self: StunOnTurnProc) {
        if self.duration > 0 {
            self.duration -= 1;
            if self.duration == 0 {
                self.stunned = false;
            }
        }
    }

    fn setStunned(ref self: StunOnTurnProc, duration: u8) {
        if self.duration < duration {
            self.duration = duration;
            self.stunned = true;
        }
    }

    fn isStunned(ref self: StunOnTurnProc) -> bool {
        return self.stunned;
    }

    fn updateStunned(ref self: StunOnTurnProc) {
        if self.duration > 0 {
            self.stunned = true;
        } else {
            self.stunned = false;
        }
    }
}
