functions {
  vector additive_log_ratio(vector x, int len_x){
    // declarations
    vector[len_x] x_ratio;
    vector[len_x] y;
    // calculations
    for (i in 1:len_x)
      x_ratio[i] = x[i]/x[len_x];
    y = log(x_ratio);
    return y;
  }  
  
  vector inv_additive_log_ratio(vector x, int len_x){
    // declarations
    vector[len_x] x_exp;
    vector[len_x] y;
    // calculations
    x_exp = exp(x);
    y = x_exp / sum(x_exp);
    return y;
  }
  
    vector change_order_ppi(vector ppi_in, int len_ppi){
    vector[len_ppi] ppi_out;
    ppi_out[1:2] = ppi_in[1:2];
    ppi_out[3] = ppi_in[4];
    ppi_out[4] = ppi_in[3];
    return ppi_out;
  }
  
  vector colsum(matrix A, int m, int n){
    vector[n] a;
    for (j in 1:n){
      a[j] = 0;
      for (i in 1:m){
        a[j] = a[j] + A[i, j];
      }
    }
    return a;
  }
  
  vector rowsum(matrix A, int m, int n){
    vector[m] a;
    for (i in 1:m){
      a[i] = 0;
      for (j in 1:n){
        a[i] = a[i] + A[i, j];
      }
    }
    return a;
  }
}

data {
  // dimensions 
  int<lower=0> n_days; // 1:T
  int<lower=0> n_polls_state; // 1:I
  int<lower=0> n_polls_reg; // 1:K
  int<lower=0> n_polls_nat; // 1:J
  int<lower=0> n_parties; // 1:P
  int<lower=0> n_regions; // 1:R
  int<lower=0> n_states; // 1:S
  int<lower=0> n_pollsters; // 1:H
  
  int<lower=0> dim_mmu_v; // sum(n_parties_by_state - 1)
  array[n_states] int n_parties_by_state;
  array[n_regions] int n_parties_by_region;
  
  // auxiliary variable needed when converting (two-dimensional) mmu_v to (three-dimensional) mmu 
  array[n_states] int offset_mmu_v; 
    
  // state_polls
  array[n_parties, n_polls_state] int y;
  array[n_polls_state] int day_poll;
  array[n_polls_state] int state_poll;
  array[n_polls_state] int n_responses;
  array[n_polls_state] int house_poll;
  
  // regional polls
  array[n_parties, n_polls_reg] int y_reg;
  array[n_polls_reg] int day_poll_reg;
  array[n_polls_reg] int n_responses_reg;
  array[n_polls_reg] int house_poll_reg;
  array[n_polls_reg] int region_poll;
  matrix[n_regions, n_states] state_weights_reg;
  
  // national polls
  array[n_parties, n_polls_nat] int y_nat;
  array[n_polls_nat] int day_poll_nat;
  array[n_polls_nat] int n_responses_nat;
  array[n_polls_nat] int house_poll_nat;
  vector[n_states] state_weights_nat;
    
  // priors
  vector[dim_mmu_v] m_mmu_T;
  cov_matrix[dim_mmu_v] V_mmu_T;
  real<lower=0> sig_ddelta; 
  
  // params
  cov_matrix[dim_mmu_v] W;
}

transformed data {
  cholesky_factor_cov[dim_mmu_v] chol_W;
  chol_W = cholesky_decompose(W);
  cholesky_factor_cov[dim_mmu_v] chol_V_mmu_T;
  chol_V_mmu_T = cholesky_decompose(V_mmu_T);
}

parameters {

  matrix[dim_mmu_v, n_days] w;

  vector[dim_mmu_v] mmu_T;
  
  matrix[n_pollsters - 1, n_parties - 1] ddelta_raw;
}

