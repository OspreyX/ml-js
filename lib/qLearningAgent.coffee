boltzmann = require './explorationPolicies/boltzmannExploration'
_ = require 'underscore'

exports.QLearningAgent = class QLearningAgent
  qValues = null
  nb_actions = null
  constructor: (q_values_manager, options) ->
    qValues = q_values_manager
    nb_actions = qValues.nb_actions
    options = options ? {}
    @learning_rate = options.learning_rate ? 0.1
    @discount_factor = options.discount_factor ? 0.9
    @exploration_policy = options.exploration_policy ? new boltzmann.BoltzmannExploration
    
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
  
      
