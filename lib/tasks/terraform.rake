namespace :terraform do
  desc 'Initialize the Terraform configuration'
  task :init do
    sh 'terraform init ./terraform'
  end

  desc 'Apply the Terraform configuration'
  task :apply => 'render:config' do
    sh 'terraform apply -var-file ./terraform/instance.tfvars ./terraform'
  end

  desc 'Destroy the Terraform infrastructure'
  task :destroy do
    sh 'terraform destroy -var-file ./terraform/instance.tfvars ./terraform'
  end
end
