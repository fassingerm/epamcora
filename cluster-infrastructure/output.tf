output "filesystem_mount" {
  value = module.cluster-infra.cp_filesystem_mount_point
}

output "filesystem_type" {
  value = module.cluster-infra.deploy_filesystem_type
}

output "cp_pipectl_script" {
  value = module.cluster-infra.cp_deploy_script
}
