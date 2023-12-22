from collections.vector import DynamicVector

fn main():
    var vec = DynamicVector[Int]()
    vec.push_back(15)
    let tinySet = TinySet[0](vec)


@value
struct TinySet[min_value:Int]():
    alias capacity = 8
    var data: SIMD[DType.uint64, Self.capacity]

    fn __init__(inout self, v: DynamicVector[Int]):
        self.data = SIMD[DType.uint64, Self.capacity]()
        for i in range(v.size):  # why does DynamicVector not implement Sized?
            self.add1(v[i]) # cast Int to UInt32

    @staticmethod
    fn block_id(idx: Int) -> Int:
        return idx>>6

    @staticmethod
    fn block_mask(idx: Int) -> UInt64:
        return 1 << (idx & 0b0011_1111)

    fn add1(inout self, v: Int):
        let idx: Int = v - min_value
        self.data[Self.block_id(idx)] |= Self.block_mask(idx)

