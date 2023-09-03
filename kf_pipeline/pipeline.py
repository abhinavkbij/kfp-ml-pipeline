import os
import kfp
from dotmap import DotMap
import kfp.dsl as dsl
from kfp.v2.dsl import component, Dataset, Model, Artifact, Input, Output
from kfp import compiler

from components import (
    data_ingestion,
    preprocessing
)
from utils.utils import read_config

config = read_config(file_path="./config/pipeline_conf.json")

config = DotMap(config)

# create dirs if not exist
os.makedirs(config.pipeline.pipeline_root_local, exist_ok=True)
os.makedirs(config.pipeline.package_path_local, exist_ok=True)

@dsl.pipeline(
    name="demo-kfp-pipeline",
    pipeline_root=config.pipeline.pipeline_root_local
)
def kfp_pipeline(
    project_id: str
):
    ingestion_task = data_ingestion.fetch_dataset(
        bq_path=config.components.data_ingestion.bq_path
    )
    
    preprocess_task = preprocessing.preprocess_data(
        input_df=ingestion_task.outputs['output_dataset']
    )

compiler.Compiler().compile(
    pipeline_func=kfp_pipeline,
    package_path=config.pipeline.package_path_local+"pipeline.yml"
)