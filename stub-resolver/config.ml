(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let resolver =
  let doc = Key.Arg.info ~doc:"Recursive resolver to query" ["resolver"] in
  Key.(create "resolver" Arg.(opt ipv4_address (Ipaddr.V4.of_string_exn "141.1.1.1") doc))

let dns_handler =
  let packages =
    let pin = "git+https://github.com/roburio/udns.git" in
    [
      package "logs" ;
      package ~pin:"git+https://github.com/hannesm/mirage-tcpip.git#lru.0.3.0" "tcpip"; package ~pin "udns";
      package ~pin "udns-mirage";
      package ~pin "udns-resolver";
      package ~pin "udns-server";
      package ~pin "udns-mirage-resolver";
      package ~pin "udns-tsig";
      package "randomconv" ;
      package "lru" ;
      package "rresult" ;
      package "duration" ;
    ]
  in
  foreign
    ~deps:[abstract nocrypto]
    ~keys:[Key.abstract resolver]
    ~packages
    "Unikernel.Main" (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "stub-resolver" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ generic_stackv4 default_network ]
