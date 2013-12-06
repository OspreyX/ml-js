_ = require 'underscore'

module.exports = 
  ClassificationEvaluator: class ClassificationEvaluator
    dataset = null
    predictor = null
    constructor: (classifier, data) ->
      predictor = classifier
      dataset = data
      @recall = 0
      @precision = 0
      this._evaluate()
    
    getFScore: -> 
      if (@recall == 0 and @precision == 0)
        return 0
      f_score = 2 * @recall * @precision / (@recall + @precision)
      f_score
    
    _evaluate: ->
      
      results = [
        [0,0], # [TN, FN]
        [0,0]  # [FP, TP]
      ]
      
      for ex in dataset
        prediction = predictor.predict ex.state
        expected = ex.expected
        results[prediction][expected] += 1
        
      TP = results[1][1]
      FP = results[1][0]
      FN = results[0][1]
      if TP == 0
        @precision = 0
        @recall = 0
      else 
        @precision =  TP / (TP + FP)
        @recall = TP / (TP + FN)
      
      