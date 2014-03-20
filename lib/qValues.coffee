fann = require 'fann'
evens= require 'events'

exports.CSDAQValues = class CSDAQValues extends evens.EventEmitter
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
    old_reward= @nets[action_index].run(state)[0]
    @nets[action_index].train_once(state, new_value)
    this.emit 'learned_once', Math.pow(old_reward - value, 2) / 2