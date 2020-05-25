# modulus
Open Platform for Modular Structures and Architecture in Swift


*Interface*

Represents one view (plan, rotated plan, front, side) of the structure in 2D.

Generics
Holder
Holder is a “graph” representation of the structure, and generic so that different structures such as Scaff, Tent, Cube, etc can use this same 2D view and logic. 

InterfaceState<Tent>
InterfaceState<Scaff>
InterfaceState<Cube>

graph 
GenericEditingView
