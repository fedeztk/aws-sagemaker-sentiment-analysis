module "huggingface_sagemaker" {
  source               = "philschmid/sagemaker-huggingface/aws"
  version              = "0.5.0"
  name_prefix          = "nlp"
  pytorch_version      = "1.9.1"
  transformers_version = "4.12.3"
  instance_type        = var.instance_type
  instance_count       = 1
  hf_model_id          = "SamLowe/roberta-base-go_emotions"
  hf_task              = "text-classification"
}