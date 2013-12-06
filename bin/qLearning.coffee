fann = require 'fann'
_ = require 'underscore'
numeric = require 'numeric' 

module.exports = 
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
  BoltzmannExploration: class BoltzmannExploration
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


  ContinuousQValues: class ContinuousQValues
    constructor: (nb_features, nb_actions) ->
      @nb_features = nb_features
      @nb_actions = nb_actions
      @nets = []
      hidden_layer_size = @nb_features + 1
      for i in [0..nb_actions-1]
        net = new fann.standard @nb_features, hidden_layer_size , 1
        net.training_algorithm = "incremental"
        @nets.push net

    getQValue: (state, action_index) -> 
      @nets[action_index].run(state)[0]

    updateQValue: (state, action_index, value)-> 
      new_value = []
      new_value.push value
      @nets[action_index].train_once(state, new_value)

  QLearningAgent: class QLearningAgent
    qValues = null
    nb_actions = null
    constructor: (q_values_manager, options) ->
      qValues = q_values_manager
      nb_actions = qValues.nb_actions
      options = options ? {}
      @learning_rate = options.learning_rate ? 0.1
      @discount_factor = options.discount_factor ? 0.9
      @exploration_policy = options.exploration_policy ? new BoltzmannExploration
      
    getAction: (state)->
      actionValues = _.map [0...nb_actions], (a) -> qValues.getQValue(state, a)
      @exploration_policy.chooseAction(actionValues)

    _updateQValue: (state, action, new_value, info, cb)->
      epoch = qValues.updateQValue(state, action, new_value)
      cb info

    learn: (init_state, action_index, new_state, reward, cb)->
      init_qvalue = qValues.getQValue(init_state, action_index)
      nextActionValues = _.map [0,1], (a) -> qValues.getQValue(new_state, a)
      new_value = (1.0 - @learning_rate) * init_qvalue + @learning_rate * (reward + @discount_factor * _.max( nextActionValues ))
      info = {
        old_value: init_qvalue
        new_value: new_value
      }
      process.nextTick(this._updateQValue(init_state, action_index, new_value, info, cb))
  
      
