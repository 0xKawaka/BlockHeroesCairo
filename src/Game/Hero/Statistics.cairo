use debug::PrintTrait;

#[derive(Copy, Drop)]
struct Statistics {
    healt: u64,
    strength: u32,
    defense: u32,
    speed: u32,
    // statistics: Statistics,
}