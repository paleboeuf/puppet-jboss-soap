node 'template-jboss' {

  notice("Setting host $fqdn using Puppet ($puppetversion).")
  
  $profile_name='ifce'
  $product_home='/usr/share/jboss-soap/jboss-as/'
  $profile='production'

#  FIXME: to finish
#  httpd::mod_cluster_client { 'mod_cluster_libs':
#    deploy_folder => "$product_home/server/$profile/deploy",
#    require => Jboss-As::Os_Tuning['soap-tuning'],
#  }
  jboss-as::os_tuning { 'soap-tuning': } 
  
  httpd::mod_cluster { 'conf_mod_cluster_jboss':
    jboss_server_xml => "$product_home/server/$profile/deploy/jbossweb.sar/server.xml", 
    notify => Service['jboss-soap']
  }
}

node template-frontlb { }

node /vm-jboss*/ inherits template-jboss {

  $app_java_opts='-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -Dsun.lang.ClassLoader.allowArraySyntax=true -XX:+UseLargePages -XX:LargePageSizeInBytes=4m'
  jboss-as::base { 'jboss-soap': 
    jvm_memory => '2048',
    proxy_list => "vm-frontlb.ifce.lan:6666",
  } 
}

node /vm-frontlb*/ inherits template-frontlb {
   
  httpd::base { 'httpd-setup': } 
  httpd::mod_cluster_conf { 'mod-cluster-conf': } 
}

node vm-puppet inherits template-jboss {
 
  # vm-frontlb conf
  httpd::base { 'httpd-setup': } 
  httpd::mod_cluster_conf { 'mod-cluster-conf': } 

  # vm-jboss conf
  $app_java_opts='-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -Dsun.lang.ClassLoader.allowArraySyntax=true -XX:+UseLargePages -XX:LargePageSizeInBytes=4m'
  jboss-as::base { 'jboss-soap': 
    jvm_memory => '1024',
  }
}
