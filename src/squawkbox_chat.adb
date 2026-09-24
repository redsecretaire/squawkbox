with Ada.Text_IO;

with AWS.Net.WebSocket.Registry.Control;
with AWS.Status;

package body Squawkbox_Chat is
   type Chat_Socket is new AWS.Net.WebSocket.Object with null record;

   overriding procedure On_Open
     (Socket : in out Chat_Socket; Message : String);

   overriding procedure On_Message
     (Socket : in out Chat_Socket; Message : String);

   function Create
     (Socket  : AWS.Net.Socket_Access;
      Request : AWS.Status.Data) return AWS.Net.WebSocket.Object'Class;

   function Create
     (Socket  : AWS.Net.Socket_Access;
      Request : AWS.Status.Data) return AWS.Net.WebSocket.Object'Class
   is
   begin
      return Chat_Socket'
        (AWS.Net.WebSocket.Object
           (AWS.Net.WebSocket.Create (Socket, Request))
         with null record);
   end Create;

   overriding procedure On_Message
     (Socket : in out Chat_Socket; Message : String)
   is
   begin
      Ada.Text_IO.Put_Line ("CHAT RECEIVED: " & Message);
      Socket.Send (Message);
   end On_Message;

   overriding procedure On_Open
     (Socket : in out Chat_Socket; Message : String)
   is
      pragma Unreferenced (Message);
   begin
      Ada.Text_IO.Put_Line ("CHAT: CLIENT CONNECTED");
      Socket.Send ("SQUAWKBOX LINK ESTABLISHED");
   end On_Open;

   procedure Start is
   begin
      AWS.Net.WebSocket.Registry.Control.Start;
      AWS.Net.WebSocket.Registry.Register
        (URI     => "/chat",
         Factory => Create'Access);
   end Start;

   procedure Stop is
   begin
      AWS.Net.WebSocket.Registry.Control.Shutdown;
   end Stop;
end Squawkbox_Chat;
