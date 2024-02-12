from memory.unsafe import Pointer

struct Complex:
    var re: Float64
    var im: Float64

    fn __init__(inout self, re: Float64, im: Float64) -> None:
        self.re = re
        self.im = im
    
    fn __add__(inout self, other: Complex) -> Complex:
        return Complex(self.re + other.re, self.im + other.im)
    
    fn __sub__(inout self, other: Complex) -> Complex:
        return Complex(self.re - other.re, self.im - other.im)
    
    fn __mul__(inout self, other: Complex) -> Complex:
        return Complex(self.re * other.re - self.im * other.im, self.re * other.im + self.im * other.re)
    
    fn __getitem__(borrowed self, i: int) -> Complex raises:
        if i == 0:
            return self.re
        elif i == 1:
            return self.im
        else:
            raise("Index out of range")
    
    fn __setitem__(inout self, i: int, value: Complex) -> None raises:
        if i == 0:
            self[0] = value.re
        elif i == 1:
            self[1] = value.im
        else:
            raise("Index out of range")
    
    fn __str__(inout self) -> String:
        return String(self.re) + " + " + String(self.im) + "i"

struct ComplexArray:
    var ArrPointer: Pointer[Float64]
    var len: Int
    var capacity: Int

    fn __init__(inout self, capacity: Int = 2, default_value: Int) -> None:
        self.len = capacity * 2 if capacity > 0 else 1
        self.capacity = self.len * 4
        self.ArrPointer = Pointer[Float64].alloc(self.capacity)
    
        for i in range(self.len):
            self[i] = default_value
    
    fn __getitem__(borrowed self, i: int) -> Complex raises:
        if i > self.len:
            raise("Index out of range")
        return Complex(self.ArrPointer.load(i), self.ArrPointer.load(i + 1))
    
    fn __setitem__(inout self, loc: Int, item: Complex) -> None raises:
        if loc > self.capacity:
            raise("Index out of range")
        if loc > self.len:
            let old_len = self.len
            self.len = loc + 2
            for i in range(old_len, self.len):
                self.ArrPointer.store(i, item)
            return
        self.ArrPointer.store(loc, item)