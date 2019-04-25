open Lwt.Infix

module Main (DB : Qubes.S.DB) (Time : Mirage_time_lwt.S) = struct
  let service_name = "yomimono.updateFirewall"
  let target_domain = "0"
  let request_id = "fwbounce"

  let handler ~user cmdline flow =
    Logs.info (fun f -> f "received qrexec message: user %s, message %s" user cmdline);
    (* TODO: output stuff *)
    Lwt.return 0

  let start _db _time =
    Qubes.RExec.connect ~domid:0 () >>= fun qrexec ->
    (* `connect` exchanges HELLOs,
       so we're ready to send our MSG_TRIGGER_SERVICE message *)
    Qubes.RExec.request_service qrexec ~target_domain ~service_name ~request_id handler >|= function
    | Error (`Msg s) -> Logs.err (fun f -> f "unknown error: %s" s)
    | Error `Permission_denied -> Logs.err (fun f -> f "Permission denied for service %s" service_name)
    | Error `Closed -> Logs.err (fun f -> f "tried to write to a closed qrexec channel")
    | Ok () -> Logs.info (fun f -> f "successfully ran qrexec request")
end
