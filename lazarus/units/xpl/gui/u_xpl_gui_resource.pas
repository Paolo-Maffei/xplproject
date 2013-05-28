unit u_xpl_gui_resource;

{$mode objfpc}{$H+}

interface

uses Classes
     , SysUtils
     , ImgList
     ;

type // TxPLGUIResource =======================================================
     TxPLGUIResource = class
     private
        fImages16 : TCustomImageList;
        fImages32 : TCustomImageList;
        function Get_Images16 : TCustomImageList;
        function Get_Images32 : TCustomImageList;
     public
        constructor Create;

        property Images16 : TCustomImageList read Get_Images16;
        property Images32 : TCustomImageList read Get_Images32;
     end;

var xPLGUIResource : TxPLGUIResource;

var K_IMG_THREAD, K_IMG_pkg_installed, K_IMG_NETWORK, K_IMG_MAIL_FORWARD,
    K_IMG_MESSAGE, K_IMG_STAT, K_IMG_EDIT_FIND, K_IMG_TRIG, K_IMG_CMND,
    K_IMG_PREFERENCE, K_IMG_LOUPE, K_IMG_CE_PROCEDURE, K_IMG_SYNCHRONIZE,
    K_IMG_EDIT_ADD, K_IMG_BUILD, K_IMG_TEST, K_IMG_EDIT_REMOVE, K_IMG_REFRESH,
    K_IMG_PLAYER_PAUSE, K_IMG_PLAYER_STOP, K_IMG_DOCUMENT_SAVE, K_IMG_RECORD,
    K_IMG_DOCUMENT_OPEN, K_IMG_MENU_RUN, K_IMG_BLUE_BADGE, K_IMG_ORANGE_BADGE,
    K_IMG_GREEN_BADGE, K_IMG_TRASH, K_IMG_RED_BADGE, K_IMG_RECONNECT,
    K_IMG_CLOSE, K_IMG_COPY, K_IMG_XPL, K_IMG_LOGVIEW, K_IMG_TXT,
    K_IMG_DOWNLOAD, K_IMG_LOOP,
    K_IMG_DISCONNECt,K_IMG_PASTE, K_IMG_CHECK, K_IMG_CLEAN, K_IMG_FILTER,
    K_IMG_PREVIOUS, K_IMG_NEXT, K_IMG_OK, K_IMG_CANCEL,K_IMG_EDIT : integer;

implementation // =============================================================
uses Forms
     , LResources
     ;

constructor TxPLGUIResource.Create;
begin
   inherited;
   fImages16 := TCustomImageList.Create(Application);
   fImages32 := TCustomImageList.Create(Application);
end;

function TxPLGUIResource.Get_Images32: TCustomImageList;
begin
   Result := fImages32;
   if fImages32.Count = 0 then begin                                           // Resources are only loaded if they are accessed at least once
      fImages32.AddLazarusResource('etError');                                 // 29
      fImages32.AddLazarusResource('etInfo');                                  // 30
      fImages32.AddLazarusResource('etWarning');                               // 31
   end;
end;

