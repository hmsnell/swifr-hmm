import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from keras.models import Sequential
from keras.layers import SimpleRNN, Dense, LSTM, GRU, Flatten
from sklearn.metrics import precision_score, recall_score, f1_score, confusion_matrix, classification_report

# Load the dataset
file_path1 = 'deep_learning_new_imputed_dataset.csv'
columns1 = ["SNP_name", "Physical_Distance", "Map_Distance", "DDAF", "nSL", "iHS", "FST", "label"]

file_path2 = 'threeclass_sweeptraining_dhruv'
columns2 = ["SNP_name", "Physical_Distance", "Map_Distance", "DDAF", "nSL", "iHS", "FST", "label"]

# Load data with specified columns, while concatenating the two datasets
data1 = pd.read_csv(file_path1, sep=",", header=0, names=columns1)
# print the head
print(data1.head())
data2 = pd.read_csv(file_path2, sep="\s+", header=0, names=columns2)

# Concatenate the two datasets
data = pd.concat([data1, data2], ignore_index=True)

# Handle missing data
data.replace(-998, pd.NA, inplace=True)
data.dropna(inplace=True)

# Add random noise to "Physical_Distance" for "sweep" labels
def add_noise_to_sweep(data, noise_level=0.01):
    sweep_data = data[data['label'] == 'sweep']
    noise = np.random.normal(0, noise_level, sweep_data.shape[0])
    data.loc[data['label'] == 'sweep', 'Physical_Distance'] += noise
    return data

# Apply noise function
data = add_noise_to_sweep(data)

## Below code is for balancing the dataset

# Separate neutral and sweep data
neutral_data = data[data["label"] == "neutral"]
sweep_data = data[data["label"] == "sweep"]
linked_data = data[data["label"] == "linked"]

# Sample 8000 data points from neutral and linked to balance dataset
neutral_data_sample = neutral_data.sample(n=8000, random_state=1)
linked_data_sample = linked_data.sample(n=8000, random_state=1)

# Concatenate the sampled neutral and linked data with the sweep data
data = pd.concat([neutral_data_sample, sweep_data, linked_data_sample], ignore_index=True)

# Select the relevant columns for features
features = data[["Physical_Distance", "DDAF", "nSL", "iHS", "FST"]]
labels = data["label"]

# encode labels
label_encoder = LabelEncoder()
labels_encoded = label_encoder.fit_transform(labels)

# Normalize the features
scaler = StandardScaler()
features_normalized = scaler.fit_transform(features)

# Perform train-validation-test split (70%-15%-15%)
X_train, X_temp, y_train, y_temp = train_test_split(features_normalized, labels_encoded, test_size=0.3, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)

# Reshape the input to be 3-dimensional
X_train = X_train.reshape((X_train.shape[0], 1, X_train.shape[1]))
X_val = X_val.reshape((X_val.shape[0], 1, X_val.shape[1]))
X_test = X_test.reshape((X_test.shape[0], 1, X_test.shape[1]))

# Define the model
model = Sequential([
    # Dense(1024, activation='relu', input_dim=X_train.shape[1]),
    LSTM(64, activation='relu', input_shape=(1, X_train.shape[2])),
    Dense(256, activation='relu'),
    Dense(64, activation='relu'),
    Dense(3, activation='softmax')
])

# Compile the model
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Train the model
history = model.fit(X_train, y_train, validation_data=(X_val, y_val), epochs=10, batch_size=32)

# Evaluate the model on the test set
test_loss, test_accuracy = model.evaluate(X_test, y_test)
print(f'Test Accuracy: {test_accuracy:.4f}')

# Evaluate the model on the test set
y_pred = model.predict(X_test)
y_pred_classes = y_pred.argmax(axis=-1)

# Calculate precision, recall, and confusion matrix for the multi-class classification
precision = precision_score(y_test, y_pred_classes, average='weighted')
recall = recall_score(y_test, y_pred_classes, average='weighted')
f1 = f1_score(y_test, y_pred_classes, average='weighted')
cm = confusion_matrix(y_test, y_pred_classes)

print(f'Precision: {precision:.4f}')
print(f'Recall: {recall:.4f}')
print(f'F1-Score: {f1:.4f}')
print(f'Confusion Matrix:\n{cm}')
