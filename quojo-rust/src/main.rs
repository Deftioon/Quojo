use quojo_rust::linalg::vector;
use quojo_rust::qcore::Targets;
use quojo_rust::qcore::gates::Gate;

const I: vector::I = vector::I;

fn main() {
    let mut circuit = quojo_rust::qcore::CircuitRepr::<2>();
    circuit.Apply(Gate::Z, Targets(&[0]));
    circuit.Apply(Gate::X, Targets(&[1]));
    circuit.Apply(Gate::Z, Targets(&[0, 1]));
    circuit.Apply(Gate::H, Targets(&[1]));

    println!("{}", circuit);

    let a = 2.0 - 3.0 * I;
    let b = 1 + 4 * I;

    println!("a + b = {:?}", a + b);
    println!("a * b = {:?}", a * b);

    let arr = [2 + 3 * I, 4 - 4 * I, 5 + 7 * I, 0.5 - 3 * I];
    let simd = vector::ComplexSIMD::from_array(arr);

    println!("{}", simd)
}
