from TinySet import TinySet
from random import random_ui64
from time import now

fn test_tiny_set():
    alias SET_SIZE = 512

    var vec = DynamicVector[Int]()
    for i in range(20):
        let v = random_ui64(0, SET_SIZE).to_int()
        vec.push_back(v)

    let tinySet = TinySet[0, SET_SIZE](vec)

    print(str(tinySet))
    let t1 = now()
    let s = len(tinySet)
    let t2 = now()-t1
    print("size = " + str(s) + "; time "+str(t2) +" ns")


fn main():
    let start_time_ns = now()
    test_tiny_set()
    let elapsed_time_ns = now() - start_time_ns
    print_no_newline("Elapsed time " + str(elapsed_time_ns) + " ns")
    print_no_newline(" = " + str(Float32(elapsed_time_ns) / 1_000) + " μs")
    print_no_newline(" = " + str(Float32(elapsed_time_ns) / 1_000_000) + " ms")
    print_no_newline(" = " + str(Float32(elapsed_time_ns) / 1_000_000_000) + " s\n")
