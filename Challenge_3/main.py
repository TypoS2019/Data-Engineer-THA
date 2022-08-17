from google.cloud import bigquery

project = 'data-engineer-tha'

if __name__ == '__main__':
    client = bigquery.Client()
    data_sizes = {}
    for dataset_item in client.list_datasets(project=project):
        size = 0
        for table_item in client.list_tables(dataset_item.dataset_id):
            table_ref = client.get_table(table_item)
            size += table_ref.num_bytes
        data_sizes[dataset_item.dataset_id] = size
    sorted_by_size = dict(sorted(data_sizes.items(), key=lambda item: item[1], reverse=True))
    for dataset_size in sorted_by_size:
        print(dataset_size + ' = ' + str(sorted_by_size[dataset_size]) + ' bytes')
