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
Qudits are basically wider Qubits. You can define a Qudit as follows:
```py
var qudit = Qudit("1000")
```
Where the string in the `Qudit()` represents the basis state the Qudit will be set to.

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