with Ada.Containers.Vectors;
with Ada.Text_IO;

with AWS.Net.WebSocket.Registry.Control;
with AWS.Status;

package body Squawkbox_Chat is
   use type AWS.Net.WebSocket.UID;

   type Chat_Socket is new AWS.Net.WebSocket.Object with null record;

   overriding procedure On_Open
     (Socket : in out Chat_Socket; Message : String);

   overriding procedure On_Message
     (Socket : in out Chat_Socket; Message : String);

   overriding procedure On_Close
     (Socket : in out Chat_Socket; Message : String);

   overriding procedure On_Error
     (Socket : in out Chat_Socket; Message : String);

   package Socket_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Chat_Socket);

   protected Client_List is
      procedure Add (Socket : Chat_Socket);
      procedure Remove (Socket : Chat_Socket);
      function Snapshot return Socket_Vectors.Vector;
   private
      Clients : Socket_Vectors.Vector;
   end Client_List;

   function Create
     (Socket  : AWS.Net.Socket_Access;
      Request : AWS.Status.Data) return AWS.Net.WebSocket.Object'Class;

   protected body Client_List is
      procedure Add (Socket : Chat_Socket) is
      begin
         Clients.Append (Socket);
      end Add;

      procedure Remove (Socket : Chat_Socket) is
         Remaining : Socket_Vectors.Vector;
      begin
         for Client of Clients loop
            if Client.Get_UID /= Socket.Get_UID then
               Remaining.Append (Client);
            end if;
         end loop;

         Clients := Remaining;
      end Remove;

      function Snapshot return Socket_Vectors.Vector is
      begin
         return Clients;
      end Snapshot;
   end Client_List;

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

   overriding procedure On_Close
     (Socket : in out Chat_Socket; Message : String)
   is
      pragma Unreferenced (Message);
   begin
      Client_List.Remove (Socket);
   end On_Close;

   overriding procedure On_Error
     (Socket : in out Chat_Socket; Message : String)
   is
      pragma Unreferenced (Message);
   begin
      Client_List.Remove (Socket);
   end On_Error;

   overriding procedure On_Message
     (Socket : in out Chat_Socket; Message : String)
   is
      Clients   : constant Socket_Vectors.Vector := Client_List.Snapshot;
      Sender_Id : constant AWS.Net.WebSocket.UID := Socket.Get_UID;
   begin
      Ada.Text_IO.Put_Line ("CHAT RECEIVED: " & Message);
      Socket.Send (Message);

      for Stored_Client of Clients loop
         if Stored_Client.Get_UID /= Sender_Id then
            declare
               Client : Chat_Socket := Stored_Client;
            begin
               AWS.Net.WebSocket.Registry.Send
                 (Socket  => Client,
                  Message => Message,
                  Timeout => 2.0);
            end;
         end if;
      end loop;
   end On_Message;

   overriding procedure On_Open
     (Socket : in out Chat_Socket; Message : String)
   is
      pragma Unreferenced (Message);
   begin
      Client_List.Add (Socket);
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
