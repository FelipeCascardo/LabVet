unit LabVet.Providers.Connection;

interface

uses
  System.Classes,
  FireDAC.Comp.Client,
  FireDAC.Phys.PG;

type
  TLabVetConnectionDataModule = class(TDataModule)
    fdpPostgre: TFDPhysPgDriverLink;
  end;

  TLabVetConnection = class
  private
    class procedure ConfigureClientLibraryPath; static;
    class procedure EnsureDriver; static;
  public
    class function NewConnection: TFDConnection; static;
  end;

var
  LabVetConnectionDataModule: TLabVetConnectionDataModule;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  Winapi.Windows,
  FireDAC.Phys,
  FireDAC.Phys.PGDef,
  FireDAC.Stan.Def,
  LabVet.Providers.Config;

{$R *.dfm}

class procedure TLabVetConnection.ConfigureClientLibraryPath;
var
  LClientLibraryPath: string;
begin
  LClientLibraryPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Lib');
  if not TDirectory.Exists(LClientLibraryPath) then
    raise EDirectoryNotFoundException.CreateFmt(
      'Bibliotecas PostgreSQL não encontradas em "%s".',
      [LClientLibraryPath]
    );

  if not SetDllDirectory(PChar(LClientLibraryPath)) then
    RaiseLastOSError;
end;

class procedure TLabVetConnection.EnsureDriver;
var
  LClientLibraryPath: string;
begin
  ConfigureClientLibraryPath;

  if not Assigned(LabVetConnectionDataModule) then
  begin
    LabVetConnectionDataModule := TLabVetConnectionDataModule.Create(nil);
    LClientLibraryPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Lib');
    LabVetConnectionDataModule.fdpPostgre.VendorHome := LClientLibraryPath;
    LabVetConnectionDataModule.fdpPostgre.VendorLib := 'libpq.dll';
  end;
end;

class function TLabVetConnection.NewConnection: TFDConnection;
begin
  EnsureDriver;
  Result := TFDConnection.Create(nil);
  TLabVetConfig.ApplyDatabaseParams(Result);
  Result.LoginPrompt := False;
  Result.Open;
  Result.ExecSQL('set search_path to labvet, public');
end;

finalization
  LabVetConnectionDataModule.Free;

end.
