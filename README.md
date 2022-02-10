# The Knapsack Problem - An Exploration of Dynamic Programming

When asking my teacher for any recommendations for exploring dynamic programming, I was turned towards this problem. I figured that I would make this project to document my work through this problem. As of right now (writing this introduction section) I have done zero work/research on this problem, but I have seen the problem statement. For thoroughness, I will restate the problem here. 

## The Problem 

Essentially, the idea of this problem is that you are some kind of traveler/theif/Indiana Jones type who has some kind of bag/knapsack. This bag can only fit a certain volume/weight of objects until nothing else can fit inside. Throughout your travels, you fill this bag with various items that weight different amounts and are worth different amounts. The question is, what is the most optimal way of filling up your bag such that you get the most value? 

My goal with this project is to come to some form of dynamic programming solution which I have been told exists for this problem. 

## Finding a Solution 

I am going to start trying to find a solution by first creating an environment for the situation. I think I am going to need the knapsack, various objects, and a way to put objects into the knapsack. 

Alright, now I have a knapsack object: 
```julia
mutable struct Knapsack 
    maxWeight::Int
    currentWeight::Int 
    currentValue::Int
    things::Vector{Thing}
end # Knapsack
```

And a "thing" object: 
```julia
struct Thing 
    weight::Int
    value::Int
end # Thing
```

I will probably need a way to insert objects into the knapsack. So, I will make an insert function: 
```julia
function insert!(knapsack::Knapsack, thing::Thing)
    if (knapsack.currentWeight + thing.weight) <= knapsack.maxWeight 
        push!(knapsack.things, thing) # add thing to knapsack
        knapsack.currentWeight += thing.weight # add weight 
        knapsack.currentValue += thing.value # add value 

        return true
    else 
        return false # Knapsack is too heavy
    end # if
end # insert!
```

So now I actually need to do some thinking. My first thought is that I could make some form of tree, at each node there are children for the different items that could be added. We then just take the value from the parent node and add the value of the added item in the child node to get the value of the child node. Once the entire tree is constructed, we just get the smallest value on the bottom row. 

I feel like this should speed up the otherwise brute force, factorial like scaling of a bad solution to this problem at least somewhat. Naively (or maybe not?) this would run in some form of log time relative to the size of the knapsack. My only issue with this is I feel like there is optimization to be had in "remembering" the value of [sword, sheild] when you need the value of [sheild, sword]. My proposed tree approach wouldn't remember this and would have to calculate each value seperately. 

Thinking about it a little bit, I am not convinced this solution would work, but basically I am thinking that I could add a "counter" to each of the children of a given node. This counter inhibits the node from branching off to a different object for a certain number of levels. I haven't entirely thought it through, and I am not sure if it would work, but I think that is a possible idea in the future if the tree approach is... not amazing. 

For now, I want to try this tree approach, and despite the fact that I wrote the above code, I think I am going to create a new way of representing everything... Woo. 

New objects because the old ones would have been to hard to carry around on a tree... The base of the tree: 
```julia
mutable struct KnapsackTree 
    children::Vector{TreeNode}
    things::Vector{Thing} # the things in the senario
    maxWeight::Int # the maximum weight of the knapsack
end # KnapsackTree
```
Super interesting right? And the nodes for the tree: 
```julia
mutable struct TreeNode 
    children::Vector{TreeNode}
    weight::Int
    value::Int
    thing::Thing # the thing that this node represents
end # TreeNode
```

The nodes are at least a little bit more interesting. Essentially my plan is to keep a running tally of the weight and value in each node and then from each node split into however many objects there are children nodes and run from there. 

The first function I think I should create is a ```fork!()``` function. Basically, a function which takes a given node, a list of the things, and then gives the node the appropriate number of children. 

So, after getting carried away for a while and doing a bunch of the implementation, I have a program that I believe accurately generates the tree I wanted. Here is what I made: first, like I said, I made a ```fork!()``` function: 
```julia
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
```
All this function really does is it takes a given tree node and adds a new node under it for each "Thing" that will fit (within weight restrictions). It updates the weight and height and then returns if it ever actuall added something (so if the knapsack can no longer carry things, this returns ```false```). 

I then (slightly out of order of what actually happened, but for this story to make sense) created a ```propagate_children!()``` function:
```julia 
function propagate_children!(node::TreeNode, things::Vector{Thing}, maxWeight::Int)
    # loop through all children and fork them
    inserted = fork!(node, things, maxWeight) # for the node

    if any(inserted) # if one child was created
        propagate_children!.(node.children, (things,), maxWeight) # propagate children
    end # if

end # function propagate_children
```
This is essentially just a wrapper for the ```fork!()``` function that takes in a node, runs ```fork!()``` on the node, and then if it was actually forked (remember those Bools I returned earlier?) it runs itself recursively on all its children (Julia has really nice vectorization, so I just have to add that ```.```). Cool! So this in itself should be able to generate the entire tree I need, but I just added some convenience functions around it to create the inital tree: 
```julia
function create_tree(things::Vector{Thing}, maxWeight::Int)
    initialChildren = Vector{TreeNode}() # create initial children list
    for thing in things # loop through all things and create children 
        if thing.weight <= maxWeight # check weight 
            push!(initialChildren, TreeNode(Vector{TreeNode}(), thing.weight, thing.value, thing)) # add child
        end # if
    end # for

    KnapsackTree(initialChildren, things, maxWeight) # create root

end # function create_tree
```
And to put everything together and just give me the final tree:
```julia
function generate_tree(things::Vector{Thing}, maxWeight::Int)
    tree = create_tree(things, maxWeight) # create tree
    propagate_children!.(tree.children, (things,), maxWeight) # propagate children
    tree # return tree

end # function generate_tree
```
Essentially unimportant functions that just make calling things easier. I tested all of this in the ```test/treeGeneration.jl``` file, and it seems to work how I expected. Code for easier reference:
```julia
allThings = [Thing(2, 1), Thing(3, 4), Thing(1, 1)] # random things

const max_weight = 4

println(generate_tree(allThings, max_weight))
```

Okay now, as a final step, I just need to get the highest value ```TreeNode``` at the bottom of the tree... Probably the best way of doing this is propagating up another value for the maximum value of the children of a given node. So I will go tinker with that until I get something working... 

I just talked with my teacher about this solution and I have been told, and after staring at a graph for like 2 hours agree, that this is not a great solution. However, to have a baseline solution to this problem (that isn't dynamic programming, but should work) I am going to implement this. I also spent a bit of time thinking about my branch culling I suggested earlier and think that might speed this up, so maybe I try implementing that as well and comparing it to the dynamic programming solution I come up with later. Anyway, for now, back to our usually scheduled programming: 

