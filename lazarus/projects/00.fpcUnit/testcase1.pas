unit TestCase1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry; 

type

  { ClinxPLfpcUnit }

  ClinxPLfpcUnit= class(TTestCase)
  published
    procedure TestMsgType;
    procedure TestSchema;
    procedure TestAddress;
    procedure TestTarget;
    procedure TestHeader;
    procedure TestBody;
    procedure TestConfigItem;
    procedure TestMessage;
  end; 

implementation

uses u_xPL_Schema,
     u_xPL_Address,
     u_xPL_header,
     u_xPL_Body,
     u_xpl_Common,
     u_xpl_custom_message,
     u_xpl_message,
     u_xPL_Config;

procedure ClinxPLfpcUnit.TestMsgType;
var typ1,typ2 : TxPLMessageType;
begin
     typ1 := cmnd;
     AssertEquals( MsgTypeToStr(typ1) = 'xpl-cmnd',true);
     typ2 := StrToMsgType(MsgTypeToStr(typ1));
     AssertEquals( typ1 = typ2, true);
end;

procedure ClinxPLfpcUnit.TestSchema;
var schema1, schema2 : TxPLSchema;
begin
   schema1 := TxPLSchema.Create;
   AssertEquals(schema1.IsValid, false);               // invalide par défaut à la création
   schema2 := TxPLSchema.Create('chose','truc');
   schema1.Assign(schema2);                       // Tester l'assignation
   AssertEquals(schema1.classe, schema2.classe);
   schema2.resetvalues;
   AssertEquals(schema2.isvalid,false);
   schema2.Classe:='"_"éàç_"_àç';               // Tester les caractères interdits
   AssertEquals(schema2.isvalid,false);
   schema2.classe:='log';
   schema2.Type_:='basic';
   AssertEquals(schema2.isvalid,true);          // Tester le test de valeurs correctes
   AssertEquals(schema2.rawxPL,'log.basic');    // Tester la constitution de rawxpl
   schema2.Type_:='basictoolong';                  // chaine trop longue
   AssertEquals(schema2.rawxPL,'log.basic');
   schema2.RawxPL:='control.reply';                // affectation directe par rawxpl
   AssertEquals(schema2.classe,'control');         // vérifier sa décomposition
   AssertEquals(schema2.type_,'reply');
   schema2.Free;
   schema1.free;
   schema2 := 'control.reply';
   AssertEquals(schema2.classe,'control');         // vérifier sa décomposition
   AssertEquals(schema2.type_,'reply');
   schema2 := 'ac.basic';
   AssertEquals(schema2.classe,'ac');         // vérifier sa décomposition
   AssertEquals(schema2.type_,'basic');
   schema2.free;
end;

procedure ClinxPLfpcUnit.TestAddress;
var adr1,adr2, adr3 : TxPLAddress;
begin
   adr1 := TxPLAddress.Create;
   AssertEquals(adr1.isvalid,false);               // invalide par défaut à la création
   adr1.vendor := 'moi';
   adr1.Device :='device';
   adr1.instance:='instance';
   AssertEquals(adr1.isvalid,true);               // invalide par défaut à la création
   adr2 := TxPLAddress.Create(adr1);
   AssertEquals(adr1.rawxpl, adr2.rawxpl);         // teste assignation
   adr2.resetvalues;
   AssertEquals(adr2.isvalid,false);               // invalide par défaut à la création
   adr2.RawxPL:='moi-device.instance';
   AssertEquals(adr1.rawxpl, adr2.rawxpl);         // teste le split de rawxpl
   AssertEquals(adr1.Equals(adr2),true);
   AssertEquals(adr1.VD,'moi-device');
   adr1.VD := 'clinique-essai';
   AssertEquals(adr1.RawxPL, 'clinique-essai.instance');
   adr1.Instance := '0001';
   AssertEquals(adr1.Instance,'0001');
   adr1.Vendor := 'hy-phen';
   AssertEquals(adr1.Instance = 'hy-phen',false);
   adr1.Free;
   adr2.free;
end;

procedure ClinxPLfpcUnit.TestTarget;
var adr1 : TxPLAddress;
    tar1 : TxPLTargetAddress;
