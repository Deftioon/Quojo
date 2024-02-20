import complexNum as comp

struct Qubit:
    var bit: comp.ComplexMatrix

fn main() raises:
    var myArray = complexNum.ComplexArray(3)
    myArray.print()