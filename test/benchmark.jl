include("../src/KnapsackDynamicProgramming.jl")

using .KnapsackDynamicProgramming

using BenchmarkTools

const maxValue = 100 
const maxWeight = 100 

"""
Generates a bunch of random things. n of them

"""
function generate_things(n::Int, maxWeight::Int, maxValue::Int, maxNumber::Int; maxNumberConst::Bool=false)
    things = Vector{Thing}()

    for i ∈ 1:n 
        weight = rand(1:maxWeight)
        value = rand(1:maxValue)
        if maxNumberConst 
            number = maxNumber
        else
            number = rand(1:maxNumber)
        end # if 

        push!(things, Thing(weight, value, number))
    end # for 

    things 
end # function generate_things

if length(ARGS) < 3 # need two arguments for number of things and weight 
    throw(DomainError(ARGS, "Expecting three arguments: [number of things] [max number of a thing] [total weight]"))
else 
    nThings = parse(Int, ARGS[1])
    maxNumber = parse(Int, ARGS[2])
    totalWeight = parse(Int, ARGS[3])
    
    println("number of things: ", nThings)
    println("max number of a thing: ", maxNumber)
    println("max weight: ", totalWeight)

    println("Benchmarked runtime: ")
    # println(@benchmark get_best_items(x) setup=(x=Situation(totalWeight, generate_things(nThings, maxWeight, maxValue, div(totalWeight, 20)))))

    situation = Situation(totalWeight, generate_things(nThings, maxWeight, maxValue, maxNumber), maxNumber)
    println(@benchmark bounded_dp_knapsack(situation))

end # if 


