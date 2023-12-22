from collections.vector import DynamicVector
# from sys.intrinsics import gather # https://docs.modular.com/mojo/stdlib/sys/intrinsics.html#gather


@value
struct TinySet[min_value:Int, max_value: Int](CollectionElement, Sized, Stringable):
    alias capacity: Int = Self.calc_capacity[max_value - min_value]()
    var data: SIMD[DType.uint64, Self.capacity]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = SIMD[DType.uint64, Self.capacity]()

    fn __init__(inout self, v: DynamicVector[Int]):
        self.data = SIMD[DType.uint64, Self.capacity]()
        for i in range(v.size):
            self.addX(v[i])

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
        return 1 << (idx.cast[DType.uint64]() & 0b0011_1111)

    # trait CollectionElement
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    # trait CollectionElement
    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data ^

    # trait CollectionElement
    fn __del__(owned self: Self):
        pass

    @always_inline("nodebug")
    fn add1[T: DType](inout self, v: SIMD[T, 1]):
        constrained[T.is_integral()]()
        let idx = v - min_value
        self.data[Self.block_id(idx)] |= Self.block_mask(idx)

    @always_inline("nodebug")
    fn addX(inout self, v: Int):
        self.add1(UInt32(v)) # cast Int to UInt32


    @always_inline("nodebug")
    fn remove[T: DType](inout self, v: SIMD[T, 1]):
        constrained[T.is_integral()]()
        let idx = v - min_value
        self.data[Self.block_id(idx)] &= Self.block_mask(idx).__neg__()

    @always_inline("nodebug")
    fn remove(inout self, v: Int):
        self.remove(UInt32(v)) # cast Int to UInt32

    # trait Stringable
    fn __str__(self) -> String:
        var result: String = "["
        for i in range(self.capacity):
            if self.data[i]:
                result += str(i) +","
        return result + "]"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return math.reduce_bit_count(self.data)
        #use from math.bit import ctpop
