{ stdenv, fetchurl, bundlerEnv, ruby }:

let
  version = "3.4.8";
  rubyEnv = bundlerEnv {
    name = "redmine-env-${version}";

    inherit ruby;
    gemdir = ./.;
    groups = [ "ldap" "openid" ];
  };
in
  stdenv.mkDerivation rec {
    name = "redmine-${version}";

    src = fetchurl {
      url = "https://www.redmine.org/releases/${name}.tar.gz";
      sha256 = "1d8bj3hx2nlyvsqbx7zbslb4dgwgyxidj4jzh4n2ki0i7vgw0x5m";
    };

    buildInputs = [ rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler ];

    buildPhase = ''
      mv config config.dist
      mv public/themes public/themes.dist
    '';

    installPhase = ''
      mkdir -p $out/share
      cp -r . $out/share/redmine
      for i in config files log plugins public/plugin_assets public/themes tmp; do
        rm -rf $out/share/redmine/$i
        ln -fs /run/redmine/$i $out/share/redmine/$i
      done
    '';

    meta = with stdenv.lib; {
      homepage = http://www.redmine.org/;
      platforms = platforms.linux;
      maintainers = [ maintainers.garbas ];
      license = licenses.gpl2;
    };
  }
