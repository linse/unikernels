(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let net = generic_stackv4 default_network

let logger = syslog_udp ~config:(syslog_config "sn.nqsb.io") net

let keys =
  let doc = Key.Arg.info ~doc:"nsupdate keys (name:type:value,...)" ["keys"] in
  Key.(create "keys" Arg.(opt (list string) [] doc))

let dns_handler =
  let packages =
    let pin = "git+https://github.com/roburio/udns.git" in
    [
      package "logs" ;
      package ~pin "udns";
      package ~pin "udns-mirage";
      package ~pin "udns-server";
      package ~pin "udns-mirage-server";
      package ~pin "udns-tsig";
      package "nocrypto";
    ]
  and keys = Key.([ abstract keys ])
  in
  foreign
    ~deps:[abstract nocrypto ; abstract logger ; abstract app_info]
    ~keys
    ~packages
    "Unikernel.Main" (random @-> pclock @-> mclock @-> time @-> stackv4 @-> job)

let () =
  register "snnqsb" [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $ default_time $ generic_stackv4 default_network ]
