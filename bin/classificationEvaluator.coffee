_ = require 'underscore'

module.exports = 
  ClassificationEvaluator: class ClassificationEvaluator
    constructor: (options ) ->

    
    _computeFScore: (precision, recall) -> 
      if (recall == 0 and precision == 0)
        return 0
      2 * recall * precision / (recall + precision)
  
    _processResult: (classifier, data, cb)->
      results = [
        [0,0], # [TN, FN]
        [0,0]  # [FP, TP]
      ]
      
      for ex in data
        prediction = classifier.predict ex.state
        expected = ex.expected
        results[prediction][expected] += 1
        
      TP = results[1][1]
      FP = results[1][0]
      FN = results[0][1]
      precision = 0
      recall = 0
      if TP != 0
        precision =  TP / (TP + FP)
        recall = TP / (TP + FN)
      result = {
        precision: precision
        recall: recall
        fscore: this._computeFScore(precision, recall)
      }
      cb result

    evaluate: (classifier, data, cb)->
      process.nextTick(this._processResult(classifier, data, cb))
        
      
      