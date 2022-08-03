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
    function getActualDocument(): string;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses SConsts, DM;

procedure TfmMain.actGetMailExecute(Sender: TObject);
var
  MsgCount: integer;
  i, c: integer;
Begin
  try

    try                           
      Msg.ContentType := 'multipart/related';        // ��������� ��� �������� �����
      Msg.CharSet := 'Windows-1251';                 // ����� ����� ????? � ������
      Msg.IsEncoded := True;

      memoLog.Lines.Add('������� ����������...');
      
      POP.Connect;
      MsgCount := POP.CheckMessages;
      memoLog.Lines.Add('���������� ������� �����������');
    except
      on ex: Exception do
        Begin
          memoLog.Lines.Add('��������� ������ �����������. ���������: ' + ex.Message);
          Exit;
        End;
    end;
     

    for I := 1 to MsgCount do
    try
      Msg.Clear;
      POP.Retrieve(i, Msg);


      if Msg.From.Address = 'subwoofer.666@yandex.ru' then
        Begin      
          memoLog.Lines.Add('������ �� ' + Msg.From.Address);          
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

                    memoLog.Lines.Add('���� - ' + (ExtractFilePath(GetModuleName(0)) + 
                                                                   'In\' +  
                                                                   Msg.MessageParts.Items[c].FileName) + ' ������� ��������');
                  except
                    on ex: Exception do
                      Begin
                        memoLog.Lines.Add('������ ���������� ����� - ' + 
                                          TIdAttachmentFile(Msg.MessageParts.Items[c]).FileName + 
                                          '. ���������: ' + ex.Message);
                        Continue;
                      End;
                  End;

                   

                 if Msg.MessageParts.Items[c] is TIdText then
                  Begin
                    try
                      memoLog.Lines.Add('-----------------------------------');
                      memoLog.Lines.Add('����� ������ �� ' + Msg.From.Address);
                      memoLog.Lines.Add('���� ������ - ' + Msg.Subject);
                      memoLog.Lines.Add(TIdText(Msg.MessageParts.Items[c]).Body.Text);
                      memoLog.Lines.Add('-----------------------------------');                    
                    finally

                    end;
                  End;
              except
                on exc: Exception do
                  Begin
                    memoLog.Lines.Add('������ ��������� ���������� �� ������ �� ' + Msg.From.Address + '. ��������� - ' + exc.Message);
                    Continue;
                  End;
              end;
        End;


    except
      on ex: Exception do
        Begin
          memoLog.Lines.Add('������ ��� ��������� ������. ���������: ' + ex.Message);
          Continue;
        End;
    end;
  finally
    POP.Disconnect;
  end;


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
      memoLog.Lines.Add('���� ������� �� ���������');
      Exit;
    End;

    try
      strFilePath := ExtractFilePath(GetModuleName(0)) + 'In\' + getActualDocument();
      currOrder := EmptyStr;
    
      memoLog.Lines.Add('���� �� �����: ' + strFilePath);
      XMLDoc.FileName := strFilePath;
      XMLDoc.Active := True;

      rootNode := XMLDoc.DocumentElement;
      memoLog.Lines.Add('�������� ����� � ���������');

      for i := 0 to rootNode.ChildNodes.Count-1 do
        try
          rootNodeOrders := rootNode.ChildNodes[i];

          if currOrder <> rootNodeOrders.ChildNodes['ORDERID'].Text then
            Begin
              currOrder := rootNodeOrders.ChildNodes['ORDERID'].Text;

              // Head doc
              memoLog.Lines.Add('����� ������ - ' + rootNodeOrders.ChildNodes['ORDERID'].Text);
          memoLog.Lines.Add('���� ������ ������ ' + rootNodeOrders.ChildNodes['ORDER_DATE'].Text);
              memoLog.Lines.Add('�������� ���� �������� - ' + rootNodeOrders.ChildNodes['DELIVERY_DATE'].Text);
              memoLog.Lines.Add('��� �� � ���� CCH - ' + rootNodeOrders.ChildNodes['SALES_REPID'].Text);
              memoLog.Lines.Add('����� �� � ���� CCH - ' + rootNodeOrders.ChildNodes['CLIENTID'].Text);
              memoLog.Lines.Add('�������� ������� - ' + rootNodeOrders.ChildNodes['CLIENT_NAME'].Text);
              memoLog.Lines.Add('����� �������� - ' + rootNodeOrders.ChildNodes['CLIENT_ADDRESS'].Text);
              memoLog.Lines.Add('��� �������� ��(����������) - ' + rootNodeOrders.ChildNodes['DTC'].Text);
              memoLog.Lines.Add('��� ��(�����) -  ' + rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text);
              memoLog.Lines.Add('��� ������� ' + rootNodeOrders.ChildNodes['FISCAL_NUMBER'].Text);
              memoLog.Lines.Add('��� ������ ������������� CCH ' + rootNodeOrders.ChildNodes['ACTGRINUM'].Text);
              memoLog.Lines.Add('���������� ����� �������� - ' + rootNodeOrders.ChildNodes['CITY'].Text);
              memoLog.Lines.Add('�������� ������ ' + rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text);

              // Recorting to DB
              AppData.Cmd.CommandText := Format(SSQLAddHeadOrder, [rootNodeOrders.ChildNodes['ORDERID'].Text,
                                                                   rootNodeOrders.ChildNodes['ORDER_DATE'].Text,
                                                                   rootNodeOrders.ChildNodes['DELIVERY_DATE'].Text,
                                                                   rootNodeOrders.ChildNodes['SALES_REPID'].Text,
                                                                   rootNodeOrders.ChildNodes['CLIENTID'].Text.IsEmpty,
                                                                   rootNodeOrders.ChildNodes['CLIENT_NAME'].Text,
                                                                   rootNodeOrders.ChildNodes['CLIENT_ADDRESS'].Text,
                                                                   rootNodeOrders.ChildNodes['DTC'].Text,
                                                                   rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text,
                                                                   rootNodeOrders.ChildNodes['FISCAL_NUMBER'].Text,
                                                                   rootNodeOrders.ChildNodes['ACTGRINUM'].Text,
                                                                   rootNodeOrders.ChildNodes['CITY'].Text,
                                                                   rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text
                                                                   ]);
              AppData.Cmd.Execute;

              memoLog.Lines.Add('����� ������ - ' + rootNodeOrders.ChildNodes['ORDERID'].Text + ' ������� ���������');
            End;



          // Body doc
          memoLog.Lines.Add('����� ������ - ' + rootNodeOrders.ChildNodes['ORDERID'].Text);
          memoLog.Lines.Add('���� ������ ������ ' + rootNodeOrders.ChildNodes['ORDER_DATE'].Text);
          memoLog.Lines.Add('����� �� � ���� CCH - ' + rootNodeOrders.ChildNodes['CLIENTID'].Text);
          memoLog.Lines.Add('��� ��(�����) -  ' + rootNodeOrders.ChildNodes['CLIENTID_DISTRIB'].Text);
          memoLog.Lines.Add('��� �������� � ���� CCH - ' + rootNodeOrders.ChildNodes['PRODUCT_CODE'].Text);
          memoLog.Lines.Add('�������� �������� - ' + rootNodeOrders.ChildNodes['PRODUCT_NAME'].Text);
          memoLog.Lines.Add('���������� ���� (�������� ������) - ' + rootNodeOrders.ChildNodes['QTY_CASES'].Text);
          memoLog.Lines.Add('���-�� ���� ������ ' + rootNodeOrders.ChildNodes['QTY_BOTTLES'].Text);
          memoLog.Lines.Add('���-�� ���������� (��������) �������� ' + rootNodeOrders.ChildNodes['FREE_CASE'].Text);
          memoLog.Lines.Add('������(���.) �� ������ ��������� ��� ��� ' + rootNodeOrders.ChildNodes['DISCOUNT'].Text);
          memoLog.Lines.Add('���� �� ��. � ���. ��� ��� � ������ ������  ' + rootNodeOrders.ChildNodes['PRICE_CASE'].Text);
          memoLog.Lines.Add('���� �� 1 ����� �������� ������ (������, ����������, �������) - ' + rootNodeOrders.ChildNodes['PRICE_EA'].Text);
          memoLog.Lines.Add('��� ������ ������������� CCH ' + rootNodeOrders.ChildNodes['ACTGRINUM'].Text);
          memoLog.Lines.Add('���-�� �������� �� ������� - ' + rootNodeOrders.ChildNodes['CASES_DISCOUNTED'].Text);
          memoLog.Lines.Add('������������� ����� �������� -  ' + rootNodeOrders.ChildNodes['DISCOUNT_PROMO_ID'].Text);
          memoLog.Lines.Add('�������� ��������� �� ������ - ' + rootNodeOrders.ChildNodes['GROSS_VALUE'].Text);
          memoLog.Lines.Add('�������� ������ ' + rootNodeOrders.ChildNodes['INPUT_CHANNEL'].Text);

          memoLog.Lines.Add(EmptyStr);
          currOrder := rootNodeOrders.ChildNodes['ORDERID'].Text;

        except
          on ex: Exception do
            Begin
              memoLog.Lines.Add('������ ��������� ����. ���������: ' + ex.Message);
              Continue;
            End;
        end;
    finally
      XMLDoc.Active := False;
    end;
end;

// ��������� ���������� ����� �� ����� In
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

end.
