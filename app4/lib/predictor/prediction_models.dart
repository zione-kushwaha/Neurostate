import 'dart:math';

abstract class PredictionModel {
  String get modelName;
  void recordTransition(String fromRoute, String toRoute);
  List<String> predictNextRoutes(String currentRoute, {double threshold = 0.35});
  double getConfidence(String fromRoute, String targetRoute);
  Map<String, dynamic> exportState();
}

/// Model 0: Naive Popularity Frequency Baseline
class PopularityBaselineModel implements PredictionModel {
  @override
  String get modelName => 'PopularityBaseline';

  final Map<String, int> _visitFrequencies = {};
  int _totalVisits = 0;

  @override
  void recordTransition(String fromRoute, String toRoute) {
    _visitFrequencies[toRoute] = (_visitFrequencies[toRoute] ?? 0) + 1;
    _totalVisits++;
  }

  @override
  List<String> predictNextRoutes(String currentRoute, {double threshold = 0.35}) {
    if (_totalVisits == 0) return [];
    final candidates = _visitFrequencies.entries
        .where((e) => e.key != currentRoute && (e.value / _totalVisits) >= threshold)
        .map((e) => e.key)
        .toList();
    return candidates;
  }

  @override
  double getConfidence(String fromRoute, String targetRoute) {
    if (_totalVisits == 0) return 0.0;
    return (_visitFrequencies[targetRoute] ?? 0) / _totalVisits;
  }

  @override
  Map<String, dynamic> exportState() => {
    'model': modelName,
    'total_visits': _totalVisits,
    'frequencies': _visitFrequencies,
  };
}

/// Model 1: 1st-Order Markov Chain with Laplace Smoothing
class MarkovFirstOrderModel implements PredictionModel {
  @override
  String get modelName => 'MarkovFirstOrder';

  final Map<String, Map<String, int>> _transitionCounts = {};
  final double smoothingAlpha;

  MarkovFirstOrderModel({this.smoothingAlpha = 1.0});

  @override
  void recordTransition(String fromRoute, String toRoute) {
    _transitionCounts.putIfAbsent(fromRoute, () => {});
    _transitionCounts[fromRoute]![toRoute] = (_transitionCounts[fromRoute]![toRoute] ?? 0) + 1;
  }

  @override
  List<String> predictNextRoutes(String currentRoute, {double threshold = 0.35}) {
    final transitions = _transitionCounts[currentRoute];
    if (transitions == null || transitions.isEmpty) return [];

    final totalTransitions = transitions.values.reduce((a, b) => a + b);
    final totalDistinctStates = max(1, _transitionCounts.length);
    final denom = totalTransitions + (smoothingAlpha * totalDistinctStates);

    final List<String> predicted = [];
    for (final entry in transitions.entries) {
      final prob = (entry.value + smoothingAlpha) / denom;
      if (prob >= threshold) {
        predicted.add(entry.key);
      }
    }
    return predicted;
  }

  @override
  double getConfidence(String fromRoute, String targetRoute) {
    final transitions = _transitionCounts[fromRoute];
    if (transitions == null) return 0.0;
    final totalTransitions = transitions.values.reduce((a, b) => a + b);
    final count = transitions[targetRoute] ?? 0;
    return totalTransitions > 0 ? (count / totalTransitions) : 0.0;
  }

  @override
  Map<String, dynamic> exportState() => {
    'model': modelName,
    'matrix': _transitionCounts,
  };
}

/// Model 2: 2nd-Order Markov Chain P(S_{t+1} | S_t, S_{t-1}) with Katz-style Backoff
class MarkovSecondOrderModel implements PredictionModel {
  @override
  String get modelName => 'MarkovSecondOrder';

  final Map<String, Map<String, int>> _secondOrderCounts = {}; // Key: "$fromRoute2->$fromRoute1"
  final MarkovFirstOrderModel _firstOrderFallback = MarkovFirstOrderModel();
  String? _previousRoute;

