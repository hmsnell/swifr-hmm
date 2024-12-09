import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error
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
    
    # Reset index to ensure continuous integer indexing
    complete_data = complete_data.reset_index(drop=True)
    
    print(f"Original dataset shape: {data.shape}")
    print(f"Complete cases shape: {complete_data.shape}")
    print(f"Percentage of complete cases: {(len(complete_data) / len(data) * 100):.2f}%")
    
    return complete_data

def introduce_missingness(data, rate=0.1, random_state=None):
    """
    Introduce missing values at exactly the specified rate in the complete dataset.
    """
    if random_state is not None:
        np.random.seed(random_state)
        
    missing_data = data.copy()
    n_rows = len(data)
    
    for col in COLS_TO_PROCESS:
        # Calculate exact number of values to make missing
        n_missing = int(rate * n_rows)
        # Generate random row indices
        indices_to_remove = np.random.choice(missing_data.index, size=n_missing, replace=False)
        missing_data.loc[indices_to_remove, col] = np.nan
    
    # Verify missingness rate
    actual_rates = {col: (missing_data[col].isna().sum() / n_rows * 100) 
                   for col in COLS_TO_PROCESS}
    print("\nActual missingness rates:")
    for col, actual_rate in actual_rates.items():
        print(f"{col}: {actual_rate:.1f}%")
    
    return missing_data

def interpolate(data):
    """Interpolate missing values using linear interpolation."""
    interpolated_data = data.copy()
    
    # Sort by Physical_Distance and keep track of original index
    sorted_data = interpolated_data.sort_values('Physical_Distance')
    
    for col in COLS_TO_PROCESS:
        # Get non-NaN values
        mask = ~sorted_data[col].isna()
        x = sorted_data.loc[mask, 'Physical_Distance'].values
        y = sorted_data.loc[mask, col].values
        
        if len(x) > 0:
            # Remove duplicate x values by averaging y values
            unique_x, unique_indices = np.unique(x, return_inverse=True)
            unique_y = np.array([y[unique_indices == i].mean() for i in range(len(unique_x))])
            
            # Perform linear interpolation
            f = np.interp(sorted_data['Physical_Distance'].values, unique_x, unique_y)
            sorted_data[col] = f
            
            # Handle any remaining NaNs or infinities
            sorted_data[col] = pd.to_numeric(sorted_data[col], errors='coerce')
            sorted_data[col] = sorted_data[col].replace([np.inf, -np.inf], np.nan)
            sorted_data[col] = sorted_data[col].fillna(method='ffill').fillna(method='bfill')
    
    # Return to original order
    return sorted_data.sort_index()

def calculate_interpolation_accuracy(original_data, data_with_missing, interpolated_data):
    """Calculate MSE for interpolated values compared to original values."""
    column_mses = {}
    
    for col in COLS_TO_PROCESS:
        # Find where values were artificially made missing
        missing_mask = data_with_missing[col].isna()
        
        if missing_mask.any():
            original = original_data.loc[missing_mask, col]
            interpolated = interpolated_data.loc[missing_mask, col]
            
            # Remove any rows where either value is NaN or infinite
            valid_mask = ~(original.isna() | interpolated.isna() | 
                         np.isinf(original) | np.isinf(interpolated))
            
            if valid_mask.any():
                mse = mean_squared_error(
                    original[valid_mask],
                    interpolated[valid_mask]
                )
                column_mses[col] = mse
                print(f"MSE for {col}: {mse:.4f}")
    
    # Return average MSE across columns
    overall_mse = np.mean(list(column_mses.values())) if column_mses else np.nan
    print(f"Overall MSE: {overall_mse:.4f}")
    return overall_mse

def run_analysis(data, missingness_rates=[0.1, 0.25, 0.5, 0.75]):
    """Run the complete analysis pipeline on complete cases only."""
    # Preprocess the data to get only complete cases
    complete_data = preprocess_data(data)
    
    results = []

    for rate in missingness_rates:
        print(f"\nProcessing missingness rate: {rate*100}%")
        
        # Create dataset with missing values
        data_with_missing = introduce_missingness(complete_data, rate, 
                                                random_state=int(rate * 100))
        
        # Perform linear interpolation
        print("\nLinear Interpolation:")
        interpolated_linear = interpolate(data_with_missing)
        linear_mse = calculate_interpolation_accuracy(complete_data, data_with_missing, 
                                                      interpolated_linear)
        results.append(linear_mse)
    
    # Visualization
    plt.figure(figsize=(10, 6))
    plt.plot(missingness_rates, results, 'b-o', label='Linear Interpolation')
    plt.xlabel('Missingness Rate')
    plt.ylabel('Mean Squared Error (MSE)')
    plt.title('Interpolation Performance vs. Missingness Rate')
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.show()

# Example usage:
data = pd.read_csv('threeclass_testingdata_dhruv', sep='\s+', header=0, 
                   names=["SNP_name", "Physical_Distance", "Map_Distance", 
                         "DDAF", "nSL", "iHS", "FST", "label"])
# randomly sampled 100k rows
data = data.sample(n=500000, random_state=1)
run_analysis(data)
