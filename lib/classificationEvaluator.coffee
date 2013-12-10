_ = require 'underscore'
numeric = require 'numeric' 
async = require 'async' 

###
NOTICE : ClassificationEvaluator assumes your inputs  
are properly normalized between 0 and 1 
###
exports.ClassificationEvaluator = class ClassificationEvaluator
  constructor: (options) ->
    options = options ? {}

  _processResult: (classifier, test_set, cb)->
    labels = _.uniq(_.pluck(test_set, 'expected'))
    nb_labels = labels.length
    nb_examples = test_set.length
    results = []
    for i in [0...nb_labels]
      results[i]=_.map [1..nb_labels], (i)->0
    
    onces = _.map [1..nb_labels], (i)->1

    getIndex = (label)->
      index = _.indexOf labels, label
      if index == -1 #label existing in trainning set but not in test set
        labels.push label
        index = nb_labels
        for i in [0...nb_labels]
          results[i][index] = 0
        nb_labels++
        results[index]=_.map [1..nb_labels], (i)->0
      index
    computeFScore = (precision, recall) -> 
      if (recall == 0 and precision == 0)
        return 0
      2 * recall * precision / (recall + precision)
    
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
        fscore: computeFScore(precision, recall)
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
  evaluate: (classifier, test_set, done_cb)->
    this.performKFoldCrossValidation 1, classifier, test_set, (report)->
      done_cb report

  
  _performKFoldCrossValidation: (kfold, classifier, data_set, done_cb)->
    data = _.shuffle data_set 
    nb_example_per_subset = Math.floor(data.length / kfold)
    data_subsets = []
    k = 0
    for i in [0...kfold]
      subset = data[k...k + nb_example_per_subset]
      k += nb_example_per_subset
      data_subsets.push subset
    
    _sets = []
    for i in [0...kfold]
      i_trainning_set = []
      for j in [0...kfold]
        if j != i
          i_trainning_set = i_trainning_set.concat data_subsets[j]
      set = { 
        trainning: i_trainning_set
        test: data_subsets[i]
        classifier: _.clone classifier
      }
      _sets.push set    
    
    trainAndEvaluateSet = (set)->
      set.classifier.train set.trainning
      labels = _.uniq(_.pluck(set.test, 'expected'))
      nb_labels = labels.length
      nb_examples = set.test.length
      results = []
      for i in [0...nb_labels]
        results[i]=_.map [1..nb_labels], (i)->0
      
      onces = _.map [1..nb_labels], (i)->1

      getIndex = (label)->
        index = _.indexOf labels, label
        if index == -1 #label existing in trainning set but not in test set
          labels.push label
          index = nb_labels
          for i in [0...nb_labels]
            results[i][index] = 0
          nb_labels++
          results[index]=_.map [1..nb_labels], (i)->0
        index
      
      computeFScore = (precision, recall) -> 
        if (recall == 0 and precision == 0)
          return 0
        2 * recall * precision / (recall + precision)
      
      for ex in set.test
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
          fscore: computeFScore(precision, recall)
        }
        per_class_reports.push classResult
        
      report = {
        accuracy: nb_good_prediction / nb_examples
        lowest_fscore: _.min(_.pluck(per_class_reports, 'fscore'))
        lowest_precision: _.min(_.pluck(per_class_reports, 'precision'))
        lowest_recall: _.min(_.pluck(per_class_reports, 'recall'))
        classReports: per_class_reports
      }
      report
    
    set_reports = []
    for set in  _sets
      set_report = trainAndEvaluateSet set
      set_reports.push set_report
      
    sumAccuracies = 0
    sumFScores = 0
    sumPrecisions = 0
    sumRecall = 0
    for r in set_reports
      sumAccuracies+=r.accuracy
      sumFScores += r.lowest_fscore
      sumPrecisions += r.lowest_precision
      sumRecall += r.lowest_recall

    report = {
      kfold: kfold
      average_accuracy: sumAccuracies / kfold
      average_fscore: sumFScores / kfold
      average_precision: sumPrecisions / kfold
      average_recall: sumRecall / kfold
      subsetsReports: set_reports
    }
    done_cb report
      
    
  performKFoldCrossValidation: (k, classifier, data_set, done_cb)->
    this._performKFoldCrossValidation k, classifier, data_set, (report)->
      done_cb report

      
      