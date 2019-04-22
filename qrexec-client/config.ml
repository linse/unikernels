open Mirage

let main =
  let packages = [
    package "mirage-qubes";
  ] in
  foreign
    ~packages
    "Unikernel.Main" (qubesdb @-> time @-> job)

let () =
  register "ask-update-firewall" ~argv:no_argv [
    main $ default_qubesdb $ default_time
  ]
