unit LabVet.Models.Analito;

interface

uses
  System.JSON,
  System.SysUtils,

  LabVet.Models.Base;

type
  TTipoValorAnalito = (
    tvaInteiro = 1,
    tvaDecimal = 2,
    tvaCaractere = 3
  );

  TAnalito = class(TEntidadeAuditavel)
  public
    IdAnalito: Int64;
    CdAnalito: string;
    NmAnalito: string;
    DsTecnica: string;
    DsUnidadeMedida: string;
    TpValor: TTipoValorAnalito;
    FgPercentual: Boolean;
    constructor Create;
    class function FromJSON(AJSON: TJSONObject): TAnalito; static;
    function ToJSON: TJSONObject;
  end;

implementation

class function TAnalito.FromJSON(AJSON: TJSONObject): TAnalito;
var
  LValue: TJSONValue;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');

  Result := TAnalito.Create;
  LValue := AJSON.GetValue('codigo');
  if Assigned(LValue) then Result.CdAnalito := LValue.Value;
  LValue := AJSON.GetValue('nome');
  if Assigned(LValue) then Result.NmAnalito := LValue.Value;
  LValue := AJSON.GetValue('tecnica');
  if Assigned(LValue) then Result.DsTecnica := LValue.Value;
  LValue := AJSON.GetValue('unidadeMedida');
  if Assigned(LValue) then Result.DsUnidadeMedida := LValue.Value;
  LValue := AJSON.GetValue('tipoValor');
  if Assigned(LValue) then Result.TpValor := TTipoValorAnalito(LValue.GetValue<Integer>);
  LValue := AJSON.GetValue('percentual');
  if Assigned(LValue) then Result.FgPercentual := LValue.GetValue<Boolean>;
end;

function TAnalito.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdAnalito));
  Result.AddPair('codigo', CdAnalito);
  Result.AddPair('nome', NmAnalito);
  Result.AddPair('tecnica', DsTecnica);
  Result.AddPair('unidadeMedida', DsUnidadeMedida);
  Result.AddPair('tipoValor', TJSONNumber.Create(Ord(TpValor)));
  Result.AddPair('percentual', TJSONBool.Create(FgPercentual));
  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

constructor TAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
  TpValor := tvaCaractere;
end;

end.
