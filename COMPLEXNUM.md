## Complex Number Module
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

You can set the real and imaginary values

You can print the number as follows:
```py
myComplex.print()
# Prints formatted number (0 + 2i, 5 - 3i)
```

You can add, subtract, and multiply Complex Numbers with the `+, -, *` operators respectively.

You can retrieve the conjugate of the number with the `ComplexNum.conjugate()` or `ComplexNum.c()` methods as follows:
```py
var newComplex = myComplex.c()
```
Or, alternatively, with the `__inverse__` dunder method, as follows:
```py
var newComplex = ~myComplex()
```
These two work exactly the same.

### Complex Arrays
Complex Arrays are Arrays that store Complex Numbers (`ComplexNum`s)

It is constructed as follows:
```py
# ComplexArray(length: Int, default_value: ComplexNum = ComplexNum(0,0))
var myArray = ComplexArray(3) # This creates a Complex Array of length 3 with 0 + 0i in every index.
var myArray = ComplexArray(5, ComplexNum(0,-2)) # This creates a Complex Array of length 5 with 0 - 2i in every index.
```

You can get and set the items with the `__getitem__` and `__setitem__` dunder methods, as follows:
```py
myArray[0] = ComplexNum(0,1)
myArray[0].print()
# Prints 0 + 1i
```

You can also print the array's contents with `ComplexArray.print` as follows:
```py
myArray.print()
```

### Complex Matrices
We step away from Arrays and move into Matrices. These form the basis for Qubits and Quantum Gates.

You can construct one as follows:
```py
# ComplexMatrix()
```
