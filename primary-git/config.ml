(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Mirage

let net = generic_stackv4 default_network

let logger = syslog_udp ~config:(syslog_config "ns.nqsb.io") net

let keys =
  let doc = Key.Arg.info ~doc:"nsupdate keys (name:type:value,...)" ["keys"] in
  Key.(create "keys" Arg.(opt (list string) [] doc))

let remote_k =
  let doc = Key.Arg.info ~doc:"Remote git repository." ["r"; "remote"] in
  Key.(create "remote" Arg.(opt string "https://github.com/roburio/udns.git" doc))

let dns_handler =
  let udns_pin = "git+https://github.com/roburio/udns.git#nsnqsb" in
  let irmin_pin = "git+https://github.com/hannesm/irmin.git#nsnqsb" in
  let git_pin = "git+https://github.com/hannesm/ocaml-git.git#nsnqsb" in
  let packages = [
    package "logs" ;
    package ~pin:udns_pin "udns";
    package ~pin:udns_pin "udns-client";
    package ~pin:udns_pin "udns-mirage-client";
    package ~pin:udns_pin "udns-mirage";
    package ~pin:udns_pin "udns-server";
    package ~pin:udns_pin "udns-zone";
    package ~pin:udns_pin "udns-mirage-server";
    package ~pin:udns_pin "udns-tsig";
    package "nocrypto" ;
    package ~pin:irmin_pin "irmin";
    package ~pin:irmin_pin "irmin-git";
    package ~pin:irmin_pin "irmin-mem";
    package ~pin:irmin_pin "irmin-mirage";
    package ~pin:"git+https://github.com/hannesm/encore.git#nsnqsb" "encore";
    package ~pin:git_pin "git";
    package ~pin:git_pin "git-http";
    package ~pin:git_pin "git-mirage";
    package ~pin:"git+https://github.com/hannesm/ocaml-conduit.git#nsnqsb" "mirage-conduit";
    package ~pin:"git+https://github.com/hannesm/ke.git#nsnqsb" "ke"
  ] in
  foreign
    ~deps:[abstract nocrypto; abstract logger ; abstract app_info]
    ~keys:[Key.abstract remote_k ; Key.abstract keys]
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4 @-> resolver @-> conduit @-> job)

let () =
  register "nsnqsb"
    [dns_handler $ default_random $ default_posix_clock $ default_monotonic_clock $
     default_time $ net $ resolver_dns net $ conduit_direct ~tls:true net]
