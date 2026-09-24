with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Server;

with Squawkbox_Chat;
with Squawkbox_HTTP;

procedure Squawkbox is
   --  Only values in the valid TCP port range are allowed.
   subtype Port_Number is Positive range 1 .. 65_535;

   Server_Name : constant String      := "SQUAWKBOX";
   Listen_Host : constant String      := "127.0.0.1";
   Listen_Port : constant Port_Number := 8_080;

   --  'Image converts the number to text; Trim removes its leading space.
   Port_Text : constant String :=
     Ada.Strings.Fixed.Trim (Listen_Port'Image, Ada.Strings.Both);

   --  The long-lived Ada Web Server object.
   Web_Server : AWS.Server.HTTP;
begin
   Squawkbox_Chat.Start;

   AWS.Server.Start
     (Web_Server     => Web_Server,
      Name           => Server_Name,
      Callback       => Squawkbox_HTTP.Handle_Request'Access,
      Max_Connection => 10,
      Host           => Listen_Host,
      Port           => Listen_Port);

   Ada.Text_IO.Put_Line (Server_Name & " SERVER");
   Ada.Text_IO.Put_Line ("STATUS: LISTENING");
   Ada.Text_IO.Put_Line
     ("OPEN: http://" & Listen_Host & ":" & Port_Text & "/");
   Ada.Text_IO.Put_Line
     ("WEBSOCKET: ws://127.0.0.1:8080/chat");
   Ada.Text_IO.Put_Line ("PRESS Q TO SHUT DOWN");

   --  Keep the process alive until Q is entered.
   AWS.Server.Wait (AWS.Server.Q_Key_Pressed);
   AWS.Server.Shutdown (Web_Server);
   Squawkbox_Chat.Stop;
end Squawkbox;
