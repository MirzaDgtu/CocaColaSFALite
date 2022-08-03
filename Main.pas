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
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, System.StrUtils;

type
  TfmMain = class(TForm)
    sbMain: TStatusBar;
    pnlLog: TPanel;
    pnlMain: TPanel;
    ggProgress: TGauge;
    tbBtns: TToolBar;
    btnOpenLogFile: TToolButton;
    btnSaveLogFile: TToolButton;
    btnSendMail: TToolButton;
    memoLog: TMemo;
    gbxLog: TGroupBox;
    imLogo: TImage;
    gbxMoves: TGroupBox;
    btnGetMail: TBitBtn;
    btnClearLog: TToolButton;
    AL: TActionList;
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
    btnCloseApp: TToolButton;
    IL: TImageList;
    actSendMail: TAction;
    actOpenLogFIle: TAction;
    actSaveLogFile: TAction;
    actCloseApp: TAction;
    actClearLog: TAction;
    procedure MsgInitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
    procedure actGetMailExecute(Sender: TObject);
    procedure actParceXMLExecute(Sender: TObject);
    procedure actSendMailExecute(Sender: TObject);
    procedure actOpenLogFIleExecute(Sender: TObject);
    procedure actSaveLogFileExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure actCloseAppExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FpathLog: String;
    { Private declarations }
    function getActualDocument(): string;
    procedure SetpathLog(const Value: String);
  public
    { Public declarations }

  published
    property pathLog: String read FpathLog write SetpathLog;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses SConsts, DM;

