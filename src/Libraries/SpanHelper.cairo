use core::box::BoxTrait;
use core::option::OptionTrait;
use debug::PrintTrait;

fn includes<T, +PartialEq<T>>(arr: Span<T>, item: @T) -> bool {
    let arrLen = arr.len();
    let mut i: u32 = 0;
    let mut found: bool = false;
    loop {
        if (i >= arrLen) {
            break;
        }
        let value = arr[i];
        if (value == item) {
            found = true;
            break;
        }
        i += 1;
    };
    return found;
}

fn print<T, +Copy<T>, +PrintTrait<T>>(arr: Span<T>) {
    let arrLen = arr.len();
    let mut i: u32 = 0;
    loop {
        if (i >= arrLen) {
            break;
        }
        let value = *arr[i];
        value.print();
        i += 1;
    }
}
