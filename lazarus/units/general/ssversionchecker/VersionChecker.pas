{
04/01/2011 : Updated by clinique for ClinxPL project.

Based on :
Copyright (c) Sambo Software. All Rights Reserved.
This component and it's source is licensed under the LGPL and the MPL license.

Author: Sambo Software
Date: 30/09/02
Version: 1.2

http://www.sambosoftware.net

This component uses the Indy HTTPClient component.

Portions of this software are Copyright (c) 1993 - 2002, Chad Z. Hower (Kudzu) and the Indy Pit Crew
http:/ /www.nevrona.com/Indy/

Please refer to the license.txt file for the license files.
}
unit VersionChecker;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes;

type TVersionChecker = class(TComponent)
     private
        fServerLocation : string;
        fCurrentVersion : string;
        fServerVersion : string;
        fDownloadURL   : string;
        fVersionNode: string;
        fDownloadNode : string;
        fUpdateFound: TNotifyEvent;
        fUpdateNotFound: TNotifyEvent;
     public
	procedure CheckVersion; //(const ProxSrvr, ProxPort : string);
     published
        property ServerLocation  : string read fServerLocation write fServerLocation;       // Distant file holding last version information
        property CurrentVersion  : string read fCurrentVersion write fCurrentVersion;       // Version of the local application
        property VersionNode     : string read fVersionNode    write fVersionNode;          // Node to be queried to get version information
        property DownloadNode    : string read fDownloadNode   write fDownloadNode;         // Node to be queried to get download site information
        property ServerVersion   : string read fServerVersion;                              // As a result, the server version
        property DownloadURL     : string read fDownloadURL;                                // As a result, the download location
        property OnNoUpdateFound : TNotifyEvent read fUpdateNotFound write fUpdateNotFound; // Events handlers
        property OnUpdateFound   : TNotifyEvent read fUpdateFound    write fUpdateFound;    // Events handlers
     end;

implementation //==============================================================
uses xPath,
     IdHTTP,
     XMLRead,
     StrUtils,
     DOM;

// ============================================================================
function Evaluate(const aQuery : string; const aDoc : TXMLDocument) : string;
var xpathValue: TXPathVariable;
begin
   xPathValue := EvaluateXPathExpression(aQuery, aDoc.DocumentElement);
   Result := IfThen(Assigned(xPathValue),xPathValue.AsText);
end;

// ============================================================================
procedure TVersionChecker.CheckVersion; //(const ProxSrvr, ProxPort : string);
var XMLStream : TStringStream;
    XML : TXMLDocument;
    HTTPClient : TIdHTTP;
begin
   if not (Assigned(fUpdateFound) and Assigned(fUpdateNotFound)) then exit;    // No event assigned : no reason to do anything ...

   HTTPClient := TIdHTTP.Create(Self);                                         // create the HTTPClient object
   //HTTPClient.ProxyParams.ProxyPort:= StrToInt(ProxPort);
   //HTTPClient.ProxyParams.ProxyServer:= ProxSrvr;

   XMLStream := TStringStream.Create(HTTPClient.Get(fServerLocation));
   XMLStream.Position := 0;
   ReadXMLFile(XML,XMLStream);
   XMLStream.Free;

   fServerVersion := Evaluate(VersionNode,XML);

   if (fServerVersion > fCurrentVersion) then begin                            // check to see if the version is greater
      fDownloadURL := Evaluate(DownloadNode, XML);
      FUpdateFound(self);
   end else FUpdateNotFound(self);

   HTTPClient.Free;                                                            // Free all the components used}
   XML.Free;
end;

end.
