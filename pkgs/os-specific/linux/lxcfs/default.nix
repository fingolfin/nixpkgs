{ config, stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, help2man, fuse
, enableDebugBuild ? config.lxcfs.enableDebugBuild or false }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "lxcfs-4.0.1";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "lxcfs";
    rev = name;
    sha256 = "09y26ln2wxpi809kd3r352my64aal0yz2a5kin0i25gnvivl32cs";
  };

  nativeBuildInputs = [ pkgconfig help2man autoreconfHook ];
  buildInputs = [ fuse ];

  preConfigure = stdenv.lib.optionalString enableDebugBuild ''
    sed -i 's,#AM_CFLAGS += -DDEBUG,AM_CFLAGS += -DDEBUG,' Makefile.am
  '';

  configureFlags = [
    "--with-init-script=systemd"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  installFlags = [ "SYSTEMD_UNIT_DIR=\${out}/lib/systemd" ];

  postFixup = ''
    # liblxcfs.so is reloaded with dlopen()
    patchelf --set-rpath "$(patchelf --print-rpath "$out/bin/lxcfs"):$out/lib" "$out/bin/lxcfs"
  '';

  meta = {
    homepage = "https://linuxcontainers.org/lxcfs";
    description = "FUSE filesystem for LXC";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mic92 fpletz ];
  };
}
