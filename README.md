# Quojo
A Quantum Computing Simulation written in Mojo

## TODO:
- Implement Uncomputing
- Implement Quantum Circuits
- Add Sample Programs (Quantum Search, Quantum Teleportation)
- Optimize code and make it more readable
  - Parallelize Quantum Gates

## Usage
### Creating a Qubit (Quantum Bit)
Use the `Qubit` Struct to create a qubit using a string representing a basis state.
```py
# Qubit(State: Int)
var myQubit = Qubit("1")
```
The mapping of String to Basis State is as follows:

`"0"` $\rightarrow|0\rangle$

`"1"` $\rightarrow|1\rangle$

It is not allowed to input any String other than `"0"` or `"1"`, doing so will create an `Exception` and terminate the code if unhandled.

The `print` method in the `Qubit` struct can be used to print the contents of the Qubit (this is NOT recommended as it breaks the rules of physics, but only serves for observing purposes and does not affect the workings of the circuits)

Constructing a Qubit with a predefined state is also possible.
```py
import complexNum as complx
var State = complx.ComplexMatrix(1,2)
State[0,0] = complx.ComplexNum(0.8,0)
State[0,1] = complx.ComplexNum(0.6,0)

var myQubit = Qubit(State)
```
The magnitudes of the squares of the two components of the Qubit, here being `State[0, 0]` and `State[0, 1]`, **must** sum to 1 by the 2nd axiom of probability theory. This is not strongly restrained so far, but is assumed when **measuring**.

### Measuring
Measuring a Qubit is an irreversible operation, and therefore after measuring a Qubit the object will be overwritten to whatever was measured: either $|0\rangle$ or $|1\rangle$.

With Qubit $\alpha|0\rangle + \beta|1\rangle$, the probability amplitude of measuring $|0\rangle$ is of probability $|\alpha^2|$, and likewise the probability of measuring $|1\rangle$. is $|\beta^2|$.

You can measure a Qubit with the `measure` method from the `Qubit` struct. 

```py
var myQubit = Qubit(1)

# Qubit.measure() -> None
myQubit.measure()
```

### Creating a Qudit (Quantum Register)
A Qudit is analogically the same as a classical register; it stores Qubits. 

A Qudit can be initialized with the `Qudit` struct.
```py
# Qudit(width: Int)
var myQudit = Qudit(3) # Creates a Qudit with a width of 3 -> It can store 3 Qubits
```

Qubits can be stored and manipulated with the `__getitem__` and `__setitem__` methods.
```py
var p = Qubit("0")
var q = Qubit("1")
myQudit[0] = p
myQudit[1] = q
myQudit[2].print() # This works because every element of a Qudit is a Qubit
# Prints
# 0.0 0.0
# 0.0 0.0
```

Qudits can be printed with `print()`. Print format is yet to be formatted.
```py
myQudit.print()
# 1.0 0.0
# 0.0 0.0
# 0.0 0.0
# 1.0 0.0
# 0.0 0.0
# 0.0 0.0
```

### Quantum Gates

Quantum Gates are unitary matrices that can be multiplied with Qubits to manipulate them.

```py
let Gates = QuantumGates()
var myQubit = Qubit(0)
```

#### Currently Supported Gates:
- Pauli X, Y, and Z gates
```py
var xBit = Gates.X(myQubit)
var yBit = Gates.Y(myQubit)
var zBit = Gates.Z(myQubit)
```
- Hadamard Gate
```py
var hBit = Gates.H(myQubit)
```
- Phase Shift (P, S) Gate
```py
var pBit = Gates.P(myQubit, phi) # Here, Phi is an angle measured in radians and rotates the Qubit by phi radians on the z axis on the Bloch Sphere
var pBit = Gates.S(myQubit, phi)
```
S by default has a `phi` value of $\frac{\pi}{2}$. To use other `phi` values use the `P` gate.

