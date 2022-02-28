"""
Function to find the ideal items to put into the Knapsack in the knapsack
problem. Implemented with the dynamic programming solution. 

"""
function get_best_items(situation::Situation)
    # matrix to store all of the values for each item and weight. 
    scores = Int.(zeros(length(situation.things)+1, situation.maxWeight+1))

    blankTuple = Tuple((0 for i in situation.things)) # blank tuple to fill matrix with which counts number of each item at each index

    thingTotals = fill(blankTuple, (length(situation.things)+1, situation.maxWeight+1)) # matrix of the same size with a bunch of tuples counting the number of each item at each position. Currently all 0 to initialize matrix

    for w in 1:situation.maxWeight # loop through all the possible weights in the situation
        for (thingIndex, thing) in enumerate(situation.things) # loop through all the things 
            if w-thing.weight >= 0 # make sure you can fit thing into knapsack 
                previousValues = scores[1:length(situation.things)+1, w-thing.weight+1] # get all the values from the weight when "removing" this thing 

                # get the max value of the values 
                maxValue = findmax(previousValues) # get maximum value and its index

                if thingTotals[thingIndex+1, w+1][thingIndex] + 1 <= thing.maxN # make sure you have enough of the item
                    scores[thingIndex+1, w+1] = maxValue[1] + thing.value # set the value of the thing at this weight to the max value
                    
                    thingTotals[thingIndex+1, w+1] = Tuple(( index == thingIndex ? value+1 : value for (index, value) in enumerate(thingTotals[thingIndex+1, w-thing.weight+1]))) # add one to the total of the thing just added
                else 
                    scores[thingIndex+1, w+1] = maxValue[1] # set the value of the thing at this weight to the max value (so the previous best)

                    thingTotals[thingIndex+1, w+1] = thingTotals[thingIndex+1, w-thing.weight+1] # set the thingTotals to the thingTotals of the previous weight (nothing was updated)
                end # if


            end # if 

        end # for
    end # for

end # function get_best_items

