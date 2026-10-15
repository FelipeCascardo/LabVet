unit LabVet.Services.Analito;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.Analito;

type
  EAnalitoValidacao = class(Exception);
  EAnalitoNaoEncontrado = class(Exception);

  TAnalitoService = class
  private
    procedure Validar(AValue: TAnalito);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TAnalito>;
    function ObterPorId(AId: Int64): TAnalito;
    function Criar(AValue: TAnalito; AActorId: Int64): TAnalito;
    function Atualizar(AId: Int64; AValue: TAnalito; AActorId: Int64): TAnalito;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Repositories.Analito;

procedure TAnalitoService.Validar(AValue: TAnalito);
begin
  if not Assigned(AValue) then
    raise EAnalitoValidacao.Create('Analito obrigatório.');
  if AValue.CdAnalito.Trim.IsEmpty or
    (Length(AValue.CdAnalito.Trim) > 100) then
    raise EAnalitoValidacao.Create('Informe um código de até 100 caracteres.');
  if AValue.NmAnalito.Trim.IsEmpty or
    (Length(AValue.NmAnalito.Trim) > 200) then
    raise EAnalitoValidacao.Create('Informe um nome de até 200 caracteres.');
  if not (AValue.TpValor in [tvaInteiro..tvaCaractere]) then
    raise EAnalitoValidacao.Create('Tipo de valor inválido.');
end;

function TAnalitoService.Listar(ApenasAtivos: Boolean): TObjectList<TAnalito>;
var
  LRepository: TAnalitoRepository;
begin
  LRepository := TAnalitoRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TAnalitoService.ObterPorId(AId: Int64): TAnalito;
var
  LRepository: TAnalitoRepository;
begin
  LRepository := TAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EAnalitoNaoEncontrado.Create('Analito não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TAnalitoService.Criar(AValue: TAnalito; AActorId: Int64): TAnalito;
var
  LExisting: TAnalito;
  LRepository: TAnalitoRepository;
begin
  Validar(AValue);

  LRepository := TAnalitoRepository.Create;
  try
    LExisting := LRepository.FindByCode(AValue.CdAnalito.Trim);
    try
      if Assigned(LExisting) then
        raise EAnalitoValidacao.Create('Já existe analito com este código.');
    finally
      LExisting.Free;
    end;

    AValue.CdAnalito := AValue.CdAnalito.Trim;
    AValue.NmAnalito := AValue.NmAnalito.Trim;
    AValue.DsTecnica := AValue.DsTecnica.Trim;
    AValue.DsUnidadeMedida := AValue.DsUnidadeMedida.Trim;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TAnalitoService.Atualizar(
  AId: Int64;
  AValue: TAnalito;
  AActorId: Int64
): TAnalito;
var
  LExisting: TAnalito;
  LRepository: TAnalitoRepository;
begin
  Validar(AValue);

  LRepository := TAnalitoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EAnalitoNaoEncontrado.Create('Analito não encontrado.');

    LExisting := LRepository.FindByCode(AValue.CdAnalito.Trim);
    try
      if Assigned(LExisting) and (LExisting.IdAnalito <> AId) then
        raise EAnalitoValidacao.Create('Já existe analito com este código.');
    finally
      LExisting.Free;
    end;

    Result.CdAnalito := AValue.CdAnalito.Trim;
    Result.NmAnalito := AValue.NmAnalito.Trim;
    Result.DsTecnica := AValue.DsTecnica.Trim;
    Result.DsUnidadeMedida := AValue.DsUnidadeMedida.Trim;
    Result.TpValor := AValue.TpValor;
    Result.FgPercentual := AValue.FgPercentual;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TAnalitoService.DefinirAtivo(
  AId: Int64;
  AAtivo: Boolean;
  AActorId: Int64
);
var
  LRepository: TAnalitoRepository;
begin
  LRepository := TAnalitoRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EAnalitoNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
