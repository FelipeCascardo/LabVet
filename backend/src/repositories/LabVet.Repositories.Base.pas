unit LabVet.Repositories.Base;

interface

uses FireDAC.Comp.Client;

type
  TBaseRepository = class
  private
    FConnection: TFDConnection;
    FOwnsConnection: Boolean;
  protected
    function NewQuery: TFDQuery;
  public
    constructor Create; virtual;
    constructor CreateWithConnection(AConnection: TFDConnection); virtual;
    destructor Destroy; override;
    property DatabaseConnection: TFDConnection read FConnection;
  end;

implementation

uses System.SysUtils, LabVet.Providers.Connection;

constructor TBaseRepository.Create;
begin
  inherited Create;
  FConnection := TLabVetConnection.NewConnection;
  FOwnsConnection := True;
end;

constructor TBaseRepository.CreateWithConnection(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise EArgumentNilException.Create('A conexão compartilhada é obrigatória.');
  FConnection := AConnection;
  FOwnsConnection := False;
end;

destructor TBaseRepository.Destroy;
begin
  if FOwnsConnection then
    FConnection.Free;
  inherited;
end;

function TBaseRepository.NewQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConnection;
end;

end.
