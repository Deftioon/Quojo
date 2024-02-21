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

And each basis state maps to each of these vectors:

$|00\rangle=\left[\begin{array}{l}1 \\ 0 \\ 0 \\ 0\end{array}\right],|01\rangle=\left[\begin{array}{l}0 \\ 1 \\ 0 \\ 0\end{array}\right],|10\rangle=\left[\begin{array}{l}0 \\ 0 \\ 1 \\ 0\end{array}\right]$, $|11\rangle=\left[\begin{array}{l}0 \\ 0 \\ 0 \\ 1\end{array}\right]$

This applies similarly to one qubit ($|0\rangle$) and other Qubit sizes ($|000\rangle$, $|0000\rangle$, ...).

