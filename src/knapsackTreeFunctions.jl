""" 
A function which forks a given node into the number of children there are 
things. Won't create a child if that child would be too expensive. Returns
true on success and false if all children are too expensive.

# Parameters

    node::TreeNode
        The node to fork.

    things::Vector{Thing}
        A list of all things in the senario 
    
    maxWeight::Int
        The maximum weight of a child.

# Returns

    Bool
        True if the node was forked, false if it was too expensive.

"""
function fork!(node::TreeNode, things::Vector{Thing}, maxWeight::Int)
    oneInsert = false # keep track if one child was created
    # loop through all things and add them as children if they are legal
    for thing in things
        if (node.weight + thing.weight) <= maxWeight # check weight 
            push!(node.children, TreeNode(Vector{TreeNode}(), (node.weight + thing.weight), (node.value + thing.value), thing)) # add child
            oneInsert = true
        end # if 

    end # for 

    oneInsert # return if one child was created

end # function fork!

"""
Function to create a tree. 

# Parameters

    things::Vector{Thing}
        A list of all things in the senario 
    
    maxWeight::Int
        The maximum weight of the knapsack 

# Returns

    tree::KnapsackTree
        The root of the tree.

"""
function create_tree(things::Vector{Thing}, maxWeight::Int)
    initialChildren = Vector{TreeNode}() # create initial children list
    for thing in things # loop through all things and create children 
        if thing.weight <= maxWeight # check weight 
            push!(initialChildren, TreeNode(Vector{TreeNode}(), thing.weight, thing.value, thing)) # add child
        end # if
    end # for

    KnapsackTree(initialChildren, things, maxWeight) # create root

end # function create_tree

""" 
Function to propagate children of tree into more children and so on. Will
be called recursively until all children are created.

# Parameters

    node::TreeNode
        The node to fork.

    things::Vector{Thing}
        A list of all things in the senario

    maxWeight::Int
        The maximum weight of a child.
        

"""
function propagate_children!(node::TreeNode, things::Vector{Thing}, maxWeight::Int)
    # loop through all children and fork them
    inserted = fork!(node, things, maxWeight) # for the node

    if any(inserted) # if one child was created
        propagate_children!.(node.children, (things,), maxWeight) # propagate children
    end # if

end # function propagate_children

"""
Final function to create tree, propagate all possibilities, and return the
tree

"""
function generate_tree(things::Vector{Thing}, maxWeight::Int)
    tree = create_tree(things, maxWeight) # create tree
    propagate_children!.(tree.children, (things,), maxWeight) # propagate children
    tree # return tree

end # function generate_tree