  @override
  void recordTransition(String fromRoute, String toRoute) {
    _firstOrderFallback.recordTransition(fromRoute, toRoute);

    if (_previousRoute != null) {
      final key = '$_previousRoute->$fromRoute';
      _secondOrderCounts.putIfAbsent(key, () => {});
      _secondOrderCounts[key]![toRoute] = (_secondOrderCounts[key]![toRoute] ?? 0) + 1;
    }
    _previousRoute = fromRoute;
  }

  @override
  List<String> predictNextRoutes(String currentRoute, {double threshold = 0.35}) {
    if (_previousRoute != null) {
      final key = '$_previousRoute->$currentRoute';
      final transitions = _secondOrderCounts[key];
      if (transitions != null && transitions.isNotEmpty) {
        final total = transitions.values.reduce((a, b) => a + b);
        if (total >= 2) {
          final List<String> predicted = [];
          for (final entry in transitions.entries) {
            final prob = entry.value / total;
            if (prob >= threshold) {
              predicted.add(entry.key);
            }
          }
          if (predicted.isNotEmpty) return predicted;
        }
      }
    }
    // Fallback to 1st order
    return _firstOrderFallback.predictNextRoutes(currentRoute, threshold: threshold);
  }

  @override
  double getConfidence(String fromRoute, String targetRoute) {
    if (_previousRoute != null) {
      final key = '$_previousRoute->$fromRoute';
      final transitions = _secondOrderCounts[key];
      if (transitions != null && transitions.containsKey(targetRoute)) {
        final total = transitions.values.reduce((a, b) => a + b);
        return transitions[targetRoute]! / total;
      }
    }
    return _firstOrderFallback.getConfidence(fromRoute, targetRoute);
  }

  @override
  Map<String, dynamic> exportState() => {
    'model': modelName,
    'second_order_matrix': _secondOrderCounts,
    'first_order_fallback': _firstOrderFallback.exportState(),
  };
}

/// Model 3: Contextual Multi-Armed Bandit with Dynamic Confidence Thresholding
class ContextualBanditModel implements PredictionModel {
  @override
  String get modelName => 'ContextualBandit';

  final MarkovSecondOrderModel _coreMarkov = MarkovSecondOrderModel();
  
  // Weights for context features: [base, battery, network, ram]
  double baseThreshold = 0.35;
  double betaBattery = 0.20; // High battery lowers threshold (more aggressive)
  double betaNetwork = 0.15; // Fast network lowers threshold
  double betaRam = 0.10;     // High free RAM lowers threshold

  // Simulated device context [0.0 = low/constrained, 1.0 = high/ample]
  double deviceBatteryLevel = 0.85;
  double deviceNetworkQuality = 0.90;
  double deviceFreeRamRatio = 0.75;

  double computeDynamicThreshold() {
    // High resources -> lower threshold (more prefetching)
    // Low resources -> higher threshold (conservative prefetching)
    final resourceScore = (deviceBatteryLevel * 0.4) + (deviceNetworkQuality * 0.4) + (deviceFreeRamRatio * 0.2);
    final dynamicTau = baseThreshold + (0.5 - resourceScore) * 0.3;
    return dynamicTau.clamp(0.15, 0.65);
  }

  @override
  void recordTransition(String fromRoute, String toRoute) {
    _coreMarkov.recordTransition(fromRoute, toRoute);
  }

  @override
  List<String> predictNextRoutes(String currentRoute, {double threshold = 0.35}) {
    final dynamicTau = computeDynamicThreshold();
    return _coreMarkov.predictNextRoutes(currentRoute, threshold: dynamicTau);
  }

  @override
  double getConfidence(String fromRoute, String targetRoute) {
    return _coreMarkov.getConfidence(fromRoute, targetRoute);
  }

  @override
  Map<String, dynamic> exportState() => {
    'model': modelName,
    'dynamic_threshold': computeDynamicThreshold(),
    'context': {
      'battery': deviceBatteryLevel,
      'network': deviceNetworkQuality,
      'free_ram': deviceFreeRamRatio,
    },
    'core_markov': _coreMarkov.exportState(),
  };
}
