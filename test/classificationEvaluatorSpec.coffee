process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
evaluators = require '../bin/classificationEvaluator'
_ = require 'underscore'

describe 'ClassificationEvaluator', ->
  evaluator = null
  
  beforeEach ->
      evaluator = new evaluators.ClassificationEvaluator 
  
  describe 'default parameter', ->  
    it 'should have nfold set to 5',  ->
      evaluator.nfold.should.equal 5

  test_set =  [
    {state:[0, 0, 0], expected: 'A'}, 
    {state:[0, 0, 1], expected: 'B'}, 
    {state:[0, 1, 0], expected: 'C'}, 
    {state:[0, 1, 1], expected: 'D'}
    {state:[1, 0, 0], expected: 'A'}, 
    {state:[1, 0, 1], expected: 'B'}, 
    {state:[1, 1, 0], expected: 'C'}, 
    {state:[1, 1, 1], expected: 'D'}
  ]  
  describe 'ClassificationEvaluator', ->

    describe 'evaluates', ->
      describe 'with naive classifier', ->
        bad_classifier = null
        beforeEach ->
          bad_classifier = {
            predict: (state) -> 'A' 
          }
          
        
        it 'accuracy to be 0.25', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            report.accuracy.should.equal 0.25
            done
        
        it 'fscore to be 0', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            report.lowest_fscore.should.equal 0
            done
        it 'lowest precision to be 0', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            report.lowest_precision.should.equal 0
            done
        it 'lowest recall to be 0', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            report.lowest_recall.should.equal 0
            done

        it 'recall to be 1 for class \'A\'', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            aReport = _.findWhere(report.classReports, {class: 'A'})
            aReport.recall.should.equal 1
            done
        
        it 'precision to be 0.25 for class \'A\'', (done) ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            aReport = _.findWhere(report.classReports, {class: 'A'})
            aReport.precision.should.equal 0.25
            done
          
        it 'fscore to be 0.4 for class \'A\'', (done)->
          evaluator.evaluate bad_classifier, test_set, (report)->
            aReport = _.findWhere(report.classReports, {class: 'A'})
            aReport.fscore.should.equal 0.4
            done

        it 'recall to be 0 for class \'B\'', (done)  ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            bReport = _.findWhere(report.classReports, {class: 'B'})
            bReport.recall.should.equal 0
            done
        
        it 'precision to be 0 for class \'B\'', (done) ->
          evaluator.evaluate bad_classifier, test_set, (report)->
            bReport = _.findWhere(report.classReports, {class: 'B'})
            bReport.precision.should.equal 0
            done
          
        it 'fscore to be 0 for class \'B\'', (done)->
          evaluator.evaluate bad_classifier, test_set, (report)->
            bReport = _.findWhere(report.classReports, {class: 'B'})
            bReport.fscore.should.equal 0
            done
      
      describe 'with perfect classifier', ->
        perfect_classifier = null
        beforeEach ->
          perfect_classifier = {
            prevision_table: [
              ['A', 'B'], 
              ['C', 'D']
            ]
            predict: (state) -> 
              x_1 = state[1]
              x_2 = state[2]
              this.prevision_table[x_1][x_2] # note : independant from state[0]
          }
          
        it 'accuracy to be 1', (done)  ->
          evaluator.evaluate perfect_classifier, test_set, (report)->
            report.accuracy.should.equal 1
            report.lowest_fscore.should.equal 1
            report.lowest_precision.should.equal 1
            report.lowest_recall.should.equal 1
            done

        it 'recall to be 1 for all classes', (done)  ->
          evaluator.evaluate perfect_classifier, test_set, (report)->
            for classReport in report.classReports
              classReport.recall.should.equal 1
            done
        
        it 'precision to be 1 for all classes', (done) ->
          evaluator.evaluate perfect_classifier, test_set, (report)->
            for classReport in report.classReports
              classReport.precision.should.equal 1
            done
          
        it 'fscore to be 1 for all classes', (done)->
          evaluator.evaluate perfect_classifier, test_set, (report)->
            for classReport in report.classReports
              classReport.fscore.should.equal 1
            done