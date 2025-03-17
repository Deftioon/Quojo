# Visualization in Quojo-Rust

Quojo-Rust provides visualization tools for both quantum circuits and ZX-calculus diagrams using TikZ.

## Quantum Circuit Visualization

### Basic Circuit Visualization

```rust
use quojo_rust::qcore::{CircuitRepr, Targets, TikzConfig};
use quojo_rust::qcore::gates::Gate;

// Create a quantum circuit
let mut circuit = CircuitRepr::<2>();
circuit.Apply(Gate::H, Targets(&[0]));
circuit.ApplyControlled(Gate::X, 0, 1);

// Create a TikZ configuration
let config = TikzConfig();

// Save the circuit visualization
circuit.save_tikz(&config, "circuit.tex").unwrap();
```

### Circuit Visualization Configuration

You can customize the appearance of circuit diagrams:

```rust
use quojo_rust::qcore::tikz::TikzQConfig;

// Create a custom configuration
let mut config = TikzQConfig::default();
config.gate_spacing = 1.5;
config.wire_spacing = 0.8;
config.show_labels = true;
config.font_size = "\\small".to_string();
config.wire_style = "thick, gray".to_string();

// Use the custom configuration
circuit.save_tikz(&config, "custom_circuit.tex").unwrap();
```

## ZX-Graph Visualization

### Basic ZX-Graph Visualization

```rust
use quojo_rust::zxcalc::graph::{EdgeType, SpiderType, ZXGraph};
use quojo_rust::zxcalc::tikz::{TikzConfig, save_tikz_to_file};

// Create a ZX graph
let mut graph = ZXGraph::new();
let z1 = graph.add_node(SpiderType::Z, 0.0);
let x1 = graph.add_node(SpiderType::X, 0.0);
graph.add_edge(z1, x1, EdgeType::Regular);

// Create a TikZ configuration
let config = TikzConfig::default();

// Save the graph visualization
save_tikz_to_file(&graph, &config, "zx_graph.tex").unwrap();
```

### ZX-Graph with Input and Output Wires

You can visualize ZX-graphs with input and output wires:

```rust
// Create nodes with input/output wires
let i1 = graph.add_input_node(SpiderType::Z, 0.0);
let x1 = graph.add_node(SpiderType::X, 0.0);
let o1 = graph.add_output_node(SpiderType::Z, 0.0);

// Connect them
graph.add_edge(i1, x1, EdgeType::Regular);
graph.add_edge(x1, o1, EdgeType::Regular);

// Save the visualization
save_tikz_to_file(&graph, &config, "zx_with_io.tex").unwrap();
```

### ZX-Graph Visualization Configuration

You can customize the appearance of ZX-diagrams:

```rust
use quojo_rust::zxcalc::tikz::TikzConfig;

// Create a custom configuration
let mut config = TikzConfig::default();
config.node_spacing = 1.5;
config.layer_spacing = 2.5;
config.z_style = "circle,draw=darkgreen,fill=green!20,minimum size=7mm,text=black".to_string();
config.x_style = "circle,draw=darkred,fill=red!20,minimum size=7mm,text=black".to_string();
config.hadamard_box_style = "fill=yellow!80,draw=orange,minimum size=3mm".to_string();

// Use the custom configuration
save_tikz_to_file(&graph, &config, "custom_zx.tex").unwrap();
```

## Processing TikZ Output

The visualization functions generate TikZ code, which can be compiled to PDF using LaTeX:

1. Save the visualization to a `.tex` file
2. Compile it with a LaTeX distribution:
   ```bash
   pdflatex circuit.tex
   ```
3. View the resulting `circuit.pdf` file

### Using Generated TikZ in Your Documents

You can also include the generated TikZ code in your own LaTeX documents:

```latex
\documentclass{article}
\usepackage{tikz}

\begin{document}
\section{My Quantum Circuit}

Here's a Bell state preparation circuit:

\input{bell_state.tex}

And its ZX-calculus representation:

\input{bell_state_zx.tex}
\end{document}
```