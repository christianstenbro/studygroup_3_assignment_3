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
  array[N] int<lower=0, upper=7> choice;
  array[N] int<lower=0> first_rating;
  array[N] int<lower=0> total;
  array[N] int<lower=0> group_rating;
  array[N] real<lower=0> prior_mu;
  array[N] real prior_sigma;
    
}

// The parameters accepted by the model. Our model
parameters {
  real<lower=0>w_first; // weight of subject's own first rating for a 
  real<lower=0>w_group; // weight of the group rating
}

model {
  
  target += lognormal_lpdf(w_first | prior_mu, prior_sigma) // these should be specified when calling the model  
  target += lognormal_lpdf(w_group | prior_mu, prior_sigma)


  // Defining likelihood functions


}

