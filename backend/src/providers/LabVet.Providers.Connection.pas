unit LabVet.Providers.Connection;

interface

uses FireDAC.Comp.Client;

type
  TLabVetConnection = class
  public
    class function NewConnection: TFDConnection; static;
  end;

implementation

uses
  FireDAC.Phys, FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  LabVet.Providers.Config;

class function TLabVetConnection.NewConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  TLabVetConfig.ApplyDatabaseParams(Result);
  Result.LoginPrompt := False;
  Result.Open;
  Result.ExecSQL('set search_path to labvet, public');
end;

end.
