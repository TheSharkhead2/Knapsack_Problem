include("../src/KnapsackDynamicProgramming.jl")

using .KnapsackDynamicProgramming

using BenchmarkTools

const maxValue = 100 
const maxWeight = 100 

"""
Generates a bunch of random things. n of them

"""
function generate_things(n::Int, maxWeight::Int, maxValue::Int, maxNumber::Int)
    things = Vector{Thing}()

    for i ∈ 1:n 
        weight = rand(1:maxWeight)
        value = rand(1:maxValue)
        number = rand(1:maxNumber)

        push!(things, Thing(weight, value, number))
    end # for 

    things 
end # function generate_things

if length(ARGS) < 2 # need two arguments for number of things and weight 
    throw(DomainError(ARGS, "Expecting two arguments: [number of things] [total weight]"))
else 
    nThings = parse(Int, ARGS[1])
    totalWeight = parse(Int, ARGS[2]) # the weight the knapsack can hold

    things = generate_things(nThings, maxWeight, maxValue, div(totalWeight, 20))

    println("Testing with the Things: ", things)

    situation = Situation(totalWeight, things)

    println(@benchmark get_best_items(situation))
end # if 

