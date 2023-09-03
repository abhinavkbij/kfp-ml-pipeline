import kfp
import kfp.dsl as dsl
from kfp.v2.dsl import component, Dataset, Model, Artifact, Input, Output


@component(base_image="python:3.9.2", packages_to_install=["numpy", "pandas", "gcsfs", "google-cloud-bigquery", "google-cloud-storage"])
def fetch_dataset(
    bq_path: str,
    output_dataset: Output[Dataset]
):
    from google.cloud import bigquery

    # Construct a BigQuery client object.
    client = bigquery.Client()

    query = """
        SELECT name, SUM(number) as total_people
        FROM `bigquery-public-data.usa_names.usa_1910_2013`
        WHERE state = 'TX'
        GROUP BY name, state
        ORDER BY total_people DESC
        LIMIT 20
    """
    query_job = client.query(query)  # Make an API request.

    print("The query data:")
    df = query_job.to_dataframe()
    print (df.head())
    df.to_csv(output_dataset.path, index=False)