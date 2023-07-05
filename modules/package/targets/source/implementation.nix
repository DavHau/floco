# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, pdef, pkgs, ... }: {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/package/targets/source/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.source =
    if pdef.fetchInfo ? path
    then pdef.fetchInfo.path
    else if pdef.fetchInfo.type == "tarball"
    then
      pkgs.fetchurl {
        url = pdef.fetchInfo.url;
        hash = pdef.fetchInfo.narHash or (builtins.trace pdef throw "no hash");
      }
    else
      builtins.fetchTree pdef.fetchInfo;


# ---------------------------------------------------------------------------- #


}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
