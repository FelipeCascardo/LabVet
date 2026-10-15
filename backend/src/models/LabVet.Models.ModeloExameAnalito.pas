unit LabVet.Models.ModeloExameAnalito;

interface

uses
  System.JSON,
  System.SysUtils,

  LabVet.Models.Base;

type
  TModeloExameAnalito = class(TEntidadeAuditavel)
  public
    IdModeloExameAnalito: Int64;
    IdModeloExame: Int64;
    IdExameAnalito: Int64;
    DsSecao: string;
    NrExibicao: Integer;
    DsRotulo: string;
    DsTecnica: string;
    DsUnidadeMedida: string;
    DsReferencia: string;
    VrRefMinimo: TTextoOpcional;
    VrRefMaximo: TTextoOpcional;
    VrRefPerMinimo: TNumeroOpcional;
    VrRefPerMaximo: TNumeroOpcional;
    constructor Create;
    class function FromJSON(AJSON: TJSONObject): TModeloExameAnalito; static;
    function ToJSON: TJSONObject;
  end;

implementation

procedure LerTextoOpcional(
  AJSON: TJSONObject;
  const ANome: string;
  var ADestino: TTextoOpcional
);
var
  LValor: TJSONValue;
begin
  LValor := AJSON.GetValue(ANome);
  if Assigned(LValor) and not (LValor is TJSONNull) then
  begin
    ADestino.PossuiValor := True;
    ADestino.Valor := LValor.Value;
  end;
end;

procedure LerNumeroOpcional(
  AJSON: TJSONObject;
  const ANome: string;
  var ADestino: TNumeroOpcional
);
var
  LValor: TJSONValue;
begin
  LValor := AJSON.GetValue(ANome);
  if Assigned(LValor) and not (LValor is TJSONNull) then
  begin
    ADestino.PossuiValor := True;
    ADestino.Valor := LValor.GetValue<Extended>;
  end;
end;

class function TModeloExameAnalito.FromJSON(
  AJSON: TJSONObject
): TModeloExameAnalito;
var
  LValor: TJSONValue;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');

  Result := TModeloExameAnalito.Create;
  Result.IdModeloExame := AJSON.GetValue<Int64>('idModeloExame');
  Result.IdExameAnalito := AJSON.GetValue<Int64>('idExameAnalito');
  Result.NrExibicao := AJSON.GetValue<Integer>('ordem');

  LValor := AJSON.GetValue('secao');
  if Assigned(LValor) then
    Result.DsSecao := LValor.Value;

  LValor := AJSON.GetValue('rotulo');
  if Assigned(LValor) then
    Result.DsRotulo := LValor.Value;

  LValor := AJSON.GetValue('tecnica');
  if Assigned(LValor) then
    Result.DsTecnica := LValor.Value;

  LValor := AJSON.GetValue('unidadeMedida');
  if Assigned(LValor) then
    Result.DsUnidadeMedida := LValor.Value;

  LValor := AJSON.GetValue('referencia');
  if Assigned(LValor) then
    Result.DsReferencia := LValor.Value;

  LerTextoOpcional(AJSON, 'referenciaMinima', Result.VrRefMinimo);
  LerTextoOpcional(AJSON, 'referenciaMaxima', Result.VrRefMaximo);
  LerNumeroOpcional(AJSON, 'referenciaPercentualMinima', Result.VrRefPerMinimo);
  LerNumeroOpcional(AJSON, 'referenciaPercentualMaxima', Result.VrRefPerMaximo);
end;

function TModeloExameAnalito.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdModeloExameAnalito));
  Result.AddPair('idModeloExame', TJSONNumber.Create(IdModeloExame));
  Result.AddPair('idExameAnalito', TJSONNumber.Create(IdExameAnalito));
  Result.AddPair('secao', DsSecao);
  Result.AddPair('ordem', TJSONNumber.Create(NrExibicao));
  Result.AddPair('rotulo', DsRotulo);
  Result.AddPair('tecnica', DsTecnica);
  Result.AddPair('unidadeMedida', DsUnidadeMedida);
  Result.AddPair('referencia', DsReferencia);

  if VrRefMinimo.PossuiValor then
    Result.AddPair('referenciaMinima', VrRefMinimo.Valor)
  else
    Result.AddPair('referenciaMinima', TJSONNull.Create);

  if VrRefMaximo.PossuiValor then
    Result.AddPair('referenciaMaxima', VrRefMaximo.Valor)
  else
    Result.AddPair('referenciaMaxima', TJSONNull.Create);

  if VrRefPerMinimo.PossuiValor then
    Result.AddPair('referenciaPercentualMinima', TJSONNumber.Create(VrRefPerMinimo.Valor))
  else
    Result.AddPair('referenciaPercentualMinima', TJSONNull.Create);

  if VrRefPerMaximo.PossuiValor then
    Result.AddPair('referenciaPercentualMaxima', TJSONNumber.Create(VrRefPerMaximo.Valor))
  else
    Result.AddPair('referenciaPercentualMaxima', TJSONNull.Create);

  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

constructor TModeloExameAnalito.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
