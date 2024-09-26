object dtmPrincipal: TdtmPrincipal
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object qryExecute: TFDQuery
    Connection = FDConnection
    Left = 368
    Top = 32
  end
  object FDTransaction: TFDTransaction
    Connection = FDConnection
    Left = 200
    Top = 32
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    Left = 80
    Top = 32
  end
end