#### Gates operating on Qudits
- CNOT - Only operable on Qudits of width 2
```py
var myQudit = Qudit(2)
var p = Qubit("0")
var q = Qubit("1")
myQudit[0] = p
myQudit[1] = q
var r = Gates.CNOT(myQudit)
r.print()
# 1.0 0.0
# 0.0 0.0
# 1.0 0.0
# 0.0 0.0
```
`CX()` is also a valid function, running the `CNOT` method.
- SWAP - Only Operable on Qudits of width 2
```py
var r = Gates.SWAP(myQudit)
r.print()
# 1.0 0.0
# 0.0 0.0
# 0.0 0.0
# 1.0 0.0
```
- CCNOT (Toffioli - Only Operable on Qudits of width 3)
```py
var myQudit = Qudit(3)
var p = Qubit("0")
var q = Qubit("1")
var k = Qubit("1")
myQudit[0] = p
myQudit[1] = q
myQudit[2] = k
var r = Gates.CCNOT(myQudit)
r.print()
```
`CCX()` is also a valid function, running the `CCNOT` method.
Current CCNOT implementation is cheesy and flimsy, expect errors to occur.

### Parallel Gates?
Parallel Gates will certainly be implemented in the future, but it is not top priority as it is impractical, or rather, it uses too many resources to be applied practically. To put this into perspective, lets look at the Hadamard Gate. 

To apply a Hadamard Gate on two qubits together, we need a 4x4 Matrix.

Three qubits corresponds to a 8x8,

And at 16 Qubits we're looking at a gate size of 65,536 by 65,536, which takes quite a while to multiply. The lower-bound time complexity for multiplying two of such matrices is $\Omega(n^2\log{n})$

To quote Wikipedia (not good source I know),
> The time complexity for multiplying two $n\times n$ matrices is at least $\Omega(n^2\log{n})$, if using a classical machine. Because the size of a gate that operates on $q$ qubits is $2^q\times 2^q$ it means that the time for simulating a step in a quantum circuit (by means of multiplying the gates) that operates on generic entangled states is $\Omega(2^{q^2}\log{2^q})$. For this reason it is believed to be intractable to simulate large entangled quantum systems using classical computers.

### Quantum Wires
In Quojo, Quantum Wires serve as a medium to create a sort of "Compound Gate". Gates can be strung together to pass a Qubit through all of them at once. This reduces the need for repeated Gates in the circumstance that a certain sequence of gates needs to be repeated, for example if using a Hadamard and a Pauli X gate, a Quantum Gate can be constructed to call only once to pass a Qubit through both of these gates. If a wire was not used, then it would take two calls and a lot of repetition. 

Quantum Wires also aid in the construction of Quantum Circuits, which are essentially Quantum Wires but involve multiple qubits and multiple wires.

You can construct a Quantum Wire as follows:
```py
var Wire = QuantumWire("H X Y Z M")
```
A wire is constructed using a string of gates, each gate separated by a space. `Wire.help()` prints a directory of every gate able to be added.
```py
Wire.help()
# -------QUANTUM WIRE HELP--------
# Valid States: "I H X Y Z S M"
# I: Identity Gate
# H: Hadamard Gate
# X: Pauli-X Gate
# Y: Pauli-Y Gate
# Z: Pauli-Z Gate
# S: Phase Gate
# M: Measure Qubit
# --------------------------------
```
Gates can be added to Wires with `add`.
```py
Wire.add("H")
```
Wires can be printed with `print` with pretty formatting
```py
Wire.print()
# ▯ -H-X-Y-Z-M-H->
```

Qubits can be passed through Wires with the `parse` method.
```py
var q = Qubit("0")
var wire = QuantumWire("H X Y Z H H I H")
var r = wire.parse(q)
```

### Quantum Circuits
Work in Progress

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

## Sample Programs
### Quantum Search
With a classical computer, a linear search has time complexity $O(n)$. With a Quantum Computer, a Quantum Search has time complexity $O(\sqrt{n})$.
