use core::option::OptionTrait;
use core::traits::Into;
use debug::PrintTrait;
fn rand32(seed: u64, max: u32) -> u32 {
    let multiply: u128 = 1103515245;
    let add: u128 = 12345;
    let next = (seed.into() * multiply) + add;
    let rdm128 =  (next/65536) % max.into();
    let rdm: u32 = rdm128.try_into().unwrap();
    return rdm;
}

fn rand8(seed: u64, max: u32) -> u8 {
    let multiply: u128 = 1103515245;
    let add: u128 = 12345;
    let next = (seed.into() * multiply) + add;
    let rdm128 =  (next/65536) % max.into();
    let rdm: u8 = rdm128.try_into().unwrap();
    return rdm;
}