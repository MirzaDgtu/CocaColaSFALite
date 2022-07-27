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
begin
  try
    Msg.ContentType := 'text/plain';        // Кодировка для русского языка
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
        except
          on err: Exception do
            memoLog.Lines.Add('Ошибка при отправке письма - ' + err.Message);
        end;
      finally

      end;
  finally

  end;

end;

end.
