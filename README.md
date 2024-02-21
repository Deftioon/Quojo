# Quantum-Mojo
A Quantum Computing Machine written in Mojo

## Usage
### Creating a Qubit
Use the `Qubit` Struct to create a qubit using a string representing the basis state.
```cs
var myQubit = Qubit("01")
```
The mapping of String to Basis State is as follows:

`"00"` $\rightarrow|00\rangle$

`"00"` $\rightarrow|01\rangle$

`"00"` $\rightarrow|10\rangle$

`"00"` $\rightarrow|11\rangle$

This applies similarly to one qubit ($|0\rangle$) and other Qubit sizes ($|000\rangle$, $|0000\rangle$, ...).

