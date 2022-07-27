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
    POP: TIdPOP3;
    procedure MsgInitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
    procedure actGetMailExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses SConsts;

procedure TfmMain.actGetMailExecute(Sender: TObject);
{var
  SMTP: TidPOP3;
  i: integer;
begin
  try
  //  Msg.From.Address := sFromEmailAdress + ';mirzali.pirmagomedov@vostok-td.ru';
    Msg.ContentType := 'multipart/related';        // Кодировка для русского языка
    Msg.CharSet := 'Windows-1251';          // иначе будут ????? в письме
    Msg.IsEncoded := True;

    SMTP := TidPOP3.Create(nil);
      try
        try
         SMTP.Host := 'pop.mail.ru';
         SMTP.Port := 110;
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
                if FileExists(TIdAttachmentFile(Msg.MessageParts.Items[i].FileName).FileName) then
                  DeleteFile(TIdAttachmentFile(Msg.MessageParts.Items[i].FileName).FileName);
                  TIdAttachmentFile(Msg.MessageParts.Items[i].FileName).SaveToFile(Msg.MessageParts.Items[i].FileName);
              End;

              if Msg.MessageParts.Items[i] is TIdText then
                Begin
                  memoLog.Lines.Add('Текст письма от ' + Msg.From.Address);
                  memoLog.Lines.Add(TIdText(Msg.MessageParts.Items[i]).Body.Text);
                End;
           End;
        except
          on err: Exception do
            memoLog.Lines.Add('Ошибка при отправке письма - ' + err.Message);
        end;
      finally
        SMTP.Disconnect;
      end;
  finally

  end;     }

var
  MsgCount: integer;
  i, c: integer;
Begin
  try

    Msg.ContentType := 'multipart/related';        // Кодировка для русского языка
    Msg.CharSet := 'Windows-1251';          // иначе будут ????? в письме
    Msg.IsEncoded := True;

    POP.Connect;
    MsgCount := POP.CheckMessages;
    memoLog.Lines.Add('Количество писем - ' + MsgCount.ToString);

    for I := 1 to MsgCount do
    try
      Msg.Clear;
      POP.Retrieve(i, Msg);

      if Msg.From.Address = 'subwoofer.666@yandex.ru' then
        Begin      
          for c := 0 to Msg.MessageParts.Count-1 do
              try
       //          if Msg.MessageParts.Items[c] is TIdAttachmentFile then
       //           Begin
       //             TIdAttachmentFile(Msg.MessageParts.Items[i].FileName).SaveToFile(ExtractFilePath(GetModuleName(0)) + 'In\' +  Msg.MessageParts.Items[i].FileName);
       //            End;

                 if Msg.MessageParts.Items[c] is TIdText then
                  Begin
                    memoLog.Lines.Add('Текст письма от ' + Msg.From.Address);
                    memoLog.Lines.Add('Тема письма - ' + Msg.Subject);
                    memoLog.Lines.Add(TIdText(Msg.MessageParts.Items[c]).Body);
                  End;
              except
                on exc: Exception do
                  Begin
                    memoLog.Lines.Add('Ошибка получения информации из письма от ' + Msg.From.Address + '. Сообщение - ' + exc.Message);
                    Continue;
                  End;
              end;
        End;


    except
      on ex: Exception do
        Begin
          memoLog.Lines.Add('Ошибка при получении письма. Сообщение: ' + ex.Message);
          Continue;
        End;
    end;
  finally
    POP.Disconnect;
  end;


end;

procedure TfmMain.MsgInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);
begin
  VHeaderEncoding := 'B';
  VCharSet := 'windows-1251';
end;

end.
