include("../src/KnapsackProblem.jl")

using .KnapsackProblem

allThings = [Thing(2, 1), Thing(3, 4), Thing(1, 1)] # random things

const max_weight = 4

println(generate_tree(allThings, max_weight))
