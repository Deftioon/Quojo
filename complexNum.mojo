from memory.unsafe import Pointer

struct ComplexNum:
    var re: Float64
    var im: Float64

    fn __init__(inout self, re: Float64, im: Float64) -> None:
        self.re = re
        self.im = im
    
    fn __copyinit__(inout self, existing: Self) -> None:
        self.re = existing.re
        self.im = existing.im
    
    fn __add__(inout self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re + other.re, self.im + other.im)
    
    fn __sub__(inout self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re - other.re, self.im - other.im)
    
    fn __mul__(inout self, other: ComplexNum) -> ComplexNum:
        return ComplexNum(self.re * other.re - self.im * other.im, self.re * other.im + self.im * other.re)
    
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
    
    fn print(inout self) -> None:
        print(self.re, "+", self.im, "i")

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
    
    fn __add__(inout self, other: ComplexMatrix) raises -> ComplexMatrix:
        if self.rows != other.rows or self.cols != other.cols:
            raise("ComplexMatrix: add -> Matrix dimensions do not match")
        var result = ComplexMatrix(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i * self.cols + j] = self.data[i * self.cols + j] + other.data[i * other.cols + j]
        return result

    fn __mul__(inout self, other: ComplexMatrix) raises -> ComplexMatrix:
        if self.cols != other.rows:
            raise("ComplexMatrix: mul -> Matrix dimensions do not match")
        var result = ComplexMatrix(self.rows, other.cols)
        for i in range(self.rows):
            for j in range(other.cols):
                for k in range(self.cols):
                    result.data[i * other.cols + j] = result.data[i * other.cols + j] + self.data[i * self.cols + k] * other.data[k * other.cols + j]
        return result
    
    fn print(inout self) raises -> None:
        for i in range(self.rows):
            for j in range(self.cols):
                print_no_newline(i, j, " ")
                self.data[i * self.cols + j].print()

fn main() raises:
    var myArr = ComplexArray(5, ComplexNum(1, 0))

    var myMat = ComplexMatrix(2, 2, ComplexNum(1, 0))
    var myMat2 = ComplexMatrix(2, 2, ComplexNum(1, 0))
    myMat2[0, 1] = ComplexNum(2, 0)
    var myMat3 = myMat * myMat2
    myMat3.print()