function TxPLGUIResource.Get_Images16: TCustomImageList;
begin
   Result := fImages16;
   if fImages16.Count = 0 then begin                                           // Resources are only loaded if they are accessed at least once
      K_IMG_XPL := fImages16.AddLazarusResource('xpl');                                     // 0
      K_IMG_CLOSE := fImages16.AddLazarusResource('menu_exit');                               // 1
      fImages16.AddLazarusResource('menu_information');                        // 2
      K_IMG_DOCUMENT_SAVE := fImages16.AddLazarusResource('laz_save');         // 3
      K_IMG_REFRESH := fImages16.AddLazarusResource('laz_refresh');                             // 4
      K_IMG_CE_PROCEDURE := fImages16.AddLazarusResource('ce_procedure');      // 5
      K_IMG_MENU_RUN := fImages16.AddLazarusResource('menu_run');              // 6
      K_IMG_pkg_installed := fImages16.AddLazarusResource('pkg_installed');    // 7
      K_IMG_TXT := fImages16.AddLazarusResource('txt');                                     // 8
      K_IMG_DOWNLOAD := fImages16.AddLazarusResource('2downarrow');                              // 9
      K_IMG_EDIT_ADD := fImages16.AddLazarusResource('edit_add');              // 10
      K_IMG_EDIT_REMOVE := fImages16.AddLazarusResource('edit_remove');        // 11
      fImages16.AddLazarusResource('ledgreen');                                // 12
      fImages16.AddLazarusResource('ledorange');                               // 13
      fImages16.AddLazarusResource('ledred');                                  // 14
      K_IMG_OK := fImages16.AddLazarusResource('button_ok');                   // 15
      K_IMG_CANCEL := fImages16.AddLazarusResource('button_cancel');           // 16
      K_IMG_DOCUMENT_OPEN := fImages16.AddLazarusResource('fileopen');         // 17
      K_IMG_COPY := fImages16.AddLazarusResource('editcopy');                                // 18
      K_IMG_PASTE := fImages16.AddLazarusResource('editpaste');                 // 19
      K_IMG_MAIL_FORWARD := fImages16.AddLazarusResource('mail_forward');      // 20
      fImages16.AddLazarusResource('misc');                                    // 21
      K_IMG_PLAYER_PAUSE := fImages16.AddLazarusResource('player_pause');                            // 22
      K_IMG_PLAYER_STOP := fImages16.AddLazarusResource('player_stop');                             // 23
      K_IMG_FILTER := fImages16.AddLazarusResource('item_filter');                             // 24
      K_IMG_CLEAN := fImages16.AddLazarusResource('menu_clean');                              // 25
      fImages16.AddLazarusResource('up');                                      // 26
      fImages16.AddLazarusResource('down');                                    // 27
      fImages16.AddLazarusResource('clock');                                   // 28
      fImages16.AddLazarusResource('exit');                                    // 29
      K_IMG_DISCONNECT := fImages16.AddLazarusResource('disconnect');          // 30
      K_IMG_RECONNECT  := fImages16.AddLazarusResource('reconnect');           // 31
      fImages16.AddLazarusResource('activity');                                // 32
      K_IMG_TRASH := fImages16.AddLazarusResource('trash');
      K_IMG_CHECK := fImages16.AddLazarusResource('check');                                   // 34
      fImages16.AddLazarusResource('notchecked');                              // 35
      K_IMG_LOGVIEW := fImages16.AddLazarusResource('logview');                                 // 36
      K_IMG_SYNCHRONIZE := fImages16.AddLazarusResource('synchronize');        // 37
      K_IMG_PREFERENCE  := fImages16.AddLazarusResource('preferences');        // 38
      K_IMG_GREEN_BADGE := fImages16.AddLazarusResource('greenbadge');         // 39
      K_IMG_RED_BADGE := fImages16.AddLazarusResource('redbadge');             // 40
      K_IMG_BLUE_BADGE:= fImages16.AddLazarusResource('bluebadge');            // 41
      K_IMG_ORANGE_BADGE := fImages16.AddLazarusResource('orangebadge');       // 42
      K_IMG_EDIT_FIND := fImages16.AddLazarusResource('edit-find');            // 43
      K_IMG_THREAD  := fImages16.AddLazarusResource('thread');                 // 44
      K_IMG_MESSAGE := fImages16.AddLazarusResource('message');                // 45
      K_IMG_NETWORK := fImages16.AddLazarusResource('network');
      K_IMG_LOUPE := fImages16.AddLazarusResource('loupe');
      K_IMG_RECORD := fImages16.AddLazarusResource('record');
      K_IMG_BUILD := fImages16.AddLazarusResource('menu_build');
      K_IMG_TEST := fImages16.AddLazarusResource('menu_test');
      K_IMG_PREVIOUS := fImages16.AddLazarusResource('resultset_previous');
      K_IMG_NEXT := fImages16.AddLazarusResource('resultset_next');
      K_IMG_EDIT := fImages16.AddLazarusResource('page_edit');
      K_IMG_LOOP := fImages16.AddLazarusResource('loop');
      // Msgtype ==============================================================
      K_IMG_CMND := fImages16.AddLazarusResource('xpl-cmnd');
      K_IMG_STAT := fImages16.AddLazarusResource('xpl-stat');
      K_IMG_TRIG := fImages16.AddLazarusResource('xpl-trig');
   end;
end;

initialization // =============================================================
   {$I menu.lrs}     // Interface icons
   {$I class.lrs}    // Message classes
   {$I msgtype.lrs}  // Message types
   xPLGUIResource := TxPLGUIResource.Create;

finalization // ===============================================================
   xPLGUIResource.Free;

end.
