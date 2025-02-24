use std::fmt;

#[derive(Debug)]
pub enum NodeType {
    Z,
    X,
    H,
}

#[derive(Debug)]
struct Node {
    id: usize,
    node_type: NodeType,
    phase: f64,
    outgoing_edges: Vec<usize>,
    incoming_edges: Vec<usize>,
}

impl Node {
    fn new(id: usize, node_type: NodeType, phase: f64) -> Self {
        Self {
            id,
            node_type,
            phase,
            outgoing_edges: Vec::new(),
            incoming_edges: Vec::new(),
        }
    }

    fn get_phase(&self) -> f64 {
        self.phase
    }

    fn set_phase(&mut self, phase: f64) {
        self.phase = phase;
    }
}

#[derive(Debug)]
struct Edge {
    id: usize,
    source: usize,
    target: usize,
}

impl Edge {
    fn new(id: usize, source: usize, target: usize) -> Self {
        Self { id, source, target }
    }
}

pub struct Graph {
    nodes: Vec<Node>,
    edges: Vec<Edge>,
}

impl Graph {
    pub fn new() -> Self {
        Self {
            nodes: Vec::new(),
            edges: Vec::new(),
        }
    }

    pub fn add_node(&mut self, node_type: NodeType, phase: f64) -> usize {
        let node_id = self.nodes.len();
        let node = Node::new(node_id, node_type, phase);
        self.nodes.push(node);
        node_id
    }

    pub fn add_edge(&mut self, source: usize, target: usize) -> usize {
        let edge_id = self.edges.len();
        let edge = Edge::new(edge_id, source, target);

        if let Some(source_node) = self.nodes.get_mut(source) {
            source_node.outgoing_edges.push(edge_id);
        } else {
            panic!("Source node index {} does not exist", source)
        }

        if let Some(target_node) = self.nodes.get_mut(target) {
            target_node.incoming_edges.push(edge_id);
        } else {
            panic!("Target node index {} does not exist", target)
        }

        self.edges.push(edge);
        edge_id
    }

    pub fn fuse_nodes(&mut self, node_a: usize, node_b: usize) {
        let (a_index, b_index) = if node_a < node_b {
            (node_a, node_b)
        } else {
            (node_b, node_a)
        };

        let (first, second) = self.nodes.split_at_mut(b_index);
        let a_node = &mut first[a_index];
        let b_node = &mut second[0];

        a_node.phase += b_node.phase;

        let b_incoming = b_node.incoming_edges.clone();
        let b_outgoing = b_node.outgoing_edges.clone();

        for edge_id in b_incoming {
            let edge = self.edges.get_mut(edge_id).unwrap();
            edge.target = a_index;
            a_node.incoming_edges.push(edge_id);
        }

        for edge_id in b_outgoing {
            let edge = self.edges.get_mut(edge_id).unwrap();
            edge.source = a_index;
            a_node.outgoing_edges.push(edge_id);
        }
        let b_pos = self.nodes.iter().position(|x| x.id == b_index).unwrap();
        self.nodes.remove(b_pos);
    }

    pub fn remove_unconnected_nodes(&mut self) {
        let mut nodes_to_remove = Vec::new();

        for node in &self.nodes {
            if node.incoming_edges.is_empty() && node.outgoing_edges.is_empty() {
                nodes_to_remove.push(node.id);
            }
        }

        for node_id in nodes_to_remove {
            let node_pos = self.nodes.iter().position(|x| x.id == node_id).unwrap();
            self.nodes.remove(node_pos);
        }
    }

    pub fn remove_singletons(&mut self) {
        let mut nodes_to_remove = Vec::new();

        for node in &self.nodes {
            if node.incoming_edges.is_empty() && node.outgoing_edges.is_empty() {
                nodes_to_remove.push(node.id);
            }
        }

        for node_id in nodes_to_remove {
            let node_pos = self.nodes.iter().position(|x| x.id == node_id).unwrap();
            self.nodes.remove(node_pos);
        }
    }

    pub fn to_adjacency_matrix(&self) -> Vec<Vec<usize>> {
        let mut adjacency_matrix = vec![vec![0; self.nodes.len()]; self.nodes.len()];

        for edge in &self.edges {
            adjacency_matrix[edge.source][edge.target] += 1;
        }

        adjacency_matrix
    }

    pub fn print_graph(&self) {
        println!("Nodes: ");
        for node in &self.nodes {
            println!("{:?}", node);
        }
        println!("Edges: ");
        for edge in &self.edges {
            println!("{:?}", edge);
        }
    }
}

impl fmt::Debug for Graph {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "Graph")?;
        writeln!(f, "Nodes:")?;
        for node in &self.nodes {
            writeln!(f, "{:?}", node)?;
        }
        writeln!(f, "Edges:")?;
        for edge in &self.edges {
            writeln!(f, "{:?}", edge)?;
        }
        Ok(())
    }
}
