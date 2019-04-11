(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let dns_handler =
  let packages =
    let pin = "git+https://github.com/roburio/udns.git" in
    [
      package "logs" ;
      package ~pin:"git+https://github.com/hannesm/mirage-tcpip.git#lru.0.3.0" "tcpip"; package ~pin "udns";
      package ~pin "udns-server";
      package ~pin "udns-mirage";
      package ~pin "udns-mirage-server";
      package ~pin "udns-tsig";
      package "nocrypto"
    ]
  in
  foreign
    ~deps:[abstract nocrypto]
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "primary" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ generic_stackv4 default_network ]
