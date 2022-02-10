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