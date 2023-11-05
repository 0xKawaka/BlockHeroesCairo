trait VecTrait<V, T> {
    fn new() -> V;
    fn newFromArray(array: Array<T>) -> V;
    fn toArray(ref self: V) -> Array<T>;
    fn get(ref self: V, index: usize) -> Option<T>;
    fn getValue(ref self: V, index: usize) -> T;
    fn at(ref self: V, index: usize) -> T;
    fn push(ref self: V, value: T);
    fn set(ref self: V, index: usize, value: T);
    fn remove(ref self: V, index: usize);
    fn len(self: @V) -> usize;
}
