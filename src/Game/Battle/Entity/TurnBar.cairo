
#[derive(Copy, Drop)]
struct TurnBar {
    entityIndex: u32,
    speed: u64,
    turnbar: u64,
    incrementStep: u64,
    decimals: u64,
}

fn new(entityIndex: u32, speed: u64) -> TurnBar {
    TurnBar {
        entityIndex: entityIndex,
        speed: speed,
        turnbar: 0,
        incrementStep: 7,
        decimals: 100,
    }
}

trait TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar);
    fn resetTurn(ref self: TurnBar);
    fn setSpeed(ref self: TurnBar, speed: u64);
}

impl TurnBarImpl of TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar) {
        self.turnbar += self.speed * self.incrementStep;
    }

    fn resetTurn(ref self: TurnBar) {
        self.turnbar = 0;
    }

    fn setSpeed(ref self: TurnBar, speed: u64) {
        self.speed = speed;
    }

}
