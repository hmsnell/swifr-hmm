import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from keras.models import Sequential
from keras.layers import SimpleRNN, Dense, LSTM, GRU, Flatten
from sklearn.metrics import precision_score, recall_score, f1_score, confusion_matrix, classification_report

# Load the dataset
file_path1 = 'all_data_testing_classified2'
columns1 = ["SNP_name", "Physical_Distance", "Map_Distance", "DDAF", "nSL", "iHS", "FST",
           "pi_neutral", "pi_sweep", "P(neutral)", "P(sweep)", "SRS_label"]

file_path2 = 'sweep_training_data_for_dhruv'
columns2 = ["SNP_name", "Physical_Distance", "Map_Distance", "DDAF", "nSL", "iHS", "FST", "label"]

# Load data with specified columns, while concatenating the two datasets
data1 = pd.read_csv(file_path1, sep="\s+", header=0, names=columns1)

# remove the 'pi neutral', 'pi sweep', 'P(neutral)', 'P(sweep)' columns in the first dataset
# 'SRS_label' in the first dataset is renamed to 'label' to match the second dataset

data1 = data1.drop(columns=["pi_neutral", "pi_sweep", "P(neutral)", "P(sweep)"])
data1 = data1.rename(columns={"SRS_label": "label"})

data2 = pd.read_csv(file_path2, sep="\s+", header=0, names=columns2)
# if a row contains "SNP_name" as the value in the "SNP_name" column, drop that row
data2 = data2[data2["SNP_name"] != "SNP_name"]
# Now you can concatenate the DataFrames
data = pd.concat([data1, data2], ignore_index=True)


# Handle missing data (-998 values)
data.replace(-998, pd.NA, inplace=True)
data.dropna(inplace=True)

## Below code is for balancing the dataset

# Separate neutral and sweep data
neutral_data = data[data["label"] == "neutral"]
sweep_data = data[data["label"] == "sweep"]

# print size of sweep data
print(sweep_data.shape)
# Sample 8000 neutral data points
neutral_data_sample = neutral_data.sample(n=8000, random_state=1)

# Concatenate the sampled neutral data with the sweep data
data = pd.concat([neutral_data_sample, sweep_data], ignore_index=True)
data = data.sample(frac=1, random_state=1).reset_index(drop=True)


# Select the relevant columns for features
features = data[["DDAF", "nSL", "iHS", "FST"]]
labels = data["label"]

# Encode the labels (sweep -> 1, neutral -> 0)
label_encoder = LabelEncoder()
labels_encoded = label_encoder.fit_transform(labels)

# Normalize the features
scaler = StandardScaler()
features_normalized = scaler.fit_transform(features)

# Reshape the features for RNN input: (samples, timesteps, features)
# features_reshaped = features_normalized.reshape((features_normalized.shape[0], 1, features_normalized.shape[1]))


# Perform train-validation-test split (70%-15%-15%)
X_train, X_temp, y_train, y_temp = train_test_split(features_normalized, labels_encoded, test_size=0.3, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)


# Define the model
model = Sequential([
    # You can choose between SimpleRNN, LSTM, or GRU
    Dense(256, activation='relu', input_dim=X_train.shape[1]),
    Dense(32, activation='relu'),
    Dense(1, activation='sigmoid')
])

# Compile the model
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Train the model
history = model.fit(X_train, y_train, validation_data=(X_val, y_val), epochs=5, batch_size=32)

# Evaluate the model on the test set
test_loss, test_accuracy = model.evaluate(X_test, y_test)
print(f'Test Accuracy: {test_accuracy:.4f}')

## precision, recall, f1-score

# Evaluate the model on the test set
y_pred = (model.predict(X_test) > 0.5).astype("int32")

# Calculate precision, recall, and F1-score
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)

print(f'Precision: {precision:.4f}')
print(f'Recall: {recall:.4f}')
print(f'F1-Score: {f1:.4f}')

# Optional: Confusion matrix and classification report
print(confusion_matrix(y_test, y_pred))
print(classification_report(y_test, y_pred, target_names=['neutral', 'sweep']))