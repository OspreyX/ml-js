process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
ml = require '../bin/ml'
_ = require 'underscore'


describe 'QLearningAgent', ->
  agent = null
  fakeQvalue = null  
  init_state= [0,0,0]
  new_state = [0,0,0]
  action_index = 0
  beforeEach ->
    fakeQvalue = {
      getQValue: (state, action_index) -> 0
      updateQValue: (state, action_index, value)-> value
      nb_features: 3 
      nb_actions: 2
    }
    agent = new ml.QLearningAgent(fakeQvalue)
    
  it 'should respond to \'getAction\' with the action index', ->
    state= [0,0,0]
    agent.getAction(state).should.be.an.Number
  
  it 'should respond to \'learn\'', (done)->
    reward = 0
    agent.learn init_state, action_index, new_state, reward, (info)->
      done
    
  it 'should have \'learning_rate\' property set to 0.1', ->
    agent.learning_rate.should.equal 0.1
    
  it 'should have \'discount_factor\' property set to 0.9', ->
    agent.discount_factor.should.equal 0.9

  it 'should have Boltzmann exploration policy by default', ->
    agent.exploration_policy.should.be.an.instanceOf ml.BoltzmannExploration
    
  describe 'when initialized with custom parameters', ->
    options = { learning_rate: 0.2, discount_factor: 0.8}
    beforeEach ->
      agent = new ml.QLearningAgent(fakeQvalue, options)
    
    it 'should have \'learning_rate\' updated', ->
      agent.learning_rate.should.equal 0.2
      
    it 'should have \'discount_factor\' updated', ->
      agent.discount_factor.should.equal 0.8

    it 'should return info after qvalue update', (done)-> #(1.0 - 0.2) * 0 + 0.2 * ( 1 + 0.8 * 0 ) = 0.2
      agent.learn init_state, action_index, new_state, 1, (info)-> 
        info.old_value.should.equal 0
        info.new_value.should.equal 0.2
        done

    


    
