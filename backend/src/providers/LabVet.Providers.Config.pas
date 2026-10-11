unit LabVet.Providers.Config;

interface

uses FireDAC.Comp.Client;

type
  TLabVetConfig = class
  public
    class function GetValue(const AName: string; const ADefault: string = ''): string; static;
    class procedure ApplyDatabaseParams(AConnection: TFDConnection); static;
  end;

implementation

uses System.Classes, System.IOUtils, System.SysUtils;

class function TLabVetConfig.GetValue(const AName: string;
  const ADefault: string): string;
var
  LEnvFile: string;
  LValues: TStringList;
begin
  Result := GetEnvironmentVariable(AName);
  if Result.IsEmpty then
  begin
    LEnvFile := GetEnvironmentVariable('LABVET_ENV_FILE');
    if LEnvFile.IsEmpty then
      LEnvFile := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\.env'));
    if TFile.Exists(LEnvFile) then
    begin
      LValues := TStringList.Create;
      try
        LValues.LoadFromFile(LEnvFile);
        Result := LValues.Values[AName].Trim;
      finally
        LValues.Free;
      end;
    end;
  end;
  if Result.IsEmpty then
    Result := ADefault;
end;

class procedure TLabVetConfig.ApplyDatabaseParams(AConnection: TFDConnection);
var
  LPassword: string;
begin
  LPassword := GetValue('POSTGRES_PASSWORD');
  if LPassword.IsEmpty then
    raise EInvalidOp.Create('Defina POSTGRES_PASSWORD no arquivo .env local.');

  AConnection.Params.Values['DriverID'] := 'PG';
  AConnection.Params.Values['Server'] := GetValue('POSTGRES_HOST', '127.0.0.1');
  AConnection.Params.Values['Port'] := GetValue('POSTGRES_PORT', '5434');
  AConnection.Params.Values['Database'] := GetValue('POSTGRES_DB', 'labvet');
  AConnection.Params.Values['User_Name'] := GetValue('POSTGRES_USER', 'labvet_app');
  AConnection.Params.Values['Password'] := LPassword;
  AConnection.Params.Values['CharacterSet'] := 'UTF8';
end;

end.
