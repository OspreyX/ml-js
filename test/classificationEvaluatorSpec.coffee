process.env.NODE_ENV = 'test'
assert = require 'assert'
require 'should'
evaluators = require '../bin/classificationEvaluator'
_ = require 'underscore'

describe 'ClassificationEvaluator', ->
  evaluator = null
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
  bad_classifier = {
    predict: (state) -> 'A'
    train: (trainning_set)->
      info = {
        cost: 0
        message: "Im a fake classifier"
      } 
      info
  }
  perfect_classifier = {
    prevision_table: [
      ['A', 'B'], 
      ['C', 'D']
    ]
    predict: (state) -> 
      x_1 = state[1]
      x_2 = state[2]
      this.prevision_table[x_1][x_2] # note : independant from state[0]
    train: (trainning_set)->
      info = {
        cost: 0
        message: "Im a fake classifier"
      } 
      info
  }

  beforeEach ->
    evaluator = new evaluators.ClassificationEvaluator 
  
  
      
  describe 'when evaluates naive classifier', ->
    
    it 'should use only one subset (ie k = 1)', (done)  =>
      evaluator.evaluate bad_classifier, test_set, (report)->
        report.kfold.should.equal 1
        done()
        
    it 'should report an accuracy of 0.25', (done)  =>
      evaluator.evaluate bad_classifier, test_set, (report)->
        report.average_accuracy.should.equal 0.25
        done()

    it 'should report a fscore of 0', (done)  ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        report.average_fscore.should.equal 0
        done()
    
    it 'should report a precision of 0', (done)  ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        report.average_precision.should.equal 0
        done()
    
    it 'should report a recall of 0', (done)  ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        report.average_recall.should.equal 0
        done()

    it 'should report a recall of 1 for class \'A\'', (done)  ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0].classReports
        aReport = _.findWhere(subReport, {class: 'A'})
        aReport.recall.should.equal 1
        done()
    
    it 'should report a precision of 0.25 for class \'A\'', (done) ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0]
        aReport = _.findWhere(subReport.classReports, {class: 'A'})
        aReport.precision.should.equal 0.25
        done()
      
    it 'should report a fscore of 0.4 for class \'A\'', (done)->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0]
        aReport = _.findWhere(subReport.classReports, {class: 'A'})
        aReport.fscore.should.equal 0.4
        done()

    it 'should report a recall of 0 for class \'B\'', (done)  ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0]
        bReport = _.findWhere(subReport.classReports, {class: 'B'})
        bReport.recall.should.equal 0
        done()
    
    it 'should report a precision of 0 for class \'B\'', (done) ->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0]
        bReport = _.findWhere(subReport.classReports, {class: 'B'})
        bReport.precision.should.equal 0
        done()
      
    it 'should report a fscore of 0 for class \'B\'', (done)->
      evaluator.evaluate bad_classifier, test_set, (report)->
        subReport = report.subsetsReports[0]
        bReport = _.findWhere(subReport.classReports, {class: 'B'})
        bReport.fscore.should.equal 0
        done()
  
  describe 'when perform n-fold cross validation on perfect classifier', ->
      
    it 'should report an accuracy of 1', (done)  ->
      evaluator.performKFoldCrossValidation 8, perfect_classifier, test_set, (report)->
        report.average_accuracy.should.equal 1
        report.average_fscore.should.equal 1
        report.average_precision.should.equal 1
        report.average_recall.should.equal 1
        done()

    it 'should report a recall of 1 for all classes', (done)  ->
      evaluator.performKFoldCrossValidation 8, perfect_classifier, test_set, (report)->
        for subset in report.subsetsReports
          for classReport in subset.classReports
            classReport.recall.should.equal 1
        done()
    
    it 'should report a precision of 1 for all classes', (done) ->
      evaluator.performKFoldCrossValidation 8, perfect_classifier, test_set, (report)->
        for subset in report.subsetsReports
          for classReport in subset.classReports
            classReport.precision.should.equal 1
        done()
      
    it 'should report a fscore of 1 for all classes', (done)->
      evaluator.performKFoldCrossValidation 8, perfect_classifier, test_set, (report)->
        for subset in report.subsetsReports
          for classReport in subset.classReports
            classReport.fscore.should.equal 1
        done()


            