
""" 
The "bag" for this situation. This will keep track of the objects within it,
the maximum weight it can carry, the total weight of the objects currently
within, and the current value of the objects.

"""
mutable struct Knapsack 
    maxWeight::Int
    currentWeight::Int 
    currentValue::Int
    things::Vector{Thing}
end # Knapsack


"""
A "thing" is a single item in the knapsack. It has a weight and a value.

"""
struct Thing 
    weight::Int
    value::Int
end # Thing