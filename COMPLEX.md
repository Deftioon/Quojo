### Complex Numbers
A Complex Number is able to be created using the `ComplexNum` struct, and is constructed as follows:
```py
# ComplexNum(re: Float64, im: Float64)
var myComplex = ComplexNum()
```

**Reading Values**

You can read the real and imaginary values from the Complex Number as follows:
```py
myComplex[0] # This returns the real value
myComplex[1] # This returns the imaginary value
```

**Setting Values**

You can set the real and imaginary values as follows:
```py
myComplex[0] = 0.1 # Sets real
myComplex[1] = 0.2 # Sets imaginary
```

**Printing**

You can print the number as follows:
```py
myComplex.print()
# Prints formatted number (0 + 2i, 5 - 3i)
```

**Operating**

You can add, subtract, and multiply Complex Numbers with the `+, -, *` operators respectively.

**Conjugation**

You can retrieve the conjugate of the number with the `ComplexNum.conjugate()` or `ComplexNum.c()` methods as follows:
```py
var newComplex = myComplex.c()
```
Or, alternatively, with the `__inverse__` dunder method, as follows:
```py
var newComplex = ~myComplex()
```
These two work exactly the same.

**Magnitude**

You can retrieve the magnitude of the number with the `ComplexNum.magnitude` or `ComplexNum.m` methods as follows:
```py
var magnitude = myComplex.m()
```

### Complex Arrays
Complex Arrays are Arrays that store Complex Numbers (`ComplexNum`s)

**Constructing**

It is constructed as follows:
```py
# ComplexArray(length: Int, default_value: ComplexNum = ComplexNum(0,0))
var myArray = ComplexArray(3) # This creates a Complex Array of length 3 with 0 + 0i in every index.
var myArray = ComplexArray(5, ComplexNum(0,-2)) # This creates a Complex Array of length 5 with 0 - 2i in every index.
```

**Getting and Setting**

You can get and set the items with the `__getitem__` and `__setitem__` dunder methods, as follows:
```py
myArray[0] = ComplexNum(0,1)
myArray[0].print()
# Prints 0 + 1i
```

**Printing**

You can also print the array's contents with `ComplexArray.print` as follows:
```py
myArray.print()
```

### Complex Matrices
We step away from Arrays and move into Matrices. These form the basis for Qubits and Quantum Gates.

**Constructing**

You can construct one as follows:
```py
# ComplexMatrix(rows: Int, cols: Int, default_value: ComplexNum = ComplexNum(0,0))
var myMatrix = ComplexMatrix(3, 3) # Creates a 3x3 Matrix with values set to 0 + 0i

var myMatrix = ComplexMatrix(3, 4, ComplexNum(1,2)) # Creates a 3x4 Matrix with values set to 1 + 2i
```

**Getting and Setting**

You can set and get values from the matrix with the following syntax:
```py
# ComplexMatrix[row: Int, col: Int]

var value = myMatrix[0, 0]
myMatrix[0,1] = ComplexNum(1,2)
```

**Operating**

You can perform elementary operations with the `+, -` operators.

The `*` operator is overloaded:
- `ComplexMatrix * Float64`: Every element of the matrix is multiplied by the Float value
- `ComplexMatrix * ComplexArray`: Every row of the matrix is multiplied element-wise with the `ComplexArray`
- `ComplexMatrix * ComplexMatrix`: The two matrices are multiplied element-wise.

The `@` operator achieves matrix multiplication.
```py
var newMat = myMatrixOne @ myMatrixTwo
```

**Transposing**

You can transpose any Complex Matrix with the `ComplexMatrix.transpose`, which swaps the axes.
```py
var transposed = myMatrix.transpose()
```

You can get the conjugate transpose of any Complex Matrix with the `ComplexMatrix.conjugate_transpose` method:
```py
var conj_trans = myMatrix.conjugate_transpose()
```

**Printing**

And of course, you can print the contents with `ComplexMatrix.print()`