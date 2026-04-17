
# Load packages and data
pacman::p_load(here, cmdstanr, tidyverse, posterior, bayesplot)

# import simulation data
data_raw <- read_csv(here(data_name))

# Specify model file path
stan_file <- here(stan_file_name)

# Define path for saving fitted model object
stan_results_dir <- "fitted_models"
model_file <- here(output_dir, fitted_model_name)

if (!dir.exists(here(stan_results_dir))) {
  dir.create(here(stan_results_dir), recursive = TRUE)
}


cat("Compiling and fitting Stan model...\n")

# Compile the Stan model
model <- cmdstan_model(stan_file,
                               cpp_options = list(stan_threads = FALSE), # Enable threading
                               stanc_options = list("O1")) # Basic optimization

# Sample from the posterior distribution using MCMC
fit <- model$sample(
  data = list(N = nrow(data_raw), 
                    first_rating = data_raw$first_ratings, 
                    group_rating = data_raw$group_ratings,
                    second_rating = data_raw$second_rating,
                    prior_mu = 0,
                    prior_sigma = 0.5,
                    total = rep(7, nrow(data_raw))),      
  seed = 123,                    # For reproducible MCMC sampling
  chains = 4,                    # Number of parallel Markov chains (recommend 4)
  parallel_chains = 4, # Run chains in parallel
  #threads_per_chain = 1,         # For within-chain parallelization (usually 1 is fine)
  iter_warmup = 1000,            # Number of warmup iterations per chain (discarded)
  iter_sampling = 2000,          # Number of sampling iterations per chain (kept)
  refresh = 0,                   # How often to print progress updates. 0 means never since the model is so fast
  max_treedepth = 10,            # Controls complexity of MCMC steps (adjust if needed)
  adapt_delta = 0.8              # Target acceptance rate (adjust if divergences occur)
)

# Save the fitted model object
fit$save_object(file = model_file)
cat("Model fit completed and saved to:", model_file, "\n")
  


