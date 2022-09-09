let
  escape' = chars: builtins.replaceStrings chars (builtins.map (c: "\\${c}") chars);
  escape = escape' ["\\" "^" "$" "." "+" "*" "?" "|" "(" ")" "[" "{" "}"];
  capture = re: "(${re})";
  allMatches = regex: str:
    builtins.concatMap (g: if builtins.isList g then [(builtins.head g)] else []) (builtins.split (capture regex) str);
  match = builtins.match;
in rec{

  meta = string: let
   pre = "^.*";
   startMeta = let
     std = escape "(std)";
   in "# ${std} -+\n";
   r = ".*";
   endMeta = let
     dts = escape "(dts)";
   in "# ${dts} -+\n";
   post = ".*";

   m = match (pre + startMeta + (capture r) + endMeta + post) string;
  in if m != null then builtins.head m else m;

  args = meta: let
    r = "# args: [^\n]+";
    m = allMatches r meta;
  in m;

  flags = meta: let
    r = "# flags: [^\n]+";
    m = allMatches r meta;
  in m;

  header = meta: let
    these = map (s: s + "\n") ((args meta) ++ (flags meta));
    those = builtins.genList (_: "") (builtins.length these);
  in builtins.replaceStrings these those meta;

  description = header: let
    r = "# [^[:space:]][^\n]+";
    m = allMatches r header;
  in map (s: builtins.substring 2 (-1) s) m;

  shorthelp = header: let
    r = "#   +[^[:space:]][^\n]+";
    m = allMatches r header;
  in map (s: builtins.substring 4 (-1) s) m;

  s = ''
    # (std) -----------------------------
    #
    # I'm a description of a task
    # spanning over two lines
    #
    #   Use me to run something
    #     in a special way
    #
    # args:  foo|str       Some foo
    # args:  bar|str       Some bar
    # args:  baz|str       Some baz
    # flags: f/flag|str    Some flag
    # flags: v/version|str Some version
    #
    # (dts) -----------------------------
  '';
}
