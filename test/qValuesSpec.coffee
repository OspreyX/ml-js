process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
ml = require '../bin/ml'
_ = require 'underscore'


describe 'ContinuousQValues', ->
  qValues = null 
  updated_xor = [
  #  A, B, a -> reward
    {state: [0, 0], action: 0, reward: 1}, # reward = 1 because 0 XOR 0 == 0
    {state: [0, 0], action: 1, reward: 0}, # reward = 0 because 0 XOR 0 != 0 
    {state: [0, 1], action: 0, reward: 0},
    {state: [0, 1], action: 1, reward: 1},
    {state: [1, 0], action: 0, reward: 0},
    {state: [1, 0], action: 1, reward: 1},
    {state: [1, 1], action: 0, reward: 1},
    {state: [1, 1], action: 1, reward: 0}
  ]

  beforeEach ->
    qValues = new ml.ContinuousQValues 2, 2

  it 'should respond to \'getQValue\' with the action value', ->
    action_index = 0
    qValues.getQValue([0,0], action_index).should.be.an.Number  

  it 'should contains an array of 2 neural networks (one for each action)', ->
    qValues.nets.should.be.an.Array
    qValues.nets.length.should.equal 2

  it 'should contains iteratives neural networks', ->
    net.training_algorithm.should.equal("incremental") for net in qValues.nets

  describe 'when train once', ->
    test_state = [1, 0]
    action = 1
    expected_reward = 1
    called = false

    beforeEach (done_cb) ->
      init_reward = qValues.getQValue test_state, action
      qValues.on 'learned_once', (cost)->
        cost.should.equal (1/2 * Math.pow(init_reward - expected_reward, 2))
        called= true
        done_cb()
      qValues.updateQValue test_state, action, expected_reward

    it 'should raise \'learned_once\' event', ->
      called.should.be.true

  describe 'when trainned with xor example', ->
    beforeEach ->
      for i in [1..5000]
        for ex in updated_xor
          qValues.updateQValue ex.state, ex.action, ex.reward

    it 'should predict 0 to be a good choice for 0 XOR 0 (prob ~ 1)', ->
      qValues.getQValue([0, 0], 0).should.be.approximately 1.0, 1e-1

    it 'should predict 1 to be a bad choice for 0 XOR 0 (prob ~ 0)', ->
      qValues.getQValue([0, 0], 1).should.be.approximately 0.0, 1e-1

    it 'should predict 1 to be a good choice for 0 XOR 1', ->
      qValues.getQValue([0, 1], 1).should.be.approximately 1.0, 1e-1


    it 'should predict 0 to be a bad choice for 0 XOR 1', ->
      qValues.getQValue([0, 1], 0).should.be.approximately 0.0, 1e-1

    it 'should predict 0 as the best action (i.e. result) for 0 XOR 0',->
      actionValues = _.map [0,1], (a) ->
        qValues.getQValue([0,0], a)

      maxValue = _.max actionValues
      action_index = _.indexOf actionValues, maxValue
      action_index.should.equal 0