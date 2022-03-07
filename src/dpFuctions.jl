"""
Function to find the ideal items to put into the Knapsack in the knapsack
problem. Implemented with the dynamic programming solution. 

"""
function get_best_items(situation::Situation)
    # matrix to store all of the values for each item and weight. 
    scores = Int.(zeros(length(situation.things)+1, situation.maxWeight+1))

    blankTuple = Tuple(Int.(zeros(length(situation.things)))) # blank tuple to fill matrix with which counts number of each item at each index

    thingTotals = fill(blankTuple, (length(situation.things)+1, situation.maxWeight+1)) # matrix of the same size with a bunch of tuples counting the number of each item at each position. Currently all 0 to initialize matrix

    for w in 1:situation.maxWeight # loop through all the possible weights in the situation
        for (thingIndex, thing) in enumerate(situation.things) # loop through all the things 
            if w-thing.weight >= 0 # make sure you can fit thing into knapsack 
                previousValues = scores[1:length(situation.things)+1, w-thing.weight+1] # get all the values from the weight when "removing" this thing 

                newTotals = getfield.(thingTotals[1:length(situation.things)+1, w-thing.weight+1], thingIndex) .+ 1
                totalsDifferences = newTotals .- thing.maxN
                previousValuesOver = totalsDifferences .< 0

                println(thingTotals[1:length(situation.things)+1, w-thing.weight+1])
                println(newTotals)
                println(totalsDifferences)
                println(previousValuesOver)

                previousValuesIncreased = previousValues + (previousValuesOver * thing.value) # add the value of the thing to the previous values if there are enough of the thing

                # get the max value of the values 
                maxValue = findmax(previousValuesIncreased) # get maximum value and its index

                if previousValuesOver[maxValue[2]] == 1 # if you could fit another thing in and so we are adding a thing, then make sure that is updated 
                    scores[thingIndex+1, w+1] = maxValue[1] # set the value at this index to the maximum value of the previous values added to the things value
                    
                    previousTotals = thingTotals[maxValue[2], w-thing.weight+1]

                    thingTotals[thingIndex+1, w+1] = (previousTotals[1:thingIndex-1]..., previousTotals[thingIndex]+1, previousTotals[thingIndex+1:length(previousTotals)]...)
                else # otherwise you don't have to update the thingTotals
                    scores[thingIndex+1, w+1] = maxValue[1] # set the value of the thing at this weight to the max value (so the previous best)

                    thingTotals[thingIndex+1, w+1] = thingTotals[maxValue[2], w-thing.weight+1] # set the thingTotals to the thingTotals of the previous weight (nothing was updated)
                end # if
            end # if 
        end # for
    end # for

    maxScore = findmax(scores[1:length(situation.things)+1, situation.maxWeight+1]) # get the max value and index of the last row of scores (this would be the ideal score)

    thingComb = thingTotals[maxScore[2], situation.maxWeight+1] # get the thing combination of the max score

    (maxScore[1], thingComb)

end # function get_best_items

