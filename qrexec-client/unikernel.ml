open Lwt.Infix

module Main (DB : Qubes.S.DB) (Time : Mirage_time_lwt.S) = struct
  let please_change_fw = Cstruct.of_string "yomimono.updateFirewall"

  let send_trigger_service ~target_domain ~service_name ~ident =
    let tsp = Cstruct.create Qubes.Formats.Qrexec.sizeof_trigger_service_params in
    Cstruct.blit service_name 0 tsp 0 (min (Cstruct.len service_name) 64);
    Cstruct.blit target_domain 0 tsp 64 (min (Cstruct.len target_domain) 32);
    (* TODO: we should make sure ident is unique and track correct
       handlers for specific idents (for the case where multiple
       requests have been made from one user of the library,
       which may have different handlers); for now make the user track it,
       and have them be responsible for demultiplexing via the `handler` API *)
    Cstruct.blit ident 0 tsp 96 (min (Cstruct.len ident) 32);
    tsp

  let handler ~user str _flow =
    Logs.info (fun f -> f "received qrexec message: user %s, message %s" user str);
    Lwt.return 0

  let start _db _time =
    Qubes.RExec.connect ~domid:0 () >>= fun qrexec ->
    let msg = send_trigger_service ~target_domain:(Cstruct.of_string "dom0") ~service_name:please_change_fw ~ident:(Cstruct.of_string "0") in
    Lwt.async (fun () ->
      Qubes.RExec.listen qrexec handler
    );
    Qubes.RExec.send qrexec ~ty:`Trigger_service msg >|= (function
    | `Ok () -> Logs.info (fun f -> f "successfully ran qrexec request");
    | `Eof -> Logs.err (fun f -> f "couldn't run qrexec request: EOF on channel; it's already closed?")) >>= fun () ->
    Time.sleep_ns 10_000_000_000L >>= fun () -> Lwt.return_unit

end
