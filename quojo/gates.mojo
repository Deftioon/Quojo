from .linalg import *

@value
struct QuantumGate[rows: Int, cols: Int]:
    var matrix: Matrix[rows, cols]

    fn __init__(out self):
        self.matrix = Matrix[rows, cols](0.0, 0.0)

    fn __str__(self) raises -> String:
        return str(self.matrix)

    fn replace_matrix(mut self, matrix: Matrix[rows, cols]):
        self.matrix = matrix
    
    fn set_matrix(mut self, *values: ComplexSIMD[DType.float64, 1]):
        for i in range(rows):
            for j in range(cols):
                self.matrix[i, j] = values[i * cols + j]
