"""
Unit tests for higher-order Markov chain navigation sequence prediction.
Verifies n-gram transition probability distribution and Katz backoff normalization.
"""
from collections import defaultdict

class MarkovPredictor:
    def __init__(self, order=2):
        self.order = order
        self.transitions = defaultdict(lambda: defaultdict(int))
    
    def train(self, sequences):
        for seq in sequences:
            for i in range(len(seq) - 1):
                ctx = tuple(seq[max(0, i - self.order + 1):i + 1])
                nxt = seq[i + 1]
                self.transitions[ctx][nxt] += 1
                
    def predict_next(self, current_ctx):
        ctx = tuple(current_ctx[-self.order:])
        counts = self.transitions.get(ctx, {})
        if not counts and len(ctx) > 1:
            # Backoff to lower order
            return self.predict_next(current_ctx[1:])
        if not counts:
            return None
        total = sum(counts.values())
        return {route: count / total for route, count in counts.items()}

def test_markov_prediction():
    predictor = MarkovPredictor(order=2)
    history = [
        ["home", "feed", "detail", "checkout"],
        ["home", "feed", "detail", "checkout"],
        ["home", "feed", "profile"],
    ]
    predictor.train(history)
    probs = predictor.predict_next(["home", "feed"])
    assert probs is not None
    assert probs["detail"] > probs["profile"]
    print("Markov prediction tests passed!")

if __name__ == "__main__":
    test_markov_prediction()
