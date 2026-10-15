unit LabVet.Models.ExameAnalito;

interface

uses
  System.JSON,
  System.SysUtils,
  LabVet.Models.Base;

type
  TExameAnalito = class(TEntidadeAuditavel)
  public
    IdExameAnalito: Int64;
    IdExame: Int64;
    IdAnalito: Int64;
    constructor Create;
    class function FromJSON(AJSON: TJSONObject): TExameAnalito; static;
    function ToJSON: TJSONObject;
  end;

implementation

class function TExameAnalito.FromJSON(AJSON: TJSONObject): TExameAnalito;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  Result := TExameAnalito.Create;
  Result.IdExame := AJSON.GetValue<Int64>('idExame');
  Result.IdAnalito := AJSON.GetValue<Int64>('idAnalito');
end;

function TExameAnalito.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdExameAnalito));
  Result.AddPair('idExame', TJSONNumber.Create(IdExame));
  Result.AddPair('idAnalito', TJSONNumber.Create(IdAnalito));
  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

constructor TExameAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
