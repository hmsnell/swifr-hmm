import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers.legacy import Adam
import warnings

warnings.filterwarnings('ignore')

# Define columns to process globally
COLS_TO_PROCESS = ['DDAF', 'nSL', 'iHS', 'FST']


def preprocess_data(data):
    """
    Preprocess the data by handling 998 values and taking absolute values.
    """
    processed = data.copy()
    processed.replace(998, np.nan, inplace=True)
    # processed[COLS_TO_PROCESS] = processed[COLS_TO_PROCESS].abs()
    print(f"Original dataset shape: {data.shape}")
    print(f"Missing values in each column after preprocessing:")
    print(processed[COLS_TO_PROCESS].isna().sum())
    return processed


def build_model(input_dim):
    """Define and compile a simple neural network model."""
    model = Sequential([
        Dense(64, activation='relu', input_dim=input_dim),
        Dense(32, activation='relu'),
        Dense(1)  # Output layer for regression
    ])
    model.compile(optimizer=Adam(learning_rate=0.001), loss='mse')
    return model


def build_multi_output_model(input_dim):
    """Define and compile a neural network model for multi-output regression."""
    model = Sequential([
        Dense(64, activation='relu', input_dim=input_dim),
        Dense(32, activation='relu'),
        Dense(2)  # Two outputs for predicting both nSL and iHS
    ])
    model.compile(optimizer=Adam(learning_rate=0.001), loss='mse')
    return model


def train_models(data):
    """
    Train models to predict missing values.
    Returns three models:
    - One for predicting `nSL`
    - One for predicting `iHS`
    - One for predicting both `nSL` and `iHS`
    """
    models = {}

    # Train model to predict nSL
    data_nsl = data.dropna(subset=['DDAF', 'iHS', 'FST', 'nSL'])
    X_nsl = data_nsl[['DDAF', 'iHS', 'FST']]
    y_nsl = data_nsl['nSL']
    model_nsl = build_model(input_dim=X_nsl.shape[1])
    model_nsl.fit(X_nsl, y_nsl, epochs=2, batch_size=32, validation_split=0.1, verbose=1)
    models['nSL'] = model_nsl

    # Train model to predict iHS
    data_ihs = data.dropna(subset=['DDAF', 'nSL', 'FST', 'iHS'])
    X_ihs = data_ihs[['DDAF', 'nSL', 'FST']]
    y_ihs = data_ihs['iHS']
    model_ihs = build_model(input_dim=X_ihs.shape[1])
    model_ihs.fit(X_ihs, y_ihs, epochs=2, batch_size=32, validation_split=0.1, verbose=1)
    models['iHS'] = model_ihs

    # Train model to predict both nSL and iHS
    data_nsl_ihs = data.dropna(subset=['DDAF', 'FST', 'nSL', 'iHS'])
    X_nsl_ihs = data_nsl_ihs[['DDAF', 'FST']]
    y_nsl_ihs = data_nsl_ihs[['nSL', 'iHS']]
    model_nsl_ihs = build_multi_output_model(input_dim=X_nsl_ihs.shape[1])
    model_nsl_ihs.fit(X_nsl_ihs, y_nsl_ihs, epochs=2, batch_size=32, validation_split=0.1, verbose=1)
    models['nSL_iHS'] = model_nsl_ihs

    return models


def deep_learning_imputation(data, models):
    """
    Use trained models to fill missing values in the data.
    """
    dl_imputed_data = data.copy()

    # Predict nSL
    missing_nsl = dl_imputed_data['nSL'].isna() & dl_imputed_data[['DDAF', 'iHS', 'FST']].notna().all(axis=1)
    if missing_nsl.any():
        X_missing = dl_imputed_data.loc[missing_nsl, ['DDAF', 'iHS', 'FST']]
        dl_imputed_data.loc[missing_nsl, 'nSL'] = models['nSL'].predict(X_missing).flatten()

    # Predict iHS
    missing_ihs = dl_imputed_data['iHS'].isna() & dl_imputed_data[['DDAF', 'nSL', 'FST']].notna().all(axis=1)
    if missing_ihs.any():
        X_missing = dl_imputed_data.loc[missing_ihs, ['DDAF', 'nSL', 'FST']]
        dl_imputed_data.loc[missing_ihs, 'iHS'] = models['iHS'].predict(X_missing).flatten()

    # Predict both nSL and iHS
    missing_both = dl_imputed_data['nSL'].isna() & dl_imputed_data['iHS'].isna() & dl_imputed_data[['DDAF', 'FST']].notna().all(axis=1)
    if missing_both.any():
        X_missing = dl_imputed_data.loc[missing_both, ['DDAF', 'FST']]
        predictions = models['nSL_iHS'].predict(X_missing)
        dl_imputed_data.loc[missing_both, ['nSL', 'iHS']] = predictions

    return dl_imputed_data


# Load the actual dataset
data = pd.read_csv('allscenarios_training_data_cleaned_subsetted', sep='\s+', header=0, 
                   names=["SNP_name", "Physical_Distance", "Map_Distance", 
                          "DDAF", "nSL", "iHS", "FST", "label"])

# Preprocess the data
processed_data = preprocess_data(data)

# Remove rows where DDAF or FST are missing
filtered_data = processed_data.dropna(subset=['DDAF', 'FST']).reset_index(drop=True)

# Train models
print("\nTraining models...")
models = train_models(filtered_data)

# Impute missing values
print("\nImputing missing values using deep learning...")
dl_imputed_data = deep_learning_imputation(filtered_data, models)

# Save the new dataset
dl_imputed_data.to_csv('deep_learning_new_imputed_dataset.csv', index=False)
print("\nDeep learning imputed dataset saved as 'deep_learning_new_imputed_dataset.csv'")
