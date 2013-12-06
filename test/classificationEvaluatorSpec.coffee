process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
evaluators = require '../js/classificationEvaluator'
_ = require 'underscore'

describe 'ClassificationEvaluator', ->
  evaluator = null
  classifier = null
  xor_dataset =  [
    {state:[0, 0], expected: 0}, 
    {state:[0, 1], expected: 1}, 
    {state:[1, 0], expected: 1}, 
    {state:[1, 1], expected: 0}
  ] 
    
  describe 'on xor (binary) dataset', ->
    
    describe 'with naive classifier', ->
      
      beforeEach ->
        classifier = {
          predict: (state) -> 0 #return the class index
        }
        evaluator = new evaluators.ClassificationEvaluator classifier, xor_dataset
      
      it 'should return a recall of 0', ->
        evaluator.recall.should.equal 0
      
      it 'should return a precision of 0', ->
        evaluator.precision.should.equal 0
        
      it 'should return a f_score of 0', ->
        evaluator.getFScore().should.equal 0
    
    describe 'with perfect classifier', ->
      beforeEach ->
        classifier = {
          xor_table: [[0, 1], [1, 0]]
          predict: (state) -> 
            A = state[0]
            B = state[1]
            this.xor_table[A][B]
        }
        evaluator = new evaluators.ClassificationEvaluator classifier, xor_dataset
        
      it 'should return a recall of 1', ->
        evaluator.recall.should.equal 1
      
      it 'should return a precision of 1', ->
        evaluator.precision.should.equal 1
        
      it 'should return a f_score of 1', ->
        evaluator.getFScore().should.equal 1
    
    