with AWS.Response;
with AWS.Status;

package Squawkbox_HTTP is
   --  Called once for each HTTP request received by the server.
   function Handle_Request
     (Request : AWS.Status.Data) return AWS.Response.Data;
end Squawkbox_HTTP;
