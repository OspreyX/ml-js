_ = require 'underscore'
numeric = require 'numeric' 

module.exports = 
  ClassificationEvaluator: class ClassificationEvaluator
    constructor: (options) ->
      options = options ? {}
      @nfold = options.nfold ? 5
    
    _computeFScore: (precision, recall) -> 
      if (recall == 0 and precision == 0)
        return 0
      2 * recall * precision / (recall + precision)
  
    _processResult: (classifier, test_set, cb)->
      labels = _.uniq(_.pluck(test_set, 'expected'))
      nb_labels = labels.length
      nb_examples = test_set.length
      results = []
      for i in [0...nb_labels]
        results[i]=_.map [1..nb_labels], (i)->0
      
      onces = _.map [1..nb_labels], (i)->1

      getIndex = (label)->
        _.indexOf labels, label

      for ex in test_set
        prediction = classifier.predict ex.state
        expected = ex.expected
        results[getIndex prediction][getIndex expected] += 1
      
      sum_predictions = numeric.dot(results, onces)
      sum_expected = numeric.dot( numeric.transpose(results) , onces)

      per_class_reports = []
      nb_good_prediction = 0
      for label in labels
        label_index = getIndex label
        
        TP = results[label_index][label_index]
        
        precision = 0
        recall = 0
        if TP != 0
          precision =  TP / sum_predictions[label_index]
          recall = TP / sum_expected[label_index]
        nb_good_prediction+=TP
        classResult = {
          class: label
          precision: precision
          recall: recall
          fscore: this._computeFScore(precision, recall)
        }
        per_class_reports.push classResult
      

      report = {
        accuracy: nb_good_prediction / nb_examples
        lowest_fscore: _.min(_.pluck(per_class_reports, 'fscore'))
        lowest_precision: _.min(_.pluck(per_class_reports, 'precision'))
        lowest_recall: _.min(_.pluck(per_class_reports, 'recall'))
        classReports: per_class_reports
      }
      cb report
    
    ###
    NOTICE : this function assumes your classifier is already trained 
    ###
    evaluate: (classifier, test_set, cb)->
      process.nextTick(this._processResult(classifier, test_set, cb))
        
      
      