procedure TfmMain.actClearLogExecute(Sender: TObject);
begin
  if Length(Trim(memoLog.Lines.Text)) > 0 then
    Begin
      if MessageBox(Handle, Pchar('Окно лога содержит информацию!' +
                                  #13 + 'Желаете сохранить?'),
                            PChar('Очистить лог'),
                    MB_ICONQUESTION+MB_YESNO) = ID_YES then
        Begin
          actSaveLogFileExecute(nil);
          memoLog.Lines.Clear;
        End
      else
        memoLog.Lines.Clear;
    End;
end;

procedure TfmMain.actCloseAppExecute(Sender: TObject);
begin
  Close();
end;

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


      if Msg.From.Address = sFromEmailAdress then
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

procedure TfmMain.actOpenLogFIleExecute(Sender: TObject);
begin
  OD.InitialDir := pathLog;
  OD.FilterIndex := 3;
  if OD.Execute then
     memoLog.Lines.LoadFromFile(OD.FileName);
end;

procedure TfmMain.actParceXMLExecute(Sender: TObject);
var
  rootNode: IXMLNode;
  rootNodeOrders, rootNodeOrdersBody: IXMLNode;
  i, j: integer;
  strFilePath, currOrder: string;
begin
   if getActualDocument().IsEmpty then
    Begin
      memoLog.Lines.Add('Файл заказов не обнаружен');
      Exit;
    End;

    try
      strFilePath := ExtractFilePath(GetModuleName(0)) + 'In\' + getActualDocument();
      currOrder := EmptyStr;
    
      memoLog.Lines.Add('Путь до файла: ' + strFilePath);
      XMLDoc.FileName := strFilePath;
      XMLDoc.Active := True;

      rootNode := XMLDoc.DocumentElement;
      memoLog.Lines.Add('Документ готов к обработке');

      for i := 0 to rootNode.ChildNodes.Count-1 do
        try
          rootNodeOrders := rootNode.ChildNodes[i];

          if currOrder <> rootNodeOrders.ChildNodes['ORDERID'].Text then
            Begin
              currOrder := rootNodeOrders.ChildNodes['ORDERID'].Text;

              // Head doc
              memoLog.Lines.Add(EmptyStr);
              memoLog.Lines.Add('-------------' + rootNodeOrders.ChildNodes['ORDERID'].Text+ '-------------');
              memoLog.Lines.Add('Номер заказа - ' + rootNodeOrders.ChildNodes['ORDERID'].Text);
              memoLog.Lines.Add('Дата взятия заказа ' + rootNodeOrders.ChildNodes['ORDER_DATE'].Text);
              memoLog.Lines.Add('Плановая дата доставки - ' + rootNodeOrders.ChildNodes['DELIVERY_DATE'].Text);
              memoLog.Lines.Add('Имя ТП в базе CCH - ' + rootNodeOrders.ChildNodes['SALES_REPID'].Text);
              memoLog.Lines.Add('Номер ТТ в базе CCH - ' + rootNodeOrders.ChildNodes['CLIENTID'].Text);
              memoLog.Lines.Add('Название клиента - ' + rootNodeOrders.ChildNodes['CLIENT_NAME'].Text);
              memoLog.Lines.Add('Адрес доставки - ' + rootNodeOrders.ChildNodes['CLIENT_ADDRESS'].Text);
              memoLog.Lines.Add('Код маршрута ТП(территории) - ' + rootNodeOrders.ChildNodes['DTC'].Text);
              memoLog.Lines.Add('Код ТТ(Фолио) -  ' + rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text);
              memoLog.Lines.Add('ИНН клиента - ' + rootNodeOrders.ChildNodes['FISCAL_NUMBER'].Text);
              memoLog.Lines.Add('Код склада дистрибьютора CCH - ' + rootNodeOrders.ChildNodes['ACTGRINUM'].Text);
              memoLog.Lines.Add('Населенный пункт доставки - ' + rootNodeOrders.ChildNodes['CITY'].Text);
              memoLog.Lines.Add('Источник заказа - ' + rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text);
              memoLog.Lines.Add('-------------------------------------------');
              memoLog.Lines.Add(EmptyStr);

              try
                // Recorting to DB
                AppData.Cmd.CommandText := Format(SSQLAddHeadOrder, [rootNodeOrders.ChildNodes['ORDERID'].Text,
                                                                     rootNodeOrders.ChildNodes['ORDER_DATE'].Text,
                                                                     rootNodeOrders.ChildNodes['DELIVERY_DATE'].Text,
                                                                     rootNodeOrders.ChildNodes['SALES_REPID'].Text,
                                                                     rootNodeOrders.ChildNodes['CLIENTID'].Text,
                                                                     rootNodeOrders.ChildNodes['CLIENT_NAME'].Text,
                                                                     StringReplace(rootNodeOrders.ChildNodes['CLIENT_ADDRESS'].Text, ';', ',', [rfReplaceAll, rfIgnoreCase]),
                                                                     rootNodeOrders.ChildNodes['DTC'].Text,
                                                                     rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text,
                                                                     rootNodeOrders.ChildNodes['FISCAL_NUMBER'].Text,
                                                                     rootNodeOrders.ChildNodes['ACTGRINUM'].Text,
                                                                     StringReplace(rootNodeOrders.ChildNodes['CITY'].Text, ';', '', [rfReplaceAll, rfIgnoreCase]),
                                                                     rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text
                                                                     ]);
                AppData.Cmd.Execute;

                memoLog.Lines.Add(#13+AppData.Cmd.CommandText+#13);
              except
                on ex: Exception do
                  Begin
                    memoLog.Lines.Add(#13+'Ошибка записи заявки - ' +
                                          rootNodeOrders.ChildNodes['ORDERID'].Text +
                                          'Сообщение: ' + ex.Message+
                                      #13);
                    Continue;
                  End;
              end;


              memoLog.Lines.Add(#13+'Шапка заявки - ' +
                                     rootNodeOrders.ChildNodes['ORDERID'].Text +
                                     ' успешно добавлена'+
                                #13);
            End;



              // Body doc
              memoLog.Lines.Add('Номер заказа - ' + rootNodeOrders.ChildNodes['ORDERID'].Text);
              memoLog.Lines.Add('Дата взятия заказа - ' + rootNodeOrders.ChildNodes['ORDER_DATE'].Text);
              memoLog.Lines.Add('Номер ТТ в базе CCH - ' + rootNodeOrders.ChildNodes['CLIENTID'].Text);
              memoLog.Lines.Add('Код ТТ(Фолио) -  ' + rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text);
              memoLog.Lines.Add('Код продукта в базе CCH - ' + rootNodeOrders.ChildNodes['PRODUCT_CODE'].Text);
              memoLog.Lines.Add('Название продукта - ' + rootNodeOrders.ChildNodes['PRODUCT_NAME'].Text);
              memoLog.Lines.Add('Количество мест (упаковок товара) - ' + rootNodeOrders.ChildNodes['QTY_CASES'].Text);
              memoLog.Lines.Add('Кол-во штук товара ' + rootNodeOrders.ChildNodes['QTY_BOTTLES'].Text);
              memoLog.Lines.Add('Кол-во бесплатных (бонусных) упаковок - ' + rootNodeOrders.ChildNodes['FREE_CASE'].Text);
              memoLog.Lines.Add('Скидка(руб.) от полной стоимости без НДС - ' + rootNodeOrders.ChildNodes['DISCOUNT'].Text);
              memoLog.Lines.Add('Цена за уп. в руб. без НДС с учетом скидки - ' + rootNodeOrders.ChildNodes['PRICE_CASE'].Text);
              memoLog.Lines.Add('Цена за 1 штуку штучного товара (крышки, стаканчики, соломка) - ' + rootNodeOrders.ChildNodes['PRICE_EA'].Text);
              memoLog.Lines.Add('Код склада дистрибьютора CCH - ' + rootNodeOrders.ChildNodes['ACTGRINUM'].Text);
              memoLog.Lines.Add('Кол-во упаковок со скидкой - ' + rootNodeOrders.ChildNodes['CASES_DISCOUNTED'].Text);
              memoLog.Lines.Add('Идентификатор промо механики -  ' + rootNodeOrders.ChildNodes['DISCOUNT_PROMO_ID'].Text);
              memoLog.Lines.Add('Итоговая стоимость по товару - ' + rootNodeOrders.ChildNodes['GROSS_VALUE'].Text);
              memoLog.Lines.Add('Источник заказа - ' + rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text);

              try
                AppData.CMD.CommandText :=  Format(SSQLAddMoveOrder, [rootNodeOrders.ChildNodes['ORDERID'].Text,
                                                                      rootNodeOrders.ChildNodes['ORDER_DATE'].Text,
                                                                      rootNodeOrders.ChildNodes['CLIENTID'].Text,
                                                                      rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text,
                                                                      rootNodeOrders.ChildNodes['PRODUCT_CODE'].Text,
                                                                      rootNodeOrders.ChildNodes['PRODUCT_NAME'].Text,
                                                                      rootNodeOrders.ChildNodes['QTY_CASES'].Text,
                                                                      rootNodeOrders.ChildNodes['QTY_BOTTLES'].Text,
                                                                      rootNodeOrders.ChildNodes['FREE_CASE'].Text,
                                                                      rootNodeOrders.ChildNodes['DISCOUNT'].Text,
                                                                      rootNodeOrders.ChildNodes['PRICE_CASE'].Text,
                                                                      rootNodeOrders.ChildNodes['PRICE_EA'].Text,
                                                                      rootNodeOrders.ChildNodes['ACTGRINUM'].Text,
                                                                      rootNodeOrders.ChildNodes['CASES_DISCOUNTED'].Text,
                                                                      rootNodeOrders.ChildNodes['DISCOUNT_PROMO_ID'].Text,
                                                                      EmptyStr,
                                                                      rootNodeOrders.ChildNodes['GROSS_VALUE'].Text,
                                                                      rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text
                                                                      ]);
                AppData.Cmd.Execute;

                memoLog.Lines.Add(EmptyStr);
                memoLog.Lines.Add(#13 + AppData.Cmd.CommandText + #13);
                memoLog.Lines.Add(EmptyStr);
                memoLog.Lines.Add('Запись - ' +
                                   rootNodeOrders.ChildNodes['ORDERID'].Text + '_' +
                                   rootNodeOrders.ChildNodes['PRODUCT_CODE'].Text +
                                   ' успешно добавлена!');
              except
                on ex: Exception do
                  Begin
                    memoLog.Lines.Add(#13 + 'Ошибка добавления записи - ' +
                                            rootNodeOrders.ChildNodes['ORDERID'].Text + '_' +
                                            rootNodeOrders.ChildNodes['PRODUCT_CODE'].Text +
                                            'Сообщение: ' + ex.Message +
                                      #13);
                    Continue;
                  End;
              end;

          memoLog.Lines.Add(EmptyStr);
          currOrder := rootNodeOrders.ChildNodes['ORDERID'].Text;

        except
          on ex: Exception do
            Begin
              memoLog.Lines.Add('Ошибка получения поля. Сообщение: ' + ex.Message);
              Continue;
            End;
        end;
    finally
      XMLDoc.Active := False;
    end;
end;

procedure TfmMain.actSaveLogFileExecute(Sender: TObject);
begin
  if Length(Trim(memoLog.Lines.Text)) > 0 then
  try
    memoLog.Lines.SaveToFile(pathLog + 'log_' + FormatDateTime('dd-mm-yyyy hh-mm-ss', Now()) + '.log', TEncoding.UTF8);
    memoLog.Lines.Add('Лог успешно сохранен!');
  except
    on ex: Exception do
      memoLog.Lines.Add('Ошибка сохранения лога - ' + ex.Message);
  end;
end;

procedure TfmMain.actSendMailExecute(Sender: TObject);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
 // attach   : TIdAttachmentFile;     // Для вложений
begin
  { DONE 1 -opmp -cLog : Отправка письма об успешном формировании выгрузки }
  if memoLog.Lines.Text <> EmptyStr then
    try
      Msg := TIdMessage.Create(nil);
      try
        Msg.From.Address := 'reports@vostok-td.ru';
        Msg.From.Name := 'Поддержка ТД Восток';
        Msg.Recipients.EMailAddresses := 'mirzali.pirmagomedov@vostok-td.ru';
        Msg.Subject := Format('Отчёт CocaCola-SFALite - [%s] - [%s]', [{FormatDateTime('dd.mm.yyyy', dtpBegin.Date),
                                                                       FormatDateTime('dd.mm.yyyy', dtpEnd.Date)}
                                                                       FormatDateTime('dd.MM.yyyy hh:mm', Now()),
                                                                       FormatDateTime('dd.MM.yyyy hh:mm', Now())]);

        Msg.Body.Text := memoLog.Text;
        Msg.Date := Now();
        Msg.ContentType := 'text/plain';        // Кодировка для русского языка
        Msg.CharSet := 'Windows-1251';          // иначе будут ????? в письме
        Msg.IsEncoded := True;


        SMTP := TIdSMTP.Create(nil);
        try
          try
           SMTP.Host := 'smtp.mail.ru';
           SMTP.Port := 465;
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
           SMTP.Send(Msg);
          except
            on err: Exception do
              memoLog.Lines.Add('Ошибка при отправке письма - ' + err.Message);
          end;
        finally
           FreeAndNil(SMTP);
           memoLog.Lines.Add('Письмо о формировании отчета отправлен на электронную почту');
        end;
      finally
        FreeAndNil(Msg);
      end;
    finally
    end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  SetpathLog(ExtractFilePath(GetModuleName(0)) + 'Log\');
end;

// Получение последнего файла из папки In
function TfmMain.getActualDocument: string;
var
  sr: TSearchRec;
  dt: TDateTime;
  fn: string;
begin
 if FindFirst(ExtractFilePath(GetModuleName(0)) + 'In\*.xml', faAnyfile, sr) = 0 then
  begin
    dt := sr.Time;
    fn := sr.Name;
    repeat
      if sr.Time > dt then
      begin
        dt := sr.Time;
        fn := sr.Name;
      end;
    until FindNext(sr) <> 0;
  end;
      Result := fn;
  FindClose(sr);
end;

procedure TfmMain.MsgInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);
begin
  VHeaderEncoding := 'B';
  VCharSet := 'windows-1251';
end;

procedure TfmMain.SetpathLog(const Value: String);
begin
  FpathLog := Value;
end;

end.
