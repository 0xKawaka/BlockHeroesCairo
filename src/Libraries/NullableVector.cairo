use super::IVector::VecTrait;

// impl VecIndex<V, T, impl VecTraitImpl: VecTrait<V, T>> of Index<V, usize, T> {
//     #[inline(always)]
//     fn index(ref self: V, index: usize) -> T {
//         self.at(index)
//     }
// }

struct NullableVector<T> {
    items: Felt252Dict<Nullable<T>>,
    len: usize,
}

impl DestructNullableVector<T, +Drop<T>> of Destruct<NullableVector<T>> {
    fn destruct(self: NullableVector<T>) nopanic {
        self.items.squash();
    }
}

impl NullableVectorImpl<T, +Drop<T>, +Copy<T>> of VecTrait<NullableVector<T>, T> {
    fn new() -> NullableVector<T> {
        NullableVector { items: Default::default(), len: 0 }
    }
    fn newFromArray(array: Array<T>) -> NullableVector<T> {
        let mut vec = VecTrait::<NullableVector, T>::new();
        let mut i: u32 = 0;
        loop {
            if (i >= array.len()) {
                break;
            }
            vec.push(*array.get(i).unwrap().unbox());
            i += 1;  
        };
        return vec;
    }
    fn get(ref self: NullableVector<T>, index: usize) -> Option<T> {
        if index < self.len() {
            Option::Some(self.items.get(index.into()).deref())
        } else {
            Option::None
        }
    }
    fn getValue(ref self: NullableVector<T>, index: usize) -> T {
        assert(index < self.len(), 'Index out of bounds');
        self.items.get(index.into()).deref()
    }

    fn at(ref self: NullableVector<T>, index: usize) -> T {
        assert(index < self.len(), 'Index out of bounds');
        self.items.get(index.into()).deref()
    }

    fn push(ref self: NullableVector<T>, value: T) {
        self.items.insert(self.len.into(), nullable_from_box(BoxTrait::new(value)));
        self.len = integer::u32_wrapping_add(self.len, 1_usize);
    }

    fn set(ref self: NullableVector<T>, index: usize, value: T) {
        assert(index < self.len(), 'Index out of bounds');
        self.items.insert(index.into(), nullable_from_box(BoxTrait::new(value)));
    }
    fn remove(ref self: NullableVector<T>, index: usize) {
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
    fn len(self: @NullableVector<T>) -> usize {
        *self.len
    }
}
