unit LabVet.Providers.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Phys.IBBase,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  System.IOUtils,
  Winapi.Windows;

type
  TLabVetConnectionDataModule = class(TDataModule)
    fdcLabVet: TFDConnection;
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
  LVendorHome: string;
begin
  ConfigureClientLibraryPath;

  if not Assigned(LabVetConnectionDataModule) then
  begin
    LabVetConnectionDataModule := TLabVetConnectionDataModule.Create(nil);
    LVendorHome := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
    LabVetConnectionDataModule.fdpPostgre.VendorHome := LVendorHome;
    LabVetConnectionDataModule.fdpPostgre.VendorLib := 'libpq.dll';
  end;
end;

class function TLabVetConnection.NewConnection: TFDConnection;
begin
  EnsureDriver;
  Result := TFDConnection.Create(nil);
  Result.Params.Assign(LabVetConnectionDataModule.fdcLabVet.Params);
  TLabVetConfig.ApplyDatabaseParams(Result);
  Result.LoginPrompt := False;
  Result.Open;
  Result.ExecSQL('set search_path to labvet, public');
end;

Initialization

Finalization
  LabVetConnectionDataModule.Free;

end.

