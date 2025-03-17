use std::collections::{HashMap, HashSet};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct NodeIndex(pub usize);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct EdgeIndex(pub usize);

#[derive(Debug, Clone, PartialEq)]
pub enum SpiderType {
    Z,
    X,
}

#[derive(Debug, Clone, PartialEq)]
pub enum EdgeType {
    Regular,
    Hadamard,
}

#[derive(Debug)]
pub struct ZXGraph {
    pub nodes: Vec<Option<Node>>,
    pub edges: Vec<Option<Edge>>,
    pub free_nodes: Vec<usize>,
    pub free_edges: Vec<usize>,
    pub input_nodes: HashSet<NodeIndex>,
    pub output_nodes: HashSet<NodeIndex>,
}

#[derive(Debug, Clone)]
pub struct Node {
    pub spider_type: SpiderType,
    pub phase: f64,
    pub edges: HashSet<EdgeIndex>,
}

#[derive(Debug)]
pub struct Edge {
    pub endpoints: (NodeIndex, NodeIndex),
    pub edge_type: EdgeType,
}

impl ZXGraph {
    pub fn new() -> Self {
        ZXGraph {
            nodes: Vec::new(),
            edges: Vec::new(),
            free_nodes: Vec::new(),
            free_edges: Vec::new(),
            input_nodes: HashSet::new(),
            output_nodes: HashSet::new(), 
        }
    }

    pub fn add_node(&mut self, spider_type: SpiderType, phase: f64) -> NodeIndex {
        let idx = if let Some(idx) = self.free_nodes.pop() {
            self.nodes[idx] = Some(Node {
                spider_type,
                phase,
                edges: HashSet::new(),
            });
            idx
        } else {
            self.nodes.push(Some(Node {
                spider_type,
                phase,
                edges: HashSet::new(),
            }));
            self.nodes.len() - 1
        };
        NodeIndex(idx)
    }

    pub fn add_input_node(&mut self, spider_type: SpiderType, phase: f64) -> NodeIndex {
        let node_idx = self.add_node(spider_type, phase);
        self.input_nodes.insert(node_idx);
        node_idx
    }

    pub fn set_as_input(&mut self, node_idx: NodeIndex) {
        if node_idx.0 < self.nodes.len() && self.nodes[node_idx.0].is_some() {
            self.input_nodes.insert(node_idx);
        }
    }

    pub fn unset_as_input(&mut self, node_idx: NodeIndex) {
        self.input_nodes.remove(&node_idx);
    }

    pub fn is_input_node(&self, node_idx: NodeIndex) -> bool {
        self.input_nodes.contains(&node_idx)
    }

    pub fn add_output_node(&mut self, spider_type: SpiderType, phase: f64) -> NodeIndex {
        let node_idx = self.add_node(spider_type, phase);
        self.output_nodes.insert(node_idx);
        node_idx
    }

    pub fn set_as_output(&mut self, node_idx: NodeIndex) {
        if node_idx.0 < self.nodes.len() && self.nodes[node_idx.0].is_some() {
            self.output_nodes.insert(node_idx);
        }
    }

    pub fn unset_as_output(&mut self, node_idx: NodeIndex) {
        self.output_nodes.remove(&node_idx);
    }

    pub fn is_output_node(&self, node_idx: NodeIndex) -> bool {
        self.output_nodes.contains(&node_idx)
    }

    pub fn remove_node(&mut self, idx: NodeIndex) {
        if let Some(node) = self.nodes[idx.0].take() {
            for edge_idx in node.edges {
                self.remove_edge(edge_idx);
            }
            self.free_nodes.push(idx.0);
            
            self.input_nodes.remove(&idx);
            self.output_nodes.remove(&idx);
        }
    }

    pub fn add_edge(&mut self, a: NodeIndex, b: NodeIndex, edge_type: EdgeType) -> EdgeIndex {
        let edge_idx = if let Some(idx) = self.free_edges.pop() {
            self.edges[idx] = Some(Edge {
                endpoints: (a, b),
                edge_type,
            });
            idx
        } else {
            self.edges.push(Some(Edge {
                endpoints: (a, b),
                edge_type,
            }));
            self.edges.len() - 1
        };

        if let Some(node) = &mut self.nodes[a.0] {
            node.edges.insert(EdgeIndex(edge_idx));
        }
        if let Some(node) = &mut self.nodes[b.0] {
            node.edges.insert(EdgeIndex(edge_idx));
        }

        EdgeIndex(edge_idx)
    }

