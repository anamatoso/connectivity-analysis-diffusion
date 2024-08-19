
import os
import csv

def csv_to_txt_folder(csv_folder, txt_folder):
    # Check if the input folder exists
    if not os.path.exists(csv_folder):
        return

    # Check if the output folder exists, if not, create it
    if not os.path.exists(txt_folder):
        os.makedirs(txt_folder)

    # Iterate through each file in the csv_folder
    for filename in os.listdir(csv_folder):
        if filename.endswith('.csv'):
            # Define the full path for the CSV file
            csv_file_path = os.path.join(csv_folder, filename)
            
            # Create a corresponding TXT file name
            txt_filename = filename.replace('.csv', '.txt')
            txt_file_path = os.path.join(txt_folder, txt_filename)
            
            # Read the CSV file and write its contents to a TXT file
            with open(csv_file_path, mode='r') as csv_file:
                csv_reader = csv.reader(csv_file)
                
                with open(txt_file_path, mode='w') as txt_file:
                    for row in csv_reader:
                        txt_file.write(' '.join(row) + '\n')

    print(f"Converted CSV files in '{csv_folder}' to TXT files in '{txt_folder}'.")


csv_to_txt_folder('matrix_data/AAL116', 'matrix_data_txt/AAL116')
csv_to_txt_folder('matrix_data/schaefer100cersubcort', 'matrix_data_txt/schaefer100cersubcort')
