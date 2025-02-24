use std::fmt;

#[derive(Debug)]
pub enum NodeType {
    Z,
    X,
    H,
}

#[derive(Debug)]
pub struct Node {
    pub id: usize,
    pub node_type: NodeType,
    pub phase: f64,
    pub outgoing_edges: Vec<usize>,
    pub incoming_edges: Vec<usize>,
    pub active: bool,
}

impl Node {
    fn new(id: usize, node_type: NodeType, phase: f64) -> Self {
        Self {
            id,
            node_type,
            phase,
            outgoing_edges: Vec::new(),
            incoming_edges: Vec::new(),
            active: true,
        }
    }
}

pub struct NodeView<'a> {
    pub node: &'a Node,
    pub edges: &'a [Edge],
}

impl<'a> fmt::Debug for NodeView<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let active_outgoing: Vec<_> = self
            .node
            .outgoing_edges
            .iter()
            .filter(|&x| self.edges[*x].active)
            .collect();

        let active_incoming: Vec<_> = self
            .node
            .incoming_edges
            .iter()
            .filter(|&x| self.edges[*x].active)
            .collect();

        writeln!(f, "Node")?;
        writeln!(f, "ID: {}", self.node.id)?;
        writeln!(f, "Type: {:?}", self.node.node_type)?;
        writeln!(f, "Phase: {}", self.node.phase)?;
        writeln!(f, "Outgoing edges: {:?}", active_outgoing)?;
        writeln!(f, "Incoming edges: {:?}", active_incoming)
    }
}

#[derive(Debug)]
pub struct Edge {
    pub id: usize,
    pub source: usize,
    pub target: usize,
    pub active: bool,
}

impl Edge {
    fn new(id: usize, source: usize, target: usize) -> Self {
        Self {
            id,
            source,
            target,
            active: true,
        }
    }
}

pub struct Graph {
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,
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

        //TODO: it should not be setting the target to a_index.
        for edge_id in b_incoming {
            let edge = self.edges.get_mut(edge_id).unwrap();
            edge.active = false;
            edge.target = a_index;
            a_node.incoming_edges.push(edge_id);
        }

        for edge_id in b_outgoing {
            let edge = self.edges.get_mut(edge_id).unwrap();
            edge.source = a_index;
            a_node.outgoing_edges.push(edge_id);
        }

        self.nodes.get_mut(b_index).unwrap().active = false;
    }

    pub fn remove_self_cycles(&mut self) {
        let mut edges_to_remove = Vec::new();
        let mut related_nodes = Vec::new();

        for edge in &self.edges {
            if edge.source == edge.target {
                edges_to_remove.push(edge.id);
                related_nodes.push(edge.source);
            }
        }

        for edge_id in edges_to_remove {
            self.edges.get_mut(edge_id).unwrap().active = false;
        }

        for node_id in related_nodes {
            let node = self.nodes.get_mut(node_id).unwrap();
            node.incoming_edges.retain(|&x| x != node_id);
            node.outgoing_edges.retain(|&x| x != node_id);
        }
    }

    pub fn remove_unconnected_nodes(&mut self) {
        let mut nodes_to_remove = Vec::new();

        for node in &self.nodes {
            if node.incoming_edges.is_empty() && node.outgoing_edges.is_empty() {
                nodes_to_remove.push(node.id);
            }
        }

        for node_id in nodes_to_remove {
            self.nodes.get_mut(node_id).unwrap().active = false;
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
            if node.active {
                let view = NodeView {
                    node,
                    edges: &self.edges,
                };
                writeln!(f, "{:?}", view)?;
            }
        }
        writeln!(f, "Edges:")?;
        for edge in &self.edges {
            if edge.active {
                writeln!(f, "{:?}", edge)?;
            }
        }
        Ok(())
    }
}
