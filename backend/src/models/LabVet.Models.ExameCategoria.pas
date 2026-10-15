unit LabVet.Models.ExameCategoria;

interface

uses
  System.JSON,
  System.SysUtils,

  LabVet.Models.Base;

type
  TExameCategoria = class(TEntidadeAuditavel)
  public
    IdExameCategoria: Int64;
    NmCategoria: string;
    class function FromJSON(AJSON: TJSONObject): TExameCategoria; static;
    function ToJSON: TJSONObject;
  end;

implementation

class function TExameCategoria.FromJSON(AJSON: TJSONObject): TExameCategoria;
var
  LValue: TJSONValue;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');

  Result := TExameCategoria.Create;
  LValue := AJSON.GetValue('nome');
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result.NmCategoria := LValue.Value;
end;

function TExameCategoria.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdExameCategoria));
  Result.AddPair('nome', NmCategoria);
  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

end.
