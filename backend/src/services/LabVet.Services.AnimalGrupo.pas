unit LabVet.Services.AnimalGrupo;

interface

uses
  System.Generics.Collections,
  System.SysUtils,

  LabVet.Models.AnimalGrupo;

type
  EAnimalGrupoValidacao = class(Exception);
  EAnimalGrupoNaoEncontrado = class(Exception);

  TAnimalGrupoService = class
  private
    procedure Validar(AValue: TAnimalGrupo; AIdAtual: Int64 = 0);
  public
    function Listar(ApenasAtivos: Boolean = True): TObjectList<TAnimalGrupo>;
    function ObterPorId(AId: Int64): TAnimalGrupo;
    function Criar(AValue: TAnimalGrupo; AActorId: Int64): TAnimalGrupo;
    function Atualizar(AId: Int64; AValue: TAnimalGrupo; AActorId: Int64): TAnimalGrupo;
    procedure DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
  end;

implementation

uses
  LabVet.Repositories.AnimalGrupo;

procedure TAnimalGrupoService.Validar(AValue: TAnimalGrupo; AIdAtual: Int64);
var
  LParent: TAnimalGrupo;
  LRepository: TAnimalGrupoRepository;
begin
  if not Assigned(AValue) then
    raise EAnimalGrupoValidacao.Create('Grupo de animais obrigatório.');

  if AValue.NmAnimalGrupo.Trim.IsEmpty or
    (Length(AValue.NmAnimalGrupo.Trim) > 150) then
    raise EAnimalGrupoValidacao.Create('Informe um nome de até 150 caracteres.');

  if Length(AValue.DsDescricao.Trim) > 500 then
    raise EAnimalGrupoValidacao.Create('A descrição deve ter no máximo 500 caracteres.');

  if AValue.IdAnimalGrupoPai.PossuiValor then
  begin
    if AValue.IdAnimalGrupoPai.Valor = AIdAtual then
      raise EAnimalGrupoValidacao.Create('Um grupo não pode ser seu próprio pai.');

    LRepository := TAnimalGrupoRepository.Create;
    try
      LParent := LRepository.FindById(AValue.IdAnimalGrupoPai.Valor);
      try
        if (not Assigned(LParent)) or (not LParent.StAtivo) then
          raise EAnimalGrupoValidacao.Create('Grupo pai não encontrado ou inativo.');
      finally
        LParent.Free;
      end;
    finally
      LRepository.Free;
    end;
  end;
end;

function TAnimalGrupoService.Listar(
  ApenasAtivos: Boolean
): TObjectList<TAnimalGrupo>;
var
  LRepository: TAnimalGrupoRepository;
begin
  LRepository := TAnimalGrupoRepository.Create;
  try
    Result := LRepository.List(ApenasAtivos);
  finally
    LRepository.Free;
  end;
end;

function TAnimalGrupoService.ObterPorId(AId: Int64): TAnimalGrupo;
var
  LRepository: TAnimalGrupoRepository;
begin
  LRepository := TAnimalGrupoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if not Assigned(Result) then
      raise EAnimalGrupoNaoEncontrado.Create('Grupo de animais não encontrado.');
  finally
    LRepository.Free;
  end;
end;

function TAnimalGrupoService.Criar(AValue: TAnimalGrupo; AActorId: Int64): TAnimalGrupo;
var
  LRepository: TAnimalGrupoRepository;
begin
  Validar(AValue);
  LRepository := TAnimalGrupoRepository.Create;
  try
    AValue.NmAnimalGrupo := AValue.NmAnimalGrupo.Trim;
    AValue.DsDescricao := AValue.DsDescricao.Trim;
    LRepository.Insert(AValue, AActorId);
    Result := AValue;
  finally
    LRepository.Free;
  end;
end;

function TAnimalGrupoService.Atualizar(AId: Int64; AValue: TAnimalGrupo; AActorId: Int64): TAnimalGrupo;
var
  LRepository: TAnimalGrupoRepository;
begin
  Validar(AValue, AId);
  LRepository := TAnimalGrupoRepository.Create;
  try
    Result := LRepository.FindById(AId);
    if (not Assigned(Result)) or (not Result.StAtivo) then
      raise EAnimalGrupoNaoEncontrado.Create('Grupo de animais não encontrado.');
    Result.NmAnimalGrupo := AValue.NmAnimalGrupo.Trim;
    Result.DsDescricao := AValue.DsDescricao.Trim;
    Result.IdAnimalGrupoPai := AValue.IdAnimalGrupoPai;
    LRepository.Update(Result, AActorId);
  finally
    LRepository.Free;
  end;
end;

procedure TAnimalGrupoService.DefinirAtivo(AId: Int64; AAtivo: Boolean; AActorId: Int64);
var
  LRepository: TAnimalGrupoRepository;
begin
  LRepository := TAnimalGrupoRepository.Create;
  try
    try
      LRepository.SetActive(AId, AAtivo, AActorId);
    except
      on E: EInvalidOp do
        raise EAnimalGrupoNaoEncontrado.Create(E.Message);
    end;
  finally
    LRepository.Free;
  end;
end;

end.
