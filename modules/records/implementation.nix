# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ lib, config, pkgs, ... }: let

  nt = lib.types;

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/records/implementation.nix";

# ---------------------------------------------------------------------------- #

  config.records = {
    _module.args.fetchers = lib.mkDefault config.fetchers;
    _module.args.pkgs     = lib.mkDefault pkgs;
  };  # End `config.records'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
