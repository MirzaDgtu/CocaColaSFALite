unit DM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TAppData = class(TDataModule)
    Connection: TADOConnection;
    Cmd: TADOCommand;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AppData: TAppData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
