import csv

cleaned_keyword = 'cleaned_'


def remove_headers(cvs_file_name):
    with open(cvs_file_name, newline='') as csv_file:
        with open(cleaned_keyword + cvs_file_name, mode='w', newline='') as cleaned_csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            csv_writer = csv.writer(cleaned_csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for idx, row in enumerate(csv_reader):
                if idx == 0:
                    csv_writer.writerow(row)
                elif not check_header(row):
                    csv_writer.writerow(row)
                    break
            csv_writer.writerows(csv_reader)


def check_header(row):
    if row[0] == '' or row[1] == '':
        return False
    count = 0
    for cell in row:
        count += 1
        if count > 2 and cell != '':
            return False
    return True


if __name__ == '__main__':
    remove_headers('sample_data_1_header_row.csv')
    remove_headers('sample_data_3_header_rows.csv')
