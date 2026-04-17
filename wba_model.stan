//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//


// Making a stan model to recover weight parameters in a weighted bayesian agent

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  array[N] int<lower=0, upper=7> second_rating;
  array[N] int<lower=0> first_rating;
  array[N] int<lower=0> total;
  array[N] int<lower=0> group_rating;
  real prior_mu; // not used currently
  real<lower=0> prior_sigma; // not used currently
    
}

// The parameters accepted by the model. Our model
parameters {
  real<lower=0, upper=1>rho; 
  real<lower=0>kappa; 
}

// adding transformed parameters (we are re-parametizing the ratings) THESE ARE DETERMINISTIC NOW
transformed parameters {
  real<lower=0> w_first = rho * kappa; // weight of subject's own first rating
  real<lower=0> w_group = (1.0-rho) * kappa; // weight of the group rating
}

model {
  
  target += beta_lpdf(rho | 2, 2); // these should be specified when calling the model  
  target += lognormal_lpdf(kappa | log(2), 0.5);


  // Defining likelihood functions
  vector[N] alpha_post = 0.5 + w_first * to_vector(first_rating) + w_group * to_vector(group_rating);
  vector[N] beta_post = 0.5 + w_first * (to_vector(total) - to_vector(first_rating)) + w_group * (to_vector(total) - to_vector(group_rating));
  
  target += beta_binomial_lpmf(second_rating | 7, alpha_post, beta_post);
  
}

generated quantities {
  vector[N] log_lik;
  array[N] int prior_pred;
  array[N] int posterior_pred;
  real lprior; // what is this??

  // it is an 'accumulator for joint prior log-density required by priorsense'...
  lprior = beta_lpdf(rho | 2, 2) + lognormal_lpdf(kappa | log(2), 0.5);
  
  real rho_prior = beta_rng(2, 2);
  real kappa_prior = lognormal_rng(log(2), 0.5);
  real wf_prior = rho_prior * kappa_prior;
  real wg_prior = (1.0-rho_prior) * kappa_prior;

  for (i in 1:N) {
    // posterior predictions
    real alpha_post = 0.5 + w_first * first_rating[i]
 + w_group * group_rating[i]; 
 
    real beta_post = 0.5 + w_first * (total[i] - first_rating[i]) + w_group * (total[i] - second_rating[i]);
 
    // what do we use this for?
    log_lik[i] = beta_binomial_lpmf(second_rating[i] | 7, alpha_post, beta_post);
    posterior_pred[i] = beta_binomial_rng(7, alpha_post, beta_post);
    
    // prior predictionts
    real ap = 0.5 + wf_prior * first_rating[i] + wg_prior * group_rating[i];
    real bp = 0.5 + wf_prior * (total[i] - first_rating[i]) + wg_prior * (total[i] - group_rating[i]);
    prior_pred[i] = beta_binomial_rng(i, ap, bp);
 }
}

