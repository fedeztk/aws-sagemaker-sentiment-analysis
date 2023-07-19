from diagrams import Diagram
from diagrams.aws.compute import Lambda
from diagrams.aws.network import APIGateway
from diagrams.aws.database import DDB
from diagrams.aws.storage import S3
from diagrams.aws.ml import Sagemaker, SagemakerModel

with Diagram(
    "Infrastructure of AWS SageMaker sentiment analysis",
    show=False,
    filename="infrastructure",
    direction="TB",
):
    api_gw = APIGateway("API Key protected Gateway endpoint")

    lambda_fun = Lambda("lambda")
    dynamodb = DDB("dynamodb")
    bucket = S3("s3 bucket")
    sagemaker = Sagemaker("sagemaker")
    sagemaker_model = SagemakerModel("huggingface nlp model")

    api_gw >> lambda_fun
    lambda_fun >> dynamodb
    lambda_fun << bucket
    lambda_fun >> sagemaker
    sagemaker << sagemaker_model