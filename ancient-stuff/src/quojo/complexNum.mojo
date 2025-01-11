from memory.unsafe import Pointer
from complex import ComplexSIMD

struct ComplexNum:
    var re: Float64
    var im: Float64

    fn __init__(inout self, re: Float64, im: Float64) -> None:
        self.re = re
        self.im = im
    
    fn __copyinit__(inout self, existing: Self) -> None:
        self.re = existing.re
        self.im = existing.im
    
    fn __add__(borrowed self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re + other.re, self.im + other.im)
    
    fn __sub__(borrowed self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re - other.re, self.im - other.im)
    
    fn __mul__(borrowed self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re * other.re - self.im * other.im, self.re * other.im + self.im * other.re)
    
    fn __mul__(borrowed self, other: Float64) -> ComplexNum:
        return ComplexNum(self.re * other, self.im * other)
    
    fn __invert__(borrowed self) -> ComplexNum:
        return ComplexNum(self.re, -self.im)
    
    fn __ne__(borrowed self, other: ComplexNum) -> Bool:
        return self.re != other.re or self.im != other.im
    
    fn __getitem__(borrowed self, i: Int) raises -> Float64 :
        if i == 0:
            return self.re
        elif i == 1:
            return self.im
        else:
            raise("ComplexNum: getitem -> Index out of range. Can only use indices 0 and 1 to get real and imaginary components respectively")
    
    fn __setitem__(inout self, i: Int, value: ComplexNum) raises -> None:
        if i == 0:
            self.re = value.re
        elif i == 1:
            self.im = value.im
        else:
            raise("ComplexNum: setitem -> Index out of range. Can only set indices 0 and 1 to set real and imaginary components respectively")
    
    fn print(borrowed self) -> None:
        if self.im >= 0:
            print(self.re, "+", self.im, "i")
        else:
            print(self.re, "-", -1 * self.im, "i")
    
    fn conjugate(borrowed self) -> ComplexNum:
        return ComplexNum(self.re, -self.im)
    
    fn magnitude(borrowed self) -> Float64:
        return (self.re * self.re + self.im * self.im) ** 0.5

    fn c(borrowed self) -> ComplexNum:
        return ComplexNum(self.re, -self.im)
    
    fn m(borrowed self) -> Float64:
        return (self.re * self.re + self.im * self.im) ** 0.5

struct ComplexArray:
    var ArrPointer: Pointer[Float64]
    var len: Int

    fn __init__(inout self, length: Int, default_value: ComplexNum = ComplexNum(0,0)) raises -> None:
        self.len = length
        self.ArrPointer = Pointer[Float64].alloc(length * 2)
        for i in range(length):
            self[i] = default_value
        
    fn __copyinit__(inout self, existing: Self) -> None:
        self.len = existing.len
        self.ArrPointer = existing.ArrPointer
    
    fn __getitem__(borrowed self, i: Int) raises -> ComplexNum:
        if i > self.len - 1:
            raise("ComplexArray: getitem -> Index out of range")
        return ComplexNum(self.ArrPointer.load(i * 2), self.ArrPointer.load(i * 2 + 1))
    
    fn __setitem__(inout self, loc: Int, item: ComplexNum) raises -> None :
        if loc > self.len - 1:
            raise("ComplexArray: setitem -> Index out of range")
        self.ArrPointer.store(loc * 2, item.re)
        self.ArrPointer.store(loc * 2 + 1, item.im)
    
    fn print(inout self) raises -> None:
        for i in range(self.len):
            print(self[i].re, "+", self[i].im, "i")

struct ComplexMatrix:
    var rows: Int
    var cols: Int
    var data: ComplexArray

    fn __init__(inout self, rows: Int, cols: Int, default_value: ComplexNum = ComplexNum(0,0)) raises -> None:
        self.rows = rows
        self.cols = cols
        self.data = ComplexArray(rows * cols, default_value)
    
    fn __copyinit__(inout self, existing: Self) -> None:
        self.rows = existing.rows
        self.cols = existing.cols
        self.data = existing.data
    
    fn __getitem__(borrowed self, i: Int, j: Int) raises -> ComplexNum:
        if i > self.rows - 1 or j > self.cols - 1:
            raise("ComplexMatrix: getitem -> Index out of range")
        return self.data[i * self.cols + j]

    fn __setitem__(inout self, i: Int, j: Int, value: ComplexNum) raises -> None:
        if i > self.rows - 1 or j > self.cols - 1:
            raise("ComplexMatrix: setitem -> Index out of range")
        self.data[i * self.cols + j] = value
    
    fn __add__(borrowed self, other: ComplexMatrix) raises -> ComplexMatrix:
        if self.rows != other.rows or self.cols != other.cols:
            raise("ComplexMatrix: add -> Matrix dimensions do not match")
        var result = ComplexMatrix(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i * self.cols + j] = self.data[i * self.cols + j] + other.data[i * other.cols + j]
        return result

    fn __mul__(borrowed self, other: Float64) raises -> ComplexMatrix:
        var result = ComplexMatrix(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i * self.cols + j] = self.data[i * self.cols + j] * other
        return result

    fn __mul__(borrowed self, other: ComplexNum) raises -> ComplexMatrix:
        var result = ComplexMatrix(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i * self.cols + j] = self.data[i * self.cols + j] * other
        return result
    
    fn __mul__(borrowed self, other: ComplexArray) raises -> ComplexMatrix:
        if self.cols != other.len:
            raise("ComplexMatrix: mul -> Matrix dimensions on 0th axis do not match")

        var result = ComplexMatrix(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result[i, j] = self[i, j] * other[i]
        return result
    
    fn __mul__(borrowed self, other: ComplexMatrix) raises -> ComplexMatrix:
        var result = ComplexMatrix(self.rows * other.rows, self.cols * other.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                for k in range(other.rows):
                    for l in range(other.cols):
                        result[i * other.rows + k, j * other.cols + l] = self[i, j] * other[k, l]
        return result

    fn __matmul__(borrowed self, other: ComplexMatrix) raises -> ComplexMatrix:
        if self.cols != other.rows:
            raise("ComplexMatrix: mul -> Matrix dimensions do not match")

        var result = ComplexMatrix(self.rows, other.cols)
        for i in range(self.rows):
            for j in range(other.cols):
                for k in range(self.cols):
                    result.data[i * other.cols + j] = result.data[i * other.cols + j] + self.data[i * self.cols + k] * other.data[k * other.cols + j]
        return result
    
    fn transpose(borrowed self) raises -> ComplexMatrix:
        var result = ComplexMatrix(self.cols, self.rows)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[j * self.rows + i] = self.data[i * self.cols + j]
        return result
    
    fn conjugate_transpose(borrowed self) raises -> ComplexMatrix:
        var result = ComplexMatrix(self.cols, self.rows)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[j * self.rows + i] = ~self.data[i * self.cols + j]
        return result


    fn print(borrowed self) raises -> None:
        for i in range(self.rows):
            for j in range(self.cols):
                print(i, j, end = " ")
                self.data[i * self.cols + j].print()
