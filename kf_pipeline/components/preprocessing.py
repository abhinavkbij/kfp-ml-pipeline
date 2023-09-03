import kfp
import kfp.dsl as dsl
from kfp.v2.dsl import component, Dataset, Model, Artifact, Input, Output


@component(
    base_image="python:3.9.2", packages_to_install=["gcsfs", "pandas", "google-cloud-storage", "numpy"]
)
def preprocess_data(
    input_df: Input[Dataset],
    output_df: Output[Dataset]
):
    pass