program CocaColaSFALite;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fmMain},
  DM in 'DM.pas' {AppData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TAppData, AppData);
  Application.Run;
end.
