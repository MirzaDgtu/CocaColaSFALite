unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Gauges, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, IdMessage, IdAttachmentFile,
  IdText, IdSMTP, IdPOP3, IdCoderHeader, IdMessageClient, IdExplicitTLSClientServerBase,
  IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient;

type
  TfmMain = class(TForm)
    sbMain: TStatusBar;
    pnlLog: TPanel;
    pnlMain: TPanel;
    ggProgress: TGauge;
    tbBtns: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    memoLog: TMemo;
    gbxLog: TGroupBox;
    imLogo: TImage;
    gbxMoves: TGroupBox;
    btnGetMail: TBitBtn;
    ToolButton4: TToolButton;
    AL: TActionList;
    IL: TImageList;
    OD: TOpenDialog;
    Msg: TIdMessage;
    btnParseXml: TBitBtn;
    btnLoadToDB: TBitBtn;
    actGetMail: TAction;
    actParceXML: TAction;
    actLoadToDB: TAction;
    OpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    procedure btnGetMailClick(Sender: TObject);
    procedure MsgInitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.btnGetMailClick(Sender: TObject);
var
  SMTP: TIdSMTP;
  i: integer;
begin
  try
    Msg.From.Address := sFromEmailAdress + ';mirzali.pirmagomedov@vostok-td.ru';
    Msg.ContentType := 'multipart/related';        // Кодировка для русского языка
    Msg.CharSet := 'Windows-1251';          // иначе будут ????? в письме
    Msg.IsEncoded := True;

    SMTP := TidPOP3.Create(nil);
      try
        try
         SMTP.Host := 'pop.mail.ru';
         SMTP.Port := 110;
         SMTP.AuthType := satDefault;
         SMTP.Username := 'reports@vostok-td.ru';
         SMTP.Password := 'uaA2eAiRSo^2';

         OpenSSL.Destination := SMTP.Host + ':' + IntToStr(SMTP.Port);
         OpenSSL.Host := SMTP.Host;
         OpenSSL.Port := SMTP.Port;
         OpenSSL.DefaultPort := 0;
         OpenSSL.SSLOptions.Mode := sslmUnassigned;

         SMTP.IOHandler := OpenSSL;
         SMTP.UseTLS := utUseExplicitTLS;

         SMTP.Connect;
         SMTP.Retrieve(SMTP.CheckMessages-1, Msg);

         for I := 0 to Msg.MessageParts.Count-1 do
           Begin
             if Msg.MessageParts.Items[i] is TIdAttachmentFile then
              Begin
                if FileExists(TIdAttachmentFile(Msg.MessageParts.Items[i].FileName)) then
                  DeleteFile(TIdAttachmentFile(Msg.MessageParts.Items[i].FileName));
                  TIdAttachmentFile(Msg.MessageParts.Items[i].FileName).SaveToFile(Msg.MessageParts.Items[i].FileName);
              End;

              if Msg.MessageParts.Items[i] is TIdText then
                Begin
                  memoLog.Lines.Add('Текст письма от ' + Msg.From.Address);
                  memoLog.Lines.Add(TIdText(Msg.MessageParts.Items[i]).Body);
                End;
           End;
        except
          on err: Exception do
            memoLog.Lines.Add('Ошибка при отправке письма - ' + err.Message);
        end;
      finally

      end;
  finally

  end;

end;

procedure TfmMain.MsgInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);
begin
  VHeaderEncoding := 'B';
  VCharSet := 'windows-1251';
end;

end.
