class openresty::package {
  include openresty::params

  ensure_packages(['wget', 'gcc', 'gcc-c++'])
  exec { 'openresty::package::download_openresty':
    cwd     => '/tmp/resty',
    command => "wget ${openresty::params::openresty_url} -O openresty.tar.gz",
    creates => '/tmp/resty/openresty.tar.gz',
  }

  exec { 'openresty::package::download_pcre':
    cwd     => '/tmp/resty',
    command => "wget ${openresty::params::pcre_url} -O pcre.tar.gz ; tar zxf pcre.tar.gz",
  }


  exec { 'openresty::package::download_luajit':
    cwd     => '/tmp/resty',
    command => "wget ${openresty::params::luajit_url} -O luajit.tar.gz",
  }

  exec { 'openresty::package::install_luajit':
    cwd     => '/tmp/resty',
    command => "tar zxf luajit.tar.gz ; cd LuaJIT* ; ./configure ; make -j2 install",
    require  => [
      Exec['openresty::package::download_luajit'],
    ],
  }

  exec { 'openresty::package::install_openresty':
    cwd     => '/tmp/resty',
    command => "tar zxf openresty.tar.gz ; cd openresty* ; ./configure --with-pcre=/tmp/resty/pcre-8.40  --with-pcre-jit --with-luajit --with-http_ssl_module --without-http_coolkit_module --without-http_set_misc_module --without-http_encrypted_session_module --without-http_form_input_module --without-http_srcache_module --without-http_lua_module --without-http_headers_more_module --without-http_array_var_module --without-http_redis2_module --without-http_memc_module --without-http_redis_module --without-http_rds_json_module --without-http_rds_csv_module --without-http_lua_upstream_module --without-ngx_devel_kit_module --without-http_echo_module --without-http_xss_module ; make -j2 install",
    require  => [
      Exec['openresty::package::download_openresty'],
      Exec['openresty::package::install_luajit'],
      Exec['openresty::package::download_pcre'],
      Package['gcc', 'gcc-c++', 'wget'],
    ],
  }
  file { 'openresty init script':
    ensure  => file,
    path    => '/etc/init.d/nginx',
    content => template("/etc/puppet/template/openresty.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  service { 'nginx':
    ensure     => 'running',
    name       => 'nginx',
    enable     => 'true',
    hasstatus  => true,
    hasrestart => false,
    restart    => '/etc/init.d/nginx reload',
    require    => [Exec['openresty::package::install_openresty'], File['openresty init script']],
  }


}
