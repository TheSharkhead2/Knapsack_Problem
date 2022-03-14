include("../src/KnapsackDynamicProgramming.jl")

using .KnapsackDynamicProgramming

allThings = [Thing(2, 1, 1), Thing(3, 2, 3), Thing(4, 5, 2)]

situation = Situation(10, allThings, 3)

println(bounded_dp_knapsack(situation))