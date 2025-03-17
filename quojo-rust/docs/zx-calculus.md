# ZX-Calculus in Quojo-Rust

Quojo-Rust provides tools for working with ZX-calculus, a graphical language for reasoning about quantum circuits and quantum processes.

## What is ZX-Calculus?

ZX-calculus represents quantum processes as diagrams with:

- Spiders (nodes): Z-spiders (green) and X-spiders (red)
- Edges: Regular connections and Hadamard edges (with yellow boxes)
- Phases: Associated with spiders, representing rotations

## ZX Graph Structure

Quojo-Rust implements ZX diagrams using the `ZXGraph` structure:

```rust
pub struct ZXGraph {
    pub nodes: Vec<Option<Node>>,
    pub edges: Vec<Option<Edge>>,
    pub free_nodes: Vec<usize>,
    pub free_edges: Vec<usize>,
    pub input_nodes: HashSet<NodeIndex>,
    pub output_nodes: HashSet<NodeIndex>,
}
```

## Creating ZX Graphs

### Basic Graph Creation

```rust
use quojo_rust::zxcalc::graph::{EdgeType, SpiderType, ZXGraph};

// Create a new ZX graph
let mut graph = ZXGraph::new();

// Add spiders (nodes)
let z1 = graph.add_node(SpiderType::Z, 0.0);  // Z spider with 0 phase
let x1 = graph.add_node(SpiderType::X, 0.0);  // X spider with 0 phase
let z2 = graph.add_node(SpiderType::Z, std::f64::consts::PI/2.0);  // Z spider with π/2 phase

// Connect nodes with edges
graph.add_edge(z1, x1, EdgeType::Regular);  // Regular edge
graph.add_edge(x1, z2, EdgeType::Hadamard);  // Hadamard edge
```

### Input and Output Nodes

ZX diagrams can have designated input and output nodes:

```rust
// Add input nodes
let i1 = graph.add_input_node(SpiderType::Z, 0.0);
let i2 = graph.add_input_node(SpiderType::Z, 0.0);

// Add output nodes
let o1 = graph.add_output_node(SpiderType::Z, 0.0);
let o2 = graph.add_output_node(SpiderType::X, 0.0);

// Mark existing nodes as inputs/outputs
graph.set_as_input(node_idx);
graph.set_as_output(node_idx);
```

## ZX Graph Simplification

ZX-calculus enables quantum circuit optimization through graph simplification rules. Quojo-Rust implements spider fusion:

```rust
// Perform spider fusion
let fusion_count = graph.fuse_spiders();
println!("Performed {} fusion operations", fusion_count);
```

Spider fusion combines adjacent spiders of the same type, adding their phases.

## Graph Traversal

You can analyze the structure of ZX graphs:

```rust
// Get the neighbors of a node
let neighbors = graph.neighbors(node_idx);

// Access node data
if let Some((spider_type, phase)) = graph.node_data(node_idx) {
    println!("Node type: {:?}, phase: {}", spider_type, phase);
}

// Access edge data
if let Some(edge_type) = graph.edge_data(edge_idx) {
    println!("Edge type: {:?}", edge_type);
}
```

## Visualizing ZX Graphs

Quojo-Rust provides TikZ visualization for ZX graphs:

```rust
use quojo_rust::zxcalc::tikz::{TikzConfig, save_tikz_to_file};

// Create a visualization config
let config = TikzConfig::default();

// Save the graph visualization
save_tikz_to_file(&graph, &config, "zx_graph.tex").unwrap();
```

For more visualization options, see [visualization.md](visualization.md).

## ZX-Calculus Rewrite Rules

ZX-calculus is powerful because it provides a set of rewrite rules for transforming ZX diagrams. Quojo-Rust currently implements:

1. **Spider Fusion**: Merging connected spiders of the same type, adding their phases.

```rust
// Fuse spiders where possible
let fusion_count = graph.fuse_spiders();
```

## Example: CNOT Circuit as ZX Graph

Here's a complete example showing how a CNOT circuit appears in ZX-calculus:

```rust
use quojo_rust::qcore::{CircuitRepr, Targets};
use quojo_rust::qcore::gates::Gate;
use quojo_rust::qcore::zx::circuit_to_zx_graph;
use quojo_rust::zxcalc::tikz::{TikzConfig, save_tikz_to_file};

fn main() {
    // Create a CNOT circuit
    let mut circuit = CircuitRepr::<2>();
    circuit.ApplyControlled(Gate::X, 0, 1);
    
    // Convert to ZX-graph
    let zx_graph = circuit_to_zx_graph(&circuit);
    
    // Visualize the ZX representation
    let config = TikzConfig::default();
    save_tikz_to_file(&zx_graph, &config, "cnot_as_zx.tex").unwrap();
}
```

In the ZX Calculus, a CNOT appears as:
- A Z spider (green) on the control wire
- An X spider (red) on the target wire
- A regular edge connecting these spiders