process.env.NODE_ENV = 'test'
assert = require 'assert'
_ = require 'underscore'
require 'should'
ml = require '../bin/ml'


describe 'BoltzmannExploration', ->
  expl = null
  options = {
    temperature: 0.25
  }
  beforeEach ->
    expl = new ml.BoltzmannExploration options

  it 'should have temperature set to 0.25 by default', ->
    expl.temperature.should.equal 0.25

  it 'should return [0.5, 0.5] when asking probabilities for [0.5,0.5]', ->
    expl.getProbabilities([0.5, 0.5]).should.eql [0.5, 0.5]

  it 'should return approximately [0, 1] when asking probabilities for [0,1]', ->
    prob = expl.getProbabilities([0, 1])
    prob[0].should.approximately 0, 5e-2
    prob[1].should.approximately 1, 5e-2

  it 'should return values ​​whose sum must be equal to 1 ', ->
    prob = expl.getProbabilities([0.85, 0.9])
    _.reduce( prob, (sum, val)-> sum + val).should.be.approximately 1, 1e-5

  it 'should return 1 when choose action with [0,1]', ->
    expl.chooseAction([0, 1]).should.equal 1