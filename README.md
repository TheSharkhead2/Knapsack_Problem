# The Knapsack Problem - An Exploration of Dynamic Programming

When asking my teacher for any recommendations for exploring dynamic programming, I was turned towards this problem. I figured that I would make this project to document my work through this problem. As of right now (writing this introduction section) I have done zero work/research on this problem, but I have seen the problem statement. For thoroughness, I will restate the problem here. 

## The Problem 

Essentially, the idea of this problem is that you are some kind of traveler/theif/Indiana Jones type who has some kind of bag/knapsack. This bag can only fit a certain volume/weight of objects until nothing else can fit inside. Throughout your travels, you fill this bag with various items that weight different amounts and are worth different amounts. The question is, what is the most optimal way of filling up your bag such that you get the most value? 

My goal with this project is to come to some form of dynamic programming solution which I have been told exists for this problem. 

## Finding a Solution 

Note from after getting halfway through this: this isn't a dynamic programming solution, but it should work, so I will implement this as a reference. 

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

I just talked with my teacher about this solution and I have been told, and after staring at a graph for like 2 hours agree, that this is not a great solution. However, to have a baseline solution to this problem (that isn't dynamic programming, but should work) I am going to implement this. Another thing I was told is that I misinterpreted the problem, and there are limits on the amount of each item you can take... which makes sense, but I totally disregarded I guess. That is something I am going to need to worry about now. I also spent a bit of time thinking about my branch culling I suggested earlier and think that might speed this up, so maybe I try implementing that as well and comparing it to the dynamic programming solution I come up with later. Anyway, for now, back to our usually scheduled programming: 

## The **Dynamic Programming** Solution

So how can we think about approaching this from a dynamic programming perspective? Well, we want to think about how we would break down a step into smaller sub-steps. What would a "previous step" be in this context? Essentially the bad with one less item in it. So the best bag with a given number of items in it is the best of all the bags without one of the items plus a new item. 

In slightly more precise language, we could say that we have some function ```b(w)``` that for some weight ```w```, it returns the "best value for that weight. Well we could break down this function into the smaller weights that would have had to come before it: 
```
b(w) = max(v_1 + b[w-w_1] + ... + v_n + b[w-w_n])
```
Essentially, find the best value of all the previous possible weight steps when adding the value of the object that corresponds to jumping to this new weight. We can then break down all the functions in this new expression and break down the functions in those and so on. 

Of course, we should add that the best value for a situation with no previous weights is just 0 as this means this is the base weight. 

So with that out of the way, how would we approach creating this algorithm? Well, we would have to look at all the weights between 0 and the maximum weight of a given situation. We then have to look at what happens for any given weight if we add another item. 

So how would this play out? Well we can start with weight 0, and because 0 weight means 0 items, this has 0 value so the best you can do is... 0 value. That was the easy case, now for all following weights we say, for each item, if I went back to the maximum score for our current weight minus the weight of this item and add the value of this item to the value then is this a larger value or was it a larger value for the previous item at this weight? 

This is very hard to explain, and I am not doing a good job of it, but I think I understand how to implement it so I am going to do that. 

We start the implementation by making some objects to hold information: 
```julia
struct Thing
    value::Int
    weight::Int
    maxN::Int # the max of this item you can have
end # Thing

struct Situation
    maxWeight::Int
    things::Vector{Thing}
end # Situation
```

These are largely just data storage to make the code a bit more readable and easier on me. Essentially, we are just storing the max weight of the knapsack, the various things you can pick up, and how many of each thing there is. Basically, just the parameters for a given senario. 

So now onto the actual algorithm. We want to go through all the possible weights and then all the possible things and then store information about each of those combinations. Therefore, a matrix of size numberThings x weight would be a helpful storage device: 
```julia 
scores = Int.(zeros(length(situation.things)+1, situation.maxWeight+1))
```

This will be a matrix where we just store the max score for each position in the matrix. For simplicity, we also probably want to store what combination of items we are using at each location. For that we can use a new matrix: 
```julia 
blankTuple = Tuple((0 for i in situation.things)) 

thingTotals = fill(blankTuple, (length(situation.things)+1, situation.maxWeight+1)) 
```

Essentially what I am doing here is creating a blank Tuple with integer entries for each of the Things. Whenever we add one Thing to a certain position, we can just increment that position in the Tuple by 1. I am putting all these Tuples into another matrix of the same size as the previous scores matrix. 

Now this does present my main issue with my algorithm: This list comprehension: ```Tuple((0 for i in situation.things)) ```. I'll get to why more later, but essentially I couldn't think of a way to update just one of the indices of the Tuple without another list comprehension... Which technically could slow the algorithm down a ton with a lot of items. But I haven't benchmarked this yet, so we hope Julia has some cool caching that makes list comprehension much better in this instance. If not, this is a place where I definitely know there is an issue and I know what I have to do to improve it. 

Anyway, we now loop through all the entries in the matrix and calculate the optimal score for each weight and thing. We start our loop by making sure that the item can even fit within this weight of knapsack: 
```julia
for w in 1:situation.maxWeight 
    for (thingIndex, thing) in enumerate(situation.things) 
        if w-thing.weight >= 0 
            
        end 
    end 
end
```

This would be solved anyway due to the way the rest of the loop is programmed; however, there really isn't any point in checking to see all the previous weights and then seeing if you can add this current weight if you just couldn't add the thing if the bag was empty. It is just never possible. Therefore, this if statement is purely to remove checking these trivial cases. 

Once this check has been completed, we know we can safely "remove" this item and we won't be left with negative weight. So we look at the values for the knapsack when this weight is removed: 
```julia 
for w in 1:situation.maxWeight 
    for (thingIndex, thing) in enumerate(situation.things) 
        if w-thing.weight >= 0 
            previousValues = scores[1:length(situation.things)+1, w-thing.weight+1]
        end 
    end 
end
```

For clarity from now on, I am only going to put the code in the loop as most of the algorithm takes place in the loop. So here is the new code: 
```julia
previousValues = scores[1:length(situation.things)+1, w-thing.weight+1]
```

This is very simply just grabbing the column in the scores matrix that represents taking away the weight of the current thing. It isn't too complicated. The reason we do this, is we can then find the maximum value in this slice: 
```julia 
previousValues = scores[1:length(situation.things)+1, w-thing.weight+1]

maxValue = findmax(previousValues)
```

Here the ```findmax()``` command gives us the index and the maximum value for the vector. Very handy.