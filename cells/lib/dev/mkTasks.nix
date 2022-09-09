{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;

  l = nixpkgs.lib // builtins;
in {
  mkTask = name: attrOrStr: let
    extractSpec = s: let
      linetail = "([^\n]+)\n";
      std = "\\(std\\)";
      dts = "\\(dts\\)";

      startMeta = "# ${std} -+\n";
      description = "# ${linetail}";
      shorthelp = "#   ${linetail}";
      endMeta = "# ${std} -+\n";
      m = l.match "";
    in {
      interpreter = nixpkgs.bash;
      description = "";
      shorthelp = "";
      args = [];
      flags = {};
    };
    spec =
      if l.isString attrOrStr
      then extractSpec attrOrStr
      else attrOrStr;
  in
    l.derivation {
      inherit (spec) interpreter description shorthelp args flags;
      name = l.toDerivationName name;
      args = [
        (l.toFile "make-task" ''
          source $__envShellCommands
          source $__envShellOptions
          export PATH=$__envSearchPathsBase
          if test -v __envSearchPaths; then
            source $__envSearchPaths/template
          fi
          ${asContent builder}
          if test -v __envAction; then
            copy $__envAction $out/makes-action.sh
          fi
          if test -v __envHelp; then
            copy $__envHelp $out/README.md
          fi
        '')
      ];
      builder = l.getExe nixpkgs.bash;
      outputs = ["out"];
      system = nixpkgs.system;
    };
}
