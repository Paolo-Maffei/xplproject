unit u_xpl_gui_resource;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , Controls
     ;

type TxPLGUIResource = class
        private
           fImages     : TImageList;

        public
           constructor Create;
           destructor  Destroy; override;

           property Images    : TImageList         read fImages;
     end;

var xPLGUIResource : TxPLGUIResource;

const K_IMG_RECONNECT  = 'reconnect';
      K_IMG_DISCONNECT = 'disconnect';
      K_IMG_OK         = 'button_ok';
      K_IMG_CANCEL     = 'button_cancel';

var K_IMG_THREAD, K_IMG_pkg_installed, K_IMG_NETWORK, K_IMG_MAIL_FORWARD, K_IMG_MESSAGE,
    K_IMG_STAT, K_IMG_EDIT_FIND, K_IMG_TRIG, K_IMG_CMND : integer;

implementation // =============================================================
uses Forms,
     LResources;

constructor TxPLGUIResource.Create;
begin
   inherited;

   fImages := TImageList.Create(nil);
   fImages.AddLazarusResource('xpl');               // 0
   fImages.AddLazarusResource('menu_exit');         // 1
   fImages.AddLazarusResource('menu_information');  // 2
   fImages.AddLazarusResource('laz_save');          // 3
   fImages.AddLazarusResource('laz_refresh');       // 4
   fImages.AddLazarusResource('ce_procedure');      // 5
   fImages.AddLazarusResource('menu_run');          // 6
   K_IMG_pkg_installed := fImages.AddLazarusResource('pkg_installed');     // 7
   fImages.AddLazarusResource('txt');               // 8
   fImages.AddLazarusResource('2downarrow');        // 9
   fImages.AddLazarusResource('edit_add');          // 10
   fImages.AddLazarusResource('edit_remove');       // 11
   fImages.AddLazarusResource('ledgreen');          // 12
   fImages.AddLazarusResource('ledorange');         // 13
   fImages.AddLazarusResource('ledred');            // 14
   fImages.AddLazarusResource(K_IMG_OK);            // 15
   fImages.AddLazarusResource(K_IMG_CANCEL);        // 16
   fImages.AddLazarusResource('fileopen');          // 17
   fImages.AddLazarusResource('editcopy');          // 18
   fImages.AddLazarusResource('editpaste');         // 19
   K_IMG_MAIL_FORWARD := fImages.AddLazarusResource('mail_forward');      // 20
   fImages.AddLazarusResource('misc');              // 21
   fImages.AddLazarusResource('player_pause');      // 22
   fImages.AddLazarusResource('player_stop');       // 23
   fImages.AddLazarusResource('item_filter');       // 24
   fImages.AddLazarusResource('menu_clean');        // 25
   fImages.AddLazarusResource('up');                // 26
   fImages.AddLazarusResource('down');              // 27
   fImages.AddLazarusResource('clock');             // 28
   fImages.AddLazarusResource('etError');           // 29
   fImages.AddLazarusResource('etInfo');            // 30
   fImages.AddLazarusResource('etWarning');         // 31
   fImages.AddLazarusResource('exit');              // 32
   fImages.AddLazarusResource(K_IMG_DISCONNECT);    // 33
   fImages.AddLazarusResource(K_IMG_RECONNECT);     // 34
   fImages.AddLazarusResource('activity');          // 35
   fImages.AddLazarusResource('trash');             // 36
   fImages.AddLazarusResource('check');             // 37
   fImages.AddLazarusResource('notchecked');        // 38
   fImages.AddLazarusResource('logview');           // 39
   fImages.AddLazarusResource('synchronize');       // 40
   fImages.AddLazarusResource('preferences');       // 41
   fImages.AddLazarusResource('greenbadge');        // 42
   fImages.AddLazarusResource('redbadge');          // 43
   fImages.AddLazarusResource('bluebadge');         // 44
   fImages.AddLazarusResource('orangebadge');       // 45
   K_IMG_EDIT_FIND := fImages.AddLazarusResource('edit-find');         // 46
   fImages.AddLazarusResource('Indy');              // 47
   fImages.AddLazarusResource('splash_logo');       // 48
   K_IMG_THREAD  := fImages.AddLazarusResource('thread');
   K_IMG_MESSAGE := fImages.AddLazarusResource('message');
   K_IMG_NETWORK := fImages.AddLazarusResource('network');
   K_IMG_CMND := fImages.AddLazarusResource('xpl-cmnd');
   K_IMG_STAT := fImages.AddLazarusResource('xpl-stat');
   K_IMG_TRIG := fImages.AddLazarusResource('xpl-trig');
end;

destructor TxPLGUIResource.Destroy;
begin
   fImages.Free;
   inherited;
end;

initialization
   {$I menu.lrs}

end.
