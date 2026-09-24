with Ada.Characters.Latin_1;

with AWS.Messages;

package body Squawkbox_HTTP is
   --  A line-feed character used in plain-text responses.
   Line_Feed : constant Character := Ada.Characters.Latin_1.LF;

   function Handle_Request
     (Request : AWS.Status.Data) return AWS.Response.Data
   is
      --  The address portion following the host and port.
      Request_Path : constant String := AWS.Status.URI (Request);
   begin
      if Request_Path = "/" then
         --  Send the existing HTML file to the browser.
         return AWS.Response.File
           (Content_Type => "text/html; charset=utf-8",
            Filename     => "index.html");

      elsif Request_Path = "/flight-check" then
         --  Keep our small diagnostic route available.
         return AWS.Response.Build
           (Content_Type => "text/plain; charset=utf-8",
            Message_Body =>
              "SQUAWKBOX SERVER" & Line_Feed
              & "STATUS: LISTENING" & Line_Feed
              & "REQUEST: " & Request_Path & Line_Feed);

      else
         --  Return an HTTP 404 response for an unknown route.
         return AWS.Response.Build
           (Content_Type => "text/plain; charset=utf-8",
            Message_Body =>
              "SQUAWKBOX: ROUTE NOT FOUND" & Line_Feed
              & "REQUEST: " & Request_Path & Line_Feed,
            Status_Code  => AWS.Messages.S404);
      end if;
   end Handle_Request;
end Squawkbox_HTTP;
