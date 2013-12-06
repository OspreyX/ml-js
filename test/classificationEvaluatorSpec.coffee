process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
evaluators = require '../bin/classificationEvaluator'
_ = require 'underscore'

describe 'ClassificationEvaluator', ->
  evaluator = null
  xor_dataset =  [
    {state:[0, 0], expected: 0}, 
    {state:[0, 1], expected: 1}, 
    {state:[1, 0], expected: 1}, 
    {state:[1, 1], expected: 0}
  ] 
    
  describe 'on xor (binary) dataset', ->
    
    describe 'with naive classifier', ->
      bad_classifier = null
      beforeEach ->
        bad_classifier = {
          predict: (state) -> 0 #return the class index
        }
        evaluator = new evaluators.ClassificationEvaluator 
      
      it 'should return a recall of 0', (done)  ->
        evaluator.evaluate bad_classifier, xor_dataset, (result)->
          result.recall.should.equal 0
          done
      
      it 'should return a precision of 0', (done) ->
        evaluator.evaluate bad_classifier, xor_dataset, (result)->
          result.precision.should.equal 0
          done
        
      it 'should return a f_score of 0', (done)->
        evaluator.evaluate bad_classifier, xor_dataset, (result)->
          result.fscore.should.equal 0
          done
    
    describe 'with perfect classifier', ->
      perfect_classifier = null
      beforeEach ->
        perfect_classifier = {
          xor_table: [[0, 1], [1, 0]]
          predict: (state) -> 
            A = state[0]
            B = state[1]
            this.xor_table[A][B]
        }
        evaluator = new evaluators.ClassificationEvaluator
        
      it 'should return a recall of 1', (done)->
        evaluator.evaluate perfect_classifier, xor_dataset, (result)->
          result.recall.should.equal 1
          done
      
      it 'should return a precision of 1', (done)->
        evaluator.evaluate perfect_classifier, xor_dataset, (result)->
          result.precision.should.equal 1
          done
        
      it 'should return a f_score of 1', (done)->
        evaluator.evaluate perfect_classifier, xor_dataset, (result)->
          result.fscore.should.equal 1
          done
    
    