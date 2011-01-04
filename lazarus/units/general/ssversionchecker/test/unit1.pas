unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, VersionChecker;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpdateAvailable(sender : TObject);
    procedure NoUpdate(sender : TObject);
  private
    { private declarations }
  public
    vChecker : TVersionChecker;
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  vChecker := TVersionChecker.Create(self);
  vChecker.ServerLocation := 'http://glh33.free.fr/?dl_name=clinique.xml';
  vChecker.CurrentVersion := '1.2';
  vChecker.VersionNode := '/xpl-plugin[@vendor="clinique"]/device[@id="clinique-logger"]/attribute::version';
  vChecker.DownloadNode := '/xpl-plugin[@vendor="clinique"]/device[@id="clinique-logger"]/attribute::download_url';
  vChecker.OnUpdateFound := @UpdateAvailable;
  vChecker.OnNoUpdateFound:= @NoUpdate;
  vChecker.CheckVersion;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  vChecker.Destroy;
end;

procedure TForm1.UpdateAvailable(sender: TObject);
begin
   label1.Caption:='update available : ' + vChecker.ServerVersion + ' at ' + vChecker.DownloadURL;
end;

procedure TForm1.NoUpdate(sender: TObject);
begin
   label1.Caption:='nothing changed';
end;

initialization
  {$I unit1.lrs}

end.

