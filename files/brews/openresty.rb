require 'formula'

class Openresty < Formula
  homepage 'http://openresty.org/'
  url 'http://openresty.org/download/ngx_openresty-1.4.2.1.tar.gz'
  sha1 'd5e794eacbd26fa05cb5bcdf748a2e87a80cb12b'
  version '1.4.2.1-boxen'

  depends_on 'pcre'

  skip_clean 'logs'

  def options
    [
      ['--with-passenger',   "Compile with support for Phusion Passenger module"],
      ['--with-webdav',      "Compile with support for WebDAV module"],
      ['--with-gzip-static', "Compile with support for Gzip Static module"]
    ]
  end

  def passenger_config_args
      passenger_root = `passenger-config --root`.chomp

      if File.directory?(passenger_root)
        return "--add-module=#{passenger_root}/ext/nginx"
      end

      puts "Unable to install nginx with passenger support. The passenger"
      puts "gem must be installed and passenger-config must be in your path"
      puts "in order to continue."
      exit
  end

  def install
    args = ["--prefix=#{prefix}",
            "--with-luajit",
            "--with-http_ssl_module",
            "--with-pcre",
            "--with-ipv6",
            "--with-cc-opt='-I#{HOMEBREW_PREFIX}/include'",
            "--with-ld-opt='-L#{HOMEBREW_PREFIX}/lib'",
            "--error-log-path=/opt/boxen/log/nginx/error.log",
            "--http-log-path=/opt/boxen/log/nginx/access.log",
            "--conf-path=/opt/boxen/config/nginx/nginx.conf",
            "--pid-path=/opt/boxen/data/nginx/nginx.pid",
            "--lock-path=/opt/boxen/data/nginx/nginx.lock"]

    args << passenger_config_args if ARGV.include? '--with-passenger'
    args << "--with-http_dav_module" if ARGV.include? '--with-webdav'
    args << "--with-http_gzip_static_module" if ARGV.include? '--with-gzip-static'

    system "./configure", *args
    system "make"
    system "make install"

    system "mv #{prefix}/nginx/sbin #{prefix}"

    # remove unnecessary config files
    system "rm -rf #{etc}/nginx"
  end
end
