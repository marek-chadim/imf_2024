---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.16.1
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

# Markov Chains Homework


## Ergodicity


Under irreducibility, the following result holds: for all $ x \in S $,

$$
\frac{1}{m} \sum_{t = 1}^m \mathbf{1}\{X_t = x\}  \to \psi^*(x)
    \quad \text{as } m \to \infty 
$$

Here

- $ \mathbf{1}\{X_t = x\} = 1 $ if $ X_t = x $ and zero otherwise  
- convergence is with probability one  
- the result does not depend on the marginal distribution  of $ X_0 $  

The convergence asserted above is a special case of a law of large numbers
result for Markov chains -- see, for example, [EDTC](http://johnstachurski.net/edtc.html),
section 4.3.4.

The result tells us that the fraction of time the chain spends at state $ x $ converges to $ \psi^*(x) $ as time goes to infinity.

This gives us another way to interpret the stationary distribution.

+++

### Example

Recall our cross-sectional interpretation of the employment/unemployment model discussed in the finite Markov chain lecture.

Assume that $ \alpha \in (0,1) $ and $ \beta \in (0,1) $, so that irreducibility and aperiodicity both hold.

We saw that the stationary distribution is $ (p, 1-p) $, where

$$
    p = \frac{\beta}{\alpha + \beta}
$$

In the cross-sectional interpretation, this is the fraction of people unemployed.

In view of our latest (ergodicity) result, it is also the fraction of time that a single worker can expect to spend unemployed.

Thus, in the long-run, cross-sectional averages for a population and time-series averages for a given person coincide.

This is one aspect of the concept  of ergodicity.

+++

**Exercise**

According to the discussion above, if a worker’s employment dynamics obey the stochastic matrix

$$
P
= \left(
\begin{array}{cc}
    1 - \alpha & \alpha \\
    \beta & 1 - \beta
\end{array}
  \right)
$$

with $ \alpha \in (0,1) $ and $ \beta \in (0,1) $, then, in the long-run, the fraction
of time spent unemployed will be

$$
p := \frac{\beta}{\alpha + \beta}
$$

In other words, if $ \{X_t\} $ represents the Markov chain for
employment, then $ \bar X_m \to p $ as $ m \to \infty $, where

$$
\bar X_m := \frac{1}{m} \sum_{t = 1}^m \mathbf{1}\{X_t = 0\}
$$

This exercise asks you to illustrate convergence by computing
$ \bar X_m $ for large $ m $ and checking that
it is close to $ p $.

You will see that this statement is true regardless of the choice of initial
condition or the values of $ \alpha, \beta $, provided both lie in
$ (0, 1) $.

Here's some code to start you off.

```{code-cell} ipython3
α = β = 0.1
p = β / (α + β)

P = ((1 - α,       α),               # Careful: P and p are distinct
     (    β,   1 - β))
mc = MarkovChain(P)
```

**Solution**

The plots below show the time series of $ \bar X_m - p $ for two initial
conditions.

As $ m $ gets large, both series converge to zero.

```{code-cell} ipython3
N = 20_000
fig, ax = plt.subplots()
ax.set_ylim(-0.25, 0.25)
ax.grid()
ax.hlines(0, 0, N, lw=2, alpha=0.6)   # Horizonal line at zero

for x0 in (0, 1):
    # Generate time series for worker that starts at x0
    X = mc.simulate(N, init=x0)
    # Compute fraction of time spent unemployed, for each n
    X_bar = (X == 0).cumsum() / (1 + np.arange(N, dtype=float))
    # Plot
    ax.fill_between(range(N), np.zeros(N), X_bar - p, alpha=0.1)
    ax.plot(X_bar - p, label=f'$X_0 = \, {x0} $')
    # Overlay in black--make lines clearer
    ax.plot(X_bar - p, 'k-', alpha=0.6)

ax.legend(loc='upper right')
plt.show()
```

## Computing Expectations


We are interested in computing expressions like

$$
    \mathbb E [ h(X_t) ] 
$$

and conditional expectations such as

$$
    \mathbb E [ h(X_{t + k})  \mid X_t = x] 
$$

where

- $ \{X_t\} $ is a Markov chain generated by $ n \times n $ stochastic matrix $ P $
-  $ \psi $ is the distribution of $ X_0 $
- $ h $ is a given function, which, in terms of matrix
  algebra, we’ll think of as the column vector  


$$
    h
    = \left(
    \begin{array}{c}
        h(x_1) \\
        \vdots \\
        h(x_n)
    \end{array}
      \right)
$$

Computing the unconditional expectation  is easy.

We just sum over the marginal  distribution  of $ X_t $ to get

$$
\mathbb E [ h(X_t) ]
= \sum_{x \in S} (\psi P^t)(x) h(x)
$$



Since $ \psi $ and hence $ \psi P^t $ are row vectors, we can also
write this as

$$
\mathbb E [ h(X_t) ]
=  \psi P^t h
$$

For the conditional expectation we need to sum over the conditional distribution
of $ X_{t + k} $ given $ X_t = x $.

We already know that this is $ P^k(x, \cdot) $, so


$$
\mathbb E [ h(X_{t + k})  \mid X_t = x]
= (P^k h)(x) 
$$

The vector $ P^k h $ stores the conditional expectation $ \mathbb E [ h(X_{t + k})  \mid X_t = x] $ over all $ x $.

+++

### Expectations of Geometric Sums

To compute present values we often need to calculate expectation of a geometric sum, such as
$ \sum_t \beta^t h(X_t) $.

In view of the preceding discussion, this is

$$
\mathbb{E} \left[
        \sum_{t=0}^\infty \beta^t h(X_t) \mid X_0 = x
    \right]
    =         \sum_{t=0}^\infty \mathbb{E} \left[ \beta^t h(X_t) \mid X_t = x
    \right]
        = \sum_{t=0}^\infty ((\beta P)^t h)(x)
$$

+++

**Exercise**  Suppose that the state of the economy is given by Hamilton's Markov chain, so that

```{code-cell} ipython3
P = ((0.971, 0.029, 0.0), 
     (0.145, 0.778, 0.077), 
     (0.0,   0.508, 0.492))
```

Suppose that current profits $\pi(X_t)$ of a firm are given by the vector 

```{code-cell} ipython3
π = (10, 5, -25)
```

Let the discount factor be

```{code-cell} ipython3
β = 0.99
```

Using the Neumann series lemma, which tells us that

$$
(I - \beta P)^{-1}  = I + \beta P + \beta^2 P^2 + \cdots
$$

compute the expected present value of the firm.

```{code-cell} ipython3

h, P = np.asarray(h), np.asarray(P)
I = np.identity(len(h))
v = np.linalg.solve(I - β * P, h)
v
```

```{code-cell} ipython3

```
