#[derive(Copy, Drop)]
struct StatModifier {
    value: u64,
    duration: u8,
}

fn new(value: u64, duration: u8) -> StatModifier {
    StatModifier {
        value,
        duration,
    }
}

trait StatModifierTrait {
    fn reduceDuration(self: StatModifier) -> ();
    fn reset(self: StatModifier) -> ();
    fn set(self: StatModifier, value: u64, duration: u8) -> ();
}

impl StatModifierImpl of StatModifierTrait {
    fn reduceDuration(mut self: StatModifier) {
        if self.duration > 0 {
            self.duration -= 1;
        }
    }
    fn reset(mut self: StatModifier) {
        self.duration = 0;
        self.value = 0;
    }
    fn set(mut self: StatModifier, value: u64, duration: u8) {
        self.value = value;
        self.duration = duration;
    }
}

