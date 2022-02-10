""" 
A given node on the tree. It has a certain number of children, a weight, and
a value. 

"""
mutable struct TreeNode 
    children::Vector{TreeNode}
    weight::Int
    value::Int
    thing::Thing # the thing that this node represents
end # TreeNode

""" 
The base of the tree 

"""
mutable struct KnapsackTree 
    children::Vector{TreeNode}
    things::Vector{Thing} # the things in the senario
    maxWeight::Int # the maximum weight of the knapsack
end # KnapsackTree


