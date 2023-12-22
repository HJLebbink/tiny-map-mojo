
from random import random_ui64

@value
struct TinySet[MIN_VALUE:Int, MAX_VALUE: Int]():
    alias CAPACITY: Int = Self.calc_capacity[MAX_VALUE - MIN_VALUE]()
    var data: SIMD[DType.uint64, Self.CAPACITY]

    fn __init__(inout self, v: DynamicVector[Int]):
        self.data = SIMD[DType.uint64, Self.CAPACITY]()
        for i in range(v.size):
            self.add1(UInt32(v[i]))

    @staticmethod
    fn calc_capacity[s: Int]() -> Int:
        @parameter
        if s <= 64: return 1
        elif s <= 128: return 2
        elif s <= 256: return 4
        else: return 8

    @staticmethod
    fn block_id[T: DType](idx: SIMD[T, 1]) -> Int:
        return idx.shift_right[6]().to_int()

    @staticmethod
    fn block_mask[T: DType](idx: SIMD[T, 1]) -> SIMD[DType.uint64, 1]:
        return 1 << (idx.cast[DType.uint64]().__and__(0b0011_1111))

    fn add1[T: DType](inout self, v: SIMD[T, 1]):
        constrained[T.is_integral()]()
        let idx = v - MIN_VALUE
        self.data[Self.block_id(idx)] |= Self.block_mask(idx)

fn main():
    alias SET_SIZE = 512

    var vec = DynamicVector[Int]()
    for i in range(20):
        vec.push_back(random_ui64(0, SET_SIZE).to_int())

    let tinySet = TinySet[0, SET_SIZE](vec)
    print("size = " + str(tinySet.data[0]))
