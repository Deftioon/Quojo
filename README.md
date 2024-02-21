# Quantum-Mojo
A Quantum Computing Machine written in Mojo

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

You can use the `print` method in the `Qubit` struct to print the contents of the Qubit (this is NOT recommended as it breaks the rules of physics, but only serves for observing purposes and does not affect the workings of the circuits)

### Measuring
Measuring a Qubit is an irreversible operation, and therefore after measuring a Qubit the object will be overwritten to whatever was measured: either $|0\rangle$ or $|1\rangle$.

With Qubit $\alpha|0\rangle + \beta|1\rangle$, the probability amplitude of measuring $|0\rangle$ is of probability $|\alpha^2|$, and likewise the probability of measuring $|1\rangle$. is $|\beta^2|$.

You can measure a Qubit with either the `measure` method from the `Qubit` struct. 

```py
var myQubit = Qubit(1)

# Qubit.measure() -> ComplexMatrix
myQubit.measure().print()

```

### Creating a Qudit (Quantum Register)
Use the `Qudit` Struct to create a qudit using a string representing the basis state.
```py
var myQudit = Qudit("01")
```
The mapping of String to Basis State is as follows:

`"00"` $\rightarrow|00\rangle$

`"00"` $\rightarrow|01\rangle$

`"00"` $\rightarrow|10\rangle$

`"00"` $\rightarrow|11\rangle$

This applies similarly to other Qudit sizes ($|000\rangle$, $|0000\rangle$, ...).

Any length of string within technical limitations is possible for any amount of Qubits in the Qudit.
