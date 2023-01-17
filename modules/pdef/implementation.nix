# ============================================================================ #
#
# A `options.floco.packages' submodule representing the definition of
# a single Node.js pacakage.
#
# ---------------------------------------------------------------------------- #

{ lib, options, config, fetchers, fetcher, basedir, ... }: let

# ---------------------------------------------------------------------------- #

  nt = lib.types;

# ---------------------------------------------------------------------------- #

in {

# ---------------------------------------------------------------------------- #

  _file = "<floco>/pdef/implementation.nix";

  imports = [
    ./binInfo/implementation.nix
    ./depInfo/implementation.nix
    ./treeInfo/implementation.nix
    ./peerInfo/implementation.nix
    ./sysInfo/implementation.nix
    ./fsInfo/implementation.nix
    ./lifecycle/implementation.nix
  ];

  options.fetchInfo = lib.mkOption {
    type = let
      coerce = fetcher.deserializeFetchInfo basedir;
    in nt.coercedTo lib.types.str coerce fetcher.fetchInfo;
  };


# ---------------------------------------------------------------------------- #

  config = {

# ---------------------------------------------------------------------------- #

    ident = lib.mkDefault (
      config.metaFiles.metaRaw.ident or config.metaFiles.pjs.name or
      ( dirOf config.key )
    );

    version = lib.mkDefault (
      config.metaFiles.metaRaw.version or config.metaFiles.pjs.version or
      ( baseNameOf config.key )
    );

    key = lib.mkDefault (
      config.metaFiles.metaRaw.key or ( config.ident + "/" + config.version )
    );


# ---------------------------------------------------------------------------- #

    # These are the oddballs.
    # `fetchInfo` is polymorphic - it is conventionally declared using
    # `_module.args.fetcher.fetchInfo', and defined by the user, a discoverer,
    # or a translator.
    # This abstraction allows users to add their own fetchers, or customize
    # the behavior of existing fetchers at the expense of making things harder
    # to read and understand.
    #
    # When in doubt or if you get frustrated - remember that you can always set
    # `floco.packages.*.*.source` directly and set any other `pdef' fields that
    # are relevant to the build plan.
    # While these abstractions may be bit of a headache, they're necessary to
    # allow the `floco' framework to be extensible.

    _module.args.fetcher = lib.mkDefault fetchers.fetchTree_tarball;

    _module.args.basedir = let
      isExt = f:
        ( ! ( lib.hasPrefix "<floco>/" f ) ) &&
        ( f != "<unknown-file>" ) &&
        ( f != "lib/modules.nix" );
      dls  = map ( v: v.file ) options.fetchInfo.definitionsWithLocations;
      exts = builtins.filter isExt dls;
      val  = if exts != [] then builtins.head exts else
             config.fetchInfo.path or config.metaFiles.pjsDir;
    in lib.mkDefault val;

    fetchInfo = let
      default = builtins.mapAttrs ( _: lib.mkDefault ) ( {
        type = "tarball";
        url  = let
          bname = baseNameOf config.ident;
          inherit (config) version;
        in "https://registry.npmjs.org/${config.ident}/-/" +
            "${bname}-${version}.tgz";
      } // ( config.metaFiles.metaRaw.fetchInfo or {} ) );
      fetcherAccepts = fetcher.fetchInfo.getSubOptions [];
    in builtins.intersectAttrs fetcherAccepts default;

    sourceInfo = let
      type    = config.fetchInfo.type or "path";
      fetched = fetcher.function config.fetchInfo;
      src     = if type != "file" then fetched else builtins.fetchTarball {
        url = "file:${builtins.unsafeDiscardStringContext fetched}";
      };
    in lib.mkDefault ( if type == "file" then { outPath = src; } else src );


# ---------------------------------------------------------------------------- #

    ltype = lib.mkIf ( config.fetchInfo ? path ) ( lib.mkDefault "dir" );


# ---------------------------------------------------------------------------- #

    metaFiles.pjsDir = let
      dp  =
        if ! ( builtins.elem ( config.fsInfo.dir or "." ) ["." "./." "" null] )
        then "/" + config.fsInfo.dir
        else "";
      projDir = config.fetchInfo.path or config.sourceInfo.outPath;
    in lib.mkDefault ( projDir + dp );

    metaFiles.pjs = lib.mkDefault (
      lib.importJSON ( config.metaFiles.pjsDir + "/package.json" )
    );


# ---------------------------------------------------------------------------- #

  # TODO: in order to handle relative paths in a sane way this routine really
  # needs to be outside of the module fixed point, and needs to accept an
  # argument indicating `basedir' to make paths relative from.
  # This works for now but I really don't like it.
  _export = lib.mkMerge [
    {
      inherit (config) ident version ltype;
      fetchInfo = fetcher.serializeFetchInfo ( basedir + "/<phony>" )
                                             config.fetchInfo;
    }
    ( lib.mkIf ( config.key != "${config.ident}/${config.version}" ) {
      inherit (config) key;
    } )
  ];


# ---------------------------------------------------------------------------- #

  };  # End `config'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
