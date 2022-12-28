{ system }:

# The latest wpa_supplicant seems to be problematic on the laptop, so
# we temporaryly use a older version.
let nixpkgs =import
  (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4599f2bb9a5a6b1482e72521ead95cb24e0aa819.tar.gz";
    sha256 = "04xr4xzcj64d5mf4jxzn5fsbz74rmf90qddp3jcdwj4skyik946d";
  })
  { inherit system; };
in
nixpkgs.wpa_supplicant
