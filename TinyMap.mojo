



@register_passable
struct TinyMap[KeyT: DType, ValueT: DType, max_size: Int = 64](CollectionElement, Sized, Stringable):
    constrained[max_size <= 64]()    
    alias size: Int = Self.calc_size[max_size]()
    var data: SIMD[ValueT, Self.size]

    @always_inline("nodebug")
    fn __init__(inout self) -> TinyMap[KeyT, ValueT, max_size]:
        self.data = SIMD[ValueT, 64]()

    fn __init__(inout self, v: DynamicVector[Tuple[KeyT, ValueT]]):
        self.data = SIMD[ValueT, 64]
        for i in range(v.__len__()):
            self.data.push_back(Layer.pack(v[i]))

    @staticmethod 
    fn calc_size[s: Int]() -> Int:
        @parameter
        if s <= 1: return 1
        elif s <= 8: return 8
        elif s <= 16: return 16
        elif s <= 32: return 32
        else: return 64

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data.__copyinit__(existing.data)

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data ^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "["
        let size = len(self.data)
        if (size > 0):
            for i in range(size-1):
                result += "(" + str(self.get_min(i)) + "," + str(self.get_max(i)) + "),"
            result += "(" + str(self.get_min(size-1)) + "," + str(self.get_max(size-1)) + ")"
        return result + "]"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.data)
