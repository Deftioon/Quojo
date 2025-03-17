# Getting Started with Quojo-Rust

This guide will help you get up and running with Quojo-Rust for quantum circuit design and ZX-calculus.

## Installation

Clone the repository:

```bash
git clone https://github.com/Deftioon/Quojo.git
cd Quojo/quojo-rust
cargo build
```

## Basic Example: Creating a Quantum Circuit

```rust
use quojo_rust::qcore::{CircuitRepr, Targets, TikzConfig};
use quojo_rust::qcore::gates::Gate;
use quojo_rust::qcore::tikz::TikzCircuit;

fn main() {
    // Create a 2-qubit circuit
    let mut circuit = CircuitRepr::<2>();
    
    // Apply a Hadamard gate to the first qubit
    circuit.Apply(Gate::H, Targets(&[0]));
    
    // Apply a CNOT gate with control on qubit 0 and target on qubit 1
    circuit.ApplyControlled(Gate::X, 0, 1);
    
    // Print the circuit
    println!("{}", circuit);
    
    // Create a TikZ visualization of the circuit
    let config = TikzConfig();
    circuit.save_tikz(&config, "bell_state.tex").unwrap();
}
```

## Basic Example: ZX-Calculus

Here's an example of creating a ZX-graph and visualizing it:

```rust
use quojo_rust::zxcalc::graph::{EdgeType, SpiderType, ZXGraph};
use quojo_rust::zxcalc::tikz::{TikzConfig, save_tikz_to_file};

fn main() {
    // Create a new ZX-graph
    let mut graph = ZXGraph::new();
    
    // Add nodes with specific spider types and phases
    let i1 = graph.add_input_node(SpiderType::Z, 0.0); // Input node
    let x1 = graph.add_node(SpiderType::X, 0.0);      // X spider
    let z1 = graph.add_node(SpiderType::Z, std::f64::consts::PI/4.0); // Z spider with π/4 phase
    let o1 = graph.add_output_node(SpiderType::Z, 0.0); // Output node
    
    // Connect nodes with edges
    graph.add_edge(i1, x1, EdgeType::Regular);
    graph.add_edge(x1, z1, EdgeType::Hadamard);
    graph.add_edge(z1, o1, EdgeType::Regular);
    
    // Save the diagram
    let config = TikzConfig::default();
    save_tikz_to_file(&graph, &config, "zx_graph.tex").unwrap();
    
    // Perform graph simplification
    let fusion_count = graph.fuse_spiders();
    println!("Performed {} fusion operations", fusion_count);
    
    // Save the simplified diagram
    save_tikz_to_file(&graph, &config, "zx_graph_simplified.tex").unwrap();
}
```


## Next Steps

- Build [quantum circuits](circuits.md)
- List of [quantum gates](gates.md)
- Methods for [ZX-calculus](zx-calculus.md)
- Methods for [visualization](visualization.md) options
