""" 
Function for inserting a Thing into a Knapsack. Will compute new value and 
weight of the Knapsack. Won't insert if Knapsack would be too heavy. 

# Parameters

    knapsack::Knapsack
        The Knapsack to insert the Thing into.

    thing::Thing
        The Thing to insert.

# Returns 

    completed::Bool
        True if the Thing was inserted, False otherwise.

"""
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
