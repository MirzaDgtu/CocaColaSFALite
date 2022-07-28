unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Gauges, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, System.Actions, Vcl.ActnList, IdMessage, IdAttachmentFile,
  IdText, IdSMTP, IdPOP3, IdCoderHeader, IdMessageClient, IdExplicitTLSClientServerBase,
  IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc;

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
    XMLDoc: TXMLDocument;
    procedure MsgInitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
    procedure actGetMailExecute(Sender: TObject);
    procedure actParceXMLExecute(Sender: TObject);
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
var
  MsgCount: integer;
  i, c: integer;
Begin
  try

    try                           
      Msg.ContentType := 'multipart/related';        // Кодировка для русского языка
      Msg.CharSet := 'Windows-1251';                 // иначе будут ????? в письме
      Msg.IsEncoded := True;

      memoLog.Lines.Add('Попытка соединения...');
      
      POP.Connect;
      MsgCount := POP.CheckMessages;
      memoLog.Lines.Add('Соединение успешно установлено');
    except
      on ex: Exception do
        Begin
          memoLog.Lines.Add('Произошла ошибка подключения. Сообщение: ' + ex.Message);
          Exit;
        End;
    end;
     

    for I := 1 to MsgCount do
    try
      Msg.Clear;
      POP.Retrieve(i, Msg);


      if Msg.From.Address = 'subwoofer.666@yandex.ru' then
        Begin      
          memoLog.Lines.Add('Письмо от ' + Msg.From.Address);          
          for c := 0 to Msg.MessageParts.Count-1 do
              try
                 if Msg.MessageParts.Items[c] is TIdAttachmentFile then
                  try
                    if FileExists(ExtractFilePath(GetModuleName(0)) + 
                                                  'In\' + 
                                                  TIdAttachmentFile(Msg.MessageParts.Items[c]).FileName) then
                      DeleteFile(ExtractFilePath(GetModuleName(0)) + 
                                                 'In\' + 
                                                 TIdAttachmentFile(Msg.MessageParts.Items[c]).FileName);
                      
                    TIdAttachmentFile(Msg.MessageParts.Items[c]).SaveToFile(ExtractFilePath(GetModuleName(0)) + 
                                                                            'In\' +  
                                                                            Msg.MessageParts.Items[c].FileName);

                    memoLog.Lines.Add('Файл - ' + (ExtractFilePath(GetModuleName(0)) + 
                                                                   'In\' +  
                                                                   Msg.MessageParts.Items[c].FileName) + ' успешно сохранен');
                  except
                    on ex: Exception do
                      Begin
                        memoLog.Lines.Add('Ошибка сохранения файла - ' + 
                                          TIdAttachmentFile(Msg.MessageParts.Items[c]).FileName + 
                                          '. Сообщение: ' + ex.Message);
                        Continue;
                      End;
                  End;

                   

                 if Msg.MessageParts.Items[c] is TIdText then
                  Begin
                    try
                      memoLog.Lines.Add('-----------------------------------');
                      memoLog.Lines.Add('Текст письма от ' + Msg.From.Address);
                      memoLog.Lines.Add('Тема письма - ' + Msg.Subject);
                      memoLog.Lines.Add(TIdText(Msg.MessageParts.Items[c]).Body.Text);
                      memoLog.Lines.Add('-----------------------------------');                    
                    finally

                    end;
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

procedure TfmMain.actParceXMLExecute(Sender: TObject);
var
  i: integer;
begin

end;

procedure TfmMain.MsgInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);
begin
  VHeaderEncoding := 'B';
  VCharSet := 'windows-1251';
end;

end.
