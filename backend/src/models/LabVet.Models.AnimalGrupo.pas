unit LabVet.Models.AnimalGrupo;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Generics.Collections,
  LabVet.Models.Base;

type
  TAnimalGrupo = class(TEntidadeAuditavel)
  private
    FFilhos: TObjectList<TAnimalGrupo>;
  public
    IdAnimalGrupo: Int64;
    IdAnimalGrupoPai: TInteiro64Opcional;
    NmAnimalGrupo: string;
    DsDescricao: string;
    constructor Create;
    destructor Destroy; override;
    class function FromJSON(AJSON: TJSONObject): TAnimalGrupo; static;
    function ToJSON: TJSONObject;
    property Filhos: TObjectList<TAnimalGrupo> read FFilhos;
  end;

implementation

class function TAnimalGrupo.FromJSON(AJSON: TJSONObject): TAnimalGrupo;
var
  LValue: TJSONValue;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('O corpo da requisição deve ser um JSON válido.');
  Result := TAnimalGrupo.Create;
  LValue := AJSON.GetValue('nome');
  if Assigned(LValue) then
    Result.NmAnimalGrupo := LValue.Value;
  LValue := AJSON.GetValue('descricao');
  if Assigned(LValue) then
    Result.DsDescricao := LValue.Value;
  LValue := AJSON.GetValue('idGrupoPai');
  if Assigned(LValue) and not (LValue is TJSONNull) then
  begin
    Result.IdAnimalGrupoPai.PossuiValor := True;
    Result.IdAnimalGrupoPai.Valor := LValue.GetValue<Int64>;
  end;
end;

function TAnimalGrupo.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(IdAnimalGrupo));
  Result.AddPair('nome', NmAnimalGrupo);
  Result.AddPair('descricao', DsDescricao);
  if IdAnimalGrupoPai.PossuiValor then
    Result.AddPair('idGrupoPai', TJSONNumber.Create(IdAnimalGrupoPai.Valor))
  else
    Result.AddPair('idGrupoPai', TJSONNull.Create);
  Result.AddPair('ativo', TJSONBool.Create(StAtivo));
end;

constructor TAnimalGrupo.Create;
begin
  inherited Create;
  StAtivo := True;
  FFilhos := TObjectList<TAnimalGrupo>.Create(True);
end;

destructor TAnimalGrupo.Destroy;
begin
  FFilhos.Free;
  inherited Destroy;
end;

end.
