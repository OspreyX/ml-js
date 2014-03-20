require("coffee-script");
exports.fann = require('fann');

// Q-Values
exports.CSDAQValues = require('../lib/qValues').CSDAQValues;

// Explorations policies
exports.BoltzmannExploration = require('../lib/explorationPolicies/boltzmannExploration').BoltzmannExploration;

// Reinforcement learning
exports.QLearningAgent = require('../lib/qLearningAgent').QLearningAgent;

// Analysis
exports.ClassificationEvaluator = require('../lib/classificationEvaluator').ClassificationEvaluator;