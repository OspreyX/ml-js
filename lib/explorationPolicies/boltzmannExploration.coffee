_ = require 'underscore'
numeric = require 'numeric' 
###
The class implements exploration policy base on 
Boltzmann distribution. Acording to the policy, 
action a at state s is selected with the next probability
                  exp( Q( s, a ) / t )       exp( A )
p( s, a ) = ----------------------------- = ----------
             SUM( exp( Q( s, b ) / t ) )        B
where Q(s, a) is action's a estimation (usefulness) 
at state s and t is Temperature.
###
exports.BoltzmannExploration = class BoltzmannExploration
  constructor: (temperature) ->
    if temperature < 0
      temperature = 0
    @temperature = temperature ? 0.25


  getProbabilities: (action_estimates)->
    A = numeric.dot(action_estimates, 1 / @temperature)
    exp_A = numeric.exp(A)
    B = _.reduce( exp_A, (memo, q)-> memo + q)
    numeric.dot(exp_A, 1 / B)

  chooseAction: (action_estimates)->
    nb_actions = action_estimates.length
    prob = this.getProbabilities action_estimates
    rand = Math.random()
    sum= 0
    for i in [0...nb_actions]
      sum += prob[i]
      return i if rand <= sum
    nb_actions - 1