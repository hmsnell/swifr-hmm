import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from scipy.stats import entropy  # For KL divergence calculation
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
import warnings
warnings.filterwarnings('ignore')

# Define columns to process globally
COLS_TO_PROCESS = ['DDAF', 'nSL', 'iHS', 'FST']

def preprocess_data(data):
    """
    Preprocess the data by handling -998 values and taking absolute values.
    Returns only rows with complete data across all columns of interest.
    """
    processed = data.copy()
    processed.replace(-998, np.nan, inplace=True)
    
    # Take absolute values of the statistics
    processed[COLS_TO_PROCESS] = processed[COLS_TO_PROCESS].abs()
    
    # Keep only rows with complete data across all columns of interest
    complete_data = processed.dropna(subset=COLS_TO_PROCESS)
    
    # Reset index for continuous integer indexing
    complete_data = complete_data.reset_index(drop=True)
    return complete_data

def introduce_missingness(data, target_stat, rate, random_state=None):
    """
    Introduce missing values at the specified rate for `target_stat`.
    """
    if random_state is not None:
        np.random.seed(random_state)
        
    data_with_missing = data.copy()
    n_rows = len(data)
    
    # Calculate exact number of values to make missing
    n_missing = int(rate * n_rows)
    indices_to_remove = np.random.choice(data_with_missing.index, size=n_missing, replace=False)
    data_with_missing.loc[indices_to_remove, target_stat] = np.nan
    
    return data_with_missing

def build_model(input_dim):
    """Define and compile a simple neural network model."""
    model = Sequential([
        Dense(64, activation='relu', input_dim=input_dim),
        Dense(32, activation='relu'),
        Dense(1)  # Output layer for regression
    ])
    model.compile(optimizer=Adam(learning_rate=0.001), loss='mse')
    return model

def calculate_kl_divergence(original_values, filled_values, bins=50):
    """
    Calculate the KL divergence between the distributions of original and filled values.
    """
    # Compute histograms to approximate distributions
    original_hist, bin_edges = np.histogram(original_values, bins=bins, density=True)
    filled_hist, _ = np.histogram(filled_values, bins=bin_edges, density=True)
    
    # Add a small value to avoid division by zero in KL divergence
    original_hist += 1e-10
    filled_hist += 1e-10
    
    # Calculate KL divergence
    kl_div = entropy(filled_hist, original_hist)
    return kl_div

def train_and_evaluate_kl(data, target_stat):
    """
    Train a model to predict `target_stat` based on the other three stats
    and evaluate using KL divergence.
    """
    # Define input and output columns
    input_cols = [col for col in COLS_TO_PROCESS if col != target_stat]
    
    # Split the data
    X = data[input_cols]
    y = data[target_stat]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Build and train the model
    model = build_model(input_dim=3)
    model.fit(X_train, y_train, epochs=10, batch_size=32, validation_split=0.1, verbose=1)
    
    # Predict on test set
    y_pred = model.predict(X_test).flatten()
    
    # Calculate KL divergence between predicted and actual distributions
    kl_div = calculate_kl_divergence(y_test, y_pred)
    print(f"KL Divergence for predicting {target_stat}: {kl_div:.4f}")
    
    return kl_div

def run_analysis_kl(data, missingness_rates=[0.1, 0.25, 0.5, 0.75]):
    """Run the analysis pipeline with different levels of missingness, using KL divergence."""
    # Preprocess the data to get only complete cases
    complete_data = preprocess_data(data)
    
    # Dictionary to store KL divergence results
    results = {rate: {} for rate in missingness_rates}
    
    for target_stat in COLS_TO_PROCESS:
        print(f"\nTesting model for {target_stat} with different missingness rates...")
        for rate in missingness_rates:
            print(f"\nMissingness rate: {rate*100}% for {target_stat}")
            
            # Introduce missingness for the target statistic
            data_with_missing = introduce_missingness(complete_data, target_stat, rate, 
                                                      random_state=int(rate * 100))
            
            # Drop rows with missing target value for training
            data_for_training = data_with_missing.dropna(subset=[target_stat])
            
            # Train and evaluate the model using KL divergence
            kl_div = train_and_evaluate_kl(data_for_training, target_stat)
            print(f"KL Divergence for {target_stat} with {rate*100}% missingness: {kl_div:.4f}")
            
            # Store the result
            results[rate][target_stat] = kl_div
    
    # Plot the results
    plt.figure(figsize=(12, 8))
    for target_stat in COLS_TO_PROCESS:
        missing_rates = list(results.keys())
        kl_divergences = [results[rate][target_stat] for rate in missing_rates]
        plt.plot(missing_rates, kl_divergences, marker='o', label=f'Predicting {target_stat}')
        
    plt.xlabel('Missingness Rate')
    plt.ylabel('KL Divergence')
    plt.title('KL Divergence for Each Summary Statistic at Varying Missingness Rates')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()

# Example usage
data = pd.read_csv('threeclass_testingdata_dhruv', sep='\s+', header=0, 
                   names=["SNP_name", "Physical_Distance", "Map_Distance", 
                          "DDAF", "nSL", "iHS", "FST", "label"])
data = data.sample(n=500000, random_state=1)
run_analysis_kl(data)