    pub fn remove_edge(&mut self, edge_idx: EdgeIndex) {
        if let Some(edge) = self.edges[edge_idx.0].take() {
            if let Some(node) = &mut self.nodes[edge.endpoints.0.0] {
                node.edges.remove(&edge_idx);
            }
            if let Some(node) = &mut self.nodes[edge.endpoints.1.0] {
                node.edges.remove(&edge_idx);
            }
            self.free_edges.push(edge_idx.0);
        }
    }

    pub fn neighbors(&self, idx: NodeIndex) -> Vec<NodeIndex> {
        let mut neighbors = Vec::new();
        if let Some(node) = &self.nodes[idx.0] {
            for edge_idx in &node.edges {
                if let Some(edge) = &self.edges[edge_idx.0] {
                    let other = if edge.endpoints.0 == idx {
                        edge.endpoints.1
                    } else {
                        edge.endpoints.0
                    };
                    neighbors.push(other);
                }
            }
        }
        neighbors
    }

    pub fn node_data(&self, idx: NodeIndex) -> Option<(&SpiderType, &f64)> {
        self.nodes[idx.0]
            .as_ref()
            .map(|n| (&n.spider_type, &n.phase))
    }

    pub fn edge_data(&self, idx: EdgeIndex) -> Option<&EdgeType> {
        self.edges[idx.0].as_ref().map(|e| &e.edge_type)
    }

    /// Returns the number of fusion operations performed
    pub fn fuse_spiders(&mut self) -> usize {
        let mut fusion_count = 0;
        
        loop {
            let fusion_candidate = self.find_fusion_candidate();
            
            if let Some((node1, node2, edge_idx)) = fusion_candidate {
                self.fuse_spider_pair(node1, node2, edge_idx);
                fusion_count += 1;
            } else {
                break;
            }
        }
        
        fusion_count
    }
    
    fn find_fusion_candidate(&self) -> Option<(NodeIndex, NodeIndex, EdgeIndex)> {
        for (i, edge_opt) in self.edges.iter().enumerate() {
            if let Some(edge) = edge_opt {
                if let EdgeType::Regular = edge.edge_type {
                    let node1 = edge.endpoints.0;
                    let node2 = edge.endpoints.1;
                    
                    if node1 == node2 {
                        continue;
                    }
                    
                    if let (Some((type1, _)), Some((type2, _))) = 
                            (self.node_data(node1), self.node_data(node2)) {
                        if type1 == type2 {
                            return Some((node1, node2, EdgeIndex(i)));
                        }
                    }
                }
            }
        }
        
        None
    }
    
    fn fuse_spider_pair(&mut self, node1: NodeIndex, node2: NodeIndex, edge_idx: EdgeIndex) {
        let mut node1_data = self.nodes[node1.0].clone().unwrap();
        let node2_data = self.nodes[node2.0].clone().unwrap();
        
        let new_phase = normalize_phase(node1_data.phase + node2_data.phase);
        
        node1_data.phase = new_phase;
        self.nodes[node1.0] = Some(node1_data.clone());
        
        let mut edges_to_reconnect = Vec::new();
        
        for &e_idx in &node2_data.edges {
            if e_idx != edge_idx {
                if let Some(edge) = &self.edges[e_idx.0] {
                    let other_end = if edge.endpoints.0 == node2 {
                        edge.endpoints.1
                    } else {
                        edge.endpoints.0
                    };
                    
                    edges_to_reconnect.push((e_idx, other_end, edge.edge_type.clone()));
                }
            }
        }
        
        self.remove_edge(edge_idx);
        
        for (old_edge_idx, other_node, edge_type) in edges_to_reconnect {
            self.remove_edge(old_edge_idx);
            
            if other_node != node1 {
                self.add_edge(node1, other_node, edge_type);
            }
        }
        
        self.remove_node(node2);
    }
}

fn normalize_phase(phase: f64) -> f64 {
    const TWO_PI: f64 = std::f64::consts::PI * 2.0;
    let mut normalized = phase % TWO_PI;
    if normalized < 0.0 {
        normalized += TWO_PI;
    }
    normalized
}
