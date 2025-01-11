from complex import ComplexSIMD

@value
struct Matrix[rows: Int, cols: Int](StringableRaising):
    var data: ComplexSIMD[DType.float64, rows * cols]
    var shape: Tuple[Int, Int]
    # Note here that SIMD widths must be powers of 2, but Quantum Gate and Qubit widths 
    # are always powers of 2, so it is safe to use SIMD[DType.float64, rows * cols] here.

    fn __init__(out self, data: ComplexSIMD[DType.float64, rows * cols]):
        self.data = data
        self.shape = (rows, cols)
    
    fn __init__(out self, re: Float64, im: Float64):
        self.data = ComplexSIMD[DType.float64, rows * cols](re, im)
        self.shape = (rows, cols)
    
    fn __str__(self) raises -> String:
        var output = String("")
        for i in range(rows):
            for j in range(cols):
                output += "({},{})".format(self.data.re[i * cols + j], self.data.im[i * cols + j])
            output += "\n"
        return output

    fn __getitem__(self, row: Int, col: Int) -> ComplexSIMD[DType.float64, 1]:
        output = ComplexSIMD[DType.float64, 1](0.0, 0.0)
        output.re[0] = self.data.re[row * cols + col]
        output.im[0] = self.data.im[row * cols + col]
        return output
    
    fn __setitem__(mut self, row: Int, col: Int, value: ComplexSIMD[DType.float64, 1]):
        self.data.re[row * cols + col] = value.re[0]
        self.data.im[row * cols + col] = value.im[0]

    fn set_matrix(mut self, *values: ComplexSIMD[DType.float64, 1]):
        for i in range(rows):
            for j in range(cols):
                self[i, j] = values[i * cols + j]

@always_inline
fn dot(this: Matrix, other: Matrix) -> Matrix[this.rows, other.cols]:
    var output = Matrix[this.rows, other.cols](0.0, 0.0)
    for i in range(this.shape[0]):
        for j in range(other.shape[1]):
            for k in range(this.shape[1]):
                output[i, j] = output[i,j] + this[i, k] * other[k, j]
    return output

@always_inline
fn kron(this: Matrix, other: Matrix) -> Matrix[this.rows * other.rows, this.cols * other.cols]:
    var output = Matrix[this.rows * other.rows, this.cols * other.cols](0.0, 0.0)
    for i in range(this.shape[0]):
        for j in range(this.shape[1]):
            for k in range(other.shape[0]):
                for l in range(other.shape[1]):
                    output[i * other.shape[0] + k, j * other.shape[1] + l] = this[i, j] * other[k, l]
    return output