begin
   adr1 := TxPLAddress.Create('moi','device','instance');
   AssertEquals(adr1.isvalid,true);
   AssertEquals(adr1.RawxPL,'moi-device.instance');
   AssertEquals(adr1.AsFilter,'moi.device.instance');
   adr1.RawxPL:='1chose-marche.bien';
   AssertEquals(adr1.IsValid,true);
   adr1.RawxPL:='chose-marche.bien';
   AssertEquals(adr1.IsValid,true);
   tar1 := TxPLTargetAddress.Create;
   AssertEquals(tar1.isvalid,true);
   AssertEquals(tar1.IsGeneric,true);
   AssertEquals(tar1.RawxPL,'*');
   tar1.Assign(adr1);
   AssertEquals(tar1.IsGeneric,false);
   AssertEquals(tar1.RawxPL,adr1.RawxPL);
   tar1.IsGeneric:=true;
   AssertEquals(tar1.IsGeneric,true);
   AssertEquals(tar1.RawxPL,'*');
   AssertEquals(tar1.AsFilter,'*.*.*');
   tar1.Assign(adr1);
   AssertEquals(tar1.Equals(adr1),true);
   tar1.IsGroup := true;
   AssertEquals(tar1.AsFilter,'xpl.group.bien');
   AssertEquals(tar1.IsGroup,true);
   AssertEquals(tar1.IsValid,true);
   AssertEquals(tar1.IsGeneric,false);
   adr1.Free;
   adr1 := tar1.RawxPL;
   AssertEquals(tar1.Equals(adr1),true);
end;

procedure ClinxPLfpcUnit.TestHeader;
var compo : TComponent;
    head1,head2 : TxPLHeader;
begin
   compo := TComponent.Create(nil);
     head1 := TxPLHeader.Create(compo);
     AssertEquals(head1.hop,1);
     head1.hop := 12;
     AssertEquals(head1.hop,1);
     head1.hop := -2;
     AssertEquals(head1.hop,1);
     head1.free;
   compo.free;
end;

procedure ClinxPLfpcUnit.TestBody;
var body1, body2 : TxPLBody;
begin
   body1 := TxPLBody.Create(nil);
   body1.AddKeyValue('essai=truc');
   AssertEquals(body1.Itemcount=1,true);
   body1.ResetValues;
   AssertEquals(body1.Itemcount=0,true);
   body1.AddKeyValue('bidule=chose');
   body1.AddKeyValue('trucmuche=');
   body1.AddKeyValue('essai=trucmlksdfjfdsjfsd fdkkldsf jdsfmljf dsflksfdj fdmslkjdsf mlksfdj fdsmlkjfds sdflmkjfds lmsdfjk sdlmfkjfsd mlfjkd dsfmljk fdslmk fjsd');
   AssertEquals(body1.Itemcount=4,true);
   body1.CleanEmptyValues;
   AssertEquals(body1.Itemcount=3,true);
   body1.Free;
end;

procedure ClinxPLfpcUnit.TestConfigItem;
var configitem : TxPLConfigItem;
begin
     configitem := TxPLConfigItem.Create(nil);
     configitem.ItemMax:=1;
     AssertEquals(ConfigItem.ItemMaxAsString,'');
     configitem.ItemMax:=12;
     AssertEquals(ConfigItem.ItemMaxAsString,'[12]');
     configitem.ItemDefault:='default';
     AssertEquals(ConfigItem.ValueCount,0);
     AssertEquals(ConfigItem.IsValid,true);
     ConfigItem.AddValue('valeur');
     AssertEquals(ConfigItem.ValueCount,1);
end;

procedure ClinxPLfpcUnit.TestMessage;
var message, message2 : TxPLCustomMessage;
    s1,s2 : string;
begin
   message := TxPLCustomMessage.Create(nil);
   message.source.Device:='device';
   message.source.Instance:='instance';
   message.source.Vendor:='vendor';
   message.target.IsGeneric:=true;
   message.MessageType:=cmnd;
   message.schema.RawxPL:='command.basic';
   message.Body.AddKeyValuePairs(['key'],['value']);
   s1 := message.RawXPL;
   AssertEquals(s1,message.RawXPL);
   s2 := s1;
   message.RawxPL := s1;
   AssertEquals(s2,message.RawxPL);
   message2 := TxPLCustomMessage.Create(nil);
   message2.Assign(message);
   AssertEquals(message.RawxPL,message2.Rawxpl);
   message.free;
end;



initialization

  RegisterTest(ClinxPLfpcUnit); 
end.