transformed parameters {

  // declarations
  matrix[dim_mmu_v, n_days] mmu_v; 
  array[n_days] matrix[n_parties, n_states] mmu; 
  array[n_days] matrix[n_parties, n_states] ppi;
  matrix[n_parties, n_polls_state] ttheta;
  matrix[n_pollsters, n_parties] ddelta;
  
  array[n_days] matrix[n_parties, n_regions] ppi_reg;
  array[n_days] matrix[n_parties, n_regions] mmu_reg;
  matrix[n_parties, n_polls_reg] ttheta_reg;
  
  array[n_days] matrix[n_parties, 1] mmu_nat;
  array[n_days] matrix[n_parties, 1] ppi_nat;
  matrix[n_parties, n_polls_nat] ttheta_nat;
  
  // house effects
  ddelta[2:n_pollsters, 2:n_parties] = ddelta_raw;
  
  for (p in 2:n_parties)
          ddelta[1, p] = 0 - sum(ddelta[2:n_pollsters, p]);
      
      
  for(h in 1:n_pollsters)  
          ddelta[h, 1] = 0 - sum(ddelta[h, 2:n_parties]);
  
  // reverse random walk

  mmu_v[:, n_days] = mmu_T;
  
  for (t in 1 : (n_days - 1)) {
    mmu_v[:, n_days - t] = mmu_v[:, n_days + 1 - t] + chol_W * w[:, n_days - t];
  }
  
  // convert mmu_v to mmu
  for (t in 1 : n_days){
    for (s in 1 : n_states){
      for (p in 1:n_parties){
        if (p >= n_parties_by_state[s]){
          mmu[t][p, s] = 0;
        } else {
          mmu[t][p, s] = mmu_v[offset_mmu_v[s] + p, t];
        }
      }
    }
  } 
  
  // transform log ratios
  
  for (t in 1 : n_days){
    for (s in 1 : n_states){
      // initialize with 0
      ppi[t][:, s] = rep_vector(0, n_parties);
      // voting intentions transformed back from log ratio space
      ppi[t][1:n_parties_by_state[s], s] = inv_additive_log_ratio(mmu[t][1:n_parties_by_state[s], s], n_parties_by_state[s]); 
    }
  }
  
  // add house effects to (log ratio) voting intentions to map with polls
  for (i in 1 : n_polls_state){
    // initialize ttheta[, i] with 0
    ttheta[, i] = rep_vector(0, n_parties);
    //mmu_i = mmu[day_poll[i]][1:n_parties_by_state[state_poll[i]], state_poll[i]]
    //ddelta_i = ddelta[house_poll[i], 1:n_parties_by_state[state_poll[i]]]
    // ttheta_i = alr^-1(mmu_i + ddelta_i)
    ttheta[1:n_parties_by_state[state_poll[i]], i] = inv_additive_log_ratio(to_vector(mmu[day_poll[i]][1:n_parties_by_state[state_poll[i]], state_poll[i]]) + to_vector(ddelta[house_poll[i], 1:n_parties_by_state[state_poll[i]]]), n_parties_by_state[state_poll[i]]); 
  }  
  
  // aggregate state ppi's to regional level
  matrix[n_parties, n_states] ppi_w_reg;
  for (t in 1 : n_days){
    for (r in 1 : n_regions){
      // set values to 0 
      ppi_w_reg = rep_matrix(0, n_parties, n_states);
      ppi_reg[t][:, r] = rep_vector(0, n_parties);
      mmu_reg[t][:, r] = rep_vector(0, n_parties);
      for (s in 1:n_states){
        // check if state is in region
        if (state_weights_reg[r, s] == 0){
            ppi_w_reg[1:n_parties_by_region[r], s] = rep_vector(0, n_parties_by_region[r]);
        } else {
            ppi_w_reg[1:n_parties_by_region[r], s] = ppi[t][1:n_parties_by_region[r], s] * state_weights_reg[r, s];
        }
      }
      ppi_reg[t][1:n_parties_by_region[r], r] = rowsum(ppi_w_reg[1:n_parties_by_region[r], :], n_parties_by_region[r], n_states);
      // convert weighted regional voting intentions back to log ratio space
      mmu_reg[t][1:n_parties_by_region[r], r] = additive_log_ratio(ppi_reg[t][1:n_parties_by_region[r], r], n_parties_by_region[r]);
    }
  }
  
  // add house effects to aggregated (log ratio) voting intentions at regional level to map with regional polls
  for (k in 1 : n_polls_reg){
    // initialize ttheta[, i] with 0
    ttheta_reg[, k] = rep_vector(0, n_parties);
    ttheta_reg[1:n_parties_by_region[region_poll[k]], k] = inv_additive_log_ratio(to_vector(mmu_reg[day_poll_reg[k]][1:n_parties_by_region[region_poll[k]], region_poll[k]]) + to_vector(ddelta[house_poll_reg[k], 1:n_parties_by_region[region_poll[k]]]), n_parties_by_region[region_poll[k]]); 
  }
  
  
  // aggregate state ppi's to the national level
  matrix[n_parties, n_states] ppi_w_nat;
  vector[n_parties] mmu_star;
  vector[n_parties] ppi_star_wrong_order;
  vector[n_parties] ppi_star;
  for (t in 1 : n_days){
      for (s in 1:n_states){
        mmu_star = rep_vector(0, n_parties);
        if (n_parties_by_state[s] == 3){
          mmu_star[1:2] = to_vector(mmu[t][1:2, s]); 
          mmu_star[3] = -100.0; // insert value for missing party!
          ppi_star_wrong_order = inv_additive_log_ratio(mmu_star, n_parties);
          ppi_star = change_order_ppi(ppi_star_wrong_order, n_parties);
          ppi_w_nat[:, s] = ppi_star * state_weights_nat[s];
        }  else {
          ppi_w_nat[:, s] = inv_additive_log_ratio(mmu[t][:, s], n_parties) * state_weights_nat[s];
        }
      }
      ppi_nat[t][:, 1] = rowsum(ppi_w_nat, n_parties, n_states);
      // convert weighted national voting intentions back to log ratio space
      mmu_nat[t][:, 1] = additive_log_ratio(ppi_nat[t][:, 1], n_parties);
  }
  
  // add house effects to aggregated (log ratio) voting intentions at national level to map with regional polls
  for (j in 1 : n_polls_nat){
    // initialize ttheta[, j] with 0
    ttheta_nat[:, j] = rep_vector(0, n_parties);
    ttheta_nat[:, j] = inv_additive_log_ratio(to_vector(mmu_nat[day_poll_nat[j]][:, 1]) + to_vector(ddelta[house_poll_nat[j], :]), n_parties); 
  }  
}

model {

  //mmu_T ~ multi_normal(m_mmu_T, V_mmu_T);
  mmu_T ~ multi_normal_cholesky(m_mmu_T, chol_V_mmu_T);
  to_vector(w) ~ std_normal(); // not entirely sure, why to_vector() is needed! See Economist's 2020 poll model 

  for (i in 1:n_polls_state){
    y[1:n_parties_by_state[state_poll[i]], i] ~ multinomial(ttheta[1:n_parties_by_state[state_poll[i]], i]); 
  }

  for (k in 1:n_polls_reg){
    y_reg[1:n_parties_by_region[region_poll[k]], k] ~ multinomial(ttheta_reg[1:n_parties_by_region[region_poll[k]], k]);
  }

  for (j in 1:n_polls_nat){
    y_nat[:, j] ~ multinomial(ttheta_nat[:, j]);
  }
  
  // house effects
  for (p in 1:(n_parties-1)) 
    for (h in 1:(n_pollsters-1))
          ddelta_raw[h, p] ~ normal(0, sig_ddelta); 
  
}
