use debug::PrintTrait;

#[derive(starknet::Store, Copy, Drop, Serde)]
struct TurnBar {
    entityIndex: u32,
    speed: u64,
    turnbar: u64,
    incrementStep: u64,
    decimals: u64,
}

fn new(entityIndex: u32, speed: u64) -> TurnBar {
    TurnBar { entityIndex: entityIndex, speed: speed, turnbar: 0, incrementStep: 7, decimals: 10, }
}

trait TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar);
    fn isFull(self: TurnBar) -> bool;
    fn resetTurn(ref self: TurnBar);
    fn setSpeed(ref self: TurnBar, speed: u64);
    fn getSpeed(self: TurnBar) -> u64;
}

impl TurnBarImpl of TurnBarTrait {
    fn incrementTurnbar(ref self: TurnBar) {
        self.turnbar += (self.speed * self.incrementStep) / self.decimals;
    // self.turnbar.print();
    }
    fn isFull(self: TurnBar) -> bool {
        self.turnbar > 999
    }
    fn resetTurn(ref self: TurnBar) {
        self.turnbar = 0;
    }
    fn setSpeed(ref self: TurnBar, speed: u64) {
        self.speed = speed;
    }
    fn getSpeed(self: TurnBar) -> u64 {
        self.speed
    }
}
