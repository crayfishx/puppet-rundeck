# == Define rundeck::config::project
#
# This definition is used to configure rundeck projects
#
# === Parameters
#
# [*file_copier_provider*]
#  The type of proivder that will be used for copying files to each of the nodes
#
# [*node_executor_provider*]
#  The type of provider that will be used to gather node resources
#
# [*resource_sources*]
#  A hash of rundeck::config::resource_source that will be used to specifiy the node
#  resources for this project
#
# [*ssh_keypath*]
#   The path the the ssh key that will be used by the ssh/scp providers
#
# [*projects_dir*]
#   The directory where rundeck is configured to store project information
#
# [*user*]
#   The user that rundeck is installed as.
#
# [*group*]
#   The group permission that rundeck is installed as.
#
# === Examples
#
# Create and manage a rundeck project:
#
# rundeck::config::project { 'test project':
#  ssh_keypath            => '/var/lib/rundeck/.ssh/id_rsa',
#  file_copier_provider   => 'jsch-scp',
#  node_executor_provider => 'jsch-ssh',
#  resource_sources       => $resource_hash
# }
#
define rundeck::config::project(
  $file_copier_provider   = $::rundeck::file_copier_provider,
  $node_executor_provider = $::rundeck::node_executor_provider,
  $resource_sources       = $::rundeck::resource_sources,
  $ssh_keypath            = $::rundeck::ssh_keypath,
  $projects_dir           = $::rundeck::projects_dir,
  $user                   = $::rundeck::user,
  $group                  = $::rundeck::group
) {



  validate_absolute_path($ssh_keypath)
  validate_re($file_copier_provider, ['jsch-scp','script-copy','stub'])
  validate_re($node_executor_provider, ['jsch-ssh', 'script-exec', 'stub'])
  validate_hash($resource_sources)
  validate_absolute_path($projects_dir)
  validate_re($user, '[a-zA-Z0-9]{3,}')
  validate_re($group, '[a-zA-Z0-9]{3,}')

  $project_dir = "${projects_dir}/${name}"
  $properties_file = "${project_dir}/etc/project.properties"
 

  File {
    owner => $user,
    group => $group,
  }

  file { $properties_file:
    ensure  => file,
  }

  file { [ $project_dir, "${project_dir}/var", "${project_dir}/etc" ]:
    ensure  => directory,
  }


  Ini_setting {
    ensure  => present,
    path    => $properties_file,
    section => '',
    require => File[$properties_file],
  }

  ini_setting {
      'project.name':
        setting => 'project.name',
        value   => $name;
    
      'project.ssh-authentication':
        setting => 'project.ssh-authentication',
        value   => 'privateKey';
    
      'project.ssh-keypath':
        setting => 'project.ssh-keypath',
        value   => $ssh_keypath;
    
      'service.FileCopier.default.provider':
        setting => 'service.FileCopier.default.provider',
        value   => $file_copier_provider;
    
      'service.NodeExecutor.default.provider':
        setting => 'service.NodeExecutor.default.provider',
        value   => $node_executor_provider;
      }
}
