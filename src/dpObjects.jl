"""
A Thing object which is just an item you can put into the knapsack. 

"""
struct Thing
    value::Int
    weight::Int
    maxN::Int # the max of this item you can have
end # Thing

"""
Knapsack situation object to keep track of given problem information

"""
struct Situation
    maxWeight::Int
    things::Vector{Thing}
end # Situation