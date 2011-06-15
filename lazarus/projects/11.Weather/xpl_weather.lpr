program xpl_weather;

{$APPTYPE CONSOLE}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
     cthreads,
  {$ENDIF}{$ENDIF}
     u_xpl_console_app, superobject,
     weather_listener;

{$R *.res}

var MyWeatherApp : TxPLConsoleApp;
    Listener : TxPLWeatherListener;

begin
   MyWeatherApp := TxPLConsoleApp.Create(nil);
   Listener := TxPLWeatherListener.Create(MyWeatherApp);

   MyWeatherApp.Title := Listener.AppName;
   Listener.Listen;

   MyWeatherApp.Run;
   MyWeatherApp.Free;
end.

