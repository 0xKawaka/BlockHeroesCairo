use core::box::BoxTrait;
use core::option::OptionTrait;
use super::IVector::VecTrait;

// impl VecIndex<V, T, impl VecTraitImpl: VecTrait<V, T>> of Index<V, usize, T> {
//     #[inline(always)]
//     fn index(ref self: V, index: usize) -> T {
//         self.at(index)
//     }
// }

struct Vector<T> {
    items: Felt252Dict<T>,
    len: usize,
}

impl DestructFeltVec<T, +Drop<T>, +Felt252DictValue<T>> of Destruct<Vector<T>> {
    fn destruct(self: Vector<T>) nopanic {
        self.items.squash();
    }
}

impl VectorImpl<T, +Drop<T>, +Copy<T>, +Felt252DictValue<T>> of VecTrait<Vector<T>, T> {
    fn new() -> Vector<T> {
        Vector { items: Default::default(), len: 0 }
    }
    fn newFromArray(array: Array<T>) -> Vector<T> {
        let mut vec = VecTrait::<Vector, T>::new();
        let mut i: u32 = 0;
        loop {
            if (i > array.len() - 1) {
                break;
            }
            vec.push(*array.get(i).unwrap().unbox());
            i += 1;
        };
        return vec;
    }
    fn get(ref self: Vector<T>, index: usize) -> Option<T> {
        if index < self.len() {
            let item = self.items.get(index.into());
            Option::Some(item)
        } else {
            Option::None
        }
    }
    fn getValue(ref self: Vector<T>, index: usize) -> T {
        assert(index < self.len(), 'Index out of bounds');
        self.items.get(index.into())
    }
    fn at(ref self: Vector<T>, index: usize) -> T {
        assert(index < self.len(), 'Index out of bounds');
        let item = self.items.get(index.into());
        item
    }
    fn push(ref self: Vector<T>, value: T) {
        self.items.insert(self.len.into(), value);
        self.len = integer::u32_wrapping_add(self.len, 1_usize);
    }
    fn set(ref self: Vector<T>, index: usize, value: T) {
        assert(index < self.len(), 'Index out of bounds');
        self.items.insert(index.into(), value);
    }
    fn remove(ref self: Vector<T>, index: usize) {
        assert(index < self.len(), 'Index out of bounds');
        let mut i: u32 = index;
        loop {
            if (i + 1 > self.len() - 1) {
                self.len -= 1;
                break;
            }
            self.set(i.into(), self.getValue(i + 1));
            i += 1;
        };
    }
    fn len(self: @Vector<T>) -> usize {
        *self.len
    }
}
