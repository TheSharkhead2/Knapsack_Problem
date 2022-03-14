[![wakatime](https://wakatime.com/badge/user/75e033f5-beb6-4359-afae-db8209348d42/project/1a7382d6-4ae6-4ecf-9757-88ba135c5297.svg)](https://wakatime.com/badge/user/75e033f5-beb6-4359-afae-db8209348d42/project/1a7382d6-4ae6-4ecf-9757-88ba135c5297)
# The Knapsack Problem - An Exploration of Dynamic Programming

When asking my teacher for any recommendations for exploring dynamic programming, I was turned towards this problem. I figured that I would make this project to document my work through this problem. As of right now (writing this introduction section) I have done zero work/research on this problem, but I have seen the problem statement. For thoroughness, I will restate the problem here. 

Note: I tried about 4 times to write a solution to this, only succeeding on my last one. My [first attempt](#finding-a-solution-not-dynamic-programming) was definitely not a dynamic programming solution. It was basically a brute force method, but I wrote up my thought process on it so I decided to keep it (I just moved it to the end, the link should take you there). I then did a little bit of research (only to get a general idea) and [tried again](#the-wrong-dynamic-programming-solution). This seemed to produce correct results (though I now doubt that) but didn't run in linear time with increasing the number of Things, so it was wrong. I then did a little bit more research and properly sat down to think through the 0-1 knapsack problem (there were no resources I could find on the bounded knapsack problem which I was working on). After that, I finally understood what I had to do and implemented it, as far as I can tell, [accurately](#attempt-at-a-solution-3). If you just want to see my correct attempt, go to [this link](#attempt-at-a-solution-3) and read that section as well as the [section where I test that algorithm](#testing-our-algorithm-v3). Otherwise, read it through how you like, just know that **a large majority of it is just wrong.** I decided to keep it all in as it shows my entire process which I think is important for a project that I essentially spent 20 hours on. 

## The Problem 

Essentially, the idea of this problem is that you are some kind of traveler/theif/Indiana Jones type who has some kind of bag/knapsack. This bag can only fit a certain volume/weight of objects until nothing else can fit inside. Throughout your travels, you fill this bag with various items that weight different amounts and are worth different amounts. The question is, what is the most optimal way of filling up your bag such that you get the most value? 

My goal with this project is to come to some form of dynamic programming solution which I have been told exists for this problem. 
 

## The Wrong Dynamic Programming Solution

To preface this section: this isn't the first attempt trying to solve this. I intially was trying to work through this completely blind to the approach I needed to take. You can read more about my thought process below this soltuion under the "Finding a Solution" header. But after spending many hours thinking about this blind, I was unable to prevent myself from looking up some guidance towards a solution. Surprisingly (though really not surprisingly) this wasn't that helpful... Nothing explained the solution well. But I did get a general direction, especially from the [Wikipedia page](https://en.wikipedia.org/wiki/Knapsack_problem), and understood much better the direction I had to take. Effectively, I understood that the approach involved creating a x by W matrix (where x is the number of Things and W is the weight) and that I needed to look at the current weight minus the weight of the current thing. From there, I built the algorithm through my own understanding and direction. Anyway, end of preface.

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

This is very simply just grabbing the column in the scores matrix that represents taking away the weight of the current thing. It isn't too complicated. We now want to find out what happens when we add the value of the current thing, but we can't add the current thing to everything, so we find which previous values all us to add one of the current thing: 
```julia 
previousValuesOver = [totals[thingIndex] + 1 <= thing.maxN ? 1 : 0 for totals in thingTotals[1:length(situation.things)+1, w-thing.weight+1] ]
```

This is where the list comprehensions get concerning, but hopefully it is fine? Essentially all I am doing here is creating a vector where each index is either 1 if we can add one of the things, 0 if we can't. This means we can multiply this vector by the value of the current thing and then add this vector to the previous values to get all the possible new values by adding the current thing: 
```julia
previousValuesIncreased = previousValues + (previousValuesOver * thing.value) 
```

Now, initially, I was doing this without list comprehension and simply finding the maxmium value of the previous values, add the current value if I could, and if I couldn't then just use that max value. But I don't believe that works as you could have an instance of, say, a value of 19 where you can't add the item valued at 5, but a value of 18 where you can. Of course, 23 > 19 so my previous algorithm wouldn't work. This change should fix that. But now that we have a list of all the possible values, we just find the best one: 
```julia 
maxValue = findmax(previousValuesIncreased)
```

Now that we have an ideal value, we just need to update the scores matrix and the thingTotals matrix and call it a day. Updating the score matrix is easy, we just set the entry to the max value, but to update the thingTotals we need to check if we actually added an item for the given max value. We can do this with a simple if statement: 
```julia 
if previousValuesOver[maxValue[2]] == 1 
    scores[thingIndex+1, w+1] = maxValue[1] 
    
    thingTotals[thingIndex+1, w+1] = Tuple(( index == thingIndex ? value+1 : value for (index, value) in enumerate(thingTotals[maxValue[2], w-thing.weight+1])))
else 
    scores[thingIndex+1, w+1] = maxValue[1] 

    thingTotals[thingIndex+1, w+1] = thingTotals[maxValue[2], w-thing.weight+1]
end 
```

So, all we are doing here is checking to see if we could add the thing earlier, meaning we did, and if we did, we update the score to be the max value and we increment the correct index in the thingTotals matrix entry to reflect the addition of a new item. In the event that we didn't add a new thing, we can update the score in the same way (remember we already accounted for this) and we can just carry over the same thingTotals entry as nothing has changed. And cool, that completes our loop! Here is the code in full: 
```julia 
for w in 1:situation.maxWeight # loop through all the possible weights in the situation
    for (thingIndex, thing) in enumerate(situation.things) # loop through all the things 
        if w-thing.weight >= 0 # make sure you can fit thing into knapsack 
            previousValues = scores[1:length(situation.things)+1, w-thing.weight+1] # get all the values from the weight when "removing" this thing 

            previousValuesOver = [totals[thingIndex] + 1 <= thing.maxN ? 1 : 0 for totals in thingTotals[1:length(situation.things)+1, w-thing.weight+1] ]

            previousValuesIncreased = previousValues + (previousValuesOver * thing.value) # add the value of the thing to the previous values if there are enough of the thing

            # get the max value of the values 
            maxValue = findmax(previousValuesIncreased) # get maximum value and its index

            if previousValuesOver[maxValue[2]] == 1 # if you could fit another thing in and so we are adding a thing, then make sure that is updated 
                scores[thingIndex+1, w+1] = maxValue[1] # set the value at this index to the maximum value of the previous values added to the things value
                
                thingTotals[thingIndex+1, w+1] = Tuple(( index == thingIndex ? value+1 : value for (index, value) in enumerate(thingTotals[maxValue[2], w-thing.weight+1]))) # add one to the total of the thing just added
            else # otherwise you don't have to update the thingTotals
                scores[thingIndex+1, w+1] = maxValue[1] # set the value of the thing at this weight to the max value (so the previous best)

                thingTotals[thingIndex+1, w+1] = thingTotals[maxValue[2], w-thing.weight+1] # set the thingTotals to the thingTotals of the previous weight (nothing was updated)
            end # if
        end # if 
    end # for
end # for
```

But we aren't totally done with our algorithm just yet (though there really isn't anything left). We need to grab the best score found: 
```julia 
maxScore = findmax(scores[1:length(situation.things)+1, situation.maxWeight+1])
```

And then the corresponding combination of items: 
```julia 
thingComb = thingTotals[maxScore[2], situation.maxWeight+1]
```

And we return both of those! Woo! Here is our algorithm in full: 
```julia 
function get_best_items(situation::Situation)
    # matrix to store all of the values for each item and weight. 
    scores = Int.(zeros(length(situation.things)+1, situation.maxWeight+1))

    blankTuple = Tuple((0 for i in situation.things)) # blank tuple to fill matrix with which counts number of each item at each index

    thingTotals = fill(blankTuple, (length(situation.things)+1, situation.maxWeight+1)) # matrix of the same size with a bunch of tuples counting the number of each item at each position. Currently all 0 to initialize matrix

    for w in 1:situation.maxWeight # loop through all the possible weights in the situation
        for (thingIndex, thing) in enumerate(situation.things) # loop through all the things 
            if w-thing.weight >= 0 # make sure you can fit thing into knapsack 
                previousValues = scores[1:length(situation.things)+1, w-thing.weight+1] # get all the values from the weight when "removing" this thing 

                previousValuesOver = [totals[thingIndex] + 1 <= thing.maxN ? 1 : 0 for totals in thingTotals[1:length(situation.things)+1, w-thing.weight+1] ]

                previousValuesIncreased = previousValues + (previousValuesOver * thing.value) # add the value of the thing to the previous values if there are enough of the thing

                # get the max value of the values 
                maxValue = findmax(previousValuesIncreased) # get maximum value and its index

                if previousValuesOver[maxValue[2]] == 1 # if you could fit another thing in and so we are adding a thing, then make sure that is updated 
                    scores[thingIndex+1, w+1] = maxValue[1] # set the value at this index to the maximum value of the previous values added to the things value
                    
                    thingTotals[thingIndex+1, w+1] = Tuple(( index == thingIndex ? value+1 : value for (index, value) in enumerate(thingTotals[maxValue[2], w-thing.weight+1]))) # add one to the total of the thing just added
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
```

Which can be found in the [dpFunctions.jl](src/dpFuctions.jl) file. Though, it is all here so you don't really have to go there if you don't want to. 

## Testing my Solution 
Showing that this solution works is... Well I don't particularly want to write another algorithm that I know for sure works, and given that I believe my logic, and it appears to work, I am just going to assume my algorithm is accurate (that could be bad though, but oh well). 

Though the type of testing that is necessary is seeing if this actually runs in O(nW) time where n is the number of things and W is the weight. ALl I need to do for this is show it is linear with W and constant n and vise versa. Shouldn't be too hard. 

Creating a testing environment was fairly simple. For starters, I needed a way to generate a certain number of things so I could show scaling with that number. Hence, I created the following function: 
```julia 
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
```

All this is doing is generating a Vector containing a bunch of random things. Cool. From here, all I have to do is grab user parameters, construct the situation, and benchmark the algorithm on that situation: 
```julia
nThings = parse(Int, ARGS[1])
totalWeight = parse(Int, ARGS[2]) # the weight the knapsack can hold

things = generate_things(nThings, maxWeight, maxValue, div(totalWeight, 20))

println("Testing with the Things: ", things)

situation = Situation(totalWeight, things)

println(@benchmark get_best_items(situation))
```

Pretty simple and straightforward.

Now for my testing results. Changing the total weight of the knapsack while keeping the number of Things constant at 10, I was able to get: 
```
50 Weight → 246.9 μs
100 Weight → 1.073 ms 
150 Weight → 1.832 ms 
200 Weight → 3.433 ms
250 Weight → 4.605 ms
300 Weight → 6.021 ms 
350 Weight → 6.699 ms 
400 Weight → 7.722 ms 
450 Weight → 8.923 ms 
500 Weight → 10.132 ms
```

So it is definetly variable, but it looks pretty linear. The increase per 50 increase in weight looks like roughly 1 ms and that seems to hold. Now for testing Things. I am going to increment the number of Things while keeping weight constant at 50: 
```
10 Things → 144.6 μs
20 Things → 702 μs
30 Things → 2.141 ms 
40 Things → 2.665 ms 
50 Things → 4.976 ms 
60 Things → 4.393 ms 
70 Things → 12.748 ms
80 Things → 14.910 ms 
90 Things → 16.459 ms 
100 Things → 25.404 ms 
110 Things → 33.799 ms
```

Okay. It seems like my reliance on list comprehension is screwing me over and the relationship with Things is not linear. I have also realized that randomly generating a bunch of Things is probably not an amazing way to test this because the time taken is going to really depend on what Things we generate. Say we generate a bunch of Things that weight more than the weight of the bag, then we can do absolutely no calculations for those things (because of the one optimization I made) and therefore the algorithm goes much, much faster. If that is not the roll of items we get, then it takes much longer. While this definetly appears to be affecting my testing, I don't believe this is the actual cause of non-linear relationship to the number of Things. 

## Fixing my Solution 
So I need to fix my program such that it runs in the correct time. This is mostly going to involve removing the 3 or so list comprehensions which shouldn't be too bad. For starters, we can pretty easily remove the unimportant, non-performance impacting, initial list comprehension:
```julia
blankTuple = Tuple((0 for i in situation.things))
```
I don't know what was going through my head at the time of writing this horrendous code, but I seem to have forgotten about some of the more useful vector functions in Julia... Like: 
```julia
blankTuple = Tuple(Int.(zeros(length(situation.things))))
```
That is much better. Our next problem is this list comprehension:
```julia
previousValuesOver = [totals[thingIndex] + 1 <= thing.maxN ? 1 : 0 for totals in thingTotals[1:length(situation.things)+1, w-thing.weight+1] ]
```

Unlike the first one, this is actually reasonably contributing to performance issues and should definetly be changed. Essentially, all this is doing is finding which weights can actually have the current thing added. We should probably be able to instead use vector operations to do this much more efficiently. For starters, we are going to need the right counter for the Thing we are on. This means getting a certain index from a bunch of Tuples. Luckily, we can do this like so: 
```julia
getfield.(thingTotals[1:length(situation.things)+1, w-thing.weight+1], thingIndex)
```

This will return a new vector where each entry is simply the count for each weight for the specific thing. We can then just add one to every entry: 
```julia 
newTotals = getfield.(thingTotals[1:length(situation.things)+1, w-thing.weight+1], thingIndex) .+ 1
```

And then subtract the max number of the Thing: 
```julia 
totalsDifferences = newtotals .- thing.maxN
```

We now check to see if there is space (as in we have a negative number): 
```julia 
totalsDifferences .< 0
```

This will finally create a vector that is 0 if it is less than 0 and 1 if it is greater than 0. All combined, we have replaced the list comprehension: 
```julia 
newTotals = getfield.(thingTotals[1:length(situation.things)+1, w-thing.weight+1], thingIndex) .+ 1
totalsDifferences = newTotals .- thing.maxN
previousValuesOver = totalsDifferences .<> 0
```

Cool! And we have one more comprehension to crack down on: 
```julia 
thingTotals[thingIndex+1, w+1] = Tuple(( index == thingIndex ? value+1 : value for (index, value) in enumerate(thingTotals[maxValue[2], w-thing.weight+1]))) # add one to the total of the thing just added
```

All this is doing is incrementing the correct index (corresponding to the index representing the current Thing) by 1. This *should* be doable with splicing. 

And after a few minutes of messing around in the REPL, I have a solution! So we of course start with the previous Tuple (like we did in the comprehension solution):
```julia
thingTotals[maxValue[2], w-thing.weight+1]
```

All we have to do, a method so much simplier than the comrehension, is this: 
```julia 
thingTotals[thingIndex+1, w+1] = (thingTotals[maxValue[2], w-thing.weight+1][1:thingIndex-1]..., thingTotals[maxValue[2], w-thing.weight+1][thingIndex]+1, thingTotals[maxValue[2], w-thing.weight+1][thingIndex+1:length(thingTotals[maxValue[2], w-thing.weight+1])]... )
```

Okay, admittedly this looks quite complicated when you don't just temporary variables, so let's just do a quick subsitution: 
```julia 
previousTotals = thingTotals[maxValue[2], w-thing.weight+1]

thingTotals[thingIndex+1, w+1] = (previousTotals[1:thingIndex-1]..., previousTotals[thingIndex]+1, previousTotals[thingIndex+1:length(previousTotals)]...)
```

All we are doing here is splitting the Tuple at the thing index, incrementing the number at that index, and then putting the Tuple back together. 

And now that we have done all that, we can put all of these fixes into the code, and retest the running times!

Though first I should make sure my code has no bugs... 

And it has bugs... 

One second... 

Okay I fixed my typos now... 

## Testing my New Solution Which Previous Testing Indicated Was Necessary
Now it is time to test my new solution without comprehensions and hope that it now runs in O(nW) time (if it doesn't, I am not sure what else I need to fix). Though I do want to make some changes to my benchmarking process so it doesn't take half an hour to test all of the values... Ahem... 

Another quick thing I want to address fixing before I work on automating the other stuff is using different lists of things. As I pointed out earlier, just depending on which Things are randomly rolled, it can dramatically (well maybe not dramatically, but significantly) change the run time. Luckily, BenchmarkTools has a good method of doing this which hopefully works. I should just be able to change from:
```julia 
things = generate_things(nThings, maxWeight, maxValue, div(totalWeight, 20))

situation = Situation(totalWeight, things)

@benchmark get_best_items(situation)
```

To: 
```julia 
@benchmark get_best_items(x) setup=(x=Situation(totalWeight, generate_things(nThings, maxWeight, maxValue, div(totalWeight, 20))))
```

As I understand this, each iteration will test with a new list of Things. 

Now to get this to run a bunch of different situations to get the full spread with one file execution... 

Now this shouldn't be too difficult, just a for loop right? Well... There appears to be some issue with this code: 
```julia 
totalWeight = parse(Int, ARGS[5]) # if changing things, then last argument is max weight
maxNumber = div(totalWeight, 20)

for nThings ∈ startValue:valueChange:endValue 

    println("number of things: ", nThings)
    println("max weight: ", totalWeight)

    generate_things(nThings, maxWeight, maxValue, maxNumber)

    println("Benchmarked runtime: ")
    println(@benchmark get_best_items(x) setup=(x=Situation(totalWeight, generate_things(nThings, maxWeight, maxValue, maxNumber))))
end # for
```

Where the variable ```nThings``` is undefined in the benchmark statement, despite being defined just 6 lines earlier... Why?!? 

Yeah so I couldn't get any of this to work. As soon as I fixed the issue with local and global variables (for some reason the macro can't see local variables), then some other indexing issues came up which I don't think are my fault. So reverting back to the original file and I just have to run this 100 times! Woo! 

Anyway, let's confirm that it is still linear with weight: 
```
10 Things, 50 Weight → 11.1 μs
10 Things, 100 Weight → 1.106 ms 
10 Things, 150 Weight → 4.101 ms 
10 Things, 200 Weight → 6.628 ms
10 Things, 250 Weight → 9.395 ms
10 Things, 300 Weight → 11.145 ms
10 Things, 350 Weight → 14.776 ms 
10 Things, 400 Weight → 17.343 ms 
10 Things, 450 Weight → 19.779 ms
10 Things, 500 Weight → 22.423 ms
```

Well.. For some reason, my new implementation appears to be consistently 2x slower than my previous implementation. It is still linear with weight, but it is slower. Which doesn't make a ton of sense? I am wondering if the Thing generation function is computationally taxing that that is having an effect (ie the benchmark function is for some reason including the time that takes in the benchmarked time, which would be irritating). Just out of curiosity, I want to try it without generating a new list of Things each time: 
```
10 Things, 500 Weight → 25.159 ms
```

Great. It is the same... So my algorithm just has a higher multiplier for some reason. Now it is a bit unclear whether this is from the low amount of weight and will go away with more weight or if this is an actual 2x multiplier, but let's hope this new implementation at least fixed the non-linear Things: 
```
10 Things, 50 Weight → 610.3 μs
20 Things, 50 Weight → 1.404 ms
30 Things, 50 Weight → 4.592 ms
40 Things, 50 Weight → 7.116 ms
50 Things, 50 Weight → 8.410 ms
60 Things, 50 Weight → 13.877 ms
70 Things, 50 Weight → 19.668 ms
80 Things, 50 Weight → 31.262 ms
90 Things, 50 Weight → 24.475 ms
100 Things, 50 Weight → 35.277 ms
110 Things, 50 Weight → 43.959 ms
```

Uh... So that doesn't look linear? But that random 24 ms is kinda weird... Trying some more values just to see: 
```
200 Things, 200 Weight → 3.64 s
300 Things, 200 Weight → 23.715 s
400 Things, 200 Weight → 36.412 s
500 Things, 200 Weight → 125.987 s
```

Yeah not linear. And the algorithm is worse in every way... Fun. 

A few days later... I have talked with my teacher a bit about my algorithm and there are a few things I think I need to try to figure out what is going on here. For starters, I am slightly concerned that this algorithm won't return correct results. The reason this is a concern of mine is sources online (really just this random [stack overflow post](https://stackoverflow.com/questions/55694896/time-complexity-of-a-bounded-knapsack-problem)) seem to suggest that I need a n x k x W tensor rather than a n x W matrix to represent the situation so I am not entirely sure if I am actually covering all the possibilities (or the necessary ones that is). My teacher seems to think that it is fine (though we only talked it through for 40 minutes and he does say he still doesn't entirely understand the algorithm) and I can see how the second matrix I am using can encode for the extra missing dimension, but I am still not convinced. 

But aside from my concerns that my algorithm isn't correct, there is the issue with running time. It definitely isn't O(nW) (or even O(nkW))... So I am going to try benchmarking this again, but holding the number of each item constant at the same value... Hopefully this shows me something: 
```
10 Things, 30 of each Thing, 100 Weight → 3.501 ms 
10 Things, 30 of each Thing, 200 Weight → 9.931 ms 
10 Things, 30 of each Thing, 400 Weight → 21.162 ms 
10 Things, 30 of each Thing, 800 Weight → 45.34 ms
10 Things, 30 of each Thing, 1600 Weight → 91.687 ms
```

Cool. So that seems pretty linear, though I was already fairly convinced that this was linear earlier, this just confirms it. Now comes the problematic area, changing the number of Things:
```
10 Things, 30 of each Thing, 100 Weight → 2.598 ms 
20 Things, 30 of each Thing, 100 Weight → 8.407 ms 
40 Things, 30 of each Thing, 100 Weight → 33.123 ms 
80 Things, 30 of each Thing, 100 Weight → 138.006 ms 
160 Things, 30 of each Thing, 100 Weight → 778.949 ms 
320 Things, 30 of each Thing, 100 Weight → 4.020 ms
```

This is very much not linear... Instead, I am pretty sure it is quadratic (at least a regression in [Desmos](https://www.desmos.com/calculator/5dgj5pwmx7) would indicate that). 

This means that, much like I feared, the vectorization inside the loop is acting as "another loop" that is making this quadratic with the number of things rather than linear. 

Doing some experimentation with vector addition in Julia, I found that adding together two vectors of length 10000000, it takes about 64.224 ms, whereas adding together two vectors of length 20000000 takes about 130.328 ms. So that is where my extra running time is coming from... Great. And unfortunately I don't see a way to fix this with my current method of implementation, but I know of a solution... That involves rewriting all of my code... Great.

## Attempt at a Solution #3
So, attempt number 3. I had already gotten about an hour into writing this solution when I realized that it wasn't going to work. I mean, it seemed to be a correct algorithm, but it just wasn't going to be in O(nkW) time. I was still using my old algorithm with just more stuff going on... It was pretty lame. 

So I then took a step back and basically doodled for a little bit, trying to figure out the 0-1 knapsack dynamic programming solution. After quite a bit of thinking, I realized I had been going about this solution entirely wrong and was very much over complicating it. 

In order to explain what I realized, let's step back to the 0-1 knapsack problem (the problem I probably should have worked on from the start). The big difference between this problem and the problem I am solving is in the 0-1 problem you can either take an item or leave it (we are going to generalize this to the problem I am working on where you can either take k of the item or k-1 of the item or k-2 of the item... or 0 of the item). To solve this problem, much like what I was doing earlier, we construct a n x W array where each index represents a possible weight and a certain thing. At each entry we compare the entry for the same weight but the Thing before the current Thing and the value of the entry for the Thing before the current Thing added to the vaule of the current Thing, but at the weight of the current weight minus the weight of the current Thing. Phew. That was a mouth-full. A bit more precisely, we are trying to find: 
```
maximum(S[i-1, W], S[i-1, W-W_i] + V_i)
```

Where ```S``` is this matrix we have constructed, ```W``` is the current weight, ```i``` is the current thing, and, fairly clearly, ```W_i``` is the weight of the current thing and ```V_i``` is the value. 

This propagates down to the bottom right corner of the array (the last Thing index and the last weight index) where we have the maximum value for the knapsack. We can pretty easily look back through the array to find which Things we took along the way (this I will explain for my actual implementation, just not this one). 

Okay cool. But what does this have to do with the problem I am trying to solve? Well, as I alluded to earlier, we can look at my problem in the same light, but with a nk x W array (or an n x k x W array, same thing). There are a few differences though. For starters, if we can only take a maximum of k Things, it doesn't make sense to, say in the k=2 entry, to look at the k=1 entry and see if you could add 2 more things. Like if you could take a maximum of 2 Things, then you have just taken 3 and this doesn't make sense! 

To solve this, we will look at the previous weight (so current weight minus the weight of the current thing) and then the maximum value of k for the previous item. Why can we look at only this maximum value? Well, because the entry we are going to compare this to is the same weight but at k-1 for any k > 1 and the previous Thing at its maximum k when k = 1. If that makes any sense. But anyways, onto the implementation! 

Okay, to start our implementation, we are still going to be using the objects we defined before: 
```julia 
struct Thing
    value::Int
    weight::Int
    maxN::Int # the max of this item you can have
end # Thing

struct Situation
    maxWeight::Int
    things::Vector{Thing}
    maxNThings::Int
end # Situation
```

These are effectively just to make data storage easier, but important to point out to see the variables in our situation. Each Thing needs a specific weight, value, and the maximum number of them there are. And then, the general situation object needs the total weight the knapsack can hold, all the Things, and just another variable that represents the maximum number of Things (so basically the maximum value of all the maximum numbers of each Thing). 

So now onto the actual algorithm, again we start by creating an empty matrix: 
```julia
scores = Int.(zeros((length(situation.things) * situation.maxNThings)+1, situation.maxWeight+1))
```

This is an nk x W matrix. I decided to use this shape of matrix as it was easier to index than a n x k x W array. This matrix encodes for each Thing, all the possible number of Things, and all the possible weights. Each entry will hold the maximum value for that combination of things. From here, we need to loop through all of those possibilities: 
```julia 
for w in 1:situation.maxWeight # loop through all the possible weights 
    for (thingIndex, thing) in enumerate(situation.things) # loop through all the things 
        for k in 1:situation.maxNThings # loop through all the possible quantities of things 
            
        end # for 
    end #for 
end # for 
```

Fairly simply, we just need to look at all these possibilities. From now on I will talk about code within this loop until specified. We now do a quick check on bounds: 
```julia 
if (k * thing.weight > w) || (k > thing.maxN) 
    
end # if
```
Here, all we are checking is to see: 1) would this number of Things even fit in this weight of knapsack? and 2) are we over the maximum number of Things for this specific Thing (remember, this isn't the same for every item)? If either of these two conditions is satisfied, we just grab the score entry directly above the current one: 
```julia
if (k * thing.weight > w) || (k > thing.maxN) 
    scores[((thingIndex-1)*situation.maxNThings)+k+1, w+1] = scores[(thingIndex-1)*situation.maxNThings+k, w+1] 
end # if
```
This piece of code either takes the score from the same Thing, but 1 fewer of them OR the maxmimum number of Things for the previous Thing (of course in the same weight). This is the condition when the previous calculated value is just a better value for the current weight and we change this particular index to this value as this index is impossible so we can just take the value before it. Now, we can only consider valid situations, so we simply take the maximum of this value just described and the value of the previous weight plus the weight of the current Thing: 
```julia
if (k * thing.weight > w) || (k > thing.maxN) 
    scores[((thingIndex-1)*situation.maxNThings)+k+1, w+1] = scores[(thingIndex-1)*situation.maxNThings+k, w+1] 
else 
    scores[((thingIndex-1)*situation.maxNThings+k)+1, w+1] = maximum([scores[((thingIndex-1)*situation.maxNThings+k), w+1], (scores[((thingIndex-1)*situation.maxNThings)+1, w-thing.weight*k+1] + thing.value*k)]) 
end # if
```

Which this is basically just some indexing and a ```maximum()``` function. And that's it! I was totally over complicating this algorithm before. I mean, there is a few other things we need to do to calculate the actual Things that were taken, but that isn't that hard. 

Now, to find which Things we took, we start at the bottom right index (the maximum score). We are going to perform an iterative scheme until we reach a Thing index of 0 (the None item basically). Here is what we do: 
- If the value directly above this value (for the previous Thing or k but in the same weight) is the same, then change that to the new Thing index and perform this iteration on that index 
- Otherwise, find out what Thing that index represents and how many are present, record that, and then move to the previous Thing at max k with a weight that is k x thing.weight less than the current weight. Perform the iteration on this new index.

Here is that process in code. We start by simply creating an empty Vector to store the totals for everything: 
```julia
totals = Int.(zeros(length(situation.things)))
```

We then just need to get some temporary variables representing the index we are looking at. For starting, this can just be that bottom right index: 
```julia 
i, j = size(values)[1], size(values)[2] 
```

From here we enter a while loop that goes until we reach a Thing index of 1 (actual thingIndex of 0, but everything is shifted up by 1): 
```julia 
while i != 1
end # while
```
Now within that while loop, we do the check to see if the current index is the same score as the index directly above it (a decrease in the thingIndex, i):
```julia 
if values[i, j] == values[i-1, j] 
    i = i - 1 
end # if
```
If it is the same, then we change to that index. If this isn't the case, we need to first find the k value and the thingIndex for the value of i we are at: 
```julia 
if values[i, j] == values[i-1, j] 
    i = i - 1 
else 
    k = (i-1) % situation.maxNThings

    thingIndex = Int(((i-1)-k)/situation.maxNThings + 1) 

end # if
```
Here, we know that we can find what number of things we are looking at simply through the mod function (though k=0 actually means k = maxNThings). We can then use this in order to calculate the thingIndex (or which thing this i index represents). Once we have these values, we can set k to the proper value (if it is 0), increment the proper index in our storage tuple by this k, and move to the previous weight class and previous thing. 

```julia 
if values[i, j] == values[i-1, j] 
    i = i - 1 
else 
    k = (i-1) % situation.maxNThings

    thingIndex = Int(((i-1)-k)/situation.maxNThings + 1) 
    
    if k == 0
        k = situation.maxNThings 
    end # if 

    totals[thingIndex] += k 
    
    i = Int(((i-1)-k)/situation.maxNThings)*situation.maxNThings + 1 
    j = Int(j - k*situation.things[thingIndex].weight) 

end # if
```

After this iteration is complete, we will have a vector counting up all the numbers of Things we have for our best combination, completing our algorithm! 

## Testing our Algorithm v3
Hopefully this is the last time I have to run a bunch of algorithm benchmarks because I have actually implemented it correctly this time. Anyways, we are hoping to see this new algorithm running in O(nkW) time, so we need to check to see if it is linear with each independently when the others are held constant. We will start with weight because that was correct before and it would be a bad thing if it wasn't correct this time: 
```
10 Things, max 20 of each, 50 Weight → 41.000 μs
10 Things, max 20 of each, 100 Weight → 103.900 μs
10 Things, max 20 of each, 200 Weight → 288.900 μs 
10 Things, max 20 of each, 400 Weight → 707.000 μs
10 Things, max 20 of each, 800 Weight → 1.782 ms 
10 Things, max 20 of each, 1600 Weight → 5.012 ms 
10 Things, max 20 of each, 3200 Weight → 12.584 ms 
10 Things, max 20 of each, 6400 Weight → 29.924 ms 
10 Things, max 20 of each, 12800 Weight → 83.491 ms 
```

That is... concerningly non-linear. Though I have a feeling this has to do with my utterly terrible find the number of each Thing function. If we just take the problem to be find the optimal weight, we can ignore that. So let's just remove that from the algorithm and see what happens: 
```
10 Things, max 20 of each, 6400 Weight → 28.006 ms 
10 Things, max 20 of each, 12800 Weight → 81.101 ms 
10 Things, max 20 of each, 25600 Weight → 161.768
10 Things, max 20 of each, 51200 Weight → 431.397 ms 
10 Things, max 20 of each, 102400 Weight → 1.093 s 
10 Things, max 20 of each, 204800 Weight → 1.867 s 
10 Things, max 20 of each, 409600 Weight → 4.056 s 
10 Things, max 20 of each, 819200 Weight → 5.289 s
```

Hmm... Okay that isn't linear. And that is a problem. It is definitely much, much faster than my previous algorithm, but it isn't running in linear time with weight. I am not entirely sure what it is running in though. Like it goes from 1.092 → 1.867 → 4.056 which is like very linear. But then it does this: 4.056 → 5.289. Something weird is definitely happening... Like theoretically just looking at the code, it should run in O(nkW) time. I see no reason why it wouldn't. But then, like... It really just doesn't look linear. My one theory is that the number of things is just too small, so I could try changing that: 
```
50 Things, max 20 of each, 1000 Weight → 18.703 ms 
50 Things, max 20 of each, 2000 Weight → 47.870 ms 
50 Things, max 20 of each, 4000 Weight → 131.463 ms 
50 Things, max 20 of each, 8000 Weight → 309.092 ms 
50 Things, max 20 of each, 16000 Weight → 673.817 ms 
50 Things, max 20 of each, 32000 Weight → 1.489 s
50 Things, max 20 of each, 64000 Weight → 3.166 s 
50 Things, max 20 of each, 128000 Weight → 5.355 s
50 Things, max 20 of each, 256000 Weight → 8.122 s 
50 Things, max 20 of each, 512000 Weight → 14.306
```

Well, it is still true that it *seems* to be doubling with higher and higher weights, but like it is weird. It isn't even doubling but like 1.8x-ing or something. Again maybe I need to try this with more Things: 
```
500 Things, max 50 of each, 1000 Weight → 560.002 ms 
500 Things, max 50 of each, 2000 Weight → 1.828 s
500 Things, max 50 of each, 4000 Weight → 5.352 s
500 Things, max 50 of each, 8000 Weight → 10.035 s 
500 Things, max 50 of each, 16000 Weight → 19.880 s
500 Things, max 50 of each, 32000 Weight → 44.521 s 
```

Okay that looks roughly linear? At least in the later number of Things which is when it is more important? I am guessing there is just so much noise that with lower values it is really just random. This seems odd, but in the limit it seems linear so that is all that matters. 

Now to check if it is linear with things. Learning my lesson, I am going to pick a larger starting value for weight: 
```
500 Things, max 50 of each, 1000 Weight → 559.581 ms
1000 Things, max 50 of each, 1000 Weight → 1.321 s
2000 Things, max 50 of each, 1000 Weight → 3.114 s
4000 Things, max 50 of each, 1000 Weight → 5.910 s 
8000 Things, max 50 of each, 1000 Weight → 10.692 s
```

So, we are seeing some of the same noise from the looks of it, but it also very much seems linear as well (assuming like 200 ms of noise more or less). I am just going to take this as saying my algorithm is linear with Things as I like that conclusion. Also, if my previous attempts at this algorithm are anything to go by, it would be pretty clear if this was O(n^2) as it would just grow out of control very fast, not fluctuate around a linear pattern. Finally, to test linearity with the max number of things:
```
500 Things, max 50 of each, 1000 Weight → 534.402 ms
500 Things, max 100 of each, 1000 Weight → 826.084 ms
500 Things, max 200 of each, 1000 Weight → 1.200 s
500 Things, max 400 of each, 1000 Weight → 1.708 s 
500 Things, max 800 of each, 1000 Weight → 2.969 s
500 Things, max 1600 of each, 1000 Weight → 6.265 s 
500 Things, max 3200 of each, 1000 Weight → out of memory error 
```

Yeah... I ran out of memory... But it seemed linear before I did so I am just going to assume that it is (specifically the 1.708 → 2.969 → 6.265)

Alright, cool! After about 17 hours and 39 minutes of straight coding (and probably around another 3-5 hours of brainstorming, researching, and thinking through things) I have finally found a solution that works. I should have looked up how to do this from the start... But it was fun! I am sorry that this write-up is such a mess, I intended it to be a stream of conscious, and it definitely was, but that also means it was a complete mess. Hopefully it was at least interesting to see how I thought this through. 

## Finding a Solution (Not Dynamic Programming)

Note from after getting halfway through this: **this isn't a dynamic programming** solution, but it should work, so I will implement this as a reference. 

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

I just talked with my teacher about this solution and I have been told, and after staring at a graph for like 2 hours agree, that this is not a great solution. However, to have a baseline solution to this problem (that isn't dynamic programming, but should work) I am going to implement this. Another thing I was told is that I misinterpreted the problem, and there are limits on the amount of each item you can take... which makes sense, but I totally disregarded I guess. That is something I am going to need to worry about now. I also spent a bit of time thinking about my branch culling I suggested earlier and think that might speed this up, so maybe I try implementing that as well and comparing it to the dynamic programming solution I come up with later. 