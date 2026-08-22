/// First-order Markov Chain Transition Matrix for Predictive Navigation & State Prefetching.
/// Tracks $P(S_{t+1} | S_t)$ across Multi-Screen topologies (Feed, Explore, Detail, Bookmarks).
class MarkovNavigationMatrix {
  // Map<CurrentState, Map<NextState, FrequencyCount>>
  final Map<String, Map<String, int>> _transitions = {};
  
  // Total transitions recorded from each state
  final Map<String, int> _stateCounts = {};

  /// Record an observed transition: previousState -> nextState
  void recordTransition(String fromState, String toState) {
    if (fromState == toState) return;
    _transitions.putIfAbsent(fromState, () => {});
    final currentCount = _transitions[fromState]![toState] ?? 0;
    _transitions[fromState]![toState] = currentCount + 1;

    _stateCounts[fromState] = (_stateCounts[fromState] ?? 0) + 1;
  }

  /// Predict top-k most likely next states with confidence score tau
  List<PredictionCandidate> predictNextStates(String currentState, {int topK = 3, double minConfidence = 0.20}) {
    if (!_transitions.containsKey(currentState)) {
      return [];
    }

    final nextMap = _transitions[currentState]!;
    final total = _stateCounts[currentState] ?? 1;

    final candidates = <PredictionCandidate>[];
    for (final entry in nextMap.entries) {
      final confidence = entry.value / total.toDouble();
      if (confidence >= minConfidence) {
        candidates.add(PredictionCandidate(
          state: entry.key,
          confidence: confidence,
          frequency: entry.value,
        ));
      }
    }

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates.take(topK).toList();
  }

  Map<String, dynamic> exportGraphSummary() {
    return {
      'total_observed_states': _stateCounts.length,
      'state_transition_matrix': _transitions,
    };
  }
}

class PredictionCandidate {
  final String state;
  final double confidence; // [0.0 - 1.0]
  final int frequency;

  PredictionCandidate({
    required this.state,
    required this.confidence,
    required this.frequency,
  });
}
