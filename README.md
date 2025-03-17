# Quojo
A Quantum Computing Simulation written in Mojo. This really only serves as one of my passion projects, but I would like it to expand into a larger platform for Quantum Development.

## Goals
This project aims to implement classical strong simulation for quantum circuits with Parametric Rewriting in ZX-Calculus ([Paper](https://arxiv.org/pdf/2403.06777)) using the Mojo and Max Engine APIs to accelerate computation.

I'm deferring development to Rust at the moment while we wait for Mojo to have the features I'd like it to have. 

Check out [Quojo-Rust](./quojo-rust/docs/README.md)

## Current Features:
- Circuit construction.
- ZX Graph construction.
- Circuit and Graph visualization in Tikz.

## TODO:
- Implement custom unitaries.
- Implement more graph rewriting.
- Implement circuit to graph conversion.
- Implement simulation.

## References
Sutcliffe, Matthew, and Aleks Kissinger. "Fast classical simulation of quantum circuits via parametric rewriting in the ZX-calculus." arXiv preprint arXiv:2403.06777 (2024).

```tex
@misc{sutcliffe2025fastclassicalsimulationquantum,
      title={Fast classical simulation of quantum circuits via parametric rewriting in the ZX-calculus}, 
      author={Matthew Sutcliffe and Aleks Kissinger},
      year={2025},
      eprint={2403.06777},
      archivePrefix={arXiv},
      primaryClass={quant-ph},
      url={https://arxiv.org/abs/2403.06777}, 
}
```
van de Wetering, John. "ZX-calculus for the working quantum computer scientist." arXiv preprint arXiv:2012.13966 (2020).

```tex
@misc{vandewetering2020zxcalculusworkingquantumcomputer,
      title={ZX-calculus for the working quantum computer scientist}, 
      author={John van de Wetering},
      year={2020},
      eprint={2012.13966},
      archivePrefix={arXiv},
      primaryClass={quant-ph},
      url={https://arxiv.org/abs/2012.13966}, 
}
```
