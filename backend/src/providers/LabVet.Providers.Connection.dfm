object LabVetConnectionDataModule: TLabVetConnectionDataModule
  Height = 150
  Width = 215
  object fdcLabVet: TFDConnection
    Params.Strings = (
      'DriverID=PG')
    LoginPrompt = False
    Left = 24
    Top = 40
  end
  object fdpPostgre: TFDPhysPgDriverLink
    DriverID = 'PG'
    VendorLib = 'libpq.dll'
    Left = 72
    Top = 40
  end
end
