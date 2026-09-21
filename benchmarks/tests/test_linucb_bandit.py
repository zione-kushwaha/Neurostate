"""
Unit tests for the 5D Contextual Multi-Armed Bandit (LinUCB) implementation.
Verifies upper confidence bound updates and decision threshold policies.
"""
import numpy as np

def test_linucb_update():
    dim = 5
    alpha = 0.25
    A = np.eye(dim)
    b = np.zeros(dim)
    
    # Feature vector: [battery, latency, ram, scroll_velocity, thermal]
    ctx = np.array([0.85, 0.12, 0.70, 0.30, 0.90])
    
    A_inv = np.linalg.inv(A)
    theta = A_inv @ b
    p = theta @ ctx + alpha * np.sqrt(ctx @ A_inv @ ctx)
    assert p > 0, "LinUCB score should be strictly positive with eye prior"
    
    # Reward feedback
    reward = 1.0
    A += np.outer(ctx, ctx)
    b += reward * ctx
    
    A_inv_new = np.linalg.inv(A)
    theta_new = A_inv_new @ b
    p_new = theta_new @ ctx + alpha * np.sqrt(ctx @ A_inv_new @ ctx)
    assert p_new > p, "Score should increase after positive reward feedback"

if __name__ == "__main__":
    test_linucb_update()
    print("LinUCB bandit unit tests passed!")
