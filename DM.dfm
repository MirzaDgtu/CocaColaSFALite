object AppData: TAppData
  OldCreateOrder = False
  Height = 296
  Width = 328
  object Connection: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=M5i4r6z3a210;Persist Security Info=' +
      'True;User ID=pmp;Initial Catalog=REPORTS;Data Source=DC-07\F2012' +
      'SQL'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 40
    Top = 32
  end
  object Cmd: TADOCommand
    Connection = Connection
    Parameters = <>
    Left = 40
    Top = 96
  end
end
